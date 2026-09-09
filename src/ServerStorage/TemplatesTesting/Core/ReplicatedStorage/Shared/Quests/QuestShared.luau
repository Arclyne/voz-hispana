local QuestShared = {}

function QuestShared.ClampProgress(progress: number, required: number): number
	return math.clamp(math.floor(progress), 0, math.floor(required))
end

function QuestShared.GetRatio(progress: number, required: number): number
	if required <= 0 then
		return 1
	end

	return math.clamp(progress / required, 0, 1)
end

function QuestShared.IsCompleted(activeQuest, questConfig): boolean
	return activeQuest.Progress >= questConfig.Objective.RequiredAmount
end

function QuestShared.FormatTime(seconds: number): string
	seconds = math.max(0, math.floor(seconds))

	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60

	if minutes > 0 then
		return string.format("%02d:%02d", minutes, secs)
	end

	return string.format("00:%02d", secs)
end

function QuestShared.GetProgressText(activeQuest, questConfig): string
	local progress = activeQuest.Progress
	local required = questConfig.Objective.RequiredAmount
	local display = questConfig.ProgressDisplay or "Amount"

	if display == "Percent" then
		local percent = math.floor(QuestShared.GetRatio(progress, required) * 100)
		return tostring(percent) .. "%"
	end

	if display == "Time" then
		return QuestShared.FormatTime(progress) .. "/" .. QuestShared.FormatTime(required)
	end

	return tostring(progress) .. "/" .. tostring(required)
end

return QuestShared