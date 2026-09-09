--[[
	ReferralShared

	Lectura de ReferralConfig sin estado. Lo usan el servidor (para validar) y el
	cliente (para pintar), asi que los dos ven exactamente los mismos numeros.

	Nada de aqui escribe: si necesitas cambiar algo, se cambia en ReferralConfig.
]]

local ReferralConfig = require(script.Parent:WaitForChild("ReferralConfig"))

local ReferralShared = {}

-- Cache de la escalera ya ordenada. La config es estatica en runtime, asi que
-- se ordena una vez y se reparte la misma tabla (nadie la muta).
local sortedRewards: { any }? = nil

--[[
	Los hitos ordenados por numero de amigos. El orden en el que esten escritos
	en la config da igual.
]]
function ReferralShared.GetRewards()
	if sortedRewards then
		return sortedRewards
	end

	local list = {}
	local seenIds = {}

	for _, reward in ipairs(ReferralConfig.Rewards) do
		if typeof(reward.Id) ~= "string" or reward.Id == "" then
			warn("[ReferralShared] Hito sin Id, ignorado")
			continue
		end

		if seenIds[reward.Id] then
			warn("[ReferralShared] Id de hito duplicado, ignorado:", reward.Id)
			continue
		end

		if typeof(reward.Friends) ~= "number" or reward.Friends < 1 then
			warn("[ReferralShared] Hito con Friends invalido, ignorado:", reward.Id)
			continue
		end

		seenIds[reward.Id] = true
		table.insert(list, reward)
	end

	table.sort(list, function(a, b)
		return a.Friends < b.Friends
	end)

	sortedRewards = list

	return list
end

function ReferralShared.GetRewardById(id: string)
	for _, reward in ipairs(ReferralShared.GetRewards()) do
		if reward.Id == id then
			return reward
		end
	end

	return nil
end

