local players = game:GetService("Players")
local tween = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tweenInfo = TweenInfo.new(.8, Enum.EasingStyle.Sine)

-- Referencia DIRECTA al ParticleEmitter (ya no buscamos una carpeta o part)
local sleepEmitterTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Effects"):WaitForChild("SleepParticleEmitter")

local Bed = {}
Bed._instances = {}
Bed.__index = Bed

function Bed.new(bedModel)
	local self = setmetatable({}, Bed)
	self.model = bedModel
	self.currentCharacter = nil
	self.connections = {}
	self.activeParticles = nil -- Aquí guardaremos el Emitter clonado

	local scaleBlanket = self.model.Sheet.Scale.Value
	local positionBlanket = self.model.Sheet.Position.Value

	self.makeAnimations = {
		tween:Create(scaleBlanket,tweenInfo, {
			Size = scaleBlanket.Size,
			Position = scaleBlanket.Position
		})
	}
	self.messUpAnimations = {
		tween:Create(scaleBlanket,tweenInfo, {
			Size = Vector3.new(
				scaleBlanket.Size.X,
				scaleBlanket.Size.Y,
				scaleBlanket.Size.Z - 4
			),
			Position = (scaleBlanket.CFrame * CFrame.new(0, 0, -2)).Position
		})
	}

	if (positionBlanket) then
		table.insert(self.makeAnimations, 		
			tween:Create(positionBlanket, tweenInfo, {
				Position = positionBlanket.Position
			}))
		table.insert(self.messUpAnimations,
			tween:Create(positionBlanket, tweenInfo, {
				Position = (positionBlanket.CFrame * CFrame.new(0, 0, -4)).Position
			}))
	end

	Bed._instances[bedModel] = self

	return self
end

function Bed:sleep(player : Player)
	if (player:DistanceFromCharacter(self.model:GetPivot().Position) > 20) then return end;

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")

	if (not humanoid or humanoid.Health <= 0) then return end;

	local head = character:FindFirstChild("Head")

	-- 1. LÓGICA DE PARTÍCULAS (CORREGIDA)
	if head then
		-- Clonamos directamente el Emitter y lo metemos en la cabeza
		-- Al ser un efecto y no una BasePart, no afecta físicas ni posición.
		local emitter = sleepEmitterTemplate:Clone()
		emitter.Parent = head
		emitter.Enabled = false -- Empieza apagado

		self.activeParticles = emitter -- Guardamos referencia para borrarlo luego

		-- Hilo para activar tras 1 segundo
		task.delay(1, function()
			-- Verificamos si sigue siendo el mismo personaje, si sigue asignado y si el emitter existe
			if self.currentCharacter == character and emitter and emitter.Parent then
				emitter.Enabled = true
			end
		end)
	end

	self:toBulky()
	self:make()

	table.insert(self.connections, players.PlayerRemoving:Connect(function(playerRemoving)
		if (playerRemoving ~= player) then return end;
		self:wake()
	end))
	table.insert(self.connections, humanoid.Died:Connect(function()
		self:wake()
	end))

	self.model:SetAttribute("Occupied", true)
	self.currentCharacter = character
end

function Bed:wake()
	for _, connection in pairs(self.connections) do
		connection:Disconnect()
	end
	self.connections = {} -- Limpiar tabla

	-- 1. LIMPIEZA DE PARTÍCULAS
	if self.activeParticles then
		self.activeParticles:Destroy() -- Destruimos el Emitter directamente de la cabeza
		self.activeParticles = nil
	end

	local character = self.currentCharacter

	if (character) then
		local humanoid = character and character:FindFirstChild("Humanoid")

		-- Si quieres forzar que salte del asiento desde el server:
		if humanoid and humanoid.SeatPart == self.model:FindFirstChild("Seat") then
			humanoid.Sit = false
		end
	end

	self.model:SetAttribute("Occupied", nil)
	self:toFlat()
	self:messUp()
	self.currentCharacter = nil
end

function Bed.fromModel(model: Model)
	return Bed._instances[model]
end

function Bed:toBulky()
	local swollen = self.model:FindFirstChild("SwollenSheet")
	local flat = self.model:FindFirstChild("Sheet")

	if swollen then
		for _, basepart in pairs(swollen:GetChildren()) do
			if (not basepart:IsA("BasePart")) then continue end
			basepart.Transparency = 0
		end
	end

	if flat then
		for _, basepart in pairs(flat:GetChildren()) do
			if (not basepart:IsA("BasePart")) then continue end
			basepart.Transparency = 1
		end
	end
end

function Bed:toFlat()
	local swollen = self.model:FindFirstChild("SwollenSheet")
	local flat = self.model:FindFirstChild("Sheet")

	if swollen then
		for _, basepart in pairs(swollen:GetChildren()) do
			if (not basepart:IsA("BasePart")) then continue end
			basepart.Transparency = 1
		end
	end

	if flat then
		for _, basepart in pairs(flat:GetChildren()) do
			if (not basepart:IsA("BasePart")) then continue end
			basepart.Transparency = 0
		end
	end
end

function Bed:make()
	for _, animation in pairs(self.makeAnimations) do
		animation:Play()
	end
	self.model:SetAttribute("Messy", nil)
end

function Bed:messUp()
	for _, animation in pairs(self.messUpAnimations) do
		animation:Play()
	end
	self.model:SetAttribute("Messy", true)
end

return Bed