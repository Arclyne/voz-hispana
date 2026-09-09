local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShopInfo = require(ReplicatedStorage:WaitForChild("ShopInfo"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local GamePassRewards = require(script:WaitForChild("GamePassRewards"))

local GamePassService = {}

local shopPassIds: { number } = {}
for _, info in ShopInfo do
	if info.Type == "GamePass" then
		local id = tonumber(info.MainId)
		if id and id > 0 then
			table.insert(shopPassIds, id)
		end
	end
end

local function getStore(player: Player)
	local store = PlayerDataService.get(player)
	if store and store:isReady() then
		return store
	end
	return nil
end

function GamePassService.list(player: Player): { number }
	local store = getStore(player)
	local data = store and store:get()
	return (data and data.gamePasses) or {}
end

function GamePassService.owns(player: Player, passId: number?): boolean
	local id = tonumber(passId)
	if not id then
		return false
	end
	return table.find(GamePassService.list(player), id) ~= nil
end


function GamePassService.grant(player: Player, passId: number?): boolean
	local id = tonumber(passId)
	if not id then
		warn("[GamePassService] Id de gamepass inválido:", passId)
		return false
	end

	local store = getStore(player)
	if not store then
		warn("[GamePassService] Perfil no cargado para", player.Name)
		return false
	end

	if table.find(store:get().gamePasses, id) then
		local rewardOk, rewardChanged = GamePassRewards.ensure(player, id)

		if not rewardOk then
			return false
		end

		if rewardChanged then
			return store:save("Manual")
		end

		return true
	end

	local before = table.concat(store:get().gamePasses, ", ")

	store:update(function(current)
		if not table.find(current.gamePasses, id) then
			table.insert(current.gamePasses, id)
		end
		return current
	end)

	local after = table.concat(store:get().gamePasses, ", ")
	print(string.format("[GamePassService] %s | gamePasses antes: {%s} -> despues: {%s}", player.Name, before, after))

	local rewardOk = GamePassRewards.ensure(player, id)
	if not rewardOk then
		return false
	end

	return store:save("Manual")
end


function GamePassService.syncFromRoblox(player: Player)
	if not getStore(player) then
		return
	end

	for _, passId in shopPassIds do
		if not GamePassService.owns(player, passId) then
			local ok, hasIt = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
			end)
			if not ok then
				warn("[GamePassService] UserOwnsGamePassAsync falló para", player.Name, passId, hasIt)
			elseif hasIt then
				GamePassService.grant(player, passId)
			end
		end
	end

	local rewardOk, rewardChanged = GamePassRewards.ensureAll(player, GamePassService.list(player))

	if not rewardOk then
		warn("[GamePassService] No se pudieron sincronizar todas las recompensas de", player.Name)
	elseif rewardChanged then
		local store = getStore(player)
		if store then
			store:save("Manual")
		end
	end
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
	if not wasPurchased then
		return
	end
	if table.find(shopPassIds, tonumber(passId) or 0) then
		GamePassService.grant(player, passId)
		print("[GamePassService] " .. player.Name .. " compró el gamepass " .. tostring(passId))
	end
end)

return GamePassService