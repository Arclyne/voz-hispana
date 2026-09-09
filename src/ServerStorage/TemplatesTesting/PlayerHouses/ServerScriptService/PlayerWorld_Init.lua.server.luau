--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local worldSystemStorage = ServerStorage:WaitForChild("WorldSystem")
local Profiles = require(worldSystemStorage:WaitForChild("Profiles"))
local ServerPresence = require(worldSystemStorage:WaitForChild("ServerPresence"))
local WorldService = require(script.Parent:WaitForChild("WorldService"))
local HousesInfo = require(ReplicatedStorage:WaitForChild("HousesInfo"))
local RolesInfo = require(ReplicatedStorage:WaitForChild("RolesInfo"))

local ServerInfoConfiguration = ReplicatedStorage:WaitForChild("ServerInfo")
local isStarted = ReplicatedStorage:WaitForChild("isStarted")

local presence: ServerPresence.ServerPresence? = nil
local booting = false

type TeleportPayload = { key: string, accessCode: string?, placeId: number? }

local function extractPayload(player: Player): (string?, string?)
	if RunService:IsStudio() then
		warn("[PlayerWorld] Studio: usando key de prueba")
		return ("%i_defaultRoom"):format(player.UserId), nil
	end
	local joinData = player:GetJoinData()
	local tpData = joinData and joinData.TeleportData :: TeleportPayload?
	if tpData and typeof(tpData.key) == "string" then
		local accessCode = if typeof(tpData.accessCode) == "string" then tpData.accessCode else nil
		return tpData.key, accessCode
	end
	return nil, nil
end

local function onFailedServer(err: string)
	warn(err)
	ServerPresence.KickAll(err)
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

local function hasRoom(userId: number, roomName: string): (boolean, boolean)
	local data, ok = Profiles.WorldsPlayer.read(tostring(userId))
	if not ok then
		return false, false
	end
	local rooms = (data and data.rooms) or {}
	return true, table.find(rooms, roomName) ~= nil
end

local function getRoomDisplayName(ownerId: number, roomName: string): string
	local success, playerName = pcall(function()
		return Players:GetNameFromUserIdAsync(ownerId)
	end)
	if success then
		return ("%s's %s"):format(playerName, HousesInfo[roomName].name)
	else
		return "default Name"
	end
end

local function canHostWorld(hostPlayer: Player): (boolean, string?)
	local data = WorldService.get()
	if not data then
		return false, "[Error] World data not loaded."
	end

	local ownerId = data.settings.OwnerId
	if hostPlayer.UserId == ownerId then
		return true
	end

	if data.bans[tostring(hostPlayer.UserId)] == true then
		return false, "You are banned from this world."
	end

	if data.settings.ServerType == "private" then
		local role = data.roles[tostring(hostPlayer.UserId)] or 0
		if role < RolesInfo["guest"] then
			local ok, isFriend = pcall(function()
				return hostPlayer:IsFriendsWith(ownerId)
			end)
			if not ok or not isFriend then
				return false, "This world is private. Only invited users or friends of the owner can host."
			end
		end
	end

	return true
end

local function getHouseRefreshPayload(old: any?): any
	local data = WorldService.get()
	if not data then
		return old
	end

	local playerList = ServerPresence.GetPlayerList()

	local info = {}
	info.code = WorldService.getAccessCode()
	info.players = playerList
	info.playerCount = #playerList
	info.maxPlayers = Players.MaxPlayers
	info.hostingType = "room"
	info.placeId = game.PlaceId
	info.jobId = game.JobId
	info.lastUpdate = os.time()
	info.name = data.settings.Name
	info.ownerId = data.settings.OwnerId
	info.serverType = data.settings.ServerType
	info.status = "ready"

	return info
end

local function onHouseStarted()
	ServerInfoConfiguration:SetAttribute("status", "ready")
	isStarted:SetAttribute("Started", true)
	warn("Player World Started: ", ServerInfoConfiguration:GetAttribute("ServerKey"))
end

local function onHouseCleanup()
	isStarted:SetAttribute("Started", false)
	WorldService.destroy()
end

