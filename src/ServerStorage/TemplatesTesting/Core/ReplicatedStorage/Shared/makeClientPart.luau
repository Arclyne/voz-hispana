local RunService = game:GetService("RunService")

local VISUALIZE_SERVER = RunService:IsStudio()

return function(serverPart: BasePart): BasePart
    assert(RunService:IsClient())

    local name = serverPart.Name
    local transparency = serverPart.Transparency
    local material = serverPart.Material
    local color = serverPart.Color
    local parent = serverPart.Parent

    local clientPart = serverPart:Clone()
    clientPart.Parent = parent
    clientPart.Destroying:Connect(function()
        if VISUALIZE_SERVER then
            serverPart.Name = name
            serverPart.Transparency = transparency
            serverPart.Material = material
            serverPart.Color = color
        else
            serverPart.Parent = parent
        end
    end)

    if VISUALIZE_SERVER then
        serverPart.Name = `SERVER_{serverPart.Name}`
        serverPart.Transparency = 0.85
        serverPart.Material = Enum.Material.Neon
        serverPart.Color = Color3.new(0, 1, 0)
    else
        serverPart.Parent = nil
    end

    return clientPart
end
