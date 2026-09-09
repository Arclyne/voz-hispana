local module = {}
module.__index = module

IsClient = game:GetService('RunService'):IsClient()
rs = game:GetService('ReplicatedStorage')
events = rs:WaitForChild('Events'):WaitForChild('Decors')
debris = game:GetService('Debris')
local Collitions = require(script:WaitForChild("Collitions"))
local EventCustom = require(rs:WaitForChild("Client"):WaitForChild("Event"))
local SignalsGame = require(rs:WaitForChild("Shared"):WaitForChild("SignalsGame"))

local HTTPS : HttpService = not IsClient and game:GetService("HttpService")

local listExistent = {}
local IsA = "Decor"

module.Positions = require(rs:WaitForChild("Client"):WaitForChild("Posicionamientos"))

function module.verificarExistencia(NameObject, metadata)
	if typeof(NameObject) == "string" then
		local search = listExistent[NameObject]
		if search then
			if typeof(metadata) == "table" then
				metadata.Model = search.Model
				metadata.Data = search.Data
				metadata.FusionModels = search.FusionModels
			else
				return search.Model, search.Data, search.FusionModels
			end
		else
			search = rs:FindFirstChild('decoration template'):FindFirstChild(NameObject) or
				(rs:FindFirstChild("Assets"):FindFirstChild("ToolsModels"):FindFirstChild(NameObject))
			
			if search and search:FindFirstChild("Settings") then
				local list = {
					Model = search,
					Data = require(search:FindFirstChild("Settings")),
				}
				if list.Data.Fusion then
					list.FusionModels = {}
					for _,v in list.Data.Fusion do
						local model = rs:FindFirstChild("Assets"):FindFirstChild("VariableBuilds"):FindFirstChild(v.Name)
						if model then
							list.FusionModels[v.Name] = model
						end
					end
				end
				listExistent[NameObject] = list
				return module.verificarExistencia(NameObject, metadata)
			end
			
		end
	end
end

function module.new(Boolean : BoolValue,Owner)
	if not Boolean or not module.verificarExistencia(Boolean.Name) then return end	
	Owner = IsClient and game:GetService('Players').LocalPlayer or Owner
	
	local self = setmetatable({
		Boolean = Boolean,
		
		Owner = (typeof(Owner)=="number" and Owner)
			or (typeof(Owner)=="Instance" and Owner:IsA("Player")
				and (Boolean:IsDescendantOf(Owner) and Owner or Owner.UserId)) or 0,
		
		Disabled = false,
		Decor = true,
		actives = {},
		
		IsStart = true,
		
	}, module)
	
	module.verificarExistencia(Boolean.Name, self)
	
	if IsClient then
		self.DisabledChanged = EventCustom.new()
	else
		if typeof(self.Owner)=="number" then
			Boolean:SetAttribute("OwnerPlace", self.Owner)
		end
		if not Boolean:GetAttribute("UnniqueKey") then
			Boolean:SetAttribute("UnniqueKey", HTTPS:GenerateGUID(true))
		end
		self.DataUpdating = EventCustom.new()
	end
	
	self.IsHouseData = typeof(self.Owner) == "number"
	self.UnniqueKey = Boolean:GetAttribute("UnniqueKey")
	
	return self
end

function module:desactive(...)
	if not self.actives then return end
	local Datas = {...}
	if #Datas > 0 then
		for _,v in Datas do
			if self.actives[v] then
				self.actives[v]:Disconnect()
				self.actives[v] = nil
			end
		end
	else
		for _,v in self.actives do
			v:Disconnect()
		end
		table.clear(self.actives)
	end
end
function module:IsA(t) return t == IsA end