local function resolveAccessCode(serverKey: string, tpAccessCode: string?): string?
	if typeof(tpAccessCode) == "string" then
		return tpAccessCode
	end
	local _stager, stageMeta = Profiles.World.peekStaged(serverKey)
	if typeof(stageMeta) == "table" and typeof(stageMeta.accessCode) == "string" then
		return stageMeta.accessCode
	end
	return nil
end

local CONVERGE_ATTEMPTS = 3
local CONVERGE_RETRY = 0.5

local function convergeToOwner(serverKey: string, ownerMeta: any, selfAccessCode: string?): boolean
	if RunService:IsStudio() then
		return false
	end
	if
		typeof(ownerMeta) ~= "table"
		or typeof(ownerMeta.placeId) ~= "number"
		or typeof(ownerMeta.accessCode) ~= "string"
	then
		return false
	end
	if selfAccessCode ~= nil and ownerMeta.accessCode == selfAccessCode then
		return false
	end

	local function send(players: { Player })
		if #players == 0 then
			return
		end
		local opts = Instance.new("TeleportOptions")
		opts.ReservedServerAccessCode = ownerMeta.accessCode
		opts:SetTeleportData({ key = serverKey, placeId = ownerMeta.placeId, accessCode = ownerMeta.accessCode })
		for attempt = 1, CONVERGE_ATTEMPTS do
			local ok, err = pcall(TeleportService.TeleportAsync, TeleportService, ownerMeta.placeId, players, opts)
			if ok then
				return
			end
			warn(("[PlayerWorld] Converge teleport fail (%d): %s"):format(attempt, tostring(err)))
			task.wait(CONVERGE_RETRY)
		end
		for _, plr in players do
			plr:Kick("[Error] This world is already hosted. Please try joining again.")
		end
	end

	warn("[PlayerWorld] World already hosted; converging players to the host instance.")
	task.spawn(send, Players:GetPlayers())
	Players.PlayerAdded:Connect(function(player)
		task.spawn(send, { player })
	end)
	return true
end

local function init(serverKey: string, hostPlayer: Player, tpAccessCode: string?)
	local userId, roomName = parseRoomKey(serverKey)
	if not userId or not roomName then
		onFailedServer("[Error] Invalid Server Key")
		return
	end

	if not HousesInfo[roomName] then
		onFailedServer(("[Error] Unknown room %s."):format(roomName))
		return
	end

	local okRooms, ownsRoom = hasRoom(userId, roomName)
	if not okRooms then
		onFailedServer(("[Error] Failed getting the [%i] rooms."):format(userId))
		return
	end
	if not ownsRoom then
		onFailedServer(("[Error] The user %i does not have the %s."):format(userId, roomName))
		return
	end

	local selfAccessCode = resolveAccessCode(serverKey, tpAccessCode)
	local store = WorldService.start({
		serverKey = serverKey,
		ownerId = userId,
		displayName = getRoomDisplayName(userId, roomName),
		accessCode = selfAccessCode,
	})

	store:onDenied():Connect(function(owner, ownerMeta)
		if presence then
			presence:Cleanup()
			presence = nil
		end
		if convergeToOwner(serverKey, ownerMeta, selfAccessCode) then
			return
		end
		onFailedServer(("[Error] This world is already hosted by %s."):format(tostring(owner)))
	end)

	if not store:awaitReady() then
		if not store:isDenied() then
			onFailedServer("[Error] The data server could not be obtained.")
		end
		return
	end

	local allowed, why = canHostWorld(hostPlayer)
	if not allowed then
		WorldService.destroy()
		onFailedServer(why or "[Error] Not allowed to host this world.")
		return
	end

	ServerInfoConfiguration:SetAttribute("ServerKey", serverKey)
	ServerInfoConfiguration:SetAttribute("status", "pending")

	presence = ServerPresence.new({
		ServerKey = serverKey,
		GetRefreshPayload = getHouseRefreshPayload,
		OnStarted = onHouseStarted,
		OnCleanup = onHouseCleanup,
	})
	presence:Start()
end

local function onPlayerAdded(player: Player)
	if booting or presence then
		return
	end
	local key, accessCode = extractPayload(player)
	if key then
		booting = true
		init(key, player, accessCode)
		booting = false
	end
end

for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

Players.PlayerAdded:Once(onPlayerAdded)

game:BindToClose(function()
	if presence then
		presence:Cleanup()
	else
		WorldService.destroy()
	end
end)
