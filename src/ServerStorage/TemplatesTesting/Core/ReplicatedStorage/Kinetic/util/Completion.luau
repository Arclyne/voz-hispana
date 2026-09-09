--!strict
--[[
	Handle de finalizacion devuelto por `start`.

	Cero dependencias es un objetivo de la biblioteca, asi que no arrastramos una
	implementacion de Promise. Esto cubre lo que hace falta: encadenar, esperar y
	cancelar. Si el consumidor ya usa Promise, envolverlo es una linea.
]]

local types = require(script.Parent.Parent.types)

type AnimationResult = types.AnimationResult

--[=[
	@class Completion

	Handle de finalizacion que devuelven [SpringValue:start] y [Controller:start].

	Cero dependencias es un objetivo de Kinetic, asi que no se arrastra una
	implementacion de Promise de terceros. Esto cubre lo que hace falta: encadenar,
	esperar y cancelar.

	```lua
	api:start({ x = 1 }):andThen(function(result)
		print(result.finished)
	end)
	```
]=]
local Completion = {}
Completion.__index = Completion

export type Completion = typeof(setmetatable(
	{} :: {
		_settled: boolean,
		_result: AnimationResult?,
		_callbacks: { (AnimationResult) -> () },
		_onCancel: (() -> ())?,
		_waiting: { thread },
	},
	Completion
))

function Completion.new(onCancel: (() -> ())?): Completion
	return setmetatable({
		_settled = false,
		_result = nil,
		_callbacks = {},
		_onCancel = onCancel,
		_waiting = {},
	}, Completion)
end

--[=[
	@function resolved
	@within Completion
	@param result AnimationResult
	@return Completion

	Completion ya resuelta. Util cuando `start` no tiene nada que animar.
]=]
function Completion.resolved(result: AnimationResult): Completion
	local self = Completion.new()
	self:_settle(result)
	return self
end

function Completion._settle(self: Completion, result: AnimationResult)
	if self._settled then
		return
	end
	self._settled = true
	self._result = result

	for _, callback in self._callbacks do
		task.spawn(callback, result)
	end
	table.clear(self._callbacks)

	for _, thread in self._waiting do
		task.spawn(thread, result)
	end
	table.clear(self._waiting)
end

--[=[
	@method andThen
	@within Completion
	@param fn (result: AnimationResult) -> ()
	@return Completion -- La misma, para encadenar.

	Ejecuta `fn` al terminar. Si ya termino, se ejecuta igualmente.
]=]
function Completion.andThen(self: Completion, fn: (AnimationResult) -> ()): Completion
	if self._settled then
		task.spawn(fn, self._result :: AnimationResult)
	else
		table.insert(self._callbacks, fn)
	end
	return self
end

--[=[
	@method await
	@within Completion
	@yields
	@return AnimationResult

	Bloquea el hilo actual hasta que termine y devuelve el resultado.
]=]
function Completion.await(self: Completion): AnimationResult
	if self._settled then
		return self._result :: AnimationResult
	end
	table.insert(self._waiting, coroutine.running())
	return coroutine.yield()
end

--[=[
	@method cancel
	@within Completion

	Detiene la animacion asociada y resuelve como cancelada.
]=]
function Completion.cancel(self: Completion)
	if self._settled then
		return
	end
	if self._onCancel then
		(self._onCancel :: () -> ())()
	end
	self:_settle({ value = 0, finished = false, cancelled = true })
end

--[=[
	@method isSettled
	@within Completion
	@return boolean

	`true` si ya se resolvio, por exito o por cancelacion.
]=]
function Completion.isSettled(self: Completion): boolean
	return self._settled
end

return Completion
