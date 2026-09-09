local module = {}
module.__index = module

local Replicated = game:GetService('ReplicatedStorage')
local Interactable = Replicated:WaitForChild('Client'):WaitForChild('interactable')
local PromptModule = require(Interactable:WaitForChild('Paint'))

local Store = require(Replicated:WaitForChild('Shared'):WaitForChild('Stores'))
local monetizacion = require(Replicated.Shared:WaitForChild('Monetization'))

local Player = game:GetService("Players").LocalPlayer

local MarcosModels = Replicated:WaitForChild("Assets"):WaitForChild("Frames")

local Shared = Replicated:WaitForChild("Shared")
local PaintShared = Shared:WaitForChild("Paint")
local ServerClient = require(PaintShared:WaitForChild("ServerClient"))

function module.new(Frame)
	local self = setmetatable({
		enabled = false,
		gui = Frame,
		debris = game:GetService('Debris'),
		
		TypesSlides = {
			['Gamepass'] = Enum.InfoType.GamePass,
			['Shirt or Pants'] = Enum.InfoType.Asset,
		},
		
		FramesMod = require(script.Frames),
		Marcos = Player:WaitForChild("MarcosPaint"),
	}, module)
	
	self.Store = Store
	self.PromptModule = PromptModule
	self.TypeSelected = self.TypesSlides.Gamepass
	
	return self
end

function module:ClearFrame(Frame : GuiBase)
	if typeof(Frame)=="Instance" and Frame:IsA("GuiBase") then
		for _,GUI in Frame:GetChildren() do
			if GUI:IsA("GuiBase") then
				self.debris:AddItem(GUI,0)
			end
		end
	end
end

function module:ActiveSlide()
	if self.gui.Back.Gamepasses.SlideTypes.Visible or not self.enabled then return end
	for index,typee in self.TypesSlides do
		local clone = script:FindFirstChild('TemplateType'):Clone()
		clone.Text = index
		clone.Frame.Visible = self.TypeSelected == typee
		clone.MouseButton1Click:Connect(function()
			self.TypeSelected = typee
			self:DesactiveSlide()
		end)
		clone.Parent = self.gui.Back.Gamepasses.SlideTypes
	end
	self.gui.Back.Gamepasses.ViewType.Rotation = 180
	self.gui.Back.Gamepasses.SlideTypes.Visible = true
end
function module:DesactiveSlide()
	if not self.gui.Back.Gamepasses.SlideTypes.Visible then return end
	self.gui.Back.Gamepasses.SlideTypes.Visible = false
	self.gui.Back.Gamepasses.ViewType.Rotation = 0
	self:ClearFrame(self.gui.Back.Gamepasses.SlideTypes)
end

function module:GetIcon(Product)
	if typeof(Product)=="table" then
		if table.find({0,34}, Product.assetType) then
			return "rbxthumb://type=Asset&id=%d&w=420&h=420"
		elseif table.find({12,11}, Product.assetType) then
			return "rbxthumb://type=Asset&w=768&h=432&id=%d"
		end
	end
	return "rbxassetid://%d"
end

function module:CreateProducts()
	if not self.enabled then return end

	self:ClearFrame(self.gui.Back.Gamepasses.Precios)
	
	for _,product in monetizacion.ProductsPlayer do
		local clone = script:FindFirstChild('TemplateGamepasses'):Clone()
		clone.Button.TextPrice.Text = string.format('R$ %d', product.price)
		clone.Button.IconPrice.Image = string.format(self:GetIcon(product), product.id)
		clone.Button.BackgroundColor3 = self.ConfirmData.Product ~= product.id and clone.Button.BackgroundColor3 or Color3.fromRGB(193, 187, 143)
		clone.Button.MouseButton1Click:Connect(function()
			self.ConfirmData.Product = product.id~=self.ConfirmData.Product and product.id
			self:CreateProducts()
		end)
		clone.Parent = self.gui.Back.Gamepasses.Precios
	end
	
end

function module:CrearMarcoImage(NameMarco, resolucion, Parent:ViewportFrame)
	local clone:Model = typeof(NameMarco)=="string" and MarcosModels:FindFirstChild(NameMarco)
	clone = clone and typeof(resolucion)=="string" and clone:FindFirstChild(resolucion)
	clone = clone and clone:Clone()
	if clone then
		clone:PivotTo(CFrame.new(0,0,0))
		local camera = Instance.new("Camera", Parent)
		camera.CameraType = Enum.CameraType.Scriptable
		Parent.CurrentCamera = camera
		local Size = clone:GetExtentsSize()
		local newSize = Vector3.new(Size.X>Size.Z and 0 or Size.Z,0,Size.Z>Size.X and 0 or -Size.X)
		camera.CFrame = CFrame.lookAt(newSize * 1.5, Vector3.zero)
		clone.Parent = Parent
	end
end

