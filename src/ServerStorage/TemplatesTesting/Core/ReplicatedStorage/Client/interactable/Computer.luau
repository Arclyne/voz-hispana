local Display = require(script.Parent.Display)

local Computer = {}
Computer.__index = Computer
setmetatable(Computer, Display)

function Computer.new(model: Model)
	local self = Display.new(model)
	setmetatable(self, Computer)

	self.wheel = self:getDefaultWheel()
	
	local page = self.wheel:addPage("Juegos")
	page:addAction("Proximamente", function() print("...") end)

	return self
end

return Computer
