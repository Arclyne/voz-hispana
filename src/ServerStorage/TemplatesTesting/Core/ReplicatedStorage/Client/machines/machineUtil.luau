local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Observers = require(ReplicatedStorage.Shared.Observers)

local CHARACTER_TRANSPARENCY = 0.925

local player = Players.LocalPlayer
local exports = {}

function exports.setCamera(part: Part, filter: { string }?)
    local camera = Workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = part.CFrame

    local whitelist = filter or {}
    table.insert(whitelist, "HumanoidRootPart")

    local function setTransparency(instance: Instance, transparency: number)
        for _, child in instance:GetChildren() do
            if table.find(whitelist, child.Name) then
                continue
            end

            if child:IsA("BasePart") then
                child.Transparency = transparency
            end

            setTransparency(child, transparency)
        end
    end

    local cleanup = Observers.observeCharacter(function(_, character)
        setTransparency(character, CHARACTER_TRANSPARENCY)

        return function()
            setTransparency(character, 0)
        end
    end)

    return function()
        cleanup()
        camera.CameraType = Enum.CameraType.Custom
    end
end

function exports.freezeCharacter(part: Part?)
    local character = player.Character 
	local humanoid = character.Humanoid

    local walkSpeed = humanoid.WalkSpeed
    local jumpPower = humanoid.JumpPower
    local jumpHeight = humanoid.JumpHeight

    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    humanoid.JumpHeight = 0

    if part then
        character:PivotTo(part.CFrame * CFrame.new(0, character:GetExtentsSize().Y / 2, 0))
    end

    return function()
        humanoid.WalkSpeed = walkSpeed
        humanoid.JumpPower = jumpPower
        humanoid.JumpHeight = jumpHeight
    end
end

return exports
