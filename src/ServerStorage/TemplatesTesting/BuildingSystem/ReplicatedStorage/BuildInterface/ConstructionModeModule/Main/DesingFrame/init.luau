local module = {}
module.__index = module

local UIS = game:GetService("UserInputService")
local ClickInput = {Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1}

function module.new(metatable)
	local self = setmetatable({}, module)
	self.self = metatable
	self.DataMaterials = self.self.self.serv.Player:WaitForChild("Materials")
	self.gui = metatable.gui.Main.Sections.DesingFrame
	
	self.Buttons = {
		self.gui.DesignButtons.Floor.ImageButton,
		self.gui.DesignButtons.Wall.ImageButton,
	}
	
	self.MaterialGui = {}
	self.ColorsButton = {}
	
	self:init()
	
	return self
end

function module:Open()
	if not self.actives then

		self.actives = {}
		self.gui.Visible = true
		self.Button:Select(true)
		
		for index, Button in self.Buttons do
			table.insert(self.actives, Button:Connect(function()
				if self.SectionSelected ~= index then
					self.SectionSelected = index
					self:ChangeSection()
				end
			end))
		end
		
		for _,Button in self.ColorsButton do
			table.insert(self.actives, Button.Button:Connect(function()
				self:Change({Color = Button.Color})
			end))
		end
		for _,Button in self.MaterialGui do
			table.insert(self.actives, Button.Animator:Connect(function()
				if (not Button.Data.Price and not Button.Data.IsWithGamepass) or
					(Button.Data.Price and table.find(string.split(self.DataMaterials.Value,","),tostring(Button.Data.Key))) or 
					(Button.Data.IsWithGamepass and self.self.self.serv.Monetizacion:IsGamepassOwner(Button.Data.IsWithGamepass)) then
					self:Change({Material = Button.Data.Key})
				elseif Button.Data.Price then
					local NameMaterial = #Button.Data.MaterialVariant>0 and Button.Data.MaterialVariant or Button.Data.Material.Name
					self.self.self.serv.Promt:Prompt({Pregunta = `Estas seguro de comprar el material {NameMaterial}?`},function()
						self.self.self.serv.Stores:ComprarMaterial(Button.Data.Key)
					end)
				else
					self.self.self.serv.Monetizacion:PurchaseProduct(Button.Data.IsWithGamepass)
				end
			end))
		end
		
		table.insert(self.actives, self.DataMaterials:GetPropertyChangedSignal("Value"):Connect(function() self:UpdateMaterials() end))
		
		table.insert(self.actives, self.MoreColorsButton:Connect(function() self:OpenMoreColors(not self.MoreColorsEnabled) end))
		
		if self.self.self.Store:IsA("Store") then
			
			for _, Estructura in self.self.self.Store.ChildsBase do
				table.insert(self.actives,Estructura.Value:GetAttributeChangedSignal("Material"):Connect(function() self:AdjustButtons() end))
				table.insert(self.actives,Estructura.Value:GetAttributeChangedSignal("Color"):Connect(function() self:AdjustButtons() end))
			end
			
		elseif self.self.self.Store:IsA("House") then
			
			self.DesingData = self.self.self.Store:GetColorAndTexture()
			table.insert(self.actives, self.self.self.Store:GetAttributeChangedSignal("Desing"):Connect(function()
				self.DesingData = self.self.self.Store:GetColorAndTexture()
				self:AdjustButtons()
			end))
			
			self.self.self.Store:UpdateRoomPlayer()
			self.RunningAction = self.self.self.serv.Running:AddFunct(function()
				self.self.self.Store:UpdateRoomPlayer()
			end)
			
			table.insert(self.actives, self.self.self.Store.ChangeRoom:Connect(function() self:ChangeSection() end))
		end
		
		self:ChangeSection()
		self:UpdateMaterials()
	end
end

-------MoreColors
function module:AddedInput(input : InputObject, action)
	if input and action and table.find(ClickInput, input.UserInputType) and input.UserInputState==Enum.UserInputState.Begin then
		local IsPhone = input.UserInputType==Enum.UserInputType.Touch
		local list = {}
		table.insert(list, (IsPhone and UIS.TouchEnded or UIS.InputEnded):Connect(function(input2)
			if input==input2 or input2.UserInputType==Enum.UserInputType.MouseButton1 then
				self.self.self.serv.ElimineActive(list)
				action()
			end
		end))
		table.insert(list, (IsPhone and UIS.TouchMoved or UIS.InputChanged):Connect(function(input2)
			if input==input2 or input2.UserInputType==Enum.UserInputType.MouseMovement then
				action(input2.Position)
			end
		end))
		action(input.Position)
		return list
	end
