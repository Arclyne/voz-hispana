--!strict

-- =======================
-- Logs
-- =======================
local LOG_SUCCESS = true
local TAG = "[Nametag]"

local function info(...)
	if LOG_SUCCESS then
		print(TAG, ...)
	end
end

local function warnLog(...)
	warn(TAG, ...)
end

local function fullNameSafe(obj: Instance?): string
	if not obj then
		return "nil"
	end

	local ok, result = pcall(function()
		return obj:GetFullName()
	end)

	if ok then
		return result
	end

	return tostring(obj)
end

-- =======================
-- Servicios
-- =======================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalizationService = game:GetService("LocalizationService")

-- =======================
-- Config
-- =======================
local VIP_GAMEPASS_ID: number? = nil -- usa gamepass o atributo IsVIP

local COUNTRY_LABEL_NAME = "1Country"
local NAME_LABEL_NAME = "2Name"
local LEVEL_LABEL_NAME = "3Level"
local GROUP_TAG_NAME = "4GroupTag"
local VIP_TAG_NAME = "5VipTag"

local GROUP_LAYOUT_ORDER = 4
local VIP_LAYOUT_ORDER = 5

local CHARACTER_READY_TIMEOUT = 15

-- =======================
-- Arquitectura propia
-- =======================
local PlayerInit = require(ReplicatedStorage:WaitForChild("PlayerInit"))

-- =======================
-- Módulos Nametag
-- =======================
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NametagFolder = Shared:WaitForChild("Nametag")

local Countries = require(NametagFolder:WaitForChild("Countries"))
local GroupRoles = require(NametagFolder:WaitForChild("GroupRoles"))
local LevelStyler = require(NametagFolder:WaitForChild("LevelStyler"))

-- =======================
-- Utilidades
-- =======================
local function waitUntilCharacterIsInWorkspace(player: Player, character: Model, timeout: number): boolean
	local start = os.clock()

	while os.clock() - start < timeout do
		if player.Character ~= character then
			return false
		end

		if character:IsDescendantOf(workspace) then
			return true
		end

		task.wait(0.1)
	end

	warnLog(
		"Timeout esperando a que Character entre en Workspace:",
		player.Name,
		fullNameSafe(character),
		"Parent:",
		fullNameSafe(character.Parent)
	)

	return false
end

local function getTemplatesFolder(): Folder?
	if GroupRoles.getTemplatesFolder then
		local ok, folder = pcall(GroupRoles.getTemplatesFolder)

		if ok and folder and typeof(folder) == "Instance" and folder:IsA("Folder") then
			return folder
		end
	end

	local groupRolesModule = NametagFolder:FindFirstChild("GroupRoles")

	if groupRolesModule and groupRolesModule:IsA("ModuleScript") then
		local folder = groupRolesModule:FindFirstChild("Templates")

		if folder and folder:IsA("Folder") then
			return folder
		end
	end

	return nil
end

local function cloneTextTemplate(templates: Folder, name: string): TextLabel?
	local inst = templates:FindFirstChild(name, true)

	if inst and inst:IsA("TextLabel") then
		return inst:Clone()
	end

	warnLog("No se encontró TextLabel template:", name, "en", fullNameSafe(templates))
	return nil
end

-- =======================
-- Datos jugables
-- =======================
local function getCountryFlagFor(player: Player): string
	local ok, regionCode = pcall(function()
		return LocalizationService:GetCountryRegionForPlayerAsync(player)
	end)

	if not ok then
		warnLog("No se pudo obtener país para:", player.Name, tostring(regionCode))
	end

	local code = (ok and regionCode) and regionCode or "US"

	return Countries[code] or "🏳️"
end

local function hasVip(player: Player): boolean
	if VIP_GAMEPASS_ID then
		local ok, owned = pcall(
			MarketplaceService.UserOwnsGamePassAsync,
			MarketplaceService,
			player.UserId,
			VIP_GAMEPASS_ID
		)

		if not ok then
			warnLog("No se pudo comprobar VIP gamepass para:", player.Name, tostring(owned))
			return false
		end

		return owned == true
	end

	return player:GetAttribute("IsVIP") == true
end

