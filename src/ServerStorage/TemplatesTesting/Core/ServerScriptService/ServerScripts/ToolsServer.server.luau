local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local SoundManager = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SoundManager"))
local CooldownManager = require(ReplicatedStorage.Shared.Cooldown:WaitForChild("CooldownManager"))
local VoiceModulator = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("VoiceModulator"))
local PlayerInit = require(ReplicatedStorage:WaitForChild("PlayerInit"))

local remotes = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Tools")
local cannonTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models"):WaitForChild("CannonModel")
local ragdollRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("RagdollTarget")

local equipRemote = remotes:WaitForChild("EquipTool")
local equipRemoteAccesory = remotes:WaitForChild("EquipToolAccesory")
local flyRemote = remotes:WaitForChild("Fly")
local ballonRemote = remotes:WaitForChild("Ballon")
local cannonRemote = remotes:WaitForChild("Cannon")
local gloveGunRemote = remotes:WaitForChild("GloveGun")

local CANNON_APPEAR_SOUND_ID = 136836088450502
local CANNON_FIRE_SOUND_ID = 140172249821450
local CANNON_COOLDOWN_KEY = "Cannon"
local CANNON_COOLDOWN_SECONDS = 5
local CANNON_GROUND_SINK = 0.4

local SizeManager = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SizeManager"))
local minimizateRemote = remotes:WaitForChild("Minimizate")
local maximizateRemote = remotes:WaitForChild("Maximizate")
local DRINK_SOUND_ID = 2245190929

equipRemoteAccesory.OnServerEvent:Connect(function(player: Player, handle: Part, accesory: BasePart, isEquipping: boolean)
	local character = player.Character or player.CharacterAdded:Wait()

	if not accesory or not handle then return end

	if isEquipping then
		accesory.Parent = character
	else
		accesory.Parent = handle.Parent
	end
end)

equipRemote.OnServerEvent:Connect(function(player: Player, handle: Part)
	local equipSound = handle:FindFirstChild("EquipSound")
	if equipSound and equipSound:IsA("Sound") then
		equipSound:Play()
	end
end)

local flySession = {}

flyRemote.OnServerEvent:Connect(function(player, particles1, particles2, toggle, startSound, runningSound, stopSound)
	flySession[player] = (flySession[player] or 0) + 1
	local sessionId = flySession[player]

	particles1.Enabled = toggle
	particles2.Enabled = toggle

	if toggle then
		startSound:Play()
		task.delay(0.5, function()
			if flySession[player] == sessionId then
				runningSound:Play()
			end
		end)
	else
		runningSound:Stop()
		stopSound:Play()
	end
end)

ballonRemote.OnServerEvent:Connect(function(player, equipped, tool)
	local character = player.Character
	if not character then return end
	if not tool or not tool:FindFirstChild("Handle") then return end

	local balloonMesh = tool.Handle:FindFirstChild("BallonMesh")
	if not balloonMesh then return end

	if equipped then
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return end

		local offset = Vector3.new(0, 2, 0)
		balloonMesh.CFrame = root.CFrame + offset

		balloonMesh.RopeConstraint.Attachment1 = tool.Handle.Attachment2

		balloonMesh.Transparency = 0
		balloonMesh.RopeConstraint.Visible = true
	else
		balloonMesh.Transparency = 1
		balloonMesh.RopeConstraint.Visible = false
	end
end)

----------------------------------------------------------------
-- CANNON
----------------------------------------------------------------

local CANNON_INITIAL_SPEED = 190
local CANNON_FORCE = 2800
local CANNON_FORCE_DURATION = 0.08
local CANNON_UPWARD_BIAS = 0.6
local CANNON_LIFETIME = 5
local PARTICLE_DURATION = 0.3

local cannonState = {}

local function getExplosionMiddle(model)
	local explosion = model:FindFirstChild("Explosion")
	if not explosion then return nil end

	local middle = explosion:FindFirstChild("Middle")
	return middle
end

