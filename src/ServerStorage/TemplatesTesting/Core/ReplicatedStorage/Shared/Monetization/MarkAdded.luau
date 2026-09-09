local module = {}
module.__index = module

function module.new(Player, id, InfoType)
	local self = setmetatable({
		Player = Player,
		id = id,
		InfoType = InfoType
	}, module)
	return self
end

function module:BindToClose(action)
	if self.IsDestroyed then return end
	assert(typeof(action) == "function", "Agregar solo funciones.")
	self.BindToCloseAction = action
end

function module:cancel(was)
	if self.IsDestroyed then return end
	if self.BindToCloseAction then task.defer(self.BindToCloseAction,self.Player,self.id,was) end
	self:Destroy()
end

function module:Destroy()
	self.BindToCloseAction = nil
	table.clear(self)
	self.IsDestroyed = true
end

function module:decition(id, was, infoType)
	if infoType ~= self.InfoType
		or id ~= self.id then
		self:cancel("Closed")
	else
		self:cancel(was and "Success" or "Cancel")
	end
end

return module