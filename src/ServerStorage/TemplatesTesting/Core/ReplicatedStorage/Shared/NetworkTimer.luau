local RunService = game:GetService("RunService")

local SERVER_TICK_RATE = 60

local NetworkTimer = {}
NetworkTimer.__index = NetworkTimer

export type NetworkTimer = typeof(setmetatable(
    {} :: {
        timeBetweenTicks: number,
        currentTick: number,
    },
    NetworkTimer
))

function NetworkTimer.new(): NetworkTimer
    return setmetatable({
        timeBetweenTicks = 1 / SERVER_TICK_RATE,
        currentTick = 0,
    }, NetworkTimer)
end

function NetworkTimer.bind(self: NetworkTimer, callback: () -> ())
    local timer = 0

    local connection = RunService.Heartbeat:Connect(function(dt)
        timer += dt

        while timer >= self.timeBetweenTicks do
            timer -= self.timeBetweenTicks
            self.currentTick += 1
            callback()
        end
    end)

    return function()
        connection:Disconnect()
    end
end

return NetworkTimer
