local BUFFER_SIZE = 1024

local CircularBuffer = {}
CircularBuffer.__index = CircularBuffer

export type CircularBuffer<T> = typeof(setmetatable(
    {} :: {
        _buffer: { [number]: T },
    },
    CircularBuffer
))

function CircularBuffer.new<T>(): CircularBuffer<T>
    return setmetatable({
        _buffer = table.create(BUFFER_SIZE),
    }, CircularBuffer)
end

function CircularBuffer.set<T>(self: CircularBuffer<T>, index: number, value: T)
    self._buffer[index % BUFFER_SIZE] = value
end

function CircularBuffer.get<T>(self: CircularBuffer<T>, index: number): T
    return self._buffer[index % BUFFER_SIZE]
end

return CircularBuffer