end

function module:MoreColorTween()
	self.TweenMore = self.self.self.serv.ElimineOnlyTween(self.TweenMore)
	local Position = UDim2.fromScale(not self.MoreColorsEnabled and 1.02 or 0.784,-2.155)
	if self.actives then
		self.self.self.serv.ElimineOnlyActive(self.actives, "TweenActive")
		self.TweenMore = self.self.self.serv.CreateTween(self.gui.MoreColors, {Position = Position}, .1)
		self.gui.MoreColors.Visible = true
		self.actives["TweenActive"] = self.TweenMore.Completed:Connect(function()
			self.self.self.serv.ElimineOnlyActive(self.actives, "TweenActive")
			self.gui.MoreColors.Visible = not not self.MoreColorsEnabled
		end)
		self.TweenMore:Play()
	else
		self.gui.MoreColors.Position = Position
		self.gui.MoreColors.Visible = not not self.MoreColorsEnabled
	end
	self.gui.ColorsBar.MoreColors.TextLabel.Text = self.MoreColorsEnabled and "Less" or "More"
end

function module:OpenMoreColors(Enabled)
	if Enabled and not self.MoreColorsEnabled then
		self.MoreColorsEnabled = {actives = {}}
		local Frame = self.gui.MoreColors
		table.insert(self.MoreColorsEnabled.actives, Frame.Close.MouseButton1Click:Connect(function() self:OpenMoreColors() end))
		table.insert(self.MoreColorsEnabled.actives, Frame.Confirm.MouseButton1Click:Connect(function()
			local XandY = Frame.WheelImage.ColorSelector.Position
			local Z = Frame.ColorBar.Frame.Position.Y.Scale
			local ColorSelect = self.self.self.ColorFormat.GetColorFromXY_HSV(Vector3.new(XandY.X.Scale, XandY.Y.Scale, Z))
			self:UpdateLastColor(self.self.self.ColorFormat.HexToColor3(Frame.RGB.RGBBOX.Text),"Confirm")
			self:OpenMoreColors()
		end))
		table.insert(self.MoreColorsEnabled.actives, Frame.RGB.RGBBOX.FocusLost:Connect(function()
			self:UpdateLastColor(self.self.self.ColorFormat.HexToColor3(Frame.RGB.RGBBOX.Text),"Changed")
		end))
		table.insert(self.MoreColorsEnabled.actives, Frame.RGB.PasteButton.MouseButton1Click:Connect(function()
			if typeof(self.self.self.CopyDataRGBBOX)=="string" then
				self:UpdateLastColor(self.self.self.ColorFormat.HexToColor3(self.self.self.CopyDataRGBBOX),"Changed")
			end
		end))
		table.insert(self.MoreColorsEnabled.actives, Frame.RGB.CopyButton.MouseButton1Click:Connect(function()
			self.self.self.CopyDataRGBBOX = Frame.RGB.RGBBOX.Text
		end))
		table.insert(self.MoreColorsEnabled.actives, Frame.WheelImage.InputBegan:Connect(function(input)
			self.MoreColorsEnabled.WheelColor = self.MoreColorsEnabled.WheelColor or self:AddedInput(input, function(Position)
				if Position then
					local wheelSize = Frame.WheelImage.AbsoluteSize
					local maxRadius = wheelSize.X/2
					local wheelCenterPosition = Frame.WheelImage.AbsolutePosition + (wheelSize/2)
					Position = Vector2.new(Position.X, Position.Y) - wheelCenterPosition
					local angle = math.atan2(Position.X, Position.Y)
					local magnitude = Position.Magnitude
					local x = math.cos(angle) * magnitude
					local y = math.sin(angle) * magnitude
					local factor = math.min(1, maxRadius / magnitude)
					x, y = x * factor, y * factor
					x,y = (x + maxRadius) / (maxRadius * 2), (y + maxRadius) / (maxRadius * 2)
					local Z = Frame.ColorBar.Frame.Position.Y.Scale
					self:UpdateLastColor(self.self.self.ColorFormat.GetColorFromXY_HSV(Vector3.new(y,x,Z)),"Changed")
				else
					self.MoreColorsEnabled.WheelColor = nil
				end
			end)
		end))
		table.insert(self.MoreColorsEnabled.actives, Frame.ColorBar.InputBegan:Connect(function(input)
			self.MoreColorsEnabled.ColorBar = self.MoreColorsEnabled.ColorBar or self:AddedInput(input, function(Position)
				if Position then
					Position = (Position.Y - Frame.ColorBar.AbsolutePosition.Y) / Frame.ColorBar.AbsoluteSize.Y
					local XandY = Frame.WheelImage.ColorSelector.Position
					self:UpdateLastColor(self.self.self.ColorFormat.GetColorFromXY_HSV(Vector3.new(XandY.X.Scale, XandY.Y.Scale, math.clamp(Position,0,1))),"Changed")
				else
					self.MoreColorsEnabled.ColorBar = nil
				end
			end)
		end))
		self:MoreColorTween()
		self:ChangeLastColor()
	elseif not Enabled and self.MoreColorsEnabled then
		self:BackLastColor()
		self.MoreColorsEnabled = self.self.self.serv.ElimineActive(self.MoreColorsEnabled.actives)
		self:MoreColorTween()
	end
