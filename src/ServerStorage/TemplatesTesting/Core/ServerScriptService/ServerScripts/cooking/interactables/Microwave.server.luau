local CookingStation = require(script.Parent.Parent.CookingStation)

local DEFAULT_COOK_DURATION = 6

local Microwave = setmetatable({}, CookingStation)
Microwave.__index = Microwave

local function getSound(model: Model, soundName: string): Sound?
	-- Preferimos buscar los sonidos dentro de una carpeta llamada Sounds.
	local soundsFolder = model:FindFirstChild("Sounds")
	local sound = soundsFolder and soundsFolder:FindFirstChild(soundName)

	-- Si no existe Sounds, buscamos igualmente en descendientes del modelo.
	if not sound then
		sound = model:FindFirstChild(soundName, true)
	end

	if sound and sound:IsA("Sound") then
		return sound
	end

	return nil
end

local function getPointLight(model: Model): PointLight?
	local lightHolder = model:FindFirstChild("Light")
	if not lightHolder then
		return nil
	end

	return lightHolder:FindFirstChildOfClass("PointLight")
end

local function setMicrowaveLight(model: Model, enabled: boolean)
	local pointLight = getPointLight(model)

	if pointLight then
		pointLight.Enabled = enabled
	end
end

local function getSlotPivot(model: Model): CFrame?
	local slot = model:FindFirstChild("Slot")

	if slot and slot:IsA("BasePart") then
		return slot:GetPivot()
	end

	if slot and slot:IsA("Model") then
		return slot:GetPivot()
	end

	return nil
end

local function playOneShotAndWait(sound: Sound?)
	if not sound then
		return
	end

	sound.Looped = false
	sound:Stop()
	sound.TimePosition = 0
	sound:Play()

	-- Esperamos a que termine PlaceFood antes de iniciar la cuenta atrás.
	-- Si TimeLength todavía no ha cargado, usamos una espera pequeña de seguridad.
	if sound.TimeLength <= 0 then
		task.wait(0.5)
		return
	end

	sound.Ended:Wait()
end

local function playOneShot(sound: Sound?)
	if not sound then
		return
	end

	sound.Looped = false
	sound:Stop()
	sound.TimePosition = 0
	sound:Play()
end

local function stopSound(sound: Sound?)
	if not sound then
		return
	end

	sound:Stop()
	sound.TimePosition = 0
end

function Microwave.new()
	local self = CookingStation.new("Microwave")

	self.defaultDuration = DEFAULT_COOK_DURATION

	-- No necesitamos que CookingStation cree un visual del resultado.
	-- El microondas solo muestra la bolsa mientras procesa.
	self.skipResultVisual = true

	return setmetatable(self, Microwave)
end

function Microwave:matchAttribute(tool: Tool): string?
	-- PopCornBag debe tener Microwaveable = true.
	-- Además debe tener un ObjectValue hijo llamado Target apuntando a PopCorn.
	if tool:GetAttribute("Microwaveable") then
		return "Microwaveable"
	end

	return nil
end

function Microwave:validate(model: Model): boolean
	-- Evita usar el microondas mientras cocina o mientras hay un resultado pendiente.
	return not model:GetAttribute("Active") and not model:GetAttribute("ResultReady")
end

function Microwave:onStart(ctx)
	local model = ctx.model

	local placeFoodSound = getSound(model, "PlaceFood")
	local workingSound = getSound(model, "Working")
	local finishSound = getSound(model, "Finish")
	local poppingSound = getSound(model, "Popping")
	
	local shouldPlayPopping = ctx.tool.Name == "PopCornBag"

	local cookDuration = model:GetAttribute("Duration")
		or ctx.tool:GetAttribute("Duration")
		or self.defaultDuration

	local slotPivot = getSlotPivot(model)

	-- Marcamos el microondas como ocupado desde el principio.
	model:SetAttribute("Active", true)
	model:SetAttribute("CookingDuration", nil)

	-- Visual de la bolsa dentro del microondas.
	local foodClone = CookingStation.cloneFood(ctx.tool)
	if foodClone and slotPivot then
		foodClone.Name = "ProcessingVisual"
		foodClone:PivotTo(slotPivot)
		foodClone.Parent = model
	end

	-- Quitamos la Tool del jugador después de colocarla visualmente.
	ctx.removeTool()

	-- Primero suena PlaceFood.
	-- La cuenta atrás todavía no empieza.
	playOneShotAndWait(placeFoodSound)

	-- Ahora empieza el cocinado real.
	setMicrowaveLight(model, true)

	if workingSound then
		workingSound.Looped = true
		workingSound:Stop()
		workingSound.TimePosition = 0
		workingSound:Play()
	end
	
	if shouldPlayPopping and poppingSound then
		poppingSound.Looped = true
		poppingSound:Stop()
		poppingSound.TimePosition = 10
		poppingSound:Play()
	end

	-- El cliente usa este atributo para mostrar la barra rellenándose.
	model:SetAttribute("CookingDuration", cookDuration)

	-- Esta función la llama CookingStation cuando termina la duración.
	return function()
		-- Terminó la cuenta atrás.
		model:SetAttribute("CookingDuration", nil)

		stopSound(workingSound)
		stopSound(poppingSound)
		setMicrowaveLight(model, false)

		local visual = model:FindFirstChild("ProcessingVisual")
		if visual then
			visual:Destroy()
		end

		-- Importante:
		-- NO esperamos a que termine Finish.
		-- Lo reproducimos y devolvemos el control inmediatamente para que
		-- CookingStation marque ResultReady y aparezca "Recoger" al instante.
		playOneShot(finishSound)

		model:SetAttribute("Active", false)

		return slotPivot
	end
end

function Microwave:onCancel(ctx)
	local model = ctx.model

	model:SetAttribute("CookingDuration", nil)
	model:SetAttribute("Active", false)

	setMicrowaveLight(model, false)

	stopSound(getSound(model, "Working"))
	stopSound(getSound(model, "Popping"))
	stopSound(getSound(model, "Finish"))

	local visual = model:FindFirstChild("ProcessingVisual")
	if visual then
		visual:Destroy()
	end
end

function Microwave:onPickup(model: Model)
	-- Si el jugador recoge mientras sigue sonando el pitido final,
	-- el sonido se corta inmediatamente.
	stopSound(getSound(model, "Finish"))

	model:SetAttribute("Active", false)
	model:SetAttribute("CookingDuration", nil)

	setMicrowaveLight(model, false)
end

Microwave.new():bind()