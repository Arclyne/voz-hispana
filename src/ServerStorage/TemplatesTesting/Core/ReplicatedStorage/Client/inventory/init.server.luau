local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- Module Imports
local InventoryWheel = require(script:WaitForChild("InventoryWheel"))
local InventoryList = require(script:WaitForChild("InventoryList"))
local shared = ReplicatedStorage:WaitForChild("Shared")
local GuiScaleManager = require(shared:WaitForChild("GuiScaleManager"))

-- Player & Camera Reference
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- variables
local inventoryInitialised = false
local suppressWheelRemoveCount = 0

if not player.Character then
	player.CharacterAdded:Wait()
end

-- UI References & Remote Events
local remotes = ReplicatedStorage:WaitForChild("Events")
local inventory = player:WaitForChild("StarterGear")
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("InventoryUI")
local guiTablet = playerGui:WaitForChild("WorldSystemUI")

-- Path to tablet inventory frame
local inventoryFrame = guiTablet:WaitForChild("Menu")
	:WaitForChild("Inventory")
	:WaitForChild("Main")
	:WaitForChild("Content")
	:WaitForChild("Inventory")

-- Component Initialization
local list = InventoryList.new(inventoryFrame.list)
local wheel = InventoryWheel.new(inventoryFrame.wheel)
local tools = wheel:clone(gui.tools)

GuiScaleManager.Register(gui.tools, {
	pcScale = 0.7,
	tabletScale = 0.9,
	mobileScale = 1,
})

-- Input Configuration
tools:EnableKeyboard(true)

local openToolsEvent = remotes.IconsUI:WaitForChild("OpenTools")

-- Visual Effects Configuration
local BLUR_NAME = "InventoryBlur"
local TARGET_FOV = 65
local DEFAULT_FOV = 70 
local BLUR_SIZE = 24
local TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local blurEffect = Lighting:FindFirstChild(BLUR_NAME) or Instance.new("BlurEffect")
blurEffect.Name = BLUR_NAME
blurEffect.Size = 0
blurEffect.Parent = Lighting

--------------------------------------------------------------------------------
-- Visual State Management
--------------------------------------------------------------------------------

local function setVisuals(isOpen)
	local targetBlur = isOpen and BLUR_SIZE or 0
	local targetFov = isOpen and TARGET_FOV or DEFAULT_FOV

	if isOpen then
		DEFAULT_FOV = camera.FieldOfView
	end

	TweenService:Create(blurEffect, TWEEN_INFO, {Size = targetBlur}):Play()
	TweenService:Create(camera, TWEEN_INFO, {FieldOfView = targetFov}):Play()
end

local function toggleTools()
	local isOpening = not gui.tools.Visible
	gui.tools.Visible = isOpening
	setVisuals(isOpening)
end

--------------------------------------------------------------------------------
-- Helpers de Conteo y Lógica
--------------------------------------------------------------------------------

-- Helper para saber cuántos items tienes en total de un tipo
local function getItemCount(id: string)
	local tool = inventory:FindFirstChild(id)
	if tool then
		return tool:GetAttribute("Stack") or 1
	end
	return 0
end

-- Función PURA para quitar de la rueda
local removeItemFromWheel
removeItemFromWheel = function(index: number, replicateToServer: boolean?)
	local id = wheel:getItemByIndex(index)

	if id then
		if replicateToServer == false then
			suppressWheelRemoveCount += 1
		end

		wheel:removeItemByIndex(index)

		local count = getItemCount(id)
		if count > 0 then
			list:addItem(id, count)
		end
	end
end

-- Función PURA para añadir a la rueda (con reemplazo que devuelve el antiguo a la lista)
local function addItemToWheel(index: number, id: string)
	-- Si en ese slot había otro item, lo quitamos primero para devolverlo a la lista
	local replacedId = wheel:getItemByIndex(index)
	if replacedId and replacedId ~= id then
		removeItemFromWheel(index, false)
	end

	local count = getItemCount(id)
	local ok = wheel:addItem(index, id, count)
	if ok then
		list:removeItem(id)
	end
end

--------------------------------------------------------------------------------
-- Lógica Central de Inventario
--------------------------------------------------------------------------------

