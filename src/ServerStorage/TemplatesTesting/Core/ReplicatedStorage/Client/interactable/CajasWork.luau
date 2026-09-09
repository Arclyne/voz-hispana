local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)

local Chamba = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("JobSystem"))

local Box = {}
Box.__index = Box
setmetatable(Box, Interactable)

function Box.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, Box)

	self.track = nil
	self.model = model
	self.wheel = self:getDefaultWheel()

	self:setAdornee(model:FindFirstChild("Prompt"))
	self:setClickHitbox(model)
	
	
	self:_init()
	model.AttributeChanged:Connect(function(attribute)
		if attribute == "Occuped" then
			self:_init()
		end
	end)
	
	return self
end

function Box:GetBox()
	local object = Chamba.SearchModel("CajasWork", self.model)
	if not object or not object.Occupant then return end
	object:GiveBox()
end

function Box:_init()
	if self.model:GetAttribute("Occuped") then
		
		self.wheel:setQuickAction("Obtener", self.GetBox, self)
		self.wheel.page:addAction("Obtener", self.GetBox, self)
		self:enable()
		self:AddHighlight()
		
	else
		self.wheel.page:removeAction("Obtener")
		self:RemoveHighlight()
		self:disable()
	end
end

return Box
