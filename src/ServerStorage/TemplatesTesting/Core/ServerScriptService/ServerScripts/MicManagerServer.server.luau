--!strict

local Players = game:GetService("Players")
local VoiceChatService = game:GetService("VoiceChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- RemoteEvent Server -> Client
local existingEvent = ReplicatedStorage:FindFirstChild("UpdateMicEvent")
local UpdateMicEvent: RemoteEvent

if existingEvent and existingEvent:IsA("RemoteEvent") then
	UpdateMicEvent = existingEvent
else
	if existingEvent then
		existingEvent:Destroy()
	end

	UpdateMicEvent = Instance.new("RemoteEvent")
	UpdateMicEvent.Name = "UpdateMicEvent"
	UpdateMicEvent.Parent = ReplicatedStorage
end

-- Evita que resultados antiguos sobrescriban resultados nuevos
local requestVersion = 0
local workerRunning = false

local function makeGroupSet(groups: {any}): {[string]: boolean}
	local set: {[string]: boolean} = {}

	for _, groupId in ipairs(groups) do
		if typeof(groupId) == "string" then
			set[groupId] = true
		end
	end

	return set
end

local function shareAnyGroup(a: {[string]: boolean}?, b: {[string]: boolean}?): boolean
	if not a or not b then
		return false
	end

	for groupId in pairs(a) do
		if b[groupId] then
			return true
		end
	end

	return false
end

local function sendMicPermissions(allPlayers: {Player}, groupsArray: {any})
	local playerGroups: {[Player]: {[string]: boolean}} = {}

	for i, player in ipairs(allPlayers) do
		local rawGroups = groupsArray[i]

		if typeof(rawGroups) ~= "table" then
			rawGroups = {}
		end

		playerGroups[player] = makeGroupSet(rawGroups)

		print(string.format(
			"[MicServer] %s groups = %s",
			player.Name,
			HttpService:JSONEncode(rawGroups)
			))
	end

	for _, targetPlayer in ipairs(allPlayers) do
		if targetPlayer.Parent == Players then
			local compatibilityList: {[string]: boolean} = {}
			local targetGroups = playerGroups[targetPlayer]

			for _, otherPlayer in ipairs(allPlayers) do
				if otherPlayer ~= targetPlayer and otherPlayer.Parent == Players then
					local otherGroups = playerGroups[otherPlayer]
					local canChat = shareAnyGroup(targetGroups, otherGroups)

					compatibilityList[tostring(otherPlayer.UserId)] = canChat
				end
			end

			print(string.format(
				"[MicServer] Enviando lista a %s: %s",
				targetPlayer.Name,
				HttpService:JSONEncode(compatibilityList)
				))

			UpdateMicEvent:FireClient(targetPlayer, compatibilityList)
		end
	end
end

local function requestMicUpdate(reason: string)
	requestVersion += 1
	local requestedVersion = requestVersion

	print(string.format(
		"[MicServer] Update solicitado: %s | versión=%d",
		reason,
		requestedVersion
		))

	if workerRunning then
		return
	end

	workerRunning = true

	task.spawn(function()
		while true do
			local myVersion = requestVersion
			local allPlayers = Players:GetPlayers()

			if #allPlayers < 1 then
				break
			end

			print(string.format(
				"[MicServer] Solicitando grupos de chat | versión=%d | jugadores=%d",
				myVersion,
				#allPlayers
				))

			local success, result = pcall(function()
				return (VoiceChatService :: any):GetChatGroupsAsync(allPlayers)
			end)

			if not success then
				if not RunService:IsStudio() and tostring(result):find("disabled") then
					warn("[MicServer] ❌ Error en GetChatGroupsAsync. Detalles:", result)
				end
			elseif myVersion ~= requestVersion then
				print(string.format(
					"[MicServer] Ignorando resultado viejo versión=%d. Versión actual=%d",
					myVersion,
					requestVersion
					))
			else
				local groupsArray = result

				if typeof(groupsArray) ~= "table" then
					warn("[MicServer] ❌ GetChatGroupsAsync no devolvió una tabla válida")
				else
					sendMicPermissions(allPlayers, groupsArray)
				end
			end

			-- Si mientras esperábamos se pidió otro update, repetimos una vez más
			if myVersion == requestVersion then
				break
			end
		end

		workerRunning = false
	end)
end

local function scheduleMicRefresh(reason: string)
	-- Primera pasada rápida
	task.delay(0.5, function()
		requestMicUpdate(reason .. " +0.5s")
	end)

	-- Segunda pasada cuando Roblox ya debería haber estabilizado VoiceChat
	task.delay(3, function()
		requestMicUpdate(reason .. " +3s")
	end)

	-- Tercera pasada de seguridad para casos lentos de carga
	task.delay(8, function()
		requestMicUpdate(reason .. " +8s")
	end)
end

Players.PlayerAdded:Connect(function(player)
	scheduleMicRefresh("PlayerAdded " .. player.Name)
end)

Players.PlayerRemoving:Connect(function(player)
	task.delay(0.5, function()
		requestMicUpdate("PlayerRemoving " .. player.Name)
	end)

	task.delay(3, function()
		requestMicUpdate("PlayerRemoving retry")
	end)
end)

task.delay(2, function()
	requestMicUpdate("Startup")
end)