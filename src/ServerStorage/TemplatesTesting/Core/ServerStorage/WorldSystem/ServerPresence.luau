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
function ServerPresence.RequestRefresh(self: ServerPresence)
	local soon = os.clock() + REFRESH_DEBOUNCE
	if soon < self._nextTick then
		self._nextTick = soon
	end
end

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

function ServerPresence.GetPlayerList(): {number}
	local playerList = {}
	for _, player in Players:GetPlayers() do
		table.insert(playerList, player.UserId)
	end
	return playerList
end

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

function ServerPresence.GetActiveMap(): MemoryStoreHashMap
	return MemoryStoreService:GetHashMap(ACTIVE_MAP_NAME)
end

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
