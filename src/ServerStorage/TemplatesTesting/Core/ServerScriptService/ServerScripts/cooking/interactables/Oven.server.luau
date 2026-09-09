local CookingStation = require(script.Parent.Parent.CookingStation)

local Oven = setmetatable({}, CookingStation)
Oven.__index = Oven

function Oven.new()
	local self = CookingStation.new("Oven")
	return setmetatable(self, Oven)
end

function Oven:matchAttribute(tool: Tool): string?
	return if tool:GetAttribute("Bakeable") then "Bakeable" else nil
end

function Oven:validate(model: Model): boolean
	return not model:GetAttribute("Active")
end

function Oven:onStart(ctx)
	local model = ctx.model

	local foodClone = CookingStation.cloneFood(ctx.tool)
	local foodSlot = model:FindFirstChild("Slot")

	-- Open door, wait for open animation, then place food inside
	model:SetAttribute("DoorOpen", true)
	task.wait(0.4)
	if foodClone and foodClone.PrimaryPart and foodSlot then
		foodClone:PivotTo(foodSlot:GetPivot())
		foodClone.Name = "ProcessingVisual"
		foodClone.Parent = model
	end
	ctx.removeTool()

	-- Close door after brief pause, then wait for close animation
	task.wait(0.75)
	model:SetAttribute("DoorOpen", false)
	task.wait(0.4)

	model:SetAttribute("Active", true)

	return function()
		local visual = model:FindFirstChild("ProcessingVisual")

		if visual then
			model:SetAttribute("DoorOpen", true)

			-- Eliminamos el plato que se estaba cocinando
			-- antes de que CookingStation cree el resultado final
			visual:Destroy()
		else
			model:SetAttribute("DoorOpen", false)
		end

		model:SetAttribute("Active", false)

		return foodSlot and foodSlot:GetPivot()
	end
end

function Oven:onCancel(ctx)
	local visual = ctx.model:FindFirstChild("ProcessingVisual")
	if visual then
		visual:Destroy()
	end
end

function Oven:onPickup(model: Model)
	model:SetAttribute("DoorOpen", false)
end

Oven.new():bind()