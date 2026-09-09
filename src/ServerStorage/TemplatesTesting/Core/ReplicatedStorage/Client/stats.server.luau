local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local showNotificationBindableEvent = eventsFolder.Player:WaitForChild("ShowNotificationBindable")

local player = Players.LocalPlayer

local StatsConfig = require(ReplicatedStorage.Client.notificationsManager:WaitForChild("statsNotifications"))

if not player.Character or not player.Character.Parent then
	player.CharacterAdded:Wait()
end

local gui = player.PlayerGui:WaitForChild("StatsUI")

local COLOR_RED = Color3.fromRGB(170, 0, 0)
local COLOR_BLUE = Color3.fromRGB(85, 170, 255)
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Sine)

local function updateStatGui(statHolder, statValue)
	local rotation = math.clamp(statValue * 3.6, 0, 360)
	local rightRot = math.clamp(rotation, 0, 180)
	local leftRot  = math.clamp(rotation, 180, 360)

	local rightGrad = statHolder.Right.Frame.UIGradient
	local leftGrad  = statHolder.Left.Frame.UIGradient

	TweenService:Create(rightGrad, TWEEN_INFO, { Rotation = rightRot }):Play()
	TweenService:Create(leftGrad,  TWEEN_INFO, { Rotation = leftRot  }):Play()
end

local function bindToStat(frame: Frame)
	local stat = frame:GetAttribute("Stat") or "unknown"
	local holder = frame:FindFirstChild("Holder")
	local text = frame:FindFirstChild("StatName")

	local function onChange()
		local value = player:GetAttribute(stat)

		if value <= 0 then
			local config = StatsConfig[stat]
			if config then
				showNotificationBindableEvent:Fire("Salud", config.message, 6, config.imageId, 'explosion', config.soundId)
			else
				error("stat no encontrada en la tabla statsConfig!")
			end		
		end

		local colorA = COLOR_RED
		local colorB = COLOR_BLUE
		local t = math.clamp(player:GetAttribute(stat) or 0, 0, 1)
		local targetColor = COLOR_RED:Lerp(COLOR_BLUE, t)

		updateStatGui(holder, value)
		TweenService:Create(text, TWEEN_INFO, { TextColor3 = targetColor }):Play()
	end
	-- Esperar a que se cargue la stat
	repeat task.wait() until player:GetAttribute(stat) ~= nil
	onChange()
	player:GetAttributeChangedSignal(stat):Connect(onChange)
end

for _, frame in gui.Frame.Frame.Stats:GetChildren() do
	if frame:IsA("Frame") then
		bindToStat(frame)
	end
end