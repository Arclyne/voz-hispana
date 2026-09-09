--!strict

--[=[
	@class capitalize

	Pone en mayúscula la primera letra. Fuente única de la convención de nombres de las
	tarjetas keyeadas (`cards`): `World` + `admin` → `WorldAdminCard`, para que [Store] al
	construir y [Store.readCard] al leer deriven el mismo DataStore default.
]=]
local function capitalize(text: string): string
	return text:sub(1, 1):upper() .. text:sub(2)
end

return capitalize
