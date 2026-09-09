local Workspace = game:GetService("Workspace")

local attachment0 = Instance.new("Attachment")
attachment0.Parent = Workspace.Terrain

local attachment1 = Instance.new("Attachment")
attachment1.Parent = Workspace.Terrain

local beam = Instance.new("Beam")
beam.Attachment0 = attachment0
beam.Attachment1 = attachment1
beam.Segments = 50
beam.Width0 = 0.4
beam.Width1 = 0.4
beam.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
    ColorSequenceKeypoint.new(0.1, Color3.fromRGB(255, 98, 98)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 98, 98)),
})
beam.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.2),
    NumberSequenceKeypoint.new(1, 0.2),
})
beam.Parent = Workspace.Terrain

local function beamProjectile(g: Vector3, v0: Vector3, x0: Vector3, t1: number)
    local c = 0.125
    local p3 = 0.5 * g * t1 * t1 + v0 * t1 + x0
    local p2 = p3 - (g * t1 * t1 + v0 * t1) / 3
    local p1 = (c * g * t1 * t1 + 0.5 * v0 * t1 + x0 - c * (x0 + p3)) / (3 * c) - p2

    local curve0 = (p1 - x0).Magnitude
    local curve1 = (p2 - p3).Magnitude

    local b = (x0 - p3).Unit
    local r1 = (p1 - x0).Unit
    local u1 = r1:Cross(b).Unit
    local r2 = (p2 - p3).Unit
    local u2 = r2:Cross(b).Unit

    b = u1:Cross(r1).Unit

    local cf1 = CFrame.new(x0.X, x0.Y, x0.Z, r1.X, u1.X, b.X, r1.Y, u1.Y, b.Y, r1.Z, u1.Z, b.Z)
    local cf2 = CFrame.new(p3.X, p3.Y, p3.Z, r2.X, u2.X, b.X, r2.Y, u2.Y, b.Y, r2.Z, u2.Z, b.Z)

    return curve0, -curve1, cf1, cf2
end

local module = {}

function module.enable()
    beam.Enabled = true
end

function module.disable()
    beam.Enabled = false
end

function module.update(gravity: Vector3, velocity: Vector3, origin: Vector3, duration: number)
    local curve0, curve1, cf1, cf2 = beamProjectile(gravity, velocity, origin, duration)
    beam.CurveSize0 = curve0
    beam.CurveSize1 = curve1

    attachment0.CFrame = Workspace.Terrain.CFrame:Inverse() * cf1
    attachment1.CFrame = Workspace.Terrain.CFrame:Inverse() * cf2
end

return module