local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Tus módulos
local PlayerInit = require(ReplicatedStorage:WaitForChild("PlayerInit"))
local CooldownManager = require(ReplicatedStorage.Shared.Cooldown:WaitForChild("CooldownManager"))
local Collections = require(ReplicatedStorage.Client.EconomySystem:WaitForChild("Collections"))
local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local showNotificationEvent = eventsFolder.Player:WaitForChild("ShowNotification")

-- Configuración
local REWARD_KEY = "SueldoTiempoJugado"
local REWARD_AMOUNT = 25
local REWARD_INTERVAL = 600 -- 10 minutos
local STAT_NAME = "Coins" 

local IMAGE_ID = 107645265535864
local SOUND_ID = 133962474176377

-----------------------------------
-- FUNCIÓN PARA DAR RECOMPENSA
-----------------------------------
local function DarRecompensa(player)
	local recompensa = {
		[STAT_NAME] = REWARD_AMOUNT
	}

	local success, err = pcall(function()
		Collections.Give(player, recompensa, true)
	end)

	if success then
		showNotificationEvent:FireClient(
			player, 
			"Sueldo", 
			"¡Gracias por jugar! +"..REWARD_AMOUNT.." monedas. Proxima recompensa en 10 minutos.", 
			5, 
			IMAGE_ID, 
			"rotate", 
			SOUND_ID
		)
	else
		warn("[Recompensas] Error al dar dinero a " .. player.Name .. ": " .. tostring(err))
	end
end

-----------------------------------
-- GESTIÓN DE ENTRADA AL JUEGO
-----------------------------------
PlayerInit.Connect(function(player)
	-- 1. Esperamos a que el sistema de Lym cree la carpeta de Cooldowns
	-- (Importante para no sobreescribir datos antes de que carguen)
	local cooldownFolder = player:WaitForChild("Cooldowns", 10)
	if not cooldownFolder then
		warn("[Recompensas] No se encontraron los cooldowns de " .. player.Name)
		return
	end

	-- 2. Revisamos la JoinData con SEGURIDAD AUTOMÁTICA
	local joinData = player:GetJoinData()
	-- Verificamos si el ID del universo de origen es idéntico a nuestro universo actual
	local vieneDeMiJuego = joinData.SourceGameId == game.GameId 

	if vieneDeMiJuego then
		print("[Recompensas] " .. player.Name .. " viene de un teleport SEGURO. Revisando cooldown...")
		local onCd, remaining = CooldownManager.IsOnCooldown(player, REWARD_KEY)

		if not onCd then
			-- El tiempo se acabó MIENTRAS viajaba de un place a otro.
			-- Le damos el premio atrasado y le reiniciamos el contador.
			print("[Recompensas] ¡El tiempo acabó durante el teleport! Dando premio a " .. player.Name)
			DarRecompensa(player)
			CooldownManager.Start(player, REWARD_KEY, REWARD_INTERVAL)
		else
			print("[Recompensas] Aún le quedan " .. remaining .. "s a " .. player.Name)
			-- Si onCd es true, no hacemos nada. El bucle de abajo seguirá su curso.
		end
	else
		-- Viene de la calle (inicio de sesión nuevo) O de un juego hackeado. Reseteamos a 10 minutos.
		print("[Recompensas] " .. player.Name .. " es un jugador nuevo/fresco o externo. Reseteando a 10 mins.")
		CooldownManager.Start(player, REWARD_KEY, REWARD_INTERVAL)
	end
end)

-----------------------------------
-- BUCLE PRINCIPAL DE TIEMPO
-----------------------------------
task.spawn(function()
	while task.wait(1) do
		for _, player in ipairs(Players:GetPlayers()) do
			-- Solo lo comprobamos si la carpeta existe (si Lym ya la cargó)
			if player:FindFirstChild("Cooldowns") then

				local onCd, _ = CooldownManager.IsOnCooldown(player, REWARD_KEY)

				-- Si ya no está en cooldown, significa que llegó a 0
				if not onCd then
					-- 1. Le damos el dinero
					DarRecompensa(player)
					-- 2. Le ponemos el cooldown otra vez (reiniciamos el ciclo)
					CooldownManager.Start(player, REWARD_KEY, REWARD_INTERVAL)
				end

			end
		end
	end
end)