end
function module:BackLastColor(Color : Color3)
	if self.MoreColorsEnabled and self.MoreColorsEnabled.LastColor then
		local Model:Model
		if self.self.self.Store:IsA("Store") then
			Model = self.MoreColorsEnabled.LastColor.Model
			Color = Color or self.MoreColorsEnabled.LastColor.Value:GetAttribute("Color")
		elseif self.self.self.Store:IsA("House") then
			local ListRuta = string.split(self.MoreColorsEnabled.LastColor,".")
			local data = self.DesingData[ListRuta[2]]
			data = data and data[ListRuta[1]]
			Model = data and data.Base
			Color = Color or (data and data.Color)
		end
		if Model and Color then
			for _,part in Model:GetChildren() do
				if part:IsA("BasePart") then
					part.Color = Color
				end
			end
		end
	end
end
function module:UpdateLastColor(Color:Color3, Status)
	if self.MoreColorsEnabled and self.MoreColorsEnabled.LastColor and Color then
		local H,S,V = Color:ToHSV()
		self.gui.MoreColors.WheelImage.ColorSelector.Position = UDim2.fromScale(self.self.self.ColorFormat.GetXYFromHSV(H,S))
		self.gui.MoreColors.RGB.RGBBOX.Text = self.self.self.ColorFormat.HSVtoHex(H,S,V)
		self.gui.MoreColors.ColorBar.Frame.Position = UDim2.fromScale(.5, 1 - V)
		self.gui.MoreColors.ColorBar.UIGradient.Color = self.self.self.ColorFormat.GetBarColor(Color)
		if Status == "Changed" then
			self:BackLastColor(Color)
		elseif Status == "Confirm" then
			self:Change({Color = Color})
		end
	end
end
function module:ChangeLastColor()
	if not self.MoreColorsEnabled then return end
	self:BackLastColor()
	local NameSection = self.SectionSelected==1 and "Floors" or "Walls"
	local Color:Color3
	if self.self.self.Store:IsA("Store") then
		for _, Estructura in self.self.self.Store.ChildsBase do
			if Estructura.Value.Name == NameSection then
				self.MoreColorsEnabled.LastColor = Estructura
				self:UpdateLastColor(Estructura.Value:GetAttribute("Color"), "Begin")
			end
		end
	elseif self.self.self.Store:IsA("House") then
		local ImHere = self.self.self.Store:UpdateRoomPlayer()
		self.MoreColorsEnabled.LastColor = NameSection.."."..ImHere
		local data = self.DesingData[ImHere]
		data = data and data[NameSection]
		self:UpdateLastColor(data and data.Color, "Begin")
	end
	self.MoreColorsEnabled.ColorBar = self.self.self.serv.ElimineActive(self.MoreColorsEnabled.ColorBar)
	self.MoreColorsEnabled.WheelColor = self.self.self.serv.ElimineActive(self.MoreColorsEnabled.WheelColor)
end
-----------------

