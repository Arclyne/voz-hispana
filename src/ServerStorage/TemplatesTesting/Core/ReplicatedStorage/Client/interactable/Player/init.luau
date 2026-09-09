local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")

local remotes = ReplicatedStorage.Events
local openGiftShopEvent = remotes:WaitForChild("IconsUI"):WaitForChild("OpenGiftShop")

local SignalGame = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SignalsGame"))

if not player.Character or not player.Character.Parent then
	player.CharacterAdded:Wait()
end

local Player = {}
Player.__index = Player
setmetatable(Player, Interactable)

local CurrentTool = "none"

function Player.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, Player)
	
	self.Player = Players:GetPlayerFromCharacter(model.Parent)
	self.model = model
	self.adornee = model
	self.wheel = self:getDefaultWheel()
	
	self.wheel.page:addAction("Donar", self.DonarCoins, self)
	self.wheel.page:addAction("Ajustar Volumen", self.AjustarVolumen, self)

	if self.Player and self.Player ~= player then
		self.wheel.page:addAction("Regalar", self.RegalarGamepass, self)
	end
	--self.wheel.page:addAction("Ajustar Volumen", self.AjustarVolumen, self)

	self:setAdornee(self.adornee)
	self:setClickHitbox(model.Parent)

	local Character = player.Character or player.CharacterAdded:Wait()
	
	Character.ChildAdded:Connect(function(child)
		if child:IsA("Tool")  then
			for _, moduleChild in script:GetChildren() do
				if moduleChild:IsA("ModuleScript") and moduleChild.Name == child.Name then
					local module = require(moduleChild)
					CurrentTool = child.Name
					module.new(self, child) 
					break
				end
			end
		end
	end)
	
	return self
end

function Player:RemoveToCatalog(actionName)
	if self.wheel and self.wheel.page then
		self.wheel.page:removeAction(actionName)
		CurrentTool = "none"
	end
end

function Player:DonarCoins() SignalGame:Fire("PlayerDonation", self.Player) end
function Player:AjustarVolumen() SignalGame:Fire("PlayerVolume", self.Player.DisplayName) end

function Player:RegalarGamepass()
	if not (self.Player and self.Player.Parent) then
		return
	end

	openGiftShopEvent:Fire(self.Player)
end

return Player