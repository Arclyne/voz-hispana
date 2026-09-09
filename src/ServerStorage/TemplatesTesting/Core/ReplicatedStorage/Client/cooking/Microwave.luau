local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local CookingInteractable = require(script.Parent.CookingInteractable)

local Microwave = {}
Microwave.__index = Microwave
setmetatable(Microwave, CookingInteractable)

function Microwave.new(model: Model)
	local self = CookingInteractable.new(model, "Microwave")
	setmetatable(self, Microwave)

	self._cookBar = nil
	self._cookTween = nil
	self._cookProgressFrame = nil

	-- Rueda especial para herramientas que puedan usarse en el microondas.
	-- En este caso, PopCornBag debe tener el atributo booleano Microwaveable = true.
	local wheel = self:addWheel("microwave", function(tool)
		return tool:GetAttribute("Microwaveable") == true
	end)

	wheel:setQuickAction("Cocinar", self.request, self)
	wheel.page:addAction("Cocinar", self.request, self)

	-- Mientras el microondas está activo, se bloquean las acciones normales.
	-- Cuando ResultReady sea true, CookingInteractable se encargará de activar "Recoger".
	model:GetAttributeChangedSignal("Active"):Connect(function()
		if model:GetAttribute("Active") then
			self:disable()
		else
			self:enable()
		end
	end)

	-- Barra de progreso del cocinado.
	-- El servidor activa este atributo cuando empieza la cuenta atrás real.
	model:GetAttributeChangedSignal("CookingDuration"):Connect(function()
		local duration = model:GetAttribute("CookingDuration")

		if duration then
			self:showCookingBar(duration)
		else
			self:destroyCookingBar()
		end
	end)

	if model:GetAttribute("Active") then
		self:disable()
	end

	local duration = model:GetAttribute("CookingDuration")
	if duration then
		self:showCookingBar(duration)
	end

	return self
end

function Microwave:showCookingBar(duration: number)
	self:destroyCookingBar()

	local barTemplate = ReplicatedStorage.Assets.Interactable.Billboard:WaitForChild("Bar")
	local bar = barTemplate:Clone()
	bar.Name = "Bar_MicrowaveCooking"

	local adornee = self.model:FindFirstChild("Prompt")
	if not adornee then
		bar:Destroy()
		return
	end

	if bar:IsA("BillboardGui") then
		bar.Adornee = adornee
	end

	bar.Parent = adornee

	local barFrame = bar:FindFirstChild("ToolActivatedBar", true)
	local progressFrame = barFrame and barFrame:FindFirstChild("Bar", true)

	if not barFrame or not progressFrame then
		bar:Destroy()
		return
	end

	progressFrame.Size = UDim2.new(0, 0, 1, 0)
	barFrame.Visible = true

	self._cookBar = bar
	self._cookProgressFrame = progressFrame

	-- La barra se rellena de 0 a 100% durante el tiempo de cocinado.
	self._cookTween = TweenService:Create(
		progressFrame,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{
			Size = UDim2.new(1, 0, 1, 0),
		}
	)

	self._cookTween:Play()
end

function Microwave:destroyCookingBar()
	if self._cookTween then
		self._cookTween:Cancel()
		self._cookTween = nil
	end

	if self._cookBar then
		self._cookBar:Destroy()
		self._cookBar = nil
	end

	self._cookProgressFrame = nil
end

function Microwave:onDestroy()
	self:destroyCookingBar()
end

return Microwave