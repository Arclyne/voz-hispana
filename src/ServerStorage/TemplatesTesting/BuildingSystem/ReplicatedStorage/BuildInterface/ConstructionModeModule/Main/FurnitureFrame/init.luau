local module = {}
module.__index = module

local templateButton = script:FindFirstChild("Template")
local templateCoin = script:FindFirstChild("TemplateCoin")
local TextS = game:GetService("TextService")

function module.new(metatable)
	local self = setmetatable({}, module)
	self.self = metatable
	self.gui = metatable.gui.Main.Sections.FurnitureFrame
	self.InfoCoins = self.self.self.serv.InfoCoins
	self.LevelPlayer = self.self.self.serv.Player:WaitForChild("leaderstats"):WaitForChild("Level")
	self.Buttons = {}
	self.Products = {}
	self:init()
	return self
end

function module:Open()
	if not self.actives then
		
		self.actives = {}
		self.gui.Visible = true
		self.self.OcultButt.gui.Visible = true
		self.Button:Select(true)
		
		local IsInList = {}
		
		for model, product in self.Products do
			product.GUI.Visible = true
			table.insert(self.actives, product.GUI.MouseEnter:Connect(function() self:Info(model, product.setting, product.GUI) end))
			for _,section in product.setting.section do
				if not IsInList[section] then
					IsInList[section] = true
				end
			end
		end

		for _,Button in self.Buttons do
			local active = not not IsInList[Button.gui.Name]
			Button.gui.Visible = active
			if active then
				table.insert(self.actives, Button:Connect(function()
					if self.ButtonSelected == Button then return end

					self.ButtonSelected = Button
					for _,Button in self.Buttons do
						if Button ~= self.ButtonSelected then
							Button:UnSelect(true)
						else
							Button:Select(true)
						end
					end
					self:Order()

				end))

				if self.ButtonSelected == Button then
					Button:Select()
				end
			end
		end
		
		table.insert(self.actives, self.self.OcultButt:Connect(function()
			self.IsOcultInfo = not self.IsOcultInfo
			self.self.OcultButt.gui.ImageLabel.Image = string.format("rbxassetid://%d", self.IsOcultInfo and 109052352694585 or 76801143900057)
			self:Info()
		end))
		table.insert(self.actives, self.LevelPlayer:GetPropertyChangedSignal("Value"):Connect(function() self:Order() end))
		
		self:Order()
	end
	
end

function module:Info(model , setting, button)
	local frame = self.gui.Information
	local infoFrame = frame.Back
	
	local ALTO_DEL_FRAME = 1.5 -- alto del frame information
	local TamanoLetraDescrition = .07
	
	self.self.self.serv.ElimineOnlyActive(self.actives,"leave")
	self.tweenInfo = self.self.self.serv.ElimineOnlyTween(self.tweenInfo)
	self.self.self.serv.ElimineButtons(infoFrame.Information.Prices)
	
	for _,v:Instance in infoFrame.ViewportFrame:GetChildren() do
		if not v:IsA("UIAspectRatioConstraint") then
			self.self.self.serv.Debris:AddItem(v,0)
		end
	end
	infoFrame.IconProduct.Image = ""
	
	if model and setting and button and not self.InfoActive then
		if not self.IsOcultInfo then
			self.InfoActive = true
			self.tweenInfo = self.self.self.serv.CreateTween(frame,{Size = UDim2.fromScale(.374,ALTO_DEL_FRAME)},.1)
			self.tweenInfo:Play()
			
			if setting.Gui.Icon then
				infoFrame.IconProduct.Image = setting.Gui.Icon
			else
				self:CreateIcon(model, infoFrame.ViewportFrame)
			end
			
			infoFrame.Information.NameProduct.Text = setting.Gui.Name
			local DescriptionText:TextLabel = infoFrame.Information.DescriptionProduct
			DescriptionText.Text = setting.Gui.Description

			for nameCoin, Price in setting.Price do
				local info = self.InfoCoins[nameCoin]
				if info then
					local cloneCoin = templateCoin:Clone()
					cloneCoin.Icon.Image = info.Icon
					cloneCoin.Price.Text = tostring(Price)
					cloneCoin.Price.TextColor3 = info.Color
					cloneCoin.Parent = infoFrame.Information.Prices
				end
			end
			
			local SizeY = (frame.Parent.AbsoluteSize.Y * ALTO_DEL_FRAME) * infoFrame.Size.Y.Scale * infoFrame.Information.Size.Y.Scale
			
			local newSize = TextS:GetTextSize(setting.Gui.Description,
				SizeY * TamanoLetraDescrition,
				DescriptionText.Font,
				Vector2.new(DescriptionText.AbsoluteSize.X, math.huge)
			)
			
			DescriptionText.Size = UDim2.fromScale(1,newSize.Y / SizeY)
			
			self.actives.leave = button.MouseLeave:Connect(function() self:Info() end)
		end
	elseif self.InfoActive then
		if self.actives then
			self.tweenInfo = self.self.self.serv.CreateTween(frame,{Size = UDim2.fromScale(.374,0)},.1)
			self.tweenInfo:Play()
		else
			frame.Size = UDim2.fromScale(.374,0)
		end
		self.InfoActive = false
	end
end

