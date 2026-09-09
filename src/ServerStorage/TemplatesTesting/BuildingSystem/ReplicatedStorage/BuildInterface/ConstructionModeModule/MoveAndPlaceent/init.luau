local module = {}
module.__index = module

local eventChanged = Instance.new("BindableEvent")
local debris = game:GetService("Debris")

local IsA = "Build"

function module.new(metatable)
	local self = setmetatable({}, module)
	
	self.Enabled = false
	self.actives = {}
	self.saveDecor = {}
	self.self = metatable
	self.highlight = script:WaitForChild("Highlight")
	self.gui = script:WaitForChild("BillboardBuildingSystem")
	self.gui.Parent = self.self.serv.Player:FindFirstChild("PlayerGui")
	self.gui.Enabled = false
	
	self.StateChanged = eventChanged.Event
	
	self.BarButton = self.self.serv.MovedButtonScroll.new(self.gui.DragLine.Line)
	self.BarButton:AddedArrow(self.BarButton.Button.MoveButton)
	
	self.Positions = self.self.serv.Stores.AddedDecor.Added.Positions

	return self
end

function module:IsA(t) return t == IsA end

function module:index(model : Model)
	if model and not self.Enabled then
		
		self.Enabled = model
		if self:Added() then
			eventChanged:Fire(true)
		else
			self.Enabled = false
		end
		
	elseif not model and self.Enabled then
		
		for _, modelSave in self.saveDecor do
			if modelSave.Model:IsDescendantOf(game) then
				modelSave.Model.Parent = modelSave.Parent
			end
		end
		
		if self.ModelsPutTable then
			for _, object in self.ModelsPutTable do
				debris:AddItem(object.Model, 0)
			end
		end
		
		if self.FusionInProcess and self.FusionInProcess.Model ~= self.modelInProcess then
			debris:AddItem(self.FusionInProcess.Model, 0)
		end
		self.FusionInProcess = nil
		self.ModelsPutTable = nil
		table.clear(self.saveDecor)
		self.ModelChanges = nil
		self.DataS = nil
		self:MoveIt()
		
		self.Enabled = false
		self.self.serv.ElimineActive(self.actives)
		self.RunningAction = self.self.serv.Running:ElimineFunct(self.RunningAction)
		self:CloseChangeAmount()
		self:Destroy()
		self:RaycastSections()
		eventChanged:Fire(false)
	end
end


