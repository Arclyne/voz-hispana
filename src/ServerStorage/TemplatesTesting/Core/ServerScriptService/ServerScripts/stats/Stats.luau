local Timer = require(script.Parent.Timer)

local Stats = {}
Stats._instances = {}
Stats.__index = Stats

function Stats.new(player: Player)
	local self = setmetatable({}, Stats)
	self._player = player
	self._timer = Timer.new()
	self._timer:start()
	
	self:reset()
	self:addDecrementor("hunger", 0.3, 10)
	self:addDecrementor("thirst", 0.35, 10)
	self:addDecrementor("sleepness", 0.26, 10)
	self:addDecrementor("hygiene", 0.28, 10)
	self:addDecrementor("bladder", 2, 10)
	self:addDecrementor("physic", 0.15, 10)
	
	Stats._instances[player] = self

	return self
end

function Stats.fromPlayer(player: Player)
	return Stats._instances[player]
end

function Stats:get(name: string): number
	return self._player:GetAttribute(name)
end

function Stats:set(name: string, value: number)
	self._player:SetAttribute(name, value)
end

function Stats:reset()
	self._player:SetAttribute("hunger", 100)
	self._player:SetAttribute("thirst", 100)
	self._player:SetAttribute("sleepness", 100)
	self._player:SetAttribute("hygiene", 100)
	self._player:SetAttribute("bladder", 100)
	self._player:SetAttribute("physic", 100)
end

function Stats:increment(name: string, value: number)
	self:set(name, math.min(100, self:get(name) + value))
end

function Stats:decrement(name: string, value: number)
	self:set(name, math.max(0, self:get(name) - value))
end

function Stats:onChange(name: string, callback: () -> ())
	return self._player:GetAttributeChangedSignal(name):Connect(callback)
end

function Stats:addIncrementor(name: string, value: number, interval: number)
	return self._timer:registerCallback(function()
		self:increment(name, value)
	end, interval)
end

function Stats:addDecrementor(name: string, value: number, interval: number)
	return self._timer:registerCallback(function()
		self:decrement(name, value)
	end, interval)
end

return Stats
