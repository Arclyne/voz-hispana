local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)

local remotes = ReplicatedStorage.Events
local cooldown = 0.1
local debounce = false

local Seat = {}
Seat.__index = Seat
setmetatable(Seat, Interactable)

function Seat.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, Seat)
	
	self.seat = model:WaitForChild("Seat")
	self.wheel = self:getDefaultWheel()
	
	self:setAdornee(self.seat)
	self:setClickHitbox(model)
	self.wheel:setQuickAction("Sentarse", self.sit, self)
	self.wheel.page:addAction("Sentarse", self.sit, self)

	self.seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if (self.seat.Occupant) then
			self:disable()
		else
			self:enable()
		end
	end)
	
	if self.seat.Occupant then
		self:disable()
	end
	
	return self
end

function Seat:sit()
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	if debounce then
		return
	end
	
	debounce = true
	remotes.Interactable.Sit:FireServer(self.seat)
	task.wait(cooldown)
	debounce = false
end

return Seat
