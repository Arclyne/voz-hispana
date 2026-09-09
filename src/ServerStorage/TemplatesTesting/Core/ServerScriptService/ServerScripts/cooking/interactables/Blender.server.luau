local CookingStation = require(script.Parent.Parent.CookingStation)

local Blender = setmetatable({}, CookingStation)
Blender.__index = Blender

function Blender.new()
	local self = CookingStation.new("Blender")
	self.defaultDuration = 4
	self.skipResultVisual = true
	return setmetatable(self, Blender)
end

function Blender:matchAttribute(tool: Tool): string?
	return if tool:GetAttribute("Blendable") then "Blendable" else nil
end

function Blender:validate(model: Model): boolean
	return not model:GetAttribute("Active")
end

function Blender:onStart(ctx)
	local model = ctx.model
	local contentMesh = model:FindFirstChild("ContentMesh")
	local blendColor = ctx.tool:GetAttribute("BlendColor")

	model:SetAttribute("Active", true)

	if contentMesh then
		if blendColor then
			contentMesh.Color = blendColor
		end
		contentMesh.Transparency = 0
	end

	return function()
		model:SetAttribute("Active", false)
	end
end

function Blender:onCancel(ctx)
	local contentMesh = ctx.model:FindFirstChild("ContentMesh")
	if contentMesh then
		contentMesh.Transparency = 1
	end
end

function Blender:onPickup(model: Model)
	local contentMesh = model:FindFirstChild("ContentMesh")
	if contentMesh then
		contentMesh.Transparency = 1
	end
end

Blender.new():bind()
