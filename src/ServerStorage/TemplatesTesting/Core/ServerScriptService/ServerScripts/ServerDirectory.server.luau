--!strict
-- [Roblox Services] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")
local ServerStorage = game:GetService("ServerStorage")

-- Modules
local PrettyPrint = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PrettyPrint"))

-- Constants 
local DIRECTORY_MAP = MemoryStoreService:GetHashMap("UserServerRegistry_Test")
local MSG_TOPIC_UPDATE = "UserServerRegistryUpdate"
local MSG_TOPIC_CLOSED = "UserServerRegistryClosed"
local PAGE_SIZE = 200
local CACHE_TTL = 60 * 5
local SUB_RETRY_BASE = 0.25
local SUB_RETRY_MAX = 6
local lastMsgTs = os.time()
-- Debe coincidir con EventService.EventKey. El evento es un singleton y siempre vive bajo
-- esta key, así que se lee de una en vez de barrer el mapa entero buscándolo.
local EVENT_KEY = "event_active"
-- Un ListItemsAsync recorre las 21 particiones del HashMap aunque esté vacío. Si la cuota
-- del universo ya está agotada, insistir es exactamente lo que la mantiene agotada.
local THROTTLE_COOLDOWN = 60
local blockedUntil = 0

-- Remotes
local GetFriendServersRF = ReplicatedStorage.Events.WorldSystem.GetFriendServers
local GetMostPlayedServersRF = ReplicatedStorage.Events.WorldSystem.GetMostPlayedServers
local GetServerInfoRF = ReplicatedStorage.Events.WorldSystem.GetServerInfo
local GetPlayerHouseServersRF = ReplicatedStorage.Events.WorldSystem.GetPlayerHouseServers
local GetActiveEventRF = ReplicatedStorage.Events.WorldSystem.GetActiveEvent
-- Seam server-a-server: el conteo de jugadores en vivo solo existe en el cache de
-- este script, y WorldsBrowser lo necesita para pintar los mundos de un jugador.
local GetOwnerServersBF = ServerStorage:WaitForChild("WorldSystem"):WaitForChild("GetOwnerServers")
-- Cache
local serversCache: {[string]: {[string]: any}} = {}

-- Helpers --

--[[
	¿MemoryStore nos está frenando? Es distinto de "MemoryStore falló": ante un fallo
	transitorio reintentar es lo correcto; ante un throttle es justo lo que lo alarga.
]]
local function isThrottled(err: any): boolean
	local text = tostring(err)
	return string.find(text, "RequestThrottled", 1, true) ~= nil
		or string.find(text, "TotalRequestsOverLimit", 1, true) ~= nil
end

local function toPublicEntry(key: string, info: {[string]: any}) : {[string]: any}?
	if info == nil or info.status ~= "ready" then
		return nil
	end

	return {
		serverKey = key,
		name = info.name,
		placeId = info.placeId,
		playerCount = info.playerCount,
		players = info.players,
		hostingType = info.hostingType,
		lastUpdate = info.lastUpdate,
		maxPlayers = info.maxPlayers
	}
end

local function fullSync(): ()
	if os.clock() < blockedUntil then
		warn("[ServerDirectory] fullSync omitido: la cuota de MemoryStore sigue agotada.")
		return
	end

	local newCache = {}
	local count = 0
	local MAX_RETRIES = 3
	local RETRY_DELAY = 1

	local pages
	local success = false

	for attempt = 1, MAX_RETRIES do
		local listErr
		success, listErr = pcall(function()
			pages = DIRECTORY_MAP:ListItemsAsync(PAGE_SIZE)
		end)

		if success then break end
		if isThrottled(listErr) then
			blockedUntil = os.clock() + THROTTLE_COOLDOWN
			warn(("[ServerDirectory] Cuota agotada; no vuelvo a barrer el directorio en %ds. Conservo la caché."):format(THROTTLE_COOLDOWN))
			return
		end
		warn(("[ServerDirectory] ListItemsAsync failed (attempt %d/%d). Retrying in %d sec..."):format(attempt, MAX_RETRIES, RETRY_DELAY))
		task.wait(RETRY_DELAY)
	end

	if not success then
		warn("[ServerDirectory] Full synchronization aborted: The server list could not be obtained. The existing cache has been preserved.")
		return
	end

	-- Ojo con la forma del bucle: `IsFinished` ya es true cuando la página actual es la
	-- última, así que un `while not pages.IsFinished` se saltaba la única página cuando
	-- solo había una. Leemos primero y preguntamos después.
	local syncCompletedSuccessfully = true
	while true do
		for _, item in ipairs(pages:GetCurrentPage()) do
			local v = item.value
			if v and v.status == "ready" then
				newCache[item.key] = v
				count += 1
			end
		end

		if pages.IsFinished then break end

		local advanced = false
		for attempt = 1, MAX_RETRIES do
			-- `local ok` a propósito: el nombre anterior tapaba al `advanceSuccess` de
			-- afuera, que se quedaba en false para siempre y abortaba todo fullSync.
			local ok, errMsg = pcall(function()
				pages:AdvanceToNextPageAsync()
			end)

			if ok then
				advanced = true
				break
			end
			if isThrottled(errMsg) then
				blockedUntil = os.clock() + THROTTLE_COOLDOWN
				warn(("[ServerDirectory] Cuota agotada a mitad del barrido; paro %ds."):format(THROTTLE_COOLDOWN))
				break
			end
			warn(("[ServerDirectory] AdvanceToNextPageAsync failed (attempt %d/%d): %s. Retrying..."):format(attempt, MAX_RETRIES, tostring(errMsg)))
			task.wait(RETRY_DELAY)
		end

		if not advanced then
			warn("[ServerDirectory] Full synchronization aborted: Could not advance to the next page. The cache may be incomplete.")
			syncCompletedSuccessfully = false
			break
		end
	end

	if syncCompletedSuccessfully then
		serversCache = newCache
		print("[ServersCache] Complete synchronization successful. Total number of servers cached.:", count)
	else
		print("[ServersCache] Full synchronization failed. The existing cache has been preserved to avoid inconsistencies.")
	end
