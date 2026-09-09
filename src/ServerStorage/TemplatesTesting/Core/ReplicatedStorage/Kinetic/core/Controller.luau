--!strict
--[[
	Grupo de valores nombrados con cola de props.

	El Controller es lo que el usuario manipula. Su trabajo:
	  - Poseer un SpringValue por clave y crearlos perezosamente.
	  - Interpretar las props (`to`, `from`, `loop`, `delay`, `reset`, ...).
	  - Ejecutar colas asincronas: `to` puede ser un arreglo de pasos.
	  - Emitir `onChange` una sola vez por frame con todos los valores, no una por
	    clave: escribir cuatro propiedades de un Frame debe costar un evento, no cuatro.

	Por eso el Controller, y no cada SpringValue, es lo que se registra en el
	FrameLoop: conduce sus propios springs y agrupa el resultado.
]]

local Completion = require(script.Parent.Parent.util.Completion)
local FrameLoop = require(script.Parent.FrameLoop)
local Signal = require(script.Parent.Parent.util.Signal)
local SpringValue = require(script.Parent.SpringValue)
local timeGuard = require(script.Parent.Parent.util.timeGuard)
local types = require(script.Parent.Parent.types)

type Animatable = types.Animatable
type SpringProps = types.SpringProps
type ValueMap = types.ValueMap

-- Claves de `SpringProps` que son opciones, no destinos.
local RESERVED: { [string]: true } = {
	to = true,
	from = true,
	delay = true,
	loop = true,
	reset = true,
	reverse = true,
	immediate = true,
	cancel = true,
	pause = true,
	config = true,
	onStart = true,
	onChange = true,
	onRest = true,
	onPause = true,
	onResume = true,
}

--[[
	Opciones declaradas al construir que siguen valiendo para todo `start` posterior.

	El resto (`from`, `to`, `reset`, `reverse`, `delay`, `immediate`, `cancel`,
	`loop`, `pause`) son por llamada. `from` en particular **no** puede persistir:
	si lo hiciera, cada `start` volveria a saltar al valor inicial antes de animar,
	y una cadena de pasos se reiniciaria en cada paso en vez de encadenarse.
]]
local PERSISTENT_OPTIONS: { [string]: true } = {
	config = true,
	onStart = true,
	onChange = true,
	onRest = true,
	onPause = true,
	onResume = true,
}

-- Tope de reinicios de `loop` que terminan en el mismo frame antes de cortar.
-- Sin esto, `loop = true` sobre una animacion que ya esta en su destino gira
-- para siempre dentro de un frame y congela el juego.
local MAX_INSTANT_LOOPS = 2

--[=[
	@class Controller

	Grupo de valores nombrados. Es la pieza que se manipula en el uso normal: se crea
	con [Kinetic.controller] o, enlazado a una instancia, con [Kinetic.animate].

	Emite [Controller:onChange] **una sola vez por frame** con todos los valores, no
	una por clave: escribir cuatro propiedades de un `Frame` cuesta un evento, no
	cuatro. Por eso es el Controller, y no cada [SpringValue], lo que se registra en
	el frame loop.

	```lua
	local ctrl = Kinetic.controller({ from = { x = 0, tint = Color3.new() } })
	ctrl:onChange(function(v)
		frame.Position = UDim2.fromOffset(v.x, 0)
		frame.BackgroundColor3 = v.tint
	end)
	ctrl:start({ x = 100, tint = Color3.new(0, 1, 0) })
	```
]=]
local Controller = {}
Controller.__index = Controller

export type Controller = typeof(setmetatable(
	{} :: {
		_springs: { [string]: SpringValue.SpringValue },
		_active: { [SpringValue.SpringValue]: true },
		-- Buffer reutilizado para recorrer `_active` sin iterar la tabla en vivo.
		_buffer: { SpringValue.SpringValue },
		_queued: SpringProps?,
		_snapshot: ValueMap,
		_defaults: SpringProps,
		_generation: number,
		_destroyed: boolean,
		_paused: boolean,

		changed: Signal.Signal,
	},
	Controller
))

--== Utilidades de props ===================================================--

-- Separa destinos de opciones. `{ x = 1, config = c }` -> `{ x = 1 }`, `{ config = c }`.
function Controller.splitProps(props: SpringProps): (ValueMap, SpringProps)
	local targets: ValueMap = {}
	local options: SpringProps = {}

	for key, value in props :: any do
		if RESERVED[key] then
			options[key] = value
		else
			targets[key] = value
		end
	end

	local to = props.to
	if typeof(to) == "table" and (to :: any)[1] == nil then
		for key, value in to :: any do
			targets[key] = value
		end
	end

	return targets, options
