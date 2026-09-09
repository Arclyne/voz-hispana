local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Shared.Trove)
local attach = require(ReplicatedStorage.Shared.attach)
local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))

local assets = ReplicatedStorage.Assets

local exports = {}

function exports.createBall(character: Model, onScore: (() -> ())?)
    local rightHand = character.RightHand
    local ball = assets.Machines["Basket-Ball"]:Clone()

    ball.Collider.CanCollide = false
    ball:PivotTo(rightHand.CFrame * CFrame.new(0, -ball.Size.Y / 2, 0))
    ball.Parent = rightHand

    attach(ball, rightHand)

    local connection = ball.Collider.Touched:Connect(function(hit)
        if hit.Name == "Trigger" and not ball:GetAttribute("Scored") then
            ball:SetAttribute("Scored", true)
            if onScore then
                onScore()
            end
			SoundManager:Play(nil, 13576251401, { Volume = 1 }, hit)
		end
    end)

    ball.Destroying:Connect(function()
        connection:Disconnect()
    end)

    return ball
end

function exports.throwBall(character: Model, origin: Vector3, velocity: Vector3)
    local ball = character.RightHand["Basket-Ball"]
    local weld = character.RightHand["Basket-Ball"].WeldConstraint

    weld.Enabled = false
    ball:PivotTo(CFrame.new(origin))
    ball:SetAttribute("Scored", false)
    ball.AssemblyLinearVelocity = velocity

    task.delay(0.2, function()
        ball.Collider.CanCollide = true
    end)
end

function exports.returnBall(character: Model)
    local rightHand = character.RightHand
    local ball = character.RightHand["Basket-Ball"]
    local weld = character.RightHand["Basket-Ball"].WeldConstraint

    ball.Collider.CanCollide = false
    ball:PivotTo(rightHand.CFrame * CFrame.new(0, -ball.Size.Y / 2, 0))
    weld.Enabled = true
    ball.Parent = rightHand
end

function exports.setScoreText(model: Model, score: number)
    local text = model.Mark.Text
    text.Text = string.format("%02i", score)
end

return exports
