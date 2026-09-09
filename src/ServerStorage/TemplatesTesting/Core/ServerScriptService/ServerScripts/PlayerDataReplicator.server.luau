--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local worldSystemStorage = ServerStorage:WaitForChild("WorldSystem")
local PlayerDataService = require(worldSystemStorage:WaitForChild("PlayerDataService"))
local PlayerInit = require(ReplicatedStorage:WaitForChild("PlayerInit"))
local GeneralConfiguration = require(ReplicatedStorage:WaitForChild("GeneralConfiguration"))
local collections = require(ReplicatedStorage:WaitForChild("Client").EconomySystem.Collections)
-- Remotes
local events = ReplicatedStorage:WaitForChild("Events")
local worldSystem = events:WaitForChild("WorldSystem")

local GetHousesEvent = worldSystem:WaitForChild("GetHouses")
local GetFavoriteWorlds = worldSystem:WaitForChild("GetFavoriteWorlds")
local UpdateHausesEvent = worldSystem:WaitForChild("UpdateHouses")
local GetSlots = worldSystem:WaitForChild("GetSlots")
local UpdateSlots = worldSystem:WaitForChild("UpdateSlots")
local BuySlot = worldSystem:WaitForChild("BuySlot")


local function getPlayerHouses(player: Player)
	local data = PlayerDataService.getData(player)
	return data and data.rooms or nil
end

local function getPlayerSlots(player: Player)
	local data = PlayerDataService.getData(player)
	return data and data.slots or nil
end

local function getFavoriteWorlds(player: Player)
	local data = PlayerDataService.getData(player)
	return data and data.favorites or nil
end

-- Una compra a la vez por jugador: dos invokes simultáneos leerían el mismo
-- `slots` y cobrarían dos veces por el mismo espacio.
local buying: { [Player]: boolean } = {}

local function buySlot(player: Player): (boolean, string?)
	if buying[player] then
		return false, "Compra en curso"
	end
	buying[player] = true

	local ok, err = (function(): (boolean, string?)
		local store = PlayerDataService.get(player)
		if not (store and store:isReady()) then
			return false, "Tus datos aún no cargan"
		end

		local nextSlot = store:get().slots + 1
		if nextSlot > GeneralConfiguration.MaxRooms then
			return false, "Ya tienes todos los espacios"
		end

		local price = GeneralConfiguration.HouseSlots.Prices[nextSlot]
		if not price then
			return false, "Ese espacio no está a la venta"
		end

		local wallet = collections.GetValue(player, GeneralConfiguration.HouseSlots.Currency)
		if not wallet then
			return false, "No se encontró tu monedero"
		end

		local amount = tonumber(wallet.Value) or 0
		if amount < price then
			return false, "Fondos insuficientes"
		end

		store:update(function(current)
			current.slots = math.min(current.slots + 1, GeneralConfiguration.MaxRooms)
			return current
		end)
		collections.SetAmount(player, wallet, amount - price)

		return true
	end)()

	buying[player] = nil
	return ok, err
end

GetHousesEvent.OnServerInvoke = getPlayerHouses
GetSlots.OnServerInvoke = getPlayerSlots
GetFavoriteWorlds.OnServerInvoke = getFavoriteWorlds
BuySlot.OnServerInvoke = buySlot

local function pushPlayerData(player: Player, data: any)
	UpdateHausesEvent:FireClient(player, data.rooms)
	UpdateSlots:FireClient(player, data.slots)
end

local function OnPlayerAdded(player: Player)
	local store = PlayerDataService.load(player)

	store:onChanged():Connect(function(data)
		pushPlayerData(player, data)
	end)

	if store:isReady() then
		pushPlayerData(player, store:get())
	else
		store:onReady():Connect(function()
			pushPlayerData(player, store:get())
		end)
	end
end

PlayerInit.Connect(OnPlayerAdded)

game:GetService("Players").PlayerRemoving:Connect(function(player)
	buying[player] = nil
end)