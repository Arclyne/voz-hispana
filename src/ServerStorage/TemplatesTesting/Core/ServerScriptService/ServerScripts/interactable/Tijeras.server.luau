local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local remotes = ReplicatedStorage:WaitForChild("Events")
local StartCut = remotes.Interactable:WaitForChild("StartCut")
local EndCut = remotes.Interactable:WaitForChild("EndCut")
local CancelCut = remotes.Interactable:WaitForChild("CancellCut")
local CutBarEvent = remotes.Interactable:WaitForChild("CutBar")

local CooldownManager = require(ReplicatedStorage.Shared.Cooldown:WaitForChild("CooldownManager"))

local COOLDOWN_SECONDS = 30
local MAX_DISTANCE = 15
local CUT_DURATION = 3

-- key = targetCharacterModel, value = cutterPlayer
local ActiveCuts: {[Model]: Player} = {}

local function getRoot(model: Model): BasePart?
	return model:FindFirstChild("HumanoidRootPart")
end

local function getHead(model: Model): BasePart?
	return model:FindFirstChild("Head")
end

local function isValidCharacter(model: any): boolean
	return typeof(model) == "Instance"
		and model:IsA("Model")
		and model:FindFirstChildOfClass("Humanoid") ~= nil
		and getRoot(model) ~= nil
		and getHead(model) ~= nil
end

StartCut.OnServerEvent:Connect(function(player, targetCharacter: Model)
	if CooldownManager.IsOnCooldown(player, "Tijeras") then return end
	if not isValidCharacter(targetCharacter) then return end
	if player.Character == targetCharacter then return end

	local playerChar = player.Character
	if not playerChar then return end

	local playerRoot = getRoot(playerChar)
	local targetRoot = getRoot(targetCharacter)
	if not playerRoot or not targetRoot then return end

	if (playerRoot.Position - targetRoot.Position).Magnitude > MAX_DISTANCE then
		return
	end

	if ActiveCuts[targetCharacter] then return end
	ActiveCuts[targetCharacter] = player

	-- ✅ IMPORTANTE: manda duración para que el controller global la use
	CutBarEvent:FireAllClients(targetCharacter, player, CUT_DURATION)

	-- Partículas
	local head = getHead(targetCharacter)
	if head then
		local existing = head:FindFirstChild("Particles")
		if existing then existing:Destroy() end

		local particles = ReplicatedStorage.Assets.ToolsAssets.SccisorsAssets.Particles:Clone()
		particles.Name = "Particles"
		particles.Parent = head
	end

	-- Sonido
	local soundFolder = ReplicatedStorage.Assets.ToolsAssets.SccisorsAssets.Sounds
	local availableSounds = soundFolder:GetChildren()
	if #availableSounds > 0 then
		local randomSound = availableSounds[math.random(1, #availableSounds)]:Clone()
		randomSound.Parent = targetCharacter
		randomSound:Play()
		Debris:AddItem(randomSound, randomSound.TimeLength)
	end
end)

EndCut.OnServerEvent:Connect(function(player, targetCharacter: Model)
	if not isValidCharacter(targetCharacter) then return end
	if ActiveCuts[targetCharacter] ~= player then return end
	ActiveCuts[targetCharacter] = nil

	-- Quitar partículas
	local head = getHead(targetCharacter)
	if head then
		local p = head:FindFirstChild("Particles")
		if p then p:Destroy() end
	end

	-- Cortar pelo
	local currentHair: Accessory? = nil
	for _, accessory in ipairs(targetCharacter:GetChildren()) do
		if accessory:IsA("Accessory") and accessory.AccessoryType == Enum.AccessoryType.Hair then
			currentHair = accessory
			break
		end
	end

	local accessoriesFolder = ReplicatedStorage.Assets.ToolsAssets.SccisorsAccesorys
	local changed = false

	if currentHair then
		local currentHairName = currentHair.Name
		currentHair:Destroy()

		local available = {}
		for _, accessory in ipairs(accessoriesFolder:GetChildren()) do
			if accessory.Name ~= currentHairName then
				table.insert(available, accessory)
			end
		end

		if #available > 0 then
			available[math.random(1, #available)]:Clone().Parent = targetCharacter
			changed = true
		else
			local fallback = accessoriesFolder:FindFirstChild(currentHairName)
			if fallback then
				fallback:Clone().Parent = targetCharacter
				changed = true
			end
		end
	else
		local available = accessoriesFolder:GetChildren()
		if #available > 0 then
			available[math.random(1, #available)]:Clone().Parent = targetCharacter
			changed = true
		end
	end

	if changed then
		CooldownManager.Start(player, "Tijeras", COOLDOWN_SECONDS)
	end
end)

CancelCut.OnServerEvent:Connect(function(player, targetCharacter: Model)
	if not isValidCharacter(targetCharacter) then return end
	if ActiveCuts[targetCharacter] ~= player then return end

	ActiveCuts[targetCharacter] = nil

	-- Quitar partículas
	local head = getHead(targetCharacter)
	if head then
		local p = head:FindFirstChild("Particles")
		if p then p:Destroy() end
	end

	-- ✅ esto hace que el controller global borre la barra antes de tiempo
	CancelCut:FireAllClients(targetCharacter)
end)
