local UserInput   = game:GetService("UserInputService")
local Replicated  = game:GetService("ReplicatedStorage")
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")

local ActionModule = require(script:WaitForChild("MouseAction"))

local player      = Players.LocalPlayer
local mouse       = player:GetMouse()
local camera      = workspace.CurrentCamera

local EventsRoot  = Replicated:WaitForChild("Events")
local defaultIcon = ""
local hoverIcon   = "rbxassetid://113162006500501"

local ProximityPrompt = game:GetService("ProximityPromptService")

-- INICIALIZAR ATRIBUTO (Interruptor)
if script:GetAttribute("IsActive") == nil then
	script:SetAttribute("IsActive", true)
end

local lastDet
local lastHighlight

-- FUNCIÓN DE LIMPIEZA
-- Necesaria para que no se quede un highlight pegado si desactivas el script mientras miras un objeto
local function cleanup(preserveCursor)
	if not preserveCursor then
		mouse.Icon = defaultIcon
	end

	if lastHighlight and lastHighlight.Parent then
		ActionModule.eventExit:Fire(lastHighlight.Parent)
		lastHighlight:Destroy()
		lastHighlight = nil
	end

	lastDet = nil
end

local function isInteractiveCursorEnabled()
	return script:GetAttribute("IsActive") and not player:GetAttribute("AimLockActive")
end

player:GetAttributeChangedSignal("AimLockActive"):Connect(function()
	if player:GetAttribute("AimLockActive") then
		cleanup(true)
	end
end)

-- DETECTAR EL CAMBIO DE ATRIBUTO
script:GetAttributeChangedSignal("IsActive"):Connect(function()
	if not script:GetAttribute("IsActive") then
		cleanup(player:GetAttribute("AimLockActive"))
	end
end)

ProximityPrompt:GetPropertyChangedSignal("Enabled"):Connect(function()
	script:SetAttribute("IsActive", ProximityPrompt.Enabled)
end)

local function getDetectorFromPart(part)
	local current = part
	while current do
		local det = current:FindFirstChildOfClass("ClickDetector")
		if det then
			return det
		end
		current = current.Parent
	end
	return nil
end

local function withinDistance(det, hitPos)
	local maxDist = det:GetAttribute("MaxDistance")
	if not hitPos then return false end
	if not maxDist or maxDist <= 0 then return false end

	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return false end

	return (rootPart.Position - hitPos).Magnitude <= maxDist
end

local function handleClick(det)
	local current = det:GetAttribute("ClickChangeSignal")
	if current == nil then current = false end
	det:SetAttribute("ClickChangeSignal", not current)

	local sv = det:FindFirstChild("EventName")
	if sv and sv.Value ~= "" then
		local rem = EventsRoot:FindFirstChild(sv.Value, true)
		if rem and rem:IsA("RemoteEvent") then
			rem:FireServer(det)
		end
	end
end

-- Hover
RunService.RenderStepped:Connect(function()
	if not isInteractiveCursorEnabled() then
		return
	end

	local part   = mouse.Target
	local det    = getDetectorFromPart(part)
	local hitPos = mouse.Hit and mouse.Hit.Position

	if det and det ~= lastDet and withinDistance(det, hitPos) then
		mouse.Icon = hoverIcon

		if lastHighlight and lastHighlight.Parent then
			lastHighlight:Destroy()
		end

		local hl = Instance.new("Highlight")
		hl.FillTransparency = 1
		hl.Parent = det.Parent
		hl.Adornee = det.Parent
		lastHighlight = hl

		ActionModule.event:Fire(det.Parent)

		lastDet = det

	elseif (not det or not withinDistance(det, hitPos)) and lastDet then
		mouse.Icon = defaultIcon

		if lastHighlight and lastHighlight.Parent then
			ActionModule.eventExit:Fire(lastHighlight.Parent)
			lastHighlight:Destroy()
			lastHighlight = nil
		end

		lastDet = nil
	end
end)

-- Click hooking (PC + móvil)
UserInput.InputBegan:Connect(function(input, gp)
	if gp then return end
	if not isInteractiveCursorEnabled() then return end

	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local hitPart, hitPos

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		hitPart = mouse.Target
		hitPos  = mouse.Hit and mouse.Hit.Position
	else
		local viewportPoint = Vector2.new(input.Position.X, input.Position.Y)
		local unitRay = camera:ScreenPointToRay(viewportPoint.X, viewportPoint.Y)

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = { player.Character }
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local rayResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, rayParams)
		if rayResult then
			hitPart = rayResult.Instance
			hitPos  = rayResult.Position
		end
	end

	if not hitPart then return end
	local det = getDetectorFromPart(hitPart)
	if not det or not withinDistance(det, hitPos) then return end

	handleClick(det)
end)