local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Interactable = require(script.Parent.Interactable)
local Controls = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
local showExitButton = require(ReplicatedStorage.Shared.showExitButton)
local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))

local SOUND_SHOWER_ID = "78706108410058"

local remotes = ReplicatedStorage.Events
local cleanup: (() -> ())?

local Shower = {}
Shower.__index = Shower
setmetatable(Shower, Interactable)

function Shower.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, Shower)

	self.model = model
	self.wheel = self:getDefaultWheel()
	self.wheel:setQuickAction("Ducharse", self.shower, self)
	self.wheel.page:addAction("Ducharse", self.shower, self)

	self:setAdornee(model:WaitForChild("Prompt"))
	self:setClickHitbox(model)

	local occupant = model:WaitForChild("Occupant") :: ObjectValue
	occupant.Changed:Connect(function()
		if occupant.Value == Players.LocalPlayer then
			Controls:Disable()
			cleanup = showExitButton(function()
				remotes.Interactable.Shower:FireServer()
			end)
		elseif cleanup then
			Controls:Enable()
			cleanup()
			cleanup = nil
		end

		if occupant.Value then
			self:on()
			self:disable()
		else
			self:off()
			self:enable()
		end
	end)
	
	if occupant.Value then
		self:on()
		self:disable()
	end
	
	return self
end

function Shower:shower()
	remotes.Interactable.Shower:FireServer(self.model)
end

function Shower:on()
	for _, particle in self.model:GetDescendants() do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = true
		end
	end
	
	SoundManager:Play(nil, SOUND_SHOWER_ID, { 
		Volume = 1, 
		Looped = true,
		Name = "Shower"
	}, self.model)
end

function Shower:off()
	for _, particle in self.model:GetDescendants() do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = false
		end
	end

	local sound = self.model:FindFirstChild("Shower")
	if sound and sound:IsA("Sound") then
		-- fade out
		local tween = TweenService:Create(
			sound,
			TweenInfo.new(0.6, Enum.EasingStyle.Linear),
			{ Volume = 0 }
		)
		tween:Play()
		tween.Completed:Once(function()
			if sound.Parent then
				sound:Stop()
				sound:Destroy()
			end
		end)
	end
end

return Shower
