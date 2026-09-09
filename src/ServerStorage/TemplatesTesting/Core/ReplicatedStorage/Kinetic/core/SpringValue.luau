--!strict
--[[
	Un valor animable: el motor.

	Un SpringValue mantiene *n* integradores independientes, uno por escalar del
	tipo que anima (UDim2 son 4, Color3 son 3). Solo se considera en reposo cuando
	todos lo estan, y solo entonces se da de baja del FrameLoop.

	Integrador (Euler semi-implicito, paso fijo de 2 ms, unidades de milisegundo):

		springForce  = -tension  * 1e-6 * (position - to)
		dampingForce = -friction * 1e-3 * velocity
		velocity    += (springForce + dampingForce) / mass * step
		position    += velocity * step

	El paso fijo con acumulador es lo que hace el movimiento identico a 30 y a 240
	FPS: el sobrante de cada frame se guarda y se consume en el siguiente, en vez de
	repartir el delta en pasos de tamano variable.

	Semi-implicito (la posicion usa la velocidad ya actualizada) porque es estable
	para resortes rigidos sin necesitar pasos diminutos.
]]

local Animatable = require(script.Parent.Parent.animatable)
local AnimationConfig = require(script.Parent.AnimationConfig)
local Completion = require(script.Parent.Parent.util.Completion)
local FrameLoop = require(script.Parent.FrameLoop)
local Signal = require(script.Parent.Parent.util.Signal)
local constants = require(script.Parent.Parent.constants)
local timeGuard = require(script.Parent.Parent.util.timeGuard)
local types = require(script.Parent.Parent.types)

type Animatable = types.Animatable
type SpringConfig = types.SpringConfig

local STEP_MS = constants.STEP_MS

-- Quien conduce el SpringValue en vez del FrameLoop. Un Controller agrupa sus
-- springs para emitir un solo `onChange` por frame en vez de uno por clave.
export type Owner = {
	_springActivated: (self: any, spring: any) -> (),
}

export type StartProps = {
	config: SpringConfig?,
	from: Animatable?,
	immediate: boolean?,
	reset: boolean?,
	delay: number?,
}

--[=[
	@class SpringValue

	Un unico valor animable: la unidad basica del motor.

	Mantiene *n* integradores independientes, uno por escalar del tipo que anima
	(`UDim2` son 4, `Color3` son 3), y solo se considera en reposo cuando todos lo
	estan. Se crea con [Kinetic.value].

	```lua
	local x = Kinetic.value(0, Kinetic.config.stiff)
	x:onChange(function(v) frame.Position = UDim2.fromOffset(v, 0) end)
	x:start(200)
	```
]=]
local SpringValue = {}
SpringValue.__index = SpringValue

export type SpringValue = typeof(setmetatable(
	{} :: {
		key: string,
		typeName: string,
		adapter: types.AnimatableAdapter,
		config: AnimationConfig.ResolvedConfig,

		_arity: number,
		_current: { number },
		_from: { number },
		_to: { number },
		_velocity: { number },
		_done: { boolean },
		_rounded: { number }?,

		-- Sobrante de tiempo por consumir, en ms. Garantiza el paso fijo.
		_accumulator: number,
		-- Solo para el camino por duracion.
		_elapsedMs: number,
		_progress0: number,

		_paused: boolean,
		_idle: boolean,
		-- Marca de "cambio este frame" que lee el Controller para emitir una sola
		-- vez por frame. Existe para no pagar una emision de Signal por clave.
		_dirty: boolean,
		_generation: number,
		_completion: Completion.Completion?,
		_owner: Owner?,

		changed: Signal.Signal,
	},
	SpringValue
))

--== Construccion ==========================================================--

function SpringValue.new(initial: Animatable, config: SpringConfig?, key: string?, owner: Owner?): SpringValue
	local adapter = Animatable.expectAdapterFor(initial, "valor inicial de SpringValue")
	local arity = adapter.arity
	local scalars = adapter.decompose(initial, table.create(arity), 0)

	return setmetatable({
		key = key or "value",
		typeName = adapter.name,
		adapter = adapter,
		config = AnimationConfig.resolve(nil, config),

		_arity = arity,
		_current = scalars,
		_from = table.clone(scalars),
		_to = table.clone(scalars),
		_velocity = table.create(arity, 0),
		_done = table.create(arity, true),
		_rounded = nil,

		_accumulator = 0,
		_elapsedMs = 0,
		_progress0 = 0,

		_paused = false,
		_idle = true,
		_dirty = false,
		_generation = 0,
		_completion = nil,
		_owner = owner,

		changed = Signal.new(),
	}, SpringValue)
