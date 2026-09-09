local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Board = require(script.Board)
local Controller = require(script.Controller)
local Trove = require(ReplicatedStorage.Shared.Trove)
local machineUtil = require(script.Parent.machineUtil)
local idle = require(script.idle)
local MachinePrompt = require(script.Parent.MachinePrompt)

local remotes = ReplicatedStorage.Events

local function bind<T>(model: Model, remote: RemoteEvent, callback: (...T) -> ())
	remote.OnClientEvent:Connect(function(modelCheck, ...)
		if model == modelCheck then
			callback(...)
		end
	end)
end

local Stacker = {}
Stacker.__index = Stacker

function Stacker.new(model: Model)
	local self = setmetatable({
		model = model,
		prompt = MachinePrompt.new(model),
		_trove = Trove.new(),
	}, Stacker)

	bind(model, remotes.Machines.StackerPosition, function(pos)
		if self._controller then
			self._controller.figure.x = pos
			self._controller:stack()
		end
	end)

	return self
end

function Stacker:start()
	self._trove:Add(machineUtil.setCamera(self.model.Camera))
	self._trove:Add(machineUtil.freezeCharacter(self.model.Player))

	local board = Board.new(self.model.Screen)
	local controller = Controller.new(board)
	controller:start()

	controller:onWin(function()
		task.wait(1)
		remotes.Machines.StackerFinish:FireServer(self.model, true)
	end)

	controller:onLose(function()
		task.wait(1)
		remotes.Machines.StackerFinish:FireServer(self.model, false)
	end)

	local function onClick()
		remotes.Machines.StackerPosition:FireServer(self.model, controller.figure.x)
		controller:stack()
	end

	self._trove:Add(controller)
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

function Stacker:replicate()
	local board = Board.new(self.model.Screen)
	self._controller = Controller.new(board)
	self._controller:start()
	
	self._trove:Add(function()
		self._controller:destroy()
		self._controller = nil
	end)
end

function Stacker:idle()
	idle(self.model, self._trove)
end

function Stacker:stop()
	self._trove:Clean()
end

return Stacker
