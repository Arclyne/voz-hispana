local function NewSignal()
	local listeners = {}
	return {
		Connect = function(_, fn)
			listeners[fn] = true
			return { Disconnect = function() listeners[fn] = nil end }
		end,
		Fire = function(_, ...)
			for fn in pairs(listeners) do task.spawn(fn, ...) end
		end,
	}
end

local channel = NewSignal()

return channel