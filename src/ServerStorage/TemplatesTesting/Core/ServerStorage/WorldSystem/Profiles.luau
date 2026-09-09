--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataKit = require(script.Parent.Parent.DataKit)
local PlayerSchema = require(script.Parent.PlayerSchema)
local ReferralConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Referrals"):WaitForChild("ReferralConfig"))

--[=[
	Declara las cuatro identidades persistentes del juego.

	Todo lo que sobrevive a una sesión pasa por aquí. Cada entrada es un
	[`Profile`](/api/Profile) de DataKit: un nombre, una plantilla, y una política de
	conflicto. La política es la decisión de diseño importante, y no es la misma en todas:

	| Perfil | Clave | `onConflict` | Por qué |
	|---|---|---|---|
	| `WorldsPlayer` | `tostring(userId)` | por defecto (`"steal"`) | Un jugador **se mueve** entre servidores. La sesión anterior está muerta, así que tomar el relevo es seguro. |
	| `World` | `"{userId}_{room}"` | `"deny"` | Una casa hospedada **está viva** en otro servidor, con gente dentro. No se roba: el aspirante converge hacia el dueño. |
	| `Event` | id del evento | `"deny"` | Mismo motivo que una casa. |
	| `ReferralCode` | el código, en mayúsculas | `"deny"` | Un código lo posee una sola identidad. |

	`WorldsPlayer` declara además `maxMessages = 2000` y un manejador `onMessage`, que es lo
	que sostiene la entrega idempotente de las ventas de cuadros y de las recompensas de
	invitación. El tope está razonado en el propio código: sin él, alguien con muchos
	invitados que pase semanas sin entrar acumularía un mensaje por cada uno.

	`World` declara una proyección `card` —`{ name, ownerId, serverType }`— que es lo que lee
	el navegador de casas sin tener que cargar el perfil entero.

	@class Profiles
]=]
local Profiles = {}

-- Pasado el tope se descartan los mas viejos. Un youtuber que este semanas sin
-- entrar acumula un mensaje por cada invitado que entra y otro por cada uno
-- que completa; con 100 perderia amigos sin enterarse.
local MAX_MESSAGES = 2000

local function removeKey(list: any, key: any)
	if typeof(list) ~= "table" or typeof(key) ~= "string" then
		return
	end
	local index = table.find(list, key)
	if index then
		table.remove(list, index)
	end
end

local function freeMarcoSlot(marcos: any, marcoName: any)
	if typeof(marcos) ~= "table" or typeof(marcoName) ~= "string" then
		return
	end
	for _, marco in marcos do
		if typeof(marco) == "table" and marco.Name == marcoName then
			local fallback: string? = nil
			for field, value in marco do
				if typeof(field) == "string" and string.match(field, "^Slot") then
					if value then
						marco[field] = nil
						return
					end
					fallback = fallback or field
				end
			end
			if fallback then
				marco[fallback] = nil
			end
			return
		end
	end
end

local function bumpSellStat(data: any, amount: any)
	amount = tonumber(amount) or 0
	if amount <= 0 then
		return
	end
	local stats = data.stats
	if typeof(stats) ~= "table" then
		return
	end
	for _, stat in stats do
		if typeof(stat) == "table" and stat.Name == "Sell" then
			stat.Value = tostring((tonumber(stat.Value) or 0) + amount)
			return
		end
	end
end

--[[
	Invitaciones. Los dos mensajes los manda el servidor donde juega el INVITADO,
	y los recibe el perfil del INVITADOR, este conectado o no.

	- referralPending: alguien acaba de entrar con su link. Aparece en la lista de
	  "en progreso" de la tablet.
	- referralCompleted: ese alguien ha cumplido sus minutos. Suma amigo y sale de
	  la lista.

	El handler puede correr mas de una vez sobre el mismo mensaje si falla un save
	(lo dice la doc de Store), asi que todo lo de aqui tiene que ser idempotente.
	Por eso `referralCompleted` marca la entrada como cobrada en vez de borrarla a
	secas: si se repitiera, la segunda pasada ya no sumaria.
]]
local function applyReferralPending(data: any, message: any): any?
	local inviteeId = tonumber(message.inviteeId)
	if not inviteeId or inviteeId <= 0 then
		return data -- basura: consumir y olvidar
	end

	local referrals = data.referrals
	if typeof(referrals) ~= "table" then
		return data
	end

	if typeof(referrals.pending) ~= "table" then
		referrals.pending = {}
	end

	local key = tostring(inviteeId)
	local existing = referrals.pending[key]

	-- Ya cobrado: un pending que llega tarde no puede resucitarlo.
	if typeof(existing) == "table" and existing.paid then
		return data
	end

	referrals.pending[key] = {
		name = tostring(message.name or ""),
		startedAt = tonumber(message.startedAt) or os.time(),
		paid = false,
	}

	local limit = tonumber(ReferralConfig.Settings.MaxPendingPerInviter) or 0

	if limit > 0 then
		local open = {}

		for otherKey, entry in pairs(referrals.pending) do
			if typeof(entry) == "table" and not entry.paid then
				table.insert(open, { key = otherKey, startedAt = tonumber(entry.startedAt) or 0 })
			end
		end

		table.sort(open, function(a, b)
			return a.startedAt < b.startedAt
		end)

		for index = 1, #open - limit do
			referrals.pending[open[index].key] = nil
		end
	end

	return data
