local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Machine = require(script.Parent.Machine)
local createPongSession = require(ReplicatedStorage.Shared.pong.createPongSession)
local NetworkTimer = require(ReplicatedStorage.Shared.NetworkTimer)
local Trove = require(ReplicatedStorage.Shared.Trove)

local POINTS_TO_WIN = 10

local remotes = ReplicatedStorage.Events

local Pong = {}
Pong.__index = Pong

function Pong.new(model: Model)
	local self = setmetatable({
		model = model,
		_machine = Machine.new(model, 2),
		_session = nil,
		_trove = Trove.new(),
		_scores = { 0, 0 },
	}, Pong)

	self._machine:bind(remotes.Machines.PongTick, function(player, tick: number)
		local session = self._session
		if session then
			local ball = session.ball
			ball._ticksMap[player] = tick
			ball._lastTickByPlayer[player] = tick
		end
	end)

	self._machine:bind(remotes.Machines.PongInput, function(player, input)
		local session = self._session
		if not session then
			return
		end

		if type(input) ~= "table" then
			return
		end

		local tick = input.tick
		local direction = input.direction
		if type(tick) ~= "number" or type(direction) ~= "number" then
			return
		end

		local paddle = session.player1 == player and session.paddle1 or session.paddle2
		-- Server authoritative movement happens on Paddle's server tick.
		paddle:pushInput({
			tick = tick,
			direction = math.clamp(direction, -1, 1),
		})
	end)

	self._machine:bind(remotes.Machines.PongShot, function(player)
		local session = self._session
		if session and session.ball._owner == player then
			session.ball:shoot()

			if session.paddle1._player == player then
				remotes.Machines.PongShot:FireClient(session.paddle2._player, self.model)
			else
				remotes.Machines.PongShot:FireClient(session.paddle1._player, self.model)
			end
		end
	end)

	return self
end

function Pong:join(player: Player)
	if not self._machine:join(player) then
		return false
	end

	self:_sit(player)

	-- If a player stands up before the match starts, we must
	-- release the machine slot so they can re-join later.
	local players = self._machine:getPlayers()
	local seat = if #players == 1
		then self.model:FindFirstChild("Player1", true)
		else self.model:FindFirstChild("Player2", true)
	self:_watchSeatWhileWaiting(player, seat)

	return true
end

function Pong:start()
	local players = self._machine:getPlayers()
	local player1, player2 = unpack(players)

	if not self._machine:start(player1, player2) then
		return
	end

	self._scores[1], self._scores[2] = 0, 0
	self._session = createPongSession(player1, player2, self.model)

	local function stopIfActive()
		if self._session then
			self:stop()
		end
	end

	local seat1 = self.model:FindFirstChild("Player1", true)
	local seat2 = self.model:FindFirstChild("Player2", true)
	local seatCheckers = {}

	local function watchPlayer(player: Player)
		local character = player.Character
		if not character then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end

		self._trove:Add(humanoid.Died:Once(stopIfActive))
	end

	local function watchSeatForPlayer(player: Player, seat: Instance?)
		if not seat or not seat:IsA("Seat") then
			return
		end

		local seenCorrectOccupant = false

		local function check()
			if not self._session then
				return
			end

			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				return
			end

			local occupant = seat.Occupant
			if occupant == humanoid or humanoid.SeatPart == seat then
				seenCorrectOccupant = true
				return
			end

			if seenCorrectOccupant then
				stopIfActive()
			end
		end

		table.insert(seatCheckers, check)
		self._trove:Add(seat:GetPropertyChangedSignal("Occupant"):Connect(check))
		self._trove:Add(task.spawn(check))
	end

	watchPlayer(player1)
	watchPlayer(player2)
	watchSeatForPlayer(player1, seat1)
	watchSeatForPlayer(player2, seat2)

	self._trove:Add(Players.PlayerRemoving:Connect(function(leaving)
		if leaving == player1 or leaving == player2 then
			stopIfActive()
		end
	end))

	-- Single authoritative tick loop for this machine.
	local timer = NetworkTimer.new()
	self._trove:Add(timer:bind(function()
		local session = self._session
		if not session then
			return
		end

		-- Fallback: some seat setups don't reliably fire Occupant signals.
		for _, check in seatCheckers do
			check()
			if not self._session then
				return
			end
		end

		-- Order matters: paddles first, then ball.
		session.paddle1:_handleServerTick()
		session.paddle2:_handleServerTick()
		session.ball:_handleServerTick()
	end))

	-- Spawn immediately so spectators don't see the ball idle mid-field.
	self:_spawnBall(player1)

	self._session.ball:onScore(function(dir)
		if dir == "left" then
			self._scores[1] += 1
			self:_spawnBall(player2)
		elseif dir == "right" then
			self._scores[2] += 1
			self:_spawnBall(player1)
		end

		self:_updateScore()

		local winner = self:_getWinner()
		if winner then
			self:_updateWinner(winner)
			self:_handle(winner)
			self._trove:Add(task.delay(2, function()
				self:stop()
			end))
		end
	end)
