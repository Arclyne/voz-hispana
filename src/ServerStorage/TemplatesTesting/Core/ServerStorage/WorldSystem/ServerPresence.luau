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

	Keeps this server advertised in the cross-server directory, a MemoryStore hash map
	(`UserServerRegistry_Test`) that maps a **server key** to everything another server
	needs in order to send a player here.

	Every kind of server uses it, and each supplies its own key shape and payload:

	| Server | Key | `hostingType` | Joined by |
	| --- | --- | --- | --- |
	| Public place | `"{PlaceId}_{JobId}"` | `"default"` | `TeleportOptions.ServerInstanceId` |
	| Player house | `"{UserId}_{roomName}"` | `"room"` | `ReservedServerAccessCode` |
	| Event | event key | `"event"` | `ReservedServerAccessCode` |

	The entry carries a TTL of `ACTIVE_TTL` (120 s) and is refreshed on a heartbeat every
	`UPDATE_INTERVAL` (30 s), so a server that dies without running `Cleanup` disappears
	from the directory on its own within the TTL. Every write is also published over
	`MessagingService` (`UserServerRegistryUpdate` / `UserServerRegistryClosed`) so that
	listeners can react before the next poll.

	MemoryStore throttling is handled separately from MemoryStore failure: a transient
	failure is retried with exponential backoff, while a throttle stops the retries and
	pauses all refreshes for `THROTTLE_COOLDOWN` (60 s) — still well under the TTL.

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

	Creates a presence handle. Nothing is written until [ServerPresence:Start] is called.
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

	Writes the entry now and reschedules the next refresh a full `UPDATE_INTERVAL` out.

	The payload comes from the caller's `GetRefreshPayload(old)`, which receives the
	previous value and returns the new one — it runs inside `UpdateAsync`, so it may be
	invoked more than once. On success the new payload is published over
	`MessagingService`, and the first time the payload reports `status == "ready"` while
	`ReplicatedStorage.ServerInfo` still reads `"pending"`, `OnStarted` fires.

	A throttled write pauses refreshes for `THROTTLE_COOLDOWN`; any other failure is left
	for the next heartbeat tick.
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

	Asks for a refresh *soon* rather than *now*: pulls the next tick forward to
	`REFRESH_DEBOUNCE` (2 s) from now, never pushes it back. Ten players joining at once
	then cost one write carrying the complete list instead of ten.
]=]
function ServerPresence.RequestRefresh(self: ServerPresence)
	local soon = os.clock() + REFRESH_DEBOUNCE
	if soon < self._nextTick then
		self._nextTick = soon
	end
end

--[=[
	@within ServerPresence

	Publishes the entry and starts the keepalive: a `Heartbeat` connection that refreshes
	on schedule, plus `PlayerAdded` / `PlayerRemoving` connections that request an early
	refresh so the advertised player list does not lag. Calling it twice is a no-op.
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

	Stops the keepalive and withdraws the server from the directory: disconnects the
	heartbeat and the player connections, runs `OnCleanup`, removes the MemoryStore entry,
	publishes `UserServerRegistryClosed`, and sets `ServerInfo.status` to `"closed"`.

	The player connections are dropped **before** the entry is removed on purpose. If they
	survived, a `PlayerRemoving` firing during shutdown would request a refresh that
	rewrites the key just deleted, leaving a dead server advertised until its TTL expires.

	Normally reached from `game:BindToClose`.
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

	The `UserId`s currently in this server, as published in the directory payload.
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

	Reads one directory entry, retrying transient MemoryStore failures with backoff and
	abandoning immediately on a throttle.

	@param map MemoryStoreHashMap -- normally [ServerPresence.GetActiveMap]
	@param key string -- the server key to look up
	@return any -- the entry, or nil if absent or unreadable
	@return boolean -- true when the read **failed**; nil data with false means "no such server"
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

	The MemoryStore hash map backing the directory. Every server in the universe shares it.
]=]
function ServerPresence.GetActiveMap(): MemoryStoreHashMap
	return MemoryStoreService:GetHashMap(ACTIVE_MAP_NAME)
end

--[=[
	@within ServerPresence

	Kicks everyone with `message`. Used when a server cannot establish a valid identity.
	In Studio it only warns, so a local playtest is not ejected.
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
