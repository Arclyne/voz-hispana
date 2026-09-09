local module = {}
module.__index = module

local Client = game:GetService('RunService'):IsClient()
local LocalPlayer = Client and game:GetService("Players").LocalPlayer
local IsA = "House"

local RS = game:GetService('ReplicatedStorage')
local Events = RS:WaitForChild('Events'):WaitForChild('Stores')
local Changes = require(script.Parent:WaitForChild('ColorTexture'))

local DataBaseHouseLoaded = not Client and Instance.new("BindableEvent") or nil
local UpdateLugarJugador = Client and Instance.new("BindableEvent") or nil
local breackdownValues = require(RS:FindFirstChild("Shared"):FindFirstChild("BreakDown"))
local EventCustom = require(RS:WaitForChild("Client"):WaitForChild("Event"))

local metatable

function module.new()
	if metatable then return metatable end
	local self = setmetatable({}, module)
	self.Base = workspace:WaitForChild("Casa")
	self.AngleBase = 0
	self.DecorChild = {}
	self.DataBaseLoaded = DataBaseHouseLoaded and DataBaseHouseLoaded.Event or nil
	self.ChangeRoom = UpdateLugarJugador and UpdateLugarJugador.Event or nil
	
	self.DecorChanged = Client and EventCustom.new()
	self.CountBuilds = 0
	
	self:init()
	metatable = self
	return self
end

function module:IsA(n) return n==IsA end

function module:AddToFilter()
	local list = {}
	
	if Client then
		for index, object in self.DecorChild do
			if object then
				table.insert(list, object)
			end
		end
	else
		for _,section in self.DecorChild do
			for _,object in section.Childs do
				if object.Disabled then
					table.insert(list, object.Disabled)
				end
			end
		end
	end

	local param = RaycastParams.new()
	param.FilterType = Enum.RaycastFilterType.Include
	param.FilterDescendantsInstances = list
	param.IgnoreWater = true

	return param
end

function module:GetData(ClientData)
	if not Client then
		if not self.DataBaseHouse then
			if self.InProccesSearched then return end
			local WorldService = game:GetService("ServerScriptService"):WaitForChild("WorldService")
			if WorldService then
				WorldService = require(WorldService)
				self.DataBaseHouse = WorldService.GetInstance()
				if not self.DataBaseHouse then
					warn("no se ha encontrado la instancia del data")
					self.InProccesSearched = task.spawn(function()
						local ti = tick()
						repeat task.wait(.2)
							warn("Buscando instancia del data...")
							self.DataBaseHouse = WorldService.GetInstance()
						until self.DataBaseHouse or (tick() - ti) >= 60
						self.InProccesSearched = nil
						if not self.DataBaseHouse then
							warn("No se encontró la instancia, error en la busqueda")
						else
							warn("Busqueda encontrada con exito")
							DataBaseHouseLoaded:Fire()
							self:GetData()
						end
					end)
				else
					DataBaseHouseLoaded:Fire()
					self:GetData()
				end
			else
				warn("No existe el modelo 'WorldService'.")
			end
		else
			local DataClient = {
				Permisos = self.DataBaseHouse:GetStoreData("WorldRolesStore") or {},
				Owner = tonumber(self.DataBaseHouse.OwnerId),
				Desing = self:GetColorAndTexture(not ClientData),
			}
			
			if ClientData then
				Events:FindFirstChild("GetInfoHouse"):FireClient(ClientData, DataClient)
			else
				Events:FindFirstChild("GetInfoHouse"):FireAllClients(DataClient)
			end
			
			self:DataChanged()
		end
	elseif ClientData then
		
		for index, value in ClientData do
			self:SetAttribute(index, value)
		end
		
	else
		Events:FindFirstChild("GetInfoHouse"):FireServer()
	end
end

function GetColor(model : Instance)
	local selected
	for _,basePart in model:GetChildren() do
		if basePart:IsA("BasePart") then
			if basePart.Transparency > 0 then
				selected = basePart.Color
			else
				return basePart.Color
			end
		end
	end
	return selected
end

function module:GetColorAndTexture(NewUpdate)
	local Data = (not Client and self.DataBaseHouse and self.DataBaseHouse:GetStoreData("WorldContentStore")) or (Client and self:GetAttribute("Desing"))
	Data = not Client and (Data.Desing or {}) or Data
	if Client or NewUpdate then
		local list = {}
		local function Added(PisoPared : Folder)
			if PisoPared then
				for _, model : Model in PisoPared:GetChildren() do
					if string.match(model.Name, "Color") then
						local DataSave = Data[PisoPared.Name] and Data[PisoPared.Name][model.Name] or {}
						if not Client then
							for index, value in DataSave do
								if Changes[index] then
									Changes[index](self, model, breackdownValues.Get(value))
								end
							end
						else
							list[model.Name] = list[model.Name] or {}
							list[model.Name][PisoPared.Name] = {
								Base = model,
								Color = DataSave.Color and breackdownValues.Get(DataSave.Color) or GetColor(model),
								Material = DataSave.Material,
							}
						end
						
					end
				end
			end
		end
		if not Client then
			for index,_ in Data do
				Added(self.Base:FindFirstChild("Estructura"):FindFirstChild(index))
			end
		else
			Added(self.Base:FindFirstChild("Estructura"):FindFirstChild("Floors"))
			Added(self.Base:FindFirstChild("Estructura"):FindFirstChild("Walls"))
		end
		Data = Client and list or Data
	end
	return Data
