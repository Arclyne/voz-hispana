local CookingInteractable = require(script.Parent.CookingInteractable)

local Blender = {}
Blender.__index = Blender
setmetatable(Blender, CookingInteractable)

function Blender.new(model: Model)
	local self = CookingInteractable.new(model, "Blender")
	setmetatable(self, Blender)

	local wheel = self:addWheel("blend", function(tool)
		return tool:GetAttribute("Blendable")
	end)
	wheel:setQuickAction("Mezclar", self.request, self)
	wheel.page:addAction("Mezclar", self.request, self)

	model:GetAttributeChangedSignal("Active"):Connect(function()
		if model:GetAttribute("Active") then
			self:disable()
		else
			self:enable()
		end
	end)

	return self
end

return Blender
