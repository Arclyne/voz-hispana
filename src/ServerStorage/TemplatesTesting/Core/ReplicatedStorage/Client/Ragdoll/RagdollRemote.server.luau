local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player")
local ragdollRemote = remotes:WaitForChild("RagdollTarget")

local function getCharacterHumanoid()
	local character = player.Character
	if not character then return nil, nil end
	return character, character:FindFirstChildOfClass("Humanoid")
end

ragdollRemote.OnClientEvent:Connect(function(duration)
	local character, humanoid = getCharacterHumanoid()
	if not character or not humanoid then
		return
	end

	local untilTime = os.clock() + (duration or 1.25)
	character:SetAttribute("ForcedRagdollUntil", untilTime)

	humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)

	task.delay(duration or 1.25, function()
		if humanoid and humanoid.Parent then
			local forcedUntil = character:GetAttribute("ForcedRagdollUntil") or 0
			if os.clock() >= forcedUntil then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
			end
		end
	end)
end)