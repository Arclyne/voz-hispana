local SizeManager = {}

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players") -- [NUEVO] Necesario para buscar en el inventario

-- Importamos el SoundManager dentro del módulo
local SoundManager = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SoundManager"))
local effectsFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Effects")

-- ID del sonido de cambio de tamaño
local SCALE_SOUND_ID = 91480113610534

-- Configuración de los estados (escala)
local SIZE_STATES = {
	Small = 0.6,
	Normal = 1.0,
	Big = 1.4
}

-- Definimos jerarquía numérica para calcular dirección (Grow/Shrink)
local STATE_VALUES = {
	Small = 1,
	Normal = 2,
	Big = 3
}

-- TIEMPOS DE LOS EFECTOS
local EFFECT_VISIBLE_DURATION = 3 
local GLOW_FADE_OUT_BUFFER = 2 

-- Aplica Partículas (ArrowArea y Glow) basándose en la dirección
function SizeManager:ApplySizeEffects(character: Model, direction: string)
	local head = character:FindFirstChild("Head")
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not head or not torso then return end

	local arrowColor, glowColor, arrowSpeed

	if direction == "Shrink" then
		-- SIEMPRE ROSA/MORADO AL ENCOGER
		arrowColor = Color3.fromRGB(200, 0, 200) 
		glowColor = Color3.fromRGB(150, 0, 150)  
		arrowSpeed = -2 
	else 
		-- SIEMPRE VERDE AL CRECER
		arrowColor = Color3.fromRGB(0, 255, 0)
		glowColor = Color3.fromRGB(0, 255, 0)
		arrowSpeed = 2 
	end

	-- Efecto Cabeza (ArrowArea)
	local arrow = effectsFolder:FindFirstChild("ArrowArea")
	if arrow then
		local newArrow = arrow:Clone()
		local yOffset = (direction == "Grow") and 1.5 or 2.5
		newArrow.CFrame = head.CFrame * CFrame.new(0, yOffset, 0)
		newArrow.Parent = character

		local weldArrow = Instance.new("WeldConstraint")
		weldArrow.Part0 = head
		weldArrow.Part1 = newArrow
		weldArrow.Parent = newArrow

		local arrowEffect = newArrow:FindFirstChild("ArrowEffect")
		if arrowEffect and arrowEffect:IsA("ParticleEmitter") then
			arrowEffect.Color = ColorSequence.new(arrowColor)
			arrowEffect.Speed = NumberRange.new(arrowSpeed) 
		end

		Debris:AddItem(newArrow, EFFECT_VISIBLE_DURATION) 
	end

	-- Efecto Torso (Glow)
	local glow = effectsFolder:FindFirstChild("Glow")
	if glow then
		local newGlow = glow:Clone()
		newGlow.CFrame = torso.CFrame
		newGlow.Parent = character

		local weldGlow = Instance.new("WeldConstraint")
		weldGlow.Part0 = torso
		weldGlow.Part1 = newGlow
		weldGlow.Parent = newGlow

		local attachment = newGlow:FindFirstChild("Attachment")
		if attachment then
			local glowEffect = attachment:FindFirstChild("GlowEffect")
			if glowEffect and glowEffect:IsA("ParticleEmitter") then
				glowEffect.Color = ColorSequence.new(glowColor)

				task.delay(EFFECT_VISIBLE_DURATION, function()
					if glowEffect and glowEffect.Parent then
						glowEffect.Enabled = false
						Debris:AddItem(newGlow, GLOW_FADE_OUT_BUFFER)
					end
				end)
			else
				Debris:AddItem(newGlow, EFFECT_VISIBLE_DURATION)
			end
		else
			Debris:AddItem(newGlow, EFFECT_VISIBLE_DURATION)
		end
	end
end

-- Función principal
function SizeManager:ChangeCharacterSize(character: Model, targetState: string, currentState: string, delayTime: number)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local targetScale = SIZE_STATES[targetState]
	if not targetScale then return end

	currentState = currentState or "Normal"
	delayTime = delayTime or 0

	local currentVal = STATE_VALUES[currentState] or 2
	local targetVal = STATE_VALUES[targetState]

	local direction = "Grow" 
	if currentVal > targetVal then
		direction = "Shrink" 
	end

	-- 1. Activamos las partículas
	self:ApplySizeEffects(character, direction)

	-- 2. Función interna para escalar el personaje Y las tools
	-- 2. Función interna para escalar el personaje Y las tools
	-- 2. Función interna para escalar el personaje Y la tool equipada
	local function applyScale()
		if not character or not character.Parent then return end

		local root = character:FindFirstChild("HumanoidRootPart")
		if root then
			SoundManager:Play(nil, SCALE_SOUND_ID, { Volume = 2 }, root)
		end

		-- Guardamos la escala numérica como atributo para que el Servidor la lea luego
		character:SetAttribute("SizeState", targetState)
		character:SetAttribute("CurrentScaleValue", targetScale)

		-- 1. Escalar el personaje (físicas)
		character:ScaleTo(targetScale)

		-- 2. Escalar SOLO la herramienta que tiene en la mano ahora mismo
		local equippedTool = character:FindFirstChildOfClass("Tool")
		if equippedTool then
			pcall(function()
				equippedTool.Scale = targetScale
			end)
		end
	end

	-- 3. Ejecutar la función con o sin delay
	if delayTime > 0 then
		task.delay(delayTime, applyScale)
	else
		applyScale()
	end
end

return SizeManager