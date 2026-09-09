--[[
    Notification Manager
    ---------------
    Se pueden mandar notificaciones desde el server y desde el cliente.
    El sistema actualiza automáticamente la posición de todas las notificaciones activas,
    de modo que, al añadir o eliminar una notificación, se recalcule su ubicación.
    Muestra máximo 4 notificaciones, las antiguas se van borrando.
	Efectos para las imagenes: "rotate", "explosion"
    -------------------------------------------------
    Ejemplo de uso en un Script de servidor:
    -------------------------------------------------
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local eventsFolder = ReplicatedStorage:WaitForChild("Events")
    local showNotificationEvent = eventsFolder.Player:WaitForChild("ShowNotification")
    showNotificationEvent:FireAllClients("Titulo", "Has recibido 100 monedas", 6, 86164423709638, "rotate", 12345678)
    showNotificationEvent:FireClient(player, "Titulo", "Bienvenido de nuevo!", 6, 101262602775246, 'rotate')
    -------------------------------------------------
    Ejemplo de uso en un Local Script:
    -------------------------------------------------
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local eventsFolder = ReplicatedStorage:WaitForChild("Events")
	local showNotificationBindableEvent = eventsFolder.Player:WaitForChild("ShowNotificationBindable")
	showNotificationBindableEvent:Fire("Titulo", "Hambre en estado crítico", 6, 135696630804576, 'explosion', 133962474176377)
    -------------------------------------------------
    
    Cualquier duda, preguntar a Alvelex
--]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

if not player.Character or not player.Character.Parent then
	player.CharacterAdded:Wait()
end

local TextScaler = require(ReplicatedStorage.Shared:WaitForChild("textScaler"))
local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))
local GuiScaleManager = require(ReplicatedStorage.Shared:WaitForChild("GuiScaleManager"))

local SignalGame = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SignalsGame"))

local notificationsScreen  = player:WaitForChild("PlayerGui"):WaitForChild("NotificationsUI")
local notificationsFrame  = notificationsScreen.Container:WaitForChild("NotificationsFrame")
local template = notificationsFrame:WaitForChild("NotificationTemplate")
template.Visible = false

local activeNotifications = {}

local NOTIFICATION_SCALE_CONFIG = {
	pcScale = 1,
	tabletScale = 1.1,
	mobileScale = 1.2,
}

local BASE_NOTIFICATION_SPACING = 0.25

local function getNotificationVisualScale(notification)
	local uiScale = notification:FindFirstChildOfClass("UIScale")
	if uiScale then
		return uiScale.Scale
	end

	return 1
end

