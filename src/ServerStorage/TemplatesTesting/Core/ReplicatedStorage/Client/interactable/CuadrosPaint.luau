local Work = game:GetService("Workspace")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local UserInputService = game:GetService("UserInputService")
local Interactable = require(script.Parent.Interactable)
local activesM = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("PaintActives"))
local StoreFun = require(ReplicatedStorage:WaitForChild('Shared'):WaitForChild('Stores'))

local Cam = Work.CurrentCamera
local Paint = {}
Paint.Uis = {}
Paint.__index = Paint
setmetatable(Paint,Interactable)

function Paint.new(model: Model)
	local Ui = PlayerGui:WaitForChild("PAndSUi")
	local self = Interactable.new()
	setmetatable(self, Paint)
	self.model = model
	self.uiFrame = Ui.Paint
	self.wheel = self:getDefaultWheel()
	self._originalParts = {}

	self:setAdornee(model:WaitForChild("Prompt"))
	self:setClickHitbox(model)
	
	model.AttributeChanged:Connect(function(Attribute)
		if table.find({'Owner',"IsLoadPaint"}, Attribute) then
			self:OwnerActions()
		end
	end)
	
	self:OwnerActions()
	
	return self
end

function Paint:OwnerActions()
	self.wheel.page:removeAction('Load')
	self.wheel.page:removeAction('Clear')
	if self.model:GetAttribute("Owner") == Players.LocalPlayer.UserId then
		local IsCuadroLoaded = self.model:GetAttribute("IsLoadPaint")
		self:enable()
		self.wheel.page:addAction(IsCuadroLoaded and "Clear" or 'Load',IsCuadroLoaded and self.ClearCuadro or self.Paint, self)
		self.wheel:setQuickAction(IsCuadroLoaded and "Clear" or 'Load',IsCuadroLoaded and self.ClearCuadro or self.Paint, self)
	else
		self:disable()
	end
end

function Paint:ClearCuadro() StoreFun:AccionarCompras(self.model,{}) end

function Paint:Close()
	if not activesM.isVisible or activesM.modelActual ~= self.model then return end
	local actives = activesM.isVisible
	activesM.isVisible = false
	local character = Players.LocalPlayer.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	if not self._originalParts then return end
	for part, originalProps in self._originalParts do
		if part:IsDescendantOf(game) then
			SerPropiedades(part, originalProps)
		end
	end

	self.uiFrame.Visible = false
	
	for _, Ui in ipairs(PlayerGui:GetChildren()) do
		if Ui.Name ~= "PAndSUi" and Ui:IsA("ScreenGui") then
			for i,v in pairs(Paint.Uis) do
				if Ui.Name == v then
					Ui.Enabled = true
					table.remove(Paint.Uis,i)
				end
			end
		end
	end
	
	for _,v:RBXScriptConnection in actives do v:Disconnect() end
	self:enable()
	activesM.modelActual = nil
end

function SerPropiedades(object : Instance, Propiedades)
	if typeof(object)=="Instance" and typeof(Propiedades) == "table" then
		for proiedad, value in Propiedades do
			object[proiedad] = value
		end
	end
end

function Paint:Paint()
	if activesM.isVisible or self.model:GetAttribute("InInUse") then return end
	local character = Players.LocalPlayer.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	activesM.isVisible = {}

	self:disable()
	self.wheel:hide()

	for _, Ui in ipairs(PlayerGui:GetChildren()) do
		if Ui.Name ~= "PAndSUi" and Ui:IsA("ScreenGui") then
			if Ui.Enabled == true then
				table.insert(Paint.Uis,Ui.Name)
				Ui.Enabled = false
			end
		end
	end
	
	activesM.modelActual = self.model
	
	table.insert(activesM.isVisible,self.uiFrame.Button.MouseButton1Click:Connect(function()
		self:Close()
	end))
	table.insert(activesM.isVisible, self.uiFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		if not self.uiFrame.Visible and not self.uiFrame.Parent.Tools.Visible and not self.uiFrame.Parent.Load.Visible then
			self:Close()
		end
	end))
	table.insert(activesM.isVisible, game:GetService("RunService").RenderStepped:Connect(function()
		local magnitude = (character:GetPivot().Position - self.model:GetPivot().Position).Magnitude
		if magnitude >= 30 then
			self.uiFrame.Parent.Tools.Visible = false
			self.uiFrame.Parent.Load.Visible = false
			self:Close()
		end
	end))

	self.uiFrame.Visible = true
end

function Paint:GetModelActual()
	return activesM.modelActual
end

return Paint