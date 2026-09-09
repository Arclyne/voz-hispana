local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Controller = require(script.Controller)
local machineUtil = require(script.Parent.machineUtil)
local Trove = require(ReplicatedStorage.Shared.Trove)
local MachinePrompt = require(script.Parent.MachinePrompt)

local remotes = ReplicatedStorage.Events

local function bind<T>(model: Model, remote: RemoteEvent, callback: (...T) -> ())
	remote.OnClientEvent:Connect(function(modelCheck, ...)
		if model == modelCheck then
			callback(...)
		end
	end)
end

local PopTheLock = {}
PopTheLock.__index = PopTheLock

function PopTheLock.new(model: Model)
	local self = setmetatable({
		model = model,
		prompt = MachinePrompt.new(model),
		_trove = Trove.new(),
	}, PopTheLock)

	bind(model, remotes.Machines.PopTheLockFlip, function(angle)
		if self._controller then
			self._controller:flip()
			self._controller:placeDot(angle)
		end
	end)

	bind(model, remotes.Machines.PopTheLockClaim, function()
		if self._controller then
			self._controller:claimTicket()
		end
	end)

	bind(model, remotes.Machines.PopTheLockFinish, function()
		if self._controller then
			self._controller:stop()
			self._controller:setFinishText()
		end
	end)

	return self
end

function PopTheLock:start()
	self._trove:Add(machineUtil.setCamera(self.model.Camera))
	self._trove:Add(machineUtil.freezeCharacter(self.model.Player))

	local controller = Controller.new(self.model)
	local isFlippedDot = false
	local isFinished = false

	local function getNextDotAngle()
		local offset = if isFlippedDot then -math.random(55, 65) else math.random(55, 90)
		return (controller.angle + offset) % 360
	end

	local function onFinish()
		isFinished = true
		controller:stop()
		controller:setFinishText()
		remotes.Machines.PopTheLockFinish:FireServer(self.model, controller.tickets)
	end

	local function onClick()
		if isFinished then
			return
		end

		if controller:isOverlapping() then
			isFlippedDot = not isFlippedDot

			controller:claimTicket()
			remotes.Machines.PopTheLockClaim:FireServer(self.model)

			if controller.remainingDots <= 0 then
				onFinish()
				return
			end

			controller:flip()
			controller:placeDot(getNextDotAngle())
			remotes.Machines.PopTheLockFlip:FireServer(self.model, controller.dotAngle)
		else
			onFinish()
		end
	end

	controller:start()
	controller:onDotMissed(onFinish)

	self._trove:Add(controller, "reset")
	self._trove:Add(UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			onClick()
		end
	end))
end

function PopTheLock:replicate()
	self._controller = Controller.new(self.model)
	self._controller:start()
	
	self._trove:Add(function()
		self._controller:reset()
		self._controller = nil
	end)
end

function PopTheLock:idle() end

function PopTheLock:stop()
	self._trove:Clean()
end

return PopTheLock
