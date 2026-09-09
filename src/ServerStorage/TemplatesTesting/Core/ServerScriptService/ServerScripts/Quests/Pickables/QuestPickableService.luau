local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestConfig = require(ReplicatedStorage.Shared.Quests:WaitForChild("QuestConfig"))
local QuestService = require(script.Parent.Parent:WaitForChild("QuestService"))

local questEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Quests")
local QuestPickablesUpdated = questEvents:WaitForChild("QuestPickablesUpdated")

local pickableTemplates = ReplicatedStorage
	:WaitForChild("Assets")
	:WaitForChild("Quests")
	:WaitForChild("PickableObjects")

local QuestPickableService = {}

local rng = Random.new()
local activePickablesByPlayer = {}

local function getPlayerStore(player: Player)
	activePickablesByPlayer[player] = activePickablesByPlayer[player] or {}
	return activePickablesByPlayer[player]
end

local function getSpawnFolder(): Folder?
	return workspace:FindFirstChild("QuestObjectSpawns")
end

local function getSpawnParts(): { BasePart }
	local folder = getSpawnFolder()

	if not folder then
		warn("[QuestPickableService] No existe Workspace.QuestObjectSpawns")
		return {}
	end

	local spawns = {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(spawns, descendant)
		end
	end

	if #spawns <= 0 then
		warn("[QuestPickableService] QuestObjectSpawns no tiene ningún BasePart.")
	end

	return spawns
end

local function getTemplateYOffset(objectName: string): number
	local template = pickableTemplates:FindFirstChild(objectName)

	if not template then
		warn("[QuestPickableService] No existe el template:", objectName)
		return 1
	end

	if template:IsA("Model") then
		return template:GetExtentsSize().Y / 2
	end

	if template:IsA("BasePart") then
		return template.Size.Y / 2
	end

	return 1
end

local function getUsedSpawnParts(store)
	local used = {}

	for _, info in pairs(store) do
		if info.SpawnPart and info.SpawnPart.Parent then
			used[info.SpawnPart] = true
		end
	end

	return used
end

local function getAvailableSpawnParts(store): { BasePart }
	local allSpawns = getSpawnParts()
	local used = getUsedSpawnParts(store)
	local available = {}

	for _, spawnPart in ipairs(allSpawns) do
		if not used[spawnPart] then
			table.insert(available, spawnPart)
		end
	end

	return available
end

local function getGroundedPosition(objectName: string, store): (Vector3?, BasePart?)
	local availableSpawns = getAvailableSpawnParts(store)

	if #availableSpawns <= 0 then
		return nil, nil
	end

	local spawnPart = availableSpawns[rng:NextInteger(1, #availableSpawns)]
	local spawnFolder = getSpawnFolder()

	local exclude = {}

	if spawnFolder then
		table.insert(exclude, spawnFolder)
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			table.insert(exclude, player.Character)
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = exclude

	local origin = spawnPart.Position + Vector3.new(0, 80, 0)
	local direction = Vector3.new(0, -250, 0)

	local result = workspace:Raycast(origin, direction, raycastParams)
	local groundPosition = result and result.Position or spawnPart.Position
	local yOffset = getTemplateYOffset(objectName)

	return groundPosition + Vector3.new(0, yOffset, 0), spawnPart
end

local function getActiveCollectObjectives(player: Player)
	local data = QuestService:GetData(player)
	local objectives = {}

	for _, groupName in ipairs({ "Daily", "Weekly" }) do
		local group = data[groupName]

		if typeof(group) ~= "table" then
			continue
		end

		for slot, activeQuest in ipairs(group) do
			if activeQuest.Claimed then
				continue
			end

			local questConfig = QuestConfig.GetQuestById(activeQuest.QuestId)

			if not questConfig then
				continue
			end

			local objective = questConfig.Objective

			if not objective or objective.Type ~= "CollectObject" then
				continue
			end

			if objective.PlaceId ~= game.PlaceId then
				continue
			end

			local progress = activeQuest.Progress or 0
			local required = objective.RequiredAmount or 1

			if progress >= required then
				continue
			end

			local questKey = groupName .. "_" .. tostring(slot)

			objectives[questKey] = {
				QuestKey = questKey,
				QuestId = activeQuest.QuestId,
				ObjectName = objective.ObjectName,
				Remaining = required - progress,
				MaxSpawned = objective.MaxSpawned or 3,
			}
		end
	end

	return objectives
end

local function serializePickables(store)
	local list = {}

	for _, info in pairs(store) do
		table.insert(list, {
			Id = info.Id,
			ObjectName = info.ObjectName,
			Position = info.Position,
		})
	end

	return list
end

function QuestPickableService:SyncPlayer(player: Player)
	local store = getPlayerStore(player)
	local objectives = getActiveCollectObjectives(player)

	-- Borra objetos que ya no pertenecen a una quest activa.
	for id, info in pairs(store) do
		local objective = objectives[info.QuestKey]

		if not objective or objective.ObjectName ~= info.ObjectName or objective.QuestId ~= info.QuestId then
			store[id] = nil
		end
	end

	local countsByQuestKey = {}

	for _, info in pairs(store) do
		countsByQuestKey[info.QuestKey] = (countsByQuestKey[info.QuestKey] or 0) + 1
	end

	for questKey, objective in pairs(objectives) do
		local currentCount = countsByQuestKey[questKey] or 0
		local targetCount = math.min(objective.Remaining, objective.MaxSpawned)

		while currentCount < targetCount do
			local position, spawnPart = getGroundedPosition(objective.ObjectName, store)

			if not position or not spawnPart then
				break
			end

			local id = HttpService:GenerateGUID(false)

			store[id] = {
				Id = id,
				QuestKey = objective.QuestKey,
				QuestId = objective.QuestId,
				ObjectName = objective.ObjectName,
				Position = position,
				SpawnPart = spawnPart,
			}

			currentCount += 1
		end
	end
end

function QuestPickableService:GetPickablesForPlayer(player: Player)
	self:SyncPlayer(player)

	local store = getPlayerStore(player)
	return serializePickables(store)
end

function QuestPickableService:SendUpdate(player: Player)
	if not player or not player.Parent then
		return
	end

	QuestPickablesUpdated:FireClient(player, self:GetPickablesForPlayer(player))
end

function QuestPickableService:Collect(player: Player, collectibleId: string)
	if typeof(collectibleId) ~= "string" then
		return
	end

	local store = getPlayerStore(player)
	local info = store[collectibleId]

	if not info then
		return
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	if (root.Position - info.Position).Magnitude > 30 then
		return
	end

	local objectives = getActiveCollectObjectives(player)
	local objective = objectives[info.QuestKey]

	if not objective then
		store[collectibleId] = nil
		self:SendUpdate(player)
		return
	end

	if objective.ObjectName ~= info.ObjectName or objective.QuestId ~= info.QuestId then
		store[collectibleId] = nil
		self:SendUpdate(player)
		return
	end

	store[collectibleId] = nil

	QuestService:AddProgress(player, "CollectObject", {
		PlaceId = game.PlaceId,
		ObjectName = info.ObjectName,
	}, 1)

	self:SyncPlayer(player)
	self:SendUpdate(player)
end

Players.PlayerRemoving:Connect(function(player)
	activePickablesByPlayer[player] = nil
end)

return QuestPickableService