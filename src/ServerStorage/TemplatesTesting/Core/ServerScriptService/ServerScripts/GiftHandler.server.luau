local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RequestGiftEvent = ReplicatedStorage.Events.WorldSystem:WaitForChild("RequestGift")
local CanAcquireGamePassEvent = ReplicatedStorage.Events.WorldSystem:WaitForChild("CanAcquireGamePass")
local ShopInfo = require(ReplicatedStorage:WaitForChild("ShopInfo"))
local worldSystemStorage = ServerStorage:WaitForChild("WorldSystem")
local PlayerDataService = require(worldSystemStorage:WaitForChild("PlayerDataService"))
local collections = require(ReplicatedStorage.Client.EconomySystem.Collections)
local Monetizacion = require(ReplicatedStorage:FindFirstChild("Shared"):WaitForChild("Monetization"))
local GamePassService = require(worldSystemStorage:WaitForChild("GamePassService"))
local GiftInbox = require(worldSystemStorage:WaitForChild("GiftInbox"))
local PlayerInit = require(ReplicatedStorage:WaitForChild("PlayerInit"))


local GIFT_INTENT_TTL = 600

local pendingGifts = {}

local function isConfigured(id: any): boolean
	return (tonumber(id) or 0) > 0
end

local function findByGiftProduct(productId: number)
	for _, info in ShopInfo do
		if isConfigured(info.GiftProductId) and tonumber(info.GiftProductId) == productId then
			return info
		end
	end
	return nil
end

local function findGamePassByMainId(passId: number)
	for _, info in ShopInfo do
		if info.Type == "GamePass" and isConfigured(info.MainId) and tonumber(info.MainId) == passId then
			return info
		end
	end
	return nil
end

local function ownsGamePass(player: Player, passId: number): (boolean?, string?, string)
	local store = PlayerDataService.get(player)
	if not (store and store:isReady()) then
		return nil, "Los datos del jugador todavía se están cargando. Inténtalo de nuevo.", "DataLoading"
	end

	if GamePassService.owns(player, passId) then
		return true, nil, "PlayerProfile"
	end

	local success, ownsOnRoblox = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
	end)

	if not success then
		warn("[GiftHandler] No se pudo verificar el gamepass", passId, "para", player.Name, ownsOnRoblox)
		return nil, "No se pudo verificar el gamepass ahora mismo. Inténtalo de nuevo.", "RobloxError"
	end

	return ownsOnRoblox == true, nil, "RobloxOwnership"
end

CanAcquireGamePassEvent.OnServerInvoke = function(player, passId, operation, targetUserId)
	passId = tonumber(passId)
	local info = passId and findGamePassByMainId(passId)

	if not info then
		return false, "Ese gamepass no existe."
	end

	local targetPlayer
	if operation == "Buy" then
		-- Una compra personal siempre comprueba al jugador que invocó el remote.
		-- Ignoramos cualquier UserId enviado por el cliente para evitar mezclarlo
		-- con el último destinatario de un regalo.
		targetPlayer = player
	elseif operation == "Gift" then
		targetUserId = tonumber(targetUserId)
		if not targetUserId or targetUserId == player.UserId then
			return false, "Selecciona a otro jugador para regalarle el gamepass."
		end
		targetPlayer = Players:GetPlayerByUserId(targetUserId)
		if not targetPlayer then
			return false, "Ese jugador ya no está en el servidor."
		end
	else
		return false, "Operación de compra inválida."
	end

	local owns, reason, ownershipSource = ownsGamePass(targetPlayer, passId)
	if owns == nil then
		return false, reason, targetPlayer.UserId, ownershipSource
	end

	if owns then
		if operation == "Buy" then
			return false, "Ya tienes " .. tostring(info.name) .. ". No puedes comprarlo otra vez.", targetPlayer.UserId, ownershipSource
		end
		return false, targetPlayer.Name .. " ya tiene " .. tostring(info.name) .. ". No puedes regalárselo otra vez.", targetPlayer.UserId, ownershipSource
	end

	return true, nil, targetPlayer.UserId, ownershipSource
end

RequestGiftEvent.OnServerInvoke = function(player, targetUserId, productId)
	targetUserId = tonumber(targetUserId)
	productId = tonumber(productId)
	if not targetUserId or not productId then
		return false, "Datos inválidos"
	end

	local info = findByGiftProduct(productId)
	if not info then
		return false, "Ese producto no existe"
	end

	if not info.Giftable then
		return false, "Este artículo no se puede regalar"
	end

	if targetUserId == player.UserId then
		return false, "No puedes regalarte a ti mismo"
	end

	local targetPlayer = Players:GetPlayerByUserId(targetUserId)
	if not targetPlayer then
		return false, "Ese jugador ya no está en el servidor"
	end

	if info.Type == "GamePass" then
		local owns, reason = ownsGamePass(targetPlayer, tonumber(info.MainId))
		if owns == nil then
			return false, reason
		end
		if owns then
			return false, targetPlayer.Name .. " ya tiene este gamepass. No puedes regalárselo otra vez."
		end
	end

	pendingGifts[player.UserId] = {
		TargetId = targetUserId,
		ProductId = productId,
		At = os.clock(),
	}

	return true
end

local function takeIntent(buyerId: number, productId: number)
	local intent = pendingGifts[buyerId]
	if not intent or intent.ProductId ~= productId then
		return nil
	end

	pendingGifts[buyerId] = nil

	if os.clock() - intent.At > GIFT_INTENT_TTL then
		return nil
	end

	return intent
end


MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, wasPurchased)
	if wasPurchased then
		return
	end
	local intent = pendingGifts[userId]
	if intent and intent.ProductId == tonumber(productId) then
		pendingGifts[userId] = nil
	end
end)