end

function module:DataChanged()
	if not self.DataChangedActive and self.DataBaseHouse then
		self.DataChangedActive = true
		self.DataBaseHouse.OnStoreUpdated:Connect(function(name, NewData)
			if name == "WorldRolesStore" then
				Events:FindFirstChild("GetInfoHouse"):FireAllClients({Permisos = NewData})
			elseif name == "WorldContentStore" then
				Events:FindFirstChild("GetInfoHouse"):FireAllClients({Desing = self:GetColorAndTexture(true)})
			end
		end)
	end
end

function module:ChangeDesing(Base, Change)
	if not (typeof(Base)=="string" and typeof(Change)=="table") then return end
	if Client then
		Events:FindFirstChild("ChangeDesing"):FireServer(Base, Change)
	elseif self.DataBaseHouse then
		local ListRuta = string.split(Base,".")
		if #ListRuta == 2 then
			local Base : Instance = self.Base:FindFirstChild("Estructura"):FindFirstChild(ListRuta[1])
			Base = Base and Base:FindFirstChild(ListRuta[2])
			if Base then
				self.DataBaseHouse:UpdateStore("WorldContentStore", function(Data)
					Data = typeof(Data)=="table" and Data or {}
					Data.Desing = Data.Desing or {}
					Data.Desing[ListRuta[1]] = Data.Desing[ListRuta[1]] or {}
					Data.Desing[ListRuta[1]][ListRuta[2]] = Data.Desing[ListRuta[1]][ListRuta[2]] or {}
					for index, value in Change do
						if not Changes[index] then continue end
						Data.Desing[ListRuta[1]][ListRuta[2]][index] = breackdownValues.Set(value)
					end
					return Data
				end)
			end
		end
	end
end

function module:init()
	
	if Client then
		require(RS:WaitForChild("Client"):WaitForChild("Attributes")).new(self)
	end
	
	local GetInfoHouse = Events:WaitForChild("GetInfoHouse")
	GetInfoHouse = Client and GetInfoHouse.OnClientEvent or GetInfoHouse.OnServerEvent
	GetInfoHouse:Connect(function(...) self:GetData(...) end)
	
	if Client then
		self:SetAttribute("Owner", 0)
		self:SetAttribute("Permisos", {})
		self:SetAttribute("Desing", {})
		
		self.ParentObjects = workspace:WaitForChild("ObjectsWorkspace")
		self.DataObjects = RS:WaitForChild("DataObjectsHouse")
		
		self.RemovedObjAction = {}
		
		self:GetData()
	else

		self.ParentObjects = Instance.new("Folder", workspace)
		self.ParentObjects.Name = "ObjectsWorkspace"

		self.DataObjects = Instance.new("Folder", RS)
		self.DataObjects.Name = "DataObjectsHouse"
		
	end
end

function module:GetParts()
	local modelTemplate = self.Base:FindFirstChild("Estructura")
	if modelTemplate then
		local list = {
			Walls = self.GetChilds(modelTemplate,"Walls"),
			Floors = self.GetChilds(modelTemplate, "Floors"),
			Ceiling = self.GetChilds(modelTemplate, "Ceiling"),
			NoCollition = self.GetChilds(modelTemplate, "Hitbox"),
		}
		return list
	end
end

function module:SearchRoom(Object)
	Object = typeof(Object)=="Vector3" and Object
		or typeof(Object)=="CFrame" and Object.Position
		or typeof(Object)=="Instance" and ((Object:IsA("Model") or Object:IsA("BasePart")) and Object:GetPivot().Position
			or Object:IsA("Player") and Object.Character:GetPivot().Position) or Vector3.zero
	local Model
	local MinMagnitude = math.huge
	for _,BasePart:BasePart in self.Base:FindFirstChild("Estructura"):GetDescendants() do
		if BasePart:IsA("BasePart") and string.match(BasePart.Parent.Name, "Color") then
			local ToWorldSpace = BasePart:GetClosestPointOnSurface(Object)
			local CalculeMag = (Object - ToWorldSpace).Magnitude
			if CalculeMag < MinMagnitude then
				MinMagnitude = CalculeMag
				Model = BasePart.Parent
			end
		end
	end
	return Model
end

function module:UpdateRoomPlayer()
	if not Client then return end
	local now = tick()
	if not self.tick or now-self.tick > .3 then
		self.tick = now
		local NewRoom = self:SearchRoom(LocalPlayer.Character:GetPivot())
		if NewRoom ~= self.RoomActual then
			self.RoomActual = NewRoom
			UpdateLugarJugador:Fire()
		end
	end
	return self.RoomActual.Name
end

return module.new()