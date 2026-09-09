--!strict
--[[
	Comandos de chat para administrar el evento global.

		/reserveevent <placeId>                       — reserva el servidor del evento
		/startevent  <nombre> | <desc> | [imageId]    — inicia el evento (lo revela en la GUI)
		/editevent   <nombre> | <desc> | [imageId]    — edita el evento ya iniciado
		/endevent                                     — termina el evento

	Solo responden a los UserIds de ServerStorage.Admins; a cualquier otro los ignora
	en silencio (no revelamos qué comandos existen).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local Admins = require(ServerStorage:WaitForChild("RoleService"))
local worldSystemStorage = ServerStorage:WaitForChild("WorldSystem")
local EventService = require(worldSystemStorage:WaitForChild("EventService"))

local ShowNotification = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("ShowNotification")

local NOTIFY_FADE = 6

local function notify(player: Player, title: string, message: string)
	ShowNotification:FireClient(player, title, message, NOTIFY_FADE)
end

local function reply(player: Player, ok: boolean, err: string?, successMessage: string)
	if ok then
		notify(player, "Evento", successMessage)
	else
		notify(player, "Evento", err or "Algo salió mal.")
	end
end

local function trim(text: string): string
	return (text:gsub("^%s*(.-)%s*$", "%1"))
end

--[[
	Parte los argumentos por "|" y los limpia. "Fiesta | Ven a bailar | 123" da
	{"Fiesta", "Ven a bailar", "123"}.
]]
local function splitArgs(rest: string): { string }
	local parts = {}
	for piece in rest:gmatch("[^|]+") do
		table.insert(parts, trim(piece))
	end
	return parts
end

--[[
	Normaliza el argumento de imagen: acepta un id pelado o un rbxassetid:// completo.
	Devuelve nil si no vino, para que el evento conserve la imagen que ya tenía.
]]
local function normalizeImage(raw: string?): string?
	if not raw or raw == "" then
		return nil
	end
	if raw:match("^rbxassetid://%d+$") then
		return raw
	end
	local id = raw:match("^%d+$")
	if id then
		return "rbxassetid://" .. id
	end
	return nil
end

--------------------------------------------------------------------------------
-- Comandos
--------------------------------------------------------------------------------

local function cmdReserve(player: Player, rest: string)
	local placeId = tonumber(trim(rest))
	if not placeId then
		notify(player, "Evento", "Uso: /reserveevent <placeId>")
		return
	end

	notify(player, "Evento", "Reservando servidor...")
	local ok, err = EventService.reserve(player, placeId)
	if not ok then
		notify(player, "Evento", err or "No se pudo reservar el servidor.")
		return
	end

	-- En Studio nadie viaja a ningún lado: hay que decirle al admin cómo continuar.
	if RunService:IsStudio() then
		notify(
			player,
			"Evento",
			("Studio: reserva lista para la place %d. Detén el juego, abre esa place y dale Play para simular el teleport."):format(
				placeId
			)
		)
		warn(("[EventCommands] Studio: reserva lista para la place %d. Detén el juego y dale Play a esa place."):format(placeId))
	end
end

local function cmdStart(player: Player, rest: string)
	local args = splitArgs(rest)
	if #args < 2 then
		notify(player, "Evento", "Uso: /startevent <nombre> | <descripción> | [imageId]")
		return
	end

	local ok, err = EventService.start(args[1], args[2], normalizeImage(args[3]))
	reply(player, ok, err, ("Evento '%s' iniciado."):format(args[1]))
end

local function cmdEdit(player: Player, rest: string)
	local args = splitArgs(rest)
	if #args < 2 then
		notify(player, "Evento", "Uso: /editevent <nombre> | <descripción> | [imageId]")
		return
	end

	local ok, err = EventService.edit(args[1], args[2], normalizeImage(args[3]))
	reply(player, ok, err, "Evento actualizado.")
end

local function cmdEnd(player: Player, _rest: string)
	local ok, err = EventService.finish()
	if ok and RunService:IsStudio() then
		notify(player, "Evento", "Evento terminado. En Studio no hay teleport: en el juego real esto te devuelve al lobby.")
		return
	end
	reply(player, ok, err, "Evento terminado.")
end

local COMMANDS: { [string]: (Player, string) -> () } = {
	reserveevent = cmdReserve,
	startevent = cmdStart,
	editevent = cmdEdit,
	endevent = cmdEnd,
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

	-- Silencio total para no-admins: un comando desconocido y uno sin permiso se
	-- ven igual desde afuera.
	if not Admins:IsRole(player, "Admins") then
		return
	end

	local ok, err = pcall(handler, player, rest)
	if not ok then
		warn("[EventCommands] Error en /" .. command .. ":", err)
		notify(player, "Evento", "Error interno ejecutando el comando.")
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
