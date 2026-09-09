local module = {}

local DataDesing = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("DesingData"))

function module:Color(folder : Folder, color)
	if not folder or not color then return end
	color = typeof(color) == "Color3" and color or Color3.new(1, 1, 1)
	for _,base:BasePart in folder:GetChildren() do
		if not base:IsA('BasePart') then continue end
		base.Color = color
	end
end

function module:Material(folder : Folder, Texture)
	if not folder or not Texture then return end
	local encontrar = DataDesing.FindMaterial(Texture)
	if encontrar then
		for _,base:BasePart in folder:GetChildren() do
			if not base:IsA('BasePart') then continue end
			base.Material = encontrar.Material or base.Material
			base.MaterialVariant = encontrar.MaterialVariant or ""
		end
	end
end

return module