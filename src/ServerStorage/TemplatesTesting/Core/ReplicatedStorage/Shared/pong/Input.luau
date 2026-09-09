local UserInputService = game:GetService("UserInputService")

local Input = {}
Input.upPressed = false
Input.downPressed = false

function Input.getDirection()
    if UserInputService.TouchEnabled then
        return if Input.upPressed then 1 elseif Input.downPressed then -1 else 0
    end

    return if UserInputService:IsKeyDown(Enum.KeyCode.Up)
            or UserInputService:IsKeyDown(Enum.KeyCode.W)
        then 1
        elseif UserInputService:IsKeyDown(Enum.KeyCode.Down) or UserInputService:IsKeyDown(
            Enum.KeyCode.S
        ) then -1
        else 0
end

return Input
