local module = {}
module.__index = module

local IsClient = game:GetService('RunService'):IsClient()
local RS = game:GetService("ReplicatedStorage")
local events = RS:WaitForChild('Events'):WaitForChild('Paint')
local Disconnect = require(RS:WaitForChild("Client"):WaitForChild("Disconnects"))
local Format = require(script.Parent:WaitForChild('FormatPinturaData'))
local Players = game:GetService("Players")
local LocalPlayer = IsClient and Players.LocalPlayer or nil
local PlaceId = tostring(game.PlaceId)
local HttpService = not IsClient and game:GetService("HttpService") or nil

function module.init()
	local self = setmetatable({
		maxSlots = 9,
		DataPlayer = {},
		GlobalDataCache = {},
		CuadrosInPlace = {},
		ColaLoad = not IsClient and {
			Counts = 0,
			MaxLoads = 20,
			TimeExhauste = 60,
			Cola = {},
			Saves = {},
		} or nil,
		ColaLike = not IsClient and {
			Counts = 0,
			MaxLoads = 20,
			TimeExhauste = 60,
			Cola = {},
			SpawnAction = nil,
		} or nil,
		timeUpdate = 3,
		MaxUpdateDistance = 160,
		Events = events,
		messageService = not IsClient and game:GetService("MessagingService"),
	}, module)
	self:Works()
	self.B_Events = self:BindabledEvents()
	self.Format = Format
	return self
end

---//Solo valido para el cliente
function module:BindabledEvents()
	if IsClient then
		local B_eventos = {'CacheAdded','CacheRemoved','DataAdded'}
		for index, NameEvent in B_eventos do
			local created = Instance.new('BindableEvent', script)
			created.Name = NameEvent..'Instance'
			self[NameEvent] = created.Event
			B_eventos[index] = created
		end
		return B_eventos
	end
end
function module:FireBindable(NameObject,...)
	if self.B_Events and typeof(NameObject) == 'string' then
		for _,event in self.B_Events do
			if event.Name == NameObject..'Instance' then
				return event:Fire(...)
			end
		end
	end
end

---//Solo valido para servidor
function module:AddedSave(Player, UniqueKey,Data)
	if IsClient then return end
	if typeof(UniqueKey) == 'string' and Format.SeguridadFormato(Data) and not self.ColaLoad.Saves[UniqueKey] then
		self.ColaLoad.Saves[UniqueKey] = {to = Player, Data = Data}
	end
	self.SpawnAddedSave = self.SpawnAddedSave or task.spawn(function()
		local Vacio = true
		for index, value in self.ColaLoad.Saves do
			if value then
				local n,rr = self.DataBase:SetData('DataPinturas',index, value.Data)
				if n then
					self:AddedCache(value.to,index,value.Data)
					self.ColaLoad.Saves[index] = nil

					self.SentNotification(value.to,"Sistema de cuadros",'Se ha guardado correctamente el cuadro.',5,
						2022095747,'rotate',
						8486683243)
				else
					warn(rr)
				end
			end
			break
		end
		self.SpawnAddedSave = nil
		if not Vacio then
			self:AddedSave()
		end
	end)
end

function module:loadedListCache()
	local selection = self.ColaLoad.Cola[1]
	if selection then
		for _,clave in selection.Data do
			if selection.To and selection.To:IsDescendantOf(game) then
				local success,Data = self.DataBase:GetData("DataPinturas",clave)
				if success then
					if Data then
						self.ColaLoad.Counts += 1
						self:AddedCache(selection.To,clave,Data)
					else
						table.remove(self.DataPlayer[selection.To], table.find(self.DataPlayer[selection.To], clave))
						self:Load(selection.To)
					end
				else
					self:AddedLoadCola(selection.To,clave)
				end
				task.wait((self.ColaLoad.TimeExhauste/self.ColaLoad.MaxLoads) * (not success and 2 or 1))
			else
				break
			end
		end
		table.remove(self.ColaLoad.Cola,table.find(self.ColaLoad.Cola,selection))
		self:loadedListCache()
	else
		self.ColaLoad.spawnAction = nil
		self:AddedLoadCola()
	end
end

