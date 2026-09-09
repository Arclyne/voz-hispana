local CookingInteractable = require(script.Parent.CookingInteractable)

local Stove = {}
Stove.__index = Stove
setmetatable(Stove, CookingInteractable)

function Stove.new(model: Model)
	local self = CookingInteractable.new(model, "Stove")
	setmetatable(self, Stove)

	local fryWheel = self:addWheel("fry", function(tool)
		return tool:GetAttribute("Fryable")
	end)
	fryWheel:setQuickAction("Freír", self.request, self)
	fryWheel.page:addAction("Freír", self.request, self)

	local boilWheel = self:addWheel("boil", function(tool)
		return tool:GetAttribute("Boilable")
	end)
	boilWheel:setQuickAction("Hervir", self.request, self)
	boilWheel.page:addAction("Hervir", self.request, self)

	local occupant = model:FindFirstChild("Occupant")
	occupant.Changed:Connect(function()
		if occupant.Value then
			self:disable()
		else
			self:enable()
		end
	end)

	return self
end

return Stove