end

--== Lectura ===============================================================--

--[=[
	@method get
	@within SpringValue
	@return Animatable

	Valor actual, recompuesto a su tipo original. Si la config define `round`, se
	redondea solo la salida: realimentar valores cuantizados al integrador lo dejaria
	atascado antes de llegar al objetivo.
]=]
function SpringValue.get(self: SpringValue): Animatable
	local round = self.config.round
	if not round or round <= 0 then
		return self.adapter.compose(self._current, 0)
	end

	--[[
		Redondeamos solo la salida, nunca `_current`: realimentar valores
		cuantizados al integrador lo dejaria atascado antes de llegar al objetivo.
	]]
	local rounded = self._rounded
	if not rounded then
		rounded = table.create(self._arity, 0)
		self._rounded = rounded
	end
	for i = 1, self._arity do
		(rounded :: { number })[i] = math.round(self._current[i] / round) * round
	end
	return self.adapter.compose(rounded :: { number }, 0)
end

--[=[
	@method getVelocity
	@within SpringValue
	@param index number? -- Escalar a consultar, 1-indexado. Default `1`.
	@return number

	Velocidad actual en unidades por **segundo**.
]=]
function SpringValue.getVelocity(self: SpringValue, index: number?): number
	return self._velocity[index or 1] * 1000
end

--[=[
	@method isIdle
	@within SpringValue
	@return boolean

	`true` si el valor no se esta moviendo.
]=]
function SpringValue.isIdle(self: SpringValue): boolean
	return self._idle
end

--[=[
	@method onChange
	@within SpringValue
	@param fn (value: Animatable) -> ()
	@return Connection

	Sink: se invoca en cada frame en el que el valor cambia.
]=]
function SpringValue.onChange(self: SpringValue, fn: (value: Animatable) -> ()): Signal.Connection
	return self.changed:connect(fn)
end

--[=[
	@method map
	@within SpringValue
	@param mapper any -- Una funcion, o el arreglo `range`.
	@param output { Animatable }? -- Salidas, si `mapper` es un `range`.
	@param extrapolate Extrapolate? -- Default `"clamp"`.
	@return Interpolation

	Valor derivado de este, sin fisica propia.

	```lua
	local grados = t:map(function(v) return v * 360 end)
	local color  = t:map({ 0, 1 }, { rojo, verde })
	```
]=]
-- Interpolation se requiere aqui dentro, y no arriba, porque no depende de
-- SpringValue: hacerlo al reves crearia un ciclo entre los dos modulos.
function SpringValue.map(self: SpringValue, mapper: any, output: any, extrapolate: any): any
	local Interpolation = require(script.Parent.Interpolation)
	return Interpolation.new(self :: any, mapper, output, extrapolate)
end

--[=[
	@method isPaused
	@within SpringValue
	@return boolean

	`true` si esta congelado por [SpringValue:pause].
]=]
function SpringValue.isPaused(self: SpringValue): boolean
	return self._paused
end

--== Interno ===============================================================--

function SpringValue._activate(self: SpringValue)
	self._idle = false
	if self._paused then
		return
	end
	local owner = self._owner
	if owner then
		owner:_springActivated(self)
	else
		FrameLoop.add(self :: any)
	end
end

function SpringValue._deactivate(self: SpringValue)
	self._idle = true
	if not self._owner then
		FrameLoop.remove(self :: any)
	end
end

function SpringValue._settle(self: SpringValue, finished: boolean)
	local completion = self._completion
	if not completion then
		return
	end
	self._completion = nil
	completion:_settle({
		value = self:get(),
		finished = finished,
		cancelled = not finished,
	})
end