function module:AddedLoadCola(Player:Player,Datas)
	if IsClient then return end
	if Player then
		if typeof(Datas) == 'table' and #Datas > 0 then
			table.insert(self.ColaLoad.Cola, {
				Data = Datas,
				To = Player,
			})
		elseif Format.SeguridadFormato(Datas) then
			return self:AddedLoadCola(Player,{Datas})
		end
	end
	
	if #self.ColaLoad.Cola > 0 then
		self.ColaLoad.spawnAction = self.ColaLoad.spawnAction or task.spawn(function() self:loadedListCache() end)
	elseif #self.ColaLoad.Cola <= 0 and self.ColaLoad.spawnAction then
		task.cancel(self.ColaLoad.spawnAction)
		self.ColaLoad.spawnAction = nil
	end
end
-------------------------------
function module:GetData(Player : Player, UniqueKey)
	UniqueKey = IsClient and Player or UniqueKey
	if not UniqueKey then return end
	local data = IsClient and self.DataPlayer or not IsClient and self.DataPlayer[Player]
	return data and table.find(data, UniqueKey)
end

function module:GetCache(Player : Player, UniqueKey)
	UniqueKey = IsClient and Player or UniqueKey
	if not UniqueKey then return end
	local data = IsClient and self.GlobalDataCache or not IsClient and self.GlobalDataCache[Player]
	return data and data[UniqueKey]
end

function module:AddedCache(Player:Player,UniqueKey,Data)
	Data = IsClient and UniqueKey or Data
	UniqueKey = IsClient and Player or UniqueKey
	if typeof(UniqueKey) == 'string' and Format.SeguridadFormato(Data) then
		if IsClient then
			self.GlobalDataCache[UniqueKey] = Data
			self:FireBindable('CacheAdded')
		elseif Player and Player:IsDescendantOf(game) then
			self.GlobalDataCache[Player] = self.GlobalDataCache[Player] or {}
			if Format.IsOwner(Player, Data) then
				self.GlobalDataCache[Player][UniqueKey] = Data
				events:WaitForChild('DataCache'):FireClient(Player,UniqueKey,Data)
			elseif self.DataPlayer[Player] then
				local index = table.find(self.DataPlayer[Player], UniqueKey)
				if index then
					table.remove(self.DataPlayer[Player], index)
					self:Load(Player)
				end
			end
		end
	end
end

function module:RemoveCache(Player:Player,UniqueKey)
	if IsClient then return end
	if typeof(UniqueKey) == 'string' then
		local data = IsClient and self.GlobalDataCache or self.GlobalDataCache[Player]
		if data then
			data[UniqueKey] = nil
		end
		if IsClient then
			self:FireBindable('CacheRemoved')
		else
			for _,datatInCola in self.ColaLoad.Cola do
				if datatInCola.To == Player then
					local index = table.find(datatInCola.Data, UniqueKey)
					if index then
						table.remove(datatInCola, index)
					end
				end
			end
			events:FindFirstChild('Remove'):FireClient(Player,UniqueKey)
		end
	end
end

function module:Save(Player : Player, Data)
	if IsClient then
		events:WaitForChild('Save'):FireServer(Player)
	elseif Format.SeguridadFormato(Data) then
		self.DataPlayer[Player] = self.DataPlayer[Player] or {}
		if #self.DataPlayer[Player] < self.maxSlots then
			local UniqueKey = HttpService:GenerateGUID(true)
			table.insert(self.DataPlayer[Player], UniqueKey)
			self:AddedSave(Player,UniqueKey,Data)
			self:Load(Player)
		else
			warn(string.format("No puedes guardar más de %d cuadros", self.maxSlots))
		end
	end
end

function module:Remove(Player : Player, KeyCuadro)
	if IsClient then
		events:WaitForChild('Remove'):FireServer(Player)
	elseif typeof(KeyCuadro) == 'string' then
		
		local index = self:GetData(Player, KeyCuadro)
		
		if index and self:IsNotPaintInHouse(Player, KeyCuadro) then
			
			for _,data in self.Cuadros do
				if data.CuadroSelect == KeyCuadro then
					if data.IsInUse then return end
					data:Update({})
				end
			end
			
			table.remove(self.DataPlayer[Player], index)
			self:Load(Player)
			self:RemoveCache(Player, KeyCuadro)
			
			local esperar = task.wait
			local function GetData()
				local Sucesss,DataPintura = self.DataBase:GetData("DataPinturas", KeyCuadro)
				local OwnerCuadro = Sucesss and DataPintura and Format.IsOwner(Player, DataPintura)
				if OwnerCuadro then
					local function Delete()
						local success,_ = self.DataBase:DeleteData('DataPinturas', KeyCuadro)
						if not success then
							warn('error al eliminar este cuadro, intentando de nuevo.')
							Delete(esperar(self.ColaLoad.TimeExhauste/self.ColaLoad.MaxLoads))
						else
							warn('Cuadro eliminado por completo.')
						end
					end
					Delete()
				elseif not Sucesss then
					warn('error al obtener el dato del cuadro, intentando de nuevo.')
					GetData(esperar(self.ColaLoad.TimeExhauste/self.ColaLoad.MaxLoads))
				else
					warn('No eres dueño del cuadro, no puedes eliminarlo.')
				end
			end
			GetData()
		else
			warn("el cuadro no existe o hay una casa ocupando la pintura")
		end
	end
