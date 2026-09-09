local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local worldSystem = ServerStorage:WaitForChild("WorldSystem")
local PlayerDataService = require(worldSystem:WaitForChild("PlayerDataService"))

local assets = ReplicatedStorage.Assets
local InventoryManager = {}

local WHEEL_SLOTS = 8

local WHEEL_SAVE_DELAY = 30

local DefaultTools = require(script:WaitForChild("DefaultTools"))

local wheelSaveQueued: { [Player]: boolean } = {}

local function getToolAsset(toolName: string): Tool?
	local toolsFolder = assets:FindFirstChild("Tools")
	if not toolsFolder then
		return nil
	end

	local toolAsset = toolsFolder:FindFirstChild(toolName, true)
	if toolAsset and toolAsset:IsA("Tool") then
		return toolAsset
	end

	return nil
end

local function ensureInventoryData(data)
	data.inventory = data.inventory or {}
	data.inventory.items = data.inventory.items or {}
	data.inventory.wheel = data.inventory.wheel or {}

	return data.inventory
end

local function ensureDefaultInventory(inventory)
	-- Solo se ejecuta una vez en toda la vida de los datos del jugador.
	-- Es importante NO comprobar simplemente si el inventario está vacío,
	-- porque un jugador podría gastar/quitar todos sus objetos legítimamente.
	if inventory.defaultsInitialised then
		return
	end

	for _, toolData in pairs(DefaultTools) do
		if toolData.Value == true and typeof(toolData.Name) == "string" then
			local toolName = toolData.Name

			-- Empieza con una unidad
			inventory.items[toolName] = 1

			-- Si tiene slot por defecto, añadirlo también a la wheel
			if toolData.DefaultSlot then
				local slot = tonumber(toolData.DefaultSlot)

				if slot and slot >= 1 and slot <= WHEEL_SLOTS then
					inventory.wheel[tostring(slot)] = toolName
				else
					warn("[InventoryManager] DefaultSlot inválido para:", toolName)
				end
			end
		end
	end

	inventory.defaultsInitialised = true
end

local function getStoreReady(player: Player)
	local store = PlayerDataService.load(player)

	if not store:awaitReady() then
		warn("[InventoryManager] Store no listo para", player.Name)
		return nil
	end

	if not store:canWrite() then
		warn("[InventoryManager] Store no escribible para", player.Name)
		return nil
	end

	return store
end

local function queueWheelSave(player: Player)
	if wheelSaveQueued[player] then
		return
	end

	wheelSaveQueued[player] = true

	task.delay(WHEEL_SAVE_DELAY, function()
		if not wheelSaveQueued[player] then
			return
		end

		wheelSaveQueued[player] = nil

		if not player.Parent then
			return
		end

		local store = PlayerDataService.get(player)
		if not store or not store:canWrite() then
			return
		end

		local ok, result = pcall(function()
			return store:save("InventoryWheel")
		end)

		if not ok then
			warn("[InventoryManager] Error guardando wheel:", player.Name, result)
		elseif result == false then
			warn("[InventoryManager] DataKit no confirmó guardado de wheel:", player.Name)
		end
	end)
end

local function getInventoryData(player: Player)
	local data = PlayerDataService.getData(player)
	if not data then
		return nil
	end

	return ensureInventoryData(data)
end

local function getItemCount(player: Player, name: string): number
	local inventory = getInventoryData(player)
	if not inventory then
		return 0
	end

	local count = inventory.items[name]
	if typeof(count) ~= "number" then
		return 0
	end

	return math.max(0, count)
end

local function setPhysicalToolInContainer(container: Instance?, toolName: string, count: number)
	if not container then
		return
	end

	local existing = container:FindFirstChild(toolName)

	if count <= 0 then
		if existing then
			existing:Destroy()
		end

		return
	end

	if existing and existing:IsA("Tool") then
		existing:SetAttribute("Stack", count)
		return
	end

	if existing then
		existing:Destroy()
	end

	local toolAsset = getToolAsset(toolName)
	if not toolAsset then
		warn("[InventoryManager] No existe Tool asset:", toolName)
		return
	end

	local clone = toolAsset:Clone()
	clone:SetAttribute("Stack", count)
	clone.Parent = container
