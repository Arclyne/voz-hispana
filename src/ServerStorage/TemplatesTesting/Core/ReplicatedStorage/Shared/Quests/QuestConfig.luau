local QuestConfig = {}

QuestConfig.Settings = {
	DailyCount = 3,
	WeeklyCount = 9,

	-- Valores de test
	DailySeconds = 60,
	WeeklySeconds = 300,

	DailyCooldownKey = "Quests_Daily_Reset",
	WeeklyCooldownKey = "Quests_Weekly_Reset",
}

QuestConfig.Colors = {
	Blue = Color3.fromRGB(0, 170, 255),
	DarkBlue = Color3.fromRGB(0, 88, 129),
	Yellow = Color3.fromRGB(255, 165, 62),

	CoinsText = Color3.fromRGB(236, 145, 0),
	GemsText = Color3.fromRGB(15, 185, 197),
}

QuestConfig.Images = {
	Coins = "rbxassetid://107645265535864",
	Gems = "rbxassetid://101938447947919",
}

QuestConfig.PlaceIds = {
	karaoke = 129043234524029,
	lobby = 94068794823958,
	plsDonate = 82871403803520,
	arcadeClub = 83856919904540,
}

QuestConfig.Quests = {
	{
		Id = "time_karaoke_10m",
		Pools = { "Daily", "Weekly" },

		Text = "Pasa un total de 10 minutos en el karaoke.",
		ProgressDisplay = "Time",

		Objective = {
			Type = "TimeInPlace",
			PlaceId = QuestConfig.PlaceIds.karaoke,
			RequiredAmount = 600,
		},

		Reward = {
			Xp = 20,
			Currency = "Coins",
			Amount = 25,
		},
	},

	{
		Id = "time_lobby_10m",
		Pools = { "Daily", "Weekly" },

		Text = "Pasa un total de 10 minutos en el lobby.",
		ProgressDisplay = "Time",

		Objective = {
			Type = "TimeInPlace",
			PlaceId = QuestConfig.PlaceIds.lobby,
			RequiredAmount = 600,
		},

		Reward = {
			Xp = 20,
			Currency = "Coins",
			Amount = 25,
		},
	},

	{
		Id = "time_pls_donate_10m",
		Pools = { "Daily", "Weekly" },

		Text = "Pasa un total de 10 minutos en el PLS Donate.",
		ProgressDisplay = "Time",

		Objective = {
			Type = "TimeInPlace",
			PlaceId = QuestConfig.PlaceIds.plsDonate,
			RequiredAmount = 600,
		},

		Reward = {
			Xp = 20,
			Currency = "Coins",
			Amount = 25,
		},
	},

	{
		Id = "time_arcade_club_10m",
		Pools = { "Daily", "Weekly" },

		Text = "Pasa un total de 10 minutos en el Arcade Club.",
		ProgressDisplay = "Time",

		Objective = {
			Type = "TimeInPlace",
			PlaceId = QuestConfig.PlaceIds.arcadeClub,
			RequiredAmount = 600,
		},

		Reward = {
			Xp = 20,
			Currency = "Coins",
			Amount = 25,
		},
	},

	-- Misiones de test antiguas. Puedes borrarlas cuando ya no las necesites.
	{
		Id = "time_current_place_30s",
		Pools = { "Daily", "Weekly" },

		Text = "Pasa un total de 30 segundos en este lugar.",
		ProgressDisplay = "Time",

		Objective = {
			Type = "TimeInPlace",
			PlaceId = game.PlaceId,
			RequiredAmount = 30,
		},

		Reward = {
			Xp = 20,
			Currency = "Coins",
			Amount = 25,
		},
	},

	{
		Id = "time_current_place_60s",
		Pools = { "Daily", "Weekly" },

		Text = "Pasa un total de 1 minuto en este lugar.",
		ProgressDisplay = "Time",

		Objective = {
			Type = "TimeInPlace",
			PlaceId = game.PlaceId,
			RequiredAmount = 60,
		},

		Reward = {
			Xp = 30,
			Currency = "Coins",
			Amount = 50,
		},
	},

	{
		Id = "time_current_place_90s",
		Pools = { "Weekly" },

		Text = "Pasa un total de 1 minuto y 30 segundos en este lugar.",
		ProgressDisplay = "Time",

		Objective = {
			Type = "TimeInPlace",
			PlaceId = game.PlaceId,
			RequiredAmount = 90,
		},

		Reward = {
			Xp = 50,
			Currency = "Gems",
			Amount = 5,
		},
	},

	{
		Id = "collect_test_object_3",
		Pools = { "Daily", "Weekly" },

		Text = "Recoge 3 objetos especiales.",
		ProgressDisplay = "Amount",

		Objective = {
			Type = "CollectObject",
			PlaceId = QuestConfig.PlaceIds.lobby,
			ObjectName = "TestObject",
			RequiredAmount = 3,
			MaxSpawned = 3,
		},

		Reward = {
			Xp = 20,
			Currency = "Coins",
			Amount = 25,
		},
	},
}

function QuestConfig.GetQuestById(id: string)
	for _, quest in ipairs(QuestConfig.Quests) do
		if quest.Id == id then
			return quest
		end
	end

	return nil
end

function QuestConfig.IsQuestInPool(quest, poolName: string): boolean
	for _, pool in ipairs(quest.Pools) do
		if pool == poolName then
			return true
		end
	end

	return false
end

return QuestConfig