--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local PlayerInit = require(ReplicatedStorage:WaitForChild("PlayerInit"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local NametagFolder = Shared:WaitForChild("Nametag")
local MicStatus = require(NametagFolder:WaitForChild("MicStatus"))

local function printMicStatus(player: Player)
	if player == LocalPlayer then
		return
	end

	local status = MicStatus.Get(player)

	print(
		"[MicStatusExample]",
		player.Name,
		"->",
		status
	)

	if status == "6OpenMic" then
		print(player.Name .. " puede hablar contigo y tiene el micro abierto")

	elseif status == "6CloseMic" then
		print(player.Name .. " puede hablar contigo pero tiene el micro cerrado")

	elseif status == "6NoMic" then
		print(player.Name .. " no puede hablar contigo")

	else
		print(player.Name .. " todavía no tiene estado de micro disponible")
	end
end

local function onPlayerAdded(player: Player)
	if player == LocalPlayer then
		return
	end

	print("[MicStatusExample] Jugador detectado:", player.Name)

	-- Consultar el estado actual.
	-- Puede ser nil si NametagMicClient todavía no ha recibido
	-- la información del servidor.
	printMicStatus(player)
end

local function onPlayerRemoving(player: Player)
	if player == LocalPlayer then
		return
	end

	print("[MicStatusExample] Jugador saliendo:", player.Name)
end

-- =======================
-- Cambios en tiempo real
-- =======================

MicStatus.Changed:Connect(function(userId, status)
	local player = Players:GetPlayerByUserId(userId)

	if not player then
		return
	end

	print(
		"[MicStatusExample] CAMBIO:",
		player.Name,
		"->",
		status
	)

	if status == "6OpenMic" then
		print("→", player.Name, "puede hablar contigo y tiene el micro abierto")

	elseif status == "6CloseMic" then
		print("→", player.Name, "puede hablar contigo pero tiene el micro cerrado")

	elseif status == "6NoMic" then
		print("→", player.Name, "no puede hablar contigo")

	else
		print("→", player.Name, "ya no tiene estado de micro disponible")
	end
end)

-- =======================
-- Consultar todos los estados
-- =======================

task.delay(5, function()
	print("========== MIC STATUS ==========")

	local allStatuses = MicStatus.GetAll()

	for userId, status in pairs(allStatuses) do
		local player = Players:GetPlayerByUserId(tonumber(userId) or 0)

		if player then
			print(player.Name, "->", status)
		else
			print("UserId " .. userId, "->", status)
		end
	end

	print("===============================")
end)

PlayerInit.Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)