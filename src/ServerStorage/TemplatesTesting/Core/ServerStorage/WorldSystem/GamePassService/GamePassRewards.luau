local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ShopInfo = require(ReplicatedStorage:WaitForChild("ShopInfo"))
local InventoryManager = require(ServerScriptService:WaitForChild("ServerScripts"):WaitForChild("inventory"):WaitForChild("InventoryManager"))

local GamePassRewards = {}

local passTools = {}

for _, info in ShopInfo do
	if info.Type == "GamePass" then
		local id = tonumber(info.MainId)

		if id and id > 0 and typeof(info.ToolName) == "string" and info.ToolName ~= "" then
			passTools[id] = info.ToolName
		end
	end
end

function GamePassRewards.ensure(player: Player, passId: number): (boolean, boolean)
	local id = tonumber(passId)
	if not id then
		return false, false
	end

	local toolName = passTools[id]
	if not toolName then
		return true, false
	end

	local success, changed = InventoryManager.setItemCount(player, toolName, 1)

	if not success then
		warn("[GamePassRewards] No se pudo asegurar la tool", toolName, "para", player.Name)
		return false, false
	end

	return true, changed
end

function GamePassRewards.ensureAll(player: Player, gamePasses: { number }): (boolean, boolean)
	local changed = false

	for _, passId in gamePasses do
		local success, rewardChanged = GamePassRewards.ensure(player, passId)

		if not success then
			return false, changed
		end

		if rewardChanged then
			changed = true
		end
	end

	return true, changed
end

return GamePassRewards