Players.PlayerRemoving:Connect(function(player)
	pendingGifts[player.UserId] = nil
end)

local function giveCurrency(player, currencyName, amount)
	amount = tonumber(amount) or 0

	local value = collections.GetValue(player, currencyName)
	if value then
		collections.SetAmount(player, value, (tonumber(value.Value) or 0) + amount)
		print("Se añadieron " .. amount .. " " .. currencyName .. " a " .. player.Name)
		return true
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local stat = leaderstats and leaderstats:FindFirstChild(currencyName)

	if stat and stat:IsA("ValueBase") then
		local current = tonumber(stat.Value) or 0
		local newValue = current + amount

		if stat:IsA("IntValue") or stat:IsA("NumberValue") then
			stat.Value = newValue
		else
			stat.Value = tostring(newValue)
		end

		print("Se añadieron " .. amount .. " " .. currencyName .. " (leaderstats) a " .. player.Name)
		return true
	end

	warn("Error: No se encontró la moneda '" .. tostring(currencyName) .. "' en el jugador " .. player.Name)
	return false
end

local ProductItems = {}

for _, itemInfo in pairs(ShopInfo) do
	local mainId = tonumber(itemInfo.MainId)
	local giftProductId = tonumber(itemInfo.GiftProductId)

	if isConfigured(mainId) then
		ProductItems[mainId] = {
			Info = itemInfo,
			IsGiftProduct = false,
		}
	end

	if isConfigured(giftProductId) then
		ProductItems[giftProductId] = {
			Info = itemInfo,
			-- Los gamepasses usan un Developer Product distinto para regalar.
			-- Nunca debe procesarse como una compra personal si falta el destinatario.
			IsGiftProduct = itemInfo.Type == "GamePass" and giftProductId ~= mainId,
		}
	end
end

local function applyItem(player, itemInfo): boolean
	if itemInfo.Type == "DevProduct" then
		if not (itemInfo.Currency and itemInfo.Amount) then
			warn("Producto configurado incorrectamente (Falta Currency o Amount): " .. (itemInfo.name or "Unknown"))
			return false
		end
		return giveCurrency(player, itemInfo.Currency, itemInfo.Amount)
	elseif itemInfo.Type == "GamePass" then
		return GamePassService.grant(player, itemInfo.MainId)
	end

	warn("Tipo de producto desconocido: " .. tostring(itemInfo.Type))
	return false
end


local function deliverLater(receiverId: number, itemInfo, fromUserId: number?): boolean
	local entry

	if itemInfo.Type == "GamePass" then
		entry = { kind = "gamePass", id = tonumber(itemInfo.MainId), from = fromUserId }
	elseif itemInfo.Type == "DevProduct" and itemInfo.Currency and itemInfo.Amount then
		entry = { kind = "currency", currency = itemInfo.Currency, amount = itemInfo.Amount, from = fromUserId }
	end

	if not entry then
		return false
	end

	return GiftInbox.push(receiverId, entry)
end

local function processReceipt(receiptInfo)
	local buyerId = receiptInfo.PlayerId
	local productId = tonumber(receiptInfo.ProductId) -- normaliza

	local ComprasLym = Monetizacion:VerificarCompraProduct(receiptInfo)
	if ComprasLym then return Enum.ProductPurchaseDecision.PurchaseGranted end

	local productEntry = productId and ProductItems[productId]
	if not productEntry then
		warn("No handler found for product: " .. tostring(receiptInfo.ProductId))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local itemInfo = productEntry.Info
	local intent = takeIntent(buyerId, productId)

	if productEntry.IsGiftProduct and not intent then
		-- Seguridad crítica: un producto creado exclusivamente para regalar jamás
		-- cae al comprador por defecto. Roblox volverá a intentar este recibo.
		warn("[GiftHandler] Recibo de regalo sin destinatario; no se otorgó a nadie. Comprador:", buyerId, "Producto:", productId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if intent and intent.TargetId == buyerId then
		warn("[GiftHandler] Intención de regalo inválida: comprador y receptor coinciden", buyerId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local receiverId = intent and intent.TargetId or buyerId

	local receiverPlayer = Players:GetPlayerByUserId(receiverId)
	if not receiverPlayer then
		
		if deliverLater(receiverId, itemInfo, buyerId) then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if intent and itemInfo.Type == "GamePass" then
		local owns, reason = ownsGamePass(receiverPlayer, tonumber(itemInfo.MainId))
		if owns == nil then
			warn("[GiftHandler] Receipt en espera porque no se pudo verificar la propiedad:", reason)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		if owns then
			warn("[GiftHandler] Se bloqueó una entrega duplicada de", itemInfo.name, "a", receiverPlayer.Name)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end

	local success, result = pcall(applyItem, receiverPlayer, itemInfo)

	if success and result == true then
		if intent then
			local buyerPlayer = Players:GetPlayerByUserId(buyerId)
			local buyerName = buyerPlayer and buyerPlayer.Name or ("Jugador " .. buyerId)
			print(buyerName .. " le regaló " .. (itemInfo.name or "un item") .. " a " .. receiverPlayer.Name)
		else
			print(receiverPlayer.Name .. " compró " .. (itemInfo.name or "un item"))
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		warn("Error procesando compra: " .. tostring(result))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

local function onPlayerAdded(player: Player)
	local store = PlayerDataService.load(player)
	if not store:awaitReady() then
		return
	end

	GamePassService.syncFromRoblox(player)

	for _, entry in GiftInbox.drain(player.UserId) do
		if entry.kind == "gamePass" then
			GamePassService.grant(player, entry.id)
		elseif entry.kind == "currency" then
			giveCurrency(player, entry.currency, entry.amount)
		end
	end
end

PlayerInit.Connect(onPlayerAdded)

MarketplaceService.ProcessReceipt = processReceipt
