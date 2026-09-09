--!strict
--[Roblox Services]--
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Modules
local ServerPresence = require(ServerStorage:WaitForChild("WorldSystem"):WaitForChild("ServerPresence"))
-- Instances
local ServerInfo = ReplicatedStorage:WaitForChild("ServerInfo")


if game.PrivateServerId ~= "" then
	return
end

local serverKey = ("%d_%s"):format(game.PlaceId, game.JobId)

local function getPlaceName()
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end)
	
	return if success then info.Name else "Game"
end

local baseInfo = {
	hostingType = "default",
	placeId = game.PlaceId,
	jobId = game.JobId,
	maxPlayers = Players.MaxPlayers,
	serverType = "public",
	name = getPlaceName(),
	status = "pending"
}

local function getLobbyRefreshPayload(old: any?): any
	local info = old or baseInfo

	info.players = ServerPresence.GetPlayerList()
	info.playerCount = #info.players
	info.lastUpdate = os.time()
	info.status = "ready"

	return info
end

local function onLobbyStarted()
	ServerInfo:SetAttribute("status", "ready")
	warn("Public Server Started: ", serverKey)
end

ServerInfo:SetAttribute("ServerKey", serverKey)
ServerInfo:SetAttribute("HostingType", "default")
ServerInfo:SetAttribute("status", "pending")

local config: ServerPresence.ManagerConfig = {
	ServerKey = serverKey,
	GetRefreshPayload = getLobbyRefreshPayload,
	OnStarted = onLobbyStarted
}

local registryManager = ServerPresence.new(config)
registryManager:Start()

game:BindToClose(function()
	registryManager:Cleanup()
end)