local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage.Events

local IdleToggle = {}
IdleToggle.__index = IdleToggle

setmetatable(IdleToggle, Interactable)

function IdleToggle.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, IdleToggle)

	self.model = model
	self.wheel = self:getDefaultWheel()
	self.wheel:setQuickAction("Activar", self.start, self)
	self.wheel.page:addAction("Activar", self.start, self)

	self:setAdornee(model.Prompt)
	self:setClickHitbox(model)
	
	game:GetAttributeChangedSignal("Idling"):Connect(function()
		if game:GetAttribute("Idling") then
			self:start()
		else
			self:stop()
		end
	end)
	
	if game:GetAttribute("Idling") then
		self:start()
	end

	return self
end

function IdleToggle:start()
	self.wheel:setQuickAction("Desactivar", self.stop, self)
	self.wheel.page:addAction("Desactivar", self.stop, self)
	self.wheel.page:removeAction("Activar")
	
	game:SetAttribute("Idling", true)
end

function IdleToggle:stop()
	self.wheel:setQuickAction("Activar", self.start, self)
	self.wheel.page:addAction("Activar", self.start, self)
	self.wheel.page:removeAction("Desactivar")
	
	game:SetAttribute("Idling", false)
end

return IdleToggle