local function getLevel(player: Player): number
	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then
		return 0
	end

	local lvl = leaderstats:FindFirstChild("Level")

	if lvl and lvl:IsA("StringValue") then
		return tonumber(lvl.Value) or 0
	elseif lvl and lvl:IsA("IntValue") then
		return lvl.Value
	end

	return 0
end

-- =======================
-- Prefab
-- =======================
local function getNametagAdornee(character: Model): BasePart?
	local head = character:FindFirstChild("Head")

	if not head then
		head = character:WaitForChild("Head", CHARACTER_READY_TIMEOUT)
	end

	if head and head:IsA("BasePart") then
		return head
	end

	local fallback = character:FindFirstChildWhichIsA("BasePart", true)

	if fallback then
		warnLog("Character sin Head válido. Usando fallback:", fullNameSafe(fallback))
		return fallback
	end

	warnLog("No se encontró Head ni BasePart en character:", fullNameSafe(character))
	return nil
end

local function getOrClonePrefab(player: Player, character: Model): BillboardGui?
	local head = getNametagAdornee(character)

	if not head then
		warnLog("No se puede crear nametag porque no hay Head/BasePart:", player.Name)
		return nil
	end

	local prefab = NametagFolder:FindFirstChild("NameTag")

	if not prefab or not prefab:IsA("BillboardGui") then
		warnLog("Falta ReplicatedStorage.Shared.Nametag.NameTag o no es BillboardGui")
		return nil
	end

	local existing = head:FindFirstChild(prefab.Name)

	if existing then
		if existing:IsA("BillboardGui") then
			existing.Adornee = head
			existing.Enabled = true
			return existing
		end

		warnLog(
			"Existe un objeto llamado NameTag en Head pero no es BillboardGui:",
			existing.ClassName,
			fullNameSafe(existing)
		)

		return nil
	end

	local clone = prefab:Clone()
	clone.Enabled = true
	clone.Adornee = head
	clone.Parent = head

	return clone
end

local function findTagContainer(root: Instance): Instance
	local byName = root:FindFirstChild("Holder", true)

	if byName and byName:IsA("GuiObject") then
		return byName
	end

	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("Frame") and descendant:FindFirstChildOfClass("UIListLayout") then
			return descendant
		end
	end

	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("Frame") then
			return descendant
		end
	end

	warnLog("No se encontró Holder/Frame para tags dinámicos. Usando root:", fullNameSafe(root))
	return root
end

local function clearDynamicTags(container: Instance)
	for _, name in ipairs({ GROUP_TAG_NAME, VIP_TAG_NAME }) do
		local child = container:FindFirstChild(name)

		if child then
			child:Destroy()
		end
	end
end

-- =====================================
-- Construcción/Actualización del NameTag
-- =====================================
local function buildOrUpdateNametag(player: Player, character: Model)
	local bb = getOrClonePrefab(player, character)

	if not bb then
		return
	end

	local countryLbl = bb:FindFirstChild(COUNTRY_LABEL_NAME, true)

	if countryLbl and countryLbl:IsA("TextLabel") then
		countryLbl.Text = getCountryFlagFor(player)
	else
		warnLog("No encuentro TextLabel:", COUNTRY_LABEL_NAME, "en", fullNameSafe(bb))
	end

	local nameLbl = bb:FindFirstChild(NAME_LABEL_NAME, true)

	if nameLbl and nameLbl:IsA("TextLabel") then
		nameLbl.Text = player.DisplayName
	else
		warnLog("No encuentro TextLabel:", NAME_LABEL_NAME, "en", fullNameSafe(bb))
	end

	local levelLbl = bb:FindFirstChild(LEVEL_LABEL_NAME, true)

	if levelLbl and levelLbl:IsA("TextLabel") then
		LevelStyler.apply(levelLbl, getLevel(player))
	else
		warnLog("No encuentro TextLabel:", LEVEL_LABEL_NAME, "en", fullNameSafe(bb))
	end

	local templates = getTemplatesFolder()
	local container = findTagContainer(bb)

	if not templates then
		warnLog("Templates no disponible en GroupRoles. Group/VIP omitidos.")
		clearDynamicTags(container)
		return
	end

	clearDynamicTags(container)

	-- Group
	if GroupRoles.getTemplateNameFor then
		local ok, templateName = pcall(function()
			return GroupRoles.getTemplateNameFor(player)
		end)

		if ok and templateName then
			local groupTag = cloneTextTemplate(templates, templateName)

			if groupTag then
				groupTag.Name = GROUP_TAG_NAME
				groupTag.LayoutOrder = GROUP_LAYOUT_ORDER
				groupTag.Parent = container
			end
		elseif not ok then
			warnLog("Error en GroupRoles.getTemplateNameFor:", tostring(templateName))
		end
	end

	-- VIP
	if hasVip(player) then
		local vipTag = cloneTextTemplate(templates, "5Vip")

		if vipTag then
			vipTag.Name = VIP_TAG_NAME
			vipTag.LayoutOrder = VIP_LAYOUT_ORDER
			vipTag.Parent = container
		end
	end

	info("Creado/actualizado para", player.Name, "en PlaceId", game.PlaceId)
