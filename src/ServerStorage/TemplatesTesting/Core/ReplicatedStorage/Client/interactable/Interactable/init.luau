--//

local players = game:GetService("Players")
local ReplicateStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local debris = game:GetService("Debris")

--//

local player = players.LocalPlayer

--//

local ActionWheel = require(script:WaitForChild("ActionWheel"))
local CustomPrompt = require(script:WaitForChild("CustomPrompt"))
local defaultDesing = {
	FillTransparency = 1,
	FillColor = Color3.new(0, 1, 0),
	OutlineColor = Color3.new(1, 1, 1),
	OutlineTransparency = 0,
	Parent = false,
}

local MAX_INTERACTION_DISTANCE = 18
local LINE_OF_SIGHT_INTERVAL = .05
local LINE_OF_SIGHT_MARGIN = 5

local activeInteractables = setmetatable({}, {__mode = "k"})

--//

local Interactable = {}
Interactable.__index = Interactable

function Interactable.new()
	local self = setmetatable({}, Interactable)

	--//Init
	self.adornee = nil
	self.clickHitbox = nil
	self.selectedWheel = nil
	self.wheelLocked = false
	self.enabled = true
	self.maxDistance = MAX_INTERACTION_DISTANCE
	self.promptIsVisible = false
	self.actionWheels = {}
	self.connectionDebris = {}
	self.clickDetector = Instance.new("ClickDetector")
	self.proximityPrompt = Instance.new("ProximityPrompt")
	self.customPrompt = CustomPrompt.new()
	self.clickDetector.MaxActivationDistance = 0 -- Esto se hace porque no queremos
	-- usar el de roblox
	--//Setup
	self.proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	self.proximityPrompt.HoldDuration = 0
	self.proximityPrompt.RequiresLineOfSight = false
	self.proximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	self:setMaxDistance(self.maxDistance)
	self.customPrompt:setPrompt(self.proximityPrompt)
	self.selectedWheel = self:addWheel("default")
	activeInteractables[self] = true
	--//Events
	self.proximityPrompt.PromptShown:Connect(function()
		self.promptIsVisible = true
		self:selectWheel()
		local character = player.Character
		table.insert(self.connectionDebris, character.ChildAdded:Connect(function(child)
			if (not child:isA("Tool")) then return end;
			self:selectWheel()
		end))
		table.insert(self.connectionDebris, character.ChildRemoved:Connect(function(child)
			if (not child:isA("Tool")) then return end;
			self:selectWheel()
		end))
	end)
	self.proximityPrompt.PromptHidden:Connect(function()
		self.promptIsVisible = false
		for _, connection in pairs(self.connectionDebris) do
			connection:Disconnect()
		end
		if (self.selectedWheel) then
			self.selectedWheel:hide()
		end
	end)
	self.proximityPrompt.Triggered:Connect(function()
		if not self.selectedWheel then
			return
		end
		if (self.selectedWheel:getActivePage()) then return end;
		if (self.selectedWheel.quickAction) then
			self.selectedWheel.quickAction:perform()
		else
			self.customPrompt:hide()
			self.selectedWheel:show()
		end
	end)
	self.clickDetector:GetAttributeChangedSignal("ClickChangeSignal"):Connect(function()
		if not self.selectedWheel then
			return
		end
		self.customPrompt:hide()
		self.selectedWheel:show()
	end)
	-- Para que funcione en movil
	self.customPrompt.ui.Background.MobileIcon.Activated:Connect(function()
		if not self.selectedWheel then
			return
		end
		-- Simulamos un tap: comenzamos y terminamos el hold tÃ¡ctil
		self.proximityPrompt:InputHoldBegin(Enum.ProximityPromptInputType.Touch)
		self.proximityPrompt:InputHoldEnd  (Enum.ProximityPromptInputType.Touch)
	end)

	return self, self:getDefaultWheel()
end