function module:UpdateMaterials()
	local list = string.split(self.DataMaterials.Value,",")
	for _,Button in self.MaterialGui do
		if Button.Data.Price then
			Button.Button.PriceBack.Price.Visible = not table.find(list, tostring(Button.Data.Key))
		elseif Button.Data.IsWithGamepass then
			local IsOwner = self.self.self.serv.Monetizacion:IsGamepassOwner(Button.Data.IsWithGamepass)
			Button.Button.PriceBack.IconGamepass.Visible = not IsOwner
			local ActiveIndex = "MaterialKey"..tostring(Button.Data.Key)
			if IsOwner then
				self.self.self.serv.ElimineOnlyActive(self.actives, ActiveIndex)
			elseif not self.actives[ActiveIndex] then
				local Gamepass = self.self.self.serv.Monetizacion:SearchGamePass(Button.Data.IsWithGamepass)
				self.actives[ActiveIndex] = Gamepass and Gamepass.IsPurchase.Event:Connect(function() self:UpdateMaterials() end) or nil
			end
		end
	end
end

function module:Change(Cambios)
	if not Cambios then return end
	local NameSection = self.SectionSelected==1 and "Floors" or "Walls"
	if self.self.self.Store:IsA("Store") then
		for _, Estructura in self.self.self.Store.ChildsBase do
			if Estructura.Value.Name == NameSection then
				return self.self.self.Store:ChangeDesing(Estructura.Value, Cambios)
			end
		end
	elseif self.self.self.Store:IsA("House") then
		local ImHere = self.self.self.Store:UpdateRoomPlayer()
		self.self.self.Store:ChangeDesing(NameSection.."."..ImHere, Cambios)
	end
end

function module:AdjustButtons()
	local Color, Material
	local NameSection = self.SectionSelected==1 and "Floors" or "Walls"
	
	if self.self.self.Store:IsA("Store") then
		for _, Estructura in self.self.self.Store.ChildsBase do
			if Estructura.Value.Name == NameSection then
				Color = Estructura.Value:GetAttribute("Color")
				Material = Estructura.Value:GetAttribute("Material")
				break
			end
		end
	elseif self.self.self.Store:IsA("House") then
		local ImHere = self.self.self.Store:UpdateRoomPlayer()
		local data = self.DesingData[ImHere]
		data = data and data[NameSection]
		if data then
			Color = data.Color
			Material = data.Material
		else
			self.SectionSelected = self.SectionSelected==1 and 2 or 1
			return self:ChangeSection()
		end
	end
	
	for _,Button in self.ColorsButton do
		if Button.Color == Color then
			Button.Button:Select(true)
		else
			Button.Button:UnSelect(true)
		end
	end
	
	for _,Button in self.MaterialGui do
		if Button.Data.Key == Material then
			Button.Animator:Select(true)
		else
			Button.Animator:UnSelect(true)
		end
	end
	
	self:ChangeLastColor()
	
end

function module:ChangeSection()
	if self.actives then
		local ImHere = self.self.self.Store:IsA("House") and self.self.self.Store:UpdateRoomPlayer()
		for index, Button in self.Buttons do
			if index == self.SectionSelected then
				Button:Select(true)
			else
				local NameSection = index==1 and "Floors" or "Walls"
				Button:UnSelect(true)
				Button.gui.Parent.Visible = not not (self.self.self.Store:IsA("Store") or
					self.DesingData and self.DesingData[ImHere] and self.DesingData[ImHere][NameSection])
			end
		end
		self:AdjustButtons()
	end
end

function module:Close()
	if self.actives then

		self.RunningAction = self.self.self.serv.Running:ElimineFunct(self.RunningAction)
		self.actives = self.self.self.serv.ElimineActive(self.actives)
		self.gui.Visible = false
		self.Button:UnSelect(true)
		self:OpenMoreColors()
		
	end