local function setCannonAnchored(cannonModel, anchored)
	for _, obj in ipairs(cannonModel:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Anchored = anchored
			obj.AssemblyLinearVelocity = Vector3.zero
			obj.AssemblyAngularVelocity = Vector3.zero
		end
	end
end

local function setCannonParticles(middle, enabled)
	if not middle then return end

	for _, name in ipairs({"Explosion1", "Explosion2", "Explosion3", "Explosion4"}) do
		local emitter = middle:FindFirstChild(name)
		if emitter and emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

local function getGroundBasePosition(root, character, tool, cannonModel)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {character, tool}

	local origin = root.Position + Vector3.new(0, 20, 0)
	local direction = Vector3.new(0, -300, 0)
	local result = Workspace:Raycast(origin, direction, rayParams)

	local _, size = cannonModel:GetBoundingBox()
	local groundY = result and result.Position.Y or root.Position.Y

	return Vector3.new(
		root.Position.X,
		groundY + (size.Y * 0.5) - CANNON_GROUND_SINK,
		root.Position.Z
	)
end

local function getYawFromLookVector(lookVector: Vector3)
	local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z)

	if flatLook.Magnitude < 0.001 then
		return 0
	end

	flatLook = flatLook.Unit
	return math.atan2(-flatLook.X, -flatLook.Z)
end

local function clearCannonWeld(character)
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local weld = root:FindFirstChild("CannonPlayerWeld")
	if weld then
		weld:Destroy()
	end
end

local function attachPlayerToCannon(character, mainPart, playerPosAttachment)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	clearCannonWeld(character)

	character:PivotTo(playerPosAttachment.WorldCFrame)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero

	local weld = Instance.new("WeldConstraint")
	weld.Name = "CannonPlayerWeld"
	weld.Part0 = root
	weld.Part1 = mainPart
	weld.Parent = root
end

local function freezePlayerForCannon(humanoid, state)
	if state.SavedWalkSpeed == nil then
		state.SavedWalkSpeed = humanoid.WalkSpeed
	end
	if state.SavedJumpPower == nil then
		state.SavedJumpPower = humanoid.JumpPower
	end
	if state.SavedAutoRotate == nil then
		state.SavedAutoRotate = humanoid.AutoRotate
	end

	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.AutoRotate = false
end

local function restorePlayerAfterCannon(humanoid, state)
	if state and state.SavedWalkSpeed ~= nil then
		humanoid.WalkSpeed = state.SavedWalkSpeed
	end
	if state and state.SavedJumpPower ~= nil then
		humanoid.JumpPower = state.SavedJumpPower
	end
	if state and state.SavedAutoRotate ~= nil then
		humanoid.AutoRotate = state.SavedAutoRotate
	end

	humanoid.PlatformStand = false
end

local function getLaunchDirection(baseDirection: Vector3)
	local launchDirection = baseDirection

	if launchDirection.Magnitude < 0.001 then
		launchDirection = Vector3.new(0, 1, 0)
	else
		launchDirection = launchDirection.Unit
	end

	launchDirection = launchDirection + Vector3.new(0, CANNON_UPWARD_BIAS, 0)
	return launchDirection.Unit
end

local function launchCharacter(root: BasePart, direction: Vector3)
	local existingForce = root:FindFirstChild("CannonLaunchForce")
	if existingForce then
		existingForce:Destroy()
	end

	local attachment = root:FindFirstChild("CannonLaunchAttachment")
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "CannonLaunchAttachment"
		attachment.Parent = root
	end

	local vectorForce = Instance.new("VectorForce")
	vectorForce.Name = "CannonLaunchForce"
	vectorForce.Attachment0 = attachment
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.ApplyAtCenterOfMass = true
	vectorForce.Force = direction * root.AssemblyMass * CANNON_FORCE
	vectorForce.Parent = root

	task.delay(CANNON_FORCE_DURATION, function()
		if vectorForce and vectorForce.Parent then
			vectorForce:Destroy()
		end
	end)
end

local function poseCannon(state, basePosition, yaw, pitch)
	if not state or not state.Model or not state.MainPart then return end

	local modelCF = CFrame.new(basePosition) * CFrame.Angles(0, yaw, 0)
	state.Model:PivotTo(modelCF)

	local mainPartBaseWorldCF = modelCF * state.MainPartBaseLocalCF
	state.MainPart.CFrame = mainPartBaseWorldCF * CFrame.Angles(pitch, 0, 0)
end

local function cleanupCannon(tool, player, reason)
	local state = cannonState[tool]
	if not state then
		return
	end

	if state.RunningConn then
		state.RunningConn:Disconnect()
		state.RunningConn = nil
	end

	local character = player.Character
	if character then
		clearCannonWeld(character)

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			restorePlayerAfterCannon(humanoid, state)
		end
	end

	if state.Model and state.Model.Parent then
		state.Model:Destroy()
	end

	cannonState[tool] = nil

	if reason == "Expired" then
		cannonRemote:FireClient(player, "Expired", tool)
	end
