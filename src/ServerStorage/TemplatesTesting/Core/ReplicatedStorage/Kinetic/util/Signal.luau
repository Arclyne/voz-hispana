--!strict
--[[
	Senal minima. No usamos BindableEvent porque serializa los argumentos y
	perderiamos las tablas de valores que emitimos cada frame.
]]

export type Connection = {
	disconnect: (self: Connection) -> (),
	connected: boolean,
}

type Listener = {
	fn: (...any) -> (),
	connected: boolean,
}

local Signal = {}
Signal.__index = Signal

export type Signal = typeof(setmetatable(
	{} :: {
		_listeners: { Listener },
	},
	Signal
))

function Signal.new(): Signal
	return setmetatable({ _listeners = {} }, Signal)
end

function Signal.connect(self: Signal, fn: (...any) -> ()): Connection
	local listener: Listener = { fn = fn, connected = true }
	table.insert(self._listeners, listener)

	local connection = {
		connected = true,
	}

	function connection.disconnect(conn)
		if not listener.connected then
			return
		end
		listener.connected = false
		conn.connected = false
		local index = table.find(self._listeners, listener)
		if index then
			table.remove(self._listeners, index)
		end
	end

	return connection :: any
end

function Signal.fire(self: Signal, ...: any)
	--[[
		Copiamos porque un listener puede desconectarse (o conectar otro) mientras
		emitimos, y eso reordenaria la tabla a mitad del recorrido.
	]]
	local listeners = table.clone(self._listeners)
	for _, listener in listeners do
		if listener.connected then
			listener.fn(...)
		end
	end
end

function Signal.disconnectAll(self: Signal)
	for _, listener in self._listeners do
		listener.connected = false
	end
	table.clear(self._listeners)
end

function Signal.hasListeners(self: Signal): boolean
	return #self._listeners > 0
end

return Signal