function module:ActiveGui()
	if self.Enabled and self.modelInProcess then

		self.self.Colors:Destroy()

		table.insert(self.actives, self.gui.InteractiveIcons.CancelButton.MouseButton1Click:Connect(function() self:index() end))

		local IsTable = typeof(self.Enabled)=="table"
		local Boolean

		if IsTable then
			if not self.Enabled.IsA then
				
				Boolean = self.Enabled
				table.insert(self.actives, self.Enabled.Boolean.AncestryChanged:Connect(function(_,parent) if parent then return end self:index() end))
				table.insert(self.actives, self.Enabled.Model.AncestryChanged:Connect(function(_,parent) if parent then return end self:index() end))
				table.insert(self.actives, self.Enabled.Boolean.AttributeChanged:Connect(function() self:index() end))

			elseif self.Enabled:IsA("Decors") then
				Boolean = self.Enabled:GetChildren(false)[1]
				
				local function update()
					local childs = self.Enabled:GetChildren(false)
					if #childs <= 0 then
						self:index()
					end
					Boolean = childs[1]
				end

				table.insert(self.actives, self.Enabled.ChildAdded:Connect(update))
				table.insert(self.actives, self.Enabled.ChildRemoved:Connect(update))
				table.insert(self.actives, self.Enabled.ChildChanged:Connect(update))
				table.insert(self.actives, self.self.serv.Stores.DecorsPlayer.ChildRemoved:Connect(update))

			elseif self.Enabled:IsA("Decor") then
				Boolean = self.Enabled
				
				if self.Enabled.Disabled then
					table.insert(self.actives, self.Enabled.Disabled.Changed:Connect(function() self:index() end))
				end
				table.insert(self.actives, self.Enabled.Boolean.AttributeChanged:Connect(function() self:index() end))
				table.insert(self.actives, self.Enabled.Boolean.AncestryChanged:Connect(function() self:index() end))
				table.insert(self.actives, self.Enabled.DisabledChanged:Connect(function() self:index() end))

			end

		end

		table.insert(self.actives, self.gui.InteractiveIcons.MoveButton.InputBegan:Connect(function(input)
			if table.find({Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch}, input.UserInputType) then
				self:MoveIt(input)
			end
		end))

		local PlayerId = self.self.serv.Player.UserId
		
		local HouseObjectOwner = IsTable and not self.Enabled.IsA and
			 (tonumber(self.self.Store.Owner) == PlayerId or (self.Enabled.Boolean:GetAttribute("OwnerPlace")==PlayerId
				and not self.Enabled.Boolean:GetAttribute("CuadroKey")))
		
		local InventoryAviable = not self.DataS.IsTool and IsTable and not not ((self.Enabled.IsA and self.Enabled:IsA("Decor") and self.Enabled.Disabled) or HouseObjectOwner)
		local SellObject = not self.DataS.IsTool and IsTable and not not(self.Enabled.IsA or HouseObjectOwner)
		
		self.gui.InteractiveIcons.InventoryButton.Visible = InventoryAviable
		self.gui.InteractiveIcons.SellButton.Visible = SellObject
		
		local function elimineTable(IsAcept)
			if self.ModelsPutTable then
				for _, object in self.ModelsPutTable do
					if not IsAcept then
						local NewCFrame = CFrame.new(object.calculePosition * self.modelInProcess.PrimaryPart.Size) * CFrame.Angles(table.unpack(object.Orientation))
						local newPosition = self.modelInProcess:GetPivot():ToWorldSpace(NewCFrame) + Vector3.new(0,object.Model.PrimaryPart.Size.Y/2,0)
						object.ChangesList.Position = newPosition - Vector3.new(0,self.modelInProcess.PrimaryPart.Size.Y,0)
					end
					if typeof(object.Boolean)=="table" then
						object.Boolean:Update(object.ChangesList)
					else
						self.self.serv.Stores:UpdateDecor(object.Boolean, object.ChangesList)
					end
				end
			end
			
			if not IsAcept and self.Fusions and self.Fusions.Conections then
				for _, Obje in self.Fusions.Conections.Objects do
					Obje.DataFusion.FusionWith = nil
					self.self.serv.Stores:UpdateDecor(Obje.Boolean, Obje.DataFusion)
				end
			end
			
		end
		
		if InventoryAviable then
			table.insert(self.actives, self.gui.InteractiveIcons.InventoryButton.MouseButton1Click:Connect(function()
				if self.Enabled.IsA then
					self.Enabled:Delete()
					elimineTable()
				else
					self.self.serv.Stores:UpdateDecor(self.Enabled.Boolean, false)
					elimineTable()
				end
			end))
		end
		
		if SellObject then
			if Boolean then
				
				local function SellButonChange()
					self.gui.InteractiveIcons.SellButton.Visible = not not Boolean
					if Boolean then
						self.gui.InteractiveIcons.SellButton.Total.Text = string.format("%d%%", Boolean.Boolean.Value and 70 or 100)
					end
				end
				
				SellButonChange()
				if self.Enabled.IsA and self.Enabled:IsA("Decors") then
					table.insert(self.actives, self.Enabled.ChildChanged:Connect(SellButonChange))
				else
					table.insert(self.actives, self.Enabled.Boolean:GetPropertyChangedSignal("Value"):Connect(SellButonChange))
				end

				table.insert(self.actives, self.gui.InteractiveIcons.SellButton.MouseButton1Click:Connect(function()
					if not Boolean then return end
					elimineTable()
					self.self.serv.Stores:SellDecors(Boolean.Boolean)
				end))
				
			end
		end
		
		--------------------//acept
		
		table.insert(self.actives, self.gui.InteractiveIcons.AceptButton.MouseButton1Click:Connect(function()
			if self.FusionInProcess then
				local searchModel = self.self.serv.Stores:GetDecorPlayer(self.FusionInProcess.Ancle)
				if searchModel then
					if self.FusionInProcess.Model==self.modelInProcess then
						self.ModelChanges.FusionWith = string.format("%s,%s",searchModel.Boolean.Name,searchModel.Boolean:GetAttribute("UnniqueKey"))
					else
						self.FusionInProcess.DataOtherFusion = searchModel
					end
				end
			end
			
			if IsTable then
				local BooleanSelected
				
				if self.Enabled.IsA then
					local object = self.Enabled:IsA("Decor") and self.Enabled or self.Enabled:IsA("Decors") and self.Enabled:GetChildren(false)[1]
					if object then
						BooleanSelected = object.Boolean
						object:Update(self.ModelChanges)--self.ModelChanges
					end
				else
					BooleanSelected = self.Enabled.Boolean
					self.self.serv.Stores:UpdateDecor(self.Enabled.Boolean, self.ModelChanges)
				end
				
				local FusionPa = BooleanSelected and self.FusionInProcess and self.FusionInProcess.DataOtherFusion
				if FusionPa then
					local LastData = FusionPa.IsA and FusionPa:GetData() or self.self.serv.Stores:GetInfoDecordataByBoolean(FusionPa.Boolean)
					if LastData then
						LastData.FusionWith = string.format("%s,%s", BooleanSelected.Name, BooleanSelected:GetAttribute("UnniqueKey"))
						self.self.serv.Stores:UpdateDecor(FusionPa.Boolean, LastData)
					end
				end
				
				if self.Fusions and self.Fusions.Conections
					and self.Fusions.Conections.Position~=self.ModelChanges.Position then
					for _, Obje in self.Fusions.Conections.Objects do
						if FusionPa and FusionPa.Boolean==Obje.Boolean then continue end
						Obje.DataFusion.FusionWith = nil
						self.self.serv.Stores:UpdateDecor(Obje.Boolean, Obje.DataFusion)
					end
				end
				
			else
				if self.FusionInProcess and self.FusionInProcess.DataOtherFusion then
					self.ModelChanges.CreateNewFusion = self.FusionInProcess.DataOtherFusion.Boolean
				end
				self.self.serv.Stores:BuyDecors(self.Enabled, self.ModelChanges)
			end
			
			elimineTable(true)
		end))

		self.gui.InteractiveIcons.RotateButton.Visible = self.DataS.Format~="Walls"
		if self.DataS.Format~="Walls" then
			table.insert(self.actives, self.gui.InteractiveIcons.RotateButton.MouseButton1Click:Connect(function()
				self:ChangeAmount("Orientation")
			end))
		end

		self.gui.InteractiveIcons.ScaleButton.Visible = not self.DataS.NoScale
		if not self.DataS.NoScale then
			table.insert(self.actives, self.gui.InteractiveIcons.ScaleButton.MouseButton1Click:Connect(function()
				self:ChangeAmount("Scale")
			end))
		end

		local ColorsAviable = #self.ModelChanges.Colors > 0
		self.gui.InteractiveIcons.ColorButton.Visible = ColorsAviable
		if ColorsAviable then
			table.insert(self.actives, self.gui.InteractiveIcons.ColorButton.MouseButton1Click:Connect(function()
				self.self.Colors:index(not self.self.Colors.Enabled)
			end))
		end

		table.insert(self.actives, self.self.Colors.StateChanged:Connect(function()
			self.gui.InteractiveIcons.Visible = not self.self.Colors.Enabled
		end))

		self.RunningAction = self.self.serv.Running:AddFunct(function(...) self:Running(...) end)

	end
