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

local function startShower(player: Player, model: Model)
	local humanoid = getAliveHumanoid(player)
	if not humanoid then
		return
	end

	local occupant = model:FindFirstChild("Occupant")
	if occupant.Value then
		return
	end
	
	local stats = Stats.fromPlayer(player)
	if not stats then
		return
	end
	
	local connection = humanoid.Died:Once(function()
		occupant.Value = nil
	end)

	local character = player.Character :: Model
	local platerCFrame = character:GetPivot()
	local playerPart = model:FindFirstChild("Player") :: Part
	local cleanup = stats:addIncrementor("hygiene", 10, 1)

	character:PivotTo(playerPart:GetPivot())
	occupant.Value = player
	occupant.Changed:Once(function()
		cleanup()
		connection:Disconnect()
		if humanoid.Health > 0 then
			character:PivotTo(platerCFrame)
		end
	end)
end

remotes.Interactable.Shower.OnServerEvent:Connect(function(player, model: Model?)
	if model then
		startShower(player, model)
	else
		for _, model in CollectionService:GetTagged("Shower") do
			local occupant = model:FindFirstChild("Occupant")
			if occupant.Value == player then
				occupant.Value = nil
			end
		end
	end
end)
