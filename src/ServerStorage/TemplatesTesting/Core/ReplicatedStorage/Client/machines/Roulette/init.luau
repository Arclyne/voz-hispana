local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("Shared")
local Trove = require(shared:WaitForChild("Trove"))
local machinesFolder = shared:WaitForChild("machines")
local roulettePrizes = require(machinesFolder:WaitForChild("roulettePrizes"))
local rouletteUtil = require(machinesFolder:WaitForChild("rouletteUtil"))
local SoundManager = require(shared:WaitForChild("SoundManager"))
local events = ReplicatedStorage:WaitForChild("Events")
local MessageEvent = events:WaitForChild("Player"):WaitForChild("ShowMessageBindable")
local MachinePrompt = require(script.Parent.MachinePrompt)

local Roulette = {}
Roulette.__index = Roulette

local function modulo(a, b)
	if a < b then
		return a
	else
		return a % b + 1
	end
end

local function setChildrenMaterial(instance: Instance, material: Enum.Material)
	for _, part in instance:GetChildren() do
		if part:IsA("BasePart") then
			part.Material = material
		end
	end
end

function Roulette.new(model: Model)
	local self = setmetatable({
		model = model,
		prompt = MachinePrompt.new(model),

		_trove = Trove.new(),
		_purple = model:WaitForChild("Lights"):WaitForChild("Purple"),
		_white = model:WaitForChild("Lights"):WaitForChild("White"),
		_parts = model:WaitForChild("Parts"):GetChildren(),
	}, Roulette)
	
	self.prompt.wheel.page:addAction("Info", function()
		MessageEvent:Fire(
			"Info",
			"Todas las casillas tienen exactamente la misma probabilidad. ¡Un spin gratis todos los días!"
		)
	end)
	
	local guiTemplate = script:WaitForChild("SurfaceGuiPart")

	table.sort(self._parts, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)
	
	for i, part in self._parts do
		local prize = roulettePrizes[i]

		part.Color = prize.color
		part.Material = Enum.Material.SmoothPlastic
		-- Clonamos la part contenedora del Gui y la colocamos
		local guiPart = guiTemplate:Clone()
		guiPart.Name   = "SliceGui"
		guiPart.Parent = part
		guiPart.CFrame = part.CFrame
		local pivotCFrame = part:GetPivot()
		guiPart.CFrame = pivotCFrame
		-- Asignamos Adornee y rellenamos ImageLabel/TextLabel
		local sgui = guiPart:FindFirstChildOfClass("SurfaceGui")
		if sgui then
			local img = sgui:FindFirstChild("ImageLabel")
			local txt = sgui:FindFirstChild("TextLabel")
			if img then
				img.Image = prize.image
				local scale = prize.imageScale
				local old = img.Size
				img.Size = UDim2.new(
					old.X.Scale  * scale,
					old.X.Offset * scale,
					old.Y.Scale  * scale,
					old.Y.Offset * scale
				)
			end
			if txt then txt.Text   = prize.type  end
		end
	end

	self:_illuminate(1)
	
	return self
end

function Roulette:start(turns: number)
	self._trove:Add(task.spawn(function()
		for turn = 1, turns do
			SoundManager:Play(nil, 15154119183, { Volume = 1, Pool = 2 }, self.model.PrimaryPart)
			self:_illuminate(turn)
			task.wait(rouletteUtil.getWaitTime(turn - 1, turns))
		end
	end))

	self._trove:Add(function()
		for _, part in self._parts do
			local fakePart = part:Clone()
			fakePart.Material = Enum.Material.Neon
			fakePart.Parent = part

			local tweenInfo = TweenInfo.new(0.65)
			local tween = TweenService:Create(fakePart, tweenInfo, {
				Transparency = 1,
				Size = fakePart.Size * 1.45,
			})

			tween.Completed:Connect(function()
				tween:Destroy()
				fakePart:Destroy()
			end)

			tween:Play()
		end

		self:_illuminate(1)
	end)
end

function Roulette:replicate(turns: number)
	self:start(turns)
end

function Roulette:idle()
	self._trove:Add(task.spawn(function()
		while true do
			setChildrenMaterial(self._purple, Enum.Material.Plastic)
			setChildrenMaterial(self._white, Enum.Material.Neon)

			task.wait(0.3)

			setChildrenMaterial(self._purple, Enum.Material.Neon)
			setChildrenMaterial(self._white, Enum.Material.Plastic)

			task.wait(0.3)
		end
	end))

	self._trove:Add(function()
		setChildrenMaterial(self._purple, Enum.Material.Neon)
		setChildrenMaterial(self._white, Enum.Material.Neon)
	end)
end

function Roulette:stop()
	self._trove:Clean()
end

function Roulette:_illuminate(index: number)
	for i, part in self._parts do
		part.Material = if i == modulo(index, #self._parts)
			then Enum.Material.Neon
			else Enum.Material.SmoothPlastic
	end
end

return Roulette
