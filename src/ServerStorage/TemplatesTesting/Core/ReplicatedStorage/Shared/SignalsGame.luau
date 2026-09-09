local module = {}
local DatasSignals = {}
local EventCustom = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("Event"))
function OnlyString(key)
	assert(typeof(key) == "string", "Only string")
end
function module.OnEvent(_, key, action)
	assert(typeof(action) == "function", "Only functions")
	return module:Set(key):Connect(action)
end
function module.Fire(_, key,...)
	module:Set(key):Fire(...)
end
function module.Get(_, key)
	OnlyString(key)
	return DatasSignals[key]
end
function module.Set(_, key)
	OnlyString(key)
	local event = module:Get(key)
	if not event then
		event = EventCustom.new()
		DatasSignals[key] = event
	end
	return event
end

--[[
	Servira para conectar acciones para que entre diferentes sistemas lo podamos usar:
	Podriamos usarlo para que mi sistema de GUI se desactive cuando otro Gui que no pertenezca a mi mismo polimorfismo.
	
	Ejemplo de codigo
	
	local SignalGames = require(--//Path_module)
	
	--Ejemplo 1
	local DonarCoinsSignal = SignalGames:Set("DonacionCoins")
	DonarCoinsSignal:Connect(function()
		--accion
	end)
	--Ejemplo 2
	
	Player.Character.Humanoid.Died:Connect(function()
		SignalGames:Fire("PlayerDeadSignal")
	end)
	
	:
	
	local Frame = script.Parent
	
	SignalGames:OnEvent("PlayerDeadSignal", function()
		--accion
	end)
]]

return module