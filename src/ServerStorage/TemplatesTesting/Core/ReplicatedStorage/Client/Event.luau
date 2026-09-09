local module = {}
module.__index = module
function module.new()
	local self = setmetatable({
		Actions = {},
	}, module)
	return self
end
function module:Fire(...)
	assert(not self.isDestroyed , "The event is destroyed...")
	if #self.Actions > 0 then
		for _, action in table.clone(self.Actions) do
			if not action.Connected then continue end
			task.spawn(action["function"],...)
		end
	end
end
function module:Connect(conexion)
	assert(not self.isDestroyed , "The event is destroyed...")
	assert(typeof(conexion) == "function" , "No function...")
	local tablee = {}
	tablee.__index = tablee
	local dataMetatable = setmetatable({
		Connected = true,
		["function"] = conexion,
	}, tablee)
	function tablee.Disconnect()
		if dataMetatable.Connected then
			dataMetatable.Connected = false
			local index = table.find(self.Actions, dataMetatable)
			if index then
				table.remove(self.Actions, index)
			end
		end
	end
	table.insert(self.Actions, dataMetatable)
	return dataMetatable
end
function module:Destroy()
	assert(not self.isDestroyed , "The event is destroyed...")
	self.isDestroyed = true
	table.clear(self.Actions)
end
return module