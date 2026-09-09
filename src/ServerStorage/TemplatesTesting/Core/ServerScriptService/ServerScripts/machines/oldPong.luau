local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MultiplayerMachine = require(script.Parent.MultiplayerMachine)
local createPongSession = require(ReplicatedStorage.Shared.pong.createPongSession)

local remotes = ReplicatedStorage.Events

local Pong = {}
Pong.__index = Pong

setmetatable(Pong, MultiplayerMachine)

function Pong.new(model: Model)
	local self = MultiplayerMachine.new(model)
	setmetatable(self, Pong)
	
	self.seat1 = model:FindFirstChild("Player1")
	self.seat2 = model:FindFirstChild("Player2")

	self.score1 = 0
	self.score2 = 0
	
	self:_bind(remotes.Machines.PongTick, function(player, tick)
		if self.session then
			self.session.ball._ticksMap[player] = tick
		end
	end)

	self:_bind(remotes.Machines.PongInput, function(player, input)
		if self.session then
			local paddle = self.session.player1 == player and self.session.paddle1 or self.session.paddle2
			table.insert(paddle._inputQueue, input)
		end
	end)
	
	self:_bind(remotes.Machines.PongShot, function(player)
		if self.session and self.session.ball._owner == player then
			self.session.ball:shoot()

			if self.session.paddle1._player == player then
				remotes.Machines.PongShot:FireClient(self.session.paddle2._player)
			else
				remotes.Machines.PongShot:FireClient(self.session.paddle1._player)
			end
		end
	end)

	return self
end

function Pong:waiting(player: Player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	if player == self.player1 then
		self.seat1:Sit(humanoid)
	elseif player == self.player2 then
		self.seat2:Sit(humanoid)
	end
end

function Pong:startMultiplayer()
	self.session = createPongSession(self.player1, self.player2, self.model)
	local scoreText = self.model.ScorePart.SurfaceGui.Score
	local winnerText = self.model.Glass.SurfaceGui.Winner

	local function spawnBall(player: Player)
		--if getWinner(session) then
		--	return
		--end
		self.session.ball:spawn(player)
		remotes.Machines.PongSpawn:FireClient(self.player1, { player = player })
		remotes.Machines.PongSpawn:FireClient(self.player2, { player = player })
	end

	spawnBall(self.player1)
	
	self.session.ball:onScore(function(direction)
		if direction == "left" then
			self.session.score1 += 1
			spawnBall(self.player2)
		elseif direction == "right" then
			self.session.score2 += 1
			spawnBall(self.player1)
		end

		scoreText.Text = string.format("%i | %i", self.session.score2, self.session.score1)

		local winner = nil--getWinner(self.session)
		if winner then
			winnerText.Text = `{winner.Name} ha ganado`
			self.trove:Add(task.delay(2, function()
				self:stop()
			end))

			self:handle()
		end
	end)
	
	self.trove:Add(self.session.destroy)
	self.trove:Add(function()
		self.session = nil
		scoreText.Text = "0 | 0"
		winnerText.Text = ""
	end)
end

function Pong:handle()
	print(self.player1)
end

return Pong
