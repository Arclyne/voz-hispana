--!strict
--[[
	Adaptadores de tipo: traducen valores de Roblox a escalares y de vuelta.

	Contrato:
	  - `decompose` escribe en `out` a partir de `offset`; nunca asigna tablas.
	  - `compose` lee `arity` escalares desde `offset` y construye el valor.
	  - Todo adaptador debe cumplir `compose(decompose(v)) == v` salvo error de coma flotante.
]]

local color = require(script.Parent.color)
local types = require(script.Parent.Parent.types)

type AnimatableAdapter = types.AnimatableAdapter

local colorSpace: color.ColorSpace = "linear"

local adapters = {}

-- Espacio en el que se interpolan los Color3. Ver `docs/DESIGN.md` seccion 3.6.
function adapters.setColorSpace(space: color.ColorSpace)
	colorSpace = space
end

function adapters.getColorSpace(): color.ColorSpace
	return colorSpace
end

local number: AnimatableAdapter = {
	name = "number",
	arity = 1,
	decompose = function(value: number, out: { number }, offset: number?): { number }
		out[(offset or 0) + 1] = value
		return out
	end,
	compose = function(scalars: { number }, offset: number): number
		return scalars[offset + 1]
	end,
}

local boolean: AnimatableAdapter = {
	name = "boolean",
	arity = 1,
	discrete = true,
	decompose = function(value: boolean, out: { number }, offset: number?): { number }
		out[(offset or 0) + 1] = if value then 1 else 0
		return out
	end,
	compose = function(scalars: { number }, offset: number): boolean
		return scalars[offset + 1] >= 0.5
	end,
}

local udim: AnimatableAdapter = {
	name = "UDim",
	arity = 2,
	decompose = function(value: UDim, out: { number }, offset: number?): { number }
		local o = offset or 0
		out[o + 1] = value.Scale
		out[o + 2] = value.Offset
		return out
	end,
	compose = function(s: { number }, o: number): UDim
		return UDim.new(s[o + 1], s[o + 2])
	end,
}

local udim2: AnimatableAdapter = {
	name = "UDim2",
	arity = 4,
	decompose = function(value: UDim2, out: { number }, offset: number?): { number }
		local o = offset or 0
		out[o + 1] = value.X.Scale
		out[o + 2] = value.X.Offset
		out[o + 3] = value.Y.Scale
		out[o + 4] = value.Y.Offset
		return out
	end,
	compose = function(s: { number }, o: number): UDim2
		return UDim2.new(s[o + 1], s[o + 2], s[o + 3], s[o + 4])
	end,
}

local vector2: AnimatableAdapter = {
	name = "Vector2",
	arity = 2,
	decompose = function(value: Vector2, out: { number }, offset: number?): { number }
		local o = offset or 0
		out[o + 1] = value.X
		out[o + 2] = value.Y
		return out
	end,
	compose = function(s: { number }, o: number): Vector2
		return Vector2.new(s[o + 1], s[o + 2])
	end,
}

local vector3: AnimatableAdapter = {
	name = "Vector3",
	arity = 3,
	decompose = function(value: Vector3, out: { number }, offset: number?): { number }
		local o = offset or 0
		out[o + 1] = value.X
		out[o + 2] = value.Y
		out[o + 3] = value.Z
		return out
	end,
	compose = function(s: { number }, o: number): Vector3
		return Vector3.new(s[o + 1], s[o + 2], s[o + 3])
	end,
}

local color3: AnimatableAdapter = {
	name = "Color3",
	arity = 3,
	decompose = function(value: Color3, out: { number }, offset: number?): { number }
		color.decompose(value, colorSpace, out, offset or 0)
		return out
	end,
	compose = function(s: { number }, o: number): Color3
		return color.compose(s, o, colorSpace)
	end,
}

local rect: AnimatableAdapter = {
	name = "Rect",
	arity = 4,
	decompose = function(value: Rect, out: { number }, offset: number?): { number }
		local o = offset or 0
		out[o + 1] = value.Min.X
		out[o + 2] = value.Min.Y
		out[o + 3] = value.Max.X
		out[o + 4] = value.Max.Y
		return out
	end,
	compose = function(s: { number }, o: number): Rect
		return Rect.new(s[o + 1], s[o + 2], s[o + 3], s[o + 4])
	end,
}

local numberRange: AnimatableAdapter = {
	name = "NumberRange",
	arity = 2,
	decompose = function(value: NumberRange, out: { number }, offset: number?): { number }
		local o = offset or 0
		out[o + 1] = value.Min
		out[o + 2] = value.Max
		return out
	end,
	compose = function(s: { number }, o: number): NumberRange
		local min, max = s[o + 1], s[o + 2]
		-- Los resortes no llegan al reposo a la vez; Min puede cruzar Max a mitad de camino.
		return NumberRange.new(math.min(min, max), math.max(min, max))
	end,
}

adapters.list = {
	number,
	boolean,
	udim,
	udim2,
	vector2,
	vector3,
	color3,
	rect,
	numberRange,
}

return adapters
