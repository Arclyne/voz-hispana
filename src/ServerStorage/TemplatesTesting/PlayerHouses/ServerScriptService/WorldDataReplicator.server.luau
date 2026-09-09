--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local TextService = game:GetService("TextService")

local WorldService = require(script.Parent:WaitForChild("WorldService"))
local RolesInfo = require(ReplicatedStorage:WaitForChild("RolesInfo"))

local ServerInfo = ReplicatedStorage:WaitForChild("ServerInfo")

local remotes = ReplicatedStorage:WaitForChild("Events"):WaitForChild("WorldSystem")
local SetWorldNameRF = remotes.SetWorldName
local GetUserRolRF = remotes.GetUserRol
local togglePrivacityRF = remotes.togglePrivacity
local GetWorldSettingRF = remotes.GetWorldSettings
local GetRolesRf = remotes.GetRoles
local WorldDataUpdated = remotes.WorldDataUpdated
local SetUserRoleRF = remotes.SetUserRole
local GetBansRF = remotes.GetBans
local SetBanRF = remotes.SetBan

local OWNER_ROLE = 51

local SECTION_BY_STORE = {
	WorldRolesStore = "roles",
	WorldSettingsStore = "settings",
	WorldBansStore = "bans",
}

local ReplicatedDataStores = {
	"WorldRolesStore",
	"WorldSettingsStore",
	"WorldBansStore",
}

local function roleFor(data: any, userId: number): number
	local role = data.roles[tostring(userId)] or 0
	if data.settings.OwnerId == userId then
		role = OWNER_ROLE
	end
	return role
end

local function canModerate(data: any, player: Player): boolean
	if data.settings.OwnerId == player.UserId then
		return true
	end
	return roleFor(data, player.UserId) > RolesInfo["moderator"]
end

GetUserRolRF.OnServerInvoke = function(player: Player, userId: number)
	if not userId then
		userId = player.UserId
	end
	local data = WorldService.get()
	if not data then return end

	local rol = data.roles[tostring(userId)]
	if data.settings.OwnerId == userId then
		rol = OWNER_ROLE
	end
	return rol
end

GetRolesRf.OnServerInvoke = function(_player: Player)
	local data = WorldService.get()
	return data and data.roles or nil
end

GetWorldSettingRF.OnServerInvoke = function(_player: Player)
	local data = WorldService.get()
	return data and data.settings or nil
end

SetWorldNameRF.OnServerInvoke = function(player: Player, rawName: any)
	local data = WorldService.get()
	if not data then return end
	if not canModerate(data, player) then return end

	local function limitUTF8(s: string, limit: number): string
		local len = utf8.len(s)
		if not len then return "" end
		if len <= limit then return s end
		local i = utf8.offset(s, limit + 1)
		return i and s:sub(1, i - 1) or s
	end

	local proposed = tostring(rawName or "")
	proposed = proposed:gsub("[%c%z]", "")
	proposed = proposed:gsub("^%s+", ""):gsub("%s+$", "")
	proposed = proposed:gsub("%s+", " ")
	proposed = limitUTF8(proposed, 40)
	if proposed == "" then proposed = "Room" end

	local filtered = proposed
	local okFilter, filteredOut = pcall(function()
		local res = TextService:FilterStringAsync(proposed, player.UserId)
		return res:GetNonChatStringForBroadcastAsync()
	end)
	if okFilter and typeof(filteredOut) == "string" and #filteredOut > 0 then
		filtered = filteredOut
	end

	local ok = WorldService.update(function(current)
		current.settings.Name = filtered
		return current
	end)
	if not ok then
		warn("SetWorldName UpdateFailed")
		return
	end

	return filtered
end

GetBansRF.OnServerInvoke = function(_player: Player)
	local data = WorldService.get()
	if not data or typeof(data.bans) ~= "table" then return {} end
	return data.bans
end

SetBanRF.OnServerInvoke = function(player: Player, targetUserId: number, shouldBan: boolean): boolean?
	if typeof(targetUserId) ~= "number" or typeof(shouldBan) ~= "boolean" then
		return nil
	end

	local data = WorldService.get()
	if not data then return nil end
	if not canModerate(data, player) then return nil end
	if targetUserId == data.settings.OwnerId then return nil end

	local ok = WorldService.update(function(current)
		if shouldBan then
			current.bans[tostring(targetUserId)] = true
		else
			current.bans[tostring(targetUserId)] = nil
		end
		return current
	end)

	if not ok then
		warn("SetBan UpdateFailed")
		return nil
	end

	return shouldBan
end

togglePrivacityRF.OnServerInvoke = function(player: Player)
	local data = WorldService.get()
	if not data then
		warn("NoWorldData")
		return
	end
	if not canModerate(data, player) then
		warn("Forbidden")
		return
	end

	local nextPrivacy = if data.settings.ServerType == "private" then "public" else "private"

	local ok = WorldService.update(function(current)
		current.settings.ServerType = nextPrivacy
		return current
	end)

	if not ok then
		warn("UpdateFailed")
		return
	end

	return nextPrivacy
end

SetUserRoleRF.OnServerInvoke = function(player: Player, targetUserId: number, roleName: string): (any, string?)
	if typeof(roleName) ~= "string" or typeof(targetUserId) ~= "number" then
		return false, "InvalidArguments"
	end

	local data = WorldService.get()
	if not data then return false, "NoWorldData" end
	if not canModerate(data, player) then return false, "Forbidden" end
	if targetUserId == data.settings.OwnerId then return false, "CannotEditOwner" end
	if roleName ~= "none" and RolesInfo[roleName] == nil then
		return false, "InvalidRole"
	end

	local ok = WorldService.update(function(current)
		if roleName == "none" then
			current.roles[tostring(targetUserId)] = nil
		else
			current.roles[tostring(targetUserId)] = RolesInfo[roleName]
		end
		return current
	end)

	if not ok then
		warn("SetUserRole UpdateFailed")
		return false, "UpdateFailed"
	end

	local applied = if roleName == "none" then 0 else RolesInfo[roleName]
	return applied, nil
end

local function pushStore(storeName: string)
	local data = WorldService.get()
	if not data then return end
	local section = SECTION_BY_STORE[storeName]
	if not section then return end

	for _, plr in PlayersService:GetPlayers() do
		local role = roleFor(data, plr.UserId)
		if role >= RolesInfo["moderator"] or data.settings.OwnerId == plr.UserId then
			local payload = data[section]
			if storeName == "WorldRolesStore" and data.settings.OwnerId == plr.UserId then
				payload = table.clone(payload)
				payload[tostring(plr.UserId)] = OWNER_ROLE
			end
			WorldDataUpdated:FireClient(plr, storeName, payload)
		end
	end
end

local replicationWired = false

ServerInfo:GetAttributeChangedSignal("status"):Connect(function()
	if ServerInfo:GetAttribute("status") ~= "ready" then return end
	if replicationWired then return end
	replicationWired = true

	for _, storeName in ReplicatedDataStores do
		pushStore(storeName)
	end

	WorldService.OnStoreUpdated:Connect(function(storeName)
		if table.find(ReplicatedDataStores, storeName) then
			pushStore(storeName)
		end
	end)
end)
