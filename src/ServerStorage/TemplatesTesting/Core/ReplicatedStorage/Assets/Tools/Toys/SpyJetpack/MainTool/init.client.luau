-- Asegúrate de que el juego esté cargado
if not game:IsLoaded() then
	game.Loaded:Wait()
end

-- ==========================================
-- CONSTANTES AJUSTADAS PARA CONTROL TOTAL
-- ==========================================
local FORCE = 70
local DRAG = 1
local GOING_UP_TIME = 0.1
local MAX_SPEED = 60
-- ==========================================

local ALPHA_LERP = 0.04
local FLY_ACTION_NAME = "Fly"
local GRAVITY_FORCE = workspace.Gravity

-- Servicios
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local remotes = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Tools")
local equipRemote = remotes.EquipToolAccesory
local flyRemote = remotes.Fly

local camera = workspace.CurrentCamera
local cooldown = true

local ZOOM_FOV_ADDITION = 15
local baseFOV -- ✅ guardamos el FOV real antes de volar

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Mobile Jump Button detection
local jumpButton = nil
if UserInputService.TouchEnabled then
	local touchGui = playerGui:WaitForChild("TouchGui")
	local touchControlFrame = touchGui:WaitForChild("TouchControlFrame")
	jumpButton = touchControlFrame:WaitForChild("JumpButton")
end

-- Tool / Accesory
local tool = script.Parent
local jetpackAccesory = script:WaitForChild("Jetpack")

local handle = jetpackAccesory:WaitForChild("Handle")
-- Efectos (del accesorio dentro de la tool)
local rightParticles = handle:WaitForChild("ParticlesRight"):WaitForChild("ParticleEmitter")
local leftParticles = handle:WaitForChild("ParticlesLeft"):WaitForChild("ParticleEmitter")
local startSound = handle:WaitForChild("StartSound")
local runningSound = handle:WaitForChild("RunningSound")
local endSound = handle:WaitForChild("EndSound")
local flyAnim = handle:WaitForChild("FlyAnim")

-- Estado vuelo
local flyingEvent = nil
local mobileGuiTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("JetpackMobileButtons")
local mobileGuiClone
local isGoingUp, isGoingDown = false, false

-- Referencias de personaje (se rellenan con setupCharacter)
local character
local humanoid
local humanoidRootPart

-- Fuerzas (se recrean por respawn)
local vectorForce
local alignOrientation

local function GetTotalMass()
	if not character then return 0 end
	local mass = 0
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			mass += part:GetMass()
		end
	end
	return mass
end

local function ShowMobileButtons()
	if not UserInputService.TouchEnabled or mobileGuiClone then return end
	mobileGuiClone = mobileGuiTemplate:Clone()
	mobileGuiClone.Parent = playerGui
	if jumpButton then jumpButton.Visible = false end

	mobileGuiClone:WaitForChild("UpButton").MouseButton1Down:Connect(function() isGoingUp = true end)
	mobileGuiClone.UpButton.MouseButton1Up:Connect(function() isGoingUp = false end)

	mobileGuiClone:WaitForChild("DownButton").MouseButton1Down:Connect(function() isGoingDown = true end)
	mobileGuiClone.DownButton.MouseButton1Up:Connect(function() isGoingDown = false end)
end

local function HideMobileButtons()
	if mobileGuiClone then
		mobileGuiClone:Destroy()
		mobileGuiClone = nil
	end
	isGoingUp, isGoingDown = false, false
	if jumpButton then jumpButton.Visible = true end
end

local function BuildForces(hrp: BasePart)
	-- Si el jugador respawnea, destruimos fuerzas viejas
	if vectorForce then vectorForce:Destroy() end
	if alignOrientation then alignOrientation:Destroy() end

	vectorForce = Instance.new("VectorForce")
	vectorForce.Enabled = false
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.Attachment0 = hrp:WaitForChild("RootRigAttachment")
	vectorForce.Parent = hrp

	alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Enabled = false
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.MaxAngularVelocity = math.huge
	alignOrientation.MaxTorque = math.huge
	alignOrientation.Responsiveness = 25
	alignOrientation.Attachment0 = vectorForce.Attachment0
	alignOrientation.Parent = hrp
end

local function setupCharacter(char: Model)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	BuildForces(humanoidRootPart)

	-- failsafe: si muere, paramos vuelo y restauramos FOV
	humanoid.Died:Connect(function()
		if flyingEvent then
			-- llama a StopFlying “suave” (abajo)
			if camera then camera.FieldOfView = baseFOV or camera.FieldOfView end
		end
	end)
end

