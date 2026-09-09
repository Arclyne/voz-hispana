local ReplicatedStorage = game:GetService("ReplicatedStorage")
local input_service = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local EventsFolder = ReplicatedStorage:WaitForChild("Events")

local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))
local Configuration = require(ReplicatedStorage:WaitForChild("GeneralConfiguration"))

local StoreModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Stores"))

local player = Players.LocalPlayer
local Icon = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Icon"))
local Events = ReplicatedStorage.Events:WaitForChild("IconsUI")

-- Función que crea un icono genérico
-- 'selectedImageID' es opcional: si se pasa, el icono queda en modo toggle
-- (imageID = estado Deselected, selectedImageID = estado Selected) en vez
-- de modo oneClick de una sola imagen.
local function createIcon(imageID, event, captionText, keyCodeEnum, selectedImageID)
	local icon = Icon.new()
	Icon.setDisplayOrder(9999)

	icon:align("Right")
	if selectedImageID then
		icon:setImage(imageID, "Deselected")
		icon:setImage(selectedImageID, "Selected")
	else
		icon:setImage(imageID)
	end
	icon:setImageScale(0.8)

	icon:setCaption(captionText.. keyCodeEnum.Name)
	icon:setCaptionHint(keyCodeEnum)

	icon:setTextFont("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)

	if not selectedImageID then
		icon:oneClick(true)

		icon.selected:Connect(function()
			if event then
				SoundManager:Play(player, 139037694620957, { Volume = 0.2 })
				event:Fire()
			else
				warn("No se ha definido un RemoteEvent para este icono")
			end
		end)
	else
		-- Modo toggle: solo disparamos el evento cuando el cambio viene de
		-- un click real del usuario (fromSource == "User"), para que las
		-- sincronizaciones programáticas del estado visual no disparen
		-- de más el remote de favoritos.
		local function onToggle(fromSource)
			if fromSource ~= "User" then return end
			if event then
				SoundManager:Play(player, 139037694620957, { Volume = 0.2 })
				event:Fire()
			else
				warn("No se ha definido un RemoteEvent para este icono")
			end
		end
		icon.selected:Connect(onToggle)
		icon.deselected:Connect(onToggle)
	end

	input_service.InputBegan:Connect(function(input, processed)
		if input.KeyCode == keyCodeEnum and not processed then
			-- Verificamos si el icono está habilitado antes de permitir el atajo de teclado
			if icon.isEnabled then 
				if event then
					SoundManager:Play(player, 139037694620957, { Volume = 0.2 })
					event:Fire()
				else
					warn("No se ha definido un RemoteEvent para este icono")
				end
			end
		end
	end)

	-- Devolvemos el objeto 'icon' para poder usarlo fuera
	return icon 
end

local function canCreateAdminButton()
	local placeTypeConfig = ReplicatedStorage:WaitForChild("PlaceType", 10)
	if not placeTypeConfig or placeTypeConfig:GetAttribute("placeType") ~= "room" then
		return false
	end

	local worldSystemRemotes = EventsFolder:WaitForChild("WorldSystem", 10)
	if not worldSystemRemotes then return false end
	local getUserRol = worldSystemRemotes:WaitForChild("GetUserRol", 10)
	if not getUserRol then return false end

	local rolesInfoModule = ReplicatedStorage:WaitForChild("RolesInfo", 10)
	if not rolesInfoModule then return false end
	local rolesInfo = require(rolesInfoModule)

	for _ = 1, 5 do
		local ok, result = pcall(function()
			return getUserRol:InvokeServer()
		end)
		if ok and result ~= nil then
			return result >= rolesInfo.moderator
		end
		task.wait(1)
	end
	return false
end

local iconTablet = nil
local iconAdmin = nil
local iconFavorite = nil

local FAVORITED_ICON = 128358391695543
local NOT_FAVORITED_ICON = 100211073126084

local function syncFavoriteIcon(favorites)
	if not iconFavorite then return end

	local ServerInfo = ReplicatedStorage:WaitForChild("ServerInfo")
	local serverKey = ServerInfo and ServerInfo:GetAttribute("ServerKey")
	if not serverKey then return end

	if not favorites then
		local WorldSystemEvents = EventsFolder:WaitForChild("WorldSystem")
		local GetFavoriteWorlds = WorldSystemEvents:WaitForChild("GetFavoriteWorlds")

		local ok, result = pcall(function()
			return GetFavoriteWorlds:InvokeServer()
		end)
		if not ok or not result then return end
		favorites = result
	end

	if table.find(favorites, serverKey) then
		iconFavorite:select("Init", iconFavorite)
	else
		iconFavorite:deselect("Init", iconFavorite)
	end
end

local function createIcons()
	-- No guardamos el icono porque no lo vamos a usar (por ejemplo)
	createIcon(
		2243841635,
		Events:WaitForChild("OpenAudioPlayers"),
		"Ver lista de jugadores a la ",
		Configuration.Interface.AudioPanelPlayers
	)

	-- Guardamos el icono en una variable para usarlo abajo en el ejemplo
	iconTablet = createIcon(
		119429673821416,
		Events:WaitForChild("OpenTablet"),
		"Usar tablet a la ",
		Configuration.Interface.TabletAccessKeycode
	)

	createIcon(
		86338793829287,
		Events:WaitForChild("OpenStats"),
		"Ver stats a la ",
		Configuration.Interface.StatsAccessKeycode
	)
	createIcon(
		89584974943167,
		Events:WaitForChild("OpenTools"),
		"Usar tools a la ",
		Configuration.Interface.ToolsAccessKeycode
	)
	createIcon(
		94199626866903,
		Events:WaitForChild("OpenDances"),
		"Usar bailes a la ",
		Configuration.Interface.DancesAccessKeycode
	)

	do
		if StoreModule.IsActive then
			local OpenConstruction = Instance.new("BindableEvent")
			OpenConstruction.Name = "OpenConstruction"
			OpenConstruction.Parent = Events
			local iconConstruction = createIcon(
				136339706389834,
				OpenConstruction,
				"Modo construcción ",
				Configuration.Interface.ConstructionAccessKeycode
			)
			iconConstruction:setEnabled(false)
			StoreModule.ButtonOpenMC = iconConstruction
		end

		if ReplicatedStorage:FindFirstChild("Shared"):FindFirstChild("NightClub") then
			local OpenNightClub = Instance.new("BindableEvent")
			OpenNightClub.Name = "OpenNightClub"
			OpenNightClub.Parent = Events
			local iconConstruction = createIcon(
				119066066279841,
				OpenNightClub,
				"Abrir panel Night club con ",
				Configuration.Interface.NightclubAccessKeycode
			)
		end

	end

	local adminChecked = false
	local favoriteCreated = false

	local function onStarted(isStarted)
		if not isStarted:GetAttribute("Started") then return end

		if not favoriteCreated then
			favoriteCreated = true
			iconFavorite = createIcon(
				NOT_FAVORITED_ICON,
				Events:WaitForChild("FavoriteWorld"),
				"Dar favorito a la ",
				Configuration.Interface.AdminPanelAccessKeycode,
				FAVORITED_ICON
			)
			iconFavorite:autoDeselect(false)

			task.spawn(function()
				local WorldSystemEvents = EventsFolder:WaitForChild("WorldSystem")
				local UpdateFavoriteWorlds = WorldSystemEvents:WaitForChild("UpdateFavoriteWorlds")
				UpdateFavoriteWorlds.OnClientEvent:Connect(function(favorites)
					syncFavoriteIcon(favorites)
				end)
			end)

			task.spawn(syncFavoriteIcon)
		end

		if not adminChecked then
			adminChecked = true
			task.spawn(function()
				if canCreateAdminButton() then
					iconAdmin = createIcon(
						121263432024857,
						Events:WaitForChild("OpenAdminPanel"),
						"Usar admin a la ",
						Configuration.Interface.AdminPanelAccessKeycode
					)
				end
			end)
		end
	end

	local isStarted = ReplicatedStorage:WaitForChild("isStarted", 5)
	if isStarted then
		isStarted:GetAttributeChangedSignal("Started"):Connect(function()
			onStarted(isStarted)
		end)

		if isStarted:GetAttribute("Started") then
			onStarted(isStarted)
		end
	end
end

createIcons()

-- EJEMPLO DE CÓMO ACTIVAR / DESACTIVAR PARA LYM
-- voy a desactivar la tablet por ejemplo a los 3s
--[[task.spawn(function()
	if iconTablet then
		print("Desactivando icono de tablet en 3 segundos...")
		task.wait(3)

		iconTablet:setEnabled(false) 
		print("Icono oculto/desactivado.")

		task.wait(3)

		print("Reactivando icono de tablet...")
		iconTablet:setEnabled(true)
	end
end)]]