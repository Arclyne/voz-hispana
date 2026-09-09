--[[
	ReferralMain

	El cableado del sistema de invitar amigos: engancha a los jugadores que entran,
	lleva el bucle que suma los segundos de sesion y atiende los remotes de la
	tablet. La logica esta toda en ServerStorage.WorldSystem.ReferralService.

	Sigue el mismo patron que QuestMain, que hace exactamente esto para las
	misiones.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MessagingService = game:GetService("MessagingService")
local SocialService = game:GetService("SocialService")
local RunService = game:GetService("RunService")

local worldSystem = ServerStorage:WaitForChild("WorldSystem")
local ReferralService = require(worldSystem:WaitForChild("ReferralService"))
local PlayerDataService = require(worldSystem:WaitForChild("PlayerDataService"))
local ReferralConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Referrals"):WaitForChild("ReferralConfig"))

local PlayerInit = require(ReplicatedStorage:WaitForChild("PlayerInit"))

local referralEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Referrals")
local GetReferralState = referralEvents:WaitForChild("GetReferralState")
local ShareReferralLink = referralEvents:WaitForChild("ShareReferralLink")
local ClaimReferralReward = referralEvents:WaitForChild("ClaimReferralReward")
local ReferralUpdated = referralEvents:WaitForChild("ReferralUpdated")

local ShowNotification = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("ShowNotification")

local TICK_SECONDS = 1
local NOTIFY_FADE = 6
local NOTIFY_TOPIC = "ReferralNotify"

local REQUIRED_MINUTES = math.floor(ReferralConfig.Settings.RequiredSeconds / 60)
local MINUTES_TEXT = ReferralConfig.Settings.AccumulateAcrossSessions
	and ("%d minutos"):format(REQUIRED_MINUTES)
	or ("%d minutos seguidos"):format(REQUIRED_MINUTES)

--------------------------------------------------------------------------------
-- Avisos al invitador
--------------------------------------------------------------------------------

local function notifyLocal(userId: number, title: string, message: string): boolean
	local player = Players:GetPlayerByUserId(userId)

	if not player then
		return false
	end

	ShowNotification:FireClient(player, title, message, NOTIFY_FADE)
	ReferralUpdated:FireClient(player, ReferralService.GetState(player))

	return true
end

--[[
	El invitador casi nunca esta en el mismo servidor que el invitado, asi que el
	aviso sale por MessagingService y lo recoge el servidor donde este.

	Es best-effort a proposito: si el mensaje se pierde, la seccion de Amigos lee
	el estado real al abrirse y ahi aparece igual. Nada depende de este aviso.
]]
local function notifyInviter(userId: number, title: string, message: string)
	if notifyLocal(userId, title, message) then
		return
	end

	local ok, err = pcall(function()
		MessagingService:PublishAsync(NOTIFY_TOPIC, {
			userId = userId,
			title = title,
			message = message,
		})
	end)

	if not ok then
		warn("[ReferralMain] No se pudo publicar el aviso:", err)
	end
end

local subscribeOk, subscribeErr = pcall(function()
	MessagingService:SubscribeAsync(NOTIFY_TOPIC, function(packet)
		local payload = packet and packet.Data

		if typeof(payload) ~= "table" then
			return
		end

		notifyLocal(tonumber(payload.userId) or 0, tostring(payload.title), tostring(payload.message))
	end)
end)

if not subscribeOk then
	warn("[ReferralMain] No se pudo suscribir a los avisos:", subscribeErr)
end

ReferralService.OnPendingCreated = function(inviterId: number, inviteeName: string)
	notifyInviter(inviterId, "Amigo invitado", ("%s ha entrado con tu invitacion. Si juega %s, te llevas la recompensa."):format(inviteeName, MINUTES_TEXT))
end

ReferralService.OnCompleted = function(inviterId: number, inviteeName: string)
	notifyInviter(inviterId, "Amigo invitado", ("%s ha completado sus %d minutos. Ya puedes reclamar tu recompensa."):format(inviteeName, REQUIRED_MINUTES))
end

--------------------------------------------------------------------------------
-- Remotes
--------------------------------------------------------------------------------

GetReferralState.OnServerInvoke = function(player)
	return ReferralService.GetState(player)
end

--[[
	El menu de compartir de Roblox solo se puede abrir desde el servidor. Genera un
	link corto con el `ref` del jugador dentro y se lo pasa a la hoja de compartir
	del sistema; donde no haya hoja, Roblox lo copia al portapapeles.

	Si rechaza las opciones (la caducidad no tiene maximo documentado) se reintenta
	con las suyas por defecto, para que el jugador no se quede sin link por un
	numero de la config.
]]
local sharing: { [Player]: boolean } = {}

local function promptShare(player: Player): boolean
	local options = ReferralService.GetShareOptions(player)

	local ok, result = pcall(function()
		return SocialService:PromptLinkSharingAsync(player, options)
	end)

	if not ok then
		warn("[ReferralMain] No se pudo generar el link de", player.Name, result)

		options.ExpirationSeconds = nil

		ok, result = pcall(function()
			return SocialService:PromptLinkSharingAsync(player, options)
		end)
	end

	if not ok then
		warn("[ReferralMain] Sin link para", player.Name, result)
		return false
	end

	return result == Enum.PromptLinkSharingResult.Success
end

ShareReferralLink.OnServerEvent:Connect(function(player)
	if sharing[player] then
		return
	end

	-- Roblox devuelve 403 a los share links en Studio: solo existen en un
	-- servidor publicado. Mejor decirlo que ensenar un error que no lo es.
	if RunService:IsStudio() then
		ShareReferralLink:FireClient(player, "studio")
		return
	end

	sharing[player] = true
	local shared = promptShare(player)
	sharing[player] = nil

	if player.Parent == Players then
		ShareReferralLink:FireClient(player, shared)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	sharing[player] = nil
end)

ClaimReferralReward.OnServerEvent:Connect(function(player, rewardId)
	local ok, err = ReferralService.ClaimReward(player, rewardId)

	if not ok and err then
		ShowNotification:FireClient(player, "Amigos", err, NOTIFY_FADE)
	end

	ReferralUpdated:FireClient(player, ReferralService.GetState(player))
end)

--------------------------------------------------------------------------------
-- Ciclo de vida
--------------------------------------------------------------------------------

local function waitForData(player: Player): boolean
	local store = PlayerDataService.load(player)

	if not store:awaitReady() then
		return false
	end

	return player.Parent == Players
end

local function setupPlayer(player: Player)
	if not waitForData(player) then
		return
	end

	ReferralService.OnPlayerReady(player)

	-- task.wait devuelve lo que durmio de verdad, que con el servidor cargado es
	-- mas que TICK_SECONDS; sumar el nominal haria los 15 minutos mas largos.
	while player.Parent == Players do
		local elapsed = task.wait(TICK_SECONDS)
		ReferralService.Tick(player, elapsed)
	end
end

-- PlayerInit ya reejecuta el callback para los jugadores que estaban dentro
-- cuando se registra, asi que NO hay que recorrer Players:GetPlayers() aparte:
-- serian dos bucles sumando segundos al mismo jugador.
PlayerInit.Connect(function(player)
	task.spawn(setupPlayer, player)
end)

--[[
	El volcado va por onBeforeClose y no por PlayerRemoving: PlayerDataInit tambien
	escucha PlayerRemoving para cerrar el perfil, y el orden entre dos conexiones
	al mismo evento no esta garantizado. Si el perfil se cerrara primero, los
	segundos de la sesion se perderian y un teleport a una casa reiniciaria la
	cuenta. onBeforeClose corre siempre antes del cierre.
]]
PlayerDataService.onBeforeClose(function(player)
	ReferralService.OnPlayerLeaving(player)
end)