function module:UpdateData(NoUpdate)
	if not IsClient and self.Disabled and self.ParentStore then
		local posi = self.ParentStore:IsA("Store") and self.ParentStore.CFrameBase:ToObjectSpace(self.Disabled:GetPivot())
			or self.Disabled:GetPivot()
		
		local data:BoolValue = self.ParentStore:IsA("Store") and self.Boolean:FindFirstChild(self.ParentStore.Occuped.Name)
			or self.ParentStore:IsA("House") and self.Boolean
		
		if not data then
			data = self.AddItem(self.ParentStore.Occuped.Name,true)
			data.Parent = self.Boolean
		end
		
		data:SetAttribute('Position', posi)
		data:SetAttribute('Scale', self.Disabled:GetScale())
		data:SetAttribute("FusionWith", self.Disabled:GetAttribute("FusionWith"))
		
		local IsOn = self.Disabled:GetAttribute("IsOn")
		if IsOn~=nil and self.Data.tag and table.find({"Lamp","Interruptor"}, self.Data.tag) then
			local LastIsOn = data:GetAttribute("IsOn")
			data:SetAttribute("IsOn", IsOn)
			if self.Data.tag=="Lamp" and not NoUpdate then
				SignalsGame:Fire("ChangeLamp", self.Disabled, IsOn)
			end
		end
		
		for _,part:BasePart in self.Disabled:GetChildren() do
			if not part:IsA("BasePart") then continue end
			local NamePart = part.Name:lower()
			local IsLightColor = part.Name=="LightColor"
			if part:IsA("BasePart") and (IsLightColor or string.match(NamePart, "color")
				and tonumber(string.sub(NamePart,#NamePart))) then
				local LastData = data:GetAttribute(part.Name)
				data:SetAttribute(part.Name, part.Color)
				if IsLightColor and not NoUpdate then
					SignalsGame:Fire("ChangeLamp", self.Disabled, part.Color)
				end
			end
		end
		
		if self.Data.IsTool then
			data:SetAttribute("inventory", self.Disabled:GetAttribute("inventory"))
			data:SetAttribute("owner", self.Disabled:GetAttribute("owner"))
		end
		
		if not self.IsStart then
			self.DataUpdating:Fire()
		else
			self.IsStart = false
		end
		
	end
end

function module:GetData()
	if self.ParentStore and (self.ParentStore:IsA("House") or self.ParentStore.Occuped) then
		local DataStore:BoolValue = self.ParentStore:IsA("House") and self.Boolean or self.Boolean:FindFirstChild(self.ParentStore.Occuped.Name)
		if DataStore then
			local DataLoad = DataStore:GetAttributes()
			DataLoad.Position = self.ParentStore:IsA("House")
				and DataLoad.Position or self.ParentStore.CFrameBase:ToWorldSpace(DataLoad.Position)
			local Colors = {}
			for index,value in DataLoad do
				if string.match(index:lower(),'color') and typeof(value) == 'Color3' then
					table.insert(Colors,{Name = index, Color = value})
					DataLoad[index] = nil
				end
			end
			DataLoad.Colors = Colors
			return DataLoad, DataStore
		end
	end
end

function module:BindModelToClose(fun)
	self.bindActionfunct = typeof(fun)=="function" and fun or self.bindActionfunct
end

function module:Update(Data, server)
	if IsClient then
		if not server then
			events:WaitForChild('Update'):FireServer(self.Boolean, Data)
		else
			local lastData = self.Disabled
			self.Disabled = typeof(Data)=="Instance" and Data:IsA("Model") and Data
			if lastData ~= self.Disabled then
				if self.Disabled then Collitions[self.Disabled.Name](self) end
				self.DisabledChanged:Fire()
			end
		end
	elseif typeof(Data) == 'table' and ((not self.Disabled and typeof(Data.Position)=="CFrame") or self.Disabled) then
		Data.Scale = self.Positions.GetScale(Data.Scale or (self.Disabled or self.Model):GetScale(), self.Data.Scale)

		local model, fusion = self:fusiones(Data)

		if not model then

			if self.Disabled then
				self.IsTagAdded = nil
				self:desactive("disabledRemoved")
				self.Disabled:Destroy()
				debris:AddItem(self.Disabled,0)
			elseif self.ParentStore then
				self.ParentStore.CountBuilds += 1
			end

			model = (fusion or self.Model):Clone()
			if fusion then
				model:SetAttribute("IsFusion", model.Name)
				model:SetAttribute("FusionWith", Data.FusionWith)
				model.Name = self.Model.Name
			end

			model:SetAttribute("IsFusionable", self.Data.IsFusionable)
			model:SetAttribute("FusionKey", self.Data.FusionKey)
			model:SetAttribute("IsToStoreSystem", true)
			
			debris:AddItem(model:FindFirstChild('Settings'),0)

			if self.Data.IsTool then
				model:SetAttribute("inventory", Data.inventory)
				model:SetAttribute("owner", Data.owner)
			end

			model.Parent = rs

			self.actives.disabledRemoved = model.AncestryChanged:Connect(function(_,parent)
				if parent then return end
				self:desactive("disabledRemoved")
				if self.ParentStore and self.ParentStore:IsA("Store") and self.ParentStore.Occuped then
					local DataObject = self.Boolean:FindFirstChild(self.ParentStore.Occuped.Name)
					if DataObject then DataObject:Destroy() end
				end
				if self.bindActionfunct then pcall(self.bindActionfunct) end
				self.bindActionfunct = nil
			end)

			self.Disabled = model

			if self.Data.IsProductPurchase and self.ComprasFunct then
				self.ComprasFunct:Works()
			end

			if typeof(self.Owner) == "number" then
				self.Disabled:SetAttribute("OwnerPlace", self.Owner)
				events:FindFirstChild("GetDecor"):FireAllClients(self.Boolean, model)
			else
				events:FindFirstChild('Update'):FireClient(self.Owner,self.Boolean,model,true)
			end

		end
		
		model:PivotTo(Data.Position or model:GetPivot())
		if not self.Data.NoScale then model:ScaleTo(Data.Scale) end
		
		if typeof(Data.Colors) == 'table' then
			for _,ColorData in Data.Colors do
				if ColorData.Name~="LightColor" and not tonumber(string.sub(ColorData.Name,#ColorData.Name)) then continue end
				local Part:BasePart = model:FindFirstChild(ColorData.Name, true)
				if Part and Part:IsA('BasePart') then
					local Color = typeof(ColorData.Color) == 'Color3' and ColorData.Color or Color3.new(1, 1, 1)
					Part.Color = Color
				end
			end
		end
		
		if Data.IsOn~=nil and self.Data.tag and table.find({"Lamp","Interruptor"}, self.Data.tag) then
			model:SetAttribute("IsOn", Data.IsOn)
		end
		
		self:UpdateData()
		
		return model
	else
		self:Delete()
	end
end

function module:Delete()
	if IsClient then
		events:WaitForChild('Delete'):FireServer(self.Boolean)
	elseif self.Disabled then
		debris:AddItem(self.Disabled,0)
		self.IsTagAdded = nil
		self.Disabled = nil
		if self.ComprasFunct then self.ComprasFunct:destroy() end
		if self.ParentStore and (self.ParentStore:IsA("House") or self.ParentStore.Occuped) then
			self.ParentStore.CountBuilds -= 1
		end
	elseif typeof(self.Owner) ~= "number" then
		events:WaitForChild('Update'):FireClient(self.Owner,self.Boolean,false,true)
	end
end

function module:Sell()
	if IsClient then
		events:FindFirstChild("SellDecor"):FireServer(self.Boolean)
	end
end

function module:fusiones(Data)
	if self.ParentStore then
		if self.Data.Fusion and self.Data.IsFusionable and Data.FusionWith then
			local VariablesModels = rs:FindFirstChild("Assets"):FindFirstChild("VariableBuilds")
			local tablsString = typeof(Data.FusionWith) == "string" and string.split(Data.FusionWith, ",")
			if tablsString and #tablsString == 2 then
				local Builds = self.ParentStore.DecorChild[tablsString[1]]
				if Builds then
					for _,Object in Builds do
						if Object.UnniqueKey ~= tablsString[2] then continue end
						Object.ParentStore = Object.ParentStore==self.ParentStore and Object.ParentStore or self.ParentStore
						local DataPosition = Object:GetData()
						if DataPosition then
							local Vinculacion = module.Positions.GetFusion(Data.Position, DataPosition.Position, self.Data.Fusion)
							if Vinculacion then
								return not not (self.Disabled and self.Disabled:GetAttribute("IsFusion")==Vinculacion.Name) and self.Disabled,
									VariablesModels:FindFirstChild(Vinculacion.Name)
							end
						end
					end
				end
			end
		end
	end
	return not not (self.Disabled and not self.Disabled:GetAttribute("IsFusion")) and self.Disabled
end

return module
