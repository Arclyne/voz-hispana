local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local QuestConfig = require(ReplicatedStorage.Shared.Quests:WaitForChild("QuestConfig"))
local QuestShared = require(ReplicatedStorage.Shared.Quests:WaitForChild("QuestShared"))

local Collections = require(ReplicatedStorage.Client.EconomySystem:WaitForChild("Collections"))

local CooldownManager = require(ReplicatedStorage.Shared.Cooldown:WaitForChild("CooldownManager"))

local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local questEvents = eventsFolder:WaitForChild("Quests")

local QuestUpdated = questEvents:WaitForChild("QuestUpdated")

local QuestService = {}

local DEFAULT_DATA = {
	Daily = {},
	Weekly = {},
}

local function deepCopy(data)
	local result = {}

	for key, value in pairs(data) do
		if typeof(value) == "table" then
			result[key] = deepCopy(value)
		else
			result[key] = value
		end
	end

	return result
end

local function getQuestDataValue(player: Player): StringValue
	local value = player:FindFirstChild("QuestData")

	if not value then
		value = Instance.new("StringValue")
		value.Name = "QuestData"
		value.Value = ""
		value.Parent = player
	end

	return value
end

local function decodeData(player: Player)
	local value = getQuestDataValue(player)

	if value.Value == "" then
		return deepCopy(DEFAULT_DATA)
	end

	local success, data = pcall(function()
		return HttpService:JSONDecode(value.Value)
	end)

	if not success or typeof(data) ~= "table" then
		warn("[QuestService] QuestData corrupto para", player.Name)
		return deepCopy(DEFAULT_DATA)
	end

	data.Daily = data.Daily or {}
	data.Weekly = data.Weekly or {}

	return data
end

local function saveData(player: Player, data)
	local value = getQuestDataValue(player)

	local success, encoded = pcall(function()
		return HttpService:JSONEncode(data)
	end)

	if success then
		value.Value = encoded
	else
		warn("[QuestService] No se pudo guardar QuestData para", player.Name, encoded)
	end
end

local function getGroupSettings(groupName: string)
	if groupName == "Daily" then
		return QuestConfig.Settings.DailyCount, QuestConfig.Settings.DailyCooldownKey, QuestConfig.Settings.DailySeconds
	end

	return QuestConfig.Settings.WeeklyCount, QuestConfig.Settings.WeeklyCooldownKey, QuestConfig.Settings.WeeklySeconds
end

local function isActiveAndIncomplete(activeQuest)
	if not activeQuest then
		return false
	end

	if activeQuest.Claimed then
		return false
	end

	local config = QuestConfig.GetQuestById(activeQuest.QuestId)
	if not config then
		return false
	end

	return activeQuest.Progress < config.Objective.RequiredAmount
end

local function getBlockedQuestIds(data, groupName: string)
	local blocked = {}

	for otherGroupName, questList in pairs(data) do
		if otherGroupName == "Daily" or otherGroupName == "Weekly" then
			for _, activeQuest in ipairs(questList) do
				if isActiveAndIncomplete(activeQuest) then
					blocked[activeQuest.QuestId] = true
				end
			end
		end
	end

	return blocked
end

local function buildCandidateList(data, groupName: string)
	local blocked = getBlockedQuestIds(data, groupName)
	local candidates = {}

	for _, quest in ipairs(QuestConfig.Quests) do
		if QuestConfig.IsQuestInPool(quest, groupName) and not blocked[quest.Id] then
			table.insert(candidates, quest)
		end
	end

	return candidates
end

local function shuffle(list)
	for i = #list, 2, -1 do
		local j = math.random(1, i)
		list[i], list[j] = list[j], list[i]
	end
end

