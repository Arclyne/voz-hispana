function quitarAcentos(palabra)
	local acentos = {
		["á"] = "a", ["é"] = "e", ["í"] = "i", ["ó"] = "o", ["ú"] = "u",
		["Á"] = "A", ["É"] = "E", ["Í"] = "I", ["Ó"] = "O", ["Ú"] = "U",
		["ñ"] = "n", ["Ñ"] = "N" 
	}
	return (palabra:gsub("[%z\1-\127\194-\244][\128-\191]*", function(c)
		return acentos[c] or c
	end))
end
function quitarSimbolos(str)
	return str:gsub("[^%w%s]", "")
end

function BuscarKeysPorJugador(texto, tabla, indiceLista)
	if typeof(texto) == 'string' and typeof(tabla) == 'table' and indiceLista then
		local resultados = {}

		local indices = {}
		for palabra in texto:gmatch("%S+") do
			if #palabra <= 2 then continue end
			palabra = quitarSimbolos(palabra):lower()
			table.insert(indices,quitarAcentos(palabra))
		end

		if #indices <= 0 then
			return
		end

		for index, datos in tabla do
			local Coinciden = false

			for _,coincidencia in indices do
				if string.match(index,coincidencia) then
					Coinciden = true
					break
				end
			end


			if Coinciden and datos[indiceLista] then
				for _,key in datos[indiceLista] do
					if not resultados[key] then
						resultados[key] = key
					end
				end
			else
				continue
			end

		end

		for _,_ in resultados do
			return resultados
		end
	end
end

local datos = {
	['jose'] = {
		Revision = {'cancionBonita', 'ElRey123'},
		Publicas = {'MiVidaSinTi', 'LocuraTotal'}
	},
	['luis'] = {
		Revision = {'TeAmaréPorSiempre', 'cancionbonita'},
		Publicas = {'LocuraTotal', 'AventuraTotal'}
	},
	['lose'] = {
		Revision = {'TeAmaréPorSiempre', 'cancionBonita'},
		Publicas = {'LocuraTotal', 'AventuraTotal'}
	},
}

local resultado = BuscarKeysPorJugador("os.", datos, "Revision")
print(resultado)
