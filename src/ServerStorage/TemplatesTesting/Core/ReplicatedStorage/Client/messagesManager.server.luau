local TweenService      = game:GetService("TweenService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player            = Players.LocalPlayer

-- Esperamos a que el Character exista
if not player.Character or not player.Character.Parent then
	player.CharacterAdded:Wait()
end

local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))
local eventsFolder  = ReplicatedStorage:WaitForChild("Events")
local showMsgEvent  = eventsFolder.Player:WaitForChild("ShowMessage")
local showMsgBind   = eventsFolder.Player:WaitForChild("ShowMessageBindable")

-- Función que muestra la notificación con tween
local function showMessage(title, message)
	print("mensaje")
	-- 1) Sonido
	SoundManager:Play(player, 122948856683895, { Volume = 0.1 })

	-- 2) Clonar UI y parenting
	local uiClone = ReplicatedStorage.Assets.UI.InteractionMessageUI:Clone()
	uiClone.Parent = player:WaitForChild("PlayerGui")

	-- 3) Referencia al Frame y textos
	local frame     = uiClone:WaitForChild("Frame")
	local titleLbl  = frame:WaitForChild("Tittle")
	local msgLbl    = frame:WaitForChild("Text")
	local closeBtn 	= frame:WaitForChild("Close")

	-- 4) Poner textos
	titleLbl.Text = title
	msgLbl.Text   = message

	-- 5) Guardar tamaño original y resetear a 0
	local originalSize = frame.Size
	frame.Size = UDim2.new(0, 0, 0, 0)

	-- 6) Crear y reproducir tween
	local tweenInfo = TweenInfo.new(
		0.5,                               -- tiempo (seg)
		Enum.EasingStyle.Quart,             -- estilo
		Enum.EasingDirection.Out           -- dirección
	)
	local tween = TweenService:Create(frame, tweenInfo, {
		Size = originalSize
	})
	tween:Play()
	local closing = false

	-- Función que cierra con tween inverso
	local function closeMessage()
		if closing then return end
		closing = true

		-- Sonido de cierre
		SoundManager:Play(player, 139037694620957, { Volume = 0.2 })

		-- Tween a tamaño cero
		local closeTween = TweenService:Create(frame, tweenInfo, { Size = UDim2.new(0, 0, 0, 0) })
		closeTween:Play()

		closeTween.Completed:Connect(function()
			uiClone:Destroy()
		end)
	end

	-- 7) Conectar el botón "Close"
	if closeBtn:IsA("TextButton") or closeBtn:IsA("ImageButton") then
		closeBtn.MouseButton1Click:Connect(closeMessage)
	else
		warn("Close no es un botón clicable")
	end
end

-- Conectar eventos
showMsgEvent.OnClientEvent:Connect(showMessage)
showMsgBind.Event:Connect(showMessage)
