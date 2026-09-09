local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local SoundManager = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SoundManager"))
local SmoothShiftLock = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SmoothShiftLock"))

local CANNON_APPEAR_SOUND_ID = 136836088450502
local CANNON_FIRE_SOUND_ID = 140172249821450

local player = Players.LocalPlayer
local tool = script.Parent
local handle = tool:WaitForChild("Handle")

local remotes = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Tools")
local equipRemote = remotes:WaitForChild("EquipTool")
local cannonRemote = remotes:WaitForChild("Cannon")

local equipped = false
local fired = false
local canFire = false
local aimConnection = nil
local lastAimSend = 0
local ancestryConnection = nil
local characterRemovingConnection = nil

local AIM_SEND_INTERVAL = 1 / 30
local MIN_PITCH = math.rad(-45)
local MAX_PITCH = math.rad(85)

local AIM_LOCK_CONFIG = {
	Offset = Vector3.new(0.8, 0.12, 0),
	SmoothSpeed = 18,
	CursorIconId = 76659104575933,
	ShowMouseIcon = true,
	RotateCharacterWithCamera = false,
	AllowToggleWithCtrl = false,
}

task.defer(function()
	SoundManager:Preload({
		CANNON_APPEAR_SOUND_ID,
		CANNON_FIRE_SOUND_ID,
	})
end)

local function getCharacter()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")
	return character, humanoid, root
end

local function getAimData()
	local camera = Workspace.CurrentCamera
	if not camera then
		return 0, 0, Vector3.new(0, 0, -1)
	end

	local lookVector = camera.CFrame.LookVector
	local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z)

	if flatLook.Magnitude < 0.001 then
		flatLook = Vector3.new(0, 0, -1)
	else
		flatLook = flatLook.Unit
	end

	local yaw = math.atan2(-flatLook.X, -flatLook.Z)
	local pitch = math.asin(math.clamp(lookVector.Y, -0.999, 0.999))
	pitch = math.clamp(pitch, MIN_PITCH, MAX_PITCH)

	return yaw, pitch, lookVector.Unit
end

local function stopAiming()
	equipped = false
	canFire = false

	if aimConnection then
		aimConnection:Disconnect()
		aimConnection = nil
	end

	SmoothShiftLock.Disable(tool)
	
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.AutoRotate = true
		end
	end
end

local function hardCleanup()
	stopAiming()
	fired = false
end

cannonRemote.OnClientEvent:Connect(function(action, remoteTool, extra)
	if remoteTool ~= tool then
		return
	end

	if action == "Ready" then
		canFire = true
	elseif action == "Expired" then
		hardCleanup()
		fired = true
	elseif action == "CooldownDenied" then
		hardCleanup()
		warn(("Cannon en cooldown. Quedan %.1fs"):format(tonumber(extra) or 0))
	end
end)

tool.Equipped:Connect(function()
	local character, humanoid = getCharacter()

	equipped = true
	fired = false
	canFire = false
	lastAimSend = 0

	humanoid.AutoRotate = false
	SmoothShiftLock.Enable(tool, AIM_LOCK_CONFIG)
	
	equipRemote:FireServer(handle)
	cannonRemote:FireServer("Equip", tool)

	local initialYaw, initialPitch = getAimData()
	cannonRemote:FireServer("Aim", tool, initialYaw, initialPitch)

	if aimConnection then
		aimConnection:Disconnect()
	end

	aimConnection = RunService.RenderStepped:Connect(function()
		if not equipped or fired then
			return
		end

		if tool.Parent ~= character then
			hardCleanup()
			return
		end

		local yaw, pitch = getAimData()
		local now = time()

		if now - lastAimSend >= AIM_SEND_INTERVAL then
			lastAimSend = now
			cannonRemote:FireServer("Aim", tool, yaw, pitch)
		end
	end)
end)

tool.Unequipped:Connect(function()
	hardCleanup()
	cannonRemote:FireServer("Unequip", tool)
end)

if ancestryConnection then
	ancestryConnection:Disconnect()
end
ancestryConnection = tool.AncestryChanged:Connect(function()
	local character = player.Character
	if not character or tool.Parent ~= character then
		hardCleanup()
	end
end)

if characterRemovingConnection then
	characterRemovingConnection:Disconnect()
end
characterRemovingConnection = player.CharacterRemoving:Connect(function()
	hardCleanup()
end)

tool.Activated:Connect(function()
	if not equipped or fired or not canFire then
		return
	end

	fired = true

	local _, humanoid = getCharacter()
	local yaw, pitch, lookVector = getAimData()

	cannonRemote:FireServer("Fire", tool, yaw, pitch, lookVector)

	humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)

	task.delay(1.5, function()
		if humanoid and humanoid.Parent then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		end
	end)

	stopAiming()
end)