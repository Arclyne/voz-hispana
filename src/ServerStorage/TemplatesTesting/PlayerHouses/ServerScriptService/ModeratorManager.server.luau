--!strict
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerInfo = ReplicatedStorage:WaitForChild("ServerInfo")
local WorldService = require(ServerScriptService:WaitForChild("WorldService"))
local RolesInfo = require(ReplicatedStorage:WaitForChild("RolesInfo"))

local function kickPlayer(plr: Player, reason: string?)
	local ok, err = pcall(function()
		plr:Kick(reason or "You are banned from this world.")
	end)
	if not ok then
		warn("[ModeratorManager] Kick failed for", plr.UserId, err)
	end
end

local function getGuestThreshold(): number
	return RolesInfo["guest"] or RolesInfo["invited"] or 1
end

local function hasAtLeastGuestRole(rolesMap: {[string]: number}?, userId:number): boolean
	local val = rolesMap and rolesMap[tostring(userId)] or 0
	return val >= getGuestThreshold()
end

local function isUserIdBanned(userId: number): boolean
	local mgr = WorldService.GetInstance()
	if not mgr then return false end
	local store = mgr:GetStoreData("WorldBansStore")
	if typeof(store) ~= "table" then return false end
	return store[tostring(userId)] == true
end

local function sweepKickFromSnapshot(snapshot: any)
	if typeof(snapshot) ~= "table" then return end
	for _, plr in Players:GetPlayers() do
		if snapshot[tostring(plr.UserId)] == true then
			kickPlayer(plr, "You are banned from this world.")
		end
	end
end

local function canPlayerEnter(plr: Player, mgr) : (boolean, string?)
	if not mgr then return true end

	if isUserIdBanned(plr.UserId) then
		return false, "You are banned from this world."
	end

	local settings = mgr:GetStoreData("WorldSettingsStore") :: { OwnerId:number?, ServerType:string? }?
	if not settings then
		return true
	end

	local ownerId = tonumber(settings.OwnerId or 0) or 0
	local serverType = tostring(settings.ServerType or "public")

	if plr.UserId == ownerId then
		return true
	end

	if serverType == "private" then
		local roles = mgr:GetStoreData("WorldRolesStore") :: {[string]: number}?
		if hasAtLeastGuestRole(roles, plr.UserId) then
			return true
		end
		local okFriend, isFriend = pcall(function()
			return plr:IsFriendsWith(ownerId)
		end)
		if okFriend and isFriend then
			return true
		end
		return false, "This world is private. Only invited users or friends of the owner can join."
	end

	return true
end

local function sweepKickCurrent()
	local mgr = WorldService.GetInstance()
	if not mgr then return end
	local store = mgr:GetStoreData("WorldBansStore")
	sweepKickFromSnapshot(store)
end

local function sweepAccessAll()
	local mgr = WorldService.GetInstance()
	if not mgr then return end
	for _, plr in Players:GetPlayers() do
		local allowed, why = canPlayerEnter(plr, mgr)
		if not allowed then
			kickPlayer(plr, why)
		end
	end
end

local function wireManagerSignals()
	local mgr = WorldService.GetInstance()
	if not mgr then return end

	mgr.OnStoreUpdated:Connect(function(storeName: string, snapshot: any)
		if storeName == "WorldBansStore" then
			sweepKickFromSnapshot(snapshot)
		elseif storeName == "WorldSettingsStore" or storeName == "WorldRolesStore" then
			sweepAccessAll()
		end
	end)
end

local function onReady()
	wireManagerSignals()
	sweepKickCurrent()
	sweepAccessAll()
end

if ServerInfo:GetAttribute("status") == "ready" then
	onReady()
else
	local conn
	conn = ServerInfo:GetAttributeChangedSignal("status"):Connect(function()
		if ServerInfo:GetAttribute("status") == "ready" then
			conn:Disconnect()
			onReady()
		end
	end)
end

Players.PlayerAdded:Connect(function(plr: Player)
	local function check()
		local live = Players:GetPlayerByUserId(plr.UserId)
		if not live then return end

		local mgr = WorldService.GetInstance()
		if not mgr then return end

		local allowed, why = canPlayerEnter(live, mgr)
		if not allowed then
			kickPlayer(live, why)
		end
	end

	if ServerInfo:GetAttribute("status") == "ready" then
		check()
	else
		local once
		once = ServerInfo:GetAttributeChangedSignal("status"):Connect(function()
			if ServerInfo:GetAttribute("status") == "ready" then
				once:Disconnect()
				check()
			end
		end)
	end
end)
