local module = {}
local SplitRespectingBrackets = require(script:WaitForChild("SplitRespectingBrackets"))

function module.format(encoded)
	return typeof(encoded) == 'string' and string.split(encoded, "|")
end
function module.InvertFormat(encoded)
	local format = module.SeguridadFormato(encoded)
	return format and table.concat(format,"|")
end

function module.change(encoded,change,index)
	encoded = module.SeguridadFormato(encoded)
	if typeof(index) ~= 'number' or not encoded then return false end
	index = math.clamp(math.floor(index),1,4)
	encoded[index] = change
	return encoded
end

function module.SeguridadFormato(string1)
	if typeof(string1) == 'string' then
		return module.SeguridadFormato(module.format(string1))
	elseif typeof(string1) == 'table' then
		local encontrar = string1
		return typeof(encontrar) == 'table' and encontrar[1] --[[Resolucion]] and
			tonumber(encontrar[2]) --[[Id creator]] and tonumber(encontrar[3]) --[[Id Owner]] and encontrar[4] --[[Nombre cuadro]]
			and module.GetInfoExtra(encontrar[5]) and encontrar
	end
end

function module.IsOwner(Player:Player, Format)
	local resultado = module.SeguridadFormato(Format)
	if resultado then
		return tonumber(resultado[3]) == (typeof(Player) == "number" and Player or Player.UserId)
	end
end

function module.GetPintura(string1)
	string1 = module.SeguridadFormato(string1)
	if string1 then
		for _ = 1, 5 do table.remove(string1,1) end
		return string1
	end
	return {}
end

function module.GetInfoExtra(string1)
	if typeof(string1) == 'string' and string.match(string1, "^[%(%[%{].*[%}%]%)]$") then
		return SplitRespectingBrackets(string.sub(string1,2,#string1 - 1))
	elseif typeof(string1) == 'table' then
		return string1
	end
end

return module