end

-- =========================
-- Suscripciones a cambios
-- =========================
local function connectLevelUpdates(player: Player, character: Model)
	local bb = getOrClonePrefab(player, character)

	if not bb then
		return
	end

	local connectedLevelObjects = {}

	local function updateVisual(levelValue: number)
		local levelLbl = bb:FindFirstChild(LEVEL_LABEL_NAME, true)

		if levelLbl and levelLbl:IsA("TextLabel") then
			LevelStyler.apply(levelLbl, levelValue)
		else
			warnLog("updateVisual no encuentra:", LEVEL_LABEL_NAME, "en", fullNameSafe(bb))
		end
	end

	local function connectLevelValue(lvlObj: Instance)
		if not lvlObj:IsA("ValueBase") then
			return
		end

		if connectedLevelObjects[lvlObj] then
			return
		end

		connectedLevelObjects[lvlObj] = true

		local function readLevel(): number
			if lvlObj:IsA("StringValue") then
				return tonumber(lvlObj.Value) or 0
			elseif lvlObj:IsA("IntValue") then
				return lvlObj.Value
			end

			return 0
		end

		updateVisual(readLevel())

		lvlObj:GetPropertyChangedSignal("Value"):Connect(function()
			if player.Character ~= character then
				return
			end

			updateVisual(readLevel())
		end)
	end

	local function setupLeaderstats(leaderstats: Instance)
		local lvl = leaderstats:FindFirstChild("Level")

		if lvl then
			connectLevelValue(lvl)
		end

		leaderstats.ChildAdded:Connect(function(child)
			if child.Name == "Level" then
				connectLevelValue(child)
			end
		end)
	end

	local leaderstats = player:FindFirstChild("leaderstats")

	if leaderstats then
		setupLeaderstats(leaderstats)
	end

	player.ChildAdded:Connect(function(child)
		if player.Character ~= character then
			return
		end

		if child.Name == "leaderstats" then
			setupLeaderstats(child)
		end
	end)
end

-- =========================
-- Ciclo de vida del jugador
-- =========================
local function onCharacterAdded(player: Player, character: Model)
	task.spawn(function()
		local ok, err = xpcall(function()
			if player.Character ~= character then
				return
			end

			local inWorkspace = waitUntilCharacterIsInWorkspace(player, character, CHARACTER_READY_TIMEOUT)

			if not inWorkspace then
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if not humanoid then
				local humanoidInst = character:WaitForChild("Humanoid", CHARACTER_READY_TIMEOUT)

				if humanoidInst and humanoidInst:IsA("Humanoid") then
					humanoid = humanoidInst
				end
			end

			if player.Character ~= character then
				return
			end

			if not character:IsDescendantOf(workspace) then
				return
			end

			if humanoid then
				humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			else
				warnLog("No se encontró Humanoid para:", player.Name, fullNameSafe(character))
			end

			buildOrUpdateNametag(player, character)
			connectLevelUpdates(player, character)
		end, debug.traceback)

		if not ok then
			warnLog("ERROR en onCharacterAdded para", player.Name, err)
		end
	end)
end

local function OnPlayerAdded(player: Player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)

	if player.Character then
		onCharacterAdded(player, player.Character)
	end
end

PlayerInit.Connect(OnPlayerAdded)