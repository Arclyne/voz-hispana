local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)
local Controls = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

local currentlyCleaning: Model?
local remotes = ReplicatedStorage.Events

local Pee = {}
Pee.__index = Pee
setmetatable(Pee, Interactable)

function Pee.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, Pee)

	self.model = model
	self.wheel = self:getDefaultWheel()
	
	local Tttle = model:GetAttribute("Tittle") or "Limpiar"
	self.wheel:setQuickAction(Tttle, self.clean, self)
	self.wheel.page:addAction(Tttle, self.clean, self)

	self:setAdornee(model:FindFirstChild("Prompt") or model)
	self:setClickHitbox(model)
	
	local function disabled()
		local whiteList = model:GetAttribute("WhiteList")
			and not table.find(string.split(model:GetAttribute("WhiteList"),","), tostring(LocalPlayer.UserId))
		
		if model:GetAttribute("Cleaning") or whiteList then
			self:disable()
			self:RemoveHighlight()
		else
			if model:GetAttribute("WhiteList") then
				self:AddHighlight()
			else
				self:RemoveHighlight()
			end
			self:enable()
		end

	end
	
	local lastCleaning = model:GetAttribute("PlayerCleaning")
	local function controller()
		local Cleaning = model:GetAttribute("PlayerCleaning")
		local UserId = Players.LocalPlayer.UserId
		if Cleaning==UserId then
			if model:IsDescendantOf(game) then
				Controls:Disable()
			else
				Controls:Enable()
			end
		elseif lastCleaning==UserId then
			Controls:Enable()
		end
		lastCleaning = Cleaning
	end
	
	model:GetPropertyChangedSignal("Parent"):Connect(controller)
	model.AttributeChanged:Connect(function(attribute)
		if table.find({"Cleaning", "WhiteList"}, attribute) then
			disabled()
		elseif attribute == "PlayerCleaning" then
			controller()
		end
	end)
	
	disabled()
	
	return self
end

function Pee:clean() remotes.Interactable.Pee:FireServer(self.model) end

return Pee
