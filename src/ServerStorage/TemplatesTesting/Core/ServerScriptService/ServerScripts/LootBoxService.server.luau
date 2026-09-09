--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TEST_MODE = false

--[ Modules ]--
local InventoryManager = require(ServerScriptService:WaitForChild("ServerScripts"):WaitForChild("inventory"):WaitForChild("InventoryManager"))
local AnimationManager = require(ServerScriptService.ServerScripts.AnimationSystem:WaitForChild("AnimationManager"))
local Collections = require(ReplicatedStorage.Client.EconomySystem:WaitForChild("Collections"))

--[ Remotes ]--
local PurchaseLootBoxRF = ReplicatedStorage:WaitForChild("Events"):WaitForChild("LootBox"):WaitForChild("PurchaseLootBoxRF")

--[ Data Setup ]--
local ToysFolder = ReplicatedStorage.Assets.Tools.Toys
local AnimationsData = require(game.ReplicatedStorage:WaitForChild("DancesInfo"))

local LOOTBOX_PRICES = {
	Coins = 500,
	ChestKey = 1
}

local AVAILABLE_LOOT = {}


for _, toy in ipairs(ToysFolder:GetChildren()) do
	table.insert(AVAILABLE_LOOT, {
		Name = toy.Name,
		Type = "Toy",
		ItemReference = toy
	})
end

for danceName, danceData in pairs(AnimationsData) do
	table.insert(AVAILABLE_LOOT, {
		Name = danceName,
		Type = "Dance",
		AssetId = danceData.assetId
	})
end

local function getUnownedLoot(player)
	local unownedList = {}

	for _, item in ipairs(AVAILABLE_LOOT) do
		if item.Type == "Toy" then
			if not InventoryManager.hasTool(player, item.Name) then
				table.insert(unownedList, item)
			end
		elseif item.Type == "Dance" then
			if not AnimationManager.HasAnimation(player, item.Name) then
				table.insert(unownedList, item)
			end
		end
	end

	return unownedList
end

local function getRandomReward(lootList)
	if #lootList == 0 then return nil end
	local randomIndex = math.random(1, #lootList)
	return lootList[randomIndex]
end

PurchaseLootBoxRF.OnServerInvoke = function(player, currencyType)
	local price = LOOTBOX_PRICES[currencyType]
	if not price then 
		return false, "Invalid currency type" 
	end

	if TEST_MODE then
		print("MODO PRUEBA ACTIVO: Ignorando economía e inventario para " .. player.Name)
		local reward = getRandomReward(AVAILABLE_LOOT)
		return true, reward
	end

	local unownedLoot = getUnownedLoot(player)

	if #unownedLoot == 0 then
		return false, "You already own all the rewards from this LootBox!"
	end

	local costData = {
		[currencyType] = price
	}

	local isPurchaseSuccessful = Collections.charge(player, costData, true)

	if isPurchaseSuccessful then
		local reward = getRandomReward(unownedLoot)

		if reward.Type == "Toy" then
			InventoryManager.addItem(player, reward.Name)
		elseif reward.Type == "Dance" then
			AnimationManager.AddAnimation(player, reward.Name)
		end

		return true, reward
	else
		return false, "Not enough " .. currencyType
	end
end