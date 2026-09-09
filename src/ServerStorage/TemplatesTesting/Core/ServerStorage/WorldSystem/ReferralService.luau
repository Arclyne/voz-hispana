--[[
	ReferralService

	Toda la logica de invitar amigos. Lo ajustable esta en
	ReplicatedStorage.Shared.Referrals.ReferralConfig; aqui no hay numeros sueltos.

	El recorrido de una invitacion:

	 1. `OnPlayerReady` corre cuando entra un jugador. Solo sigue si el perfil es
	    nuevo de verdad, si trae un invitador en el link y si el jugador tiene chat
	    de voz: al que echan por no tener micro no llega a contar.
	 2. `Tick` suma segundos mientras juega. Por defecto se acumulan entre
	    sesiones dentro de la ventana de 2 dias: se va y al volver sigue donde lo
	    dejo. Ver AccumulateAcrossSessions en la config.
	 3. Al llegar a los minutos, `Tick` avisa al perfil del invitador con
	    `send`, que funciona este conectado o no.
	 4. El invitador ve la lista y reclama sus hitos desde la tablet.

	Este sistema no usa MemoryStore directamente: la cuota del universo ya nos dio
	un susto en agosto. El unico roce es el timbre de DataKit al hacer `send`, que
	es best-effort y si falla el mensaje llega igual por DataStore.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VoiceChatService = game:GetService("VoiceChatService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Profiles = require(script.Parent:WaitForChild("Profiles"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local referralsFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Referrals")
local ReferralConfig = require(referralsFolder:WaitForChild("ReferralConfig"))
local ReferralShared = require(referralsFolder:WaitForChild("ReferralShared"))

local Collections = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("EconomySystem"):WaitForChild("Collections"))

local ReferralService = {}

-- Cache de los perfiles de invitados que estamos mirando para pintar la lista.
-- Sin esto, tener la tablet abierta seria una lectura de DataStore por segundo.
-- El invitado solo persiste su avance cada ProgressCheckpointSeconds, asi que
-- leerlo mas seguido que esto no lo haria mas exacto.
local PROGRESS_CACHE_SECONDS = 60

-- Jugadores a los que ahora mismo se les esta atribuyendo una invitacion. El
-- chequeo de chat de voz cede el hilo, y sin esto un link y un codigo metidos
-- a la vez podrian colar dos invitadores para el mismo jugador.
local attributing: { [Player]: boolean } = {}
local progressCache: { [string]: { at: number, secs: number, lastSeen: number, done: boolean } } = {}

--[[
	Los segundos de la sesion en curso se llevan en memoria y solo bajan al perfil
	en los checkpoints, al completar y al salir. Escribir el perfil una vez por
	segundo seria absurdo.
]]
type Session = {
	secs: number,
	lastFlush: number,
	inviterId: number,
	done: boolean,
	ageBlocked: boolean,
}

local sessions: { [Player]: Session } = {}

--------------------------------------------------------------------------------
-- Utilidades
--------------------------------------------------------------------------------

local function now(): number
	return os.time()
end

local function log(...)
	print("[ReferralService]", ...)
end

--[[
	Un perfil recien creado trae todo el template intacto. Nos apoyamos en
	`joinedAt == 0`, pero eso tambien le pasa al veterano que entra por primera vez
	despues de desplegar esto, asi que ademas exigimos que no haya rastro de
	haber jugado. Un jugador de verdad nuevo no tiene nada de esto.
]]
local function looksBrandNew(data: any): boolean
	if typeof(data) ~= "table" then
		return false
	end

	if (tonumber(data.joinedAt) or 0) > 0 then
		return false
	end

	if typeof(data.rooms) == "table" and #data.rooms > 1 then
		return false
	end

	if typeof(data.gamePasses) == "table" and next(data.gamePasses) ~= nil then
		return false
	end

	if typeof(data.inventory) == "table" and typeof(data.inventory.items) == "table" and next(data.inventory.items) ~= nil then
		return false
	end

	if typeof(data.stats) == "table" then
		for _, stat in ipairs(data.stats) do
			if typeof(stat) == "table" and (tonumber(stat.Value) or 0) > 0 then
				return false
			end
		end
	end

	return true
end

local function hasVoiceChat(userId: number): boolean
	local ok, enabled = pcall(function()
		return VoiceChatService:IsVoiceEnabledForUserIdAsync(userId)
	end)

	if not ok then
		-- Si Roblox no contesta no inventamos: sin confirmacion no se registra la
		-- invitacion. Le quedan 48 h para volver a entrar y que si conteste.
		warn("[ReferralService] No se pudo verificar el chat de voz de", userId)
		return false
	end

	return enabled == true
end

--------------------------------------------------------------------------------
-- Estado del invitado
--------------------------------------------------------------------------------

local function isExpired(referral: any): boolean
	local startedAt = tonumber(referral.startedAt) or 0
	if startedAt <= 0 then
		return true
	end

	return now() - startedAt > ReferralConfig.Settings.PendingWindowSeconds
end

--[[
	El unico sitio donde se decide si el contador sigue o vuelve a cero.

	Con AccumulateAcrossSessions, nunca vuelve a cero: los segundos son suyos hasta
	que venza la ventana de 2 dias. Sin el, solo sobrevive un corte corto, el que
	ocupa un teleport a una casa o una reconexion.
]]
local function resumeOrReset(referral: any)
	if not ReferralConfig.Settings.AccumulateAcrossSessions then
		local gap = now() - (tonumber(referral.lastSeen) or 0)

		if gap > ReferralConfig.Settings.ReconnectGraceSeconds then
			referral.secs = 0
		end
	end

	referral.lastSeen = now()
end

--------------------------------------------------------------------------------
-- Atribucion
--------------------------------------------------------------------------------

--[[
	Deja anotado en el perfil del invitado quien lo trajo, y avisa al invitador
	para que le aparezca en "en progreso".

	Devuelve (ok, error). El error es para el flujo del codigo manual, que si le
	dice al jugador por que no cuela.
]]
function ReferralService.SetInviter(player: Player, inviterId: number, source: string): (boolean, string?)
	if not ReferralConfig.Enabled then
		return false, "El sistema de invitaciones esta desactivado."
	end

	inviterId = tonumber(inviterId) or 0

	if inviterId <= 0 then
		return false, "Invitador invalido."
	end

	if inviterId == player.UserId then
		return false, "No puedes invitarte a ti mismo."
	end

	local store = PlayerDataService.get(player)
	if not store or not store:isReady() then
		return false, "Tus datos aun no han cargado. Intentalo en unos segundos."
	end

	local data = store:get()
	local referral = data.referral

	if typeof(referral) ~= "table" then
		return false, "Perfil sin datos de invitacion."
	end

	if referral.consumed then
		return false, "Ya no puedes usar una invitacion: esta no es tu primera vez."
	end

	if (tonumber(referral.inviterId) or 0) > 0 then
		return false, "Ya tienes una invitacion en curso."
	end

	if attributing[player] then
		return false, "Ya se esta registrando una invitacion."
	end

	attributing[player] = true
	local voiceOk = hasVoiceChat(player.UserId)
	attributing[player] = nil

	if not voiceOk then
		return false, "Necesitas el chat de voz activado."
	end

	-- El jugador podria haberse ido mientras comprobabamos la voz.
	if player.Parent ~= Players then
		return false, "El jugador ya no esta."
	end

	-- Alguien pudo atribuirlo mientras esperabamos a Roblox.
	if (tonumber(store:get().referral.inviterId) or 0) > 0 then
		return false, "Ya tienes una invitacion en curso."
	end

	local startedAt = now()

	store:update(function(current)
		local target = current.referral
		target.inviterId = inviterId
		target.startedAt = startedAt
		target.secs = 0
		target.lastSeen = startedAt
		target.done = false
		target.consumed = true
		return current
	end)

	-- Se persiste ya: si el servidor se cae en el proximo minuto, la invitacion
	-- no se pierde.
	store:save("referral:attributed")

	local sent = Profiles.WorldsPlayer.send(tostring(inviterId), {
		kind = "referralPending",
		inviteeId = player.UserId,
		name = player.DisplayName,
		startedAt = startedAt,
	})

	if not sent then
		warn("[ReferralService] No se pudo avisar al invitador", inviterId, "de", player.UserId)
	end

	sessions[player] = {
		secs = 0,
		lastFlush = startedAt,
		inviterId = inviterId,
		done = false,
		ageBlocked = false,
	}

	if ReferralService.OnPendingCreated then
		task.spawn(ReferralService.OnPendingCreated, inviterId, player.DisplayName, player.UserId)
	end

	log(("%s invitado por %d (%s)"):format(player.Name, inviterId, source))

	return true, nil
end

--[[
	Corre al entrar cada jugador, despues de que su perfil este listo.

	Hace dos cosas: sellar `joinedAt` la primera vez, y atribuir la invitacion si
	viene con una. Tambien reanuda o reinicia la sesion del reto.
]]
function ReferralService.OnPlayerReady(player: Player)
	local store = PlayerDataService.get(player)
	if not store or not store:isReady() then
		return
	end

	local data = store:get()
	local brandNew = looksBrandNew(data)

	if (tonumber(data.joinedAt) or 0) <= 0 then
		local stamp = now()

		store:update(function(current)
			if (tonumber(current.joinedAt) or 0) <= 0 then
				current.joinedAt = stamp
			end

			-- Solo un perfil nuevo de verdad queda abierto a ser invitado. El
			-- veterano se queda con el consumed = true del template.
			if brandNew then
				current.referral.consumed = false
			end

			return current
		end)

		if brandNew then
			ReferralService.AttributeFromJoin(player)
		end

		return
	end

	local referral = data.referral

	if typeof(referral) ~= "table" then
		return
	end

	-- Sigue abierto a ser invitado: la primera vez lo echaron por no tener chat de
	-- voz (o Roblox no contesto) y ahora vuelve con el link. Aun es su primera
	-- vez de verdad, asi que el link cuenta igual que si acabara de llegar.
	if referral.consumed == false and (tonumber(referral.inviterId) or 0) <= 0 then
		ReferralService.AttributeFromJoin(player)
		return
	end

	-- Ya tenia perfil: si trae una invitacion viva, decidimos si su sesion
	-- anterior continua o empieza de cero.
	if (tonumber(referral.inviterId) or 0) <= 0 or referral.done then
		return
	end

	if isExpired(referral) then
		return
	end

	store:update(function(current)
		resumeOrReset(current.referral)
		return current
	end)

	sessions[player] = {
		secs = tonumber(store:get().referral.secs) or 0,
		lastFlush = now(),
		inviterId = tonumber(referral.inviterId) or 0,
		done = false,
		ageBlocked = false,
	}
end

--[[
	Un amigo que ya esta en este servidor. Es lo que cubre "me he unido a un
	amigo" desde su perfil, que no deja ningun rastro en la join data.

	Si hay varios amigos dentro se queda con el primero que encuentra: la
	invitacion es de uno solo.
]]
local function findFriendInServer(player: Player): number
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			local ok, isFriend = pcall(function()
				return player:IsFriendsWith(other.UserId)
			end)

			if ok and isFriend then
				return other.UserId
			end
		end
	end

	return 0
end

--[[
	Decide quien invito a un jugador que llega abierto a ser invitado, por este
	orden: el link de Roblox, el LaunchData de un share link o deep link, y por
	ultimo un amigo que ya este en el servidor.
]]
function ReferralService.AttributeFromJoin(player: Player)
	local inviterId, source = ReferralService.ReadInviteJoinData(player)

	if inviterId <= 0 and player.Parent == Players then
		inviterId = findFriendInServer(player)
		source = "amigo en el servidor"
	end

	if inviterId > 0 then
		task.spawn(ReferralService.SetInviter, player, inviterId, source)
	end
end

--[[
	A quien pertenece un codigo. Primero el registro de codigos a medida (mandan,
	por si alguien registra uno que coincida con un nombre) y si no, el nombre de
	usuario de Roblox: asi todo el mundo tiene codigo sin repartir ninguno.

	Devuelve (ownerId, error). ownerId 0 con error nil significa que el codigo no
	existe; error viene solo cuando no se pudo comprobar.
]]
local function resolveCodeOwner(code: string): (number, string?)
	local record, ok = Profiles.ReferralCode.read(code)

	if not ok then
		return 0, "No se pudo comprobar el codigo. Intentalo en un momento."
	end

	local ownerId = tonumber(record and record.userId) or 0

	if ownerId <= 0 then
		local found, userId = pcall(function()
			return Players:GetUserIdFromNameAsync(code)
		end)

		if found and tonumber(userId) then
			ownerId = userId
		end
	end

	return ownerId, nil
end

--[[
	Saca el invitador del LaunchData de un share link o un deep link. Acepta
	`ref=CODIGO`, `code=CODIGO`, el codigo a pelo, un userId, o un JSON con la
	clave `ref`. El LaunchData lo escribe quien arma el link, asi que aqui no se
	confia en nada: solo sirve para localizar un codigo, y el codigo se resuelve
	igual que si lo hubieran tecleado.
]]
local function inviterFromLaunchData(raw: any): number
	if typeof(raw) ~= "string" or raw == "" or #raw > 200 then
		return 0
	end

	local candidate = raw

	if raw:sub(1, 1) == "{" then
		local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
		candidate = ok and typeof(decoded) == "table" and (decoded.ref or decoded.code or decoded.inviter) or ""
		candidate = tostring(candidate or "")
	else
		local value = raw:match("^%s*[Rr][Ee][Ff]%s*=%s*(.-)%s*$") or raw:match("^%s*[Cc][Oo][Dd][Ee]%s*=%s*(.-)%s*$")
		if value then
			candidate = value
		end
		candidate = candidate:match("^([^&]*)") or candidate
	end

	local asId = tonumber(candidate)
	if asId and asId > 0 and asId == math.floor(asId) then
		return asId
	end

	local code = ReferralShared.NormalizeCode(candidate)
	if not code then
		return 0
	end

	local ownerId = resolveCodeOwner(code)
	return ownerId
end

--[[
	El invitador que viene con el jugador al entrar. Devuelve (inviterId, fuente).

	`ReferredByPlayerId` lo rellena Roblox para las invitaciones y los links de
	"invitar amigos" del menu, y `LaunchData` viene de los share links del Creator
	Dashboard y de los deep links (ver ReferralConfig.Link). En ninguno de los dos
	casos el invitador tiene que estar dentro.

	La join data puede tardar un par de segundos en aparecer, de ahi los reintentos.
]]
function ReferralService.ReadInviteJoinData(player: Player): (number, string)
	for _ = 1, 5 do
		local ok, joinData = pcall(function()
			return player:GetJoinData()
		end)

		if ok and typeof(joinData) == "table" then
			local inviterId = tonumber(joinData.ReferredByPlayerId) or 0

			if inviterId > 0 then
				return inviterId, "link"
			end

			inviterId = inviterFromLaunchData(joinData.LaunchData)

			if inviterId > 0 then
				return inviterId, "launchData " .. tostring(joinData.LaunchData)
			end
		end

		if player.Parent ~= Players then
			return 0, ""
		end

		task.wait(1)
	end

	return 0, ""
end

--------------------------------------------------------------------------------
-- Progreso de la sesion
--------------------------------------------------------------------------------

--[[
	Baja al perfil los segundos que llevamos en memoria. `persist` fuerza el save
	a DataStore, que es lo que hace que el invitador vea moverse el anillo desde
	otro servidor.
]]
local function flushSession(player: Player, persist: boolean)
	local session = sessions[player]
	if not session then
		return
	end

	local store = PlayerDataService.get(player)
	if not store or not store:isReady() then
		return
	end

	local secs = math.floor(session.secs)
	local stamp = now()

	store:update(function(current)
		local referral = current.referral
		if typeof(referral) ~= "table" then
			return current
		end

		referral.secs = secs
		referral.lastSeen = stamp

		if session.done then
			referral.done = true
		end

		return current
	end)

	session.lastFlush = stamp

	if persist then
		store:save("referral:progress")
	end
end

--[[
	Completa la invitacion: se lo dice al perfil del invitador y cierra el reto.

	La comprobacion de antiguedad de cuenta se hace AQUI y no al entrar, para que
	una cuenta creada el dia de un video llegue al minimo dentro de la ventana de
	48 h y la invitacion cuente igual.
]]
local function completeReferral(player: Player)
	local session = sessions[player]
	if not session or session.done then
		return
	end

	local store = PlayerDataService.get(player)
	if not store or not store:isReady() then
		return
	end

	local referral = store:get().referral
	local inviterId = tonumber(referral.inviterId) or 0

	if inviterId <= 0 or referral.done then
		sessions[player] = nil
		return
	end

	if isExpired(referral) then
		log(("%s completo sus minutos pero la invitacion ya habia caducado"):format(player.Name))
		sessions[player] = nil
		return
	end

	if player.AccountAge < ReferralConfig.Settings.MinAccountAgeDays then
		if not session.ageBlocked then
			session.ageBlocked = true
			log(("%s completo sus minutos pero su cuenta tiene %d dias (minimo %d)"):format(
				player.Name,
				player.AccountAge,
				ReferralConfig.Settings.MinAccountAgeDays
			))
		end
		-- Sin marcar done: si vuelve mas adelante con la cuenta ya mayor, cuenta.
		-- Los segundos se quedan en el tope para no seguir sumando en vano.
		session.secs = ReferralConfig.Settings.RequiredSeconds
		return
	end

	session.done = true
	session.secs = ReferralConfig.Settings.RequiredSeconds

	flushSession(player, true)

	local sent = Profiles.WorldsPlayer.send(tostring(inviterId), {
		kind = "referralCompleted",
		inviteeId = player.UserId,
		name = player.DisplayName,
	})

	if not sent then
		warn("[ReferralService] No se pudo avisar de la invitacion completada de", player.UserId)
	end

	if ReferralService.OnCompleted then
		task.spawn(ReferralService.OnCompleted, inviterId, player.DisplayName, player.UserId)
	end

	log(("%s completo su invitacion de %d"):format(player.Name, inviterId))
end

--[[
	Suma `delta` segundos a la sesion del jugador. Lo llama el bucle de
	ReferralMain una vez por segundo.
]]
function ReferralService.Tick(player: Player, delta: number)
	local session = sessions[player]
	if not session or session.done then
		return
	end

	session.secs += delta

	if session.secs >= ReferralConfig.Settings.RequiredSeconds then
		completeReferral(player)
		return
	end

	if now() - session.lastFlush >= ReferralConfig.Settings.ProgressCheckpointSeconds then
		flushSession(player, true)
	end
end


--[[
	Al salir. Guardar aqui es lo que permite que un teleport a una casa no rompa
	la sesion: el siguiente servidor lee un `lastSeen` reciente y sigue sumando.
]]
function ReferralService.OnPlayerLeaving(player: Player)
	if sessions[player] then
		flushSession(player, false)
		sessions[player] = nil
	end

	progressCache[tostring(player.UserId)] = nil
end

--------------------------------------------------------------------------------
-- Lectura del progreso de otro (para la lista del invitador)
--------------------------------------------------------------------------------

local function readInviteeProgress(inviteeId: number)
	local key = tostring(inviteeId)

	-- Si el invitado esta en ESTE servidor, su sesion en memoria es mas fresca
	-- que cualquier cosa que haya en el DataStore.
	local localPlayer = Players:GetPlayerByUserId(inviteeId)

	if localPlayer and sessions[localPlayer] then
		local session = sessions[localPlayer]
		return {
			secs = math.floor(session.secs),
			lastSeen = now(),
			done = session.done,
			online = true,
		}
	end

	local cached = progressCache[key]

	if cached and now() - cached.at < PROGRESS_CACHE_SECONDS then
		return {
			secs = cached.secs,
			lastSeen = cached.lastSeen,
			done = cached.done,
			online = false,
		}
	end

	local data, ok = Profiles.WorldsPlayer.read(key)

	if not ok or typeof(data) ~= "table" or typeof(data.referral) ~= "table" then
		-- Lectura fallida: devolvemos lo ultimo que sabiamos en vez de un cero que
		-- haria parpadear la barra a vacio.
		if cached then
			return { secs = cached.secs, lastSeen = cached.lastSeen, done = cached.done, online = false }
		end

		return { secs = 0, lastSeen = 0, done = false, online = false }
	end

	local referral = data.referral

	progressCache[key] = {
		at = now(),
		secs = tonumber(referral.secs) or 0,
		lastSeen = tonumber(referral.lastSeen) or 0,
		done = referral.done == true,
	}

	return {
		secs = progressCache[key].secs,
		lastSeen = progressCache[key].lastSeen,
		done = progressCache[key].done,
		online = false,
	}
end

--------------------------------------------------------------------------------
-- Estado para la tablet
--------------------------------------------------------------------------------

--[[
	Limpia las invitaciones que ya no pintan nada: las caducadas sin completar y
	las ya cobradas. Se hace de forma perezosa al leer el estado, para no tener
	ningun barrido periodico corriendo.
]]
local function prunePending(player: Player)
	local store = PlayerDataService.get(player)
	if not store or not store:isReady() then
		return
	end

	local pending = store:get().referrals.pending
	if typeof(pending) ~= "table" then
		return
	end

	local window = ReferralConfig.Settings.PendingWindowSeconds
	local stale = {}

	-- Las ya cobradas se quedan hasta que venza su ventana: son el recibo que
	-- impide sumar dos veces si el invitado vuelve a completar (por ejemplo si su
	-- save del `done` fallo). Pasada la ventana ya no puede completar, y se van.
	for key, entry in pairs(pending) do
		if typeof(entry) ~= "table" then
			table.insert(stale, key)
		elseif now() - (tonumber(entry.startedAt) or 0) > window then
			table.insert(stale, key)
		end
	end

	if #stale == 0 then
		return
	end

	store:update(function(current)
		for _, key in ipairs(stale) do
			current.referrals.pending[key] = nil
		end
		return current
	end)
end

--[[
	Todo lo que la seccion de Amigos necesita pintar, en una sola tabla.
]]
function ReferralService.GetState(player: Player)
	local store = PlayerDataService.get(player)
	if not store or not store:isReady() then
		return nil
	end

	prunePending(player)

	local data = store:get()
	local referrals = data.referrals
	local total = tonumber(referrals.total) or 0

	local claimed = {}
	for _, id in ipairs(referrals.claimed or {}) do
		claimed[id] = true
	end

	local rewards = {}
	for _, reward in ipairs(ReferralShared.GetRewards()) do
		table.insert(rewards, {
			Id = reward.Id,
			Friends = reward.Friends,
			Currency = reward.Currency,
			Amount = reward.Amount,
			Unlocked = total >= reward.Friends,
			Claimed = claimed[reward.Id] == true,
		})
	end

	local default = ReferralShared.GetDefault()
	local defaultState = nil

	if default then
		local earned = ReferralShared.CountDefaultEarned(total)
		local alreadyClaimed = math.min(tonumber(referrals.defaultClaimed) or 0, earned)

		defaultState = {
			From = default.From,
			Every = default.Every,
			Currency = default.Currency,
			Amount = default.Amount,
			Earned = earned,
			Claimed = alreadyClaimed,
			Claimable = math.max(0, earned - alreadyClaimed),
		}
	end

	local pending = {}

	for key, entry in pairs(referrals.pending or {}) do
		local inviteeId = tonumber(key)

		if inviteeId and typeof(entry) == "table" and not entry.paid then
			local progress = readInviteeProgress(inviteeId)
			local startedAt = tonumber(entry.startedAt) or now()

			-- Si el invitado no esta jugando, su cuenta esta parada: el anillo se
			-- muestra a cero porque los minutos tienen que ser de una sentada.
			local live = progress.online
				or (now() - progress.lastSeen) <= ReferralConfig.Settings.ReconnectGraceSeconds

			-- Con los minutos acumulandose, lo que lleva hecho es suyo aunque no
			-- este jugando ahora: la barra se queda donde estaba, no a cero.
			local accumulate = ReferralConfig.Settings.AccumulateAcrossSessions
			local counts = accumulate or live

			table.insert(pending, {
				UserId = inviteeId,
				Name = entry.name or "",
				Seconds = counts and progress.secs or 0,
				Ratio = counts and ReferralShared.GetSessionRatio(progress.secs) or 0,
				Online = progress.online,
				-- `Online` es "esta en mi servidor"; `Live` es "esta jugando ahora",
				-- que es lo que decide el color. Un amigo jugando en otro servidor no
				-- esta Online para mi y su barra tiene que avanzar igual.
				Live = live,
				ExpiresAt = startedAt + ReferralConfig.Settings.PendingWindowSeconds,
			})
		end
	end

	table.sort(pending, function(a, b)
		if a.Ratio ~= b.Ratio then
			return a.Ratio > b.Ratio
		end
		return a.ExpiresAt < b.ExpiresAt
	end)

	local nextReward = ReferralShared.GetNextReward(total)

	-- Los que ya completaron, del mas reciente al mas antiguo. Se ensenan detras
	-- de los que estan en curso.
	local friends = {}

	for _, entry in ipairs(referrals.friends or {}) do
		if typeof(entry) == "table" and tonumber(entry.id) then
			table.insert(friends, {
				UserId = tonumber(entry.id),
				Name = entry.name or "",
				At = tonumber(entry.at) or 0,
			})
		end
	end

	return {
		Total = total,
		Friends = friends,
		-- Su link no caduca y no hay nada que teclear del otro lado.
		Link = ReferralShared.BuildLink(player.UserId),
		-- Solo para creadores. Los creditos se pagan a mano en Robux desde el
		-- grupo: Roblox no deja que un juego pague Robux a un jugador. Un jugador
		-- normal tiene tarifa 0 y aqui le sale nil, asi que ni ve el panel.
		Partner = (tonumber(referrals.partnerRate) or 0) > 0 and {
			Rate = tonumber(referrals.partnerRate) or 0,
			Points = tonumber(referrals.points) or 0,
			Paid = tonumber(referrals.pointsPaid) or 0,
			Owed = math.max(0, (tonumber(referrals.points) or 0) - (tonumber(referrals.pointsPaid) or 0)),
		} or nil,
		RequiredSeconds = ReferralConfig.Settings.RequiredSeconds,
		Pending = pending,
		Rewards = rewards,
		Default = defaultState,
		Next = nextReward,
		LadderRatio = ReferralShared.GetLadderProgress(total),
		ServerTime = workspace:GetServerTimeNow(),
	}
end

--------------------------------------------------------------------------------
-- Reclamar
--------------------------------------------------------------------------------

local function giveReward(player: Player, currency: string, amount: number)
	Collections.Give(player, { [currency] = amount }, true)
end

--[[
	Reclama un hito por su Id, o la recompensa por defecto con el Id "default".

	El orden importa: primero se marca como reclamado y se guarda, y solo despues
	se da el dinero. Al reves, un fallo de guardado dejaria al jugador cobrando el
	mismo hito una y otra vez.
]]
function ReferralService.ClaimReward(player: Player, rewardId: string): (boolean, string?)
	if typeof(rewardId) ~= "string" then
		return false, "Recompensa invalida."
	end

	local store = PlayerDataService.get(player)
	if not store or not store:isReady() then
		return false, "Tus datos aun no han cargado."
	end

	local referrals = store:get().referrals
	local total = tonumber(referrals.total) or 0

	if rewardId == "default" then
		local default = ReferralShared.GetDefault()
		if not default then
			return false, "Esa recompensa no existe."
		end

		local earned = ReferralShared.CountDefaultEarned(total)
		local alreadyClaimed = math.min(tonumber(referrals.defaultClaimed) or 0, earned)
		local times = earned - alreadyClaimed

		if times <= 0 then
			return false, "Aun no tienes nada que reclamar aqui."
		end

		store:update(function(current)
			current.referrals.defaultClaimed = earned
			return current
		end)

		if not store:save("referral:claim") then
			return false, "No se pudo guardar. Intentalo otra vez."
		end

		giveReward(player, default.Currency, default.Amount * times)

		return true, nil
	end

	local reward = ReferralShared.GetRewardById(rewardId)
	if not reward then
		return false, "Esa recompensa ya no existe."
	end

	if total < reward.Friends then
		return false, ("Te faltan amigos para esta recompensa (%d de %d)."):format(total, reward.Friends)
	end

	for _, id in ipairs(referrals.claimed or {}) do
		if id == rewardId then
			return false, "Ya has reclamado esta recompensa."
		end
	end

	store:update(function(current)
		if typeof(current.referrals.claimed) ~= "table" then
			current.referrals.claimed = {}
		end

		if not table.find(current.referrals.claimed, rewardId) then
			table.insert(current.referrals.claimed, rewardId)
		end

		return current
	end)

	if not store:save("referral:claim") then
		return false, "No se pudo guardar. Intentalo otra vez."
	end

	giveReward(player, reward.Currency, reward.Amount)

	return true, nil
end

--------------------------------------------------------------------------------
-- Compartir
--------------------------------------------------------------------------------

--[[
	Lo que se le pasa al menu de compartir de Roblox. El link corto que genera
	lleva el mismo `ref` que el permanente, asi que da igual por cual entren.

	Solo se puede abrir desde el servidor, por eso lo llama ReferralMain y no la
	tablet.
]]
function ReferralService.GetShareOptions(player: Player)
	local share = (ReferralConfig.Link and ReferralConfig.Link.Share) or {}

	return {
		LaunchData = ReferralShared.BuildLaunchData(player.UserId),
		ExpirationSeconds = share.ExpirationSeconds,
		PreviewTitle = share.PreviewTitle,
		PreviewDescription = share.PreviewDescription,
		PreviewAssetId = share.PreviewAssetId,
	}
end

--------------------------------------------------------------------------------
-- Pruebas
--------------------------------------------------------------------------------

--[[
	Fuerza una invitacion sobre un jugador que ya esta dentro, saltandose las dos
	comprobaciones que en Studio no se pueden cumplir: que el perfil sea nuevo y
	que venga un `ReferredByPlayerId` (que solo existe en una sesion publicada).

	ESTA PUERTA SOLO ABRE EN STUDIO. En un servidor de verdad devuelve false sin
	hacer nada, pase lo que pase, para que no exista como agujero.
]]
function ReferralService.DebugForceInvite(player: Player, inviterId: number): (boolean, string?)
	if not RunService:IsStudio() then
		return false, "Solo disponible en Studio."
	end

	inviterId = tonumber(inviterId) or 0

	if inviterId <= 0 or inviterId == player.UserId then
		return false, "Invitador invalido."
	end

	local store = PlayerDataService.get(player)
	if not store or not store:isReady() then
		return false, "Sus datos aun no han cargado."
	end

	-- Se limpia el estado de invitado para poder repetir la prueba tantas veces
	-- como haga falta sobre el mismo perfil.
	store:update(function(current)
		current.referral.inviterId = 0
		current.referral.startedAt = 0
		current.referral.secs = 0
		current.referral.lastSeen = 0
		current.referral.done = false
		current.referral.consumed = false
		return current
	end)

	sessions[player] = nil

	return ReferralService.SetInviter(player, inviterId, "prueba de Studio")
end

--[[
	Cuanto lleva de sesion el jugador y cuanto le falta. Para mirar el contador sin
	esperar a que exista la interfaz.
]]
function ReferralService.DebugSession(player: Player)
	local session = sessions[player]

	if not session then
		return nil
	end

	return {
		Seconds = math.floor(session.secs),
		Required = ReferralConfig.Settings.RequiredSeconds,
		InviterId = session.inviterId,
		Done = session.done,
	}
end

--------------------------------------------------------------------------------
-- Admin
--------------------------------------------------------------------------------

--[[
	Resumen de un invitador para el comando /invites. Funciona con el jugador
	offline: lee su perfil sin cargarlo ni quitarle el candado a nadie.
]]
function ReferralService.GetSummary(userId: number)
	local data, ok = Profiles.WorldsPlayer.read(tostring(userId))

	if not ok or typeof(data) ~= "table" or typeof(data.referrals) ~= "table" then
		return nil
	end

	local referrals = data.referrals
	local total = tonumber(referrals.total) or 0
	local points = tonumber(referrals.points) or 0
	local pointsPaid = tonumber(referrals.pointsPaid) or 0
	local pendingCount = 0

	for _, entry in pairs(referrals.pending or {}) do
		if typeof(entry) == "table" and not entry.paid then
			pendingCount += 1
		end
	end

	return {
		Total = total,
		Rate = tonumber(referrals.partnerRate) or 0,
		Points = points,
		PointsPaid = pointsPaid,
		Owed = math.max(0, points - pointsPaid),
		InProgress = pendingCount,
		Code = referrals.code or "",
		JoinedAt = tonumber(data.joinedAt) or 0,
	}
end

--[[
	Marca a alguien como creador y le fija su tarifa en creditos por amigo. Rate 0
	lo deja de ser. Funciona con la persona desconectada.
]]
function ReferralService.SetPartnerRate(userId: number, rate: number): (boolean, string?)
	rate = math.max(0, math.floor(tonumber(rate) or 0))

	local onlinePlayer = Players:GetPlayerByUserId(userId)
	local store = onlinePlayer and PlayerDataService.get(onlinePlayer)

	if store and store:isReady() then
		store:update(function(current)
			current.referrals.partnerRate = rate
			return current
		end)

		store:save("referral:partner")

		return true, nil
	end

	if not Profiles.WorldsPlayer.send(tostring(userId), { kind = "referralPartner", rate = rate }) then
		return false, "No se pudo guardar la tarifa."
	end

	return true, nil
end

--[[
	Apunta creditos como pagados. Los ganados nunca se tocan: lo que sube es el
	contador de pagados, y la diferencia es lo que se debe.

	Funciona con la persona desconectada porque va por `send`.
]]
function ReferralService.MarkPaid(userId: number, amount: number): (boolean, string?)
	amount = math.floor(tonumber(amount) or 0)

	if amount == 0 then
		return false, "La cantidad tiene que ser distinta de cero."
	end

	local onlinePlayer = Players:GetPlayerByUserId(userId)
	local store = onlinePlayer and PlayerDataService.get(onlinePlayer)

	if store and store:isReady() then
		store:update(function(current)
			local paid = (tonumber(current.referrals.pointsPaid) or 0) + amount
			current.referrals.pointsPaid = math.max(0, paid)
			return current
		end)

		store:save("referral:paid")

		return true, nil
	end

	local sent = Profiles.WorldsPlayer.send(tostring(userId), {
		kind = "referralPaid",
		amount = amount,
	})

	if not sent then
		return false, "No se pudo apuntar el pago."
	end

	return true, nil
end

--[[
	Asigna un codigo a un usuario. Un codigo pertenece a una sola persona para
	siempre: reasignarlo romperia las cuentas de quien ya lo estuviera repartiendo.
]]
function ReferralService.AssignCode(userId: number, rawCode: string, ownerName: string?): (boolean, string?)
	local code, err = ReferralShared.NormalizeCode(rawCode)
	if not code then
		return false, err
	end

	local existing, ok = Profiles.ReferralCode.read(code)

	if not ok then
		return false, "No se pudo comprobar el codigo."
	end

	local ownerId = tonumber(existing and existing.userId) or 0

	if ownerId > 0 and ownerId ~= userId then
		return false, ("Ese codigo ya es de %d."):format(ownerId)
	end

	local codeStore = Profiles.ReferralCode.load(code)

	if not codeStore:awaitReady() then
		codeStore:close()
		return false, "No se pudo reservar el codigo."
	end

	codeStore:update(function(current)
		current.userId = userId
		current.ownerName = ownerName or current.ownerName
		current.createdAt = current.createdAt > 0 and current.createdAt or now()
		return current
	end)

	local saved = codeStore:save("referral:assignCode")
	codeStore:close()

	if not saved then
		return false, "No se pudo guardar el codigo."
	end

	-- Y se lo anotamos en su perfil para poder ensenarselo en la tablet.
	local onlinePlayer = Players:GetPlayerByUserId(userId)
	local store = onlinePlayer and PlayerDataService.get(onlinePlayer)

	if store and store:isReady() then
		store:update(function(current)
			current.referrals.code = code
			return current
		end)
		store:save("referral:assignCode")
	else
		Profiles.WorldsPlayer.send(tostring(userId), {
			kind = "referralCode",
			code = code,
		})
	end

	return true, nil
end

return ReferralService