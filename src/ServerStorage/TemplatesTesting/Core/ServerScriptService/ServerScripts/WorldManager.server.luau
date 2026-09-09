--!strict
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local HousesInfo = require(ReplicatedStorage:WaitForChild("HousesInfo"))
local worldSystemStorage = ServerStorage:WaitForChild("WorldSystem")
local Profiles = require(worldSystemStorage:WaitForChild("Profiles"))
local ServerPresence = require(worldSystemStorage:WaitForChild("ServerPresence"))

local ATTEMPT_LIMIT = 3
local RETRY_DELAY = 0.5
local STAGED_POLL_ATTEMPTS = 10
local STAGED_POLL_INTERVAL = 1
local LOCAL_STAGE_TTL = 30
local PlaceKeyToPlaceId: {[string]: number} = {
	["karaoke"] = 129043234524029,
	["lobby"] = 94068794823958,
	["plsDonate"] = 82871403803520,
	["arcadeClub"] = 83856919904540
}

local events = ReplicatedStorage:WaitForChild("Events")
local worldSystem = events:WaitForChild("WorldSystem")

local JoinServerFunc = worldSystem:WaitForChild("JoinServer") :: RemoteFunction
local JoinWorldFunc = worldSystem:WaitForChild("JoinWorld") :: RemoteFunction

local activeMap = ServerPresence.GetActiveMap()

local function safeTeleport(placeId: number, player: Player, opts: TeleportOptions): (boolean, string?)
	if not RunService:IsStudio() then
		local attemptIndex = 0
		local success, result
		repeat
			attemptIndex += 1
			success, result = pcall(TeleportService.TeleportAsync, TeleportService, placeId, {player}, opts)
			if not success then
				warn(string.format("[WorldManager] Teleport fail (%d): %s", attemptIndex, result))
				task.wait(RETRY_DELAY)
			end
		until success or attemptIndex == ATTEMPT_LIMIT

		if not success then
			return false, "TeleportFailed: " .. tostring(result)
		end
	else
		warn("[WorldManager] Teleport ignored in studio")
	end
	return true, nil
end

local function reserveAccessCode(placeId: number): string?
	if RunService:IsStudio() then
		return HttpService:GenerateGUID(false)
	end
	local ok, code = pcall(TeleportService.ReserveServer, TeleportService, placeId)
	if ok then
		return code
	end
	warn("[WorldManager] ReserveServer failed:", code)
	return nil
end

local function parseRoomKey(serverKey: string): (number?, string?)
	if typeof(serverKey) ~= "string" then
		return nil, nil
	end
	local userIdStr, roomName = serverKey:match("^(%d+)_(.+)$")
	if not userIdStr or not roomName then
		return nil, nil
	end
	local userId = tonumber(userIdStr)
	if not userId then
		return nil, nil
	end
	return userId, roomName
end

local function teleportToHost(player: Player, serverKey: string, meta: any): (boolean, string?)
	if typeof(meta) ~= "table" or typeof(meta.placeId) ~= "number" or typeof(meta.accessCode) ~= "string" then
		return false, "Malformed host metadata"
	end
	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ReservedServerAccessCode = meta.accessCode
	teleportOptions:SetTeleportData({ key = serverKey, placeId = meta.placeId, accessCode = meta.accessCode })
	return safeTeleport(meta.placeId, player, teleportOptions)
end

local function waitForStagedHost(serverKey: string): any?
	for _ = 1, STAGED_POLL_ATTEMPTS do
		local owner, meta = Profiles.World.peek(serverKey)
		if owner and meta then
			return meta
		end
		local stager, stageMeta = Profiles.World.peekStaged(serverKey)
		if typeof(stageMeta) == "table" and stageMeta.accessCode then
			return stageMeta
		end
		if not stager then
			return nil
		end
		task.wait(STAGED_POLL_INTERVAL)
	end
	return nil
end

type LocalStage = { meta: any?, expires: number }
local localStages: { [string]: LocalStage } = {}

local function getLocalStage(serverKey: string): LocalStage?
	local stage = localStages[serverKey]
	if stage and os.clock() < stage.expires then
		return stage
	end
	localStages[serverKey] = nil
	return nil
end

local function hostWorld(player: Player, serverKey: string, roomInfo: any): (boolean, string?)
	local localStage = getLocalStage(serverKey)
	if localStage then
		if localStage.meta then
			return teleportToHost(player, serverKey, localStage.meta)
		end
		local meta = waitForStagedHost(serverKey)
		if meta then
			return teleportToHost(player, serverKey, meta)
		end
		return false, "Server is pending"
	end
	localStages[serverKey] = { expires = os.clock() + LOCAL_STAGE_TTL }

	local claim, current = Profiles.World.claimStaged(serverKey, { placeId = roomInfo.placeId })

	if claim then
		local code = reserveAccessCode(roomInfo.placeId)
		if not code then
			localStages[serverKey] = nil
			claim:release()
			return false, "The server could not be reserved"
		end
		local meta = { placeId = roomInfo.placeId, accessCode = code }
		localStages[serverKey] = { meta = meta, expires = os.clock() + LOCAL_STAGE_TTL }
		claim:setMeta(meta)
		claim:tryClaim()
		return teleportToHost(player, serverKey, meta)
	end

	localStages[serverKey] = nil

	if current and current.kind == "hosted" then
		return teleportToHost(player, serverKey, current.meta)
	end

	if current and current.kind == "staged" then
		local meta = current.meta
		if not (typeof(meta) == "table" and meta.accessCode) then
			meta = waitForStagedHost(serverKey)
		end
		if meta then
			return teleportToHost(player, serverKey, meta)
		end
		return false, "Server is pending"
	end

	return false, "The server could not be reserved"
end

JoinServerFunc.OnServerInvoke = function(player: Player, serverKey: string)
	if typeof(serverKey) ~= "string" then
		return false, "Invalid Server Key"
	end

	local _userId, roomName = parseRoomKey(serverKey)
	local roomInfo = roomName and HousesInfo[roomName]

	if roomInfo then
		return hostWorld(player, serverKey, roomInfo)
	end

	local entry, err = ServerPresence.SafeGet(activeMap, serverKey)
	if err then
		return false, "Error trying to get the server"
	end
	if not entry then
		return false, "Server not found"
	end

	local hostingType = entry.hostingType or "default"

	-- El evento corre en un servidor reservado: hay que entrar con su accessCode,
	-- no por jobId. El code sale del registro de MemoryStore, nunca del cliente.
	if hostingType == "event" then
		return teleportToHost(player, serverKey, { placeId = entry.placeId, accessCode = entry.code })
	end

	if hostingType ~= "default" then
		return false, "Unsupported hosting type"
	end

	local placeId = entry.placeId
	local jobId = entry.jobId
	if typeof(placeId) ~= "number" or typeof(jobId) ~= "string" then
		return false, "Malformed directory entry"
	end

	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ServerInstanceId = jobId
	return safeTeleport(placeId, player, teleportOptions)
end

JoinWorldFunc.OnServerInvoke = function(player: Player, placeKey: string)
	if typeof(placeKey) ~= "string" then
		return false, "Invalid place key, it isn't a string"
	end

	local placeId = PlaceKeyToPlaceId[placeKey]

	if placeId then
		local teleportOptions = Instance.new("TeleportOptions")
		return safeTeleport(placeId, player, teleportOptions)
	else
		return false, "Invalid place key " .. placeKey
	end
end
