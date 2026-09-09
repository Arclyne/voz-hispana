local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function iniciarLogica(character)
	local humanoid = character:WaitForChild("Humanoid")
	local hrp = character:WaitForChild("HumanoidRootPart")
	local speedThreshold = 100

	task.spawn(function()
		while character.Parent and humanoid.Health > 0 do
			task.wait()

			local state = humanoid:GetState()
			local speed = hrp.Velocity.Magnitude
			local forcedUntil = character:GetAttribute("ForcedRagdollUntil") or 0
			local forcedRagdollActive = os.clock() < forcedUntil

			if forcedRagdollActive then
				if state ~= Enum.HumanoidStateType.Ragdoll
					and state ~= Enum.HumanoidStateType.Dead then
					humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
				end

				humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)

			elseif state ~= Enum.HumanoidStateType.Ragdoll
				and state ~= Enum.HumanoidStateType.Dead
				and speed >= speedThreshold then

				humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
				humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)

			elseif speed < speedThreshold then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
			end
		end
	end)
end

player.CharacterAdded:Connect(iniciarLogica)

if player.Character then
	iniciarLogica(player.Character)
end