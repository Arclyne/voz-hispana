local Work = game:GetService("Workspace")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local UserInputService = game:GetService("UserInputService")
local Camera = Work.CurrentCamera
local Interactable = require(script.Parent.Interactable)
local StoreFun = require(ReplicatedStorage:WaitForChild('Shared'):WaitForChild('Stores'))
local Event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Interactable"):WaitForChild("Paint")
local activesM = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("PaintActives"))

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
		if table.find({'Owner',"IsLoadPaint","InInUse"}, Attribute) then
			self:OwnerActions()
		end
	end)
	
	self:OwnerActions()
	
	return self
end

function Paint:OwnerActions()
	self.wheel.page:removeAction('Paint')
	self.wheel.page:removeAction('Load')
	self.wheel.page:removeAction('Purchase')
	self.wheel.page:removeAction('Clear')
	self.wheel.page:removeAction('Dar Like')
	
	if self.model:GetAttribute("Owner") then
		local IsOwner = Players.LocalPlayer.UserId == self.model:GetAttribute("Owner")
		local IsCuadroLoaded = self.model:GetAttribute("IsLoadPaint")
		if IsOwner then
			self:enable()
			self.wheel.page:addAction(IsCuadroLoaded and "Clear" or 'Load',IsCuadroLoaded and self.ClearCuadro or self.Paint, self)
			self.wheel:setQuickAction(IsCuadroLoaded and "Clear" or 'Load',IsCuadroLoaded and self.ClearCuadro or self.Paint, self)
		elseif IsCuadroLoaded then
			self:enable()
			self.wheel.page:addAction('Dar Like',self.Like, self)
			self.wheel.page:addAction('Purchase',self.ActionPurchase, self)
			self.wheel:setQuickAction('Purchase',self.ActionPurchase, self)
		else
			self:disable()
		end
	elseif not self.model:GetAttribute("InInUse") then
		self:enable()
		self.wheel.page:addAction('Paint',self.Paint, self)
		self.wheel:setQuickAction('Paint',self.Paint, self)
	else
		if self.model:GetAttribute("InInUse") ~= Player.UserId and
			activesM.isVisible and activesM.modelActual == self.model then
			self:Close()
		end
		self:disable()
	end
end

function Paint:ClearCuadro() StoreFun:AccionarCompras(self.model,{}) end
function Paint:ActionPurchase() StoreFun:AccionarCompras(self.model) end
function Paint:Like() StoreFun:LikeCuadro(self.model) end

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

	humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
	humanoid.WalkSpeed = self._originalWalkSpeed or 16
	humanoid.JumpHeight = self._originalJumpPower or 7.2
	humanoid.AutoRotate = self._originalAutoRotate ~= false
	self.uiFrame.Visible = false
	Cam.CameraType = Enum.CameraType.Custom
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
	self:_disableOtherActions(false)
	self._originalParts = {}
	for _,v:RBXScriptConnection in actives do v:Disconnect() end
	self.model.PrimaryPart.Size = self.Tamano or self.model.PrimaryPart.Size
	self:enable()
	activesM.modelActual = nil
	Event:FireServer(self.model, false)
end

function GetPropiedades(object: Instance)
	if typeof(object) ~= "Instance" then return nil end

	local original = {}
	local fake = {}

	if object:IsA("ParticleEmitter") then
		original.Enabled = object.Enabled
		fake.Enabled = false
		SerPropiedades(object, fake)
		object:Clear() -- quita las ya emitidas
		return original

	elseif object:IsA("BasePart") then
		original.LocalTransparencyModifier = object.LocalTransparencyModifier
		fake.LocalTransparencyModifier = 1
		original.CanCollide = object.CanCollide
		fake.CanCollide = false

	elseif object:IsA("Decal") or object:IsA("Texture") then
		original.Transparency = object.Transparency
		fake.Transparency = 1
	elseif object:IsA("Trail") then
		original.Enabled = object.Enabled
		fake.Enabled = false

	elseif object:IsA("Fire") or object:IsA("Smoke") or object:IsA("Sparkles") then
		original.Enabled = object.Enabled
		fake.Enabled = false

	elseif object:IsA("BillboardGui") and object.Name == "NameTag" then
		original.Enabled = object.Enabled
		fake.Enabled = false
	end

	SerPropiedades(object, fake)
	return original
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
	self.Tamano = self.Tamano or self.model.PrimaryPart.Size

	self:disable()
	self.wheel:hide()
	self._originalWalkSpeed = humanoid.WalkSpeed
	self._originalJumpPower = humanoid.JumpHeight
	self._originalAutoRotate = humanoid.AutoRotate
	self.model.PrimaryPart.Size = Vector3.zero

	for _, part in ipairs(character:GetDescendants()) do
		self._originalParts[part] = GetPropiedades(part)
	end

	humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
	humanoid.WalkSpeed = 0
	humanoid.JumpHeight = 0
	humanoid.AutoRotate = false
	character:PivotTo(self.model.Site.CFrame:ToWorldSpace(CFrame.new(0,character:GetExtentsSize().Y/2,0)))
	Cam.CameraType = Enum.CameraType.Scriptable
	Cam.CFrame = self.model.Cam.CFrame
	for _, Ui in ipairs(PlayerGui:GetChildren()) do
		if Ui.Name ~= "PAndSUi" and Ui:IsA("ScreenGui") then
			if Ui.Enabled == true then
				table.insert(Paint.Uis,Ui.Name)
				Ui.Enabled = false
			end
		end
	end
	self:_disableOtherActions(true)
	activesM.modelActual = self.model
	
	table.insert(activesM.isVisible,self.uiFrame.Button.MouseButton1Click:Connect(function()
		self:Close()
	end))
	table.insert(activesM.isVisible, self.uiFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		if not self.uiFrame.Visible and not self.uiFrame.Parent.Tools.Visible and not self.uiFrame.Parent.Load.Visible  then
			self:Close()
		end
	end))
	
	local IsLastPaint = self.PaintModule.ServerClient.Format.SeguridadFormato(Player:FindFirstChild("LastPaint").Value)
	
	if IsLastPaint and not self.model:GetAttribute("Owner") then
		self.PaintModule.Init(Player,self.uiFrame.Parent,IsLastPaint[1],IsLastPaint[4], IsLastPaint)
	else
		self.uiFrame.Visible = true
	end
	
	Event:FireServer(self.model, true)
end

function Paint:_disableOtherActions(disable)
	if disable then
		self._moveConnection = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				local key = input.KeyCode
				if table.find({Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
					Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right}, key) then
				end
			end
		end)
	elseif self._moveConnection then
		self._moveConnection:Disconnect()
		self._moveConnection = nil
	end
end

function Paint:GetModelActual()
	return activesM.modelActual
end

return Paint