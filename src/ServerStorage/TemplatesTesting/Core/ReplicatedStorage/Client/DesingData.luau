local module = {}

module.Material = {
	{
		Key = 1,
		Material = Enum.Material.Wood,
		MaterialVariant = "Wood4",
		Price = {Coins = 1000},
		IsWithGamepass = nil,
	},
	
	{
		Key = 2,
		Material = Enum.Material.Metal,
		MaterialVariant = "Aluminium",
		Price = nil,
		IsWithGamepass = "Material",
	},
	
}

module.Colors = {
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(0, 0, 0),
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 0, 255),
}

function module.FindMaterial(Key)
	for _, material in module.Material do
		if material.Key == Key then
			return material
		end
	end
end

return module