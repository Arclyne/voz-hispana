local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local InventoryManager = require(ServerScriptService:WaitForChild("ServerScripts"):WaitForChild("inventory"):WaitForChild("InventoryManager"))
local Collections = require(ReplicatedStorage.Client.EconomySystem:WaitForChild("Collections"))

local Kitchen = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("Food"):WaitForChild("Kitchen")

local remotes = ReplicatedStorage.Events
local fridgeRemote = remotes.Interactable:WaitForChild("Fridge")

local MAX_DISTANCE = 20

local VALID_SECTIONS = {
	Preparada = true,
	Principales = true,
	Postres = true,
}

local VALID_CURRENCIES = {
	Coins = true,
	Gems = true,
}

local function getFirstTool(sectionName, dishName)
	local section = Kitchen:FindFirstChild(sectionName)

	if not section or not section:IsA("Folder") then
		return nil
	end

	local dishFolder = section:FindFirstChild(dishName)

	if not dishFolder or not dishFolder:IsA("Folder") then
		return nil
	end

	local toolName = dishName .. " - 1"
	local tool = dishFolder:FindFirstChild(toolName)

	if tool and tool:IsA("Tool") then
		return tool
	end

	return nil
end

local function canUseFridge(player, model)
	if not model
		or not model:IsA("Model")
		or not model:IsDescendantOf(workspace) then
		return false
	end

	if not CollectionService:HasTag(model, "Fridge") then
		return false
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not root or not humanoid or humanoid.Health <= 0 then
		return false
	end

	local distance = (
		root.Position - model:GetPivot().Position
	).Magnitude

	return distance <= MAX_DISTANCE
end

fridgeRemote.OnServerEvent:Connect(function(player, model, sectionName, dishName)
	if typeof(sectionName) ~= "string"
		or typeof(dishName) ~= "string" then
		return
	end

	if not VALID_SECTIONS[sectionName] then
		return
	end

	if not canUseFridge(player, model) then
		return
	end

	if player:GetAttribute("InventoryLoaded") ~= true then
		return
	end

	local firstTool = getFirstTool(sectionName, dishName)

	if not firstTool then
		warn(
			"[Fridge] No se encontró la Tool inicial:",
			sectionName,
			dishName
		)
		return
	end

	local price = firstTool:GetAttribute("Price")
	local currency = firstTool:GetAttribute("Currency")

	if typeof(price) ~= "number" or price < 0 then
		warn("[Fridge] Price inválido en", firstTool:GetFullName())
		return
	end

	if typeof(currency) ~= "string" or not VALID_CURRENCIES[currency] then
		warn("[Fridge] Currency inválida en", firstTool:GetFullName(), currency)
		return
	end

	local cost = {
		[currency] = price
	}

	local purchaseSuccess = Collections.charge(player, cost, true)

	if not purchaseSuccess then
		return
	end

	local itemAdded = InventoryManager.addItem(player, firstTool.Name)

	if not itemAdded then
		warn(
			"[Fridge] Se cobró la compra pero InventoryManager no pudo entregar:",
			firstTool.Name,
			"a",
			player.Name
		)
	end
end)