end

local function applyUpdate(delta: {[string]: any}, key: string)
	serversCache[key] = delta
end

local function applyClosed(serverKey: string)
	serversCache[serverKey] = nil
end

local function subscribeWithRetry(topic, handler)
	local attempt = 0
	while attempt < SUB_RETRY_MAX do
		attempt += 1
		local ok, connOrErr = pcall(function()
			return MessagingService:SubscribeAsync(topic, function(msg)
				lastMsgTs = os.time()
				local ok2, err2 = pcall(handler, msg)
				if not ok2 then warn("[MS] handler error:", err2) end
			end)
		end)
		if ok and connOrErr then
			return connOrErr
		end
		warn(("SubscribeAsync fail (%d): %s"):format(attempt, tostring(connOrErr)))
		task.wait(SUB_RETRY_BASE * 2^(attempt-1))
	end
	return nil
end

subscribeWithRetry(MSG_TOPIC_UPDATE, function(msg: any)
	if typeof(msg.Data) == "table" then
		applyUpdate(msg.Data.info, msg.Data.key)
		print("[Servers Cache] updated, new entry:", PrettyPrint(msg.Data))
		print("[New Servers Cache]:", PrettyPrint(serversCache))
	end
end)

subscribeWithRetry(MSG_TOPIC_CLOSED, function(msg: any)
	if typeof(msg.Data) == "string" then
		applyClosed(msg.Data)
		print("[Servers Cache] updated, entry deleted:", msg.Data)
		print("[New Servers Cache]:", PrettyPrint(serversCache))
	end
end)

local function buildFriendSet(userId: number): {[number]: boolean}
	local set: {[number]: boolean} = {}

	local ok, pages = pcall(function()
		return Players:GetFriendsAsync(userId)
	end)

	if ok then
		--[[warn(PrettyPrint(pages:GetCurrentPage()))
		repeat
			for _, info in ipairs(pages:GetCurrentPage()) do
				print(PrettyPrint(info))
				set[info.Id] = true
			end
			pages:AdvanceToNextPageAsync()
		until pages.IsFinished == true ]]
		
		local hasMorePages = true

		while hasMorePages do
			for _, info in ipairs(pages:GetCurrentPage()) do
				set[info.Id] = true
			end

			-- miro si es el final
			if pages.IsFinished then
				hasMorePages = false
			else 
				-- avanzamos pagina (protegemos con pcall por si falla roblox)
				local exito = pcall(function()
					pages:AdvanceToNextPageAsync()
				end)

				if not exito then
					hasMorePages = false
				end
			end
		end
	else
		warn("GetFriendsAsync failed")
	end

	return set
end

local function getFriendServers(userId: number): {{[string]: any}}
	local friends = buildFriendSet(userId)
	local result: {{[string]: any}} = {}

	for key, info in pairs(serversCache) do
		if info.status == "ready" then
			local hits = {}
			for _, id in ipairs(info.players or {}) do
				if friends[id] or (RunService:IsStudio() and id == userId) then
					table.insert(hits, id)
				end
			end

			if #hits > 0 then
				local entry = toPublicEntry(key, info)
				if entry then
					entry.friends = hits
					table.insert(result, entry)
				end
			end
		end
	end

	table.sort(result, function(a, b) return a.playerCount > b.playerCount end)
	print("FriendServers for:", userId, PrettyPrint(result))
	return result
end