end

function module:Load(Player:Player, Data)
	if IsClient then
		if Player then
			self.DataPlayer = Player
			self:FireBindable('DataAdded')
		elseif not self.YaEnviado then
			self.YaEnviado = true
			events:WaitForChild('Load'):FireServer(Player)
		end
	elseif not self.DataPlayer[Player] and typeof(Data) == 'table' then
		self.DataPlayer[Player] = Data
		task.defer(function()
			self:Load(Player)
			self:AddedLoadCola(Player, Data)
		end)
	elseif self.DataPlayer[Player] and Player:IsDescendantOf(game) then
		events:WaitForChild('Load'):FireClient(Player, self.DataPlayer[Player])
	end
end

function module:PlayerRemoving(Player:Player)
	if self.GlobalDataCache[Player] then
		self.GlobalDataCache[Player] = nil
	end
	local data = self.DataPlayer[Player]
	if not data then return end
	self.DataPlayer[Player] = nil
	return data
end

---------------Estados de los cuadros
function module:GetModelsByStore(DataStoreName, NameItem)
	if not DataStoreName or not NameItem then return false end
	local Childs = DataStoreName.DecorChild
	if not Childs then return false end
	local Models = IsClient and (DataStoreName:IsA("Store") and Childs:Find(NameItem) or Childs) or Childs[NameItem]
	if not Models then return false end
	if DataStoreName:IsA("House") and IsClient then
		local list = {}
		for index, model in Models do
			if index.Name ~= NameItem then continue end
			table.insert(list, {
				Disabled = model,
				Boolean = index,
			})
		end
		return list
	else
		return IsClient and DataStoreName:IsA("Store") and Models:GetChildren(true) or Models
	end
end

function module:IsNotCuadroInUse(KeyRanure,DataStoreName,NameItem)
	if not DataStoreName or not KeyRanure or not NameItem then return false end
	local Models = self:GetModelsByStore(DataStoreName, NameItem)
	if not Models then return false end
	for _, model in Models do
		local Data = not model.GetData and model.Boolean:GetAttributes() or model:GetData()
		if Data and Data.CuadroKey == KeyRanure then
			return false
		end
	end
	return true
end

function module:CuadrosInhabilitados(DataStoreName,NameItem)
	local Models = self:GetModelsByStore(DataStoreName, NameItem)
	if not Models then return false end
	local list = {}
	for _, model in Models do
		local Data = not model.GetData and
			model.Boolean:GetAttributes() or model:GetData()
		if Data and Data.CuadroKey then
			list[Data.CuadroKey] = true
		end
	end
	return list
end

