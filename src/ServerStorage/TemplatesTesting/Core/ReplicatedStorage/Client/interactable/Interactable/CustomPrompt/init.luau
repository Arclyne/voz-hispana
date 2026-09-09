--//

local players = game:GetService("Players")
local tween = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--//

local player = players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local assets = script:WaitForChild("Assets")
local proximityPromptUI = assets:WaitForChild("ProximityPromptUI")

local customPrompts = Instance.new("ScreenGui")
customPrompts.ResetOnSpawn = false
customPrompts.Parent = playerGui
customPrompts.Name = "CustomPrompts"

--//

local CustomPrompt = {}
CustomPrompt.__index = CustomPrompt

function CustomPrompt.new()
	local self = setmetatable({}, CustomPrompt)
	
	--//Init
	self.enabled = true
	self.adornee = nil
	self.proximityPrompt = nil
	self.ui = proximityPromptUI:Clone()
	--//Setup
	self.ui.Parent = customPrompts
	self:setActionText("Interactuar")

	self.ui.ExtentsOffset = Vector3.new((
		self.ui.Background.Action.Size.X.Scale +
		self.ui.Background.Key.Size.X.Scale), 0, 0)
	--
	
	if UserInputService.TouchEnabled then
		self.ui.Background.Key.Visible = false
		self.ui.Background.MobileIcon.Visible = true
	end

	return self
end

function CustomPrompt:enable()
	self.enabled = true
end

function CustomPrompt:disable()
	self.enabled = false
	self:hide()
end

function CustomPrompt:show()
	if not self.enabled then
		return
	end

	self.ui.Adornee = self.adornee
	self.ui.Enabled = true
	self.ui.Background:TweenSize(
		UDim2.fromScale(1, 1),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Sine,
		.1,
		true
	)
end

function CustomPrompt:hide()
	self.ui.Background:TweenSize(
		UDim2.fromScale(0, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Sine,
		.1,
		true
	)
	task.wait(.1)
	self.ui.Enabled = false
	self.ui.Adornee = nil
end

function CustomPrompt:setActionText(text)
	self.ui.Background.Action.Text = text
	
	local textBounds = self.ui.Background.Action.TextBounds
	local sizeInScale = textBounds.X / 160
	self.ui.Background.Action.Size = UDim2.fromScale(sizeInScale + .17, 1)
end

function CustomPrompt:setKeyText(key)
	self.ui.Background.Key.Text = key
end

function CustomPrompt:setAdornee(adornee)
	self.adornee = adornee
end

function CustomPrompt:setPrompt(prompt)
	self.proximityPrompt = prompt
	self.proximityPrompt.PromptShown:Connect(function()
		self:show()
	end)
	self.proximityPrompt.PromptHidden:Connect(function()
		self:hide()
	end)
	self.proximityPrompt.Triggered:Connect(function()
		tween:Create(
			self.ui.Background.Key.UIScale,
			TweenInfo.new(.1, Enum.EasingStyle.Sine),
			{Scale = 1.1}
		):Play()
	end)
	self.proximityPrompt.TriggerEnded:Connect(function()
		tween:Create(
			self.ui.Background.Key.UIScale,
			TweenInfo.new(.1, Enum.EasingStyle.Sine),
			{Scale = 1}
		):Play()
	end)
end

return CustomPrompt