function Interactable:AddHighlight(create)
	if create == nil then create = true end
	if create and not self.HighlightModel then
		local higl = Instance.new("Highlight")
		local IsDataDesing = typeof(create)=="table"
		for index, value in defaultDesing do
			higl[index] = IsDataDesing and create[index] or index=="Parent" and self.model or value
		end
		self.HighlightModel = higl
	elseif not create and self.HighlightModel then
		self.HighlightModel.Enabled = false
		debris:AddItem(self.HighlightModel,0)
		self.HighlightModel = nil
	end
end
function Interactable:RemoveHighlight() self:AddHighlight(false) end

function Interactable:GetPivot()
	if not self.adornee then return Vector3.zero end
	return self.adornee:IsA("Attachment") and self.adornee.WorldPosition or self.adornee:GetPivot().Position
end

function Interactable:_hasLineOfSight()
	if not self.adornee then
		return false
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return false
	end

	local origin = camera.CFrame.Position
	local target = self:GetPivot()
	local direction = target - origin

	if direction.Magnitude <= .01 then
		return true
	end

	local rayParams = RaycastParams.new()
	local filter = {}

	if player.Character then
		table.insert(filter, player.Character)
	end

	if self.model then
		table.insert(filter, self.model)
	elseif self.adornee then
		table.insert(filter, self.adornee)
	end

	rayParams.FilterDescendantsInstances = filter
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	return workspace:Raycast(origin, direction, rayParams) == nil
end

function Interactable:_updateLineOfSight()
	if not self.enabled or not self.adornee then
		return
	end

	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end

	local distance = (rootPart.Position - self:GetPivot()).Magnitude

	if distance > self.maxDistance + LINE_OF_SIGHT_MARGIN then
		if not self.proximityPrompt.Enabled then
			self.proximityPrompt.Enabled = true
		end
		return
	end

	local hasLineOfSight = self:_hasLineOfSight()

	if self.proximityPrompt.Enabled ~= hasLineOfSight then
		self.proximityPrompt.Enabled = hasLineOfSight
	end
end

function Interactable:addWheel(toolName, predicate)
	local wheel = ActionWheel.new()
	wheel.predicate = predicate
	wheel:setAdornee(self.adornee)

	self.actionWheels[toolName] = wheel
	wheel.page.hidden.Event:Connect(function()
		if (wheel:getActivePage() or not self.proximityPrompt.Enabled) then return end;
		if (player:DistanceFromCharacter(self:GetPivot())
			< self.maxDistance and self.promptIsVisible) then
			self.customPrompt:show()
		end
	end)
	wheel.quickActionChanged.Event:Connect(function()
		if (self.selectedWheel == wheel) then
			self.customPrompt:setActionText(wheel.quickAction.actionName)
		end
	end)

	return wheel
end

function Interactable:_getPredicatedWheel(tool)
	if not tool then
		return nil
	end

	for _, wheel in self.actionWheels do
		if wheel.predicate and wheel.predicate(tool) then
			return wheel
		end
	end
end

function Interactable:selectWheel()
	if (self.wheelLocked) then return end;

	if (self.selectedWheel) then
		self.selectedWheel:hide()
	end

	local character = player.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	local wheel = tool and self.actionWheels[tool.Name]
		or self:_getPredicatedWheel(tool)
		or self.actionWheels.default

	self:setupWheel(wheel)
end

function Interactable:lockWheel(wheelName)
	local wheel = self.actionWheels[wheelName]
	if (not wheel) then return end;

	self.wheelLocked = true

	if (self.selectedWheel) then
		self.selectedWheel:hide()
	end

	self:setupWheel(wheel)
end

function Interactable:unlock()
	self.wheelLocked = false
	self:selectWheel();
end

function Interactable:setupWheel(wheel)
	if not wheel then
		self.customPrompt:disable()
		self.selectedWheel = nil
		return
	end

	self.customPrompt:enable()
	if (wheel.quickAction) then
		self.customPrompt:setActionText(wheel.quickAction.actionName)
	else
		self.customPrompt:setActionText("Interactuar")
	end
	if (player:DistanceFromCharacter(self:GetPivot()) < self.clickDetector:GetAttribute("MaxDistance"))
		and self.promptIsVisible then
		self.customPrompt:show()
	end
	self.selectedWheel = wheel
