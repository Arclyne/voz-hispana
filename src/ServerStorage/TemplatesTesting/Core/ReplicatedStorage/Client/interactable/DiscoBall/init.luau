local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Interactable = require(script.Parent.Interactable)
local Controls = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

local ROTATION_SPEED = math.rad(90)
local MIN_ROTATION_TIME = 2
local MAX_ROTATION_TIME = 6

local remotes = ReplicatedStorage.Events
local assets = ReplicatedStorage.Assets

local beamTemplate = assets.Interactable.DiscoBeam

local DiscoBall = {}
DiscoBall.__index = DiscoBall
setmetatable(DiscoBall, Interactable)

function DiscoBall.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, DiscoBall)

	self.model = model
	self.root = model.PrimaryPart
	self.wheel = self:getDefaultWheel()
	self.wheel:setQuickAction("Encender", self.activate, self)
	self.wheel.page:addAction("Encender", self.activate, self)

	local lights = model:FindFirstChild("Lights")
	self.lights = lights:GetChildren()

	self:setAdornee(model:FindFirstChild("Light"))
	self:setClickHitbox(model)

	self:init()

	self.model:GetAttributeChangedSignal("Active"):Connect(function()
		if self.model:GetAttribute("Active") then
			self:turnOn()
		else
			self:turnOff()
		end
	end)

	if self.model:GetAttribute("Active") then
		self:turnOn()
	else
		self:turnOff()
	end

	return self
end

function DiscoBall:init()
	self.lightData = {}

	for _, light in self.lights do
		local a0 = light:FindFirstChild("Attachment0")
		if not a0 then
			a0 = Instance.new("Attachment")
			a0.Name = "Attachment0"
			a0.Parent = light
		end

		local a1 = light:FindFirstChild("Attachment1")
		if not a1 then
			a1 = Instance.new("Attachment")
			a1.Name = "Attachment1"
			a1.Parent = light
		end

		local beam = light:FindFirstChildOfClass("Beam")
		if not beam then
			beam = beamTemplate:Clone()
			beam.Parent = light
		end

		beam.Attachment0 = a0
		beam.Attachment1 = a1

		self.lightData[light] = {
			a0 = a0,
			a1 = a1,
			beam = beam,
		}
	end

	local oldActor = self.model:FindFirstChild("LaserActor")
	if oldActor then
		oldActor:Destroy()
	end

	local actor = Instance.new("Actor")
	actor.Name = "LaserActor"
	actor.Parent = self.model

	local laser = script.Laser:Clone()
	laser.Parent = actor
	laser.Enabled = true
end

function DiscoBall:activate()
	remotes.Interactable.DiscoBall:FireServer(self.model)
end

function DiscoBall:turnOn()
	self.wheel:setQuickAction("Apagar", self.activate, self)
	self.wheel.page:addAction("Apagar", self.activate, self)
	self.wheel.page:removeAction("Encender")

	if self._conn then
		self._conn:Disconnect()
	end

	local random = Random.new()
	local timer = random:NextNumber(MIN_ROTATION_TIME, MAX_ROTATION_TIME)
	local direction = 1

	self._conn = RunService.Heartbeat:Connect(function(dt)
		self.root.CFrame *= CFrame.Angles(0, ROTATION_SPEED * dt * direction, 0)

		timer -= dt
		if timer <= 0 then
			direction *= -1
			timer = random:NextNumber(MIN_ROTATION_TIME, MAX_ROTATION_TIME)
		end
	end)

	for light, data in self.lightData do
		light.Material = Enum.Material.Neon
		data.beam.Enabled = true
	end

	self.model.Light.PointLight.Enabled = true
end

function DiscoBall:turnOff()
	self.wheel:setQuickAction("Encender", self.activate, self)
	self.wheel.page:addAction("Encender", self.activate, self)
	self.wheel.page:removeAction("Apagar")

	if self._conn then
		self._conn:Disconnect()
		self._conn = nil
	end

	for light, data in self.lightData do
		light.Material = Enum.Material.Plastic
		data.beam.Enabled = false
	end

	self.model.Light.PointLight.Enabled = false
end

return DiscoBall