local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Machine = require(script.Parent.Machine)
local fireExcept = require(script.Parent.Parent.fireExcept)

local remotes = ReplicatedStorage.Events

local Stacker = {}
Stacker.__index = Stacker

function Stacker.new(model: Model)
	local self = setmetatable({
		model = model,
		_machine = Machine.new(model, 1),
	}, Stacker)
	
	self._machine:bind(remotes.Machines.StackerPosition, function(player, pos)
		fireExcept(remotes.Machines.StackerPosition, player, model, pos)
	end)
	
	self._machine:bind(remotes.Machines.StackerFinish, function(player, success)
		if success then
			self:_handle(player)
		end
		self:stop()
	end)

	return self
end

function Stacker:join(player: Player)
	return self._machine:join(player)
end

function Stacker:start()
	self._machine:start()
end

function Stacker:stop()
	self._machine:stop()
end

function Stacker:onStop(callback: (Player) -> ())
	self._machine.stopped:Connect(callback)
end

function Stacker:_handle(player: Player)
	warn(`[stacker] player({player})`)
end

return Stacker