end
function module:init()
	for index,Button in self.Buttons do
		
		local ButtonAnim = self.self.self.serv.ButtonAnimator.new(Button)
		ButtonAnim:UnSelectedAction(Button.Parent, {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})
		ButtonAnim:UnSelectedAction(Button.Parent.UIGradient, {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0,Color3.fromRGB(189, 189, 206)),
				ColorSequenceKeypoint.new(1,Color3.fromRGB(255, 255, 255))}),
		})

		ButtonAnim:EnterAction(Button.Parent, {
			Size = UDim2.fromScale(.85,.85),
		})
		ButtonAnim:DownAction(Button.Parent, {
			Size = UDim2.fromScale(.75, .75),
		})

		ButtonAnim:SelectedAction(Button.Parent, {
			BackgroundColor3 = Color3.fromRGB(85, 170, 255),
			Size = UDim2.fromScale(.8, .8),
		})
		ButtonAnim:SelectedAction(Button.Parent.UIGradient, {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0,Color3.fromRGB(85, 170, 255)),
				ColorSequenceKeypoint.new(1,Color3.fromRGB(255, 255, 255))}),
		})
		ButtonAnim:AddEffectSound("Click", 139037694620957)
		self.Buttons[index] = ButtonAnim
		self.SectionSelected = self.SectionSelected or index
		
	end
	
	local White = Color3.fromRGB(255, 255, 255)
	for _,Color:Color3 in self.self.self.DesingData.Colors do
		local Button = script:FindFirstChild("ColorButton"):Clone()
		Button.ImageColor3 = Color==White and Color3.new(0.854902, 0.854902, 0.854902) or Color
		Button:FindFirstChild("Checkmark").ImageColor3 = Color==White and Button.ImageColor3 or White
		Button.BackgroundColor3 = Color
		Button:FindFirstChild("UIGradient").Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0,Color),
			ColorSequenceKeypoint.new(1,White)})
		
		local ButtonAnim = self.self.self.serv.ButtonAnimator.new(Button)
		
		ButtonAnim:UnSelectedAction(Button:FindFirstChild("Checkmark"), {
			ImageTransparency = 1
		})
		
		local H,S,V = Color:ToHSV()
		V = V>.5 and V-.2 or V+.2
		
		ButtonAnim:EnterAction(nil, {
			BackgroundColor3 = Color3.fromHSV(H, S, V),
			Size = UDim2.fromScale(.9,.9),
		})
		ButtonAnim:DownAction(nil, {
			Size = UDim2.fromScale(.8, .8),
		})

		ButtonAnim:SelectedAction(Button:FindFirstChild("Checkmark"), {
			ImageTransparency = 0
		})
		ButtonAnim:SelectedAction(nil, {
			BackgroundColor3 = Color,
			Size = Button.Size,
		})
		
		ButtonAnim:AddEffectSound("Click", 139037694620957)
		
		Button.Parent = self.gui.ColorsBar
		table.insert(self.ColorsButton, {Button = ButtonAnim, Color = Color})
	end
	
	local AnimatorMC = self.self.self.serv.ButtonAnimator.new(self.gui.ColorsBar.MoreColors)
	AnimatorMC:EnterAction(nil, {
		BackgroundColor3 = Color3.fromRGB(181, 67, 194),
		Size = UDim2.fromScale(.11,.85),
	})
	AnimatorMC:DownAction(nil, {
		Size = UDim2.fromScale(.098, .7),
	})
	AnimatorMC:AddEffectSound("Click", 139037694620957)
	self.MoreColorsButton = AnimatorMC
	
	for _,Material in self.self.self.DesingData.Material do
		
		local Button = script:FindFirstChild("MaterialButton"):Clone()
		Button.VP.Material.Material = Material.Material or Enum.Material.SmoothPlastic
		Button.VP.Material.MaterialVariant = Material.MaterialVariant or ""
		
		local Price = Material.Price and tostring(Material.Price.Coins)
		Button.PriceBack.Price.Text = Price or ""
		Button.PriceBack.Price.Visible = not not Price
		
		Button.PriceBack.IconGamepass.Visible = not not Material.IsWithGamepass
		
		Button.MaterialName.Text = #Material.MaterialVariant>0 and Material.MaterialVariant or Button.VP.Material.Material.Name
		
		local ButtonAnim = self.self.self.serv.ButtonAnimator.new(Button)
		
		ButtonAnim:EnterAction(nil, {
			Size = Button.Size + UDim2.fromScale(.01,.05),
			BackgroundColor3 = Color3.new(0.584314, 0.584314, 0.584314),
		})
		ButtonAnim:DownAction(nil, {
			Size = Button.Size - UDim2.fromScale(.01,.05),
		})
		
		ButtonAnim:SelectedAction(nil, {
			Size = Button.Size,
			ImageColor3 = Color3.fromRGB(255, 204, 153),
			BackgroundColor3 = Color3.fromRGB(255, 204, 153),
		})
		
		table.insert(self.MaterialGui, {
			Button = Button,
			Animator = ButtonAnim,
			Data = Material,
		})
		
		Button.Parent = self.gui.DesignScrollingFrame
	end
	
end

return module