function module:CreateFrames()
	if not self.enabled then return end
	self:ClearFrame(self.gui.Back.Marcos)
	local FramesMod = ServerClient:GetMarcos()
	self.gui.Back.Marcos.Visible = #FramesMod>0
	if #FramesMod > 0 then
		for _, Frame in FramesMod do
			local CreateFrame = script:FindFirstChild("TemplateMarcos"):Clone()
			CreateFrame.Button.Cantidad.Text = Frame.Count > 1 and string.format("X%d", Frame.Count) or ""
			CreateFrame.Button.BackgroundColor3 = self.ConfirmData.Marco ~= Frame.Name and CreateFrame.Button.BackgroundColor3 or Color3.fromRGB(193, 187, 143)
			self:CrearMarcoImage(Frame.Name,self.key and self.key[1], CreateFrame.Button.ViewCuadro)
			CreateFrame.Button.MouseButton1Down:Connect(function()
				self.ConfirmData.Marco = Frame.Name~=self.ConfirmData.Marco and Frame.Name
				self:CreateFrames()
			end)
			CreateFrame.Parent = self.gui.Back.Marcos
		end
	end
end

function module:ConfirmLoad()
	if not self.enabled then return end
	Store:AccionarCompras(self.modelActual, self.ConfirmData)
	self:Disabled()
	self.gui.Parent.Paint.Visible = false
end

function module:Enabled(Key)
	local caballete : Model = PromptModule:GetModelActual()
	if self.enabled or typeof(Key) ~= "string" or not caballete then return end
	
	local IsForSale = ServerClient:IsNotPaintInHouse(Key)
	
	if (caballete:HasTag("CuadrosPaint") or not IsForSale) and #ServerClient:GetMarcos() <= 0 then
		self.gui.Parent.Paint.Visible = false
		return Store:AccionarCompras(caballete, {Pintura = Key})
	end
	
	--ServerClient:IsNotCuadroInUse(Key,Store:GetStore(Player),caballete.Name)
	
	self.enabled = {}
	self.modelActual = caballete
	self.key = ServerClient.Format.SeguridadFormato(ServerClient.GlobalDataCache[Key])
	
	self.ConfirmData = {
		Pintura = Key,
		Marco = nil,
		Product = nil,
	}
	
	local Gamepasses = self.gui.Back.Gamepasses
	
	if caballete:HasTag("Paint") and IsForSale then
		Gamepasses.Visible = true
		table.insert(self.enabled, Gamepasses.ViewType.MouseButton1Click:Connect(function()
			if Gamepasses.SlideTypes.Visible then
				self:DesactiveSlide()
			else
				self:ActiveSlide()
			end
		end))
		table.insert(self.enabled, Gamepasses.ID.FocusLost:Connect(function(Enter)
			if Enter then
				monetizacion:AddedProductPlayer(math.round(tonumber(Gamepasses.ID.Text) or 0), self.TypeSelected)
			end
		end))
		table.insert(self.enabled, Gamepasses.ID:GetPropertyChangedSignal('Text'):Connect(function()
			Gamepasses.ID.Text = tostring(math.round(tonumber(Gamepasses.ID.Text) or 0))
			if Gamepasses.ID.Text == "0" then
				Gamepasses.ID.CursorPosition = 2
			end
			self:DesactiveSlide()
		end))
		table.insert(self.enabled, monetizacion.Events.ProductsPlayer.OnClientEvent:Connect(function()
			task.delay(.1, function()
				self:CreateProducts()
			end)
		end))
		self:CreateProducts()
	else
		Gamepasses.Visible = false
	end
	
	table.insert(self.enabled, self.gui.Confirm.MouseButton1Click:Connect(function() self:ConfirmLoad() end))

	self:CreateFrames()
	table.insert(self.enabled, self.Marcos.ChildAdded:Connect(function() self:CreateFrames() end))
	table.insert(self.enabled, self.Marcos.ChildRemoved:Connect(function() self:CreateFrames() end))
	
	table.insert(self.enabled, self.gui.Exit.MouseButton1Click:Connect(function()
		self:Disabled()
	end))
	
	self.gui.Visible = true
	self.gui.Parent.Paint.Visible = false
	
	table.insert(self.enabled, self.gui:GetPropertyChangedSignal("Visible"):Connect(function()
		self:Disabled()
	end))
end

function module:Disabled()
	if not self.enabled then return end
	for _,v:RBXScriptConnection in self.enabled do v:Disconnect() end
	self:ClearFrame(self.gui.Back.Gamepasses.Precios)
	self:ClearFrame(self.gui.Back.Marcos)
	self:DesactiveSlide()
	self.enabled = nil
	self.modelActual = nil
	self.key = nil
	self.ConfirmData = nil
	local IsVisible = self.gui.Visible
	self.gui.Visible = false
	self.gui.Parent.Paint.Visible = IsVisible
end

return module
