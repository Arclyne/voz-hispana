--!strict

--[=[
	@function deepEquals
	@within Util

	Igualdad estructural recursiva: dos valores son iguales si son el mismo valor
	primitivo o si son tablas con exactamente las mismas claves y valores iguales
	en profundidad.
]=]
local function deepEquals(a: any, b: any): boolean
	if a == b then
		return true
	end
	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end
	for key, value in a do
		if not deepEquals(value, b[key]) then
			return false
		end
	end
	for key in b do
		if a[key] == nil then
			return false
		end
	end
	return true
end

return deepEquals
