type SpringParams = {
    K: number,
    mass: number,
    damping: number,
}

local Spring = {}
Spring.__index = Spring

function Spring.new<T>(target, velocity, params: SpringParams)
    local self = setmetatable({}, Spring)
    self.target = target
    self.value = target
    self.velocity = velocity
    self.K = params.K
    self.mass = params.mass
    self.damping = params.damping

    return self
end

function Spring:update()
    self.velocity += -self.K * (self.value - self.target) / self.mass - self.velocity * self.damping
    self.value += self.velocity
end

function Spring:impulse(impulsor: number)
    self.velocity += impulsor
end

return Spring
