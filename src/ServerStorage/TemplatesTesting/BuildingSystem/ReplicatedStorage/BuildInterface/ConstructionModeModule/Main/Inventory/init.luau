local module = {}
module.__index = module

local debris = game:GetService("Debris")
local template = script:FindFirstChild("Template")

function module.new(metatable)
	local self = setmetatable({}, module)
	self.self = metatable
	self.gui = metatable.gui.Main.Sections.Inventory
	self.Objects = {}
	return self
end

function module:Open()
	if not self.actives then

		self.actives = {}
		self.gui.Visible = true
		self.Button:Select(true)
		
		table.insert(self.actives, self.gui.TopBar.SearchText:GetPropertyChangedSignal("Text"):Connect(function()
			self:ordenar(self:filtrarTexto(self.gui.TopBar.SearchText.Text))
		end))
		
		local Decors = self.self.self.serv.Stores.DecorsPlayer
		
		local function UpdateNoInventory()
			for _, option in Decors:Get() do
				if #option:GetChildren(false) > 0 then
					self.gui.TextLabel.Visible = false
					return
				end
			end
			self.gui.TextLabel.Visible = true
		end
		
		if Decors.Count > 0 then
			for name, option in Decors:Get() do
				self:AddObject(name, option)
			end
			UpdateNoInventory()
		else
			self.gui.TextLabel.Visible = true
		end
		
		table.insert(self.actives, Decors.ChildAdded:Connect(function(name)
			self:AddObject(name, Decors:Find(name))
			UpdateNoInventory()
		end))
		
		table.insert(self.actives, Decors.ChildRemoved:Connect(function(name)
			self:RemoveObject(name)
			UpdateNoInventory()
		end))
		
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
		
		return true
	end
end
function module:AddObject(NameObject, list)
	if not self.actives then return end
	
	if typeof(NameObject)=='string' and typeof(list)=="table" then
		local dataAll = self.Objects[NameObject]
		if not dataAll then
			local clone = template:Clone()
			local animator = self.self.self.serv.ButtonAnimator.new(clone:FindFirstChild("Button"))
			
			animator:EnterAction(nil, {
				Size = UDim2.fromScale(.9, .9),
				BackgroundColor3 = Color3.new(0.584314, 0.584314, 0.584314),
			})
			animator:DownAction(nil, {
				Size = UDim2.fromScale(.75, .75),
			})
			animator:AddEffectSound("Click", 139037694620957)
			
			dataAll = {self = list, gui = clone, animator = animator, DataComplete = false, IsIconCreated = false}
			self.actives[NameObject.."_added"] = list.ChildAdded:Connect(function() self:AddObject(NameObject, list) end)
			self.actives[NameObject.."_removed"] = list.ChildRemoved:Connect(function() self:AddObject(NameObject, list) end)
			self.actives[NameObject.."_Changed"] = list.ChildChanged:Connect(function() self:AddObject(NameObject, list) end)
			
			self.Objects[NameObject] = dataAll
			self:AddObject(NameObject, list)
		else
			local infoModel = dataAll.self:GetDataSection()
			local countChild = dataAll.self:GetChildren(false)
			
			if infoModel then
				
				dataAll.DataComplete = #countChild > 0
				
				if #countChild > 0 then
					
					dataAll.gui.Button.NameProduct.Text = infoModel.Info.Gui.Name
					dataAll.gui.Button.AmountBack.AmountText.Text = string.format("X%d", #countChild)
					dataAll.gui.Button.AmountBack.AmountText.Visible = #countChild > 1
					dataAll.gui.Button.AmountBack.Start.Visible = not not infoModel.Info.tag
					
					if not dataAll.IsIconCreated then
						dataAll.IsIconCreated = self:CreateIcon(infoModel.Model, dataAll.gui.Button.ViewportFrame)
					end

					dataAll.gui.Parent = self.gui.Products

					self.actives[NameObject.."MouseClick"] = self.actives[NameObject.."MouseClick"] or dataAll.animator:Connect(function()
						self.self.self.MoveAndPlace:index(dataAll.self)
					end)
					
				else

					dataAll.gui.Parent = script
					self.self.self.serv.ElimineOnlyActive(self.actives,NameObject.."MouseClick")
					
				end
				
				
			end
		end
	end
	
end
function module:RemoveObject(NameObject)
	if typeof(NameObject)=='string' and self.Objects[NameObject] then
		if self.actives then
			self.self.self.serv.ElimineGroupActive(self.actives,{NameObject.."_added", NameObject.."_removed", NameObject.."MouseClick"})
		end
		debris:AddItem(self.Objects[NameObject].gui, 0)
		self.Objects[NameObject] = nil
	end
end
function module:ClearObjects()
	for name, _ in self.Objects do
		self:RemoveObject(name)
	end
end

function module:Close()
	if self.actives then
		self.actives = self.self.self.serv.ElimineActive(self.actives)
		self.gui.Visible = false
		self.Button:UnSelect(true)
		self:ClearObjects()
	end
end
function module:filtrarTexto(Text:string)
	if typeof(Text) == 'string' and #Text > 0 then
		local EliminarEspacios = Text:match("^%s*(.-)%s*$")
		return #EliminarEspacios > 0 and string.lower(EliminarEspacios)
	end
end
function module:ordenar(TextOrder)
	for name, object in self.Objects do
		object.gui.Visible = not not (not TextOrder or string.match(string.lower(name), TextOrder))
	end
end
function module:init()
	
end

return module