-- Inicial + respawn
setupCharacter(localPlayer.Character or localPlayer.CharacterAdded:Wait())
localPlayer.CharacterAdded:Connect(function(char)
	-- Si respawnea y estabas volando: cortamos
	if flyingEvent then
		-- StopFlying usa humanoid/humanoidRootPart, así que esperamos un tick
		task.defer(function()
			-- no llamamos StopFlying aquí directo porque aún no se han recreado fuerzas
			-- pero sí restauramos FOV por seguridad:
			if camera then camera.FieldOfView = baseFOV or camera.FieldOfView end
		end)
	end
	setupCharacter(char)
end)

local function StartFlying()
	-- ✅ evita Heartbeats duplicados (clave para FOV atascado)
	if flyingEvent then return end
	if not humanoid or not humanoidRootPart or not vectorForce or not alignOrientation then return end

	-- ✅ guarda el FOV real antes de tocarlo
	baseFOV = camera.FieldOfView

	vectorForce.Enabled = true
	alignOrientation.Enabled = true
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			track:Stop()
		end
		animator:LoadAnimation(flyAnim):Play()
	end

	flyRemote:FireServer(rightParticles, leftParticles, true, startSound, runningSound, endSound)

	local t = 0
	flyingEvent = RunService.Heartbeat:Connect(function(deltaTime)
		t += deltaTime
		local currentMass = GetTotalMass()
		if currentMass <= 0 then return end

		-- 1. ANTIGRAVEDAD
		vectorForce.Force = Vector3.new(0, GRAVITY_FORCE * currentMass, 0)

		-- 2. ORIENTACIÓN
		alignOrientation.CFrame = CFrame.lookAt(
			humanoidRootPart.Position,
			humanoidRootPart.Position + camera.CFrame.LookVector,
			Vector3.yAxis
		)

		-- 3. INPUT
		local moveVector = Vector3.zero
		if not UserInputService.TouchEnabled then
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector += camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector -= camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector += camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector -= camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector += Vector3.yAxis end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector -= Vector3.yAxis end
		else
			moveVector = humanoid.MoveDirection
			if isGoingUp then moveVector += Vector3.yAxis end
			if isGoingDown then moveVector -= Vector3.yAxis end
		end

		-- Impulso inicial suave
		if t < GOING_UP_TIME and moveVector.Magnitude == 0 then
			moveVector += Vector3.yAxis * 0.3
		end

		-- Aplicar movimiento
		if moveVector.Magnitude > 0 then
			vectorForce.Force += moveVector.Unit * FORCE * currentMass
		end

		-- 4. DRAG
		local velocity = humanoidRootPart.AssemblyLinearVelocity
		if velocity.Magnitude > 0 then
			local dragMultiplier = (velocity.Magnitude > MAX_SPEED) and 5 or DRAG
			vectorForce.Force -= velocity * (dragMultiplier * currentMass)
		end

		-- 5. CÁMARA (smooth)
		local isMoving = moveVector.Magnitude > 0
		local targetFOV = isMoving and ((baseFOV or camera.FieldOfView) + ZOOM_FOV_ADDITION) or (baseFOV or camera.FieldOfView)
		camera.FieldOfView = (1 - ALPHA_LERP) * camera.FieldOfView + ALPHA_LERP * targetFOV
	end)

	ShowMobileButtons()
end

local function StopFlying()
	-- ✅ esto hace que Unequipped pueda llamarlo SIEMPRE sin romper nada
	if flyingEvent then
		flyingEvent:Disconnect()
		flyingEvent = nil
	end

	-- apagar FX en servidor
	flyRemote:FireServer(rightParticles, leftParticles, false, startSound, runningSound, endSound)

	if vectorForce then vectorForce.Enabled = false end
	if alignOrientation then alignOrientation.Enabled = false end

	if humanoid then
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				if track.Animation == flyAnim then
					track:Stop()
				end
			end
		end

		humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		humanoid.CameraOffset = Vector3.zero
	end

	-- ✅ restaura FOV real
	if camera then
		camera.FieldOfView = baseFOV or camera.FieldOfView
	end

	HideMobileButtons()
end

local function ToggleFly(actionName, inputState)
	if inputState ~= Enum.UserInputState.Begin then return end
	if not cooldown then return end

	cooldown = false
	if not flyingEvent then
		StartFlying()
	else
		StopFlying()
	end
	task.wait(0.6)
	cooldown = true
end

tool.Equipped:Connect(function()
	equipRemote:FireServer(tool.Handle, jetpackAccesory, true)
	ContextActionService:BindAction(FLY_ACTION_NAME, ToggleFly, true, Enum.KeyCode.F)
end)

tool.Unequipped:Connect(function()
	ContextActionService:UnbindAction(FLY_ACTION_NAME)

	-- ✅ IMPORTANTE: SIEMPRE parar (aunque flyingEvent sea nil, es seguro)
	StopFlying()

	equipRemote:FireServer(tool.Handle, jetpackAccesory, false)
end)

tool.Activated:Connect(function()
	ToggleFly(nil, Enum.UserInputState.Begin)
end)