local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Machine = require(script.Parent.Machine)
local fireExcept = require(script.Parent.Parent.fireExcept)
local basketUtil = require(ReplicatedStorage.Shared.basketUtil)
local Trove = require(ReplicatedStorage.Shared.Trove)

local TIMER_DURATION = 60
local MAX_SCORE = TIMER_DURATION / 3

local remotes = ReplicatedStorage.Events

local Basketball = {}
Basketball.__index = Basketball

function Basketball.new(model: Model)
	local self = setmetatable({
		model = model,
		_machine = Machine.new(model, 1),
		_trove = Trove.new(),
		_score = 0,
	}, Basketball)

	self._machine:bind(remotes.Machines.BasketThrowBall, function(player, origin, velocity)
		fireExcept(remotes.Machines.BasketThrowBall, player, model, origin, velocity)
	end)
	
	self._machine:bind(remotes.Machines.BasketReturnBall, function(player)
		fireExcept(remotes.Machines.BasketReturnBall, player, model)
	end)

	self._machine:bind(remotes.Machines.BasketScore, function()
		self._score = math.min(self._score + 1, MAX_SCORE)
		basketUtil.setScoreText(self.model, self._score)
	end)

	self._machine:bind(remotes.Machines.BasketFinish, function()
		self:stop()
	end)

	model:SetAttribute("Timer", TIMER_DURATION)

	return self
end

function Basketball:join(player: Player)
	return self._machine:join(player)
end

function Basketball:start()
	local player = self._machine:getPlayer()
	if not player then
		return
	end

	if not self._machine:start(player.Character) then
		return
	end

	self._trove:Add(task.spawn(function()
		for i = TIMER_DURATION, 0, -1 do
			self.model:SetAttribute("Timer", i)
			task.wait(1)
		end
		
		if self._score > 0 then
			self:_handle(self._machine:getPlayer(), self._score)
		end

		self:stop()
	end))

	self._trove:Add(function()
		basketUtil.setScoreText(self.model, 0)
		self.model:SetAttribute("Timer", TIMER_DURATION)
	end)
end

function Basketball:stop()
	self._score = 0
	self._trove:Clean()
	self._machine:stop()
end

function Basketball:onStop(callback: (Player) -> ())
	self._machine.stopped:Connect(callback)
end

function Basketball:_handle(player: Player, score: number)
	warn(`[basketball] player({player}) score({score})`)
end

return Basketball
