local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MachinePrompt = require(script.Parent.MachinePrompt)
local Spring = require(ReplicatedStorage.Shared.Spring)
local lerp = require(ReplicatedStorage.Shared.lerp)
local Trove = require(ReplicatedStorage.Shared.Trove)

local GREEN_ZONE_SIZE = 0.1
local GREEN_ZONE_COLOR = Color3.fromRGB(85, 255, 127)
local RED_ZONE_COLOR = Color3.fromRGB(255, 87, 87)
local LINE_SPEED = 2

local remotes = ReplicatedStorage.Events
local random = Random.new(os.clock() % 3724)

local ToyMachine = {}
ToyMachine.__index = ToyMachine

function ToyMachine.new(model: Model)
	local self = setmetatable({
		model = model,
		prompt = MachinePrompt.new(model),
		_trove = Trove.new(),
	}, ToyMachine)
	
	self._spring = Spring.new(
		Vector2.new(0.2, 0),
		Vector2.zero,
		{ mass = 1, K = 0.125, damping = 0.3 }
	)
	
	self._screen = script.ScreenGui:Clone()
	self._pressed = false

	return self
end

function ToyMachine:replicate() end

function ToyMachine:idle() end

function ToyMachine:stop()
	self._trove:Clean()
end

function ToyMachine:_randomPosition()
	local startPoint = random:NextNumber(.15, .85 - GREEN_ZONE_SIZE)

	self._screen.Frame.Bar.UIGradient.Color = ColorSequence.new
	{
		ColorSequenceKeypoint.new(0, RED_ZONE_COLOR),
		ColorSequenceKeypoint.new(startPoint - .05, RED_ZONE_COLOR),
		ColorSequenceKeypoint.new(startPoint, GREEN_ZONE_COLOR),
		ColorSequenceKeypoint.new(startPoint + GREEN_ZONE_SIZE, GREEN_ZONE_COLOR),
		ColorSequenceKeypoint.new(startPoint + GREEN_ZONE_SIZE + .05, RED_ZONE_COLOR),
		ColorSequenceKeypoint.new(1, RED_ZONE_COLOR),
	}

	return startPoint
end

function ToyMachine:_moveLine()
	self._trove:Add(task.spawn(function()
		local line = self._screen.Frame.Bar.Line

		local function goTo0or1(target)
			task.wait()

			local t: number = 0
			local origin = line.Position.Y.Scale

			while t <= 1 do
				if self.presssed then
					break
				end 

				line.Position = UDim2.fromScale(0.5, lerp(origin, target, t))
				t += task.wait() * LINE_SPEED
			end

			if not self.presssed then
				line.Position = UDim2.fromScale(0.5, target)
			end
		end

		while not self.presssed do
			goTo0or1(1)
			goTo0or1(0)
		end
	end))
end

function ToyMachine:_moveMachine()
	local tween
	self._trove:Add(function()
		if tween then
			tween:Cancel()
		end
	end)
	
	self._trove:Add(task.spawn(function()
		local points = self.model.PointsHook:GetChildren()

		self._trove:Add(self.model.Hook.HookPosition.Changed:Connect(function()
			self.model.Hook:PivotTo(CFrame.new(self.model.Hook.HookPosition.Value))
		end))

		while not self._pressed do
			local newPoint: Part = points[math.random(#points)]
			local duration = (self.model.Hook:GetPivot().Position - newPoint.Position).Magnitude * 3

			tween = TweenService:Create(self.model.Hook.HookPosition, TweenInfo.new(duration), {Value = newPoint.Position})
			tween:Play()
			tween.Completed:Wait()
			tween:Destroy()
		end		
	end))
end

function ToyMachine:start()
	self.model.Hook.HookPosition.Value = self.model.Hook:GetPivot().Position

	self._trove:Add(function()
		self._pressed = false
		self._spring.target = Vector2.new(0.2, 0)
		self._screen.Parent = nil
		self._screen.Frame.Bar.Line.Position = UDim2.fromScale(0.5, 0)
	end)

	self._trove:Add(RunService.Heartbeat:Connect(function()
		self._spring:update()

		local spring = self._spring.value
		self._screen.Frame.Position = UDim2.fromScale(spring.X, spring.Y)
	end))

	local startPoint = self:_randomPosition()
	self._screen.Parent = Players.LocalPlayer.PlayerGui
	
	self:_moveLine()
	self:_moveMachine()

	self._spring.target = Vector2.zero

	self._trove:Add(self._screen.Frame.Stop.MouseButton1Down:Connect(function()
		self._pressed = true
		local inGreenZone = false
		
		local lineYPosition = self._screen.Frame.Bar.Line.Position.Y.Scale
		if ((lineYPosition >= startPoint) and (lineYPosition <= (startPoint + GREEN_ZONE_SIZE))) then
			inGreenZone = true
		end

		remotes.Machines.ToyPress:FireServer(self.model, inGreenZone, self.model.Hook.HookPosition.Value)
		self:stop()
	end))
end

return ToyMachine
