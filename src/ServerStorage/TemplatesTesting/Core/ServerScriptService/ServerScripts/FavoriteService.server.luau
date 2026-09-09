--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Remotes = ReplicatedStorage:WaitForChild("Events"):WaitForChild("WorldSystem")
local worldSystemStorage = ServerStorage:WaitForChild("WorldSystem")
local PlayerDataService = require(worldSystemStorage:WaitForChild("PlayerDataService"))

local GiveFavorite: RemoteFunction = Remotes:WaitForChild("GiveFavorite")
local RemoveFavorite: RemoteFunction = Remotes:WaitForChild("RemoveFavorite")
local UpdateFavoriteWorlds: RemoteEvent = Remotes:WaitForChild("UpdateFavoriteWorlds")

local function onGiveFavorite(player: Player, serverKey: string)
	if typeof(serverKey) ~= "string" then return false end

	local store = PlayerDataService.get(player)
	if not store or not store:isReady() then return false end

	local data = store:get()
	if table.find(data.favorites, serverKey) then return false end

	store:update(function(current)
		if not table.find(current.favorites, serverKey) then
			table.insert(current.favorites, serverKey)
		end
		return current
	end)

	UpdateFavoriteWorlds:FireClient(player, store:get().favorites)
	return true
end

local function onRemoveFavorite(player: Player, serverKey: string)
	if typeof(serverKey) ~= "string" then return false end

	local store = PlayerDataService.get(player)
	if not store or not store:isReady() then return false end

	local data = store:get()
	if not table.find(data.favorites, serverKey) then return false end

	store:update(function(current)
		local index = table.find(current.favorites, serverKey)
		if index then
			table.remove(current.favorites, index)
		end
		return current
	end)

	UpdateFavoriteWorlds:FireClient(player, store:get().favorites)
	return true
end

GiveFavorite.OnServerInvoke = onGiveFavorite
RemoveFavorite.OnServerInvoke = onRemoveFavorite