end

function module:ChangeAmount(NameType)
	if not self.actives.ChangeCA and self.ModelChanges and typeof(NameType)=="string"
		and table.find({"Scale","Orientation"},NameType) then
		
		local escalaList = self.DataS.Scale or self.Positions.normalScale
		
		local function GetPorcentaje(number)
			number = typeof(number)=="number" and number or 0
			if NameType=="Scale" then
				local porcentaje = (math.clamp(number, escalaList[1], escalaList[2])-escalaList[1]) / (escalaList[2]-escalaList[1])
				return porcentaje
			elseif NameType == "Orientation" then
				local porcentaje = ((math.deg(number) - math.deg(self.self.Store.AngleBase))%360) / 360
				return porcentaje
			else
				return 0
			end
		end
		
		local porcentaje
		if NameType=="Scale" then
			porcentaje = GetPorcentaje(self.ModelChanges.Scale)
			self.gui.DragLine.TextboxBack.Text.Text = tostring(self.ModelChanges.Scale)
		elseif NameType == "Orientation" then
			local _,Orientation,_ = self.ModelChanges.Position:ToOrientation()
			porcentaje = GetPorcentaje(Orientation)
			self.gui.DragLine.TextboxBack.Text.Text = tostring(math.round(porcentaje * 360)).."º"
		else
			return
		end
		
		self.gui.InteractiveIcons.Visible = false
		local n = NameType=="Scale" and "ScaleButton" or NameType=="Orientation" and "RotateButton"
		self.gui.DragLine.Line.MoveButton.ImageLabel.Image = self.gui.InteractiveIcons:FindFirstChild(n).ImageLabel.Image
		self.gui.DragLine.Visible = true
		self.BarButton:enabled()
		self.BarButton:changed(porcentaje)
		
		self.actives.closeCA = self.gui.DragLine.BackButton.MouseButton1Click:Connect(function()
			self:CloseChangeAmount()
		end)
		
		self.gui.DragLine.TextboxBack.Text.PlaceholderText =
			string.format("Example: %s", ({Scale=(tostring(escalaList[1]).."-"..tostring(escalaList[2])),Orientation="0-360"})[NameType])
		
		self.actives.TextboxCA = self.gui.DragLine.TextboxBack.Text.FocusLost:Connect(function()
			local Text = self.gui.DragLine.TextboxBack.Text.Text
			if NameType == "Orientation" and not tonumber(Text) then Text = string.sub(Text,0,#Text-2) end
			Text = tonumber(Text) or 0
			local newPorcentaje = GetPorcentaje(NameType == "Orientation" and (self.self.Store.AngleBase+math.rad(Text)) or Text)
			self.BarButton:changed(newPorcentaje)
		end)
		
		self.actives.ChangeCA = self.BarButton.Changed:Connect(function(valor)
			if NameType=="Scale" then
				local escalaList = self.DataS.Scale or self.Positions.normalScale
				local NewScale = escalaList[1] + ((escalaList[2]-escalaList[1]) * valor)
				self.ModelChanges.Scale = NewScale
				self.gui.DragLine.TextboxBack.Text.Text = tostring(NewScale)
				self.modelInProcess:ScaleTo(NewScale)
				self:UpdatePosition(self.ModelChanges.Position.Position)
			elseif NameType == "Orientation" then
				local NewAngle = self.self.Store.AngleBase + math.rad(valor * 360)
				self.ModelChanges.Position = CFrame.new(self.ModelChanges.Position.Position) * CFrame.Angles(0,NewAngle,0)
				self.gui.DragLine.TextboxBack.Text.Text = tostring(math.round(valor * 360)).."º"
				self:UpdatePosition(self.ModelChanges.Position.Position)
			end
		end)
		
	end
end
function module:SetChangedModel(modelClone, modelInProcess)
	modelInProcess = modelInProcess or self.modelInProcess
	if self.Enabled and modelClone and modelInProcess then
		local list = {}
		list.Position = modelInProcess:GetPivot()
		list.Scale = modelClone:GetScale()
		modelInProcess:ScaleTo(list.Scale)
		list.Colors = {}
		for _,part:BasePart in modelClone:GetChildren() do
			local NamePart = part.Name:lower()
			if part:IsA("BasePart") and (part.Name=="LightColor" or string.match(NamePart, "color")
				and tonumber(string.sub(NamePart,#NamePart))) then
				
				local color = {
					Name = part.Name,
					Color = part.Color,
				}
				
				table.insert(list.Colors, color)

				modelInProcess:FindFirstChild(part.Name).Color = part.Color
				modelInProcess:FindFirstChild(part.Name).Material = part.Material

				if part.Name=="LightColor" then
					local light = modelInProcess:FindFirstChild("LightPart"):FindFirstChildWhichIsA("Light")
					if not light then continue end
					light.Enabled = not not modelClone:GetAttribute("IsOn")
					light.Color = part.Color
				end
				
			end
		end
		for index,value in modelClone:GetAttributes() do
			modelInProcess:SetAttribute(index, value)
		end
		return list
	end
end

function module:MoveIt(Input : InputObject)
	local UIS = game:GetService("UserInputService")
	if self.Enabled and Input and Input.UserInputState==Enum.UserInputState.Begin and not self.actives.MoveItEnd then
		local IsTouch = Input.UserInputType==Enum.UserInputType.Touch
		local GetGuiInset = Vector3.new(0,game:GetService("GuiService"):GetGuiInset().Y,0)
		
		local Aumentar = self.ModelChanges.Position:VectorToWorldSpace(self.Positions.GetDirectionByFormat(self.DataS.Format) *
			(self.modelInProcess.PrimaryPart.Size/2))
		
		local Position = self.self.serv.Camera:WorldToViewportPoint(self.ModelChanges.Position.Position + Aumentar)
		local AbsolutePosition = Vector2.new(Input.Position.X, Input.Position.Y) + (Vector2.new(Position.X, Position.Y) - (self.gui.AbsoluteSize / 2))
		AbsolutePosition = Vector3.new(AbsolutePosition.X, AbsolutePosition.Y, 0)
		Position -= AbsolutePosition + GetGuiInset
		
		self.CursorPosition = {Position = AbsolutePosition + GetGuiInset + Position}
		
		local List = {self.self.serv.Player.Character, self.modelInProcess}
		local ray = RaycastParams.new()
		ray.FilterType = Enum.RaycastFilterType.Exclude
		ray.FilterDescendantsInstances = List
		self.CursorPosition.Params = ray
		
		if self.ModelsPutTable then
			for _, object in self.ModelsPutTable do
				ray:AddToFilter(object.Model)
			end
		end
		
		self.actives.MoveItEnd = (IsTouch and UIS.TouchEnded or UIS.InputEnded):Connect(function(Input2:InputObject)
			if Input==Input2 or Input2.UserInputType==Enum.UserInputType.MouseButton1 then
				self:MoveIt()
			end
		end)
		
		local function reduceEje(Actual, New, ViewportSize, Last)
			if Actual == 0 then return 0 end
			New = Actual>0 and math.max(ViewportSize + Last, New) or math.min(-Last, New)
			if Actual > 0 and New > ViewportSize then
				return math.max(0, Actual - (New - ViewportSize))
			elseif Actual < 0 and New < 0 then
				return math.min(0, Actual - New)
			end
			return Actual
		end
		
		self.actives.MoveItChanged = (IsTouch and UIS.TouchMoved or UIS.InputChanged):Connect(function(Input2:InputObject)
			if Input==Input2 or Input2.UserInputType==Enum.UserInputType.MouseMovement then
				local InputPosition = Input2.Position + GetGuiInset
				local mousePos = InputPosition + Position
				local viewport = self.self.serv.Camera.ViewportSize
				local outsideX = (mousePos.X > viewport.X or mousePos.X < 0 or InputPosition.X >= viewport.X or InputPosition.X <= 0)
				local outsideY = (mousePos.Y > viewport.Y or mousePos.Y < 0 or InputPosition.Y >= viewport.Y or InputPosition.Y <= 0)
				if outsideX or outsideY then
					local Last = (InputPosition - AbsolutePosition):Abs()
					Position = Vector3.new(outsideX and reduceEje(Position.X,mousePos.X,viewport.X, Last.X) or Position.X,
						outsideY and reduceEje(Position.Y,mousePos.Y,viewport.Y,Last.Y) or Position.Y,Position.Z)
				else
					AbsolutePosition = InputPosition
				end
				
				self.CursorPosition.Position = InputPosition + Position
			end
		end)
		
		self.actives.CharacterAdded = self.self.serv.Player.CharacterAdded:Connect(function(Cha) ray:AddToFilter(Cha) end)
		
		self.gui.InteractiveIcons.Visible = false
		UIS.MouseIconEnabled = false
	elseif not Input and self.actives.MoveItEnd then
		self.self.serv.ElimineGroupActive(self.actives, {"MoveItEnd", "MoveItChanged", "CharacterAdded"})
		self.CursorPosition = nil
		UIS.MouseIconEnabled = true
		self.gui.InteractiveIcons.Visible = true
	end
end

function module:CloseChangeAmount()
	self.gui.InteractiveIcons.Visible = true
	self.gui.DragLine.Visible = false
	self.self.serv.ElimineGroupActive(self.actives,{"closeCA","ChangeCA","TextboxCA"})
	self.BarButton:disabled()
end

function module:RaycastSections(ObjectPut)
	if self.Enabled then
		
		local function CreatParam(descendientes, raycat)
			local param = raycat and RaycastParams.new() or OverlapParams.new()
			param.FilterType = Enum.RaycastFilterType.Include
			param.FilterDescendantsInstances = descendientes
			return param
		end
		
		local listStoreParts = self.self.serv.Stores:GetStoreParts()
		self.AreaPutRaycast = CreatParam(listStoreParts[self.DataS.Format], true)
		
		local FolderDecor:Folder = self.self.Store:IsA("House") and self.self.Store.ParentObjects or self.self.Store.Decors
		local list = {}
		
		local function AddedDecor(Object)
			if self.DataS.PutInTable and self.DataS.Format=="Floors" then
				for _, basePart : BasePart in Object:GetChildren() do
					if basePart:IsA("BasePart") and basePart:GetAttribute("Table") then
						self.AreaPutRaycast:AddToFilter(basePart)
					end
				end
			end
			
			if self.DataS.Fusion and Object:GetAttribute("FusionKey") == self.DataS.FusionKey then
				table.insert(self.Fusions.Objects, Object)
			end
			
		end
		
		if self.DataS.Fusion then
			local OriginalModel,_,Models = self.self.serv.Stores.AddedDecor.Added.verificarExistencia(self.DataS.Data.Name)
			self.Fusions = {Objects = {}, Models = Models, OriginalModel = OriginalModel}
		end
		
		for _,Object:Model in FolderDecor:GetChildren() do
			if Object:IsA("Model") and ObjectPut~=Object then
				--table.insert(list, Object.PrimaryPart or Object:FindFirstChild("Primary"))
				AddedDecor(Object)
			end
		end
		self.DecorParams = CreatParam(list)
		
		local updating
		
		table.insert(self.actives, FolderDecor.ChildAdded:Connect(function(Object:Model)
			if Object:IsA("Model") and not table.find(self.DecorParams.FilterDescendantsInstances, Object) then
				AddedDecor(Object)
				if self.self.Store:IsA("Store") or Object:GetAttribute("OwnerPlace")==self.self.serv.Player.UserId then
					if not updating or tick()-updating > .2 then
						updating = tick()
						local Positions = {
							Vector3.new(1,0,0),
							Vector3.new(-1,0,0),
							self.DataS.Format=="Walls" and Vector3.new(0,1,0) or Vector3.new(0,0,1),
							self.DataS.Format=="Walls" and Vector3.new(0,-1,0) or Vector3.new(0,0,-1),
						}
						for _, Direction in Positions do
							local GoshPart = self.modelInProcess.PrimaryPart or self.modelInProcess:FindFirstChild("Primary")
							local Angle = CFrame.Angles(self.ModelChanges.Position:ToOrientation())
							local Position = self.ModelChanges.Position:PointToWorldSpace(Direction * GoshPart.Size)
							local Correction, IsEdited = self.Positions.GetPosition(GoshPart, CFrame.new(Position) * Angle, self.AreaPutRaycast, self.DecorParams, self.DataS.Format)
							if not IsEdited then
								return self:UpdatePosition(typeof(Correction)=="CFrame" and Correction.Position or Correction)
							end
						end
					end
				end
				
			end
		end))
		
		for _,v in listStoreParts.NoCollition do
			self.DecorParams:AddToFilter(v)
		end

	else
		
		self.DecorParams = nil
		self.AreaPutRaycast = nil
		if self.Fusions and self.Fusions.Conections then
			for _,Value in self.Fusions.Conections.Objects do
				if Value.FakeModel then
					debris:AddItem(Value.FakeModel, 0)
				end
			end
		end
		self.Fusions = nil
		
	end
end

function module:UpdatePosition(Position : Vector3)
	if not Position or not self.modelInProcess then return end
	local Angle = self.ModelChanges.Position - self.ModelChanges.Position.Position
	local GoshPart = self.modelInProcess.PrimaryPart or self.modelInProcess:FindFirstChild("Primary")
	local Correction = self.Positions.GetPosition(GoshPart, CFrame.new(Position) * Angle, self.AreaPutRaycast, self.DecorParams, self.DataS.Format)
	if not Correction then return end
	self.ModelChanges.Position = typeof(Correction)=="CFrame" and Correction or (CFrame.new(Correction) * Angle)
end

function module:SetFusion(ObjectFusion, Apoyo, FusionData)
	if self.FusionInProcess or not self.Fusions then return end
	local FusionIsModel = ObjectFusion == self.modelInProcess
	local GoshPart = self.modelInProcess.PrimaryPart or self.modelInProcess:FindFirstChild("Primary")
	
	local Ancle = FusionIsModel and Apoyo or ObjectFusion
	local Relative = Ancle:GetPivot():ToWorldSpace(FusionIsModel and FusionData.Value:Inverse() or FusionData.Value)
	local _, IsEditable = self.Positions.GetPosition(GoshPart, Relative, self.AreaPutRaycast, self.DecorParams, self.DataS.Format)
	
	if not IsEditable then
		self.FusionInProcess = {Name = FusionData.Name, Ancle = Ancle}
		local ModelChange = self.Fusions.Models[FusionData.Name]:Clone()
		self.FusionInProcess.Model = ModelChange
		self:SetCanCollide(ModelChange)
		self:SetChangedModel(ObjectFusion, ModelChange)
		ModelChange:PivotTo(ObjectFusion:GetPivot())
		if FusionIsModel then
			debris:AddItem(self.modelInProcess,0)
			self.modelInProcess = ModelChange
		elseif Apoyo ~= self.modelInProcess then
			if self.Fusions.Conections and
				self.Fusions.Conections.Objects[Apoyo] and
				self.Fusions.Conections.Objects[Apoyo].SaveOriginalModel then
				self.FusionInProcess.ObjectFusion = self.Fusions.Conections.Objects[Apoyo].SaveOriginalModel
				self.Fusions.Conections.Objects[Apoyo].SaveOriginalModel = nil
			else
				local saveList = {Model = Apoyo, Parent = Apoyo.Parent}
				self.FusionInProcess.ObjectFusion = saveList
				table.insert(self.saveDecor,saveList)
				Apoyo.Parent = script
			end
		else
			local changeModel = Apoyo ~= self.modelInProcess and Apoyo or not FusionIsModel and ObjectFusion
			if changeModel then
				
				if self.Fusions.Conections and
					self.Fusions.Conections.Objects[changeModel] and
					self.Fusions.Conections.Objects[changeModel].SaveOriginalModel then
					self.FusionInProcess.ObjectFusion = self.Fusions.Conections.Objects[changeModel].SaveOriginalModel
					self.Fusions.Conections.Objects[changeModel].SaveOriginalModel = nil
				else
					local saveList = {Model = changeModel, Parent = changeModel.Parent}
					self.FusionInProcess.ObjectFusion = saveList
					table.insert(self.saveDecor,saveList)
					changeModel.Parent = script
				end
				
			end
		end
		ModelChange.Parent = workspace
		if FusionIsModel then
			self.highlight.Adornee = ModelChange
			self.gui.Adornee = ModelChange.PrimaryPart or ModelChange:FindFirstChild("Primary")
		end
		return true
	end
	
end

function module:Running(delta)
	if self.modelInProcess and self.ModelChanges then
		
		if self.CursorPosition then
			local GoshPart = self.modelInProcess.PrimaryPart or self.modelInProcess:FindFirstChild("Primary")
			local Position = self.CursorPosition.Position
			local ScreenRay:Ray = self.self.serv.Camera:ViewportPointToRay(Position.X, Position.Y)
			local Raycast = workspace:Raycast(ScreenRay.Origin, ScreenRay.Direction * 200, self.CursorPosition.Params)
			if Raycast then
				self:UpdatePosition(Raycast.Position + Raycast.Normal)
			end
		end
		
		if self.DataS.Fusion and self.Fusions then
			if self.FusionInProcess then
				local Position1 = self.FusionInProcess.Model==self.modelInProcess and self.ModelChanges.Position
					or self.FusionInProcess.Model:GetPivot()
				local Position2 = self.FusionInProcess.Model==self.modelInProcess and self.FusionInProcess.Ancle:GetPivot()
					or self.ModelChanges.Position
				local fusionUpdate = self.Positions.GetFusion(Position1,Position2, self.DataS.Fusion)
				if not fusionUpdate or fusionUpdate.Name ~= self.FusionInProcess.Name then
					if self.FusionInProcess.Model==self.modelInProcess then
						local newModel = self.Fusions.OriginalModel:Clone()
						newModel:PivotTo(self.modelInProcess:GetPivot())
						self:SetCanCollide(newModel)
						self:SetChangedModel(self.modelInProcess, newModel)
						newModel.Parent = self.modelInProcess.Parent
						debris:AddItem(self.modelInProcess,0)
						self.modelInProcess = newModel
						self.highlight.Adornee = newModel
						self.gui.Adornee = newModel.PrimaryPart or newModel:FindFirstChild("Primary")
					else
						debris:AddItem(self.FusionInProcess.Model,0)
					end
					if self.FusionInProcess.ObjectFusion then
						if self.FusionInProcess.ObjectFusion.Model:IsDescendantOf(game) then
							self.FusionInProcess.ObjectFusion.Model.Parent = self.FusionInProcess.ObjectFusion.Parent
						end
						table.remove(self.saveDecor, table.find(self.saveDecor, self.FusionInProcess.ObjectFusion))
					end
					self.FusionInProcess = nil
				else
					local FusionIsModel = self.FusionInProcess.Model == self.modelInProcess
					local Relative = self.FusionInProcess.Ancle:GetPivot():ToWorldSpace(FusionIsModel and fusionUpdate.Value:Inverse() or fusionUpdate.Value)
					delta = 1/20
					self.ModelChanges.Position = Relative
				end
			elseif #self.Fusions.Objects > 0 then
				for _,object in self.Fusions.Objects do
					if not object:IsDescendantOf(game) then continue end
					local EditFusion = self.DataS.IsFusionable and self.Positions.GetFusion(self.ModelChanges.Position, object:GetPivot(), self.DataS.Fusion)
					if EditFusion then
						if self:SetFusion(self.modelInProcess, object, EditFusion) then
							break
						end
					elseif object:GetAttribute("IsFusionable")
						and (not object:GetAttribute("IsFusion") or (self.Fusions.Conections and self.Fusions.Conections.Objects[object])) then
						local ObjectFusion = self.Positions.GetFusion(object:GetPivot(), self.ModelChanges.Position, self.DataS.Fusion)
						if ObjectFusion and object:GetAttribute("IsFusion")~=ObjectFusion.Name then
							if self:SetFusion(object, self.modelInProcess, ObjectFusion) then
								break
							end
						end
					end
					for _,v in {Vector3.new(1,0,0), Vector3.new(-1,0,0)} do
						local Position = object:GetPivot():ToWorldSpace(CFrame.new(v * object.PrimaryPart.Size))
						if self.Positions.IsInArea(Position, self.ModelChanges.Position) then
							delta = 1/20
							self.ModelChanges.Position = Position
							break
						end
					end
				end
			end
			--Actualizar al resto LOL
			if not self.FusionInProcess and self.Fusions.Conections then
				if self.Positions.IsInArea(self.ModelChanges.Position, self.Fusions.Conections.Position) then
					delta = 1/20
					self.ModelChanges.Position = self.Fusions.Conections.Position
				end
			end
			
			if self.Fusions.Conections then
				for ObjectFusion, Value in self.Fusions.Conections.Objects do
					
					if self.Fusions.Conections.Position ~= self.ModelChanges.Position then
						if not Value.SaveOriginalModel then
							Value.SaveOriginalModel = {Model = ObjectFusion, Parent = ObjectFusion.Parent}
							ObjectFusion.Parent = script
							table.insert(self.saveDecor, Value.SaveOriginalModel)
						end
						if not Value.FakeModel then
							local clone = Value.orm:Clone()
							self:SetCanCollide(clone)
							self:SetChangedModel(ObjectFusion, clone)
							clone:PivotTo(ObjectFusion:GetPivot())
							clone.Parent = workspace
							Value.FakeModel = clone
						end
					else
						if Value.SaveOriginalModel then
							if Value.SaveOriginalModel.Model:IsDescendantOf(game) then
								Value.SaveOriginalModel.Model.Parent = Value.SaveOriginalModel.Parent
							end
							table.remove(self.saveDecor, table.find(self.saveDecor, Value.SaveOriginalModel))
							Value.SaveOriginalModel = nil
						end
						if Value.FakeModel then
							debris:AddItem(Value.FakeModel, 0)
							Value.FakeModel = nil
						end
					end
				end
			end
		end
		
		delta *= 20
		self.modelInProcess:PivotTo(self.modelInProcess:GetPivot():Lerp(self.ModelChanges.Position, delta))
		
		if self.ModelsPutTable then
			for _, object in self.ModelsPutTable do
				local NewCFrame = CFrame.new(object.calculePosition * self.modelInProcess.PrimaryPart.Size) * CFrame.Angles(table.unpack(object.Orientation))
				local newPosition = self.modelInProcess:GetPivot():ToWorldSpace(NewCFrame) + Vector3.new(0,object.Model.PrimaryPart.Size.Y/2,0)
				object.Model:PivotTo(newPosition)
				object.ChangesList.Position = newPosition
			end
		end
		
		local Aviable = self.self.Store.CountBuilds<self.self.serv.Stores.MaxBuildPlace or
			typeof(self.Enabled)=="table" and (not self.Enabled.IsA or self.Enabled.Disabled)
		local Color = Aviable and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(76, 76, 76)
		
		self.gui.InteractiveIcons.AceptButton.BackgroundColor3 = Color
		self.gui.InteractiveIcons.AceptButton.ImageColor3 = Color
		self.gui.InteractiveIcons.AceptButton.Interactable = not not Aviable
		
	end
end

function module:SetCanCollide(modelInProcess)
	modelInProcess = modelInProcess or self.modelInProcess
	if modelInProcess then
		for _,part:BasePart in modelInProcess:GetDescendants() do
			if part:IsA("BasePart") then
				part.CanCollide = false
				part.CanQuery = false
			end
		end
	end
end

function module:Added()
	if self.Enabled and not self.modelInProcess then
		
		local Model : Model = typeof(self.Enabled)=="Instance"
			and self.Enabled:IsA("Model") and self.Enabled:FindFirstChild("Settings")
			and self.Enabled
		
		local Data = Model and require(Model:FindFirstChild("Settings"))
		
		if not Model and typeof(self.Enabled)=="table" then
			
			if typeof(self.Enabled.IsA) == "function" then 
				if self.Enabled:IsA("Decors") then
					Model = self.Enabled:GetDataSection()
					Data = Model and Model.Info
					Model = Model and Model.Model
				elseif self.Enabled:IsA("Decor") then
					Model = self.Enabled.Disabled or self.Enabled.Model
					Data = self.Enabled.Data
				end
			elseif self.Enabled.Boolean and self.Enabled.Model then
				Model = self.Enabled.Model
				_,Data = self.self.serv.Stores.AddedDecor.Added.verificarExistencia(self.Enabled.Boolean.Name)
			end
			
		end
		
		if Model and Data then

			self.DataS = Data
			local modelClone, Position
			
			if self.Enabled.IsA and self.Enabled:IsA("Decor") then
				modelClone = self.Enabled.Model
			elseif not self.Enabled.IsA then
				modelClone = self.self.serv.Stores.AddedDecor.Added.verificarExistencia(self.Enabled.Boolean.Name)
			end
			
			if typeof(self.Enabled)=="table" then
				
				local modeloSave = (self.Enabled.IsA and self.Enabled:IsA("Decor") and self.Enabled.Disabled) or
					not self.Enabled.IsA and self.Enabled.Model

				self:RaycastSections(modeloSave)
				
				if modeloSave then
					
					if modeloSave:GetAttribute("IsFusion") then
						local OriginalModel,_,fusionModels = self.self.serv.Stores.AddedDecor.Added.verificarExistencia(modeloSave.Name)
						modelClone = fusionModels[modeloSave:GetAttribute("IsFusion")] or OriginalModel
					end
					
					table.insert(self.saveDecor,{
						Model = modeloSave,
						Parent = modeloSave.Parent,
					})
					Position = modeloSave:GetPivot()
					
					local listTable:RaycastParams
					for _,v in modeloSave:GetChildren() do
						if v:IsA("BasePart") and v:GetAttribute("Table") then
							if not listTable then
								listTable = {v}
							else
								table.insert(listTable, v)
							end
						end
					end
					
					local listTableParams
					if listTable then
						listTableParams = RaycastParams.new()
						listTableParams.FilterType = Enum.RaycastFilterType.Include
						listTableParams.FilterDescendantsInstances = listTable
					end
					
					if listTableParams or self.DataS.Fusion then
						local listObjects = self.self.Store:IsA("Store") and self.self.Store.DecorChild:GetDescendants() or self.self.Store.DecorChild
						
						local function AddedFusion(Extra, Object)
							if not self.Fusions then return end
							local ModelObject:Model = typeof(Extra)=="Instance" and Object or Object.Disabled
							local Boolean:BoolValue = typeof(Extra)=="Instance" and Extra or Object.Boolean
							
							local DataFusion = Boolean:IsDescendantOf(game) and typeof(Extra)=="Instance"
								and self.self.serv.Stores:GetInfoDecordataByBoolean(Boolean) or Object:GetData()

							local FusionKey = DataFusion and typeof(DataFusion.FusionWith) == "string" and string.split(DataFusion.FusionWith)
							FusionKey = FusionKey and FusionKey[2]
							
							if not self.Fusions.Conections then
								if ModelObject and (FusionKey and FusionKey==self.Enabled.Boolean:GetAttribute("UnniqueKey")) then

									local orm,_ = self.self.serv.Stores.AddedDecor.Added.verificarExistencia(Boolean.Name)
									
									self.Fusions.Conections = {
										Position = Position,
										Objects = {[ModelObject] = {Boolean = Boolean, DataFusion = DataFusion, Model = ModelObject, orm = orm}},
									}
								end
							else
								local Done
								for index, conection in self.Fusions.Conections.Objects do
									if conection.Boolean == Boolean then
										if ModelObject and (FusionKey and FusionKey==self.Enabled.Boolean:GetAttribute("UnniqueKey")) then
											self.Fusions.Conections.Objects[index] = nil
											conection.DataFusion = DataFusion
											conection.Model = ModelObject
											self.Fusions.Conections.Objects[ModelObject] = conection
										else
											if conection.FakeModel then
												debris:AddItem(conection.FakeModel, 0)
											end
											if conection.SaveOriginalModel then
												if conection.SaveOriginalModel.Model:IsDescendantOf(game) then
													conection.SaveOriginalModel.Model.Parent = conection.SaveOriginalModel.Parent
												end
												table.remove(self.saveDecor, table.find(self.saveDecor, conection.SaveOriginalModel))
												conection.SaveOriginalModel = nil
											end
											self.Fusions.Conections.Objects[index] = nil
										end
										Done = true
									end
								end
								if not Done and (FusionKey and FusionKey==self.Enabled.Boolean:GetAttribute("UnniqueKey")) then
									self.Fusions.Conections.Objects[ModelObject] = {Boolean = Boolean, DataFusion = DataFusion, Model = ModelObject}
								end
							end

							if Boolean:IsDescendantOf(game) and typeof(Object)=="table" and Object:IsA("Decor") then
								local UnniqueKey = Boolean:GetAttribute("UnniqueKey")
								if not self.actives[UnniqueKey] then
									self.actives[UnniqueKey] = Boolean:GetAttributeChangedSignal("FusionWith"):Connect(function()
										AddedFusion(Extra, Object)
									end)
									self.actives[UnniqueKey.."Deleted"] = Boolean.AncestryChanged:Connect(function(_,Parent)
										if Parent then return end
										self.self.serv.ElimineGroupActive(self.actives,{UnniqueKey, UnniqueKey.."Deleted"})
									end)
								end
							end
							
						end
						
						for Extra, Object in listObjects do
							local ModelObject:Model = typeof(Extra)=="Instance" and Object or Object.Disabled
							if not ModelObject then continue end
							
							local Boolean:BoolValue = typeof(Extra)=="Instance" and Extra or Object.Boolean
							local baseModel, DataObject = self.self.serv.Stores.AddedDecor.Added.verificarExistencia(ModelObject.Name)

							if ModelObject~=modeloSave and DataObject then
								if DataObject.PutInTable then
									if not listTableParams then continue end
									local ray = workspace:Raycast(ModelObject:GetPivot().Position, Vector3.new(0,-50,0), listTableParams)
									if ray then
										table.insert(self.saveDecor,{
											Model = ModelObject,
											Parent = ModelObject.Parent,
										})
										local lisNewClone = {
											Boolean = Boolean,
											Model = baseModel:Clone(),
											Orientation = {Position:ToObjectSpace(ModelObject:GetPivot()):ToOrientation()}
										}
										lisNewClone.Model:PivotTo(ModelObject:GetPivot())
										lisNewClone.Model.Parent = workspace
										lisNewClone.ChangesList = self:SetChangedModel(ModelObject, lisNewClone.Model)
										self:SetCanCollide(lisNewClone.Model)
										local calculePosition = Position:PointToObjectSpace(ray.Position) / modeloSave.PrimaryPart.Size
										lisNewClone.calculePosition = calculePosition
										if not self.ModelsPutTable then
											self.ModelsPutTable = {lisNewClone}
										else
											table.insert(self.ModelsPutTable, lisNewClone)
										end
										ModelObject.Parent = script
									end
									
								elseif self.Fusions and DataObject.Fusion --[[and self.DataS.Data.Name==DataObject.Data.Name]] then
									AddedFusion(Extra, Object)
								end
							end

						end
						
						if self.DataS.Fusion then
							if self.self.Store:IsA("Store") then
								table.insert(self.actives, self.self.Store.DecorChild:Find(self.DataS.Data.Name).ChildAdded:Connect(function(Decor)
									local Object = self.self.serv.Stores:GetDecorPlayer(Decor)
									if Object then
										AddedFusion(nil, Object)
									end
								end))
							else
								table.insert(self.actives, self.self.Store.DecorChanged:Connect(function(Decor)
									AddedFusion(Decor, self.self.Store.DecorChild[Decor])
								end))
							end
							
						end
					end

					modeloSave.Parent = script
				end
				
			else
				
				self:RaycastSections()
				
			end
			
			if not Position then
				local InitialPosition = CFrame.new(game:GetService("Players").LocalPlayer.Character:GetPivot().Position)
				local AngleInitial = CFrame.Angles(0,self.self.Store.AngleBase,0)
				local Correction = self.Positions.GetPosition(Model.PrimaryPart or Model:FindFirstChild("Primary"),
					InitialPosition*AngleInitial, self.AreaPutRaycast, self.DecorParams, self.DataS.Format)
				Position = Correction and (typeof(Correction)=="CFrame" and Correction or CFrame.new(Correction))
			end
			
			modelClone = modelClone and modelClone:Clone() or Model:Clone()
			debris:AddItem(modelClone:FindFirstChild("Settings"), 0)
			
			modelClone:PivotTo(Position)
			modelClone.Parent = workspace
			
			self.gui.Enabled = true
			self.highlight.Adornee = modelClone
			self.gui.Adornee = modelClone.PrimaryPart or modelClone:FindFirstChild("Primary")
			
			self.modelInProcess = modelClone
			self:SetCanCollide(self.modelInProcess)
			self.ModelChanges = self:SetChangedModel(Model)
			self:ActiveGui()
			
			return true
		end
	end
end

function module:BackToClose()
	if self.Enabled then
		if self.actives.MoveItEnd then
			self:MoveIt()
		elseif self.actives.ChangeCA then
			self:CloseChangeAmount()
		elseif self.self.Colors.Enabled then
			self.self.Colors:Destroy()
		else
			self:index()
		end
	end
end
function module:Destroy()
	if self.Enabled then
		self:index()
	elseif self.modelInProcess then
		self.highlight.Adornee = nil
		self.gui.Adornee = nil
		self.gui.Enabled = false
		debris:AddItem(self.modelInProcess,0)
		self.modelInProcess = nil
	end
end

return module
