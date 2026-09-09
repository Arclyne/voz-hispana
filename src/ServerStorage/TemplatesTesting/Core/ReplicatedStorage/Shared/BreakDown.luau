local module = {}

module.DataNormal = {
	['boolean'] = true,
	['string'] = true,
	['number'] = true
}

module.GetFuncs = {
	["Vector3"] = function(option)
		return Vector3.new(option.x, option.y, option.z)
	end,
	["Vector2"] = function(option)
		return Vector2.new(option.x, option.y)
	end,
	["Color3"] = function(option : Color3)
		return Color3.fromHSV(option.H, option.S, option.V)
	end,
	["CFrame"] = function(option : CFrame)
		return CFrame.new(option.x, option.y, option.z) * CFrame.Angles(option.xO, option.yO, option.zO)
	end,
	["UDim2"] = function(option : UDim2)
		return UDim2.new(option.X.Scale, option.X.Offset, option.Y.Scale, option.Y.Offset)
	end,
	["function"] = function(option)
		return option()
	end,
}

module.SetFuncs = {
	["UDim2"] = function(option : UDim2)
		return {
			X = { Scale = option.X.Scale, Offset = option.X.Offset },
			Y = { Scale = option.Y.Scale, Offset = option.Y.Offset }
		}
	end,
	["Vector3"] = function(option : Vector3)
		return { x = option.X, y = option.Y, z = option.Z }
	end,
	["Vector2"] = function(option : Vector2)
		return { x = option.X, y = option.Y }
	end,
	["Color3"] = function(option : Color3)
		local H,S,V = option:ToHSV()
		return { H = H, S = S, V = V }
	end,
	["CFrame"] = function(option : CFrame)
		local x,y,z = option:ToOrientation()
		local pos = option.Position
		return {
			x = pos.X, y = pos.Y, z = pos.Z,
			xO = x, yO = y, zO = z,
		}
	end,
}

function module.Set(Option)
	if module.DataNormal[typeof(Option)] then return Option end

	-- Protección: Verificamos si existe la función antes de llamarla
	local setFunc = module.SetFuncs[typeof(Option)]
	if setFunc then
		return {
			["type"] = typeof(Option),
			["decomposition"] = setFunc(Option),
		}
	else
		return nil
	end
end

function module.Get(List : {})
	if typeof(List) == 'table' then
		-- AQUÍ ESTABA EL ERROR: Verificamos que 'type' exista y sea válido
		if List["type"] and module.GetFuncs[List["type"]] then
			return module.GetFuncs[List["type"]](List["decomposition"])
		else
			-- Si es una tabla sin formato especial, la devolvemos tal cual para no romper nada
			return List
		end
	else
		return List
	end
end

return module