function module:IsNotPaintInHouse(Player : Player, KeyCuadro)
	KeyCuadro = IsClient and Player or KeyCuadro
	Player = IsClient and LocalPlayer or Player
	if not KeyCuadro or not Player then return false end
	local PainData = Player:FindFirstChild("LastPaint")
	if not PainData then return false end
	local NameAttribute = string.sub(KeyCuadro,2,#KeyCuadro-1)
	local Attribute = PainData:GetAttribute(NameAttribute)
	if not Attribute then return true end
	local List = string.split(Attribute, "|")
	if #List <= 0 then return true end
	for _, Casa in List do
		local separator = string.split(Casa, ":")
		if separator[1] == PlaceId then
			table.remove(List, table.find(List, Casa))
			break
		end
	end
	return #List <= 0
end

function module:MarkPaint(Player, KeyCuadro, UnniqueId)
	if IsClient or not KeyCuadro or not UnniqueId then return end
	local PainData = Player:FindFirstChild("LastPaint")
	if not PainData then return end
	local NameAttribute = string.sub(KeyCuadro,2,#KeyCuadro-1)
	local Attribute = PainData:GetAttribute(NameAttribute)
	local List = Attribute and string.split(Attribute,"|") or {}
	local IsSaved = false
	if #List > 0 then
		for index, Casa in List do
			local separator = string.split(Casa, ":")
			if separator[1] == PlaceId then
				local UnniquesId = string.split(separator[2], ",")
				if not table.find(UnniquesId, UnniqueId) then
					table.insert(UnniquesId, UnniqueId)
				end
				IsSaved = true
				List[index] = separator[1]..":"..(table.concat(UnniquesId,","))
				break
			end
		end
	end
	if not IsSaved then
		table.insert(List, PlaceId..":"..UnniqueId)
	end
	PainData:SetAttribute(NameAttribute, table.concat(List,"|"))
	return true
end

function module:UnmarkPaint(Player, KeyCuadro, UnniqueId)
	if IsClient or not KeyCuadro or not UnniqueId then return end
	local PainData = Player:FindFirstChild("LastPaint")
	if not PainData then return end
	local NameAttribute = string.sub(KeyCuadro,2,#KeyCuadro-1)
	local Attribute = PainData:GetAttribute(NameAttribute)
	if not Attribute then return true end
	local List = string.split(Attribute, "|")
	if #List <= 0 then return true end
	for index, Casa in List do
		local separator = string.split(Casa, ":")
		if separator[1] == PlaceId then
			local UnniquesId = string.split(separator[2], ",")
			local indexFind = table.find(UnniquesId, UnniqueId)
			if indexFind then
				table.remove(UnniquesId, indexFind)
			end
			if #UnniquesId <= 0 then
				table.remove(List, index)
			else
				List[index] = separator[1]..":"..(table.concat(UnniquesId,","))
			end
			break
		end
	end
	PainData:SetAttribute(NameAttribute, #List > 0 and table.concat(List,"|") or nil)
	return true
end
-------------------------------------------

function module:GetMarcos(Player)
	Player = IsClient and LocalPlayer or Player
	local InventoryMarcos = Player and Player:FindFirstChild("MarcosPaint")
	local list = {}
	if InventoryMarcos then
		for _,frame in InventoryMarcos:GetChildren() do
			local list2 = {
				Name = frame.Name,
				Count = 0,
				Instance = frame,
			}
			for _,value in frame:GetAttributes() do
				if not value then
					list2.Count += 1
				end
			end
			if list2.Count > 0 then
				table.insert(list, list2)
			end
		end
	end
	return list
end

function module:IsMarcoAviable(Player, NameMarco, IsStore)
	if typeof(NameMarco)~="string" then return end
	Player = IsClient and LocalPlayer or Player
	local InventoryMarcos = Player and Player:FindFirstChild("MarcosPaint")
	InventoryMarcos = InventoryMarcos and InventoryMarcos:FindFirstChild(NameMarco)
	if InventoryMarcos then
		for index,value in InventoryMarcos:GetAttributes() do
			if not value then
				return index, InventoryMarcos
			end
		end
	end
end

function module:SetMarco(Player:Player, NameMarco, Amount)
	Amount = typeof(Amount)=="number" and Amount>0 and Amount or 1
	if typeof(NameMarco)~="string" then return end
	Player = IsClient and LocalPlayer or Player
	local InventoryMarcos = Player and Player:FindFirstChild("MarcosPaint")
	local Marco = InventoryMarcos and InventoryMarcos:FindFirstChild(NameMarco)
	if not Marco and InventoryMarcos then
		Marco = Instance.new("BoolValue")
		Marco.Name = NameMarco
		Marco.Parent = InventoryMarcos
	end
	if Marco then
		local startCount = 0
		for _,_ in Marco:GetAttributes() do startCount += 1 end
		for i = startCount, startCount + (Amount - 1) do
			Marco:SetAttribute(string.format("Slot%d",i + 1), false)
		end
	end
end

function module:VentaRemota(Player: Player, message)
	if IsClient or typeof(message) ~= "table" then return end
	if typeof(Player) ~= "Instance" or not Player:IsDescendantOf(game) then return end

	local keyCuadro = message.keyCuadro

	if message.marco then
		local InventoryMarco = Player:FindFirstChild("MarcosPaint")
		InventoryMarco = InventoryMarco and InventoryMarco:FindFirstChild(message.marco)
		if InventoryMarco then
			local function changed(eliminado)
				for index, value in InventoryMarco:GetAttributes() do
					if (not value or eliminado) then
						InventoryMarco:SetAttribute(index, nil)
						return
					end
				end
				changed(true)
			end
			changed()
		end
	end

	local index = self:GetData(Player, keyCuadro)
	if not index then return end

	for _,data in self.Cuadros do
		if data.CuadroSelect == keyCuadro then
			if data.IsInUse then return end
			data:Update({})
		end
	end

	table.remove(self.DataPlayer[Player], index)
	self:RemoveCache(Player, keyCuadro)
end

function module:like(Player:Player, KeyCuadro)
	if not IsClient then
		if typeof(KeyCuadro)=="string" then
			local inprogress = false
			for _, selection in self.ColaLike.Cola do
				if selection.KeyCuadro == KeyCuadro and not selection.inprogress
					and not table.find(selection.list, Player.UserId) then
					table.insert(selection.list,Player.UserId)
					inprogress = true
					break
				end
			end
			if not inprogress then
				table.insert(self.ColaLike.Cola, {
					KeyCuadro = KeyCuadro,
					list = {Player.UserId},
				})
			end
		end
		if not self.ColaLike.SpawnAction then
			self.ColaLike.SpawnAction = task.spawn(function()
				local selection = self.ColaLike.Cola[1]
				if selection then
					task.wait((self.ColaLike.TimeExhauste/self.ColaLike.MaxLoads) / 2)
					selection.inprogress = true
					local success,ErrorMessage = self.DataBase:UpdateData("DataPinturas",selection.KeyCuadro,function(dataPintura)
						if not dataPintura then return end
						local formatTable = Format.format(dataPintura)
						local extras = Format.GetInfoExtra(formatTable[5])
						local likes = Format.GetInfoExtra(extras[1]) or {}
						for _, userIdPlayer in selection.list do
							if not table.find(likes, tostring(userIdPlayer)) then
								table.insert(likes, tostring(userIdPlayer))
							end
						end
						extras[1] = string.format("{%s}", table.concat(likes,','))
						extras = string.format("(%s)", table.concat(extras,","))
						formatTable[5] = extras
						formatTable = Format.InvertFormat(formatTable)
						return formatTable
					end)
					if success then
						warn(`se ha dado like a {selection.KeyCuadro} los jugadores:`, selection.list)
						table.remove(self.ColaLike.Cola, table.find(self.ColaLike.Cola, selection))
					else
						warn(ErrorMessage)
					end
					task.wait((self.ColaLike.TimeExhauste/self.ColaLike.MaxLoads) * (not success and 2 or 1))
					self.ColaLike.SpawnAction = nil
					self:like()
				end
			end)
		end
		
	end
end

function module:UpdateImageCuadros()
	if self.ModulePaint then
		for Cuadro:Model, Data in self.CuadrosInPlace do
			self.ModulePaint.LoadOtherFrames(Cuadro,Data.format)
		end
	end
end

-----Actualizacion pinturas
function module:UpdateCuadros(Player, ModeloCuadro, serializacion, force)
	force = IsClient and serializacion or force
	serializacion = IsClient and ModeloCuadro or serializacion
	serializacion = Format.SeguridadFormato(serializacion) and serializacion or nil
	ModeloCuadro = IsClient and Player or ModeloCuadro
	Player = IsClient and LocalPlayer or Player
	if IsClient then
		local now = tick()
		if not force and (self.DateTimeUpdate and (now - self.DateTimeUpdate) < (self.timeUpdate or 0.5)) then
			return
		end
		self.DateTimeUpdate = now
	end

	if typeof(ModeloCuadro)=="Instance" and ModeloCuadro:IsA("Model") and
		(ModeloCuadro:HasTag("Paint") or ModeloCuadro:HasTag("CuadrosPaint")) then
		local OwnerCuadro = ModeloCuadro:GetAttribute("InInUse") or ModeloCuadro:GetAttribute("Owner")
		if OwnerCuadro == Player.UserId then
			if IsClient then
				events:WaitForChild('Update'):FireServer(ModeloCuadro, serializacion,false)
			else
				for _,OtherPlayer in game:GetService('Players'):GetPlayers() do
					if ModeloCuadro:GetAttribute("Owner")
						or OtherPlayer ~= Player then
						events:FindFirstChild('Update'):FireClient(OtherPlayer, ModeloCuadro, serializacion)
					end
				end
				if ModeloCuadro:GetAttribute("InInUse") == Player.UserId
					and not ModeloCuadro:GetAttribute("Owner") then
					Player:FindFirstChild("LastPaint").Value = serializacion or ""
				end
				self:AddedCuadro(ModeloCuadro, serializacion)
			end
		end
	end
end

function module:AddedCuadro(Model:Model,Serializacion)
	if typeof(Model)=="Instance" and Model:IsA("Model") then
		if self.CuadrosInPlace[Model] then
			if Serializacion then
				if IsClient and self.ModulePaint then
					self.ModulePaint.LoadOtherFrames(Model,Serializacion)
				end
				self.CuadrosInPlace[Model].format = Serializacion
			else
				self:RemoveCuadro(Model)
			end
		elseif Serializacion then
			local lista = {
				actives = {},
				format = Serializacion,
			}
			table.insert(lista.actives, Model.Changed:Connect(function(propiety)
				if propiety == "Parent" then
					if not Model.Parent then
						self:RemoveCuadro(Model)
					elseif IsClient and self.ModulePaint then
						self.ModulePaint.LoadOtherFrames(Model,Serializacion)
					end
				elseif propiety == "WorldPivot" and IsClient and self.ModulePaint then
					warn("cambiooo")
					self.ModulePaint.LoadOtherFrames(Model,Serializacion)
				end
			end))
			table.insert(lista.actives, Model.AttributeChanged:Connect(function(attribute)
				local OwnerCuadro = Model:GetAttribute("InInUse") or Model:GetAttribute("Owner")
				if not OwnerCuadro then self:RemoveCuadro(Model) end
			end))
			self.CuadrosInPlace[Model] = lista
		end
	end
end
function module:RemoveCuadro(Model:Model)
	local lista = self.CuadrosInPlace[Model]
	if lista then
		if Model.Parent and IsClient and self.ModulePaint then
			self.ModulePaint.LoadOtherFrames(Model)
		end
		self.CuadrosInPlace[Model] = Disconnect.All(lista.actives)
	end
end

function module:GetAllPaints(Player)
	if IsClient then
		if typeof(Player) == "table" then
			for _, Data in Player do
				self:AddedCuadro(Data.Model, Data.format)
			end
		elseif not self.AllDataPaintsEnviado then
			self.AllDataPaintsEnviado = true
			events:FindFirstChild("GetAllPaints"):FireServer()
		end
	else
		local list = {}
		for Model, Data in self.CuadrosInPlace do
			table.insert(list, {Model = Model, format = Data.format})
		end
		if #list > 0 then
			events:FindFirstChild("GetAllPaints"):FireClient(Player, list)
		end
	end
end
-----------------------------------------------------

function module:Works()
	if self.IsActives then return end
	self.IsActives = {}
	local eventSave = events:WaitForChild('Save')
	eventSave = IsClient and eventSave.OnClientEvent or eventSave.OnServerEvent
	local eventLoad = events:WaitForChild('Load')
	eventLoad = IsClient and eventLoad.OnClientEvent or eventLoad.OnServerEvent
	local eventDataCache = events:WaitForChild('DataCache')
	eventDataCache = IsClient and eventDataCache.OnClientEvent or eventDataCache.OnServerEvent
	table.insert(self.IsActives, eventLoad:Connect(function(...) self:Load(...) end))
	
	local eventGetAllCuadros = events:WaitForChild('GetAllPaints')
	eventGetAllCuadros = IsClient and eventGetAllCuadros.OnClientEvent or eventGetAllCuadros.OnServerEvent
	table.insert(self.IsActives, eventGetAllCuadros:Connect(function(...) self:GetAllPaints(...) end))
	
	if IsClient then
		self:Load()
		events:FindFirstChild('DataCache'):FireServer()
		self:GetAllPaints()
		table.insert(self.IsActives, eventDataCache:Connect(function(...) self:AddedCache(...) end))
		table.insert(self.IsActives, events:WaitForChild('Remove').OnClientEvent:Connect(function(...) self:RemoveCache(...) end))
		table.insert(self.IsActives, events:WaitForChild('Update').OnClientEvent:Connect(function(...) self:AddedCuadro(...) end))
		task.spawn(function() while task.wait(.5) do self:UpdateImageCuadros() end end)
	else
		table.insert(self.IsActives, events:WaitForChild('Update').OnServerEvent:Connect(function(...) self:UpdateCuadros(...) end))
		table.insert(self.IsActives, events:WaitForChild('Remove').OnServerEvent:Connect(function(...) self:Remove(...) end))
		table.insert(self.IsActives, eventDataCache:Connect(function(Player:Player)
			if self.GlobalDataCache[Player] then
				for index, value in self.GlobalDataCache[Player] do
					events:FindFirstChild('DataCache'):FireClient(Player,index,value)
				end
			end
		end))
		table.insert(self.IsActives, eventSave:Connect(function(...) self:Save(...) end))
	end
end

return module.init()
