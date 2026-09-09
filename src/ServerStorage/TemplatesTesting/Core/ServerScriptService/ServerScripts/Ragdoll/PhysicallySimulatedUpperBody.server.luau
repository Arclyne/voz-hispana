local Players = game:GetService("Players")

local PlayerInit = require(game.ReplicatedStorage:WaitForChild("PlayerInit"))

local simulatedJoints = {
	--"Neck",
	"Shoulder",
	"Elbow",
	"Wrist"
}

local function setupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end

	for _, j in character:GetDescendants() do
		if not j:IsA("AnimationConstraint") then
			continue
		end

		local shouldSimulate = false
		for _, n in simulatedJoints do
			if string.find(j.Name, n) then
				shouldSimulate = true
				break
			end
		end

		if shouldSimulate then
			j.IsKinematic = false
			j.MaxTorque = 700
		end
	end
end

local function OnPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		task.delay(1, function() -- pequeño delay para que todo cargue
			setupCharacter(character)
		end)
	end)
end

PlayerInit.Connect(OnPlayerAdded)



