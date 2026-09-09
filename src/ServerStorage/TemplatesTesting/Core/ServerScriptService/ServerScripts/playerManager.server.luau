local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerInit = require(ReplicatedStorage:WaitForChild("PlayerInit"))

local EventsRoot = ReplicatedStorage:WaitForChild("Events")
local playerEvents = EventsRoot:WaitForChild("Player")

local playersLoaded = {}
local lastLoadRequestAt = {}
local respawning = {}

local LOAD_REQUEST_COOLDOWN = 2
local RESPAWN_DELAY = 3
local CHARACTER_READY_TIMEOUT = 15

local showNotificationEvent = playerEvents:WaitForChild("ShowNotification")
local loadCharacterRequest = playerEvents:WaitForChild("LoadCharacterRequest")

local InitScriptsReadyFlag = ReplicatedStorage:WaitForChild("InitScriptsReadyFlag")

local function canProcessLoadCharacterRequest(player)
	if not player or player.Parent ~= Players then
		return false, "Jugador no válido"
	end

	local now = os.clock()
	local lastRequest = lastLoadRequestAt[player]

	if lastRequest and now - lastRequest < LOAD_REQUEST_COOLDOWN then
		return false, "Cooldown"
	end

	lastLoadRequestAt[player] = now

	if not InitScriptsReadyFlag.Value then
		return false, "InitScripts todavía no está listo"
	end

	if playersLoaded[player] then
		return false, "Character ya solicitado/cargado"
	end

	return true
end

local function waitUntilCharacterIsInWorkspace(player, character, timeout)
	local start = os.clock()

	while os.clock() - start < timeout do
		if player.Parent ~= Players then
			return false
		end

		if player.Character ~= character then
			return false
		end

		if character and character:IsDescendantOf(workspace) then
			return true
		end

		task.wait(0.1)
	end

	return false
end

local function respawnPlayer(player)
	if respawning[player] then
		return
	end

	respawning[player] = true

	task.delay(RESPAWN_DELAY, function()
		if player.Parent ~= Players then
			respawning[player] = nil
			return
		end

		local ok, err = pcall(function()
			player:LoadCharacterAsync()
		end)

		if not ok then
			warn("[playerManager] Error respawneando a", player.Name, err)
		end

		respawning[player] = nil
	end)
end

local function onCharacterAdded(player, character)
	task.spawn(function()
		if not player or player.Parent ~= Players then
			return
		end

		if not character then
			return
		end

		local inWorkspace = waitUntilCharacterIsInWorkspace(player, character, CHARACTER_READY_TIMEOUT)
		if not inWorkspace then
			warn("[playerManager] Character no llegó a Workspace para", player.Name)
			return
		end

		local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
		if humanoidRootPart then
			humanoidRootPart:AddTag("Player")
		else
			warn("[playerManager] No se encontró HumanoidRootPart para", player.Name)
		end

		local humanoid = character:WaitForChild("Humanoid", 10)
		if not humanoid then
			warn("[playerManager] No se encontró Humanoid para", player.Name)
			return
		end

		humanoid.Died:Once(function()
			if player.Parent ~= Players then
				return
			end

			respawnPlayer(player)
		end)
	end)
end

loadCharacterRequest.OnServerEvent:Connect(function(player)
	local canProcess, reason = canProcessLoadCharacterRequest(player)

	if not canProcess then
		if reason ~= "Cooldown" and reason ~= "Character ya solicitado/cargado" then
			warn("[playerManager] LoadCharacterRequest rechazado para", player and player.Name, "-", reason)
		end

		return
	end

	if player.Character and player.Character.Parent then
		playersLoaded[player] = true
		return
	end

	playersLoaded[player] = true

	local ok, err = pcall(function()
		player:LoadCharacterAsync()
	end)

	if not ok then
		playersLoaded[player] = nil
		warn("[playerManager] Error en player:LoadCharacter() para", player.Name, err)
	end
end)

local function OnPlayerAdded(player)
	local joinData = player:GetJoinData()
	local vieneDeOtroPlace = joinData.SourcePlaceId ~= nil

	if player:GetAttribute("PlayerManagerLoaded") then
		return
	end
	player:SetAttribute("PlayerManagerLoaded", true)
	
	player.DevEnableMouseLock = false

	player.CharacterAdded:Connect(function(newCharacter)
		onCharacterAdded(player, newCharacter)
	end)

	if player.Character then
		onCharacterAdded(player, player.Character)
	end

	task.spawn(function()
		local character = player.Character

		if not character then
			character = player.CharacterAdded:Wait()
		end

		task.wait(3)

		if player.Parent == Players and not vieneDeOtroPlace then
			showNotificationEvent:FireClient(
				player,
				"Bienvenido!",
				"Esto es una versión Beta. Pueden esperarse bugs.",
				10,
				101262602775246,
				"rotate"
			)
		end
	end)
end

PlayerInit.Connect(OnPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	playersLoaded[player] = nil
	lastLoadRequestAt[player] = nil
	respawning[player] = nil
end)