end

-- Varias props aceptan un valor o una funcion por clave (`config`, `delay`, ...).
local function resolvePerKey(value: any, key: string): any
	if type(value) == "function" then
		return value(key)
	end
	return value
end

--== Construccion ==========================================================--

function Controller.new(props: SpringProps?): Controller
	local self = setmetatable({
		_springs = {},
		_active = {},
		_buffer = {},
		_queued = nil,
		_snapshot = {},
		_defaults = {},
		_generation = 0,
		_destroyed = false,
		_paused = false,

		changed = Signal.new(),
	}, Controller)

	if props then
		local targets, options = Controller.splitProps(props)

		for key, value in options :: any do
			if PERSISTENT_OPTIONS[key] then
				(self._defaults :: any)[key] = value
			end
		end

		if options.from then
			for key, value in options.from :: ValueMap do
				self:_ensureSpring(key, value, options)
			end
		end
		for key, value in targets do
			self:_ensureSpring(key, (options.from and (options.from :: ValueMap)[key]) or value, options)
		end

		self:_refreshSnapshot()

		if next(targets) ~= nil or typeof(options.to) == "table" then
			self:start(props)
		end
	end

	return self
end

function Controller._ensureSpring(
	self: Controller,
	key: string,
	initial: Animatable,
	options: SpringProps?
): SpringValue.SpringValue
	local spring = self._springs[key]
	if spring then
		return spring
	end

	local config = if options then resolvePerKey(options.config, key) else nil
	spring = SpringValue.new(initial, config, key, self :: any)
	self._springs[key] = spring
	return spring
end

--== FrameLoop =============================================================--

-- Llamado por un SpringValue propio cuando arranca. Ver `SpringValue.Owner`.
function Controller._springActivated(self: Controller, spring: SpringValue.SpringValue)
	if self._destroyed or self._paused then
		return
	end
	self._active[spring] = true
	FrameLoop.add(self :: any)
end

-- Llamado por el FrameLoop. `dt` en segundos.
function Controller.advance(self: Controller, dt: number): boolean
	local dirty = false

	--[[
		Recorremos una copia: avanzar un resorte puede disparar callbacks sincronos
		que arranquen otras claves, y anadir entradas a una tabla mientras se itera
		con `next` es comportamiento indefinido en Lua.
	]]
	local buffer = self._buffer
	local count = 0
	for spring in self._active do
		count += 1
		buffer[count] = spring
	end

	for i = 1, count do
		local spring = buffer[i]
		buffer[i] = nil :: any

		-- Pudo darse de baja en la cascada de otro resorte de este mismo frame.
		if not self._active[spring] then
			continue
		end

		local stillActive = spring:advance(dt)
		if spring._dirty then
			spring._dirty = false
			dirty = true
		end
		if not stillActive then
			self._active[spring] = nil
		end
	end

	if dirty then
		self:_emit()
	end

	return next(self._active) ~= nil
end

function Controller._refreshSnapshot(self: Controller)
	local snapshot = self._snapshot
	for key, spring in self._springs do
		snapshot[key] = spring:get()
	end
end

function Controller._emit(self: Controller)
	self:_refreshSnapshot()
	self.changed:fire(self._snapshot)
end

--== Comandos ==============================================================--

