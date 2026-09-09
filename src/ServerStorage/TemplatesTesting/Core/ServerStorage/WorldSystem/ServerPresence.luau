--!strict
local Players = game:GetService("Players")
local MemoryStoreService = game:GetService("MemoryStoreService")
local RunService = game:GetService("RunService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RETRY_BASE_WAIT = 0.25
local UPDATE_INTERVAL = 30
local ACTIVE_TTL = 120
local MAX_RETRIES = 6
-- Un throttle no es un fallo transitorio: es MemoryStore avisando de que la cuota del
-- universo está agotada. Reintentar lo prolonga, así que dejamos de pedir del todo
-- durante este rato. Sigue holgado bajo ACTIVE_TTL, así que la entrada no llega a expirar.
local THROTTLE_COOLDOWN = 60
-- Entrar y salir dispara refresh. Sin esta ventana, diez jugadores entrando a la vez son
-- diez UpdateAsync; con ella es uno solo, y con la lista ya completa.
local REFRESH_DEBOUNCE = 2
local ACTIVE_MAP_NAME = "UserServerRegistry_Test"
local MSG_TOPIC_UPDATE = "UserServerRegistryUpdate"
local MSG_TOPIC_CLOSED = "UserServerRegistryClosed"

--[=[
	@class ServerPresence

	Mantiene este servidor anunciado en el directorio entre servidores: un hash map de
	MemoryStore (`UserServerRegistry_Test`) que asocia una **clave de servidor** con todo
	lo que otro servidor necesita para mandar aquí a un jugador.

	Lo usan todos los tipos de servidor, y cada uno aporta su propia forma de clave y su
	propio contenido:

	| Servidor | Clave | `hostingType` | Se entra con |
	| --- | --- | --- | --- |
	| Place público | `"{PlaceId}_{JobId}"` | `"default"` | `TeleportOptions.ServerInstanceId` |
	| Casa de jugador | `"{UserId}_{roomName}"` | `"room"` | `ReservedServerAccessCode` |
	| Evento | clave del evento | `"event"` | `ReservedServerAccessCode` |

	La entrada lleva un TTL de `ACTIVE_TTL` (120 s) y se refresca por heartbeat cada
	`UPDATE_INTERVAL` (30 s), así que un servidor que muera sin ejecutar `Cleanup`
	desaparece del directorio por sí solo dentro del TTL. Cada escritura se publica además
	por `MessagingService` (`UserServerRegistryUpdate` / `UserServerRegistryClosed`) para
	que los oyentes puedan reaccionar antes del siguiente sondeo.

	El throttling de MemoryStore se trata aparte de un fallo de MemoryStore: un fallo
	transitorio se reintenta con backoff exponencial, mientras que un throttle detiene los
	reintentos y pausa todos los refrescos durante `THROTTLE_COOLDOWN` (60 s), que sigue
	holgadamente por debajo del TTL.

	@server
]=]
local ServerPresence = {}
ServerPresence.__index = ServerPresence
ServerPresence.__tostring = function(self) return `<ServerPresence:{self.ServerKey}>` end

type self = {
	ServerKey: string,
	GetRefreshPayload: (old: any?) -> any,
	OnStarted: (() -> ())?,
	OnCleanup: (() -> ())?,

	_activeMap: MemoryStoreHashMap,
	_updaterConnection: RBXScriptConnection?,
	_playerConnections: { RBXScriptConnection },
	_nextTick: number,
	_blockedUntil: number,
}

export type ServerPresence = typeof(setmetatable({} :: self, ServerPresence))

export type ManagerConfig = {
	ServerKey: string,
	GetRefreshPayload: (old: any?) -> any,
	OnStarted: (() -> ())?,
	OnCleanup: (() -> ())?,
}

local function backoff(attempt: number)
	task.wait(RETRY_BASE_WAIT * 2 ^ (attempt - 1))
end

--[[
	¿MemoryStore nos está frenando? Es distinto de "MemoryStore falló": ante un fallo
	transitorio reintentar es lo correcto; ante un throttle es justo lo que lo alarga.
]]
local function isThrottled(err: any): boolean
	local text = tostring(err)
	return string.find(text, "RequestThrottled", 1, true) ~= nil
		or string.find(text, "TotalRequestsOverLimit", 1, true) ~= nil
end

local function safeRemove(map: MemoryStoreHashMap, key: string): (boolean, boolean)
	local attempt = 0
	local success = false
	local throttled = false
	repeat
		attempt += 1
		local ok, err: any = pcall(map.RemoveAsync, map, key)
		if ok then
			success = true
		elseif isThrottled(err) then
			throttled = true
			warn("[ServerPresence] RemoveAsync throttled; abandono los reintentos.")
		else
			warn(string.format("[ServerPresence] RemoveAsync fail (%d): %s", attempt, err))
			backoff(attempt)
		end
	until success or throttled or attempt == MAX_RETRIES
	return success, throttled
end

local function safeUpdate(map: MemoryStoreHashMap, key: string, updateFn: (any?) -> any, ttl: number): (boolean, any, boolean)
	local attempt = 0
	local success = false
	local throttled = false
	local newValue = nil
	repeat
		attempt += 1
		local ok, value = pcall(map.UpdateAsync, map, key, updateFn, ttl)
		if ok then
			success = true
			newValue = value
		elseif isThrottled(value) then
			throttled = true
			warn("[ServerPresence] UpdateAsync throttled; abandono los reintentos.")
		else
			warn(string.format("[ServerPresence] UpdateAsync fail (%d): %s", attempt, value))
			backoff(attempt)
		end
	until success or throttled or attempt >= MAX_RETRIES
	return success, newValue, throttled
end

local function publishUpdate(serverKey: string, info: {[string]: any})
	local ok, err = pcall(MessagingService.PublishAsync, MessagingService, MSG_TOPIC_UPDATE, {
		key = serverKey,
		info = info,
	})
	if not ok then warn("[ServerPresence] MS publish update failed:", err) end
end

local function publishClosed(serverKey: string)
	local ok, err = pcall(MessagingService.PublishAsync, MessagingService, MSG_TOPIC_CLOSED, serverKey)
	if not ok then warn("[ServerPresence] MS publish closed failed:", err) end
end

--[=[
	@within ServerPresence

	Crea un manejador de presencia. No se escribe nada hasta llamar a [ServerPresence:Start].
]=]
function ServerPresence.new(config: ManagerConfig): ServerPresence
	local self = setmetatable({} :: any, ServerPresence)

	self.ServerKey = config.ServerKey
	self.GetRefreshPayload = config.GetRefreshPayload
	self.OnStarted = config.OnStarted
	self.OnCleanup = config.OnCleanup

	self._activeMap = ServerPresence.GetActiveMap()
	self._updaterConnection = nil
	self._playerConnections = {}
	self._nextTick = 0
	self._blockedUntil = 0

	return self
end

--[=[
	@within ServerPresence

	Escribe la entrada ahora y reprograma el siguiente refresco a un `UPDATE_INTERVAL`
	completo vista.

	El contenido viene del `GetRefreshPayload(old)` del llamante, que recibe el valor
	anterior y devuelve el nuevo; corre dentro de `UpdateAsync`, así que puede invocarse
	más de una vez. Si tiene éxito, el nuevo contenido se publica por `MessagingService`, y
	la primera vez que el contenido reporta `status == "ready"` mientras
	`ReplicatedStorage.ServerInfo` sigue en `"pending"`, se dispara `OnStarted`.

	Una escritura con throttle pausa los refrescos durante `THROTTLE_COOLDOWN`; cualquier
	otro fallo se deja para el siguiente tick del heartbeat.
]=]
function ServerPresence.RefreshNow(self: ServerPresence)
	self._nextTick = os.clock() + UPDATE_INTERVAL

	local success, newInfo, throttled = safeUpdate(self._activeMap, self.ServerKey, self.GetRefreshPayload, ACTIVE_TTL)

	if success then
		publishUpdate(self.ServerKey, newInfo)
		if newInfo.status == "ready" and ReplicatedStorage.ServerInfo:GetAttribute("status") == "pending" then
			if self.OnStarted then
				self.OnStarted()
			end
		end
		return
	end

	if throttled then
		self._blockedUntil = os.clock() + THROTTLE_COOLDOWN
		warn(("[ServerPresence] Cuota agotada; pauso los refresh de %s durante %ds."):format(self.ServerKey, THROTTLE_COOLDOWN))
	else
		warn(("[ServerPresence] TTL refresh failed for key %s; will try again on next tick."):format(self.ServerKey))
	end
end

--[[
	Pide un refresh "pronto" en vez de "ya". Un servidor lleno dispara muchos seguidos al
	entrar y salir gente; agrupándolos en una ventana corta, la lista que acaba publicándose
	es exactamente la misma y el gasto es de una sola petición.
]]
--[=[
	@within ServerPresence

	Pide un refresco *pronto* en vez de *ya*: adelanta el siguiente tick a
	`REFRESH_DEBOUNCE` (2 s) desde ahora, y nunca lo retrasa. Así, diez jugadores entrando
	a la vez cuestan una sola escritura con la lista completa en vez de diez.
]=]
function ServerPresence.RequestRefresh(self: ServerPresence)
	local soon = os.clock() + REFRESH_DEBOUNCE
	if soon < self._nextTick then
		self._nextTick = soon
	end
end

--[=[
	@within ServerPresence

	Publica la entrada y arranca el keepalive: una conexión a `Heartbeat` que refresca
	según lo programado, más conexiones a `PlayerAdded` / `PlayerRemoving` que piden un
	refresco anticipado para que la lista de jugadores anunciada no se quede atrás.
	Llamarlo dos veces no hace nada.
]=]
function ServerPresence.Start(self: ServerPresence)
	if self._updaterConnection then return end

	self:RefreshNow()

	self._updaterConnection = RunService.Heartbeat:Connect(function()
		local now = os.clock()
		if now >= self._nextTick and now >= self._blockedUntil then
			self:RefreshNow()
		end
	end)

	-- Guardadas para poder soltarlas en Cleanup. Si sobreviven al cierre, el jugador que sale
	-- reescribe la key que Cleanup acaba de borrar, y el servidor muerto se queda anunciado
	-- en el directorio hasta que expira su TTL.
	table.insert(self._playerConnections, Players.PlayerAdded:Connect(function()
		self:RequestRefresh()
	end))

	table.insert(self._playerConnections, Players.PlayerRemoving:Connect(function()
		self:RequestRefresh()
	end))
end

--[=[
	@within ServerPresence

	Detiene el keepalive y retira el servidor del directorio: desconecta el heartbeat y las
	conexiones de jugador, ejecuta `OnCleanup`, elimina la entrada de MemoryStore, publica
	`UserServerRegistryClosed`, y pone `ServerInfo.status` en `"closed"`.

	Las conexiones de jugador se sueltan **antes** de eliminar la entrada, a propósito. Si
	sobrevivieran, un `PlayerRemoving` disparado durante el apagado pediría un refresco que
	reescribiría la clave recién borrada, dejando un servidor muerto anunciado hasta que
	expire su TTL.

	Normalmente se llega desde `game:BindToClose`.
]=]
function ServerPresence.Cleanup(self: ServerPresence)
	if self._updaterConnection then
		self._updaterConnection:Disconnect()
		self._updaterConnection = nil
	end

	for _, connection in self._playerConnections do
		connection:Disconnect()
	end
	table.clear(self._playerConnections)

	if self.OnCleanup then
		self.OnCleanup()
	end

	safeRemove(self._activeMap, self.ServerKey)
	publishClosed(self.ServerKey)
	ReplicatedStorage.ServerInfo:SetAttribute("status", "closed")
end

--[=[
	@within ServerPresence

	Los `UserId` que están ahora en este servidor, tal y como se publican en el contenido del directorio.
]=]
function ServerPresence.GetPlayerList(): {number}
	local playerList = {}
	for _, player in Players:GetPlayers() do
		table.insert(playerList, player.UserId)
	end
	return playerList
end

--[=[
	@within ServerPresence

	Lee una entrada del directorio, reintentando los fallos transitorios de MemoryStore con
	backoff y abandonando de inmediato ante un throttle.

	@param map MemoryStoreHashMap -- normalmente [ServerPresence.GetActiveMap]
	@param key string -- la clave de servidor a buscar
	@return any -- la entrada, o nil si no existe o no se pudo leer
	@return boolean -- true cuando la lectura **falló**; datos nil con false significa "ese servidor no existe"
]=]
function ServerPresence.SafeGet(map: MemoryStoreHashMap, key: string): (any, boolean)
	local attempt = 0
	local data: {[string]: any}?
	local err = false
	local throttled = false
	repeat
		attempt += 1
		local ok, result = pcall(map.GetAsync, map, key)
		if ok then
			data = result
			err = false
		elseif isThrottled(result) then
			warn("[ServerPresence] GetAsync throttled; abandono los reintentos.")
			err = true
			throttled = true
		else
			warn(string.format("[ServerPresence] GetAsync fail (%d): %s", attempt, result))
			err = true
			backoff(attempt)
		end
	until data or throttled or attempt >= MAX_RETRIES

	if not err then return data, err else return nil, err end
end

--[=[
	@within ServerPresence

	El hash map de MemoryStore que respalda el directorio. Lo comparten todos los servidores del universo.
]=]
function ServerPresence.GetActiveMap(): MemoryStoreHashMap
	return MemoryStoreService:GetHashMap(ACTIVE_MAP_NAME)
end

--[=[
	@within ServerPresence

	Expulsa a todos con `message`. Se usa cuando un servidor no puede establecer una
	identidad válida. En Studio solo avisa, para no echar a nadie de una prueba local.
]=]
function ServerPresence.KickAll(message: string)
	if RunService:IsStudio() then
		warn("[ServerPresence] Kick ignored in Studio:", message)
	else
		for _, plr in ipairs(Players:GetPlayers()) do
			task.spawn(function() plr:Kick(message) end)
		end
	end
end

return ServerPresence
