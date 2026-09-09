local UserGamesFetcher = {}

local HttpService = game:GetService("HttpService")

-- Nuestro Proxy Privado
local MY_PROXY_URL = "http://107.174.178.86"
local MY_SECRET_KEY = "VozHispana14759125123471357234"

local API_BASE = MY_PROXY_URL .. "/games/v2"
local GROUPS_API = MY_PROXY_URL .. "/groups/v2"
local THUMBNAIL_API = MY_PROXY_URL .. "/thumbnails/v1/games/icons?universeIds=%d&size=512x512&format=Png"

local function fetchAPI(url)
	local headers = {
		["My-Secret"] = MY_SECRET_KEY
	}

	local success, response = pcall(function()
		-- Pasamos true para nocache, y enviamos la contraseña
		return HttpService:GetAsync(url, true, headers)
	end)

	if not success then
		warn("[Proxy VPS] ❌ Error en fetchAPI:", response)
		return nil
	end

	return HttpService:JSONDecode(response)
end

local function getUserGames(userId)
	local url = API_BASE.."/users/"..userId.."/games"
	local data = fetchAPI(url)
	return data and data.data or {}
end

local function getAdminGroups(userId)
	local url = GROUPS_API.."/users/"..userId.."/groups/roles"
	local data = fetchAPI(url)
	if not data then return {} end

	local adminGroups = {}
	for _, group in ipairs(data.data) do
		if group.role and group.role.rank >= 250 then
			table.insert(adminGroups, {
				id = group.group.id,
				name = group.group.name
			})
		end
	end
	return adminGroups
end

-- Obtener juegos de un grupo específico
local function getGroupGames(groupId)
	local url = API_BASE.."/groups/"..groupId.."/games?accessFilter=2&limit=100"
	local data = fetchAPI(url)
	return data and data.data or {}
end

local function getGameThumbnail(universeId)
	local url = string.format(THUMBNAIL_API, universeId)
	local data = fetchAPI(url)
	return data and data.data[1] and data.data[1].imageUrl or nil
end

function UserGamesFetcher.GetAllGamesWithDetails(userId)
	local allGames = {
		Player = {},
		Groups = {},
	}

	local userGames = getUserGames(userId)
	for _, g in ipairs(userGames) do
		table.insert(allGames.Player[g.name], {
			name = g.name,
			description = g.description or "No Description",
			placeId = g.rootPlace.id,
			universeId = g.id,
			visits = g.placeVisits or 0,
			creator = g.creator.name,
			source = "Perfil",
			thumbnail = getGameThumbnail(g.id),
			created = g.created -- Fecha de creación
		})
	end

	local adminGroups = getAdminGroups(userId)
	for _, group in ipairs(adminGroups) do
		local groupGames = getGroupGames(group.id)
		for _, g in ipairs(groupGames) do
			table.insert(allGames.Groups[g.name], {
				name = g.name,
				description = g.description or "No Description",
				placeId = g.rootPlace.id,
				universeId = g.id,
				visits = g.placeVisits or 0,
				creator = g.creator.name,
				source = "Grupo: "..group.name,
				thumbnail = getGameThumbnail(g.id),
				created = g.created,
				groupInfo = { 
					id = group.id,
					name = group.name
				}
			})
		end
	end
	return allGames
end

return UserGamesFetcher