--!strict

--[=[
	@class Mutex

	Cerrojo por-clave: serializa las secciones críticas que comparten el mismo
	`token`. Suspende con `coroutine.yield` y reanuda con `task.spawn`, respetando
	el scheduler de Roblox.
]=]
local Mutex = {}
Mutex.__index = Mutex

type self = {
	_queues: { [string]: { thread } },
}

export type Mutex = typeof(setmetatable({} :: self, Mutex))

--[=[
	@within Mutex
]=]
function Mutex.new(): Mutex
	return setmetatable({ _queues = {} }, Mutex)
end

--[=[
	@within Mutex

	Adquiere el cerrojo de `token`, cediendo el hilo hasta que quede libre.
]=]
function Mutex.lock(self: Mutex, token: string)
	local waiters = self._queues[token]
	if not waiters then
		self._queues[token] = {}
		return
	end
	table.insert(waiters, coroutine.running())
	coroutine.yield()
end

--[=[
	@within Mutex

	Libera el cerrojo de `token` y reanuda al siguiente en cola, si lo hay.
]=]
function Mutex.unlock(self: Mutex, token: string)
	local waiters = self._queues[token]
	if not waiters then
		return
	end
	local nextWaiter = table.remove(waiters, 1)
	if nextWaiter then
		-- no borrar `_queues[token]` acá. Si lo hiciéramos, habría una ventana donde el
		-- token se ve libre mientras nextWaiter todavía no corrió su sección crítica, y algo
		-- reentrante podría colarse a tomarlo también (doble dueño).
		task.spawn(nextWaiter)
	else
		self._queues[token] = nil
	end
end

return Mutex