end

local function spawnCannonIfNeeded(player, tool, character, humanoid, root)
	local state = cannonState[tool]
	if not state or state.Model then
		return state
	end

	local cannonModel = cannonTemplate:Clone()
	cannonModel.Name = tool.Name .. "_WorldCannon"
	cannonModel.Parent = Workspace

	local mainPart = cannonModel:WaitForChild("MainPart")
	local playerPosAttachment = mainPart:WaitForChild("PlayerPos")
	local middle = getExplosionMiddle(cannonModel)

	state.Model = cannonModel
	state.MainPart = mainPart
	state.PlayerPosAttachment = playerPosAttachment
	state.Middle = middle
	state.MainPartBaseLocalCF = cannonModel:GetPivot():ToObjectSpace(mainPart.CFrame)
	state.BasePosition = getGroundBasePosition(root, character, tool, cannonModel)

	local initialYaw = state.LatestYaw or getYawFromLookVector(root.CFrame.LookVector)
	local initialPitch = state.LatestPitch or 0

	setCannonAnchored(cannonModel, true)
	poseCannon(state, state.BasePosition, initialYaw, initialPitch)
	attachPlayerToCannon(character, mainPart, playerPosAttachment)
	freezePlayerForCannon(humanoid, state)

	if state.RunningConn then
		state.RunningConn:Disconnect()
		state.RunningConn = nil
	end

	SoundManager:Play(nil, CANNON_APPEAR_SOUND_ID, {
		Volume = 1,
		Pool = 2,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		RollOffMinDistance = 8,
		RollOffMaxDistance = 45,
	}, state.MainPart)
	cannonRemote:FireClient(player, "Ready", tool)

	return state
end

cannonRemote.OnServerEvent:Connect(function(player, action, tool, a, b, c)
	if not tool or not tool:IsA("Tool") then return end

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end

	if action == "Unequip" then
		local state = cannonState[tool]

		-- Si no existe estado, no hay nada que limpiar
		if not state then
			return
		end

		-- Solo borrar al desequipar si TODAVÍA no se ha disparado
		if not state.Fired then
			cleanupCannon(tool, player, "Unequip")
		end

		return
	end

	if tool.Parent ~= character then
		return
	end

	if action == "Equip" then
		local isOnCooldown, remaining = CooldownManager.IsOnCooldown(player, CANNON_COOLDOWN_KEY)
		if isOnCooldown then
			cannonRemote:FireClient(player, "CooldownDenied", tool, remaining)
			return
		end

		cleanupCannon(tool, player, "Reset")

		local state = {
			Model = nil,
			MainPart = nil,
			PlayerPosAttachment = nil,
			Middle = nil,
			MainPartBaseLocalCF = nil,
			BasePosition = nil,
			LatestYaw = getYawFromLookVector(root.CFrame.LookVector),
			LatestPitch = 0,
			SavedWalkSpeed = nil,
			SavedJumpPower = nil,
			SavedAutoRotate = nil,
			RunningConn = nil,
			Fired = false,
		}

		cannonState[tool] = state

		if humanoid:GetState() == Enum.HumanoidStateType.Running then
			spawnCannonIfNeeded(player, tool, character, humanoid, root)
		else
			state.RunningConn = humanoid.Running:Connect(function(speed)
				if speed > 0.1 and tool.Parent == character then
					spawnCannonIfNeeded(player, tool, character, humanoid, root)
				end
			end)
		end

		return
	end

	local state = cannonState[tool]
	if not state then return end

	if action == "Aim" then
		local yaw = a
		local pitch = b

		if typeof(yaw) ~= "number" then return end
		if typeof(pitch) ~= "number" then return end

		state.LatestYaw = yaw
		state.LatestPitch = pitch

		if state.Model and state.BasePosition then
			poseCannon(state, state.BasePosition, yaw, pitch)
		end
		return
	end

	if action == "Fire" then
		local isOnCooldown = CooldownManager.IsOnCooldown(player, CANNON_COOLDOWN_KEY)
		if isOnCooldown then
			return
		end

		if not state.Model or not state.MainPart or state.Fired then
			return
		end

		state.Fired = true
		CooldownManager.Start(player, CANNON_COOLDOWN_KEY, CANNON_COOLDOWN_SECONDS)

		local thisState = state
		task.delay(CANNON_LIFETIME, function()
			if cannonState[tool] == thisState and thisState.Model and thisState.Fired then
				cleanupCannon(tool, player, "Expired")
			end
		end)

		SoundManager:Play(nil, CANNON_FIRE_SOUND_ID, {
			Volume = 4,
			Pool = 2,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			RollOffMinDistance = 10,
			RollOffMaxDistance = 155,
		}, state.MainPart)

		local yaw = a
		local pitch = b
		local lookVector = c

		if typeof(yaw) == "number" and typeof(pitch) == "number" then
			state.LatestYaw = yaw
			state.LatestPitch = pitch
			poseCannon(state, state.BasePosition, yaw, pitch)
		end

		restorePlayerAfterCannon(humanoid, state)
		clearCannonWeld(character)

		setCannonParticles(state.Middle, true)
		task.delay(PARTICLE_DURATION, function()
			if state.Middle and state.Middle.Parent then
				setCannonParticles(state.Middle, false)
			end
		end)

		local direction
		if typeof(lookVector) == "Vector3" and lookVector.Magnitude > 0.001 then
			direction = getLaunchDirection(lookVector)
		else
			direction = getLaunchDirection(state.MainPart.CFrame.LookVector)
		end

		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		humanoid.PlatformStand = true

		RunService.Heartbeat:Wait()

		root.AssemblyLinearVelocity = direction * CANNON_INITIAL_SPEED
		launchCharacter(root, direction)

		task.delay(0.5, function()
			if humanoid and humanoid.Parent then
				humanoid.PlatformStand = false
			end
		end)

		return
	end
end)

