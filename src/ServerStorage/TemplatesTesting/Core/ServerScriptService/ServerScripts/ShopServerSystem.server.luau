local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ShopSettings = require(ReplicatedStorage:WaitForChild("ShopSettings"))
local HousesInfo = require(ReplicatedStorage:WaitForChild("HousesInfo"))
local DancesInfo = require(ReplicatedStorage:WaitForChild("DancesInfo"))

local CategoryModules = {
	Houses = HousesInfo,
	Dances = DancesInfo
}

local Events = ReplicatedStorage:WaitForChild("Events")
local GetShopDataFunc = Events:WaitForChild("WorldSystem"):WaitForChild("GetShopData")
local BuyItemFunc = Events:WaitForChild("WorldSystem"):WaitForChild("BuyItem")
local ShopUpdatedEvent = Events:WaitForChild("WorldSystem"):WaitForChild("ShopUpdated")
local UpdateHouses = Events:WaitForChild("WorldSystem"):WaitForChild("UpdateHouses")
local UpdateDances = Events:WaitForChild("WorldSystem"):WaitForChild("UpdateDances")

local collections = require(ReplicatedStorage.Client.EconomySystem.Collections)
local worldSystemStorage = ServerStorage:WaitForChild("WorldSystem")
local PlayerDataService = require(worldSystemStorage:WaitForChild("PlayerDataService"))

local AnimationManager = require(game:GetService("ServerScriptService"):WaitForChild("ServerScripts"):WaitForChild("AnimationSystem"):WaitForChild("AnimationManager"))


local ShopQueue = MemoryStoreService:GetSortedMap("GlobalShopSystem_v2")
local KEY_NAME = "CurrentRotation"
local TOPIC_NAME = "ShopUpdateTopic"

local currentShopData = nil

-- Mientras currentShopData sea nil, el bucle de abajo llama a SyncShop cada 5 segundos.
-- Si la causa de que sea nil es que MemoryStore nos está frenando, eso son 36 unidades de
-- cuota por minuto dedicadas a empeorar el problema. Esta puerta lo corta.
local THROTTLE_COOLDOWN = 60
local blockedUntil = 0

local function isThrottled(err: any): boolean
	local text = tostring(err)
	return string.find(text, "RequestThrottled", 1, true) ~= nil
		or string.find(text, "TotalRequestsOverLimit", 1, true) ~= nil
end


local function GetUniqueRandomItems(sourceModule, countNeeded)
	local pool = {}

	for id, data in pairs(sourceModule) do
		if data.IsForSale then 
			table.insert(pool, {ID = id, Weight = data.rarityWeight})
		end
	end

	if #pool <= countNeeded then
		local results = {}
		for _, item in ipairs(pool) do
			table.insert(results, item.ID)
		end
		return results
	end

	local selectedIDs = {}

	for i = 1, countNeeded do
		local totalWeight = 0
		for _, item in ipairs(pool) do totalWeight = totalWeight + item.Weight end

		if totalWeight <= 0 then break end

		local randomNum = math.random(1, totalWeight)
		local currentCount = 0
		local indexToRemove = -1

		for index, item in ipairs(pool) do
			currentCount = currentCount + item.Weight
			if randomNum <= currentCount then
				table.insert(selectedIDs, item.ID)
				indexToRemove = index
				break
			end
		end
		
		if indexToRemove ~= -1 then
			table.remove(pool, indexToRemove)
		end
	end

	return selectedIDs
end

local function GenerateNewShopData()
	local newItemsStructure = {
		Houses = {},
		Dances = {}
	}

	for categoryName, slotCount in pairs(ShopSettings.DisplaySlots) do

		local targetModule = CategoryModules[categoryName]
		if not targetModule then
			warn("There is no module for the category: " .. tostring(categoryName))
			continue
		end

		local uniqueIDs = GetUniqueRandomItems(targetModule, slotCount)

		for _, selectedID in ipairs(uniqueIDs) do

			local discount = 0
			if math.random() < ShopSettings.Discounts.Chance then
				local min = ShopSettings.Discounts.MinPct
				local max = ShopSettings.Discounts.MaxPct
				local step = ShopSettings.Discounts.Step
				local stepsCount = math.floor((max - min) / step)
				discount = min + (math.random(0, stepsCount) * step)
			end

			table.insert(newItemsStructure[categoryName], {
				Id = selectedID,
				Discount = discount
			})
		end
	end

	return {
		RotationId = HttpService:GenerateGUID(false),
		NextRefreshTime = os.time() + ShopSettings.RefreshTime,
		Items = newItemsStructure
	}
end

