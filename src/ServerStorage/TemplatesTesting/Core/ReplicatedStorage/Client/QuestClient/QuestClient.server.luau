local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local QuestConfig = require(ReplicatedStorage.Shared.Quests:WaitForChild("QuestConfig"))
local QuestShared = require(ReplicatedStorage.Shared.Quests:WaitForChild("QuestShared"))

local questEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Quests")
local GetQuestState = questEvents:WaitForChild("GetQuestState")
local ClaimQuest = questEvents:WaitForChild("ClaimQuest")
local QuestUpdated = questEvents:WaitForChild("QuestUpdated")

local QuestTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Quests")
	:WaitForChild("UI")
	:WaitForChild("QuestTemplate")

local currentState = nil

local function findDescendantByName(parent: Instance, name: string): Instance?
	for _, descendant in ipairs(parent:GetDescendants()) do
		if descendant.Name == name then
			return descendant
		end
	end

	return nil
end

local function getQuestFrame()
	local worldSystemUI = playerGui:WaitForChild("WorldSystemUI")
	return findDescendantByName(worldSystemUI, "QuestFrame")
end

local QuestFrame = getQuestFrame()

if not QuestFrame then
	warn("[QuestClient] No se encontró QuestFrame dentro de WorldSystemUI")
	return
end

local DailyFrame = QuestFrame:WaitForChild("Daily")
local WeeklyFrame = QuestFrame:WaitForChild("Weekly")

local DailyQuestList = DailyFrame:WaitForChild("QuestList")
local WeeklyQuestList = WeeklyFrame:WaitForChild("QuestList")

local DailyTimeText = DailyFrame:WaitForChild("Time"):WaitForChild("Text")
local WeeklyTimeText = WeeklyFrame:WaitForChild("Time"):WaitForChild("Text")

local function clearQuestList(listFrame: Instance)
	for _, child in ipairs(listFrame:GetChildren()) do
		if child:GetAttribute("QuestClone") then
			child:Destroy()
		end
	end
end

local function setText(object: Instance?, text: string)
	if object and object:IsA("TextLabel") or object and object:IsA("TextButton") then
		object.Text = text
	end
end

local function setClaimText(claimButton: Instance, text: string)
	local textLabel = claimButton:FindFirstChild("TextLabel")

	if textLabel and textLabel:IsA("TextLabel") then
		textLabel.Text = text
	elseif claimButton:IsA("TextButton") then
		claimButton.Text = text
	end
end

local function getCurrencyColor(currencyName: string): Color3
	if currencyName == "Gems" then
		return QuestConfig.Colors.GemsText
	end

	return QuestConfig.Colors.CoinsText
end

local function paintQuest(frame: Frame, activeQuest, questConfig, groupName: string, slot: number)
	local objective = questConfig.Objective
	local reward = questConfig.Reward

	local completed = QuestShared.IsCompleted(activeQuest, questConfig)
	local claimed = activeQuest.Claimed == true

	local ratio = QuestShared.GetRatio(activeQuest.Progress, objective.RequiredAmount)

	local description = frame:FindFirstChild("Text")
	local progress = frame:FindFirstChild("Progress")
	local xpReward = frame:FindFirstChild("XPReward")
	local currencyReward = frame:FindFirstChild("CurrencyReward")
	local imageReward = frame:FindFirstChild("ImageReward")
	local claimButton = frame:FindFirstChild("Claim")

	local barContainer = frame:FindFirstChild("Bar")
	local bar = barContainer and barContainer:FindFirstChild("Bar")

	setText(description, questConfig.Text)
	setText(progress, QuestShared.GetProgressText(activeQuest, questConfig))
	setText(xpReward, tostring(reward.Xp or 0) .. "XP")
	setText(currencyReward, tostring(reward.Amount or 0))

	if currencyReward and currencyReward:IsA("TextLabel") then
		currencyReward.TextColor3 = getCurrencyColor(reward.Currency)
	end

	if imageReward and imageReward:IsA("ImageLabel") then
		imageReward.Image = QuestConfig.Images[reward.Currency] or ""
	end

	if bar and bar:IsA("Frame") then
		bar.Size = UDim2.new(ratio, 0, 1, 0)

		if claimed then
			bar.BackgroundColor3 = QuestConfig.Colors.DarkBlue
		elseif completed then
			bar.BackgroundColor3 = QuestConfig.Colors.Yellow
		else
			bar.BackgroundColor3 = QuestConfig.Colors.Blue
		end
	end

	if claimButton and claimButton:IsA("TextButton") then
		claimButton.AutoButtonColor = completed and not claimed
		claimButton.Active = completed and not claimed

		if claimed then
			setClaimText(claimButton, "Reclamado")
			claimButton.BackgroundColor3 = QuestConfig.Colors.DarkBlue
		elseif completed then
			setClaimText(claimButton, "Reclamar")
			claimButton.BackgroundColor3 = QuestConfig.Colors.Yellow
		else
			setClaimText(claimButton, "Reclamar")
			claimButton.BackgroundColor3 = QuestConfig.Colors.Blue
		end

		claimButton.MouseButton1Click:Connect(function()
			if completed and not claimed then
				ClaimQuest:FireServer(groupName, slot)
			end
		end)
	end
end

local function renderGroup(groupName: string, listFrame: Instance, quests)
	clearQuestList(listFrame)

	for slot, activeQuest in ipairs(quests or {}) do
		local questConfig = QuestConfig.GetQuestById(activeQuest.QuestId)

		if not questConfig then
			warn("[QuestClient] Quest no encontrada en config:", activeQuest.QuestId)
			continue
		end

		local clone = QuestTemplate:Clone()
		clone.Name = groupName .. "_Quest_" .. tostring(slot)
		clone:SetAttribute("QuestClone", true)
		clone.Visible = true
		clone.Parent = listFrame

		paintQuest(clone, activeQuest, questConfig, groupName, slot)
	end
end

local function formatRemainingFromResetAt(resetAt: number): string
	local remaining = math.max(0, math.floor(resetAt - workspace:GetServerTimeNow()))
	return QuestShared.FormatTime(remaining)
end

local function render(state)
	currentState = state

	renderGroup("Daily", DailyQuestList, state.Daily)
	renderGroup("Weekly", WeeklyQuestList, state.Weekly)

	DailyTimeText.Text = formatRemainingFromResetAt(state.DailyResetAt)
	WeeklyTimeText.Text = formatRemainingFromResetAt(state.WeeklyResetAt)
end

QuestUpdated.OnClientEvent:Connect(function(state)
	render(state)
end)

task.spawn(function()
	local state = GetQuestState:InvokeServer()
	render(state)
end)

task.spawn(function()
	while true do
		task.wait(1)

		if currentState then
			DailyTimeText.Text = formatRemainingFromResetAt(currentState.DailyResetAt)
			WeeklyTimeText.Text = formatRemainingFromResetAt(currentState.WeeklyResetAt)
		end
	end
end)