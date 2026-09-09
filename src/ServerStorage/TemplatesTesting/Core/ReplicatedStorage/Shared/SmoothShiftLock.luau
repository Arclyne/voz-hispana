local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local SmoothShiftLock = {}

local MANUAL_OWNER = "__MANUAL__"

local currentOwner = nil
local currentConfig = nil
local locked = false

local currentOffset = Vector3.zero
local targetOffset = Vector3.zero
local smoothSpeed = 18
local cursorIconId = nil
local showMouseIcon = true
local rotateCharacterWithCamera = false

local renderConnection = nil
local savedAutoRotate = nil

local DEFAULT_MANUAL_CONFIG = {
	Offset = Vector3.new(1.25, 0.2, 0),
	SmoothSpeed = 18,
	CursorIconId = 76659104575933,
	ShowMouseIcon = true,
	RotateCharacterWithCamera = true,
	AllowToggleWithCtrl = true,
}

if player:GetAttribute("AimLockActive") == nil then
	player:SetAttribute("AimLockActive", false)
end

local function getHumanoidAndRoot()
	local character = player.Character
	if not character then
		return nil, nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	return humanoid, root
end

local function setCursor(iconId)
	if iconId then
		mouse.Icon = "rbxassetid://" .. tostring(iconId)
	else
		mouse.Icon = ""
	end
end

local function applyVisualState()
	if locked and currentConfig then
		targetOffset = currentConfig.Offset or Vector3.new(1.25, 0.2, 0)
		smoothSpeed = currentConfig.SmoothSpeed or 18
		cursorIconId = currentConfig.CursorIconId
		showMouseIcon = currentConfig.ShowMouseIcon ~= false
		rotateCharacterWithCamera = currentConfig.RotateCharacterWithCamera == true

		player:SetAttribute("AimLockActive", true)

		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = showMouseIcon

		if showMouseIcon and cursorIconId then
			setCursor(cursorIconId)
		else
			setCursor(nil)
		end
	else
		targetOffset = Vector3.zero
		rotateCharacterWithCamera = false

		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
		setCursor(nil)

		player:SetAttribute("AimLockActive", false)
	end
end

local function ensureRenderConnection()
	if renderConnection then
		return
	end

	renderConnection = RunService.RenderStepped:Connect(function(dt)
		local humanoid, root = getHumanoidAndRoot()
		if not humanoid then
			return
		end

		local alpha = 1 - math.exp(-smoothSpeed * dt)
		currentOffset = currentOffset:Lerp(targetOffset, alpha)
		humanoid.CameraOffset = currentOffset

		if locked and rotateCharacterWithCamera and root then
			if savedAutoRotate == nil then
				savedAutoRotate = humanoid.AutoRotate
			end

			humanoid.AutoRotate = false

			local camera = Workspace.CurrentCamera
			if camera then
				local look = camera.CFrame.LookVector
				local flatLook = Vector3.new(look.X, 0, look.Z)

				if flatLook.Magnitude > 0.001 then
					flatLook = flatLook.Unit
					root.CFrame = CFrame.new(root.Position, root.Position + flatLook)
				end
			end
		elseif savedAutoRotate ~= nil then
			humanoid.AutoRotate = savedAutoRotate
			savedAutoRotate = nil
		end

		if not locked and currentOffset.Magnitude <= 0.01 then
			humanoid.CameraOffset = Vector3.zero
			currentOffset = Vector3.zero

			if renderConnection then
				renderConnection:Disconnect()
				renderConnection = nil
			end
		end
	end)
end

local function refresh()
	applyVisualState()
	ensureRenderConnection()
end

function SmoothShiftLock.Enable(owner, config)
	if not owner then return end

	currentOwner = owner
	currentConfig = config or {}
	locked = true

	refresh()
end

function SmoothShiftLock.Disable(owner)
	if currentOwner ~= owner then
		return
	end

	currentOwner = nil
	currentConfig = nil
	locked = false

	refresh()
end

function SmoothShiftLock.Toggle(owner)
	if currentOwner ~= owner then
		return
	end

	locked = not locked

	if not locked and owner == MANUAL_OWNER then
		currentOwner = nil
		currentConfig = nil
	end

	refresh()
end

function SmoothShiftLock.ToggleManual(configOverride)
	-- Si una tool es dueña y no permite Ctrl, no hacer nada
	if currentOwner and currentOwner ~= MANUAL_OWNER then
		if currentConfig and currentConfig.AllowToggleWithCtrl == false then
			return
		end

		locked = not locked
		refresh()
		return
	end

	-- Modo manual global
	if currentOwner ~= MANUAL_OWNER then
		currentOwner = MANUAL_OWNER
		currentConfig = configOverride or DEFAULT_MANUAL_CONFIG
		locked = true
	else
		locked = not locked

		if not locked then
			currentOwner = nil
			currentConfig = nil
		end
	end

	refresh()
end

function SmoothShiftLock.IsEnabled(owner)
	if owner then
		return currentOwner == owner and locked
	end
	return locked
end

function SmoothShiftLock.IsOwnedBy(owner)
	return currentOwner == owner
end

function SmoothShiftLock.GetOwner()
	return currentOwner
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
		SmoothShiftLock.ToggleManual()
	end
end)

return SmoothShiftLock