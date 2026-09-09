local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)

local player = Players.LocalPlayer
local Usos = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("JobSystem"))

local test = {}
test.__index = test
setmetatable(test, Interactable)

function test.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, test)

	self.model = model
	self.wheel = self:getDefaultWheel()

	self:setAdornee(model:FindFirstChild("Prompt"))
	self:setClickHitbox(model)
	
	self.wheel:setQuickAction("Soltar", self.Soltar, self)
	self.wheel.page:addAction("Soltar", self.Soltar, self)

	return self
end

function test:Soltar()
	local intance = Usos.SearchModel(script.Name, self.model)
	if not intance then return end
	intance:Buy()
end

return test
