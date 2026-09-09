local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Stats = require(script.Parent.Parent.stats.Stats)

local remotes = ReplicatedStorage.Events

local function getAliveHumanoid(player: Player): Humanoid?
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end

	return humanoid
end

remotes.Interactable.Bath.OnServerEvent:Connect(function(player, model: Model)
	local humanoid = getAliveHumanoid(player)
	if not humanoid then
		return
	end

	local seat = model:FindFirstChildOfClass("Seat")
	if seat.Occupant then
		return
	end
	
	local stats = Stats.fromPlayer(player)
	if not stats then
		return
	end
	
	local cleanup =	stats:addIncrementor("hygiene", 10, 1)

	seat:Sit(humanoid)
	seat:GetPropertyChangedSignal("Occupant"):Once(cleanup)
end)
