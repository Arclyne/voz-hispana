local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage.Events

local ClassicDoor = {}
ClassicDoor.__index = ClassicDoor

setmetatable(ClassicDoor, Interactable)

function ClassicDoor.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, ClassicDoor)
	
	self.model = model
	self.wheel = self:getDefaultWheel()

	self:setAdornee(model:FindFirstChild("Proxi") or model:WaitForChild("Proxi"))
	self:setClickHitbox(model)
	
	self:changeAttribute()
	model.AttributeChanged:Connect(function() self:changeAttribute() end)

	return self
end

function ClassicDoor:Open()
	remotes.Interactable.ClassicDoor:FireServer(self.model,"OpenClose")
end

function ClassicDoor:changeAttribute()
	self.wheel.page:removeAction('Open')
	self.wheel.page:removeAction('Close')
	local IsActionInProcess = self.model:GetAttribute("IsActionInProcess")
	if IsActionInProcess then
		self:disable()
	else
		local DoorIsOpen = self.model:GetAttribute("IsOpen")
		local TextOpenClose = DoorIsOpen and "Close" or "Open"
		self.wheel:setQuickAction(TextOpenClose,self.Open, self)
		self.wheel.page:addAction(TextOpenClose, self.Open, self)
		self:enable()
	end
end

return ClassicDoor
