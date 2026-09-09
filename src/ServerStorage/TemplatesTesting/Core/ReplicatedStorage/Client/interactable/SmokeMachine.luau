local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)

local remotes = ReplicatedStorage.Events

local SmokeMachine = {}
SmokeMachine.__index = SmokeMachine
setmetatable(SmokeMachine, Interactable)

function SmokeMachine.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, SmokeMachine)

	self.model = model
	self.wheel = self:getDefaultWheel()
	self.debounce = false
	
	if model:GetAttribute("Enabled") then
		self:on()
	else
		self:off()
	end

	model:GetAttributeChangedSignal("Enabled"):Connect(function()
		if model:GetAttribute("Enabled") then
			self:on()
		else
			self:off()
		end
	end)

	self:setAdornee(model:FindFirstChild("Prompt"))
	self:setClickHitbox(model)

	return self
end

function SmokeMachine:on()
	self.wheel:setQuickAction("Apagar", self.request, self)
	self.wheel.page:addAction("Apagar", self.request, self)
	self.wheel.page:removeAction("Encender")
	
	for _, particle in self.model:GetDescendants() do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = true
		end
	end
end

function SmokeMachine:off()
	self.wheel:setQuickAction("Encender", self.request, self)
	self.wheel.page:addAction("Encender", self.request, self)
	self.wheel.page:removeAction("Apagar")
	
	for _, particle in self.model:GetDescendants() do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = false
		end
	end
end

function SmokeMachine:request()
	if self.debounce then
		return
	end
	
	self.debounce = true
	remotes.Interactable.SmokeMachine:FireServer(self.model)
	
	task.wait(0.5)
	self.debounce = false
end

return SmokeMachine
