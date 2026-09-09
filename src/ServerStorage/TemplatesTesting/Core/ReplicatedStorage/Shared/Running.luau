local module = {}

module.Functions = {}

local runService = game:GetService('RunService')
local Action = runService:IsServer() and runService.Heartbeat or runService.RenderStepped
local active:RBXScriptConnection

function Running(delta)
	if #module.Functions > 0 then
		local now = tick()
		
		for _,v in module.Functions do
			if not v.aviable or (now - v.startTime) < v.cold then continue end
			v.startTime = now
			local nice, ErrorMessage = pcall(task.spawn, v.fun, delta)
			if not nice then
				warn(ErrorMessage)
				module:ElimineFunct(v)
			end
		end
	elseif active then
		active:Disconnect()
		active = nil
	end
end

function module:AddFunct(fun, cold)
	if typeof(fun) ~= 'function' then return end
	cold = tonumber(cold) or 0
	local list = {fun = fun, aviable = true, cold = cold, startTime = tick() - cold - .1}
	table.insert(module.Functions, list)
	if not active then
		active = Action:Connect(Running)
	end
	return list
end

function module:ElimineFunct(fun)
	if typeof(fun) ~= 'table' then return end
	local index = table.find(module.Functions,fun)
	if index then
		fun.aviable = false
		table.remove(module.Functions, index)
	end
end

function module:ClearFunct()
	module.Functions = {}
end

return module