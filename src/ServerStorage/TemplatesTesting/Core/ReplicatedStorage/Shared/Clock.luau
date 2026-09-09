local Clock = {}
Clock.__index = Clock

export type Clock = typeof(setmetatable(
    {} :: {
        interval: number,
        callback: () -> (),
        elapsedTime: number,
    },
    Clock
))

function Clock.new(interval: number, callback: () -> ()): Clock
    return setmetatable({
        interval = interval,
        callback = callback,
        elapsedTime = 0,
    }, Clock)
end

function Clock.update(self: Clock, dt: number)
    self.elapsedTime += dt

    if self.elapsedTime >= self.interval then
        self.elapsedTime -= self.interval
        self.callback()
    end
end

return Clock