--!strict
--[[
	Valores derivados.

	Una interpolacion no se registra en el FrameLoop: no tiene fisica propia, se
	recalcula cuando su fuente cambia. Eso permite encadenarlas sin coste por frame
	y usar un solo resorte para mover diez propiedades derivadas de el.

	Dos formas:

		source:map(function(v) return v * 360 end)
		source:map({ 0, 0.5, 1 }, { rojo, amarillo, verde }, "clamp")

	La segunda interpola por tramos: busca el segmento de `range` donde cae la
	entrada y mezcla los dos valores de `output` correspondientes. `output` admite
	cualquier tipo animable, no solo numeros.
]]

local Animatable = require(script.Parent.Parent.animatable)
local Signal = require(script.Parent.Parent.util.Signal)
local types = require(script.Parent.Parent.types)

type AnimatableValue = types.Animatable
type Extrapolate = types.Extrapolate

-- Fuente valida: cualquier cosa con `get()` y una senal `changed`.
export type Source = {
	get: (self: any) -> any,
	changed: Signal.Signal,
}

--[=[
	@class Interpolation

	Valor derivado de otro, sin fisica propia.

	Una interpolacion no se registra en el frame loop: se recalcula cuando su fuente
	cambia. Eso permite encadenarlas sin coste por frame y usar un solo resorte para
	mover diez propiedades derivadas de el.

	Se crea con [SpringValue:map], [Controller:map] o [Kinetic.interpolate].

	```lua
	local t = Kinetic.value(0)
	local grados = t:map(function(v) return v * 360 end)
	local color  = t:map({ 0, 0.5, 1 }, { rojo, amarillo, verde })
	```
]=]
local Interpolation = {}
Interpolation.__index = Interpolation

export type Interpolation = typeof(setmetatable(
	{} :: {
		_source: Source,
		_compute: (input: any) -> any,
		_connection: Signal.Connection?,

		changed: Signal.Signal,
	},
	Interpolation
))

-- Mezcla dos valores animables del mismo tipo. `t` no se limita a 0..1 para
-- que el modo `extend` pueda extrapolar fuera del rango.
local function lerpAnimatable(a: AnimatableValue, b: AnimatableValue, t: number): AnimatableValue
	local adapter = Animatable.expectAdapterFor(a, "salida de interpolacion")

	if adapter.discrete then
		return if t < 0.5 then a else b
	end

	local arity = adapter.arity
	local from = adapter.decompose(a, table.create(arity), 0)
	local to = adapter.decompose(b, table.create(arity), 0)

	for i = 1, arity do
		from[i] += (to[i] - from[i]) * t
	end
	return adapter.compose(from, 0)
end

local function buildRangeCompute(
	range: { number },
	output: { AnimatableValue },
	extrapolate: Extrapolate
): (input: any) -> any
	assert(#range >= 2, "Kinetic: `range` necesita al menos dos puntos")
	assert(#range == #output, "Kinetic: `range` y `output` deben tener la misma longitud")

	return function(input: any): any
		if type(input) ~= "number" then
			error("Kinetic: interpolar por rango necesita una fuente numerica, no " .. typeof(input), 2)
		end

		if extrapolate == "identity" and (input < range[1] or input > range[#range]) then
			return input
		end

		-- Segmento en el que cae la entrada; los extremos se encargan del fuera de rango.
		local index = 1
		while index < #range - 1 and input >= range[index + 1] do
			index += 1
		end

		local lo, hi = range[index], range[index + 1]
		local span = hi - lo
		local t = if span == 0 then 0 else (input - lo) / span

		if extrapolate == "clamp" then
			t = math.clamp(t, 0, 1)
		end

		return lerpAnimatable(output[index], output[index + 1], t)
	end
end

--[=[
	@function new
	@within Interpolation
	@param source Interpolation -- Cualquier cosa con `get()` y una senal `changed`.
	@param mapper any -- Una funcion, o el arreglo `range`.
	@param output { Animatable }? -- Salidas, obligatorio si `mapper` es un `range`.
	@param extrapolate Extrapolate? -- Default `"clamp"`.
	@return Interpolation

	La forma por rango interpola por tramos: busca el segmento de `range` donde cae
	la entrada y mezcla los dos valores de `output` correspondientes. `output` admite
	cualquier tipo animable, no solo numeros.
]=]
function Interpolation.new(
	source: Source,
	mapper: any,
	output: { AnimatableValue }?,
	extrapolate: Extrapolate?
): Interpolation
	local compute
	if type(mapper) == "function" then
		compute = mapper
	else
		assert(output ~= nil, "Kinetic: interpolar por rango necesita un arreglo `output`")
		compute = buildRangeCompute(mapper :: { number }, output :: { AnimatableValue }, extrapolate or "clamp")
	end

	local self = setmetatable({
		_source = source,
		_compute = compute,
		_connection = nil,

		changed = Signal.new(),
	}, Interpolation)

	--[[
		Nos enganchamos a la fuente una sola vez y reemitimos. No cacheamos el
		resultado: recalcular es mas barato que invalidar, y `get` puede llamarse
		en cualquier momento sin que la fuente haya emitido.
	]]
	self._connection = source.changed:connect(function()
		if self.changed:hasListeners() then
			self.changed:fire(self:get())
		end
	end)

	return self
end

--[=[
	@method get
	@within Interpolation
	@return any

	Valor derivado actual. Se recalcula en cada llamada: recalcular es mas barato que
	invalidar una cache.
]=]
function Interpolation.get(self: Interpolation): any
	return self._compute(self._source:get())
end

--[=[
	@method map
	@within Interpolation
	@param mapper any
	@param output { Animatable }?
	@param extrapolate Extrapolate?
	@return Interpolation

	Encadena otra interpolacion sobre esta.
]=]
function Interpolation.map(
	self: Interpolation,
	mapper: any,
	output: { AnimatableValue }?,
	extrapolate: Extrapolate?
): Interpolation
	return Interpolation.new(self :: any, mapper, output, extrapolate)
end

--[=[
	@method onChange
	@within Interpolation
	@param fn (value: any) -> ()
	@return Connection

	Sink: se invoca cuando la fuente cambia.
]=]
function Interpolation.onChange(self: Interpolation, fn: (value: any) -> ()): Signal.Connection
	local connection = self.changed:connect(fn)
	return connection
end

--[=[
	@method destroy
	@within Interpolation

	Se desengancha de la fuente y desconecta sus listeners.
]=]
function Interpolation.destroy(self: Interpolation)
	if self._connection then
		(self._connection :: Signal.Connection):disconnect()
		self._connection = nil
	end
	self.changed:disconnectAll()
end

return Interpolation
