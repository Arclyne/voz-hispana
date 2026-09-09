--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Shared = ReplicatedStorage:WaitForChild("Shared")
local NametagFolder = Shared:WaitForChild("Nametag")
local GroupRolesModule = NametagFolder:WaitForChild("GroupRoles")
local TemplatesFolder = GroupRolesModule:WaitForChild("Templates")
local MicStatus = require(NametagFolder:WaitForChild("MicStatus"))

local PlayerInit = require(ReplicatedStorage:WaitForChild("PlayerInit"))
local UpdateMicEvent = ReplicatedStorage:WaitForChild("UpdateMicEvent") :: RemoteEvent

local MIC_TAG_NAME = "6MicTag"
local MIC_LAYOUT_ORDER = 6

-- [UserId_String] = boolean
local canHearMap: {[string]: boolean} = {}

local audioInputConnections: {[Player]: RBXScriptConnection} = {}

-- =======================
-- Utilidades
-- =======================

local function findTagContainer(root: Instance): Instance
	local byName = root:FindFirstChild("Holder", true)

	if byName and byName:IsA("GuiObject") then
		return byName
	end

	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("Frame") and descendant:FindFirstChildOfClass("UIListLayout") then
			return descendant
		end
	end

	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("Frame") then
			return descendant
		end
	end

	return root
end

local function removeMicIcon(character: Model)
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end

	local nametag = head:FindFirstChild("NameTag")
	if not nametag then
		return
	end

	local container = findTagContainer(nametag)
	local existingMic = container:FindFirstChild(MIC_TAG_NAME)

	if existingMic then
		existingMic:Destroy()
	end
end

-- =======================
-- Actualización de UI
-- =======================

local function addMicIcon(player: Player, character: Model)
	if player == LocalPlayer then
		return
	end

	local head = character:WaitForChild("Head", 10)
	if not head then
		return
	end

	local nametag = head:WaitForChild("NameTag", 10)
	if not nametag then
		return
	end

	local container = findTagContainer(nametag)

	local userIdStr = tostring(player.UserId)
	local canChat = canHearMap[userIdStr]

	-- IMPORTANTE:
	-- nil significa "el servidor aún no me ha dado dato de este jugador".
	-- No lo convertimos en false para evitar falsos iconos.
	if canChat == nil then
		MicStatus.Set(player, nil)

		print(string.format(
			"[MicClient] %s -> sin dato todavía, no actualizo icono",
			player.Name
			))
		return
	end

	local existingMic = container:FindFirstChild(MIC_TAG_NAME)
	if existingMic then
		existingMic:Destroy()
	end

	print(string.format(
		"[MicClient] %s -> ¿Podemos hablar? %s",
		player.Name,
		tostring(canChat)
		))

	local active: boolean? = nil

	if canChat then
		local audioInput = player:FindFirstChildWhichIsA("AudioDeviceInput")

		if audioInput then
			active = audioInput.Active
		end
	end

	local templateName = MicStatus.Resolve(canChat, active)

	MicStatus.Set(player, templateName)

	if not templateName then
		return
	end

	local template = TemplatesFolder:FindFirstChild(templateName)

	if template and template:IsA("GuiObject") then
		local clone = template:Clone()
		clone.Name = MIC_TAG_NAME
		clone.LayoutOrder = MIC_LAYOUT_ORDER
		clone.Parent = container
	else
		warn("[MicClient] ❌ No se encontró la plantilla válida:", templateName)
	end
end

local function refreshAllMicIcons()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			task.spawn(addMicIcon, player, player.Character)
		end
	end
end

local function connectAudioInput(player: Player, audioInput: AudioDeviceInput)
	local oldConnection = audioInputConnections[player]

	if oldConnection then
		oldConnection:Disconnect()
	end

	audioInputConnections[player] = audioInput:GetPropertyChangedSignal("Active"):Connect(function()
		if player.Character then
			task.spawn(addMicIcon, player, player.Character)
		end
	end)

	if player.Character then
		task.spawn(addMicIcon, player, player.Character)
	end
end

-- =======================
-- Escuchar al servidor
-- =======================

UpdateMicEvent.OnClientEvent:Connect(function(newList)
	if typeof(newList) ~= "table" then
		warn("[MicClient] ❌ Lista de compatibilidad inválida recibida del servidor")
		return
	end

	print("[MicClient] ✅ Nueva lista de compatibilidad recibida del servidor")

	canHearMap = newList :: {[string]: boolean}

	refreshAllMicIcons()
end)

-- =======================
-- Ciclo de vida del jugador
-- =======================

local function onCharacterAdded(player: Player, character: Model)
	task.spawn(function()
		addMicIcon(player, character)
	end)
end

local function onPlayerAdded(player: Player)
	if player == LocalPlayer then
		return
	end

	if player.Character then
		onCharacterAdded(player, player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)

	local audioInput = player:FindFirstChildWhichIsA("AudioDeviceInput")
	if audioInput then
		connectAudioInput(player, audioInput)
	end

	player.ChildAdded:Connect(function(child)
		if child:IsA("AudioDeviceInput") then
			connectAudioInput(player, child)
		end
	end)

	player.ChildRemoved:Connect(function(child)
		if child:IsA("AudioDeviceInput") then
			local connection = audioInputConnections[player]

			if connection then
				connection:Disconnect()
				audioInputConnections[player] = nil
			end

			if player.Character then
				task.spawn(addMicIcon, player, player.Character)
			else
				MicStatus.Set(player, nil)
			end
		end
	end)
end

local function onPlayerRemoving(player: Player)
	canHearMap[tostring(player.UserId)] = nil
	MicStatus.Set(player, nil)

	local connection = audioInputConnections[player]
	if connection then
		connection:Disconnect()
		audioInputConnections[player] = nil
	end

	if player.Character then
		removeMicIcon(player.Character)
	end
end

PlayerInit.Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)