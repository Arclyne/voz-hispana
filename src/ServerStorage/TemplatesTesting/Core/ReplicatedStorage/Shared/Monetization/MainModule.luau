local module = {}
local http = game:GetService("HttpService")
local MPS = game:GetService('MarketplaceService')

-- Nuestro Proxy Privado
local MY_PROXY_URL = "http://107.174.178.86"
local MY_SECRET_KEY = "VozHispana14759125123471357234"

module.assetTypeIds = {
	["Pants_Shirt"] = 12,
	["Pass"] = 34,
}

module.getItems = function(assetId, plrId, Intento)
	local filteredItems = {}
	local success, errormsg = pcall(function()
		if plrId.UserId < 10 then return end
		if assetId == 34 then
			-- Pases y otras lógicas
			return {}
		else
			-- Usamos nuestro servidor con la ruta de catalog
			local url = MY_PROXY_URL .. '/catalog/v1/search/items/details?Category=3&CreatorName=' .. plrId.Name
			local headers = {
				["My-Secret"] = MY_SECRET_KEY
			}

			-- Hacemos la petición con seguridad
			local response = http:GetAsync(url, true, headers)
			return http:JSONDecode(response).data
		end
	end)

	if not success then
		warn("[Proxy VPS] ❌ Error cargando items de", plrId.Name, ":", errormsg)
	end

	return typeof(errormsg) == 'table' and errormsg or filteredItems
end

module.LoadProductInfo = function(ID, tipo)
	if not tonumber(ID) then return end
	local nice,product = pcall(function()
		return MPS:GetProductInfo(ID, tipo)
	end)
	if nice then
		return {
			assetType = product.AssetTypeId,
			price = product.PriceInRobux,
			id = ID,
			itemType = product.ProductType,
			description = product.Description,
			name = product.Name,
		}
	else
		warn(product)
	end
end

module.loadItems = function(plr)
	local allItems = {}
	for _, assetType in pairs(module.assetTypeIds) do
		local items = module.getItems(assetType, plr) or {}
		for index, item in pairs(items) do
			if item.assetType == 2 then continue end
			items[index].assetType = item.assetType or assetType
			table.insert(allItems, item)
		end
	end
	return allItems
end

return module