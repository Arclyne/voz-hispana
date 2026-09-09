local Tool = script.Parent
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local remotes = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Tools")
local gloveGunRemote = remotes:WaitForChild("GloveGun")
local SmoothShiftLock = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SmoothShiftLock"))

local LOCAL_LOCK_SECONDS = 0.15
local localLocked = false
local equipped = false

local AIM_LOCK_CONFIG = {
	Offset = Vector3.new(1.35, 0.25, 0),
	SmoothSpeed = 18,
	CursorIconId = 76659104575933,
	ShowMouseIcon = true,
	RotateCharacterWithCamera = true,
	AllowToggleWithCtrl = true,
}

local function cleanupAim()
	equipped = false
	localLocked = false
	SmoothShiftLock.Disable(Tool)
end

gloveGunRemote.OnClientEvent:Connect(function(action, remoteTool, extra)
	if remoteTool ~= Tool then
		return
	end

	if action == "CooldownDenied" then
		localLocked = false
		warn(("Guante pistola en cooldown. Quedan %.1fs"):format(tonumber(extra) or 0))
	elseif action == "ResetLock" then
		localLocked = false
	end
end)

Tool.Equipped:Connect(function()
	equipped = true
	SmoothShiftLock.Enable(Tool, AIM_LOCK_CONFIG)
end)

Tool.Unequipped:Connect(function()
	gloveGunRemote:FireServer("Reset", Tool)
	cleanupAim()
end)

Tool.AncestryChanged:Connect(function()
	local character = player.Character
	if not character or Tool.Parent ~= character then
		cleanupAim()
	end
end)

player.CharacterRemoving:Connect(function()
	cleanupAim()
end)

Tool.Activated:Connect(function()
	if not equipped or localLocked then
		return
	end

	localLocked = true
	gloveGunRemote:FireServer("Fire", Tool)

	task.delay(LOCAL_LOCK_SECONDS, function()
		localLocked = false
	end)
end)