--!strict
--[[
	Conversion de Color3 al espacio en el que se interpola.

	Interpolar en sRGB (el espacio en el que Roblox guarda Color3) oscurece el punto
	medio entre dos colores saturados. Por defecto interpolamos en RGB lineal, que
	corrige eso sin coste apreciable. `oklab` es opt-in: es perceptualmente uniforme
	y da los degradados mas limpios, pero cuesta seis raices cubicas por frame y color.
]]

export type ColorSpace = "srgb" | "linear" | "oklab"

local color = {}

local function toLinear(c: number): number
	return if c <= 0.04045 then c / 12.92 else ((c + 0.055) / 1.055) ^ 2.4
end

local function toGamma(c: number): number
	return if c <= 0.0031308 then c * 12.92 else 1.055 * c ^ (1 / 2.4) - 0.055
end

local function cbrt(x: number): number
	return if x < 0 then -((-x) ^ (1 / 3)) else x ^ (1 / 3)
end

-- Descompone un Color3 en tres escalares dentro del espacio indicado.
function color.decompose(c: Color3, space: ColorSpace, out: { number }, offset: number)
	if space == "srgb" then
		out[offset + 1] = c.R
		out[offset + 2] = c.G
		out[offset + 3] = c.B
		return
	end

	local r, g, b = toLinear(c.R), toLinear(c.G), toLinear(c.B)

	if space == "linear" then
		out[offset + 1] = r
		out[offset + 2] = g
		out[offset + 3] = b
		return
	end

	-- oklab
	local l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
	local m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
	local s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)

	out[offset + 1] = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
	out[offset + 2] = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
	out[offset + 3] = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
end

-- Reconstruye un Color3 a partir de tres escalares del espacio indicado.
function color.compose(scalars: { number }, offset: number, space: ColorSpace): Color3
	local a, b, c = scalars[offset + 1], scalars[offset + 2], scalars[offset + 3]

	if space == "srgb" then
		return Color3.new(math.clamp(a, 0, 1), math.clamp(b, 0, 1), math.clamp(c, 0, 1))
	end

	local r, g, bl

	if space == "linear" then
		r, g, bl = a, b, c
	else
		-- oklab
		local l_ = a + 0.3963377774 * b + 0.2158037573 * c
		local m_ = a - 0.1055613458 * b - 0.0638541728 * c
		local s_ = a - 0.0894841775 * b - 1.2914855480 * c

		local l, m, s = l_ * l_ * l_, m_ * m_ * m_, s_ * s_ * s_

		r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
		g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
		bl = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
	end

	return Color3.new(
		math.clamp(toGamma(math.max(r, 0)), 0, 1),
		math.clamp(toGamma(math.max(g, 0)), 0, 1),
		math.clamp(toGamma(math.max(bl, 0)), 0, 1)
	)
end

return color
