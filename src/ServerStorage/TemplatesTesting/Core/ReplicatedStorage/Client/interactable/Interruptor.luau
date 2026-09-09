local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)
local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))
local StoreFun = require(ReplicatedStorage:WaitForChild('Shared'):WaitForChild('Stores'))

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

	self:setAdornee(model.PrimaryPart or model:WaitForChild("Primary"))
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

function Lamp:GetDecors(color)
	local list = {}
	if StoreFun.StoresList then
		for _,Store in StoreFun.StoresList do
			if Store.Occuped and self.model:IsDescendantOf(Store.Decors) then
				for _,model:Model in Store.Decors:GetChildren() do
					if model ~= self.model and model:HasTag("Lamp") then
						table.insert(list, {
							model = model,
							lightColor = model:FindFirstChild("LightColor"),
							lightBulb = model:FindFirstChild("Lightbulb"),
							color = typeof(color)=="Color3" and color or nil,
						})
					end
				end
			end
		end
	elseif StoreFun.Added and StoreFun.Added:IsA("House") then
		local Room = StoreFun.Added:SearchRoom(self.model)
		if not Room then return end
		for _,model:Model in StoreFun.Added.DecorChild do
			if model:HasTag("Lamp") then
				local RoomModel:Model = StoreFun.Added:SearchRoom(model)
				if RoomModel and RoomModel.Name == Room.Name then
					table.insert(list, {
						model = model,
						lightColor = model:FindFirstChild("LightColor"),
						lightBulb = model:FindFirstChild("Lightbulb"),
						color = typeof(color)=="Color3" and color or nil,
					})
				end
			end
		end
	end
	return #list>0 and list
end

function Lamp:setColor(color)
	--[[local listParts = self:GetDecors(color)
	if listParts then
		remotes.Interactable.Lamp:FireServer("changeColor",listParts,self.model)
	end]]
	remotes.Interactable.Lamp:FireServer(color,self.model)
end

function Lamp:ChangeState()
	local IsOn = self.model:GetAttribute("IsOn")
	self.wheel.page:removeAction(IsOn and "Encender" or "Apagar")
	self.wheel.page:addAction(IsOn and "Apagar" or "Encender", IsOn and self.lightOff or self.lightOn, self)
	self.wheel:setQuickAction(IsOn and "Apagar" or "Encender", IsOn and self.lightOff or self.lightOn, self)
end

function Lamp:lightOn()
	SoundManager:Play(nil, 139464282770830, { Volume = 1 }, self.model)
	--[[local listParts = self:GetDecors()
	if listParts then
		remotes.Interactable.Lamp:FireServer("lightOn",listParts,self.model)
	end]]
	remotes.Interactable.Lamp:FireServer(true,self.model)
end

function Lamp:lightOff()
	SoundManager:Play(nil, 139464282770830, { Volume = 1 }, self.model)
	remotes.Interactable.Lamp:FireServer(false,self.model)
	--[[local listParts = self:GetDecors()
	if listParts then
		remotes.Interactable.Lamp:FireServer("lightOff", listParts, self.model)
	end]]
end

return Lamp