end

local function syncPhysicalTool(player: Player, toolName: string, count: number)
	setPhysicalToolInContainer(player:FindFirstChild("StarterGear"), toolName, count)

	local character = player.Character
	local equippedTool = character and character:FindFirstChild(toolName)

	if equippedTool and equippedTool:IsA("Tool") then
		setPhysicalToolInContainer(character, toolName, count)

		local backpackCopy = player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild(toolName)
		if backpackCopy then
			backpackCopy:Destroy()
		end
	else
		setPhysicalToolInContainer(player:FindFirstChild("Backpack"), toolName, count)
	end
end

local function normalizePhysicalTool(player: Player, toolName: string, count: number)
	local containers = {
		player:FindFirstChild("StarterGear"),
		player:FindFirstChild("Backpack"),
		player.Character,
	}

	for _, container in ipairs(containers) do
		if not container then
			continue
		end

		local firstTool = nil

		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("Tool") and child.Name == toolName then
				if not firstTool then
					firstTool = child
				else
					-- Nunca debería haber dos instancias físicas
					-- de la misma Tool dentro del mismo contenedor.
					child:Destroy()
				end
			end
		end

		if firstTool then
			firstTool:SetAttribute("Stack", count)
		end
	end
end

local function clearManagedPhysicalTools(player: Player)
	local function clearContainer(container: Instance?)
		if not container then
			return
		end

		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("Tool") and getToolAsset(child.Name) then
				child:Destroy()
			end
		end
	end

	clearContainer(player:FindFirstChild("Backpack"))
	clearContainer(player:FindFirstChild("StarterGear"))

	if player.Character then
		clearContainer(player.Character)
	end
end

function InventoryManager.hasTool(player: Player, name: string)
	if typeof(name) ~= "string" then
		return false
	end

	return getItemCount(player, name) > 0
end

function InventoryManager.addItem(player: Player, name: string)
	if typeof(name) ~= "string" then
		return false
	end

	if not getToolAsset(name) then
		return false
	end

	local store = getStoreReady(player)
	if not store then
		return false
	end

	local newCount = 0

	store:update(function(data)
		local inventory = ensureInventoryData(data)
		local current = inventory.items[name]

		if typeof(current) ~= "number" then
			current = 0
		end

		newCount = current + 1
		inventory.items[name] = newCount

		return data
	end)

	syncPhysicalTool(player, name, newCount)

	return true
end

function InventoryManager.setItemCount(player: Player, name: string, count: number)
	if typeof(name) ~= "string" then
		return false, false
	end

	if not getToolAsset(name) then
		warn("[InventoryManager] No existe Tool asset:", name)
		return false, false
	end

	count = tonumber(count)

	if not count or count < 0 or count % 1 ~= 0 then
		return false, false
	end

	local store = getStoreReady(player)
	if not store then
		return false, false
	end

	local changed = false

	store:update(function(data)
		local inventory = ensureInventoryData(data)
		local current = inventory.items[name]

		if current ~= count then
			changed = true
		end

		if count <= 0 then
			inventory.items[name] = nil

			-- Si desaparece completamente, tampoco puede seguir
			-- ocupando un slot de la wheel.
			for slot, itemName in pairs(inventory.wheel) do
				if itemName == name then
					inventory.wheel[slot] = nil
				end
			end
		else
			inventory.items[name] = count
		end

		return data
	end)

	syncPhysicalTool(player, name, count)
	normalizePhysicalTool(player, name, count)

	return true, changed
end

function InventoryManager.loadOwnedTools(player: Player)
	local store = getStoreReady(player)
	if not store then
		return false
	end

	-- Inicializar inventario por defecto si es la primera vez
	store:update(function(data)
		local inventory = ensureInventoryData(data)
		ensureDefaultInventory(inventory)
		return data
	end)

	local inventory = getInventoryData(player)
	if not inventory then
		return false
	end

	clearManagedPhysicalTools(player)

	for toolName, count in pairs(inventory.items) do
		if typeof(toolName) == "string" and typeof(count) == "number" and count > 0 then
			syncPhysicalTool(player, toolName, count)
		end
	end

	return true