local function SyncShop()
	if os.clock() < blockedUntil then
		return
	end

	local success, data = pcall(function()
		return ShopQueue:GetAsync(KEY_NAME)
	end)

	-- No leer no es lo mismo que "no hay rotación": si seguíamos, generábamos una tienda
	-- nueva y pedíamos un UpdateAsync para nada, con la cuota ya en rojo.
	if not success then
		if isThrottled(data) then
			blockedUntil = os.clock() + THROTTLE_COOLDOWN
			warn(("[Shop] Cuota de MemoryStore agotada; reintento en %ds."):format(THROTTLE_COOLDOWN))
		else
			warn("[Shop] no pude leer la rotación:", data)
		end
		return
	end

	if data and os.time() < data.NextRefreshTime then
		if currentShopData == nil or currentShopData.RotationId ~= data.RotationId then
			currentShopData = data
			ShopUpdatedEvent:FireAllClients(data)
		end
		return
	end

	local newData = GenerateNewShopData()
	local ttl = ShopSettings.RefreshTime + 600

	local updateSuccess, result = pcall(function()
		return ShopQueue:UpdateAsync(KEY_NAME, function(oldData)
			if oldData and os.time() < oldData.NextRefreshTime then
				return oldData 
			end
			return newData
		end, ttl)
	end)

	if updateSuccess then
		currentShopData = result
		MessagingService:PublishAsync(TOPIC_NAME, result.RotationId)
		ShopUpdatedEvent:FireAllClients(result)
		print("Store updated and published")
	elseif isThrottled(result) then
		blockedUntil = os.clock() + THROTTLE_COOLDOWN
		warn(("[Shop] Cuota agotada al publicar la rotación; reintento en %ds."):format(THROTTLE_COOLDOWN))
	else
		warn("error updating store:", result)
	end
end

local function ProcessPurchase(player, itemIdToBuy)
	if not currentShopData then return "Error: Store loading..." end

	if os.time() > currentShopData.NextRefreshTime then
		task.spawn(SyncShop)
		return "Offer expired"
	end

	local foundOffer = nil
	local sourceModule = nil
	local category = nil

	if currentShopData.Items.Houses then
		for _, item in ipairs(currentShopData.Items.Houses) do
			if item.Id == itemIdToBuy then
				foundOffer = item
				sourceModule = HousesInfo
				category = "Houses"
				break
			end
		end
	end

	if not foundOffer and currentShopData.Items.Dances then
		for _, item in ipairs(currentShopData.Items.Dances) do
			if item.Id == itemIdToBuy then
				foundOffer = item
				sourceModule = DancesInfo
				category = "Dances"
				break
			end
		end
	end

	if not foundOffer or not sourceModule then 
		return "Item currently unavailable" 
	end

	local staticInfo = sourceModule[itemIdToBuy]
	if not staticInfo then return "Static data error" end

	local finalPrice = staticInfo.price * (1 - (foundOffer.Discount / 100))
	finalPrice = math.floor(finalPrice)

	print(player.Name .. " try to buy " .. staticInfo.name .. " for " .. finalPrice)
	
	local value = collections.GetValue(player, staticInfo.currency)

	if value then
		if tonumber(value.Value) >= finalPrice or RunService:IsStudio() then
			if category == "Houses" then
				local store = PlayerDataService.get(player)
				if not (store and store:isReady()) then
					return "Error: Player data not loaded"
				end
				local data = store:get()
				if data and not table.find(data.rooms, itemIdToBuy) then
					store:update(function(current)
						if not table.find(current.rooms, itemIdToBuy) then
							table.insert(current.rooms, itemIdToBuy)
						end
						return current
					end)
					UpdateHouses:FireClient(player, store:get().rooms)
					if not RunService:IsStudio() then
						collections.SetAmount(player, value, tonumber(value.Value) - finalPrice)
					end
				else
					return "Error: Already owned"
				end
			elseif category == "Dances" then
				if AnimationManager.HasAnimation(player, itemIdToBuy) then
					return "Error: Already owned"
				end
				AnimationManager.AddAnimation(player, itemIdToBuy)
				UpdateDances:FireClient(player, AnimationManager.GetOwned(player))
				if not RunService:IsStudio() then
					collections.SetAmount(player, value, tonumber(value.Value) - finalPrice)
				end
			else
				return "Error: Unknown category"
			end
			return "Success"
		else
			return "Insufficient Funds"
		end
	else
		return "Error: currency not found"
	end
end

pcall(function()
	MessagingService:SubscribeAsync(TOPIC_NAME, function(message)
		print("Notification received. Resynchronizing...")
		SyncShop()
	end)
end)

task.spawn(function()
	while true do
		task.wait(5)
		if currentShopData then
			local timeLeft = currentShopData.NextRefreshTime - os.time()
			if timeLeft <= 0 then
				SyncShop()
			end
		else
			SyncShop()
		end
	end
end)

GetShopDataFunc.OnServerInvoke = function(player)
	return currentShopData
end

BuyItemFunc.OnServerInvoke = ProcessPurchase

SyncShop()