local function rollGroup(data, groupName: string)
	local count = groupName == "Daily" and QuestConfig.Settings.DailyCount or QuestConfig.Settings.WeeklyCount
	local candidates = buildCandidateList(data, groupName)

	shuffle(candidates)

	local result = {}

	for i = 1, math.min(count, #candidates) do
		table.insert(result, {
			QuestId = candidates[i].Id,
			Progress = 0,
			Claimed = false,
		})
	end

	data[groupName] = result
end

function QuestService:GetData(player: Player)
	return decodeData(player)
end

function QuestService:SaveData(player: Player, data)
	saveData(player, data)
end

function QuestService:InitializePlayer(player: Player)
	getQuestDataValue(player)

	local data = decodeData(player)

	for _, groupName in ipairs({ "Daily", "Weekly" }) do
		local _, cooldownKey, cooldownSeconds = getGroupSettings(groupName)
		local onCooldown = CooldownManager.IsOnCooldown(player, cooldownKey)
		local hasQuests = data[groupName] and #data[groupName] > 0

		if not onCooldown or not hasQuests then
			rollGroup(data, groupName)
			CooldownManager.Start(player, cooldownKey, cooldownSeconds)
		end
	end

	saveData(player, data)
	self:SendFullUpdate(player)
end

function QuestService:GetStateForClient(player: Player)
	local data = decodeData(player)

	local dailyRemaining = CooldownManager.GetRemaining(player, QuestConfig.Settings.DailyCooldownKey)
	local weeklyRemaining = CooldownManager.GetRemaining(player, QuestConfig.Settings.WeeklyCooldownKey)

	return {
		Daily = data.Daily,
		Weekly = data.Weekly,

		DailyResetAt = workspace:GetServerTimeNow() + dailyRemaining,
		WeeklyResetAt = workspace:GetServerTimeNow() + weeklyRemaining,
	}
end

function QuestService:SendFullUpdate(player: Player)
	QuestUpdated:FireClient(player, self:GetStateForClient(player))
end

function QuestService:ClaimQuest(player: Player, groupName: string, slot: number)
	if groupName ~= "Daily" and groupName ~= "Weekly" then
		return
	end

	if typeof(slot) ~= "number" then
		return
	end

	local data = decodeData(player)
	local group = data[groupName]

	if typeof(group) ~= "table" then
		return
	end

	local activeQuest = group[slot]
	if not activeQuest then
		return
	end

	if activeQuest.Claimed then
		return
	end

	local questConfig = QuestConfig.GetQuestById(activeQuest.QuestId)
	if not questConfig then
		return
	end

	if activeQuest.Progress < questConfig.Objective.RequiredAmount then
		return
	end

	local reward = questConfig.Reward

	if reward.Xp and reward.Xp > 0 then
		Collections.Give(player, { Xp = reward.Xp }, true)
	end

	if reward.Currency and reward.Amount and reward.Amount > 0 then
		Collections.Give(player, { [reward.Currency] = reward.Amount }, true)
	end

	activeQuest.Claimed = true

	saveData(player, data)
	self:SendFullUpdate(player)
end

function QuestService:AddProgress(player: Player, objectiveType: string, matchData, amount: number)
	amount = math.floor(amount or 1)
	if amount <= 0 then
		return
	end

	local data = decodeData(player)
	local changed = false

	for _, groupName in ipairs({ "Daily", "Weekly" }) do
		local group = data[groupName]

		if typeof(group) ~= "table" then
			continue
		end

		for _, activeQuest in ipairs(group) do
			if activeQuest.Claimed then
				continue
			end

			local questConfig = QuestConfig.GetQuestById(activeQuest.QuestId)
			if not questConfig then
				continue
			end

			local objective = questConfig.Objective
			if objective.Type ~= objectiveType then
				continue
			end

			if objective.Type == "TimeInPlace" then
				if objective.PlaceId ~= matchData.PlaceId then
					continue
				end
			elseif objective.Type == "CollectObject" then
				if objective.PlaceId ~= matchData.PlaceId then
					continue
				end

				if objective.ObjectName ~= matchData.ObjectName then
					continue
				end
			end

			local oldProgress = activeQuest.Progress or 0
			local newProgress = QuestShared.ClampProgress(oldProgress + amount, objective.RequiredAmount)

			if newProgress ~= oldProgress then
				activeQuest.Progress = newProgress
				changed = true
			end
		end
	end

	if changed then
		saveData(player, data)
		self:SendFullUpdate(player)
	end
end

function QuestService:CheckResets(player: Player)
	local data = decodeData(player)
	local changed = false

	for _, groupName in ipairs({ "Daily", "Weekly" }) do
		local _, cooldownKey, cooldownSeconds = getGroupSettings(groupName)
		local onCooldown = CooldownManager.IsOnCooldown(player, cooldownKey)

		if not onCooldown then
			rollGroup(data, groupName)
			CooldownManager.Start(player, cooldownKey, cooldownSeconds)
			changed = true
		end
	end

	if changed then
		saveData(player, data)
		self:SendFullUpdate(player)
	end
end

return QuestService