--[=[
	@method start
	@within Controller
	@param props SpringProps? -- Si se omite, usa lo encolado por [Controller:update].
	@return Completion

	Arranca una animacion. La [Completion] resuelve cuando todas las claves
	implicadas llegan al reposo.

	Si `to` es un arreglo, se ejecuta como cadena asincrona y la [Completion]
	resuelve al terminar el ultimo paso:

	```lua
	ctrl:start({ to = { { x = 50 }, { x = 10 }, { x = 80 } } })
	```

	Si `to` es una funcion, se ejecuta como script asincrono. Recibe `next`, que
	arranca un paso y espera a que termine, y `cancel`, que aborta:

	```lua
	ctrl:start({ to = function(next)
		next({ x = 50 })
		if yaNoHaceFalta then return end
		next({ x = 0, config = Kinetic.config.slow })
	end })
	```

	Un `start` posterior aborta el script en el siguiente `next`, para que no siga
	dando ordenes una animacion que ya fue reemplazada.

	`config` y los callbacks declarados al construir el controller siguen valiendo
	aqui. El resto de props (`from`, `reset`, `delay`, `immediate`, ...) son por
	llamada.
]=]
function Controller.start(self: Controller, props: SpringProps?): Completion.Completion
	if self._destroyed then
		return Completion.resolved({ value = 0, finished = false, cancelled = true })
	end

	local resolved: SpringProps = props or self._queued or {}
	self._queued = nil

	self._generation += 1
	local generation = self._generation

	local _, options = Controller.splitProps(resolved)
	local to = options.to

	-- `to` como arreglo: cadena de pasos, uno tras otro.
	if typeof(to) == "table" and (to :: any)[1] ~= nil then
		return self:_startChain(to :: { ValueMap }, resolved, generation)
	end

	-- `to` como funcion: script asincrono que decide sus pasos sobre la marcha.
	if typeof(to) == "function" then
		return self:_startScript(to :: any, resolved, generation)
	end

	return self:_startStep(resolved, generation)
end

--[[
	Centinela para abortar un script asincrono desde dentro de `next`.

	Es una tabla unica, no un string: asi no puede confundirse con un error real
	del script del usuario, que si debe propagarse.
]]
local ABORT = newproxy(false)

function Controller._startScript(
	self: Controller,
	script: (next: (SpringProps) -> types.AnimationResult, cancel: () -> ()) -> (),
	base: SpringProps,
	generation: number
): Completion.Completion
	local completion = Completion.new(function()
		self:stop()
	end)

	task.spawn(function()
		local lastResult: types.AnimationResult? = nil
		local aborted = false

		local function isStale(): boolean
			return self._generation ~= generation or self._destroyed
		end

		local function next(stepProps: SpringProps): types.AnimationResult
			--[[
				Si otro `start` tomo el relevo, cortamos aqui en vez de dejar que el
				script siga mandando pasos a un controller que ya se movio a otra cosa.
			]]
			if isStale() then
				aborted = true
				error(ABORT)
			end

			local props: SpringProps = table.clone(base) :: any
			props.to = nil
			for key, value in stepProps :: any do
				(props :: any)[key] = value
			end

			lastResult = self:_startStep(props, generation):await()
			return lastResult :: types.AnimationResult
		end

		local function cancel()
			aborted = true
			self:stop()
		end

		local ok, err = pcall(script, next, cancel)

		if not ok and err ~= ABORT then
			-- Un error real del script del usuario no debe tragarse en silencio.
			completion:_settle({ value = 0, finished = false, cancelled = true })
			task.spawn(error, err)
			return
		end

		if isStale() or aborted then
			completion:_settle({ value = 0, finished = false, cancelled = true })
			return
		end

		completion:_settle(lastResult or { value = 0, finished = true, cancelled = false })
	end)

	return completion
end

function Controller._startChain(
	self: Controller,
	steps: { ValueMap },
	base: SpringProps,
	generation: number
): Completion.Completion
	local completion = Completion.new(function()
		self:stop()
	end)

	task.spawn(function()
		local lastResult
		for _, step in steps do
			if self._generation ~= generation or self._destroyed then
				completion:_settle({ value = 0, finished = false, cancelled = true })
				return
			end

			local stepProps: SpringProps = table.clone(base) :: any
			stepProps.to = step
			-- Un paso de la cadena no vuelve a lanzar la cadena entera.
			lastResult = self:_startStep(stepProps, generation):await()
		end

		if self._generation == generation then
			completion:_settle(lastResult or { value = 0, finished = true, cancelled = false })
		end
	end)

	return completion
end