function module:CreateIcon(Model : Model, ViewPort : ViewportFrame)
	if Model and ViewPort then
		Model = Model:Clone()
		self.self.self.serv.Debris:AddItem(Model:FindFirstChild("Settings"),0)
		Model.Parent = ViewPort
		
		local camera = Instance.new("Camera", ViewPort)
		camera.CameraType = Enum.CameraType.Scriptable
		ViewPort.CurrentCamera = camera
		
		local cameraCFrame = Model:GetPivot()
		local Size = Model:GetExtentsSize() / 1.5
		local NewPosition = cameraCFrame:ToWorldSpace(CFrame.new(-Size.X,Size.Y,-Size.Z)).Position
		
		camera.CFrame = CFrame.lookAt(NewPosition, cameraCFrame.Position)
	end
end

function module:Order()
	for model:Model, data in self.Products do
		local IsActive = not not table.find(data.setting.section, self.ButtonSelected.gui.Name)
		data.GUI.Visible = IsActive
		
		data.GUI.Button.Lock.Visible = data.setting.Price.Level
			and data.setting.Price.Level>tonumber(self.LevelPlayer.Value)
		
		if IsActive then
			data.animator:Connect(function()
				if not data.GUI.Button.Lock.Visible then
					self.self.self.MoveAndPlace:index(model)
				end
			end)
		else
			data.animator:Disconnect()
		end
	end
end

function module:Close()
	if self.actives then
		self.actives = self.self.self.serv.ElimineActive(self.actives)
		
		self.gui.Visible = false
		self.self.OcultButt.gui.Visible = false
		self.Button:UnSelect(true)
		self:Info()
		
		for _,Button in self.Buttons do
			if self.ButtonSelected == Button then
				Button:UnSelect(true)
			end
		end
		
		for model:Model, data in self.Products do
			data.GUI.Visible = false
			data.animator:Disconnect()
		end
		
	end
end

function module:init()
	
	for _,Button : TextButton in self.gui.FurnitureBar:GetChildren() do
		if Button:IsA("TextButton") then
			local animator = self.self.self.serv.ButtonAnimator.new(Button)
			animator:UnSelectedAction(nil,{
				Size = UDim2.fromScale(.07,1),
				BackgroundColor3 = Color3.fromRGB(195, 196, 213),
			})
			animator:UnSelectedAction(Button.IconSection,{
				Size = UDim2.fromScale(.7,.75),
				Position = UDim2.fromScale(.5,.5)
			})
			animator:UnSelectedAction(Button.nameSection,{
				Size = UDim2.fromScale(.0,.5),
				TextTransparency = 1,
			})
			animator:UnSelectedAction(Button.UIGradient,{
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0,Color3.fromRGB(189, 189, 206)),
					ColorSequenceKeypoint.new(1,Color3.fromRGB(255, 255, 255))}),
			})
			
			animator:SelectedAction(nil,{
				Size = UDim2.fromScale(.17,1),
				BackgroundColor3 = Color3.fromRGB(85, 170, 255),
			})
			animator:SelectedAction(Button.IconSection,{
				Size = UDim2.fromScale(.3,.75),
				Position = UDim2.fromScale(.2,.5)
			})
			animator:SelectedAction(Button.nameSection,{
				Size = UDim2.fromScale(.6,.5),
				TextTransparency = 0,
			})
			animator:SelectedAction(Button.UIGradient,{
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0,Color3.fromRGB(85, 170, 255)),
					ColorSequenceKeypoint.new(1,Color3.fromRGB(255, 255, 255))}),
			})
			
			animator:EnterAction(nil,{
				Size = UDim2.fromScale(.17,1),
			})
			animator:EnterAction(Button.IconSection,{
				Size = UDim2.fromScale(.3,.75),
				Position = UDim2.fromScale(.2,.5)
			})
			animator:EnterAction(Button.nameSection,{
				Size = UDim2.fromScale(.6,.5),
				TextTransparency = 0,
			})
			
			animator:DownAction(nil,{
				Size = UDim2.fromScale(.16,.9),
			})
			
			animator:AddEffectSound("Hover", 10066942189)
			animator:AddEffectSound("Click", 139037694620957)
			
			Button.Visible = false
			
			table.insert(self.Buttons, animator)
		end
	end
	
	table.sort(self.Buttons, function(a,b) return a.gui.LayoutOrder < b.gui.LayoutOrder end)
	
	self.ButtonSelected = self.Buttons[1]
	
	local function added(model : Model)
		local setting = model:FindFirstChild("Settings")

		if setting then
			setting = require(setting)

			local clone = templateButton:Clone()
			clone.Button.NameProduct.Text = setting.Gui.Name
			clone.Button.Prices.Start.Visible = not not setting.tag

			local animator = self.self.self.serv.ButtonAnimator.new(clone:FindFirstChild("Button"))

			animator:EnterAction(nil, {
				Size = UDim2.fromScale(.9, .9),
				BackgroundColor3 = Color3.new(0.584314, 0.584314, 0.584314),
			})
			animator:DownAction(nil, {
				Size = UDim2.fromScale(.75, .75),
			})

			for nameCoin, Price in setting.Price do
				local info = self.InfoCoins[nameCoin]
				if info then
					local cloneCoin = templateCoin:Clone()
					cloneCoin.Icon.Image = info.Icon
					cloneCoin.Price.Text = tostring(Price)
					cloneCoin.Price.TextColor3 = info.Color
					cloneCoin.Parent = clone.Button.Prices
				end
			end

			self.Products[model] = {
				setting = setting,
				GUI = clone,
				animator = animator,
			}

			self:CreateIcon(model, clone.Button.ViewportFrame)

			clone.Parent = self.gui.Products
		end
	end

	local folder = self.self.self.serv.RS:FindFirstChild("decoration template")
	for _,model : Model in folder:GetChildren() do added(model) end
	folder.ChildAdded:Connect(added)
	
end

return module
