local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)

local remotes = ReplicatedStorage.Events

local Toilet = {}
Toilet.__index = Toilet
setmetatable(Toilet, Interactable)

function Toilet.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, Toilet)

	self.model = model
	self.hinge = model:WaitForChild("Hinge")
	self.wheel = self:getDefaultWheel()
	self.wheel:setQuickAction("Usar", self.use, self)
	self.wheel.page:addAction("Usar", self.use, self)

	self:setAdornee(model:WaitForChild("Prompt"))
	self:setClickHitbox(model)

	local seat = model:WaitForChild("Seat")
	seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if seat.Occupant then
			self:disable()
		else
			self:enable()
		end
	end)
	
	if seat.Occupant then
		self:disable()
	end

	return self
end

function Toilet:use()
	remotes.Interactable.Toilet:FireServer(self.model)
end

return Toilet
