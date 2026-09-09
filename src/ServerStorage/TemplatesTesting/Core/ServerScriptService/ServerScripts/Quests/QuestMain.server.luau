local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestService = require(script.Parent:WaitForChild("QuestService"))
local QuestPickableService = require(script.Parent:WaitForChild("Pickables"):WaitForChild("QuestPickableService"))

local questEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Quests")

local GetQuestState = questEvents:WaitForChild("GetQuestState")
local ClaimQuest = questEvents:WaitForChild("ClaimQuest")

local GetQuestPickables = questEvents:WaitForChild("GetQuestPickables")
local CollectQuestPickable = questEvents:WaitForChild("CollectQuestPickable")

local TIME_PROGRESS_INTERVAL = 1

GetQuestState.OnServerInvoke = function(player)
	return QuestService:GetStateForClient(player)
end

ClaimQuest.OnServerEvent:Connect(function(player, groupName, slot)
	QuestService:ClaimQuest(player, groupName, slot)
	QuestPickableService:SendUpdate(player)
end)

GetQuestPickables.OnServerInvoke = function(player)
	return QuestPickableService:GetPickablesForPlayer(player)
end

CollectQuestPickable.OnServerEvent:Connect(function(player, collectibleId)
	QuestPickableService:Collect(player, collectibleId)
end)

local function waitForData(player: Player)
	if player:GetAttribute("DataLoaded") then
		return true
	end

	while player.Parent and not player:GetAttribute("DataLoaded") do
		player:GetAttributeChangedSignal("DataLoaded"):Wait()
	end

	return player.Parent ~= nil
end

local function setupPlayer(player: Player)
	if not waitForData(player) then
		return
	end

	QuestService:InitializePlayer(player)
	QuestPickableService:SendUpdate(player)

	while player.Parent do
		task.wait(TIME_PROGRESS_INTERVAL)

		local didReset = QuestService:CheckResets(player)

		if didReset then
			QuestPickableService:SendUpdate(player)
		end

		QuestService:AddProgress(player, "TimeInPlace", {
			PlaceId = game.PlaceId,
		}, TIME_PROGRESS_INTERVAL)
	end
end

Players.PlayerAdded:Connect(function(player)
	task.spawn(setupPlayer, player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(setupPlayer, player)
end