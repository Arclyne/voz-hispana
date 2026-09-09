local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Controls = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
local showExitButton = require(ReplicatedStorage.Shared.showExitButton)
local Trove = require(ReplicatedStorage.Shared.Trove)

local TURN_OFF_COLOR = Color3.fromRGB(17, 17, 17)
local TURN_ON_COLOR = Color3.fromRGB(202, 203, 209)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage.Events
local cleanup

local Treadmill = {}
Treadmill.__index = Treadmill

setmetatable(Treadmill, Interactable)

function Treadmill.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, Treadmill)

	self.model = model
	self.wheel = self:getDefaultWheel()
	self.wheel:setQuickAction("Correr", self.request, self)
	self.wheel.page:addAction("Correr", self.request, self)
	self.trove = Trove.new()

	self:setAdornee(model.Prompt)
	self:setClickHitbox(model)
	
	local screen = model:WaitForChild("Screen")
	local occupant = model:WaitForChild("Occupant")

	if occupant.Value then
		screen.Color = TURN_ON_COLOR
		self:disable()
	end

	occupant.Changed:Connect(function()
		TweenService:Create(screen, TweenInfo.new(0.5), {
			Color = occupant.Value and TURN_ON_COLOR or TURN_OFF_COLOR
		}):Play()

		if occupant.Value then
			self:disable()
		else
			self:enable()
		end
		
		if occupant.Value == player then
			self.player = player

			local animator = player.Character.Humanoid.Animator
			local track = animator:LoadAnimation(script.RunAnimation)
			track.Looped = true
			track:Play()
			
			player.Character:PivotTo(model.Player:GetPivot())
			Controls:Disable()

			self.trove:Add(function()
				track:Stop()
				Controls:Enable()
			end)

			self.trove:Add(showExitButton(function()
				remotes.Interactable.Treadmill:FireServer()
			end))
		elseif self.player == player then
			self.trove:Clean()
			self.player = nil
		end
	end)

	return self
end

function Treadmill:request()
	remotes.Interactable.Treadmill:FireServer(self.model)
end

return Treadmill
