local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Stats = require(script.Stats)
local lerp = require(ReplicatedStorage.Shared.lerp)
local PlayerInit = require(ReplicatedStorage:WaitForChild("PlayerInit"))
local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))

local PeeModel = ReplicatedStorage.Assets.Models.PeeModel

local BLADDER_OVERFLOW_WAIT = 5
local MAX_WALKSPEED = 16
local MIN_WALKSPEED = 8

local function spawnPee(player: Player)
	local character = player.Character
	if not character then
		return
	end
	
	local PiModelClone = PeeModel:Clone()
	PiModelClone.Parent = Workspace

	local PiMesh = PiModelClone.PiMesh
	PiMesh.Size = Vector3.new(0, 0, 0)
	
	PiModelClone.PrimaryPart = PiMesh

	local origin = character:GetPivot().Position
	local params = RaycastParams.new()
	params:AddToFilter(character)

	local result = Workspace:Raycast(origin, Vector3.new(0, -100, 0), params)
	if result then
		PiMesh.Position = result.Position
	end
	SoundManager:Play(player, 140363084183022)
	local tweenInfo = TweenInfo.new(
		1,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(PiMesh, tweenInfo, {Size = Vector3.new(3.935, 0.084, 4.471)})
	tween:Play()
	tween.Completed:Wait()
	CollectionService:AddTag(PiModelClone, "Pee")
end

local function handleBladderOverflow(player: Player, stats)
	task.delay(BLADDER_OVERFLOW_WAIT, function()
		if stats:get("bladder") == 0 then
			spawnPee(player)
			stats:set("bladder", 100)
			stats:set("hygiene", 0)
		end
	end)
end

local function updatePlayerSpeed(player: Player, stats)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = lerp(MIN_WALKSPEED, MAX_WALKSPEED, stats:get("sleepness") / 100)
	end
end

local function OnPlayerAdded(player)
	local character = player.Character or player.CharacterAdded:Wait()
	local stats = Stats.new(player)

	stats:onChange("bladder", function(value)
		if stats:get("bladder") == 0 then
			handleBladderOverflow(player, stats)
		end
	end)

	stats:onChange("sleepness", function()
		updatePlayerSpeed(player, stats)
	end)
end

PlayerInit.Connect(OnPlayerAdded)