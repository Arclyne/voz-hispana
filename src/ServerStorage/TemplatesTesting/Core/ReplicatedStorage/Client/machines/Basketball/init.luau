local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Trove = require(ReplicatedStorage.Shared.Trove)
local Prediction = require(script.Prediction)
local basketUtil = require(ReplicatedStorage.Shared.basketUtil)
local machineUtil = require(script.Parent.machineUtil)
local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))
local MachinePrompt = require(script.Parent.MachinePrompt)

local BOUNDS_AXIS_X = 2.5

local function bind<T>(model: Model, remote: RemoteEvent, callback: (...T) -> ())
	remote.OnClientEvent:Connect(function(modelCheck, ...)
		if model == modelCheck then
			callback(...)
		end
	end)
end

local Basketball = {}
Basketball.__index = Basketball

local remotes = ReplicatedStorage.Events
local player = Players.LocalPlayer
local gravity = Vector3.yAxis * -Workspace.Gravity

local function projectVector(target: Vector3, origin: Vector3, duration: number)
	return (target - origin - gravity / 2 * duration * duration) / duration
end

function Basketball.new(model: Model)
	local self = setmetatable({
		model = model,
		prompt = MachinePrompt.new(model),
		_trove = Trove.new(),
	}, Basketball)

	bind(model, remotes.Machines.BasketThrowBall, function(origin, velocity)
		if self._character then
			basketUtil.throwBall(self._character, origin, velocity)
		end
	end)

	bind(model, remotes.Machines.BasketReturnBall, function()
		if self._character then
			basketUtil.returnBall(self._character)
		end
	end)

	return self
end

function Basketball:start(character)
	self._trove:Add(machineUtil.setCamera(self.model.Camera, { "Basket-Ball" }))
	self._trove:Add(machineUtil.freezeCharacter(self.model.Player))
	self._trove:Add(task.spawn(function()
		local oldCameraCFrame = self.model.Camera.CFrame
		local rightHand = character.RightHand
		local target = self.model.Target
		local trigger = self.model.Trigger
		local triggerCFrame = trigger.CFrame

		self._trove:Add(rightHand.ChildAdded:Connect(function(child)
			if child.Name:find("Server") then
				child:Destroy()
			end
		end))

		local score = 0
		local ball = basketUtil.createBall(character, function()
			score += 1
			basketUtil.setScoreText(self.model, score)
			remotes.Machines.BasketScore:FireServer(self.model)
		end)

		self._trove:Add(ball)

		local origin = ball.Position
		local duration = math.log(1.001 + (origin - target.Position).Magnitude * 0.048)
		local random = Random.new()

		local positionX = 0
		local forceToApply = Vector3.zero
		local isThrowing = false

		local function project()
			target.Position = (triggerCFrame * CFrame.new(positionX, 0, 0)).Position
			forceToApply = projectVector(target.Position, origin, duration)
			Prediction.update(gravity, forceToApply, origin, duration)
		end

		local function prepare()
			self.model.Camera.CFrame = oldCameraCFrame
			positionX = random:NextNumber(-BOUNDS_AXIS_X * 0.9, BOUNDS_AXIS_X * 0.9)
			Prediction.enable()
			project()
			SoundManager:Play(nil, 13576215173, { Volume = 1.5 }, self.model.PrimaryPart)
		end

		local function throw()
			if isThrowing then
				return
			end

			isThrowing = true
			remotes.Machines.BasketThrowBall:FireServer(origin, forceToApply)
			basketUtil.throwBall(character, origin, forceToApply)
			Prediction.disable()

			self._trove:Add(task.delay(3, function()
				isThrowing = false
				remotes.Machines.BasketReturnBall:FireServer()
				basketUtil.returnBall(character)
				prepare()
			end))
		end

		prepare()

		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false

		local ui = self.model.Basketball:Clone()
		ui.timer.Text = string.format("%.2i", self.model:GetAttribute("Timer"))
		ui.Parent = player.PlayerGui

		self._trove:Add(ui)
		self._trove:Add(ui.exit.Activated:Connect(function()
			remotes.Machines.BasketFinish:FireServer(self.model)
		end))
		self._trove:Add(self.model:GetAttributeChangedSignal("Timer"):Connect(function()
			ui.timer.Text = string.format("%.2i", self.model:GetAttribute("Timer"))
		end))

		if UserInputService.TouchEnabled then
			self._trove:Add(ui.shoot.Activated:Connect(throw))
			self._trove:Add(RunService.Heartbeat:Connect(function()
				ui.shoot.Visible = not isThrowing
			end))
		else
			ui.exit.Text ..= " [P]"
			ui.shoot.Visible = false
		end

		self._trove:Add(UserInputService.InputBegan:Connect(function(input, processed)
			if input.KeyCode == Enum.KeyCode.P and not processed then
				remotes.Machines.BasketFinish:FireServer(self.model)
			end
		end))

		self._trove:Add(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				throw()
			end
		end))

		self._trove:Add(function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end)

		self._trove:Add(UserInputService.InputChanged:Connect(function(input: InputObject)
			if not isThrowing then
				positionX -= input.Delta.X * 0.01
				positionX = math.clamp(positionX, -BOUNDS_AXIS_X, BOUNDS_AXIS_X)
				project()
			end
		end))

		self:_moveRing()
		self:_listenScore()
		self._trove:Add(Prediction.disable)
	end))
end

function Basketball:replicate(character)
	self._character = character

	self:_moveRing()
	self:_listenScore()
	self._trove:Add(basketUtil.createBall(character))
	self._trove:Add(function()
		self._character = nil
	end)
end

function Basketball:idle() end

function Basketball:stop()
	self._trove:Clean()
end

function Basketball:_moveRing()
	local ring = self.model.Ring
	local ringCFrame = ring.CFrame
	local attachmentLeft = self.model.Bar.Left
	local attachmentRight = self.model.Bar.Right
	local cframeLeft = attachmentLeft.WorldCFrame
	local cframeRight = attachmentRight.WorldCFrame
	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear)

	local function tweenRingToCFrame(cframe: CFrame)
		local tween = self._trove:Add(
			TweenService:Create(ring, tweenInfo, {
				CFrame = cframe,
			}),
			"Cancel"
		)
		tween:Play()
		tween.Completed:Wait()
	end

	self._trove:Add(task.spawn(function()
		ring.CFrame = cframeLeft
		while true do
			tweenRingToCFrame(cframeRight)
			tweenRingToCFrame(cframeLeft)
		end
	end))

	self._trove:Add(function()
		ring.CFrame = ringCFrame
	end)
end

function Basketball:_listenScore()
	self._trove:Add(self.model:GetAttributeChangedSignal("Score"):Connect(function()
		local score = self.model:GetAttribute("Score") :: number
		self:setScoreText(score)

		if score > 0 then
			SoundManager:Play(nil, 13576251401, { Volume = 1.5 }, self.model.PrimaryPart)
		end
	end))
end

return Basketball