end
function InventoryManager.equipTool(player: Player, name: string)
	if typeof(name) ~= "string" then
		return
	end

	if not InventoryManager.hasTool(player, name) then
		return
	end

	if not player.Character then
		return
	end

	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local ownedTool = player.Backpack:FindFirstChild(name)
	if ownedTool and ownedTool:IsA("Tool") then
		humanoid:EquipTool(ownedTool)
	end
end

function InventoryManager.unequipTool(player: Player, NameItem)
	local humanoid = player and player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	if not NameItem or InventoryManager.isEquipped(player, NameItem) then
		local equippedTool = player.Character:FindFirstChildOfClass("Tool")

		if equippedTool then
			if InventoryManager.hasTool(player, equippedTool.Name) then
				humanoid:UnequipTools()
			else
				equippedTool:Destroy()
			end
		end
	end
end

function InventoryManager.isEquipped(player: Player, name: string)
	if not player.Character then
		return false
	end

	local equippedTool = player.Character:FindFirstChildOfClass("Tool")
	return equippedTool and equippedTool.Name == name
end

function InventoryManager.removeItem(player: Player, name: string)
	if typeof(name) ~= "string" then
		return false
	end

	local store = getStoreReady(player)
	if not store then
		return false
	end

	local newCount = 0

	store:update(function(data)
		local inventory = ensureInventoryData(data)
		local current = inventory.items[name]

		if typeof(current) ~= "number" then
			current = 0
		end

		newCount = math.max(0, current - 1)

		if newCount <= 0 then
			inventory.items[name] = nil

			for slot, itemName in pairs(inventory.wheel) do
				if itemName == name then
					inventory.wheel[slot] = nil
				end
			end
		else
			inventory.items[name] = newCount
		end

		return data
	end)

	syncPhysicalTool(player, name, newCount)

	return true
end

function InventoryManager.setWheelSlot(player: Player, index: number, id: string)
	if typeof(id) ~= "string" then
		return false
	end

	local cleanIndex = tonumber(index)
	if not cleanIndex or cleanIndex <= 0 or cleanIndex > WHEEL_SLOTS then
		return false
	end

	if not InventoryManager.hasTool(player, id) then
		return false
	end

	local store = getStoreReady(player)
	if not store then
		return false
	end

	store:update(function(data)
		local inventory = ensureInventoryData(data)

		for slot, itemName in pairs(inventory.wheel) do
			if tonumber(slot) == cleanIndex or itemName == id then
				inventory.wheel[slot] = nil
			end
		end

		inventory.wheel[tostring(cleanIndex)] = id

		return data
	end)

	queueWheelSave(player)

	return true
end

function InventoryManager.removeWheelSlot(player: Player, index: number)
	local cleanIndex = tonumber(index)
	if not cleanIndex or cleanIndex <= 0 or cleanIndex > WHEEL_SLOTS then
		return false
	end

	local store = getStoreReady(player)
	if not store then
		return false
	end

	store:update(function(data)
		local inventory = ensureInventoryData(data)
		inventory.wheel[tostring(cleanIndex)] = nil
		return data
	end)

	queueWheelSave(player)

	return true
end

function InventoryManager.getWheelData(player: Player)
	local store = getStoreReady(player)
	if not store then
		return {}
	end

	local inventory = getInventoryData(player)
	if not inventory then
		return {}
	end

	local result = {}

	for slot, itemName in pairs(inventory.wheel) do
		local slotNumber = tonumber(slot)

		if slotNumber and slotNumber >= 1 and slotNumber <= WHEEL_SLOTS then
			if typeof(itemName) == "string" and InventoryManager.hasTool(player, itemName) then
				result[tostring(slotNumber)] = itemName
			end
		end
	end

	return result
end

Players.PlayerRemoving:Connect(function(player)
	wheelSaveQueued[player] = nil
end)

return InventoryManager