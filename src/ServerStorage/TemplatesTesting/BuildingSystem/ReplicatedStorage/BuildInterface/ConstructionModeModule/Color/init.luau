local module = {}
module.__index = module

local eventChanged = Instance.new("BindableEvent")
local template = script:WaitForChild("ColorTemplate")
local debris = game:GetService("Debris")
local UIS = game:GetService("UserInputService")

local ClickInput = {Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1}

function module.new(metatable)
	local self = setmetatable({}, module)
	self.Tween = {Tween = {}, Action = false}
	self.ListButtons = {}
	self.IsActive = false
	self.self = metatable
	self.gui = metatable.gui.ColorFrame
	self.StateChanged = eventChanged.Event
	return self
end

function module:TweenAction()
	self.self.serv.ElimineOnlyActive(self.Tween, "Action")
	self.self.serv.ElimineTween(self.Tween.Tween)
	local anim:Tween = self.self.serv.CreateTween(self.gui,{Position = UDim2.fromScale(self.IsActive and .5 or 1,.5)},.15)
	table.insert(self.Tween.Tween, anim)
	self.gui.Visible = true
	
	self.Tween.Action = anim.Completed:Connect(function(playback)
		if playback == Enum.PlaybackState.Completed then
			self.self.serv.ElimineTween(self.Tween.Tween)
			self.self.serv.ElimineOnlyActive(self.Tween, "Action")
			self.gui.Visible = not not self.IsActive
			self:OpenFrame()
		end
	end)
	
	anim:Play()
end

function module:OpenFrame()
	if not self.IsActive then return end
	
	table.insert(self.IsActive, self.gui.Back.Close.MouseButton1Click:Connect(function() self:Destroy() end))
	
	if self.Enabled:IsA("Build") then
		
		table.insert(self.IsActive, self.Enabled.StateChanged:Connect(function() self:Destroy() end))
		
		for i,Color in self.self.MoveAndPlace.ModelChanges.Colors do
			
			local button = template:Clone()
			button.ColorText.Text = Color.Name
			button.Color.BackgroundColor3 = Color.Color
			
			local animator = self.self.serv.ButtonAnimator.new(button:FindFirstChild("Button"))
			animator:SelectedAction(nil, {
				BackgroundColor3 = Color3.fromRGB(97, 125, 170),
				Size = UDim2.fromScale(.404, 1.123),
			})
			animator:EnterAction(nil, {
				Size = UDim2.fromScale(.44, 1.23),
			})
			animator:DownAction(nil, {
				Size = UDim2.fromScale(.35, .95),
			})
			animator:AddEffectSound("Click", 139037694620957)
			
			local list = {
				gui = button,
				animator = animator,
				listData = Color,
			}
			
			animator:Connect(function()
				if self.ButtonSelect==i then return end
				self.ButtonSelect = i
				self:ChangedSelection()
			end)
			
			table.insert(self.ListButtons, list)
			button.Parent = self.gui.Back.ListColors
			
			if i == 1 then
				self.ButtonSelect = i
				self:ChangedSelection()
			end
			
		end
		
	end
	
	table.insert(self.IsActive, self.gui.Back.WheelImage.InputBegan:Connect(function(input)
		self:Wheel(input)
	end))
	table.insert(self.IsActive, self.gui.Back.ColorBar.InputBegan:Connect(function(input)
		self:Bar(input)
	end))
	table.insert(self.IsActive, self.gui.Back.RGB.RGBBOX.FocusLost:Connect(function() self:RGBBOXFocusLost() end))
	table.insert(self.IsActive, self.gui.Back.RGB.CopyButton.MouseButton1Click:Connect(function()
		self.self.CopyDataRGBBOX = self.gui.Back.RGB.RGBBOX.Text
	end))
	table.insert(self.IsActive, self.gui.Back.RGB.PasteButton.MouseButton1Click:Connect(function()
		if typeof(self.self.CopyDataRGBBOX)=="string" then
			self.gui.Back.RGB.RGBBOX.Text = self.self.CopyDataRGBBOX
			self:RGBBOXFocusLost()
		end
	end))
	
	table.insert(self.IsActive, self.gui.Back.CopyAllButton.MouseButton1Click:Connect(function()
		if self.Enabled:IsA("Build") then
			self.CopyDataAllColors = table.clone(self.self.MoveAndPlace.ModelChanges.Colors)
		end
	end))
	table.insert(self.IsActive, self.gui.Back.PasteAllButton.MouseButton1Click:Connect(function()
		if self.CopyDataAllColors then
			local lastSelect = self.ButtonSelect
			for _,data in self.CopyDataAllColors do
				for i, data2 in self.ListButtons do
					if data2.listData.Name == data.Name then
						self.ButtonSelect = i
						self:AcomodarBotones(data.Color)
						break
					end
				end
			end
			self.ButtonSelect = lastSelect
			self:AcomodarBotones()
		end
	end))
	
end

function module:RGBBOXFocusLost()
	local colorNew = self.self.ColorFormat.HexToColor3(self.gui.Back.RGB.RGBBOX.Text)
	if colorNew then
		self:AcomodarBotones(colorNew)
	end
end