-- Resuelve la velocidad inicial de un escalar, en unidades/ms.
function SpringValue._resolveVelocity(self: SpringValue, index: number, from: number, to: number): number
	local velocity = self.config.velocity

	if type(velocity) == "table" then
		return ((velocity :: { number })[index] or 0) / 1000
	end

	local v = (velocity :: number) / 1000
	if v == 0 then
		return 0
	end
	-- Un escalar orienta la velocidad hacia el destino; un arreglo la da explicita.
	if to > from then
		return v
	elseif to < from then
		return -v
	end
	return 0
end

--== Comandos ==============================================================--

--[=[
	@method start
	@within SpringValue
	@param target Animatable -- Destino. Debe ser del mismo tipo que el valor inicial.
	@param props StartProps?
	@return Completion
	@error "tipo incorrecto" -- Si `target` no es del tipo con el que se creo el valor.

	Arranca una animacion hacia `target`.

	La velocidad actual se **conserva** salvo que se pida `reset` o se declare una
	velocidad explicita en la config. Interrumpir un resorte a mitad de vuelo y
	mandarlo a otro sitio no produce un salto: es la diferencia principal entre un
	resorte y un tween.
]=]
function SpringValue.start(self: SpringValue, target: Animatable, props: StartProps?): Completion.Completion
	props = props or {}
	local p = props :: StartProps

	if typeof(target) ~= self.typeName then
		error(
			string.format(
				"Kinetic: la clave '%s' se anima como %s, pero recibio un %s. "
					.. "El tipo de un valor se fija en su creacion y no puede cambiar.",
				self.key,
				self.typeName,
				typeof(target)
			),
			2
		)
	end

	self._generation += 1
	local generation = self._generation

	if p.delay and p.delay > 0 then
		timeGuard.check("delay", p.delay)
		local completion = Completion.new(function()
			self:stop()
		end)
		self._completion = completion
		task.delay(p.delay, function()
			-- Otra animacion tomo el relevo mientras esperabamos.
			if self._generation ~= generation then
				return
			end
			local delayed = table.clone(p)
			delayed.delay = nil
			self:_startNow(target, delayed, completion)
		end)
		return completion
	end

	return self:_startNow(target, p, nil)
end

function SpringValue._startNow(
	self: SpringValue,
	target: Animatable,
	p: StartProps,
	existing: Completion.Completion?
): Completion.Completion
	local previous = self._completion
	if previous and previous ~= existing then
		self._completion = nil
		previous:_settle({ value = self:get(), finished = false, cancelled = true })
	end

	local config = AnimationConfig.resolve(self.config, p.config)
	if config.duration then
		timeGuard.check("duration", config.duration)
	end
	self.config = config

	local adapter = self.adapter
	local arity = self._arity

	if p.from ~= nil then
		adapter.decompose(p.from, self._from, 0)
		table.move(self._from, 1, arity, 1, self._current)
	elseif p.reset then
		table.move(self._from, 1, arity, 1, self._current)
	else
		table.move(self._current, 1, arity, 1, self._from)
	end

	adapter.decompose(target, self._to, 0)

	--[[
		La velocidad solo se pisa si el usuario la declara o pide `reset`.
		En cualquier otro caso se hereda, que es lo que evita el salto al
		redirigir un resorte en vuelo.
	]]
	local explicitVelocity = config.velocity ~= 0
	if p.reset or p.from ~= nil or explicitVelocity then
		for i = 1, arity do
			self._velocity[i] = self:_resolveVelocity(i, self._from[i], self._to[i])
		end
	end

	local immediate = p.immediate or adapter.discrete or false

	self._accumulator = 0
	self._elapsedMs = 0
	self._progress0 = math.clamp(config.progress, 0, 1)

	local completion = existing or Completion.new(function()
		self:stop()
	end)
	self._completion = completion

	if immediate then
		for i = 1, arity do
			self._current[i] = self._to[i]
			self._velocity[i] = 0
			self._done[i] = true
		end
		self:_deactivate()
		self.changed:fire(self:get())
		self:_settle(true)
		return completion
	end

	local anyPending = false
	for i = 1, arity do
		local atRest = self._current[i] == self._to[i] and self._velocity[i] == 0
		self._done[i] = atRest
		if not atRest then
			anyPending = true
		end
	end

	if not anyPending then
		self:_deactivate()
		self:_settle(true)
		return completion
	end

	self:_activate()
	return completion
