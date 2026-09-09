local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)

local debris = game:GetService("Debris")
local player = Players.LocalPlayer

local remotes = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Interactable")

local Chamba = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("JobSystem"))

local test = {}
test.__index = test
setmetatable(test, Interactable)

function test.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, test)

	self.track = nil
	self.model = model
	self.wheel = self:getDefaultWheel()

	model.AttributeChanged:Connect(function() self:init() end)
	self:init()

	self.wheel.page:addAction('Cancelar', self.Cancelar, self)
	return self
end

function test:init()
	if self.task then task.cancel(self.task) self.task = nil end
	self.wheel.page:removeAction('Pedir')
	self.wheel.page:removeAction('Preparar')
	self.wheel.page:removeAction('Renunciar')
	self.wheel.page:removeAction('Replenish')
	self.wheel.page:removeAction('Work')
	
	local YoEmpleado = self.model:GetAttribute("empleados") == player.UserId
	local BoxLocation = YoEmpleado and self.model:GetAttribute("BoxLocation")
	local Preparando = YoEmpleado and self.model:GetAttribute("Preparando")
	local ModelSelect = Preparando and "ModelGet" or YoEmpleado and "ModelJob" or "Model"
	
	local Adorne = self.model:FindFirstChild(ModelSelect)
	Adorne = Adorne and Adorne:FindFirstChild("Prompt")
	local Click = self.model:FindFirstChild(ModelSelect)
	Click = Click and Click:FindFirstChild("ClickPart")
	
	if not Click or not Adorne then
		self.task = task.delay(.5, function()
			self.task = nil
			self:init()
		end)
		return
	end
	
	self:setAdornee(Adorne)
	self:setClickHitbox(Click)
	
	local IsEnabled = not self.model:GetAttribute("EnabledPrompt")
	
	if Preparando and IsEnabled then
		self:AddHighlight({Parent = Click})
	else
		self:RemoveHighlight()
	end
	
	if IsEnabled then
		self:enable()
		
		if YoEmpleado then
			self.wheel.page:addAction("Renunciar", self.renunciar, self)
			if BoxLocation then
				self.wheel.page:addAction('Replenish',self.GetBox, self)
				self.wheel:setQuickAction("Replenish",self.GetBox, self)
			else
				self.wheel.page:addAction('Preparar', Preparando and self.Preparar or self.OpenGui, self)
				self.wheel:setQuickAction("Preparar", Preparando and self.Preparar or self.OpenGui, self)
			end
		else
			if self.model:GetAttribute("vacant") then
				self.wheel.page:addAction("Work", self.chambear, self)
			end
			self.wheel.page:addAction('Pedir', self.OpenGui, self)
			self.wheel:setQuickAction("Pedir", self.OpenGui, self)
		end
		
	else
		self:disable()
	end
end

function test:GetBox()
	local object = Chamba.SearchModel("BarraBartender", self.model)
	local CajasWorks = object and object.Union and object.Union.CajasWork
	if CajasWorks and CajasWorks.Occupant then
		CajasWorks:SetBox()
	end
end

function test:Preparar()
	local object = Chamba.SearchModel("BarraBartender", self.model)
	if not object or not object:IsWork() then return end
	object:ObtenerModelo()
end

function test:Cancelar()
	remotes:FindFirstChild("BarraBartender"):FireServer(self.model, "cancelar")
end

function test:OpenGui()
	remotes:FindFirstChild("BarraBartender"):FireServer(self.model, "OpenGui")
end

function test:pedir()
	remotes:FindFirstChild("BarraBartender"):FireServer(self.model, "pedir", "DrinkTest")
end

function test:chambear()
	local object = Chamba.SearchModel("BarraBartender", self.model)
	if not object then return end
	object:trabajar()
end
function test:renunciar()
	local object = Chamba.SearchModel("BarraBartender", self.model)
	if not object then return end
	object:renunciar()
end

return test
