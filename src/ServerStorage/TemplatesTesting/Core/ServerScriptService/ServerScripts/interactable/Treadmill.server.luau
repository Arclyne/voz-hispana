local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryManager = require(script.Parent.Parent.inventory.InventoryManager)
local CollectionService = game:GetService("CollectionService")
local Stats = require(script.Parent.Parent.stats.Stats)

local remotes = ReplicatedStorage.Events

local function getOccupiedTreadmill(player)
	for _, model in CollectionService:GetTagged("Treadmill") do
		if model.Occupant.Value == player then
			return model
		end
	end
end

local function startTreadmill(player, model)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	if model.Occupant.Value then
		return
	end
	
	local stats = Stats.fromPlayer(player)
	if not stats then
		return
	end
	
	local connection = humanoid.Died:Once(function()
		model.Occupant.Value = nil
	end)
	
	local incrementorCleanup = stats:addIncrementor("physic", 10, 1)
	local decrementorCleanup = stats:addDecrementor("hygiene", 10, 1)

	model.Occupant.Value = player
	model.Occupant.Changed:Once(function()
		connection:Disconnect()
		incrementorCleanup()
		decrementorCleanup()
	end)
end

local function stopTreadmill(player)
	local model = getOccupiedTreadmill(player)
	if model then
		model.Occupant.Value = nil
	end
end

remotes.Interactable.Treadmill.OnServerEvent:Connect(function(player: Player, model)
	if model then
		startTreadmill(player, model)
	else
		stopTreadmill(player)
	end
end)