--[[
	La recompensa por defecto ("+15") ya normalizada, o nil si esta apagada.
	`From` sale del ultimo hito cuando no se ha puesto a mano.
]]
function ReferralShared.GetDefault()
	local default = ReferralConfig.Default

	if not default or not default.Enabled then
		return nil
	end

	local amount = tonumber(default.Amount) or 0
	if amount <= 0 then
		return nil
	end

	local every = math.max(1, math.floor(tonumber(default.Every) or 1))
	local from = tonumber(default.From)

	if not from then
		local rewards = ReferralShared.GetRewards()
		local last = rewards[#rewards]
		from = last and (last.Friends + every) or every
	end

	return {
		From = math.max(1, math.floor(from)),
		Every = every,
		Currency = default.Currency or "Coins",
		Amount = amount,
		IsDefault = true,
	}
end

--[[
	Cuantas veces se ha ganado la recompensa por defecto con `friends` amigos.
]]
function ReferralShared.CountDefaultEarned(friends: number): number
	local default = ReferralShared.GetDefault()

	if not default or friends < default.From then
		return 0
	end

	return math.floor((friends - default.From) / default.Every) + 1
end

--[[
	El siguiente premio que le espera al jugador, sea un hito o la recompensa por
	defecto. Devuelve nil cuando ya no queda nada por delante (solo pasa si la
	recompensa por defecto esta apagada).

	La forma es siempre { Friends, Currency, Amount, Id?, IsDefault? }.
]]
function ReferralShared.GetNextReward(friends: number)
	friends = math.max(0, math.floor(friends or 0))

	for _, reward in ipairs(ReferralShared.GetRewards()) do
		if reward.Friends > friends then
			return reward
		end
	end

	local default = ReferralShared.GetDefault()
	if not default then
		return nil
	end

	local target = default.From

	if friends >= default.From then
		target = default.From + default.Every * (math.floor((friends - default.From) / default.Every) + 1)
	end

	return {
		Friends = target,
		Currency = default.Currency,
		Amount = default.Amount,
		IsDefault = true,
	}
end

--[[
	Progreso hacia el siguiente premio, para la barra de arriba de la seccion.
	Devuelve (desde, hasta, ratio). El tramo se mide entre el premio anterior y el
	siguiente, no desde cero, para que la barra no parezca parada al principio.
]]
function ReferralShared.GetProgressToNext(friends: number)
	friends = math.max(0, math.floor(friends or 0))

	local next = ReferralShared.GetNextReward(friends)
	if not next then
		return friends, friends, 1
	end

	local previous = 0

	for _, reward in ipairs(ReferralShared.GetRewards()) do
		if reward.Friends <= friends then
			previous = reward.Friends
		end
	end

	local default = ReferralShared.GetDefault()
	if default and friends >= default.From then
		previous = math.max(previous, next.Friends - default.Every)
	end

	local span = next.Friends - previous
	if span <= 0 then
		return previous, next.Friends, 1
	end

	return previous, next.Friends, math.clamp((friends - previous) / span, 0, 1)
end

--[[
	Progreso a lo largo de toda la escalera, 0..1. Es lo que pinta la barra de
	arriba de la seccion: con hitos de uno en uno, un tramo "del 4 al 5" siempre
	saldria vacio o lleno y no diria nada, mientras que "4 de 14" si se lee.

	Pasado el ultimo hito la barra se queda llena y manda el texto del siguiente
	premio por defecto.
]]
function ReferralShared.GetLadderProgress(friends: number): number
	friends = math.max(0, math.floor(friends or 0))

	local rewards = ReferralShared.GetRewards()
	local last = rewards[#rewards]

	if not last or last.Friends <= 0 then
		return friends > 0 and 1 or 0
	end

	return math.clamp(friends / last.Friends, 0, 1)
end

--[[
	Ratio del anillo de un invitado en curso, 0..1.
]]
function ReferralShared.GetSessionRatio(seconds: number): number
	local required = ReferralConfig.Settings.RequiredSeconds

	if required <= 0 then
		return 1
	end

	return math.clamp((seconds or 0) / required, 0, 1)
end

--[[
	"7 min", "1 h 20 min", "45 s". Para el tiempo que queda de sesion y para lo
	que le queda de vida a la invitacion.
]]
function ReferralShared.FormatDuration(seconds: number): string
	seconds = math.max(0, math.floor(seconds or 0))

	if seconds < 60 then
		return seconds .. " s"
	end

	local minutes = math.floor(seconds / 60)

	if minutes < 60 then
		return minutes .. " min"
	end

	local hours = math.floor(minutes / 60)
	local restMinutes = minutes % 60

	if restMinutes == 0 then
		return hours .. " h"
	end

	return hours .. " h " .. restMinutes .. " min"
end

--[[
	Normaliza un codigo tal y como lo escribe el jugador. Devuelve (codigo, error).
]]
function ReferralShared.NormalizeCode(raw: string): (string?, string?)
	if typeof(raw) ~= "string" then
		return nil, "Codigo invalido."
	end

	local code = string.upper((string.gsub(raw, "%s", "")))
	local codes = ReferralConfig.Codes

	if #code < codes.MinLength then
		return nil, "El codigo es demasiado corto."
	end

	if #code > codes.MaxLength then
		return nil, "El codigo es demasiado largo."
	end

	if not string.match(code, codes.Pattern) then
		return nil, "El codigo solo puede llevar letras, numeros y guion bajo."
	end

	return code, nil
end

--[[
	Lo que se mete en el link para decir quien invita. Lo leen los dos caminos, el
	link permanente y el corto del menu de compartir, asi que los dos acaban en la
	misma atribucion.

	Va el userId y no el nombre porque un nombre de Roblox se puede cambiar, y eso
	dejaria muerto todo lo que ese jugador ya hubiera repartido.
]]
function ReferralShared.BuildLaunchData(userId: number): string
	userId = tonumber(userId) or 0

	if userId <= 0 then
		return ""
	end

	return ("ref=%d"):format(userId)
end

--[[
	El link permanente de un jugador. Quien entre por el llega con ese `ref` en su
	join data y el servidor le atribuye la invitacion. No caduca, asi que es el
	que sirve para la descripcion de un video o un mensaje fijado de Discord.
]]
function ReferralShared.BuildLink(userId: number): string
	local link = ReferralConfig.Link
	local launchData = ReferralShared.BuildLaunchData(userId)

	if not link or (tonumber(link.PlaceId) or 0) <= 0 or launchData == "" then
		return ""
	end

	return ("https://www.roblox.com/games/start?placeId=%d&launchData=%s"):format(
		link.PlaceId,
		(launchData:gsub("=", "%%3D"))
	)
end

return ReferralShared