end

--[=[
	@method retarget
	@within SpringValue
	@param value Animatable

	Mueve el objetivo sin reiniciar la animacion ni tocar la velocidad. Ignora
	valores de otro tipo en vez de lanzar.

	Es el camino rapido que necesita [Kinetic.trail]: cada elemento persigue la
	posicion del anterior, que cambia en cada frame. Pasar por [SpringValue:start]
	ahi costaria resolver la config y crear una [Completion] sesenta veces por
	segundo y por elemento.
]=]
function SpringValue.retarget(self: SpringValue, value: Animatable)
	if typeof(value) ~= self.typeName then
		return
	end

	self.adapter.decompose(value, self._to, 0)

	local wasIdle = self._idle
	for i = 1, self._arity do
		if self._current[i] ~= self._to[i] then
			self._done[i] = false
		end
	end

	if wasIdle then
		for i = 1, self._arity do
			if not self._done[i] then
				table.move(self._current, 1, self._arity, 1, self._from)
				self:_activate()
				break
			end
		end
	end
end

--[=[
	@method set
	@within SpringValue
	@param value Animatable

	Salta al valor sin animar y notifica el cambio. Cancela cualquier animacion en
	vuelo.
]=]
function SpringValue.set(self: SpringValue, value: Animatable)
	if typeof(value) ~= self.typeName then
		error(
			string.format(
				"Kinetic: la clave '%s' se anima como %s, pero recibio un %s.",
				self.key,
				self.typeName,
				typeof(value)
			),
			2
		)
	end

	self._generation += 1
	local adapter = self.adapter
	adapter.decompose(value, self._current, 0)
	table.move(self._current, 1, self._arity, 1, self._from)
	table.move(self._current, 1, self._arity, 1, self._to)

	for i = 1, self._arity do
		self._velocity[i] = 0
		self._done[i] = true
	end

	self._accumulator = 0
	self:_deactivate()
	self.changed:fire(self:get())
	self:_settle(false)
end

--[=[
	@method stop
	@within SpringValue

	Detiene el movimiento donde este, conservando el valor actual. La [Completion]
	en vuelo se resuelve como cancelada.
]=]
function SpringValue.stop(self: SpringValue)
	self._generation += 1

	if self._idle then
		self:_settle(false)
		return
	end

	table.move(self._current, 1, self._arity, 1, self._to)
	for i = 1, self._arity do
		self._velocity[i] = 0
		self._done[i] = true
	end

	self._accumulator = 0
	self:_deactivate()
	self:_settle(false)
end

--[=[
	@method pause
	@within SpringValue

	Congela sin perder velocidad. [SpringValue:resume] retoma exactamente donde se
	quedo, a diferencia de detener y volver a arrancar.
]=]
function SpringValue.pause(self: SpringValue)
	if self._paused then
		return
	end
	self._paused = true
	if not self._owner then
		FrameLoop.remove(self :: any)
	end
end

--[=[
	@method resume
	@within SpringValue

	Reanuda tras [SpringValue:pause], conservando la velocidad que tenia.
]=]
function SpringValue.resume(self: SpringValue)
	if not self._paused then
		return
	end
	self._paused = false
	if not self._idle then
		self:_activate()
	end
end

--== Integracion ===========================================================--

-- Llamado por el FrameLoop (o por el Controller que lo posee). `dt` en segundos.
-- Devuelve `false` cuando ya no hay nada que avanzar.
function SpringValue.advance(self: SpringValue, dt: number): boolean
	if self._idle or self._paused then
		return false
	end

	local config = self.config
	local changed = if config.duration then self:_advanceDuration(dt) else self:_advanceSpring(dt)

	if changed then
		self._dirty = true
		-- El Controller lee `_dirty`; la senal solo se emite si alguien escucha.
		if self.changed:hasListeners() then
			self.changed:fire(self:get())
		end
	end

	if self._idle then
		--[[
			`task.spawn` corre de forma sincrona, asi que los callbacks de la
			Completion (un `onRest`, el siguiente paso de una cadena) se ejecutan
			dentro de esta llamada y pueden arrancar otra animacion. Releemos el
			estado en vez de devolver `false` a ciegas: si no, quien nos conduce
			daria de baja un resorte que acaba de volver a arrancar.
		]]
		self:_settle(true)
		return not self._idle
	end
	return true
