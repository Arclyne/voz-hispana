local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MachinePrompt = require(script.Parent.MachinePrompt)
local Trove = require(ReplicatedStorage.Shared.Trove)
local machineUtil = require(script.Parent.machineUtil)
local createPongSession = require(ReplicatedStorage.Shared.pong.createPongSession)
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Input = require(ReplicatedStorage.Shared.pong.Input)

local IDLE_DELAY = 0.15
local IDLE_MAX_LIGHTS = 3

local remotes = ReplicatedStorage.Events
local shootButton: GuiButton?

local function bind<T>(model: Model, remote: RemoteEvent, callback: (...T) -> ())
	remote.OnClientEvent:Connect(function(modelCheck, ...)
		if model == modelCheck then
			callback(...)
		end
	end)
end

local Pong = {}
Pong.__index = Pong

function Pong.new(model: Model)
	local self = setmetatable({
		model = model,
		prompt = MachinePrompt.new(model),
		_trove = Trove.new(),
		_pendingSpawn = nil,
	}, Pong)
	
	bind(self.model, remotes.Machines.PongPaddleUpdate, function(data)
		local session = self._session
		if session then
			local paddle = session.player1 == data.player and session.paddle1 or session.paddle2
			paddle._latestServerState = data.state
		end
	end)
	
	bind(self.model, remotes.Machines.PongSpawn, function(data)
		local session = self._session
		if not session then
			self._pendingSpawn = data
			return
		end

		if data.player == Players.LocalPlayer and shootButton then
			shootButton.Visible = true
		end
		session.ball:spawn(data.player)
	end)
	
	bind(self.model, remotes.Machines.PongShot, function()
		local session = self._session
		if session then
			session.ball:shoot()
		end
	end)
	
	bind(self.model, remotes.Machines.PongBallUpdate, function(state)
		local session = self._session
		if session then
			session.ball._latestServerState = state
		end
	end)

	return self
end

function Pong:start(player1, player2)
	self._trove:Add(machineUtil.setCamera(self.model.Camera))
	self._trove:Add(machineUtil.freezeCharacter())

	self._session = createPongSession(player1, player2, self.model)
	if self._pendingSpawn then
		local data = self._pendingSpawn
		self._pendingSpawn = nil

		if data.player == Players.LocalPlayer and shootButton then
			shootButton.Visible = true
		end
		self._session.ball:spawn(data.player)
	end
	self._trove:Add(self._session.paddle1, "destroy")
	self._trove:Add(self._session.paddle2, "destroy")
	self._trove:Add(self._session.ball, "destroy")
	self._trove:Add(function()
		self._session = nil
	end)

	self._trove:Add(UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		local session = self._session
		if not session then
			return
		end

		if input.KeyCode == Enum.KeyCode.Space and session.ball._owner == Players.LocalPlayer then
			session.ball:shoot()
			remotes.Machines.PongShot:FireServer(self.model)
		end
	end))

	if UserInputService.TouchEnabled then
		local ui = self.model.UI:Clone()
		ui.Parent = Players.LocalPlayer.PlayerGui

		shootButton = ui.Shoot :: GuiButton
		assert(shootButton)

		shootButton.Visible = false
		self._trove:Add(shootButton.Activated:Connect(function()
			local session = self._session
			if session and session.ball._owner == Players.LocalPlayer then
				session.ball:shoot()
				remotes.Machines.PongShot:FireServer(self.model)
				shootButton.Visible = false
			end
		end))

		local upButton = ui.Up :: GuiButton
		self._trove:Add(upButton.MouseButton1Down:Connect(function()
			Input.upPressed = true
		end))
		self._trove:Add(upButton.MouseButton1Up:Connect(function()
			Input.upPressed = false
		end))

		local downButton = ui.Down :: GuiButton
		self._trove:Add(downButton.MouseButton1Down:Connect(function()
			Input.downPressed = true
		end))
		self._trove:Add(downButton.MouseButton1Up:Connect(function()
			Input.downPressed = false
		end))

		self._trove:Add(ui)
		self._trove:Add(function()
			shootButton = nil
			Input.downPressed = false
			Input.upPressed = false
		end)
	end
end

function Pong:replicate() end

function Pong:idle()
	local lights = self.model.Lights:GetChildren()

	local function setColors(index: number)
		for _, light in lights do
			if light:IsA("BasePart") then
				light.Color = light.Name == tostring(index) and Color3.fromRGB(142, 141, 144)
					or Color3.fromRGB(109, 109, 109)
			end
		end
	end

	self._trove:Add(task.spawn(function()
		while true do
			for i = 1, IDLE_MAX_LIGHTS do
				setColors(i)
				task.wait(IDLE_DELAY)
			end
		end
	end))

	self._trove:Add(function()
		setColors(1)
	end)
end

function Pong:stop()
	self._trove:Clean()
end

return Pong
