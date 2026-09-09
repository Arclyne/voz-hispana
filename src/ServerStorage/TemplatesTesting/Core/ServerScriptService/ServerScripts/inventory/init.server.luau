-- ServerScriptService/InventoryServer.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerInit = require(ReplicatedStorage:WaitForChild("PlayerInit"))
local InventoryManager = require(script:WaitForChild("InventoryManager"))

local WHEEL_SLOTS = 8
local remotes = ReplicatedStorage:WaitForChild("Events")
local inventoryRemotes = remotes:WaitForChild("Inventory")

inventoryRemotes:WaitForChild("Equip").OnServerEvent:Connect(function(player, name: string)
	if typeof(name) ~= "string" then
		return
	end

	if InventoryManager.hasTool(player, name) then
		InventoryManager.equipTool(player, name)
	end
end)

inventoryRemotes:WaitForChild("Unequip").OnServerEvent:Connect(function(player)
	InventoryManager.unequipTool(player)
end)

inventoryRemotes:WaitForChild("WheelAdd").OnServerEvent:Connect(function(player, index, id)
	if typeof(index) ~= "number" or index % 1 ~= 0 then
		return
	end

	if index <= 0 or index > WHEEL_SLOTS then
		return
	end

	if typeof(id) ~= "string" then
		return
	end

	InventoryManager.setWheelSlot(player, index, id)
end)

inventoryRemotes:WaitForChild("WheelRemove").OnServerEvent:Connect(function(player, index)
	if typeof(index) ~= "number" or index % 1 ~= 0 then
		return
	end

	if index <= 0 or index > WHEEL_SLOTS then
		return
	end

	InventoryManager.removeWheelSlot(player, index)
end)

inventoryRemotes:WaitForChild("GetWheel").OnServerInvoke = function(player)
	return InventoryManager.getWheelData(player)
end

local function connectCharacter(player, character)
	local humanoid = character:WaitForChild("Humanoid", 10)

	if humanoid then
		humanoid.Died:Connect(function()
			InventoryManager.unequipTool(player)
		end)
	end
end

local function OnPlayerAdded(player)
	if player:GetAttribute("InventorySystemLoaded") then
		return
	end

	player:SetAttribute("InventorySystemLoaded", true)
	player:SetAttribute("InventoryLoaded", false)

	local loaded = InventoryManager.loadOwnedTools(player)

	if not loaded then
		warn("No se pudo cargar inventario para " .. player.Name)
		player:SetAttribute("InventorySystemLoaded", nil)
		return
	end

	player:SetAttribute("InventoryLoaded", true)

	if player.Character then
		task.defer(connectCharacter, player, player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		connectCharacter(player, character)
	end)
end

PlayerInit.Connect(OnPlayerAdded)