end

-- Cuantas caras de amigos ya completados se guardan. No es el total (ese no se
-- pierde nunca): es solo cuantas se pueden ensenar en la seccion.
local MAX_FRIEND_FACES = 24

local function applyReferralCompleted(data: any, message: any): any?
	local inviteeId = tonumber(message.inviteeId)
	if not inviteeId or inviteeId <= 0 then
		return data
	end

	local referrals = data.referrals
	if typeof(referrals) ~= "table" then
		return data
	end

	if typeof(referrals.pending) ~= "table" then
		referrals.pending = {}
	end

	local key = tostring(inviteeId)
	local entry = referrals.pending[key]

	-- La red de seguridad contra el doble conteo: si esta entrada ya se cobro, no
	-- se vuelve a sumar pase lo que pase.
	if typeof(entry) == "table" and entry.paid then
		return data
	end

	referrals.total = (tonumber(referrals.total) or 0) + 1

	-- Si es creador, este amigo le vale ademas creditos. Un jugador normal tiene
	-- tarifa 0 y no acumula ninguno. Se cobran a la tarifa que tenga AHORA:
	-- subirle la tarifa manana no repaga lo de ayer.
	local rate = tonumber(referrals.partnerRate) or 0

	if rate > 0 then
		referrals.points = (tonumber(referrals.points) or 0) + rate
	end

	-- La cara del amigo, para poder ensenar a quien invitaste y no solo cuantos.
	if typeof(referrals.friends) ~= "table" then
		referrals.friends = {}
	end

	local name = tostring(message.name or (typeof(entry) == "table" and entry.name) or "")

	table.insert(referrals.friends, 1, {
		id = inviteeId,
		name = name,
		at = os.time(),
	})

	while #referrals.friends > MAX_FRIEND_FACES do
		table.remove(referrals.friends)
	end

	referrals.pending[key] = {
		name = name,
		startedAt = typeof(entry) == "table" and entry.startedAt or os.time(),
		completedAt = os.time(),
		paid = true,
	}

	return data
end

Profiles.WorldsPlayer = DataKit.Profile.define("WorldsPlayer", PlayerSchema.Template, {
	maxMessages = MAX_MESSAGES,

	onMessage = function(data, message)
		if typeof(message) ~= "table" then
			return nil
		end

		if message.kind == "paintSold" then
			removeKey(data.paints.keys, message.keyCuadro)
			freeMarcoSlot(data.paints.marcos, message.marco)
			bumpSellStat(data, message.price)

			return data
		end

		if message.kind == "referralPending" then
			return applyReferralPending(data, message)
		end

		if message.kind == "referralCompleted" then
			return applyReferralCompleted(data, message)
		end

		-- Pagos apuntados por el admin y codigo asignado, para cuando la persona
		-- estaba desconectada en ese momento.
		if message.kind == "referralPaid" then
			local amount = tonumber(message.amount) or 0
			local paid = (tonumber(data.referrals.pointsPaid) or 0) + amount
			data.referrals.pointsPaid = math.max(0, paid)
			return data
		end

		if message.kind == "referralPartner" then
			data.referrals.partnerRate = math.max(0, tonumber(message.rate) or 0)
			return data
		end

		if message.kind == "referralCode" then
			if typeof(message.code) == "string" and message.code ~= "" then
				data.referrals.code = message.code
			end
			return data
		end

		return nil
	end,
})

--[[
	Registro de codigos manuales de invitacion: la identidad es el codigo en
	mayusculas y dentro solo va a quien pertenece. Se lee con
	`Profiles.ReferralCode.read("MICODIGO")`.

	`onConflict = "deny"` porque dos servidores asignando el mismo codigo a la vez
	debe fallar, no robarse el candado.
]]
Profiles.ReferralCode = DataKit.Profile.define("ReferralCode", {
	userId = 0,
	ownerName = "",
	createdAt = 0,
}, {
	onConflict = "deny",
})

Profiles.World = DataKit.Profile.define("World", {
	settings = {
		OwnerId = 0,
		Name = "Room",
		ServerType = "public",
	},
	roles = {},
	bans = {},
	content = {},
}, {
	onConflict = "deny",
	card = {
		project = function(data)
			return {
				name = data.settings.Name,
				ownerId = data.settings.OwnerId,
				serverType = data.settings.ServerType,
			}
		end,
	},
})

Profiles.Event = DataKit.Profile.define("Event", {
	name = "Evento",
	description = "",
	image = "",
	started = false,
	startedAt = 0,
	hostId = 0,
}, {
	onConflict = "deny",
})

return Profiles
