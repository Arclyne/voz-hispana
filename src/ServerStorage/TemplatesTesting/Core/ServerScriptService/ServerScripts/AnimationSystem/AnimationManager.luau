local module = {}

-- Requerimos la configuración de IDs (que está al mismo nivel, como hermano)
local AnimationConfig = require(game.ReplicatedStorage:WaitForChild("DancesInfo"))

-- Función única para añadir bailes
-- Sirve para: DataStore (al cargar), Tiendas (al comprar), Premios, etc.
function module.AddAnimation(player: Player, animationName: string)
	-- 1. Validar que el baile existe en nuestra configuración
	local animData = AnimationConfig[animationName]
	if not animData then
		warn("Intentaste añadir una animación que no existe en la config: " .. tostring(animationName))
		return nil
	end

	-- 2. Buscar o crear la carpeta de animaciones del jugador
	local animFolder = player:FindFirstChild("Animations")
	if not animFolder then
		animFolder = Instance.new("Folder")
		animFolder.Name = "Animations"
		animFolder.Parent = player
	end

	-- 3. Verificar si el jugador ya lo tiene
	if animFolder:FindFirstChild(animationName) then
		-- Ya lo tiene, retornamos el existente
		return animFolder[animationName]
	end

	-- 4. Crear el objeto que representa la posesión del baile
	local val = Instance.new("BoolValue")
	val.Name = animationName
	val.Value = true -- Indica que lo posee

	-- 5. APLICAR ATRIBUTOS (Crucial para que tu UI funcione)
	val:SetAttribute("Category", animData.category)
	val:SetAttribute("AssetId", animData.assetId)
	val:SetAttribute("Looped", animData.looped)
	val:SetAttribute("StopOnMove", animData.stopOnMove)

	val.Parent = animFolder

	return val
end

-- Función para verificar si tiene un baile (útil para validaciones rápidas)
function module.HasAnimation(player: Player, animationName: string)
	local folder = player:FindFirstChild("Animations")
	if folder and folder:FindFirstChild(animationName) then
		return true
	end
	return false
end

-- Nombres de los bailes (category == "dances") que el jugador ya posee. Los
-- gestos quedan afuera a propósito: esto alimenta la tienda de bailes.
function module.GetOwned(player: Player): {string}
	local owned = {}
	local folder = player:FindFirstChild("Animations")
	if not folder then
		return owned
	end

	for _, val in folder:GetChildren() do
		if val:GetAttribute("Category") == "dances" then
			table.insert(owned, val.Name)
		end
	end

	return owned
end

return module
