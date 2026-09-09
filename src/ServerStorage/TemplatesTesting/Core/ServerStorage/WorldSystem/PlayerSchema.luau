--!strict
--[[
	PlayerSchema

	Forma por defecto del perfil WorldsPlayer.

	Vive aparte de Profiles y de PlayerDataReplicator porque los dos lo necesitan:
	Profiles lo usa como template (DataKit lo reconcilia sobre lo cargado) y el
	replicador lo usa como red de seguridad cuando una clave llega nil.

	Las claves replicadas guardan ValueBase serializados con la forma:

		{ Name = "Coins", Value = "0", Childs = { ... }, <atributos> }

	Ojo con reconcile: solo rellena claves string. Una lista que ya existe en el
	perfil no recibe entradas nuevas, asi que para stats se hace merge por nombre
	en el replicador (ver SPEC).
]]

local PlayerSchema = {}

-- El orden de esta lista es el orden en el que aparecen en leaderstats.
PlayerSchema.Stats = {
	{ Name = "Coins", Value = "0" },
	{ Name = "Gems", Value = "0" },
	{ Name = "Level", Value = "0" },
	{ Name = "Xp", Value = "0" },
	{ Name = "Spins", Value = "0" },
	{ Name = "ChestKey", Value = "0" },
	{ Name = "Buy", Value = "0" },
	{ Name = "Sell", Value = "0" },
}

-- Bailes con los que arranca un jugador nuevo. Value = true significa "lo tiene".
PlayerSchema.Animations = {
	{ Name = "Twist", Value = true },
	{ Name = "Laugh", Value = true },
}

PlayerSchema.Template = {
	-- Mundos / sistema de casas
	rooms = { "defaultRoom" },
	slots = 2,
	favorites = {},
	gamePasses = {},

	inventory = {
		items = {},
		wheel = {},
	},

	paints = {
		keys = {},
		marcos = {},
	},

	-- Claves replicadas a Instances por PlayerDataReplicator
	stats = PlayerSchema.Stats,
	animations = PlayerSchema.Animations,
	storesData = { { Name = "Simple", Value = false } },
	stylesSalas = { { Name = "Classic" } },
	inventoryBuild = {},
	inventoryProducts = {},
	cooldowns = {},
	questData = { Name = "QuestData", Value = "" },
	guide = { Name = "GuideService", Value = false },
	lastPaint = { Name = "LastPaint", Value = "" },
	karaoke = { Name = "Biblioteca", Value = "" },
	materials = "",
	favoriteNightclub = "",

	-- Timestamp (os.time) de la PRIMERA vez que el jugador entro al juego. Se
	-- escribe una sola vez y no se vuelve a tocar. Vale 0 hasta entonces, y ese 0
	-- es justo la senal de "jugador nuevo" que usa el sistema de invitaciones.
	joinedAt = 0,

	-- Lo que este jugador es COMO INVITADO: quien lo trajo y como va su reto.
	referral = {
		inviterId = 0, -- userId del que lo invito
		startedAt = 0, -- cuando arranco la ventana de 48 h
		secs = 0, -- segundos jugados de la sesion actual
		lastSeen = 0, -- ultimo latido; pasada la gracia, secs vuelve a 0
		done = false, -- ya completo sus minutos
		consumed = true, -- ya se le atribuyo, o no puede serlo. Ver nota abajo.
	},

	-- Lo que este jugador es COMO INVITADOR.
	referrals = {
		total = 0, -- amigos completados de por vida. Nunca baja.
		claimed = {}, -- ids de hitos ya reclamados
		defaultClaimed = 0, -- veces que ha cobrado la recompensa por defecto
		pending = {}, -- [userId del invitado] = { name, startedAt }
		friends = {}, -- los que ya completaron: { id, name, at }. Se guardan para
		-- poder ensenar sus caras en la seccion; los mas antiguos se van cayendo.
		code = "", -- su codigo manual, si le asignaron uno

		--[[
			Creadores (influencers, gente contratada). Cobran CREDITOS ademas de la
			escalera de monedas, y esos creditos se pagan por fuera, en Robux, desde
			el grupo: Roblox no deja que un juego pague Robux a un jugador. El juego
			solo lleva la cuenta.

			`partnerRate > 0` es lo UNICO que separa a un creador de un jugador
			normal. Con tarifa 0 no se acumula ni un credito, asi que un jugador
			normal no es que los tenga escondidos: no existen para el.

			Las claves se siguen llamando `points` porque ya hay perfiles guardados
			con ese nombre; renombrarlas les vaciaria la cuenta.
		]]
		partnerRate = 0, -- creditos por cada amigo. 0 = no es creador
		points = 0, -- creditos ganados de por vida. Nunca baja.
		pointsPaid = 0, -- creditos ya pagados por fuera
	},
}

--[[
	Ojo con `referral.consumed = true` en el template.

	El default es "no se le puede atribuir", y es a proposito. Un perfil que ya
	existia antes de este sistema se reconcilia con el template y sale con
	consumed = true, asi que un jugador viejo no puede colarse como invitado de
	nadie. Solo ReferralService lo pone en false, y unicamente cuando comprueba
	que el perfil es nuevo de verdad (joinedAt == 0 y sin rastro de haber jugado).
]]

return PlayerSchema
