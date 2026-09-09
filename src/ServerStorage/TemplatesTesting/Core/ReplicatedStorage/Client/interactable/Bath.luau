local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)

local WATER_FADE_DURATION = 2
local WATER_TRANSPARENCY = 0.15

local remotes = ReplicatedStorage.Events
local cleanup: (() -> ())?

local Bath = {}
Bath.__index = Bath
setmetatable(Bath, Interactable)

function Bath.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, Bath)

	self.model = model
	self.water = model:WaitForChild("Water")
	self.wheel = self:getDefaultWheel()
	self.wheel:setQuickAction("Bañarse", self.bath, self)
	self.wheel.page:addAction("Bañarse", self.bath, self)
	
	self:setAdornee(model:WaitForChild("Prompt"))
	self:setClickHitbox(model)

	local seat = model:FindFirstChildOfClass("Seat")
	seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if seat.Occupant then
			self:on()
			self:disable()
		else
			self:off()
			self:enable()
		end
	end)

	if seat.Occupant then
		self:on()
		self:disable()
	end
	
	return self
end

function Bath:bath()
	remotes.Interactable.Bath:FireServer(self.model)
end

function Bath:on()
	TweenService:Create(self.water, TweenInfo.new(WATER_FADE_DURATION), { Transparency = WATER_TRANSPARENCY }):Play()

	for _, particle in self.model:GetDescendants() do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = true
		end
	end
end

function Bath:off()
	TweenService:Create(self.water, TweenInfo.new(WATER_FADE_DURATION), { Transparency = 1 }):Play()

	for _, particle in self.model:GetDescendants() do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = false
		end
	end
end

return Bath