local function getMostPlayedServers(limit: number?): {{[string]: any}}
	local list: {{[string]: any}} = {}

	for key, info in pairs(serversCache) do
		if info.status == "ready" and info.hostingType == "room" and info.serverType == "public" then
			local entry = toPublicEntry(key, info)
			if entry then
				table.insert(list, entry)
			end
		end
	end

	table.sort(list, function(a, b) return a.playerCount > b.playerCount end)

	local top = math.min(limit or 10, #list)
	local result = {}
	for i = 1, top do
		result[i] = list[i]
	end
	print("MostPlayedServers:", PrettyPrint(result))
	return result
end

--[[
	Devuelve el evento activo, o nil si no hay ninguno. Solo puede haber uno a la vez.
	Deliberadamente NO expone `code` ni `jobId`: el accessCode del servidor reservado se
	resuelve server-side en JoinServer y nunca viaja al cliente.
]]
local function findEventInCache(): {[string]: any}?
	for key, info in pairs(serversCache) do
		if info.status == "ready" and info.hostingType == "event" then
			return {
				serverKey = key,
				name = info.name,
				description = info.description,
				image = info.image,
				placeId = info.placeId,
				playerCount = info.playerCount,
				maxPlayers = info.maxPlayers,
			}
		end
	end
	return nil
end

local lastEventResync = -math.huge
local EVENT_RESYNC_COOLDOWN = 10

local function getActiveEvent(): {[string]: any}?
	local event = findEventInCache()
	if event then
		return event
	end

	-- El cache se llena por MessagingService (best-effort, se puede perder) o por el
	-- fullSync cada CACHE_TTL. Sin este resync, un lobby que se perdió el aviso esconde
	-- el evento hasta 5 minutos — y el botón Refresh de la GUI no servía de nada, porque
	-- solo volvía a leer el mismo cache vacío.
	--
	-- Este resync era un fullSync(), y ahí estaba la fuga de cuota: ListItemsAsync recorre
	-- las 21 particiones del HashMap aunque no haya un solo dato, así que preguntar "¿hay
	-- evento?" costaba 21 unidades. Y como casi nunca hay evento, se preguntaba cada 10 s.
	-- El evento vive bajo una key fija: leerla directamente cuesta 1.
	if os.clock() - lastEventResync >= EVENT_RESYNC_COOLDOWN and os.clock() >= blockedUntil then
		lastEventResync = os.clock()

		local ok, info = pcall(DIRECTORY_MAP.GetAsync, DIRECTORY_MAP, EVENT_KEY)
		if ok then
			-- También limpia: si el evento terminó y perdimos el aviso, esto lo saca del cache.
			if typeof(info) == "table" and info.status == "ready" then
				serversCache[EVENT_KEY] = info
			else
				serversCache[EVENT_KEY] = nil
			end
		elseif isThrottled(info) then
			blockedUntil = os.clock() + THROTTLE_COOLDOWN
			warn(("[ServerDirectory] Cuota agotada; no consulto el evento en %ds."):format(THROTTLE_COOLDOWN))
		else
			warn("[ServerDirectory] No pude leer el evento activo:", info)
		end

		event = findEventInCache()
	end

	return event
end

--[[
	Info en vivo de las casas de un dueño, indexada por serverKey. Solo aparecen las
	que tienen servidor abierto: una casa cerrada no está en el directorio, y quien
	llama debe caer a la tarjeta del mundo (WorldCard) para nombre y privacidad.
]]
local function getOwnerServers(ownerId: number): { [string]: { [string]: any } }
	local prefix = tostring(ownerId) .. "_"
	local byKey: { [string]: { [string]: any } } = {}

	for key, info in pairs(serversCache) do
		if info.status == "ready" and info.hostingType == "room" and key:sub(1, #prefix) == prefix then
			byKey[key] = {
				name = info.name,
				serverType = info.serverType,
				playerCount = info.playerCount,
				maxPlayers = info.maxPlayers,
			}
		end
	end

	return byKey
end

local function isServerOwner(player: Player, key: string): boolean
	local userIdServer = tonumber(key:match("^([0-9]+)_"))
	local userIdPlayer = player.UserId
	return userIdServer == userIdPlayer
end

local function getPlayerHouseServers(player: Player): {{[string]: any}}
	local result: {{[string]: any}} = {}
	warn(serversCache)
	for key, info in pairs(serversCache) do
		if info.status == "ready" and info.hostingType == "room" and isServerOwner(player, key) then
			local entry = toPublicEntry(key, info)
			if entry then
				table.insert(result, entry)
			end
		end
	end

	return result
end

GetFriendServersRF.OnServerInvoke = function(player)
	return getFriendServers(player.UserId)
end

GetMostPlayedServersRF.OnServerInvoke = function(_, limit: number?)
	return getMostPlayedServers(limit)
end

GetPlayerHouseServersRF.OnServerInvoke = function(player)
	return getPlayerHouseServers(player)
end

GetActiveEventRF.OnServerInvoke = function()
	return getActiveEvent()
end

GetOwnerServersBF.OnInvoke = function(ownerId: number)
	return getOwnerServers(ownerId)
end

task.delay(math.random(1, 10), function()
	fullSync()

	while true do
		task.wait(CACHE_TTL)
		fullSync()
	end
end)