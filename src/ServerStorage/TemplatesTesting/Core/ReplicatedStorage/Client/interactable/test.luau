local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)

local player = Players.LocalPlayer
local sleepAnimation = Instance.new("Animation")
sleepAnimation.AnimationId = "rbxassetid://114963865100023"

local remotes = ReplicatedStorage.Events
local debounce = false
local cooldown = 1

local test = {}
test.__index = test
setmetatable(test, Interactable)

function test.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, test)

	self.track = nil
	self.model = model
	self.wheel = self:getDefaultWheel()

	self:setAdornee(model)
	self:setClickHitbox(model)
	self.wheel:setQuickAction("Dormir", self.sleep, self)
	self.wheel.page:addAction("Dormir", self.sleep, self)

	return self
end

function test:sleep()
	if self.currentTween then return end
	
	
	local tweenControl = Interactable:TweenBar(7, self.model, function()
		print("termiando")
		self.currentTween = nil
	end)

	self.currentTween = tweenControl
end

function test:cancelSleep()
	if self.currentTween then
		self.currentTween.Cancel()
		self.currentTween = nil
	end
end

return test
