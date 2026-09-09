local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)

local player = Players.LocalPlayer
local sleepAnimation = Instance.new("Animation")
sleepAnimation.AnimationId = "rbxassetid://114963865100023"

local remotes = ReplicatedStorage.Events

-- ESTADO GLOBAL (en este cliente) para TODAS las camas dobles
local isSleepingOrBusy = false
local COOLDOWN_TIME = 2

local DoubleBed = {}
DoubleBed.__index = DoubleBed

-- Colisiones sábana (soporta Sheet y SwollenSheetL/R/LR)
local function setSheetCollisions(model: Model, canCollide: boolean)
	local folders = {
		model:FindFirstChild("SwollenSheetL"),
		model:FindFirstChild("SwollenSheetR"),
		model:FindFirstChild("SwollenSheetLR"),
		model:FindFirstChild("SwollenSheet"),
		model:FindFirstChild("Sheet"),
	}

	for _, container in ipairs(folders) do
		if container then
			for _, part in ipairs(container:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = canCollide
				end
			end
		end
	end
end

local function findSeats(model: Model)
	-- Prioridad: Seat1 / Seat2
	local seat1 = model:FindFirstChild("Seat1")
	local seat2 = model:FindFirstChild("Seat2")

	if seat1 and seat2 and seat1:IsA("Seat") and seat2:IsA("Seat") then
		return seat1, seat2
	end

	-- Fallback: primeros 2 Seat/VehicleSeat que encuentre dentro del modelo
	local found = {}
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("Seat") or d:IsA("VehicleSeat") then
			table.insert(found, d)
		end
	end

	table.sort(found, function(a, b)
		return a:GetFullName() < b:GetFullName()
	end)

	return found[1], found[2]
end

function DoubleBed.new(model: Model)
	local self = setmetatable({}, DoubleBed)

	self.model = model
	self.track = nil
	self.currentSide = nil

	self.seat1, self.seat2 = findSeats(model)
	if not self.seat1 or not self.seat2 then
		warn(("⚠️ DoubleBed %s necesita 2 Seats (recomendado: Seat1 y Seat2)."):format(model.Name))
	end

	-- Conexión para detectar levantarse (como Bed)
	self.sitConnection = nil

	-- Dos interactables (izq/der)
	self.interactableL, self.wheelL = Interactable.new()
	self.interactableR, self.wheelR = Interactable.new()

	self.interactableL:setAdornee(model:WaitForChild("PromptHolder1"))
	self.interactableL:setClickHitbox(model)

	self.interactableR:setAdornee(model:WaitForChild("PromptHolder2"))
	self.interactableR:setClickHitbox(model)

	self.wheelL:setQuickAction("Dormir", self.sleepL, self)
	self.wheelL.page:addAction("Dormir", self.sleepL, self)

	self.wheelR:setQuickAction("Dormir", self.sleepR, self)
	self.wheelR.page:addAction("Dormir", self.sleepR, self)

	-- Occupied por lado
	model:GetAttributeChangedSignal("Occupied1"):Connect(function()
		if model:GetAttribute("Occupied1") then self.interactableL:disable() else self.interactableL:enable() end
	end)

	model:GetAttributeChangedSignal("Occupied2"):Connect(function()
		if model:GetAttribute("Occupied2") then self.interactableR:disable() else self.interactableR:enable() end
	end)

	-- Messy (acción Tender) -> en ambos wheels por consistencia
	model:GetAttributeChangedSignal("Messy"):Connect(function()
		if model:GetAttribute("Messy") then
			self.wheelL.page:addAction("Tender", self.make, self)
			self.wheelR.page:addAction("Tender", self.make, self)
		else
			self.wheelL.page:removeAction("Tender")
			self.wheelR.page:removeAction("Tender")
		end
	end)

	if model:GetAttribute("Occupied1") then self.interactableL:disable() end
	if model:GetAttribute("Occupied2") then self.interactableR:disable() end
	if model:GetAttribute("Messy") then
		self.wheelL.page:addAction("Tender", self.make, self)
		self.wheelR.page:addAction("Tender", self.make, self)
	end

	return self
end

function DoubleBed:sleepL()
	self:sleep(1)
end

function DoubleBed:sleepR()
	self:sleep(2)
end

function DoubleBed:sideIsEmpty(side: number)
	return not self.model:GetAttribute("Occupied" .. side)
end

function DoubleBed:findEmptySide()
	if not self.model:GetAttribute("Occupied1") then
		return 1
	elseif not self.model:GetAttribute("Occupied2") then
		return 2
	end
end

function DoubleBed:getSeatForSide(side: number)
	if side == 1 then return self.seat1 end
	if side == 2 then return self.seat2 end
end

function DoubleBed:sleep(side: number?)
	-- 1) CHEQUEO GLOBAL (igual que Bed)
	if isSleepingOrBusy then return end

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	if not self.seat1 or not self.seat2 then return end

	local selectedSide = side
	if selectedSide then
		if not self:sideIsEmpty(selectedSide) then return end
	else
		selectedSide = self:findEmptySide()
	end
	if not selectedSide then return end

	local seat = self:getSeatForSide(selectedSide)
	if not seat then return end

	-- Bloqueo global
	isSleepingOrBusy = true
	self.currentSide = selectedSide

	-- Limpieza de seguridad
	if self.sitConnection then
		self.sitConnection:Disconnect()
		self.sitConnection = nil
	end

	-- 2) SENTARSE (igual que Bed)
	seat:Sit(humanoid)

	-- 3) ANIMACIÓN (igual que Bed)
	local animator = humanoid:FindFirstChild("Animator") or humanoid:WaitForChild("Animator")
	self.track = animator:LoadAnimation(sleepAnimation)
	self.track.Priority = Enum.AnimationPriority.Action4
	self.track:Play(0.1)

	-- 4) COLISIÓN SÁBANA OFF (igual que Bed)
	setSheetCollisions(self.model, false)

	-- 5) ESCUCHAR LEVANTAMIENTO (Humanoid.Seated)
	self.sitConnection = humanoid.Seated:Connect(function(isSeated)
		if not isSeated then
			self:wake()
		end
	end)

	-- Desactivar ambos prompts mientras duerme
	self.interactableL:disable()
	self.interactableR:disable()

	remotes.Interactable.DoubleBed:FireServer(self.model, "sleep", tostring(self.currentSide))
