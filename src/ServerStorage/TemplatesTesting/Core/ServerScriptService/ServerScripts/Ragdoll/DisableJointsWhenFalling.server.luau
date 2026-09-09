-- Disables the character's AnimationConstraints to make the body limp when the character is in a falling down state.

local PlayerInit = require(game.ReplicatedStorage:WaitForChild("PlayerInit"))

local disabledStates = {
	Enum.HumanoidStateType.Ragdoll,
	Enum.HumanoidStateType.FallingDown,
	Enum.HumanoidStateType.GettingUp,
	Enum.HumanoidStateType.Dead,
}

local function setupCharacter(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 5) :: Humanoid?
	local hrp = character:WaitForChild("HumanoidRootPart", 5) :: BasePart?

	if not humanoid or not hrp then
		return
	end

	-- keep BallSocketConstraints on death
	humanoid.BreakJointsOnDeath = false
	-- avoid HRP colliding with UpperTorso on death
	hrp.CanCollide = false

	humanoid.Died:Connect(function()
		print("died!")
		for _, joint in character:GetDescendants() do
			if joint:IsA("AnimationConstraint") then
				joint.Enabled = false
			elseif joint:IsA("BallSocketConstraint") then
				joint.MaxFrictionTorque = 10
			end
		end
	end)

	-- hack: if we don't wait, the joints get disabled and the arms get stuck in a weird position
	task.wait(1)

	while humanoid.Parent and character.Parent do
		local enableAC = true
		local state = humanoid:GetState()

		if table.find(disabledStates, state) then
			enableAC = false
		end

		for _, j in character:GetDescendants() do
			if j:IsA("AnimationConstraint") and j.Name ~= "Root" then
				j.Enabled = enableAC
			end
		end

		task.wait()
	end
end

local function OnPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		task.defer(setupCharacter, character)
	end)
end

PlayerInit.Connect(OnPlayerAdded)
