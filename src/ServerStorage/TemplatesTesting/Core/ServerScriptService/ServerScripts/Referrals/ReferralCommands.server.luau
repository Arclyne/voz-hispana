--[[
	Comandos de chat para llevar las invitaciones de la gente contratada.

		/invites <usuario>            — total, creditos, lo que se debe y en progreso
		/socio   <usuario> <n>        — lo hace creador a n creditos por amigo (0 lo quita)
		/pagar   <usuario> <n>        — apunta n creditos como ya pagados
		/codigo  <usuario> <CODIGO>   — le asigna un codigo de invitacion
		/link    <usuario>            — su link permanente, para pasarselo a mano

	Los creditos son solo de los creadores: un jugador normal tiene tarifa 0 y no
	acumula ninguno. Lo suyo es la escalera de monedas, que se lleva todo el mundo.

	Todos funcionan con la persona desconectada.

	Como EventCommands: a quien no sea admin se le ignora en silencio, para no
	revelar que comandos existen.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local Admins = require(ServerStorage:WaitForChild("RoleService"))
local ReferralService = require(ServerStorage:WaitForChild("WorldSystem"):WaitForChild("ReferralService"))
local ReferralShared = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Referrals"):WaitForChild("ReferralShared"))

local ShowNotification = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("ShowNotification")

local NOTIFY_FADE = 10

local function notify(player: Player, message: string)
	ShowNotification:FireClient(player, "Invitaciones", message, NOTIFY_FADE)
	print("[ReferralCommands]", message)
end

local function trim(text: string): string
	return (text:gsub("^%s*(.-)%s*$", "%1"))
end

--[[
	Acepta un userId pelado o un nombre de usuario. El nombre se resuelve contra
	Roblox, asi que funciona con gente que no esta en el servidor.
]]
local function resolveUser(raw: string): (number?, string?)
	local text = trim(raw)

	if text == "" then
		return nil, "Falta el usuario."
	end

	local asId = tonumber(text)
	if asId and asId > 0 then
		return math.floor(asId), nil
	end

	local player = Players:FindFirstChild(text)
	if player and player:IsA("Player") then
		return player.UserId, nil
	end

	local ok, userId = pcall(function()
		return Players:GetUserIdFromNameAsync(text)
	end)

	if not ok or not userId then
		return nil, ("No encuentro al usuario '%s'."):format(text)
	end

	return userId, nil
end

local function describeUser(userId: number): string
	local ok, name = pcall(function()
		return Players:GetNameFromUserIdAsync(userId)
	end)

	if ok and name then
		return ("%s (%d)"):format(name, userId)
	end

	return tostring(userId)
end

--------------------------------------------------------------------------------
-- Comandos
--------------------------------------------------------------------------------

local function cmdInvites(player: Player, rest: string)
	local userId, err = resolveUser(rest)
	if not userId then
		notify(player, err or "Uso: /invites <usuario>")
		return
	end

	local summary = ReferralService.GetSummary(userId)
	if not summary then
		notify(player, ("No pude leer el perfil de %s."):format(describeUser(userId)))
		return
	end

	local codeText = summary.Code ~= "" and (" | codigo %s"):format(summary.Code) or ""
	local partnerText = ""

	if summary.Rate > 0 then
		partnerText = (" | CREADOR a %d creditos/amigo: %d ganados, %d pagados, debe %d"):format(
			summary.Rate, summary.Points, summary.PointsPaid, summary.Owed)
	end

	notify(player, ("%s: %d invitados | %d en progreso%s%s"):format(
		describeUser(userId),
		summary.Total,
		summary.InProgress,
		codeText,
		partnerText
	))
end

--[[
	Hace creador a alguien y le fija su tarifa en creditos por amigo. Es lo UNICO
	que separa a un creador de un jugador normal: tarifa 0 y no acumula creditos.

	Las tarifas se negocian una a una, por eso van en el comando y no en la config.
]]
local function cmdSocio(player: Player, rest: string)
	local target, rateText = rest:match("^(%S+)%s+(%d+)$")

	if not target then
		notify(player, "Uso: /socio <usuario> <creditos por amigo>  (0 para quitarle el trato)")
		return
	end

	local userId, err = resolveUser(target)
	if not userId then
		notify(player, err or "Usuario invalido.")
		return
	end

	local rate = tonumber(rateText) or 0
	local ok, failure = ReferralService.SetPartnerRate(userId, rate)

	if not ok then
		notify(player, failure or "No se pudo guardar la tarifa.")
		return
	end

	if rate == 0 then
		notify(player, ("%s ya no es creador."):format(describeUser(userId)))
	else
		notify(player, ("%s es creador a %d creditos por amigo."):format(describeUser(userId), rate))
	end
end

local function cmdPagar(player: Player, rest: string)
	local target, amountText = rest:match("^(%S+)%s+(-?%d+)$")

	if not target then
		notify(player, "Uso: /pagar <usuario> <creditos>")
		return
	end

	local userId, err = resolveUser(target)
	if not userId then
		notify(player, err or "Usuario invalido.")
		return
	end

	local amount = tonumber(amountText) or 0
	local ok, failure = ReferralService.MarkPaid(userId, amount)

	if not ok then
		notify(player, failure or "No se pudo apuntar el pago.")
		return
	end

	local summary = ReferralService.GetSummary(userId)

	if summary then
		notify(player, ("Apuntados %d creditos a %s. Ahora: %d ganados, %d pagados, debe %d."):format(
			amount,
			describeUser(userId),
			summary.Points,
			summary.PointsPaid,
			summary.Owed
		))
	else
		notify(player, ("Apuntados %d creditos a %s."):format(amount, describeUser(userId)))
	end
end

local function cmdCodigo(player: Player, rest: string)
	local target, rawCode = rest:match("^(%S+)%s+(%S+)$")

	if not target then
		notify(player, "Uso: /codigo <usuario> <CODIGO>")
		return
	end

	local userId, err = resolveUser(target)
	if not userId then
		notify(player, err or "Usuario invalido.")
		return
	end

	local code = ReferralShared.NormalizeCode(rawCode)
	local ok, failure = ReferralService.AssignCode(userId, rawCode, target)

	if not ok then
		notify(player, failure or "No se pudo asignar el codigo.")
		return
	end

	notify(player, ("Codigo %s asignado a %s."):format(tostring(code), describeUser(userId)))
end

--[[
	El link permanente de alguien, para mandarselo por fuera a un contratado. En la
	tablet solo hay boton de compartir, y el link que ese boton genera caduca; este
	no, asi que es el que vale para la descripcion de un video.

	Sale tambien por el output de Studio, que es de donde se puede copiar.
]]
local function cmdLink(player: Player, rest: string)
	local userId, err = resolveUser(rest)
	if not userId then
		notify(player, err or "Uso: /link <usuario>")
		return
	end

	local link = ReferralShared.BuildLink(userId)
	if link == "" then
		notify(player, "No hay PlaceId configurado en ReferralConfig.Link.")
		return
	end

	notify(player, ("Link de %s: %s"):format(describeUser(userId), link))
end

--[[
	Solo Studio. Se hace pasar por invitado de alguien para poder recorrer todo el
	sistema sin un link real, que en Studio no existe.
]]
local function cmdTestInvite(player: Player, rest: string)
	if not RunService:IsStudio() then
		return
	end

	local userId, err = resolveUser(rest)
	if not userId then
		notify(player, err or "Uso: /testinvite <usuario que te invita>")
		return
	end

	local ok, failure = ReferralService.DebugForceInvite(player, userId)

	if not ok then
		notify(player, failure or "No se pudo simular la invitacion.")
		return
	end

	notify(player, ("Ahora eres invitado de %s. Quedate en el juego para completar los minutos."):format(describeUser(userId)))
end

--[[
	Solo Studio. Cuanto llevas de sesion, para no tener que adivinar.
]]
local function cmdTestProgress(player: Player, _rest: string)
	if not RunService:IsStudio() then
		return
	end

	local session = ReferralService.DebugSession(player)

	if not session then
		notify(player, "No tienes ninguna invitacion en curso.")
		return
	end

	notify(player, ("%d de %d segundos | invitador %d | completada: %s"):format(
		session.Seconds,
		session.Required,
		session.InviterId,
		tostring(session.Done)
	))
end

local COMMANDS: { [string]: (Player, string) -> () } = {
	invites = cmdInvites,
	pagar = cmdPagar,
	codigo = cmdCodigo,
	link = cmdLink,
	socio = cmdSocio,
	testinvite = cmdTestInvite,
	testprogress = cmdTestProgress,
}

--------------------------------------------------------------------------------
-- Entrada
--------------------------------------------------------------------------------

local function onChatted(player: Player, message: string)
	local command, rest = message:match("^/(%a+)%s*(.*)$")
	if not command then
		return
	end

	local handler = COMMANDS[command:lower()]
	if not handler then
		return
	end

	if not Admins:IsRole(player, "Admins") then
		return
	end

	local ok, err = pcall(handler, player, rest)
	if not ok then
		warn("[ReferralCommands] Error en /" .. command .. ":", err)
		notify(player, "Error interno ejecutando el comando.")
	end
end

local function onPlayerAdded(player: Player)
	player.Chatted:Connect(function(message)
		onChatted(player, message)
	end)
end

for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
