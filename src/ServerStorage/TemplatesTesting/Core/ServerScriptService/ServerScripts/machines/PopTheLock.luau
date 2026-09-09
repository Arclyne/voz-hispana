local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Machine = require(script.Parent.Machine)
local fireExcept = require(script.Parent.Parent.fireExcept)

local remotes = ReplicatedStorage.Events

local PopTheLock = {}
PopTheLock.__index = PopTheLock

function PopTheLock.new(model: Model)
	local self = setmetatable({
		model = model,
		_machine = Machine.new(model, 1),
	}, PopTheLock)

	self._machine:bind(remotes.Machines.PopTheLockFlip, function(player, angle)
		fireExcept(remotes.Machines.PopTheLockFlip, player, model, angle)
	end)

	self._machine:bind(remotes.Machines.PopTheLockClaim, function(player)
		fireExcept(remotes.Machines.PopTheLockClaim, player, model)
	end)
	
	self._machine:bind(remotes.Machines.PopTheLockFinish, function(player, tickets)
		fireExcept(remotes.Machines.PopTheLockFinish, player, model, tickets)
		if tickets > 0 then
			self:_handle(player, tickets)
		end
		self:stop()
	end)

	return self
end

function PopTheLock:join(player: Player)
	return self._machine:join(player)
end

function PopTheLock:start()
	self._machine:start()
end

function PopTheLock:stop()
	self._machine:stop()
end

function PopTheLock:onStop(callback: (Player) -> ())
	self._machine.stopped:Connect(callback)
end

function PopTheLock:_handle(player: Player, tickets: number)
	warn(`[pop the lock] player({player}) tickets({tickets})`)
end

return PopTheLock
