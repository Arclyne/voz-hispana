local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)

local player = Players.LocalPlayer
local sleepAnimation = Instance.new("Animation")
sleepAnimation.AnimationId = "rbxassetid://114963865100023"

local remotes = ReplicatedStorage.Events

-- ESTADO GLOBAL: Compartido por todas las camas en este cliente.
-- Si es true, el jugador está durmiendo en ALGUNA cama o está en cooldown.
local isSleepingOrBusy = false 

-- Cooldown de seguridad para las físicas del Seat
local COOLDOWN_TIME = 2 

local Bed = {}
Bed.__index = Bed
setmetatable(Bed, Interactable)

function Bed.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, Bed)

	self.track = nil
	self.model = model
	self.wheel = self:getDefaultWheel()

	-- Buscamos el asiento existente en el modelo
	self.seat = model:FindFirstChild("Seat")
	if not self.seat then
		warn("⚠️ La cama " .. model.Name .. " no tiene una parte llamada 'Seat'. Colócala manualmente.")
	end

	-- Variable para guardar la conexión del evento
	self.sitConnection = nil

	self:setAdornee(model:WaitForChild("PromptHolder"))
	self:setClickHitbox(model)
	self.wheel:setQuickAction("Dormir", self.sleep, self)
	self.wheel.page:addAction("Dormir", self.sleep, self)

	model:GetAttributeChangedSignal("Occupied"):Connect(function()
		if model:GetAttribute("Occupied") then self:disable() else self:enable() end
	end)

	model:GetAttributeChangedSignal("Messy"):Connect(function()
		if model:GetAttribute("Messy") then self.wheel.page:addAction("Tender", self.make, self) else self.wheel.page:removeAction("Tender") end
	end)

	if model:GetAttribute("Occupied") then self:disable() end
	if model:GetAttribute("Messy") then self.wheel.page:addAction("Tender", self.make, self) end

	return self
end

-- Función auxiliar para colisiones de la sábana
local function setSheetCollisions(model, canCollide)
	local sheet = model:FindFirstChild("SwollenSheet") or model:FindFirstChild("Sheet")
	if sheet then
		for _, part in pairs(sheet:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = canCollide end
		end
	end
end

function Bed:sleep()
	-- 1. CHEQUEO GLOBAL: Si ya estás durmiendo (en esta u otra cama) o en cooldown, no hace nada.
	if isSleepingOrBusy then return end

	if not self.seat then return end 

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	-- Bloqueamos interacciones globalmente
	isSleepingOrBusy = true

	-- 1. LIMPIEZA DE SEGURIDAD
	if self.sitConnection then 
		self.sitConnection:Disconnect()
		self.sitConnection = nil
	end

	-- 2. SENTARSE
	self.seat:Sit(humanoid)

	-- 3. ANIMACIÓN
	local animator = humanoid:FindFirstChild("Animator") or humanoid:WaitForChild("Animator")
	self.track = animator:LoadAnimation(sleepAnimation)
	self.track.Priority = Enum.AnimationPriority.Action4 
	self.track:Play(0.1)

	-- 4. APAGAR COLISIÓN SÁBANA
	setSheetCollisions(self.model, false)

	-- 5. ESCUCHAR LEVANTAMIENTO
	self.sitConnection = humanoid.Seated:Connect(function(isSeated)
		if not isSeated then
			self:wake()
		end
	end)

	remotes.Interactable.Bed:FireServer("sleep", self.model)
end

function Bed:wake()
	-- Se llama automáticamente cuando el jugador salta (Humanoid.Seated false)

	-- 1. DESCONECTAR EVENTO
	if self.sitConnection then
		self.sitConnection:Disconnect()
		self.sitConnection = nil
	end

	-- 2. PARAR ANIMACIÓN
	if self.track then
		self.track:Stop()
		self.track:Destroy()
		self.track = nil
	end

	-- 3. SEGURIDAD EXTRA:
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	if humanoid and humanoid.SeatPart == self.seat then
		humanoid.Sit = false
	end

	remotes.Interactable.Bed:FireServer("wake", self.model)

	-- 4. GESTIÓN DEL COOLDOWN GLOBAL
	-- Mantenemos isSleepingOrBusy en true un poco más para evitar el bug del Seat
	task.delay(COOLDOWN_TIME, function()
		isSleepingOrBusy = false
	end)
end

function Bed:make()
	-- Para tender la cama usamos un debounce local simple, ya que no afecta a las físicas del jugador
	if self.makingDebounce then return end
	self.makingDebounce = true

	remotes.Interactable.Bed:FireServer("make", self.model)

	task.wait(1) -- Cooldown pequeño para tender la cama
	self.makingDebounce = false
end

return Bed