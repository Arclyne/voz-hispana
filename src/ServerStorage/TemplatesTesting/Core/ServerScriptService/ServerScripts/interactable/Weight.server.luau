local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = require(script.Parent.Parent.stats.Stats)

local assets = ReplicatedStorage.Assets
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

remotes.Interactable.Weight.OnServerEvent:Connect(function(player)
	local stats = Stats.fromPlayer(player)
	if not stats then
		return
	end

	local humanoid = getAliveHumanoid(player)
	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	local track = animator:LoadAnimation(assets.Interactable.Weight.Animation)
	track:Play()
	track.Stopped:Wait()

	stats:increment("physic", 10)
end)
