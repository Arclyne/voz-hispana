local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Referencias a los módulos hijos
local Manager = require(script.AnimationManager)
local DataConfig = require(game.ReplicatedStorage:WaitForChild("DancesInfo"))

local remotes = ReplicatedStorage.Events

-- Lógica de reproducción (Play/Stop)
-- Usamos los atributos que el Manager colocó en el BoolValue
local function playAnimation(player: Player, name: string, humanoid: Humanoid?)
	if not humanoid then
		humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	end

	-- Verificamos posesión usando el Manager o buscando la carpeta
	local animFolder = player:FindFirstChild("Animations")
	local animValue = animFolder and animFolder:FindFirstChild(name)

	if not animValue then
		warn(player.Name .. " intentó bailar " .. name .. " sin tenerlo.")
		return 
	end

	-- Obtenemos IDs de los atributos (mucho más rápido que requerir configs)
	local assetId = animValue:GetAttribute("AssetId")
	local looped = animValue:GetAttribute("Looped")
	local stopOnMove = animValue:GetAttribute("StopOnMove")

	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator or not assetId then return end

	-- Crear animación temporal
	local animation = Instance.new("Animation")
	animation.AnimationId = assetId

	-- Stop on move check inicial
	if stopOnMove and (humanoid :: Humanoid).MoveDirection.Magnitude > 0 then
		animation:Destroy()
		return
	end

	local track = animator:LoadAnimation(animation)
	track.Looped = looped or false
	track:Play()
	track:SetAttribute("Dance", true)
	animation:Destroy() 

	if stopOnMove then
		local connection
		connection = (humanoid :: Humanoid):GetPropertyChangedSignal("MoveDirection"):Connect(function()
			if (humanoid :: Humanoid).MoveDirection.Magnitude > 0 then
				if connection then connection:Disconnect() end
				track:Stop()
			end
		end)
		track.Stopped:Connect(function()
			if connection then connection:Disconnect() end
		end)
	end
end

local function stopAnimation(player: Player, humanoid: Humanoid?)
	if not humanoid then
		humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	end
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in animator:GetPlayingAnimationTracks() do
			if track:GetAttribute("Dance") then
				track:Stop()
			end
		end
	end
end

-- EVENTOS

remotes.Animate.OnServerEvent:Connect(function(player, name: string?)
	stopAnimation(player)
	if name then
		playAnimation(player, name)
	end
end)

remotes.Animator.GetAnimations.OnServerInvoke = function()
	return DataConfig
end

-- Consumido por la tienda de bailes (DancesController) para saber cuáles ya
-- tiene el jugador y mostrar "Comprada" en vez de "Comprar".
remotes.WorldSystem:WaitForChild("GetDances").OnServerInvoke = function(player: Player)
	return Manager.GetOwned(player)
end

-- Eliminamos AddAnimation remote por seguridad.

remotes.Animator.PlayAnimation.OnServerEvent:Connect(function(player, name: string?, humanoid: Humanoid?)
	if name then
		stopAnimation(player, humanoid)
		playAnimation(player, name, humanoid)
	end
end)