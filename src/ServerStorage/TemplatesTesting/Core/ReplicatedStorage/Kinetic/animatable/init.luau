--!strict
--[[
	Registro de tipos animables.

	El motor solo sabe integrar numeros. Este registro es el unico punto donde la
	biblioteca sabe que existen UDim2, Color3 o Vector3; anadir un tipo nuevo es
	registrar un adaptador, sin tocar el resto.
]]

local adapters = require(script.adapters)
local color = require(script.color)
local types = require(script.Parent.types)

type AnimatableAdapter = types.AnimatableAdapter

local byName: { [string]: AnimatableAdapter } = {}

for _, adapter in adapters.list do
	byName[adapter.name] = adapter
end

local Animatable = {}

Animatable.setColorSpace = adapters.setColorSpace
Animatable.getColorSpace = adapters.getColorSpace

export type ColorSpace = color.ColorSpace

-- Registra un adaptador propio. Sobrescribe el existente si comparte nombre.
function Animatable.register(adapter: AnimatableAdapter)
	assert(type(adapter.name) == "string", "el adaptador necesita un nombre")
	assert(type(adapter.arity) == "number" and adapter.arity > 0, "el adaptador necesita una aridad positiva")
	byName[adapter.name] = adapter
end

-- Devuelve el adaptador de un valor, o `nil` si el tipo no es animable.
function Animatable.adapterFor(value: any): AnimatableAdapter?
	return byName[typeof(value)]
end

-- Igual que `adapterFor`, pero falla con un mensaje util.
function Animatable.expectAdapterFor(value: any, context: string?): AnimatableAdapter
	local adapter = byName[typeof(value)]
	if not adapter then
		error(
			string.format(
				"Kinetic no sabe animar valores de tipo '%s'%s. Registra un adaptador con Kinetic.registerType.",
				typeof(value),
				if context then " (" .. context .. ")" else ""
			),
			3
		)
	end
	return adapter
end

-- `true` si Kinetic puede animar este valor.
function Animatable.isAnimatable(value: any): boolean
	return byName[typeof(value)] ~= nil
end

-- Atajo: aplana un valor en una tabla nueva. Para el hot path, usa el adaptador directo.
function Animatable.decompose(value: any): { number }
	local adapter = Animatable.expectAdapterFor(value)
	return adapter.decompose(value, table.create(adapter.arity), 0)
end

-- Atajo: reconstruye un valor del tipo indicado.
function Animatable.compose(typeName: string, scalars: { number }, offset: number?): any
	local adapter = byName[typeName]
	if not adapter then
		error(string.format("Kinetic no tiene un adaptador registrado para '%s'", typeName), 2)
	end
	return adapter.compose(scalars, offset or 0)
end

return Animatable
