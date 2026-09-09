--[[

There's a strange behavior where the HumanoidRootPart can sink below a surface as you're getting up.
You slide horizontally extremely fast. This script just makes the HRP collide while getting up, to "push" it above the ground.
This is hacky but seems to fix the sliding.

]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function conectarAyudaLevantarse(character)
	local humanoid = character:WaitForChild("Humanoid")
	local hrp = character:WaitForChild("HumanoidRootPart")

	-- Conectamos el evento al nuevo humanoide
	humanoid.StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.GettingUp then
			hrp.CanCollide = true
		else
			-- Opcional: Solo desactivar colisión si NO es Dead o Physics
			-- Pero siguiendo tu lógica original:
			hrp.CanCollide = false
		end
	end)
end

player.CharacterAdded:Connect(conectarAyudaLevantarse)

if player.Character then
	conectarAyudaLevantarse(player.Character)
end