function Controller._startStep(self: Controller, props: SpringProps, generation: number): Completion.Completion
	local targets, options = Controller.splitProps(props)
	local defaults = self._defaults

	local function option(name: string): any
		local value = (options :: any)[name]
		if value == nil then
			value = (defaults :: any)[name]
		end
		return value
	end

	if option("cancel") then
		local cancel = option("cancel")
		if cancel == true then
			self:stop()
		else
			self:stop(cancel :: any)
		end
	end

	local from = option("from") :: ValueMap?
	local reverse = option("reverse")

	if reverse and from then
		local swapped: ValueMap = {}
		for key, value in from do
			swapped[key] = targets[key] ~= nil and targets[key] or value
		end
		for key, value in from do
			targets[key] = value
		end
		from = swapped
	end

	--[[
		Sin destinos no hay nada que animar. Puede pasar legitimamente: un `start`
		que solo trae `cancel` o `pause`.
	]]
	if next(targets) == nil then
		return Completion.resolved({ value = 0, finished = true, cancelled = false })
	end

	local onStart = option("onStart")
	local onRest = option("onRest")
	local onChangeProp = option("onChange")

	local pending = 0
	local anyCancelled = false
	local aggregate = Completion.new(function()
		self:stop()
	end)

	local changeConnection
	if onChangeProp then
		changeConnection = self.changed:connect(function(values)
			(onChangeProp :: any)(values)
		end)
	end

	local function finishOne(result: types.AnimationResult)
		if result.cancelled then
			anyCancelled = true
		end
		pending -= 1
		if pending > 0 then
			return
		end
		if changeConnection then
			changeConnection:disconnect()
		end
		aggregate:_settle({
			value = result.value,
			finished = not anyCancelled,
			cancelled = anyCancelled,
		})
	end

	local starts: { () -> () } = {}

	for key, target in targets do
		local initial = (from and from[key]) or target
		local spring = self:_ensureSpring(key, initial, options)

		local delay = resolvePerKey(option("delay"), key)
		if delay then
			timeGuard.check("delay", delay)
		end

		local startProps: SpringValue.StartProps = {
			config = resolvePerKey(option("config"), key),
			from = from and from[key] or nil,
			immediate = resolvePerKey(option("immediate"), key) or nil,
			reset = option("reset") or nil,
			delay = delay,
		}

		pending += 1
		table.insert(starts, function()
			if onStart then
				(onStart :: any)({ value = spring:get(), finished = false, cancelled = false }, key)
			end
			spring:start(target, startProps):andThen(function(result)
				if onRest then
					(onRest :: any)(result, key)
				end
				finishOne(result)
			end)
		end)
	end

	--[[
		Arrancamos despues de haber contado todas las claves. Si arrancasemos dentro
		del bucle, una animacion inmediata podria resolver con `pending == 1` y
		cerrar el agregado antes de registrar el resto.
	]]
	for _, run in starts do
		run()
	end

	self:_refreshSnapshot()
	self:_handleLoop(props, generation, aggregate)

	return aggregate
end

function Controller._handleLoop(
	self: Controller,
	props: SpringProps,
	generation: number,
	completion: Completion.Completion
)
	local loop = props.loop
	if loop == nil or loop == false then
		return
	end

	local remaining = if type(loop) == "number" then loop else math.huge
	local instantLoops = 0

	local function scheduleNext()
		completion:andThen(function(result)
			if self._generation ~= generation or self._destroyed or result.cancelled then
				return
			end

			local keepGoing = if type(loop) == "function" then (loop :: any)() else remaining > 0
			if not keepGoing then
				return
			end
			remaining -= 1

			local nextProps: SpringProps = table.clone(props) :: any
			if type(loop) == "table" then
				for key, value in loop :: any do
					(nextProps :: any)[key] = value
				end
			end
			nextProps.loop = nil

			local startedAt = os.clock()
			self._generation += 1
			local nextGeneration = self._generation
			local nextCompletion = self:_startStep(nextProps, nextGeneration)

			if nextCompletion:isSettled() and os.clock() - startedAt < 0.001 then
				instantLoops += 1
				if instantLoops >= MAX_INSTANT_LOOPS then
					warn(
						"[Kinetic] `loop` se detuvo: la animacion termina sin moverse. "
							.. "Un loop necesita volver al punto de partida, por ejemplo "
							.. "`loop = { reset = true }`."
					)
					return
				end
			else
				instantLoops = 0
			end

			self:_handleLoop(props, nextGeneration, nextCompletion)
		end)
	end

	scheduleNext()
end

--[=[
	@method update
	@within Controller
	@param props SpringProps

	Encola props sin arrancar. Se aplican en el siguiente [Controller:start] llamado
	sin argumentos.
]=]
function Controller.update(self: Controller, props: SpringProps)
	self._queued = props
end

--[=[
	@method stop
	@within Controller
	@param keys (string | { string })? -- Si se omite, detiene todas.

	Detiene las claves indicadas donde esten. Las [Completion] en vuelo se resuelven
	como canceladas.
]=]
function Controller.stop(self: Controller, keys: (string | { string })?)
	self._generation += 1

	if keys == nil then
		for _, spring in self._springs do
			spring:stop()
		end
		table.clear(self._active)
		return
	end

	local list = if type(keys) == "string" then { keys } else keys :: { string }
	for _, key in list do
		local spring = self._springs[key]
		if spring then
			spring:stop()
			self._active[spring] = nil
		end
	end
