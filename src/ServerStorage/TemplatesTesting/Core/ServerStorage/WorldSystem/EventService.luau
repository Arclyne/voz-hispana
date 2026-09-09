--!strict
--[[
	EventService — el evento global del juego (uno solo a la vez).

	Vive en Core, así que existe en todos los places. Tiene dos mitades:

	- Lado lobby: `reserve()` toma la reserva de staging sobre la identidad singleton
	  `event_active`, reserva el servidor y teletransporta al admin. Como la identidad es
	  fija, un segundo `reserve()` encuentra la identidad ocupada y falla — ese es todo el
	  mecanismo de "un solo evento a la vez".

	- Lado host: `tryHost()` corre en el servidor reservado cuando llega el admin, toma el
	  lease real (onConflict = "deny") y publica la presencia. El evento queda invisible
	  hasta que `start()` lo marca como listo.

	El evento vive mientras viva su servidor: si se vacía, el TTL de la presencia y del
	lease expiran y el evento se limpia solo.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local MemoryStoreService = game:GetService("MemoryStoreService")

local worldSystemStorage = ServerStorage:WaitForChild("WorldSystem")
local Profiles = require(worldSystemStorage:WaitForChild("Profiles"))
local ServerPresence = require(worldSystemStorage:WaitForChild("ServerPresence"))

local EVENT_KEY = "event_active"
local LOBBY_PLACE_ID = 94068794823958
local TELEPORT_ATTEMPTS = 3
local TELEPORT_RETRY_DELAY = 0.5

-- Puente de Studio: como ahí el teleport es no-op, `reserve()` deja la reserva anotada
-- con TTL largo y la place reservada la levanta al darle Play. Es el equivalente a lo que
-- hacen las casas en PlayerWorld_Init, pero sin inventar datos: usa la reserva de verdad.
local STUDIO_PENDING_MAP = "EventStudioPending"
local STUDIO_PENDING_KEY = "pending"
local STUDIO_PENDING_TTL = 3600

local EventService = {}

EventService.EventKey = EVENT_KEY

local currentStore: any = nil
local currentPresence: any = nil
local currentAccessCode: string? = nil
local destroyed = false
local strandedConn: RBXScriptConnection? = nil

--------------------------------------------------------------------------------
-- Puente de Studio
--------------------------------------------------------------------------------

local function studioPendingMap()
	return MemoryStoreService:GetHashMap(STUDIO_PENDING_MAP)
end

local function setStudioPending(placeId: number, accessCode: string)
	if not RunService:IsStudio() then
		return
	end
	local ok, err = pcall(function()
		studioPendingMap():SetAsync(STUDIO_PENDING_KEY, {
			placeId = placeId,
			accessCode = accessCode,
		}, STUDIO_PENDING_TTL)
	end)
	if not ok then
		warn("[EventService] No pude anotar la reserva de Studio:", err)
	end
end

local function peekStudioPending(): any?
	if not RunService:IsStudio() then
		return nil
	end
	local ok, value = pcall(function()
		return studioPendingMap():GetAsync(STUDIO_PENDING_KEY)
	end)
	if not ok or typeof(value) ~= "table" then
		return nil
	end
	return value
end

local function clearStudioPending()
	if not RunService:IsStudio() then
		return
	end
	pcall(function()
		studioPendingMap():RemoveAsync(STUDIO_PENDING_KEY)
	end)
end

--[[
	En Studio no hay teleport, así que tampoco hay TeleportData. Devuelve el payload que
	habría traído el admin si el teleport hubiera pasado, pero solo en la place que se
	reservó de verdad: así darle Play al lobby (o a una casa) nunca hostea un evento.
]]
local function studioTeleportData(): any?
	local pending = peekStudioPending()
	if not pending or pending.placeId ~= game.PlaceId then
		return nil
	end
	return {
		eventKey = EVENT_KEY,
		placeId = pending.placeId,
		accessCode = pending.accessCode,
	}
end

--------------------------------------------------------------------------------
-- Helpers de teleport / reserva
--------------------------------------------------------------------------------

local function safeTeleport(placeId: number, players: { Player }, opts: TeleportOptions): (boolean, string?)
	if RunService:IsStudio() then
		warn("[EventService] Teleport ignorado en Studio")
		return true, nil
	end

	local attemptIndex = 0
	local success, result
	repeat
		attemptIndex += 1
		success, result = pcall(TeleportService.TeleportAsync, TeleportService, placeId, players, opts)
		if not success then
			warn(string.format("[EventService] Teleport fail (%d): %s", attemptIndex, tostring(result)))
			task.wait(TELEPORT_RETRY_DELAY)
		end
	until success or attemptIndex == TELEPORT_ATTEMPTS

	if not success then
		return false, "No se pudo teletransportar: " .. tostring(result)
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
	warn("[EventService] ReserveServer falló:", code)
	return nil
end

local function teleportToEvent(players: { Player }, placeId: number, accessCode: string): (boolean, string?)
	local opts = Instance.new("TeleportOptions")
	opts.ReservedServerAccessCode = accessCode
	opts:SetTeleportData({ eventKey = EVENT_KEY, placeId = placeId, accessCode = accessCode })
	return safeTeleport(placeId, players, opts)
end

--------------------------------------------------------------------------------
-- Lado lobby: reservar
--------------------------------------------------------------------------------

--[[
	Reserva el servidor del evento y manda al admin ahí. Falla si ya hay un evento
	activo (hosteado por otro server) o si otro admin está reservando en este momento.
]]
function EventService.reserve(player: Player, placeId: number): (boolean, string?)
	if typeof(placeId) ~= "number" or placeId <= 0 then
		return false, "El placeId no es válido."
	end

	-- claimStaged solo detecta conflictos entre servers distintos: el lease es
	-- idempotente para el mismo serverId, así que dos reservas desde este mismo lobby
	-- ganarían las dos. Chequear el staging a mano cubre ese caso.
	local stager = Profiles.Event.peekStaged(EVENT_KEY)
	if stager then
		return false, "Ya hay una reserva de evento en curso. Espera unos segundos o termina el evento actual."
	end

	local claim, current = Profiles.Event.claimStaged(EVENT_KEY, { placeId = placeId })

	if not claim then
		if current and current.kind == "hosted" then
			return false, "Ya hay un evento activo. Usa /endevent para terminarlo primero."
		elseif current and current.kind == "staged" then
			return false, "Otro admin está reservando un evento en este momento."
		end
		return false, "No se pudo reservar el servidor, intenta de nuevo."
	end

	local code = reserveAccessCode(placeId)
	if not code then
		claim:release()
		return false, "No se pudo reservar el servidor en ese place."
	end

	-- Republica la meta y renueva el TTL: reservar pudo tardar.
	claim:setMeta({ placeId = placeId, accessCode = code })
	claim:tryClaim()

	-- Antes del teleport: en Studio esta anotación ES el teleport.
	setStudioPending(placeId, code)

	local ok, err = teleportToEvent({ player }, placeId, code)
	if not ok then
		clearStudioPending()
		claim:release()
		return false, err
	end

	return true, nil
end

--[[
	¿Hay una reserva de Studio esperando a que le den Play a esta place? Lo usa
	/reserveevent para decirle al admin qué hacer después.
]]
function EventService.getStudioPending(): any?
	return peekStudioPending()
end

--------------------------------------------------------------------------------
-- Lado host: bootear el evento en el servidor reservado
--------------------------------------------------------------------------------

local function buildPayload(): any
	local data = currentStore and currentStore:get()
	local playerList = ServerPresence.GetPlayerList()

	return {
		code = currentAccessCode,
		hostingType = "event",
		serverType = "public",
		placeId = game.PlaceId,
		jobId = game.JobId,
		name = data and data.name or "Evento",
		description = data and data.description or "",
		image = data and data.image or "",
		players = playerList,
		playerCount = #playerList,
		maxPlayers = Players.MaxPlayers,
		lastUpdate = os.time(),
		-- ServerDirectory solo cachea entradas "ready", así que el evento queda
		-- reservado pero invisible hasta que un admin corra /startevent.
		status = (data and data.started) and "ready" or "pending",
	}
end

--[[
	Si este jugador llegó con TeleportData de evento, este servidor se convierte en el
	host del evento. Devuelve true si el arranque quedó hecho (o ya estaba hecho).
]]
function EventService.tryHost(player: Player): boolean
	if currentStore then
		return true
	end

	local joinData = player:GetJoinData()
	local tpData = joinData and joinData.TeleportData
	if typeof(tpData) ~= "table" or tpData.eventKey ~= EVENT_KEY then
		-- Studio: el teleport nunca ocurrió, pero la reserva sí. Si esta place es la
		-- reservada, arrancamos como si el admin acabara de llegar.
		tpData = studioTeleportData()
		if not tpData then
			return false
		end
		warn("[EventService] Studio: hosteando desde la reserva pendiente de /reserveevent")
	end

	local accessCode = tpData.accessCode
	if typeof(accessCode) ~= "string" then
		-- El ganador del staging ya publicó el código; preferilo al de TeleportData.
		local _stager, stageMeta = Profiles.Event.peekStaged(EVENT_KEY)
		if typeof(stageMeta) == "table" and typeof(stageMeta.accessCode) == "string" then
			accessCode = stageMeta.accessCode
		end
	end

	currentAccessCode = accessCode
	destroyed = false

	local store = Profiles.Event.load(EVENT_KEY, {
		leaseMeta = {
			placeId = game.PlaceId,
			jobId = game.JobId,
			accessCode = accessCode,
		},
	})
	currentStore = store

	store:onDenied():Connect(function()
		-- Otro server ya hostea el evento: no somos nadie, cerramos.
		EventService.shutdown()
		ServerPresence.KickAll("Este evento ya está siendo hosteado en otro servidor.")
	end)

	if not store:awaitReady() then
		EventService.shutdown()
		return false
	end

	-- Un evento recién reservado arranca sin iniciar: /startevent lo revela.
	store:update(function(data)
		data.started = false
		data.hostId = player.UserId
		return data
	end)

	currentPresence = ServerPresence.new({
		ServerKey = EVENT_KEY,
		GetRefreshPayload = buildPayload,
	})
	currentPresence:Start()

	-- La reserva ya se consumió: si vuelves a darle Play sin reservar de nuevo, esta
	-- place no debe autoproclamarse host otra vez.
	clearStudioPending()

	return true
end

--------------------------------------------------------------------------------
-- Comandos del host
--------------------------------------------------------------------------------

function EventService.isHosting(): boolean
	return currentStore ~= nil and not destroyed and currentStore:isReady()
end

function EventService.isStarted(): boolean
	if not EventService.isHosting() then
		return false
	end
	local data = currentStore:get()
	return data ~= nil and data.started == true
end

local function applyDetails(name: string, description: string, imageId: string?): (boolean, string?)
	if not currentStore:canWrite() then
		return false, "Los datos del evento no están disponibles ahora mismo."
	end

	currentStore:update(function(data)
		data.name = name
		data.description = description
		if imageId then
			data.image = imageId
		end
		return data
	end)
	return true, nil
end

--[[
	Inicia el evento: lo marca como listo para que aparezca en la GUI del lobby.
]]
function EventService.start(name: string, description: string, imageId: string?): (boolean, string?)
	if not EventService.isHosting() then
		return false, "Este servidor no es el servidor de un evento."
	end
	if EventService.isStarted() then
		return false, "El evento ya está iniciado. Usa /editevent para cambiarlo."
	end

	local ok, err = applyDetails(name, description, imageId)
	if not ok then
		return false, err
	end

	currentStore:update(function(data)
		data.started = true
		data.startedAt = os.time()
		return data
	end)

	currentPresence:RefreshNow()
	return true, nil
end

function EventService.edit(name: string, description: string, imageId: string?): (boolean, string?)
	if not EventService.isHosting() then
		return false, "Este servidor no es el servidor de un evento."
	end
	if not EventService.isStarted() then
		return false, "El evento todavía no está iniciado. Usa /startevent."
	end

	local ok, err = applyDetails(name, description, imageId)
	if not ok then
		return false, err
	end

	currentPresence:RefreshNow()
	return true, nil
end

--[[
	Cierra el evento sin tocar a los jugadores: saca la presencia del directorio y
	suelta el lease para que se pueda reservar otro evento.
]]
function EventService.shutdown()
	if destroyed then
		return
	end
	destroyed = true

	if currentPresence then
		currentPresence:Cleanup()
		currentPresence = nil
	end
	if currentStore then
		currentStore:close()
		currentStore = nil
	end
	currentAccessCode = nil
end

--[[
	Termina el evento y devuelve a todos al lobby.
]]
function EventService.finish(): (boolean, string?)
	if not EventService.isHosting() then
		return false, "Este servidor no es el servidor de un evento."
	end

	EventService.shutdown()
	clearStudioPending()

	-- Este servidor ya no está en el directorio, pero un teleport en vuelo puede seguir
	-- aterrizando gente: la mandamos al lobby también, o se quedarían encerrados.
	if not strandedConn then
		strandedConn = Players.PlayerAdded:Connect(function(late: Player)
			safeTeleport(LOBBY_PLACE_ID, { late }, Instance.new("TeleportOptions"))
		end)
	end

	local players = Players:GetPlayers()
	if #players > 0 then
		local ok, err = safeTeleport(LOBBY_PLACE_ID, players, Instance.new("TeleportOptions"))
		if not ok then
			-- El evento SÍ quedó cerrado; lo que falló es la vuelta. El admin tiene que
			-- enterarse, porque los jugadores quedaron en un servidor muerto.
			return false, "Evento cerrado, pero no pude devolver a los jugadores al lobby: " .. tostring(err)
		end
	end

	return true, nil
end

game:BindToClose(function()
	EventService.shutdown()
end)

return EventService