end

function DoubleBed:wake()
	-- Se llama automáticamente cuando Humanoid.Seated pasa a false
	if self.sitConnection then
		self.sitConnection:Disconnect()
		self.sitConnection = nil
	end

	if self.track then
		self.track:Stop()
		self.track:Destroy()
		self.track = nil
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		-- Seguridad extra como en Bed: si sigue sentado en uno de los seats, lo suelta
		local sp = humanoid.SeatPart
		if sp and (sp == self.seat1 or sp == self.seat2) then
			humanoid.Sit = false
		end
	end

	-- Rehabilitar prompts solo si el lado está libre
	if not self.model:GetAttribute("Occupied1") then self.interactableL:enable() end
	if not self.model:GetAttribute("Occupied2") then self.interactableR:enable() end

	remotes.Interactable.DoubleBed:FireServer(self.model, "wake", tostring(self.currentSide))

	-- COOLDOWN GLOBAL anti-bug del Seat (igual que Bed)
	task.delay(COOLDOWN_TIME, function()
		isSleepingOrBusy = false
	end)
end

function DoubleBed:make()
	-- Para tender, debounce simple (no afecta físicas)
	if self.makingDebounce then return end
	self.makingDebounce = true

	remotes.Interactable.DoubleBed:FireServer(self.model, "make")

	task.wait(1)
	self.makingDebounce = false
end

return DoubleBed