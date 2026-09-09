--!strict

--[=[
	@class Util

	Funciones puras reutilizables del paquete.
]=]

--[=[
	@function deepCopy
	@within Util

	Copia profunda de una tabla. Los valores no-tabla se devuelven sin cambios.
]=]
local function deepCopy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for k, v in pairs(value) do
		copy[k] = deepCopy(v)
	end
	return copy
end

return deepCopy