end

function Pong:stop()
	local players = self._machine:getPlayers()
	local seat1 = self.model:FindFirstChild("Player1", true)
	local seat2 = self.model:FindFirstChild("Player2", true)

	for _, player in players do
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local seatPart = humanoid.SeatPart
			if seatPart == seat1 or seatPart == seat2 then
				humanoid.Sit = false
				pcall(function()
					humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				end)
				pcall(function()
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end)
			end
		end
	end

	if self._session then
		self._session:destroy()
		self._session = nil
	end

	self._trove:Clean()
	self._machine:stop()
	self:_updateScore()
	self:_updateWinner()

	table.clear(self._scores)
end

function Pong:onStop(callback: (Player) -> ())
	self._machine.stopped:Connect(callback)
end

function Pong:_handle(player: Player)
	warn(`[pong] player({player})`)
end

function Pong:_spawnBall(player: Player)
	if self:_getWinner() then
		return
	end

	self._session.ball:spawn(player)

	local players = self._machine:getPlayers()
	remotes.Machines.PongSpawn:FireClient(players[1], self.model, { player = player })
	remotes.Machines.PongSpawn:FireClient(players[2], self.model, { player = player })
end

function Pong:_updateScore()
	local scoreText = self.model.ScorePart.SurfaceGui.Score
	scoreText.Text = string.format("%i | %i", self._scores[1], self._scores[2])
end

function Pong:_updateWinner(player: Player?)
	local winnerText = self.model.Glass.SurfaceGui.Winner
	winnerText.Text = player and `{player.Name} ha ganado!` or ""
end

function Pong:_getWinner()
	local players = self._machine:getPlayers()
	if self._scores[1] >= POINTS_TO_WIN then
		return players[1]
	elseif self._scores[2] >= POINTS_TO_WIN then
		return players[2]
	end
end

function Pong:_watchSeatWhileWaiting(player: Player, seat: Instance?)
	if not seat or not seat:IsA("Seat") then
		return
	end

	local watchStartedAt = os.clock()

	local started = false
	local function markStarted()
		started = true
	end

	-- Stop checking once the match has started.
	if self.model:GetAttribute("Started") then
		markStarted()
	else
		self._trove:Add(self.model:GetAttributeChangedSignal("Started"):Connect(function()
			if self.model:GetAttribute("Started") then
				markStarted()
			end
		end))
	end

	local seenCorrectOccupant = false

	local function check()
		if started then
			return
		end

		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end

		local occupant = seat.Occupant
		if occupant == humanoid or humanoid.SeatPart == seat then
			seenCorrectOccupant = true
			return
		end

		-- If the player was seated and then isn't anymore, release the machine.
		if seenCorrectOccupant then
			self:stop()
			return
		end

		-- If seating never "sticks" (SeatPart never becomes our seat),
		-- don't keep the player locked in the machine.
		if os.clock() - watchStartedAt > 1 then
			self:stop()
		end
	end

	self._trove:Add(seat:GetPropertyChangedSignal("Occupant"):Connect(check))
	self._trove:Add(task.spawn(function()
		while not started and self._session == nil do
			check()
			task.wait(0.2)
		end
	end))

	-- If we never actually get seated (or immediately lose occupant)
	-- don't leave the player locked in machineByPlayer.
	self._trove:Add(task.delay(5, function()
		if started or self._session ~= nil then
			return
		end
		check()
	end))
end

function Pong:_sit(player: Player)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local seat1 = self.model:FindFirstChild("Player1", true)
	local seat2 = self.model:FindFirstChild("Player2", true)
	local players = self._machine:getPlayers()

	if #players == 1 then
		seat1:Sit(humanoid)
	else
		seat2:Sit(humanoid)
	end
end

return Pong
