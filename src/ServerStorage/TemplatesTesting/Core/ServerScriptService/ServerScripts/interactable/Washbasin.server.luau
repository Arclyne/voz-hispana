local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryManager = require(script.Parent.Parent.inventory.InventoryManager)
local Stats = require(script.Parent.Parent.stats.Stats)

local remotes = ReplicatedStorage.Events

local function startWashbasin(player: Player, model)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	
	local stats = Stats.fromPlayer(player)
	if not stats then
		return
	end

	local occupant = model.Occupant
	local playerPart = model.Player
	local connection = humanoid.Died:Once(function()
		occupant.Value = nil
	end)

	occupant.Value = player
	character:PivotTo(playerPart:GetPivot())

	task.wait(2)

	if occupant.Value == player then
		stats:increment("hygiene", 10)
	end

	occupant.Value = nil
end

remotes.Interactable.WashHands.OnServerEvent:Connect(function(player: Player, model)
	local occupant = model.Occupant
	if not occupant.Value then
		startWashbasin(player, model)
	end
end)

remotes.Interactable.WashTeeth.OnServerEvent:Connect(function(player: Player, model)
	local occupant = model.Occupant
	if not occupant.Value then
		startWashbasin(player, model)
	end
end)
