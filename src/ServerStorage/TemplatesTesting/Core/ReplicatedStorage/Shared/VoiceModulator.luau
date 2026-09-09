local TweenService = game:GetService("TweenService")
local VoiceModulator = {}

-- Configuraciones de tono (Límites de Roblox: min 0.5, max 2.0)
local PITCH_PRESETS = {
	Normal = 1.0,
	Small = 1.75, -- Voz de pito (aguda)
	Big = 0.65    -- Voz grave (profunda)
}

function VoiceModulator:SetVoiceState(player: Player, state: string)
	local character = player.Character
	if not character then return end

	-- 1. Encontrar los componentes actuales de la API de Audio
	local fader = player:FindFirstChildWhichIsA("AudioFader")
	local emitter = character:FindFirstChildWhichIsA("AudioEmitter")

	if not fader or not emitter then
		warn("VoiceModulator: No se encontró el AudioFader en el Player o el AudioEmitter en el Character.")
		return
	end

	-- 2. Buscar si ya hemos creado el Modulador de Tono previamente
	local pitchShifter = character:FindFirstChild("VoicePitchShifter")

	-- Si es la primera vez que se transforma, estructuramos la nueva cadena de Wires
	if not pitchShifter then
		pitchShifter = Instance.new("AudioPitchShifter")
		pitchShifter.Name = "VoicePitchShifter"
		pitchShifter.Pitch = 1
		pitchShifter.Parent = character

		-- Romper la conexión vieja directa (Fader -> Emitter)
		-- Buscamos en el Emitter (como me indicaste que lo tenías) y en el Character
		for _, child in ipairs(emitter:GetChildren()) do
			if child:IsA("Wire") and child.SourceInstance == fader then
				child:Destroy()
			end
		end

		for _, desc in ipairs(character:GetDescendants()) do
			if desc:IsA("Wire") and desc.SourceInstance == fader and desc.TargetInstance == emitter then
				desc:Destroy()
			end
		end

		-- Crear la nueva cadena de cables: Fader -> PitchShifter -> Emitter
		local wireToPitch = Instance.new("Wire")
		wireToPitch.Name = "Wire_Fader_To_Pitch"
		wireToPitch.SourceInstance = fader
		wireToPitch.TargetInstance = pitchShifter
		wireToPitch.Parent = pitchShifter -- Lo guardamos aquí para tenerlo ordenado

		local wireToEmitter = Instance.new("Wire")
		wireToEmitter.Name = "Wire_Pitch_To_Emitter"
		wireToEmitter.SourceInstance = pitchShifter
		wireToEmitter.TargetInstance = emitter
		wireToEmitter.Parent = pitchShifter
	end

	-- 3. Aplicar el cambio de voz
	local targetPitch = PITCH_PRESETS[state] or PITCH_PRESETS.Normal

	-- Usamos un Tween para que la voz no cambie de golpe, sino que haga 
	-- una transición suave al encogerse/agrandarse (¡queda súper natural!)
	local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	TweenService:Create(pitchShifter, tweenInfo, {Pitch = targetPitch}):Play()
end

return VoiceModulator