function module:AddedInput(input : InputObject, action)
	if input and action and table.find(ClickInput, input.UserInputType) and input.UserInputState==Enum.UserInputState.Begin then
		local IsPhone = input.UserInputType==Enum.UserInputType.Touch
		local list = {}
		table.insert(list, (IsPhone and UIS.TouchEnded or UIS.InputEnded):Connect(function(input2)
			if input==input2 or input2.UserInputType==Enum.UserInputType.MouseButton1 then
				self.self.serv.ElimineActive(list)
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

function module:Wheel(input)
	if input and not self.WheelActive then
		local Frame = self.gui.Back.WheelImage
		local wheelSize = Frame.AbsoluteSize
		local wheelCenterPosition = Frame.AbsolutePosition + (wheelSize/2)
		local maxRadius = wheelSize.X/2
		
		self.WheelActive = self:AddedInput(input, function(Position : Vector2)
			if Position then
				if self.ButtonSelect and self.ListButtons[self.ButtonSelect] then
					Position = Vector2.new(Position.X, Position.Y) - wheelCenterPosition
					local angle = math.atan2(Position.X, Position.Y)
					local magnitude = Position.Magnitude
					local x = math.cos(angle) * magnitude
					local y = math.sin(angle) * magnitude
					local factor = math.min(1, maxRadius / magnitude)
					x, y = x * factor, y * factor
					x,y = (x + maxRadius) / (maxRadius * 2), (y + maxRadius) / (maxRadius * 2)
					Frame.ColorSelector.Position = UDim2.fromScale(y,x)
					self:Change()
				end
			else
				self.WheelActive = nil
			end
		end)
	elseif not input and self.WheelActive then
		self.WheelActive = self.self.serv.ElimineActive(self.WheelActive)
	end
end
function module:Bar(input)
	if input and not self.BarActive then
		local Frame = self.gui.Back.ColorBar
		self.BarActive = self:AddedInput(input, function(Position : Vector2)
			if Position then
				local data = self.ButtonSelect and self.ListButtons[self.ButtonSelect]
				if data then
					Position = (Position.Y - Frame.AbsolutePosition.Y) / Frame.AbsoluteSize.Y
					Frame.Frame.Position = UDim2.fromScale(.5, math.clamp(Position,0,1))
					self:Change()
				end
			else
				self.BarActive = nil
			end
		end)
	elseif not input and self.BarActive then
		self.BarActive = self.self.serv.ElimineActive(self.BarActive)
	end
end

function module:Change()
	local data = self.ButtonSelect and self.ListButtons[self.ButtonSelect]
	
	local XandY = self.gui.Back.WheelImage.ColorSelector.Position--.X.Scale
	local Z = self.gui.Back.ColorBar.Frame.Position.Y.Scale
	
	local ColorSelect = self.self.ColorFormat.GetColorFromXY_HSV(Vector3.new(XandY.X.Scale, XandY.Y.Scale, Z))
	if data then
		self.gui.Back.ColorBar.UIGradient.Color = self.self.ColorFormat.GetBarColor(ColorSelect)
		data.gui.Color.BackgroundColor3 = ColorSelect
		data.listData.Color = ColorSelect
		
		local model:Model = self.self.MoveAndPlace.modelInProcess
		model:FindFirstChild(data.listData.Name).Color = ColorSelect
		
		if data.listData.Name=="LightColor" then
			local light = model:FindFirstChild("LightPart"):FindFirstChildWhichIsA("Light")
			if light then light.Color = ColorSelect end
		end
		
		self.gui.Back.RGB.RGBBOX.Text = self.self.ColorFormat.HSVtoHex(ColorSelect)
	end
end
function module:AcomodarBotones(data)
	data = data or (self.ButtonSelect and
		self.ListButtons[self.ButtonSelect] and self.ListButtons[self.ButtonSelect].listData.Color)
	if data then
		local H,S,V = data:ToHSV()
		self.gui.Back.WheelImage.ColorSelector.Position = UDim2.fromScale(self.self.ColorFormat.GetXYFromHSV(H,S))
		self.gui.Back.ColorBar.Frame.Position = UDim2.fromScale(.5,1 - V)
		self:Change()
	end
end

function module:ChangedSelection()
	for index, Button in self.ListButtons do
		if index == self.ButtonSelect then
			self.self.MoveAndPlace.highlight.Adornee = self.self.MoveAndPlace.modelInProcess:FindFirstChild(Button.listData.Name)
				or self.self.MoveAndPlace.modelInProcess
			Button.animator:Select(true)
		else
			Button.animator:UnSelect(true)
		end
	end
	self:AcomodarBotones()
end

function module:index(enabled, Store)
	if enabled and not self.IsActive then
		
		local searched = self.self.MoveAndPlace.Enabled and
			#self.self.MoveAndPlace.ModelChanges.Colors>0 and self.self.MoveAndPlace
		if not searched then return end
		
		self.Enabled = searched
		self.IsActive = {}
		eventChanged:Fire(true)
		
		self:TweenAction()
	elseif not enabled and self.IsActive then
		
		for _,button in self.ListButtons do
			button.animator:Disconnect()
			debris:AddItem(button.gui,0)
		end
		self:Wheel()
		self:Bar()
		table.clear(self.ListButtons)
		self.IsActive = self.self.serv.ElimineActive(self.IsActive)
		self.self.MoveAndPlace.highlight.Adornee = self.self.MoveAndPlace.modelInProcess
		self.Enabled = nil
		eventChanged:Fire(false)
		self:TweenAction()
		
	end
end

function module:Destroy()
	self:index()
end

return module
