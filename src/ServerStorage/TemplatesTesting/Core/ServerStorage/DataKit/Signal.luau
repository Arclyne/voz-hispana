--!strict

--[=[
	@class Signal

	Evento observable mínimo. Cada listener se entrega en su propio thread
	(`task.spawn`): un error en uno no afecta a los demás ni a quien dispara.
]=]
local Signal = {}
Signal.__index = Signal

export type Connection = {
	Disconnect: (self: Connection) -> (),
}

type Listener = (...any) -> ()

type self = {
	_listeners: { [Listener]: true },
}

export type Signal = typeof(setmetatable({} :: self, Signal))

--[=[
	@within Signal
]=]
function Signal.new(): Signal
	return setmetatable({ _listeners = {} }, Signal)
end

--[=[
	@within Signal

	Suscribe `fn`. La conexión devuelta lo desuscribe con `:Disconnect()`.
]=]
function Signal.Connect(self: Signal, fn: Listener): Connection
	self._listeners[fn] = true
	return {
		Disconnect = function()
			self._listeners[fn] = nil
		end,
	}
end

--[=[
	@within Signal

	Entrega los argumentos a cada listener suscrito.
]=]
function Signal.Fire(self: Signal, ...: any)
	for fn in pairs(self._listeners) do
		task.spawn(fn, ...)
	end
end

return Signal