----------------------------------------------------------------
-- GLOVE GUN
----------------------------------------------------------------

local GLOVE_COOLDOWN_KEY = "GloveGun"
local GLOVE_COOLDOWN_SECONDS = 5

local GLOVE_RAGDOLL_LEAD = 0.1
local GLOVE_RAGDOLL_DURATION = 1.25

local GLOVE_PARTICLE_DURATION = 0.25
local GLOVE_EXTEND_DISTANCE = 4
local GLOVE_EXTEND_TIME = 0.08
local GLOVE_RETURN_DELAY = 1
local GLOVE_RETURN_TIME = 0.12

-- Cambia esto si sale en dirección contraria
local GLOVE_FORWARD_SIGN = -1

local GLOVE_LAUNCH_INITIAL_SPEED = 135
local GLOVE_LAUNCH_FORCE = 2000
local GLOVE_LAUNCH_FORCE_DURATION = 0.08
local GLOVE_LAUNCH_UPWARD_BIAS = 0.2

local GLOVE_FIRE_SOUND_ID = 81788881841044
local GLOVE_HIT_SOUND_ID = 73171011601510

local gloveRigCache = {}

local function launchCharacterPhysics(root: BasePart, direction: Vector3, initialSpeed: number, forceAmount: number, forceDuration: number)
	local existingForce = root:FindFirstChild("ToolLaunchForce")
	if existingForce then
		existingForce:Destroy()
	end

	local attachment = root:FindFirstChild("ToolLaunchAttachment")
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "ToolLaunchAttachment"
		attachment.Parent = root
	end

	local vectorForce = Instance.new("VectorForce")
	vectorForce.Name = "ToolLaunchForce"
	vectorForce.Attachment0 = attachment
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.ApplyAtCenterOfMass = true
	vectorForce.Force = direction * root.AssemblyMass * forceAmount
	vectorForce.Parent = root

	root.AssemblyLinearVelocity = direction * initialSpeed

	task.delay(forceDuration, function()
		if vectorForce and vectorForce.Parent then
			vectorForce:Destroy()
		end
	end)
end

local function getLaunchDirectionWithBias(baseDirection: Vector3, upwardBias: number)
	local direction = baseDirection.Magnitude > 0.001 and baseDirection.Unit or Vector3.new(0, 1, 0)
	direction = direction + Vector3.new(0, upwardBias, 0)
	return direction.Unit
end

local function getCharacterFromPart(part: BasePart): Model?
	local model = part:FindFirstAncestorOfClass("Model")
	if not model then return nil end
	if not model:FindFirstChildOfClass("Humanoid") then return nil end
	if not model:FindFirstChild("HumanoidRootPart") then return nil end
	return model
end

