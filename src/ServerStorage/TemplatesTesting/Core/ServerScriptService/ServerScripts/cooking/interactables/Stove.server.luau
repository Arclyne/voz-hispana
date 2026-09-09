local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CookingStation = require(script.Parent.Parent.CookingStation)

local COOKWARE = {
	Fryable = ReplicatedStorage.Assets.Furnitures.Pan,
	Boilable = ReplicatedStorage.Assets.Furnitures.Pot,
}

local Stove = setmetatable({}, CookingStation)
Stove.__index = Stove

function Stove.new()
	local self = CookingStation.new("Stove")
	self.expirationTime = 3
	self.expiredItem = "Overcooked"
	self.skipResultVisual = true
	return setmetatable(self, Stove)
end

function Stove:matchAttribute(tool: Tool): string?
	for attribute in COOKWARE do
		if tool:GetAttribute(attribute) then
			return attribute
		end
	end
	return nil
end

function Stove:validate(model: Model): boolean
	local occupant = model:FindFirstChild("Occupant")
	return occupant and not occupant.Value
end

function Stove:onStart(ctx)
	local occupant = ctx.model:FindFirstChild("Occupant")
	occupant.Value = ctx.player

	local cookware = COOKWARE[ctx.matchedAttribute]:Clone()
	for _, desc in cookware:GetDescendants() do
		if desc:IsA("BasePart") then
			desc.Anchored = true
		end
	end
	cookware:PivotTo(ctx.model.Cookware.CFrame * CFrame.new(0, 0.1, 0))
	cookware.Name = "ProcessingVisual"
	cookware.Parent = ctx.model

	return function()
		if occupant.Value == ctx.player then
			occupant.Value = nil
		end
		for _, desc in cookware:GetDescendants() do
			if desc:IsA("ParticleEmitter") then
				desc.Enabled = false
			end
		end
		return ctx.model.Cookware.CFrame * CFrame.new(0, 0.5, 0)
	end
end

function Stove:onCancel(ctx)
	local occupant = ctx.model:FindFirstChild("Occupant")
	occupant.Value = nil
	local cookware = ctx.model:FindFirstChild("ProcessingVisual")
	if cookware then
		cookware:Destroy()
	end
end

function Stove:onExpire(model: Model): boolean
	local cookware = model:FindFirstChild("ProcessingVisual")
	if not cookware then
		return false
	end

	local foodModel = cookware:FindFirstChildOfClass("Model")
	if not foodModel then
		return false
	end

	for _, desc in foodModel:GetDescendants() do
		if desc:IsA("MeshPart") then
			desc.Color = Color3.new(0, 0, 0)
			desc.TextureID = ""
		elseif desc:IsA("BasePart") then
			desc.Color = Color3.new(0, 0, 0)
			desc.Material = Enum.Material.Slate
		end
	end
	return true
end

Stove.new():bind()
