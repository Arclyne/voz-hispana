local Roulette = require(script.Parent.Roulette)
local Stacker = require(script.Parent.Stacker)
local Basketball = require(script.Parent.Basketball)
local PopTheLock = require(script.Parent.PopTheLock)
local ToyMachine = require(script.Parent.ToyMachine)
local Pong = require(script.Parent.Pong)

local MachineFactory = {}

function MachineFactory.create(type: string, model: Model)
	if type == "Stacker" then
		return Stacker.new(model)
	elseif type == "Roulette" then
		return Roulette.new(model)
	elseif type == "Basketball" then
		return Basketball.new(model)
	elseif type == "PopTheLock" then
		return PopTheLock.new(model)
	elseif type == "ToyMachine" then
		return ToyMachine.new(model)
	elseif type == "Pong" then
		return Pong.new(model)
	end
end

return MachineFactory
