local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end -- Buena práctica: ignorar si escribes en chat

	if input.KeyCode == Enum.KeyCode.R then
		-- Buscamos el personaje ACTUAL, no el viejo
		local character = player.Character
		if not character then return end

		local humanoid = character:FindFirstChild("Humanoid")

		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)

			-- Esperamos 5s y reactivamos
			task.delay(5, function()
				-- Verificamos que el humanoide siga existiendo después de 5s
				if humanoid and humanoid.Parent then
					humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
				end
			end)
		end
	end
end)