end

function SpringValue._advanceDuration(self: SpringValue, dt: number): boolean
	local config = self.config
	local durationMs = (config.duration :: number) * 1000
	local dtMs = dt * 1000

	local progress
	if durationMs <= 0 then
		progress = 1
	else
		self._elapsedMs += dtMs
		progress = math.clamp(self._progress0 + self._elapsedMs / durationMs, 0, 1)
	end

	local eased = config.easing(progress)
	local arity = self._arity
	local changed = false

	for i = 1, arity do
		local previous = self._current[i]
		local position = self._from[i] + eased * (self._to[i] - self._from[i])
		self._velocity[i] = if dtMs > 0 then (position - previous) / dtMs else 0
		if position ~= previous then
			changed = true
		end
		self._current[i] = position
	end

	if progress >= 1 then
		for i = 1, arity do
			self._done[i] = true
			self._velocity[i] = 0
		end
		self:_deactivate()
	end

	return changed
end

function SpringValue._advanceSpring(self: SpringValue, dt: number): boolean
	local config = self.config

	-- Un resorte sin tension no tiene fuerza que lo mueva: nunca llegaria.
	if config.tension <= 0 then
		for i = 1, self._arity do
			self._done[i] = true
			self._velocity[i] = 0
		end
		self:_deactivate()
		return false
	end

	--[[
		Acumulador de paso fijo: el sobrante que no llena un paso completo se
		guarda para el frame siguiente. Sin esto, el tamano de paso dependeria
		del framerate y la animacion se sentiria distinta en cada maquina.
	]]
	self._accumulator += dt * 1000
	local steps = math.floor(self._accumulator / STEP_MS)
	if steps <= 0 then
		return false
	end
	self._accumulator -= steps * STEP_MS

	local mass = config.mass
	local tension = config.tension * 1e-6
	local friction = config.friction * 1e-3
	local bounceFactor = if config.clamp then 0 else config.bounce
	local canBounce = bounceFactor ~= nil

	local changed = false
	local anyActive = false

	for i = 1, self._arity do
		if self._done[i] then
			continue
		end

		local position = self._current[i]
		local velocity = self._velocity[i]
		local from = self._from[i]
		local to = self._to[i]

		local precision = config.precision or (if from == to then 0.005 else math.min(1, math.abs(to - from) * 0.001))
		precision = math.max(constants.MIN_PRECISION, precision)

		local restVelocity = if config.restVelocity then (config.restVelocity :: number) / 1000 else precision / 10
		local isGrowing = if from == to then velocity > 0 else from < to

		local finished = false

		for _ = 1, steps do
			-- En reposo hacen falta las dos cosas: ir lento y estar cerca.
			if math.abs(velocity) <= restVelocity and math.abs(to - position) <= precision then
				finished = true
				break
			end

			if canBounce then
				local isBouncing = position == to or (position > to) == isGrowing
				if isBouncing then
					velocity = -velocity * (bounceFactor :: number)
					position = to
				end
			end

			local acceleration = (-tension * (position - to) - friction * velocity) / mass
			velocity += acceleration * STEP_MS
			position += velocity * STEP_MS
		end

		if finished then
			position = to
			velocity = 0
			self._done[i] = true
		else
			anyActive = true
		end

		if position ~= self._current[i] then
			changed = true
		end
		self._current[i] = position
		self._velocity[i] = velocity
	end

	if not anyActive then
		self:_deactivate()
	end

	return changed
end

--== Ciclo de vida =========================================================--

--[=[
	@method destroy
	@within SpringValue

	Libera el valor: lo da de baja del frame loop, resuelve su [Completion] como
	cancelada y desconecta sus listeners.
]=]
function SpringValue.destroy(self: SpringValue)
	self._generation += 1
	self:_deactivate()
	self:_settle(false)
	self.changed:disconnectAll()
end

return SpringValue