end


function Interactable:removeWheel(wheelName)
	local wheel = self.actionWheels[wheelName]
	if (not wheel) then return end;
	wheel:destroy();
	self.actionWheels[wheelName] = nil
	self:selectWheel()
end

function Interactable:setKey(key)
	self.proximityPrompt.KeyboardKeyCode = key
	self.customPrompt:setKeyText(key.Name)
end

function Interactable:setMaxDistance(distance)
	distance = math.clamp(distance, 0, MAX_INTERACTION_DISTANCE)
	self.maxDistance = distance

	if not self.enabled then
		return
	end

	self.proximityPrompt.MaxActivationDistance = distance
	self.clickDetector:SetAttribute("MaxDistance", distance)
end

function Interactable:setAdornee(adornee)
	self.adornee = adornee
	self.proximityPrompt.Parent = adornee
	self.customPrompt:setAdornee(adornee)
	for _, actionWheel in pairs(self.actionWheels) do
		actionWheel:setAdornee(adornee)
	end
end

function Interactable:setClickHitbox(hitbox)
	self.clickHitbox = hitbox
	self.clickDetector.Parent = hitbox
end

function Interactable:getDefaultWheel()
	return self.actionWheels.default
end

function Interactable:enable()
	self.enabled = true
	self.proximityPrompt.MaxActivationDistance = self.maxDistance
	self.clickDetector:SetAttribute("MaxDistance", self.maxDistance)
	self:_updateLineOfSight()
end

function Interactable:disable()
	self.enabled = false
	self.proximityPrompt.Enabled = false
	self.proximityPrompt.MaxActivationDistance = 0
	self.clickDetector:SetAttribute("MaxDistance", 0)
	self.customPrompt:hide()
	if (self.selectedWheel) then self.selectedWheel:hide() end
end

function Interactable:TweenBar(Duration: number, Character: Model, Callback: () -> ())
	local barTemplate = ReplicateStorage.Assets.Interactable.Billboard.Bar
	local newBar = barTemplate:Clone()
	newBar.Name = "Bar_Local"

	-- siempre al Head, no al Model
	local head = Character:FindFirstChild("Head")
	if not head then
		return nil
	end

	-- si es BillboardGui, asignar adornee
	if newBar:IsA("BillboardGui") then
		newBar.Adornee = head
	end

	-- si ya había una local, la reemplazamos
	local old = head:FindFirstChild("Bar_Local")
	if old then old:Destroy() end

	newBar.Parent = head

	local barFrame = newBar:FindFirstChild("ToolActivatedBar", true)
	local progressBar = barFrame and barFrame:FindFirstChild("Bar", true)
	if not barFrame or not progressBar then
		newBar:Destroy()
		return nil
	end

	progressBar.Size = UDim2.new(0, 0, 1, 0)
	barFrame.Visible = true

	local tweenInfo = TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(progressBar, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)})

	local cancelled = false

	tween.Completed:Connect(function(state)
		if cancelled then return end
		if state == Enum.PlaybackState.Completed then
			barFrame.Visible = false

			if Callback then
				Callback()
			end

			task.delay(0.25, function()
				if newBar and newBar.Parent then
					newBar:Destroy()
				end
			end)
		end
	end)

	tween:Play()

	return {
		Pause = function()
			tween:Pause()
		end,
		Cancel = function()
			cancelled = true
			tween:Cancel()
			if newBar and newBar.Parent then
				newBar:Destroy()
			end
		end
	}
end

local lineOfSightElapsed = 0

RunService.Heartbeat:Connect(function(deltaTime)
	lineOfSightElapsed += deltaTime

	if lineOfSightElapsed < LINE_OF_SIGHT_INTERVAL then
		return
	end

	lineOfSightElapsed = 0

	for interactable in activeInteractables do
		interactable:_updateLineOfSight()
	end
end)

return Interactable