end

--[=[
	@method set
	@within Controller
	@param values ValueMap

	Salta a los valores indicados sin animar, cancelando lo que hubiera en vuelo.
]=]
function Controller.set(self: Controller, values: ValueMap)
	self._generation += 1
	for key, value in values do
		local spring = self:_ensureSpring(key, value)
		spring:set(value)
		self._active[spring] = nil
	end
	self:_emit()
end

--[=[
	@method pause
	@within Controller

	Congela todas las claves sin perder velocidad.
]=]
function Controller.pause(self: Controller)
	if self._paused then
		return
	end
	self._paused = true
	for _, spring in self._springs do
		spring:pause()
	end
	FrameLoop.remove(self :: any)

	local onPause = self._defaults.onPause
	if onPause then
		(onPause :: any)({ value = 0, finished = false, cancelled = false }, "")
	end
end

--[=[
	@method resume
	@within Controller

	Reanuda tras [Controller:pause], conservando las velocidades.
]=]
function Controller.resume(self: Controller)
	if not self._paused then
		return
	end
	self._paused = false

	local anyActive = false
	for _, spring in self._springs do
		spring:resume()
		if not spring:isIdle() then
			self._active[spring] = true
			anyActive = true
		end
	end
	if anyActive then
		FrameLoop.add(self :: any)
	end

	local onResume = self._defaults.onResume
	if onResume then
		(onResume :: any)({ value = 0, finished = false, cancelled = false }, "")
	end
end

--[=[
	@method get
	@within Controller
	@return ValueMap

	Snapshot de los valores actuales.

	:::caution
	La tabla devuelta es de solo lectura y **se reutiliza entre frames**. Copiala si
	necesitas conservarla mas alla del momento de la llamada.
	:::
]=]
function Controller.get(self: Controller): ValueMap
	self:_refreshSnapshot()
	return self._snapshot
end

--[=[
	@method velocity
	@within Controller
	@param key string
	@param index number? -- Escalar a consultar, 1-indexado. Default `1`.
	@return number

	Velocidad actual de una clave, en unidades por segundo. Devuelve `0` si la clave
	no existe.
]=]
function Controller.velocity(self: Controller, key: string, index: number?): number
	local spring = self._springs[key]
	return if spring then spring:getVelocity(index) else 0
end

--[=[
	@method isIdle
	@within Controller
	@return boolean

	`true` si ninguna clave se esta moviendo.
]=]
function Controller.isIdle(self: Controller): boolean
	return next(self._active) == nil
end

--[=[
	@method onChange
	@within Controller
	@param fn (values: ValueMap) -> ()
	@return Connection

	Sink principal: se invoca **una vez por frame** con todos los valores, mientras
	alguna clave se mueva.
]=]
function Controller.onChange(self: Controller, fn: (values: ValueMap) -> ()): Signal.Connection
	return self.changed:connect(fn)
end

--[=[
	@method map
	@within Controller
	@param key string
	@param mapper any -- Una funcion, o el arreglo `range`.
	@param output { Animatable }? -- Salidas, si `mapper` es un `range`.
	@param extrapolate Extrapolate? -- Default `"clamp"`.
	@return Interpolation
	@error "clave inexistente" -- Si `key` no existe en este controller.

	Valor derivado de una clave concreta.
]=]
function Controller.map(self: Controller, key: string, mapper: any, output: any, extrapolate: any): any
	local spring = self._springs[key]
	if not spring then
		error(string.format("Kinetic: no existe la clave '%s' en este controller", key), 2)
	end
	return spring:map(mapper, output, extrapolate)
end

--[=[
	@method destroy
	@within Controller

	Libera el controller: destruye sus springs, lo da de baja del frame loop y
	desconecta sus listeners. Los `start` posteriores no hacen nada.

	Un controller creado por [Kinetic.animate] se destruye solo cuando su instancia
	se destruye.
]=]
function Controller.destroy(self: Controller)
	if self._destroyed then
		return
	end
	self._destroyed = true
	self._generation += 1

	for _, spring in self._springs do
		spring:destroy()
	end
	table.clear(self._springs)
	table.clear(self._active)
	table.clear(self._snapshot)

	FrameLoop.remove(self :: any)
	self.changed:disconnectAll()
end

return Controller
