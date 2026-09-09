local SLOWEST_SPEED = 0.05
local FASTEST_SPEED = 0.5

local module = {}

function module.getWaitTime(currentTurn: number, maxTurns: number)
    local a = SLOWEST_SPEED
    local b = (FASTEST_SPEED / SLOWEST_SPEED) ^ (1 / (maxTurns - 1))
    return a * (b ^ (currentTurn - 1))
end

return module