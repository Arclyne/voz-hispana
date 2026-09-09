local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Interactable = require(script.Parent.Interactable)
local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))
local Controls = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

local remotes = ReplicatedStorage.Events

local Washbasin = {}
Washbasin.__index = Washbasin

setmetatable(Washbasin, Interactable)

function Washbasin.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, Washbasin)

	self.model = model
	self.wheel = self:getDefaultWheel()
	self.wheel:setQuickAction("Lavar manos", self.washHands, self)
	self.wheel.page:addAction("Lavar manos", self.washHands, self)
	self.wheel.page:addAction("Lavar dientes", self.washTeeth, self)
	
	self:setAdornee(model.Prompt)
	self:setClickHitbox(model)

	local occupant = model:WaitForChild("Occupant")
	if occupant.Value then
		self:disable()
	end
	
	occupant.Changed:Connect(function()
		if occupant.Value == Players.LocalPlayer then
			Controls:Disable()
		else
			Controls:Enable()
		end

		if occupant.Value then
			self:disable()
		else
			self:enable()
		end
	end)

	return self
end

function Washbasin:washHands()
	remotes.Interactable.WashHands:FireServer(self.model)
end

function Washbasin:washTeeth()
	remotes.Interactable.WashTeeth:FireServer(self.model)
end

return Washbasin