local function getGloveRig(tool: Tool)
	local cached = gloveRigCache[tool]
	if cached then
		return cached
	end

	local handle = tool:FindFirstChild("Handle")
	if not handle or not handle:IsA("BasePart") then return nil end

	local base = handle:FindFirstChild("Base")
	local glove = handle:FindFirstChild("Glove")
	local ragdollCollision = handle:FindFirstChild("RagdollCollision")
	local decalFolder = handle:FindFirstChild("Decal")

	if not base or not base:IsA("BasePart") then return nil end
	if not glove or not glove:IsA("BasePart") then return nil end
	if not ragdollCollision or not ragdollCollision:IsA("BasePart") then return nil end
	if not decalFolder then return nil end

	local barrelR = decalFolder:FindFirstChild("BarrelR")
	local barrelL = decalFolder:FindFirstChild("BarrelL")

	if not barrelR or not barrelR:IsA("BasePart") then return nil end
	if not barrelL or not barrelL:IsA("BasePart") then return nil end

	local gloveWeld = base:FindFirstChild("GloveWeld")
	local barrelRWeld = base:FindFirstChild("BarrelRWeld")
	local barrelLWeld = base:FindFirstChild("BarrelLWeld")
	local collisionWeld = base:FindFirstChild("CollisionWeld")

	if not gloveWeld or not gloveWeld:IsA("Weld") then return nil end
	if not barrelRWeld or not barrelRWeld:IsA("Weld") then return nil end
	if not barrelLWeld or not barrelLWeld:IsA("Weld") then return nil end
	if not collisionWeld or not collisionWeld:IsA("Weld") then return nil end

	local attachment = glove:FindFirstChild("Attachment")
	local circle = attachment and attachment:FindFirstChild("Circle")
	if not circle or not circle:IsA("ParticleEmitter") then
		return nil
	end

	local rig = {
		Handle = handle,
		Base = base,
		Glove = glove,
		BarrelR = barrelR,
		BarrelL = barrelL,
		RagdollCollision = ragdollCollision,
		Particles = circle,

		GloveWeld = gloveWeld,
		BarrelRWeld = barrelRWeld,
		BarrelLWeld = barrelLWeld,
		CollisionWeld = collisionWeld,

		InitialGloveC0 = gloveWeld.C0,
		InitialBarrelRC0 = barrelRWeld.C0,
		InitialBarrelLC0 = barrelLWeld.C0,
		InitialCollisionC0 = collisionWeld.C0,

		InitialBarrelRSize = barrelR.Size,
		InitialBarrelLSize = barrelL.Size,

		AnimationToken = 0,
		Busy = false,
	}

	gloveRigCache[tool] = rig
	return rig
end

local function setGloveRigAmount(rig, amount: number)
	-- Mover el glove hacia delante
	rig.GloveWeld.C0 = rig.InitialGloveC0 * CFrame.new(0, 0, GLOVE_FORWARD_SIGN * amount)

	-- BarrelR: crecer solo hacia delante en X
	rig.BarrelR.Size = Vector3.new(
		rig.InitialBarrelRSize.X + amount,
		rig.InitialBarrelRSize.Y,
		rig.InitialBarrelRSize.Z
	)
	rig.BarrelRWeld.C0 = rig.InitialBarrelRC0 * CFrame.new(-GLOVE_FORWARD_SIGN * (amount * 0.5), 0, 0)

	-- BarrelL: crecer solo hacia delante en X
	rig.BarrelL.Size = Vector3.new(
		rig.InitialBarrelLSize.X + amount,
		rig.InitialBarrelLSize.Y,
		rig.InitialBarrelLSize.Z
	)
	rig.BarrelLWeld.C0 = rig.InitialBarrelLC0 * CFrame.new(0, 0, GLOVE_FORWARD_SIGN * (amount * 0.5))

	-- Si quieres que el hitbox acompañe al puño, descomenta esto:
	-- rig.CollisionWeld.C0 = rig.InitialCollisionC0 * CFrame.new(0, 0, GLOVE_FORWARD_SIGN * amount)
end

local function resetGloveRig(rig)
	rig.Particles.Enabled = false
	setGloveRigAmount(rig, 0)
	rig.Busy = false
end

