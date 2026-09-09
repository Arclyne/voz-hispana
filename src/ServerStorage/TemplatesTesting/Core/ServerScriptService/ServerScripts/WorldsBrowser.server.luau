--!strict
--[Roblox Services]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")

--[Configuración Proxy]--
-- Nuestro servidor VPS privado (Puerto 80)
local MY_PROXY_URL = "http://107.174.178.86"
local MY_SECRET_KEY = "VozHispana14759125123471357234"

-- Remotes
local events = ReplicatedStorage:WaitForChild("Events")
local worldSystem = events:WaitForChild("WorldSystem")

local SearchPlayerRF = worldSystem:WaitForChild("SearchPlayer")
local GetPlayerHousesRF = worldSystem:WaitForChild("GetPlayerHouses")

-- Modules
local worldSystemStorage = ServerStorage:WaitForChild("WorldSystem")
local Profiles = require(worldSystemStorage:WaitForChild("Profiles"))
local HousesInfo = require(ReplicatedStorage:WaitForChild("HousesInfo"))

-- Info en vivo (conteo de jugadores, nombre y privacidad actuales) de ServerDirectory.
local GetOwnerServersBF = worldSystemStorage:WaitForChild("GetOwnerServers")

local ROOMS_CACHE_TTL = 30
local DEFAULT_MAX_PLAYERS = 5
local roomsCache: { [number]: { rooms: { string }, ts: number } } = {}

local function searchPlayer(keyword: string) : {any}
	if keyword == "" then return {} end

	local q = HttpService:UrlEncode(keyword)
	local url = ("%s/users/v1/users/search?keyword=%s&limit=50"):format(MY_PROXY_URL, q)

	-- Creamos un paquete con la contraseña
	local headers = {
		["My-Secret"] = MY_SECRET_KEY
	}

	-- Pasamos 'headers' como tercer argumento
	local ok, res = pcall(function()
		return HttpService:GetAsync(url, true, headers)
	end)

	if not ok then
		warn("[Server] ❌ Error (Posiblemente contraseña incorrecta):", res)
		return {}
	end

	local success, datos = pcall(function() return HttpService:JSONDecode(res) end)
	if not success or not datos.data then return {} end

	return datos.data
end

local function getRooms(userId: number): { string }
	local cached = roomsCache[userId]
	if cached and os.clock() - cached.ts < ROOMS_CACHE_TTL then
		return cached.rooms
	end

	local data, ok = Profiles.WorldsPlayer.read(tostring(userId))
	if not ok then
		warn("[WorldsBrowser] Error leyendo las casas de", userId)
		return {}
	end

	local rooms = (data and data.rooms) or {}
	roomsCache[userId] = { rooms = rooms, ts = os.clock() }
	return rooms
end

--[[
	Cada casa del jugador con lo que el buscador necesita pintar: el nombre que le
	puso el dueño, si es pública o privada, y cuánta gente hay dentro.

	Dos fuentes, por orden de frescura:
	  1. El directorio en vivo, si la casa tiene servidor abierto — trae conteo real.
	  2. La WorldCard, si está cerrada — es la proyección que el mundo escribe al
	     guardar, la única forma de saber su nombre sin cargar (ni bloquear) el mundo.
	Si nunca se abrió no hay ninguna de las dos: cae al nombre estático del catálogo.

	El conteo NO se cachea: es el dato que el jugador espera ver al re-buscar.
]]
local function getPlayerHouses(userId: number)
	local rooms = getRooms(userId)

	local okLive, live = pcall(function()
		return GetOwnerServersBF:Invoke(userId)
	end)
	if not okLive then
		warn("[WorldsBrowser] No se pudo leer el directorio en vivo:", live)
		live = {}
	end

	local result = {}

	for _, room in rooms do
		local serverKey = ("%i_%s"):format(userId, room)
		local liveInfo = live[serverKey]

		local name, serverType
		if liveInfo then
			name = liveInfo.name
			serverType = liveInfo.serverType
		else
			local card = Profiles.World.readCard(serverKey)
			name = card and card.name
			serverType = card and card.serverType
		end

		local static = HousesInfo[room]

		table.insert(result, {
			room = room,
			serverKey = serverKey,
			name = name or (static and static.name) or room,
			serverType = serverType or "public",
			playerCount = (liveInfo and liveInfo.playerCount) or 0,
			maxPlayers = (liveInfo and liveInfo.maxPlayers) or DEFAULT_MAX_PLAYERS,
			online = liveInfo ~= nil,
			image = static and static.MainImage or nil,
		})
	end

	return result
end

--[ Conexiones ]--

SearchPlayerRF.OnServerInvoke = function(player: Player, keyword: string)
	print("🔍 Buscando jugador:", keyword)
	return searchPlayer(keyword)
end

GetPlayerHousesRF.OnServerInvoke = function(player: Player, userId: number)
	return getPlayerHouses(userId)
end