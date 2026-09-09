local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage.Events

local Bin = {}
Bin.__index = Bin

setmetatable(Bin, Interactable)

function Bin.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, Bin)

	self.model = model
	self.wheel = self:addWheel("throw", function(tool)
		return tool:GetAttribute("Kitchen")
	end)
	self.wheel:setQuickAction("Arrojar", self.throw, self)
	self.wheel.page:addAction("Arrojar", self.throw, self)

	self:removeWheel("default")
	self:setAdornee(model.Prompt)
	self:setClickHitbox(model)

	return self
end

function Bin:throw()
	remotes.Interactable.Bin:FireServer()
end

return Bin
