local players = game:GetService("Players")
local tween = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tweenInfo = TweenInfo.new(.8, Enum.EasingStyle.Sine)

-- Igual que Bed server: referencia directa a template del emitter
local sleepEmitterTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Effects"):WaitForChild("SleepParticleEmitter")

local DoubleBed = {}
DoubleBed._instances = {}
DoubleBed.__index = DoubleBed

function DoubleBed.new(bedModel: Model)
	local self = setmetatable({}, DoubleBed)
	self.model = bedModel

	-- Estado por lado
	self.side = {
		[1] = { character = nil, connections = {}, emitter = nil },
		[2] = { character = nil, connections = {}, emitter = nil },
	}

	-- Animaciones de sábana (igual que tus scripts)
	local scaleBlanket = self.model.Sheet.Scale.Value
	local positionBlanket = self.model.Sheet.Position.Value

	self.makeAnimations = {
		tween:Create(scaleBlanket, tweenInfo, {
			Size = scaleBlanket.Size,
			Position = scaleBlanket.Position
		})
	}

	self.messUpAnimations = {
		tween:Create(scaleBlanket, tweenInfo, {
			Size = Vector3.new(
				scaleBlanket.Size.X,
				scaleBlanket.Size.Y,
				scaleBlanket.Size.Z - 4
			),
			Position = (scaleBlanket.CFrame * CFrame.new(0, 0, -2)).Position
		})
	}

	if positionBlanket then
		table.insert(self.makeAnimations,
			tween:Create(positionBlanket, tweenInfo, { Position = positionBlanket.Position })
		)

		table.insert(self.messUpAnimations,
			tween:Create(positionBlanket, tweenInfo, {
				Position = (positionBlanket.CFrame * CFrame.new(0, 0,
					self.model:GetAttribute("CustomMessUpDistance") or -4
					)).Position
			})
		)
	end

	DoubleBed._instances[bedModel] = self
	return self
end

local function disconnectAll(t)
	for _, c in ipairs(t) do
		c:Disconnect()
	end
	table.clear(t)
end

function DoubleBed:isOccupied(side: number)
	return self.model:GetAttribute("Occupied" .. side) ~= nil
end

function DoubleBed:anyOccupied()
	return self:isOccupied(1) or self:isOccupied(2)
end

function DoubleBed:sleep(player: Player, side: string | number)
	if player:DistanceFromCharacter(self.model:GetPivot().Position) > 20 then return end

	local s = tonumber(side)
	if s ~= 1 and s ~= 2 then return end
	if self:isOccupied(s) then return end

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	-- Asignar
	self.side[s].character = character
	self.model:SetAttribute("Occupied" .. s, true)

	-- Partículas (igual que Bed server)
	local head = character:FindFirstChild("Head")
	if head then
		local emitter = sleepEmitterTemplate:Clone()
		emitter.Parent = head
		emitter.Enabled = false
		self.side[s].emitter = emitter

		task.delay(1, function()
			if self.side[s].character == character and emitter and emitter.Parent then
				emitter.Enabled = true
			end
		end)
	end

	-- Conexiones de seguridad (igual que Bed server)
	table.insert(self.side[s].connections, players.PlayerRemoving:Connect(function(leaving)
		if leaving ~= player then return end
		self:wake(s)
	end))

	table.insert(self.side[s].connections, humanoid.Died:Connect(function()
		self:wake(s)
	end))

	-- Estado visual sábana
	self:toBulky()
	self:make()
end

function DoubleBed:wake(side: string | number)
	local s = tonumber(side)
	if s ~= 1 and s ~= 2 then return end

	-- Desconectar conexiones de ese lado
	disconnectAll(self.side[s].connections)

	-- Limpiar partículas de ese lado
	if self.side[s].emitter then
		self.side[s].emitter:Destroy()
		self.side[s].emitter = nil
	end

	-- Forzar soltar del seat (si quieres, como Bed server)
	local character = self.side[s].character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid and humanoid.Health > 0 then
			local seat = self.model:FindFirstChild("Seat" .. s)
			if seat and humanoid.SeatPart == seat then
				humanoid.Sit = false
			end
		end
	end

	-- Vaciar lado
	self.side[s].character = nil
	self.model:SetAttribute("Occupied" .. s, nil)

	-- Si ya no hay nadie, se aplana y se ensucia, si no, se mantiene bulky
	if not self:anyOccupied() then
		self:toFlat()
		self:messUp()
	else
		self:toBulky()
	end
end

function DoubleBed:make()
	for _, anim in ipairs(self.makeAnimations) do
		anim:Play()
	end
	self.model:SetAttribute("Messy", nil)
end

function DoubleBed:messUp()
	for _, anim in ipairs(self.messUpAnimations) do
		anim:Play()
	end
	self.model:SetAttribute("Messy", true)
end

function DoubleBed:toBulky()
	-- Ocultar la Sheet plana
	for _, basePart in ipairs(self.model.Sheet:GetChildren()) do
		if basePart:IsA("BasePart") then
			basePart.Transparency = 1
		end
	end

	local left = self:isOccupied(1)
	local right = self:isOccupied(2)

	if left and right then
		self:bulkyBoth()
	elseif left and not right then
		self:bulkyLeft()
	elseif not left and right then
		self:bulkyRight()
	end
end

function DoubleBed:toFlat()
	for _, folderName in ipairs({ "SwollenSheetL", "SwollenSheetR", "SwollenSheetLR" }) do
		local f = self.model:FindFirstChild(folderName)
		if f then
			for _, p in ipairs(f:GetChildren()) do
				if p:IsA("BasePart") then
					p.Transparency = 1
				end
			end
		end
	end

	for _, p in ipairs(self.model.Sheet:GetChildren()) do
		if p:IsA("BasePart") then
			p.Transparency = 0
		end
	end
end

function DoubleBed:bulkyLeft()
	for _, p in ipairs(self.model.SwollenSheetL:GetChildren()) do
		if p:IsA("BasePart") then p.Transparency = 0 end
	end
	for _, p in ipairs(self.model.SwollenSheetR:GetChildren()) do
		if p:IsA("BasePart") then p.Transparency = 1 end
	end
	for _, p in ipairs(self.model.SwollenSheetLR:GetChildren()) do
		if p:IsA("BasePart") then p.Transparency = 1 end
	end
end

function DoubleBed:bulkyRight()
	for _, p in ipairs(self.model.SwollenSheetL:GetChildren()) do
		if p:IsA("BasePart") then p.Transparency = 1 end
	end
	for _, p in ipairs(self.model.SwollenSheetR:GetChildren()) do
		if p:IsA("BasePart") then p.Transparency = 0 end
	end
	for _, p in ipairs(self.model.SwollenSheetLR:GetChildren()) do
		if p:IsA("BasePart") then p.Transparency = 1 end
	end
end

function DoubleBed:bulkyBoth()
	for _, p in ipairs(self.model.SwollenSheetL:GetChildren()) do
		if p:IsA("BasePart") then p.Transparency = 0 end
	end
	for _, p in ipairs(self.model.SwollenSheetR:GetChildren()) do
		if p:IsA("BasePart") then p.Transparency = 0 end
	end
	for _, p in ipairs(self.model.SwollenSheetLR:GetChildren()) do
		if p:IsA("BasePart") then p.Transparency = 1 end
	end
end

function DoubleBed.fromModel(model: Model)
	return DoubleBed._instances[model]
end

return DoubleBed