local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)
local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))

local remotes = ReplicatedStorage.Events
local cooldown = 1
local debounce = false

local Lamp = {
	colors = {
		Color3.new(0.545098, 0.682353, 1),
		Color3.new(1, 0.580392, 0.454902),
		Color3.new(0.545098, 1, 0.419608),
		Color3.new(0.921569, 0.992157, 1)
	}
}

Lamp.__index = Lamp
setmetatable(Lamp, Interactable)

function Lamp.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, Lamp)

	self.model = model
	self.wheel = self:getDefaultWheel()

	self:setAdornee(model:WaitForChild("LightPart"))
	self:setClickHitbox(model)
	self.wheel:setQuickAction("Encender", self.lightOn, self)
	self.wheel.page:addAction("Encender", self.lightOn, self)

	local colorsPage = self.wheel:addPage("Colores")
	for i, color in pairs(self.colors) do
		colorsPage:addAction("Color " .. i, self.setColor, self, Lamp.colors[i])
	end
	
	model.AttributeChanged:Connect(function(Attribute)
		if Attribute=="IsOn" then
			self:ChangeState()
		end
	end)
	self:ChangeState()
	
	return self
end

function Lamp:setColor(color)
	--[[remotes.Interactable.Lamp:FireServer("changeColor", {{
		model = self.model,
		lightColor = self.model:FindFirstChild("LightColor"),
		lightBulb = self.model:FindFirstChild("Lightbulb"),
		color = color
	}})]]
	remotes.Interactable.Lamp:FireServer(color, self.model)
end

function Lamp:ChangeState()
	local IsOn = self.model:GetAttribute("IsOn")
	self.wheel.page:removeAction(IsOn and "Encender" or "Apagar")
	self.wheel.page:addAction(IsOn and "Apagar" or "Encender", IsOn and self.lightOff or self.lightOn, self)
	self.wheel:setQuickAction(IsOn and "Apagar" or "Encender", IsOn and self.lightOff or self.lightOn, self)
end

function Lamp:lightOn()
	SoundManager:Play(nil, 139464282770830, { Volume = 1 }, self.model)
	remotes.Interactable.Lamp:FireServer(true, self.model)
	--[[remotes.Interactable.Lamp:FireServer("lightOn", {{
		model = self.model,
		lightColor = self.model:FindFirstChild("LightColor"),
		lightBulb = self.model:FindFirstChild("Lightbulb"),
	}})]]
end

function Lamp:lightOff()
	SoundManager:Play(nil, 139464282770830, { Volume = 1 }, self.model)
	remotes.Interactable.Lamp:FireServer(false, self.model)
	--[[remotes.Interactable.Lamp:FireServer("lightOff", {{
		model = self.model,
		lightColor = self.model:FindFirstChild("LightColor"),
		lightBulb = self.model:FindFirstChild("Lightbulb"),
	}})]]
end

return Lamp