-- Actualiza todos los números (List y Wheel)
local function syncVisuals()
	-- 1. Actualizar Wheel
	for i = 1, 8 do
		local id = wheel:getItemByIndex(i)
		if id then
			local count = getItemCount(id)
			if count > 0 then
				wheel:updateSlotVisuals(i, count)
			else
				wheel:removeItemByIndex(i) -- Se gastó (llegó a 0)
			end
		end
	end

	-- 2. Actualizar List
	local processedIds = {}

	-- A. Revisar items que tenemos físicamente
	for _, item in pairs(inventory:GetChildren()) do
		local id = item.Name
		if not processedIds[id] then
			processedIds[id] = true
			local count = getItemCount(id)

			if not wheel:getSlotOfItem(id) then
				-- Si no está en la rueda, actualizamos la lista con el nuevo número
				list:addItem(id, count)
			else
				list:removeItem(id)
			end
		end
	end

	-- B. (Opcional) Limpiar de la lista visual cosas que ya no tenemos
	-- Como InventoryList no tiene método getItems, confiamos en que removeItem de abajo cubra esto,
	-- o que addItem actualice correctamente.
end

-- Lógica para nuevos items
local function handleNewItem(item)
	local id = item.Name
	local count = getItemCount(id)

	if wheel:getSlotOfItem(id) then
		syncVisuals()
		return
	end

	local emptySlot = wheel:getFirstEmptySlot()
	if emptySlot then
		addItemToWheel(emptySlot, id)
	else
		list:addItem(id, count)
	end
end

-- NUEVA FUNCIÓN: Conectar detectores de cambio a un item
local function connectItemStats(item)
	-- Escuchar cambios en el atributo Stack
	if item:IsA("Tool") then
		item:GetAttributeChangedSignal("Stack"):Connect(function()
			-- Cada vez que el número cambie (beber pocion, coger otra), refrescamos UI
			syncVisuals()
		end)
	end
end

--------------------------------------------------------------------------------
-- Event Listeners
--------------------------------------------------------------------------------

tools.clicked.Event:Connect(function(index, item)
	gui.tools.Visible = false
	setVisuals(false)
	if not item then return end 

	local character = player.Character
	if not character then return end

	local currentTool = character:FindFirstChildOfClass("Tool")
	if currentTool and currentTool.Name == item then
		remotes.Inventory.Unequip:FireServer()
	else
		remotes.Inventory.Equip:FireServer(item)
	end
end)

wheel.clicked.Event:Connect(function(index, item)
	removeItemFromWheel(index)
end)

wheel.removed.Event:Connect(function(index)
	if not inventoryInitialised then
		return
	end

	if suppressWheelRemoveCount > 0 then
		suppressWheelRemoveCount -= 1
		return
	end

	remotes.Inventory.WheelRemove:FireServer(index)
end)

list.dropped.Event:Connect(function(id, location)
	local index = wheel:getIndexAt(location)
	if index > 0 then
		addItemToWheel(index, id)
	end
end)

gui.toolbar.close.Activated:Connect(function()
	gui.toolbar.Visible = false
	remotes.Inventory.Unequip:FireServer()
end)

inventory.ChildAdded:Connect(function(object)
	-- 1. Conectar el "chivato" para ver si cambia su numero en el futuro
	connectItemStats(object)

	if not inventoryInitialised then
		task.defer(syncVisuals)
		return
	end
	-- 2. Manejar logica de entrada
	handleNewItem(object)
end)

inventory.ChildRemoved:Connect(function(object)
	syncVisuals()
end)

while player:GetAttribute("InventoryLoaded") ~= true do
	player:GetAttributeChangedSignal("InventoryLoaded"):Wait()
end

-- Initial Load
local initialWheelData = remotes.Inventory.GetWheel:InvokeServer()

-- Cargar Wheel Inicial
for index, id in pairs(initialWheelData) do
	local numIndex = tonumber(index)
	if numIndex and id then
		wheel:addItem(numIndex, id, getItemCount(id))
	end
end

-- IMPORTANTE: Conectar items que ya existían al entrar (DataStore)
for _, item in pairs(inventory:GetChildren()) do
	connectItemStats(item)
end

-- Sincronizar todo
syncVisuals()

inventoryInitialised = true

wheel.added.Event:Connect(function(index, id)
	if not inventoryInitialised then
		return
	end

	remotes.Inventory.WheelAdd:FireServer(index, id)
end)

local function onCharacterAdded(character: Model)
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if character.Name ~= player.Name then
		humanoidRootPart:AddTag("Player")
	end

	character.ChildAdded:Connect(function(instance)
		if instance:IsA("Tool") then
			gui.toolbar.Visible = true
			gui.toolbar.image.Image = instance.TextureId
		end
	end)
	character.ChildRemoved:Connect(function(instance)
		if instance:IsA("Tool") then
			gui.toolbar.Visible = false
		end
	end)
end

if player.Character then
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)

-- lo comento porque lo hacemos ahora en GameLoader
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) 
openToolsEvent.Event:Connect(toggleTools)