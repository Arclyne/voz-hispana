local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryManager = require(script.Parent.Parent.inventory.InventoryManager)

local remotes = ReplicatedStorage.Events

remotes.Interactable.Bin.OnServerEvent:Connect(function(player: Player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local tool = character:FindFirstChildOfClass("Tool")
	if tool and tool:GetAttribute("Kitchen") then
		InventoryManager.unequipTool(player)
	end
end)