local function animateGloveAmount(rig, fromAmount: number, toAmount: number, duration: number, token: number)
	if duration <= 0 then
		setGloveRigAmount(rig, toAmount)
		return
	end

	local startTime = os.clock()

	while true do
		if rig.AnimationToken ~= token then
			return
		end

		local alpha = (os.clock() - startTime) / duration
		if alpha >= 1 then
			break
		end

		local eased = 1 - (1 - alpha) * (1 - alpha)
		local value = fromAmount + (toAmount - fromAmount) * eased
		setGloveRigAmount(rig, value)

		RunService.Heartbeat:Wait()
	end

	if rig.AnimationToken == token then
		setGloveRigAmount(rig, toAmount)
	end
end

local function playGloveShotFX(rig)
	rig.AnimationToken += 1
	local token = rig.AnimationToken
	rig.Busy = true

	rig.Particles.Enabled = true
	task.delay(GLOVE_PARTICLE_DURATION, function()
		if rig.Particles and rig.Particles.Parent and rig.AnimationToken == token then
			rig.Particles.Enabled = false
		end
	end)

	task.delay(GLOVE_RAGDOLL_LEAD, function()
		if rig.AnimationToken ~= token then
			return
		end

		animateGloveAmount(rig, 0, GLOVE_EXTEND_DISTANCE, GLOVE_EXTEND_TIME, token)

		task.delay(GLOVE_RETURN_DELAY, function()
			if rig.AnimationToken ~= token then
				return
			end

			animateGloveAmount(rig, GLOVE_EXTEND_DISTANCE, 0, GLOVE_RETURN_TIME, token)

			if rig.AnimationToken == token then
				rig.Busy = false
			end
		end)
	end)
end

local function getGloveHitTarget(player: Player, tool: Tool, hitbox: BasePart): (Model?, Humanoid?, BasePart?)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {player.Character, tool}
	overlapParams.MaxParts = 20

	local parts = Workspace:GetPartsInPart(hitbox, overlapParams)

	local bestCharacter = nil
	local bestHumanoid = nil
	local bestRoot = nil
	local bestDistance = math.huge

	local originRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	for _, part in ipairs(parts) do
		local character = getCharacterFromPart(part)
		if character and character ~= player.Character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local root = character:FindFirstChild("HumanoidRootPart")

			if humanoid and root and humanoid.Health > 0 then
				local distance = originRoot and (originRoot.Position - root.Position).Magnitude or 0
				if distance < bestDistance then
					bestDistance = distance
					bestCharacter = character
					bestHumanoid = humanoid
					bestRoot = root
				end
			end
		end
	end

	return bestCharacter, bestHumanoid, bestRoot
end

local function applyTemporaryRagdoll(targetCharacter: Model, humanoid: Humanoid, duration: number)
	local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)

	-- respaldo en server
	humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)

	-- orden correcta al cliente dueño del personaje
	if targetPlayer then
		ragdollRemote:FireClient(targetPlayer, duration)
	end

	task.delay(duration, function()
		if humanoid and humanoid.Parent then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		end
	end)
end

gloveGunRemote.OnServerEvent:Connect(function(player: Player, action: string, tool: Tool)
	if not tool or not tool:IsA("Tool") then return end
	if tool.Parent ~= player.Character then return end

	local rig = getGloveRig(tool)
	if not rig then
		return
	end

	if action == "Reset" then
		rig.AnimationToken += 1
		resetGloveRig(rig)
		gloveGunRemote:FireClient(player, "ResetLock", tool)
		return
	end

	if action ~= "Fire" then
		return
	end

	if rig.Busy then
		return
	end

	local isOnCooldown, remaining = CooldownManager.IsOnCooldown(player, GLOVE_COOLDOWN_KEY)
	if isOnCooldown then
		gloveGunRemote:FireClient(player, "CooldownDenied", tool, remaining)
		return
	end

	CooldownManager.Start(player, GLOVE_COOLDOWN_KEY, GLOVE_COOLDOWN_SECONDS)
	playGloveShotFX(rig)
	
	SoundManager:Play(nil, GLOVE_FIRE_SOUND_ID, {
		Volume = 3.5,
		Pool = 3,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		RollOffMinDistance = 8,
		RollOffMaxDistance = 45,
	}, rig.Handle)

	local hitCharacter, hitHumanoid, hitRoot = getGloveHitTarget(player, tool, rig.RagdollCollision)

	if not hitHumanoid or not hitRoot then
		return
	end
	
	SoundManager:Play(nil, GLOVE_HIT_SOUND_ID, {
		Volume = 4,
		Pool = 4,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		RollOffMinDistance = 8,
		RollOffMaxDistance = 35,
	}, hitRoot)

	applyTemporaryRagdoll(hitCharacter, hitHumanoid, GLOVE_RAGDOLL_DURATION)
	
	task.delay(GLOVE_RAGDOLL_LEAD, function()
		if not hitRoot or not hitRoot.Parent then
			return
		end

		local baseDirection = rig.Handle.CFrame.LookVector * -GLOVE_FORWARD_SIGN
		local launchDirection = getLaunchDirectionWithBias(baseDirection, GLOVE_LAUNCH_UPWARD_BIAS)

		hitRoot.AssemblyLinearVelocity = Vector3.zero
		hitRoot.AssemblyAngularVelocity = Vector3.zero

		launchCharacterPhysics(
			hitRoot,
			launchDirection,
			GLOVE_LAUNCH_INITIAL_SPEED,
			GLOVE_LAUNCH_FORCE,
			GLOVE_LAUNCH_FORCE_DURATION
		)
	end)
end)

