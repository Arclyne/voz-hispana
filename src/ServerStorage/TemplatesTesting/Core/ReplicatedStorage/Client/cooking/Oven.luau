local TweenService = game:GetService("TweenService")
local CookingInteractable = require(script.Parent.CookingInteractable)

local LIGHT_TWEEN_INFO = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local LIGHT_MAX_RANGE = 8

local DOOR_TWEEN_INFO = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local DOOR_OPEN_ANGLE = math.rad(-67)

local Oven = {}
Oven.__index = Oven
setmetatable(Oven, CookingInteractable)

function Oven.new(model: Model)
	local self = CookingInteractable.new(model, "Oven")
	setmetatable(self, Oven)

	local wheel = self:addWheel("bake", function(tool)
		return tool:GetAttribute("Bakeable")
	end)
	wheel:setQuickAction("Hornear", self.request, self)
	wheel.page:addAction("Hornear", self.request, self)

	local light = model:FindFirstChild("Light")
	local pointLight = light and light:FindFirstChildOfClass("PointLight")
	if pointLight then
		pointLight.Range = 0
	end

	local door = model:FindFirstChild("Door")
	local doorPivot = door and door.PrimaryPart
	local closedCFrame = doorPivot and doorPivot.CFrame

	model:GetAttributeChangedSignal("DoorOpen"):Connect(function()
		if not doorPivot or not closedCFrame then
			return
		end

		local targetCFrame = if model:GetAttribute("DoorOpen")
			then closedCFrame * CFrame.Angles(DOOR_OPEN_ANGLE, 0, 0)
			else closedCFrame

		TweenService:Create(doorPivot, DOOR_TWEEN_INFO, { CFrame = targetCFrame }):Play()
	end)

	model:GetAttributeChangedSignal("Active"):Connect(function()
		if model:GetAttribute("Active") then
			self:disable()
			if pointLight then
				TweenService:Create(pointLight, LIGHT_TWEEN_INFO, { Range = LIGHT_MAX_RANGE }):Play()
			end
		else
			self:enable()
			if pointLight then
				TweenService:Create(pointLight, LIGHT_TWEEN_INFO, { Range = 0 }):Play()
			end
		end
	end)

	return self
end

return Oven
