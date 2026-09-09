local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)

local player = Players.LocalPlayer

local module = {}
module.__index = module
setmetatable(module, Interactable)

function module.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, module)

	self.track = nil
	self.model = model
	self.wheel = self:getDefaultWheel()

	self:setAdornee(model:FindFirstChild("Table"):FindFirstChild("Prompt"))
	self:setClickHitbox(model:FindFirstChild("Table"):FindFirstChild("DJ"))
	
	self:init()
	
	return self
end

function module:init()
	local moduleNightclub = ReplicatedStorage:WaitForChild("Shared"):FindFirstChild("NightClub")
	if moduleNightclub then
		self.Main = require(moduleNightclub).new(self.model)
		self.Main:GetAttributeChangedSignal("Host"):Connect(function() self:Change() end)
		self.wheel.page:addAction("Open", self.Open, self)
		self:Change()
	end
end

function module:Change()
	if self.Main and self.Main:IsDj() then
		self:enable()
		
		local IsHost = self.Main:GetAttribute("Host")
		
		self.wheel:setQuickAction(not IsHost and "Claim" or IsHost==LocalPlayer and "Unclaim" or "Open",(not IsHost or IsHost==LocalPlayer) and self.Claim or self.Open, self)
		
		self.wheel.page:removeAction('Claim')
		self.wheel.page:removeAction('Unclaim')
		
		if IsHost then
			if IsHost==LocalPlayer then
				self.wheel.page:addAction("Unclaim", self.Claim, self)
			end
		else
			self.wheel.page:addAction("Claim", self.Claim, self)
		end
		
	else
		self:disable()
	end
end

function module:Claim()
	if self.Main then self.Main:ClaimHost() end
end

function module:Open()
	if not self.EventOpen then
		self.EventOpen = ReplicatedStorage
			:WaitForChild("Events")
			:WaitForChild("IconsUI")
			:WaitForChild("OpenNightClub")
	end
	self.EventOpen:Fire()
end

return module