----------------------------------------------------------------
-- SIZE POTIONS (MINIMIZATE & MAXIMIZATE)
----------------------------------------------------------------

-- Evento de la poción pequeña
minimizateRemote.OnServerEvent:Connect(function(player: Player, action: string)
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local currentState = character:GetAttribute("SizeState") or "Normal"
	if currentState == "Small" then return end -- Si ya es pequeño, abortamos

	if action == "Drink" then
		SoundManager:Play(nil, DRINK_SOUND_ID, { Volume = 1 }, root)

	elseif action == "Shrink" then
		-- Lógica de escalones: Si es Grande pasa a Normal, si es Normal pasa a Pequeño
		local targetState = (currentState == "Big") and "Normal" or "Small"

		print("Transformando al jugador de " .. currentState .. " a estado: " .. targetState)

		-- [CORREGIDO] Ahora pasamos currentState como tercer parámetro, y el delay como cuarto
		SizeManager:ChangeCharacterSize(character, targetState, currentState, 1)
		VoiceModulator:SetVoiceState(player, targetState)
	end
end)

-- Evento de la poción grande
maximizateRemote.OnServerEvent:Connect(function(player: Player, action: string)
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local currentState = character:GetAttribute("SizeState") or "Normal"
	if currentState == "Big" then return end -- Si ya es grande, abortamos

	if action == "Drink" then
		SoundManager:Play(nil, DRINK_SOUND_ID, { Volume = 1 }, root)

	elseif action == "Grow" then
		-- Lógica de escalones: Si es Pequeño pasa a Normal, si es Normal pasa a Grande
		local targetState = (currentState == "Small") and "Normal" or "Big"

		print("Transformando al jugador de " .. currentState .. " a estado: " .. targetState)

		-- [CORREGIDO] Ahora pasamos currentState como tercer parámetro, y el delay como cuarto
		SizeManager:ChangeCharacterSize(character, targetState, currentState, 1)
		VoiceModulator:SetVoiceState(player, targetState)
	end
end)

-- =================================================================
-- [SEGURO DE ESCALADO DE TOOLS (SERVER)]
-- Verifica el tamaño de la herramienta en el momento en que se equipa
-- =================================================================

function GetSizeCharacter(model)
	local piernaPartes = {"Head","UpperTorso","LowerTorso","LeftLowerLeg","LeftFoot","LeftUpperLeg"}
	local TamanoBody = 0
	for _,detail in piernaPartes do
		local Part:BasePart = model:FindFirstChild(detail)
		if not Part then return end
		TamanoBody += Part.Size.Y
	end
	return TamanoBody / 5.912
end

local function onCharacterAddedForTools(character: Model)
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			-- Un mini delay de 1 frame asegura que la Tool se ha anclado bien al jugador
			task.wait() 
			-- Leemos el tamaño actual del jugador (si no tiene, asumimos 1 normal)
			local targetScale = GetSizeCharacter(character) or 1

			print("ESCALARRRRRRRR", targetScale)
			child:ScaleTo(targetScale)
			
		end
	end)
end

local function onPlayerAddedForTools(player: Player)
	-- Si el personaje ya existe (porque cargó antes), lo conectamos
	if player.Character then 
		onCharacterAddedForTools(player.Character) 
	end

	-- Escuchamos cada vez que respawnee
	player.CharacterAdded:Connect(function(character) 
		onCharacterAddedForTools(character) 
	end)
end

-- Registramos el callback de forma segura con tu módulo
PlayerInit.Connect(onPlayerAddedForTools)