-- Actualiza posiciones de todas las notificaciones cuando se añaden o se borran
local function updateNotificationPositions(duration)
	local baseY = 1.058     -- Posición Y para la notificación más nueva

	for i, notif in ipairs(activeNotifications) do
		local visualScale = getNotificationVisualScale(notif)
		local spacing = BASE_NOTIFICATION_SPACING * visualScale    -- Espacio entre notificaciones según escala

		local targetY = baseY - spacing * (#activeNotifications - i)
		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local targetPos = UDim2.new(notif.Position.X.Scale, notif.Position.X.Offset, targetY, notif.Position.Y.Offset)
		local moveTween = TweenService:Create(notif, tweenInfo, {Position = targetPos})
		moveTween:Play()
	end
end

local function showNotification(title, message, fadeTime, imageId, effect, soundId)
	SoundManager:Play(player, 122948856683895, { Volume = 0.1 })
	fadeTime = fadeTime or 3
	local notificationClone = template:Clone()
	notificationClone.Name = "Notification"
	notificationClone.Visible = true
	notificationClone.Parent = notificationsFrame
	notificationClone.Position = UDim2.new(0.942, 0, 1.058, 0)
	notificationClone.ZIndex = 2

	GuiScaleManager.Register(notificationClone, NOTIFICATION_SCALE_CONFIG)

	if soundId then
		SoundManager:Play(player, soundId, { Volume = 0.1 })
	end

	local titleLabel = notificationClone:WaitForChild("Tittle")
	local messageLabel = notificationClone:WaitForChild("Message")
	local closeButton = notificationClone:WaitForChild("Close")

	if titleLabel then
		titleLabel.Text = title or ""
		titleLabel.TextSize = TextScaler.getScaledFontSize(titleLabel.Text, titleLabel.TextSize)
	end

	if messageLabel then
		messageLabel.Text = message or ""
		if imageId then
			local imageLabel = notificationClone:WaitForChild("ImageLabel")
			if imageLabel then
				messageLabel.Size = UDim2.new(0.625, messageLabel.Size.X.Offset, 0.35, messageLabel.Size.Y.Offset)
				messageLabel.Position = UDim2.new(0.66, messageLabel.Position.X.Offset, 0.52, messageLabel.Position.Y.Offset)
				titleLabel.Size = UDim2.new(0.523, titleLabel.Size.X.Offset, 0.16, titleLabel.Size.Y.Offset)
				titleLabel.Position = UDim2.new(0.652, titleLabel.Position.X.Offset, titleLabel.Position.Y.Scale, titleLabel.Position.Y.Offset)
				closeButton.Position = UDim2.new(0.65, messageLabel.Position.X.Offset, 0.8, messageLabel.Position.Y.Offset)
				imageLabel.Image = "rbxassetid://" .. tostring(imageId)

				if effect == "rotate" then
					local rotationSequence = {-20, 20, -20, 20, 0}
					local currentStep = 1
					local function rotateNext()
						if currentStep > #rotationSequence then return end
						local targetRotation = rotationSequence[currentStep]
						currentStep = currentStep + 1
						local rotateTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
						local rotateTween = TweenService:Create(imageLabel, rotateTweenInfo, {Rotation = targetRotation})
						rotateTween:Play()
						rotateTween.Completed:Connect(rotateNext)
					end
					rotateNext()
				elseif effect == "explosion" then
					local originalSize = imageLabel.Size
					local tweenInfo1 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					local tweenInfo2 = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					local tweenInfo3 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					local tween1 = TweenService:Create(imageLabel, tweenInfo1, {
						Size = UDim2.new(originalSize.X.Scale * 0.8, originalSize.X.Offset,
							originalSize.Y.Scale * 0.8, originalSize.Y.Offset)
					})
					tween1:Play()
					tween1.Completed:Connect(function()
						local tween2 = TweenService:Create(imageLabel, tweenInfo2, {
							Size = UDim2.new(originalSize.X.Scale * 1.2, originalSize.X.Offset,
								originalSize.Y.Scale * 1.2, originalSize.Y.Offset)
						})
						tween2:Play()
						tween2.Completed:Connect(function()
							local tween3 = TweenService:Create(imageLabel, tweenInfo3, {Size = originalSize})
							tween3:Play()
						end)
					end)
				end
				imageLabel.Visible = true
			end
			messageLabel.TextSize = TextScaler.getScaledFontSize(message, messageLabel.TextSize)
		end
	end

	-- Animación de entrada
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(notificationClone, tweenInfo, {Position = UDim2.new(0.25, 0, 0.9, 0)})
	tween:Play()

	table.insert(activeNotifications, notificationClone)
	updateNotificationPositions(0.25)

	-- Botón cerrar
	closeButton.MouseButton1Click:Connect(function()
		local index = table.find(activeNotifications, notificationClone)
		if index then
			table.remove(activeNotifications, index)
			local shrinkTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local targetSize = UDim2.new(0, 0, notificationClone.Size.Y.Scale, notificationClone.Size.Y.Offset)
			local tweenShrink = TweenService:Create(notificationClone, shrinkTweenInfo, {Size = targetSize})
			notificationClone.ZIndex = 1
			tweenShrink:Play()
			tweenShrink.Completed:Connect(function()
				notificationClone:Destroy()
			end)
			updateNotificationPositions(0.5)
		end
	end)

	-- Auto-destruir al expirar
	local bar = notificationClone:WaitForChild("BarFrame"):WaitForChild("Bar")
	local barMaxSize = bar.Size.X.Scale
	bar.Size = UDim2.new(0, 0, bar.Size.Y.Scale, bar.Size.Y.Offset)
	local barTweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Linear)
	local barTween = TweenService:Create(bar, barTweenInfo, {Size = UDim2.new(barMaxSize, 0, bar.Size.Y.Scale, bar.Size.Y.Offset)})
	barTween:Play()

	delay(fadeTime, function()
		if notificationClone and notificationClone.Parent then
			local shrinkTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local targetSize = UDim2.new(0, 0, notificationClone.Size.Y.Scale, notificationClone.Size.Y.Offset)
			local tweenShrink = TweenService:Create(notificationClone, shrinkTweenInfo, {Size = targetSize})
			notificationClone.ZIndex = 1
			tweenShrink:Play()
			tweenShrink.Completed:Connect(function()
				notificationClone:Destroy()
				for i, n in ipairs(activeNotifications) do
					if n == notificationClone then
						table.remove(activeNotifications, i)
						break
					end
				end
				updateNotificationPositions(0.5)
			end)
		end
	end)
end

local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local showNotificationEvent = eventsFolder.Player:WaitForChild("ShowNotification")
showNotificationEvent.OnClientEvent:Connect(showNotification)

local showNotificationBindableEvent = eventsFolder.Player:WaitForChild("ShowNotificationBindable")
showNotificationBindableEvent.Event:Connect(showNotification)

SignalGame:OnEvent("ShowNoitification", showNotification)