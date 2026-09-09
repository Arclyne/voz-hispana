local fn = {}
fn.__index = fn

local Client = game:GetService('RunService'):IsClient()
local plr = Client and game:GetService('Players').LocalPlayer
local RS = game:GetService('ReplicatedStorage')
local Events = RS:WaitForChild('Events')
local EventChanged = Client and Instance.new('BindableEvent', script) or nil
local IsStudio = game:GetService("RunService"):IsStudio() and game.PlaceId
local debris = game:GetService("Debris")
local breackdownValues = not Client and require(RS:FindFirstChild("Shared"):FindFirstChild("BreakDown"))

local DataDesing = require(RS:WaitForChild("Client"):WaitForChild("DesingData"))

fn.DecorEvents = Events:WaitForChild('Decors')
fn.StoreEvents = Events:WaitForChild('Stores')

function GetChilds(Base:Instance, NameChild, list)
	list = typeof(list)=="table" and list or {}
	if typeof(Base)=="Instance" and typeof(NameChild)=="string" then
		local searched = Base:FindFirstChild(NameChild)
		if searched then
			for _,basePart in searched:GetDescendants() do
				if basePart:IsA("BasePart") and
					not basePart:GetAttribute("NoPut") and basePart:GetAttribute("Whitelist") then
					table.insert(list, basePart)
				end
			end
		end
	end
	return list
end
function GetInfoIdsHouses()
	local Data = require(RS:WaitForChild("HousesInfo"))
	local list = {}
	for _,v in Data do
		table.insert(list, v.placeId)
	end
	return list
end

function fn.new()
	local self = setmetatable({
		collS = game:GetService('CollectionService'),
		IsActive = false,
		ComprasList = {},
		DecorsPlayer = require(script:WaitForChild("DecorsPlayer")),
		AddedDecor = require(script:WaitForChild('DecorFuncs')),
		AddItem = require(RS.Shared:WaitForChild('AddValues')),
		comprasFunct = not Client and require(script:WaitForChild('Compras')) or nil,
		StoreGui = Client and require(RS:WaitForChild("Client"):WaitForChild("Event")).new() or nil,
		
		MaxBuildPlace = 5,
		
	}, fn)

	self.PlaceId_PlsDonate = false and IsStudio or 82871403803520
	self.PlaceId_CasaPlaya = false and {IsStudio} or GetInfoIdsHouses()

	self.Added = game.PlaceId==self.PlaceId_PlsDonate and
		require(script:WaitForChild('Added')) or table.find(self.PlaceId_CasaPlaya,game.PlaceId) and require(script:WaitForChild("HouseAdded"))

	self.AddedDecor.Added.AddItem = self.AddItem
	self.AddedDecor.Added.Main = self

	if Client then
		self.AddedDecor.ListMain = self.DecorsPlayer
	end

	self:SetStore()
	self:Works()

	self.OwnerAdded = EventChanged and EventChanged.Event or nil

	return self
end

function fn:Add(Base:BasePart)
	if not self.IsActive then return end
	if game.PlaceId == self.PlaceId_PlsDonate then
		local object = self:GetStore(Base)
		if object then
			return not object.Occuped and object
		else
			if self:IsBase(Base) then
				object = self.Added.new(Base)
				table.insert(self.StoresList, object)
				return object
			end
		end
	end
end
function fn:Removed(Base:BasePart)
	if not self.IsActive then return end
	if game.PlaceId == self.PlaceId_PlsDonate then
		local store = self:GetStore(Base)
		if store then
			if store.Occuped then
				self:UpdateStore(store.Owner, Base, false)
			end
			if store.OwnerChanged then
				store.OwnerChanged:Destroy()
			end
			table.clear(store)
			table.remove(self.StoresList, table.find(self.StoresList, store))
		end
	end
end
function fn:IsBase(Base)
	for _,v in self.collS:GetTagged(self.Tag) do
		if v == Base then return v end
	end
end
function fn:GetStore(Base : Instance)
	if not self.IsActive then return end
	if game.PlaceId == self.PlaceId_PlsDonate then
		local IsInstance = typeof(Base) == "Instance"
		local IsModel = IsInstance and (Base:IsA("Model") or Base:IsA("BasePart") or Base:IsA("Folder"))
		for _,store in self.StoresList do
			if Base == store or IsInstance and
				(store.Owner == Base or store.Occuped == Base or
					IsModel and (store.Base == Base or Base:IsDescendantOf(store.Base))) then
				return store
			end
		end
	elseif self.Added and self.Added:IsA("House") then
		if Client then
			local UserId = tostring(plr.UserId)
			if tostring(self.Added.Owner) == UserId or
				(self.Added:GetAttribute("Permisos")[UserId] and
					self.Added:GetAttribute("Permisos")[UserId] ~= 46) then
				return self.Added
			end
		elseif typeof(Base)=="Instance" and Base:IsA("Player") then
			local UserId = tostring(Base.UserId)
			local roles = self.Added.DataBaseHouse:GetStoreData("WorldRolesStore") or {}
			if tostring(self.Added.DataBaseHouse.OwnerId)==UserId or
				(roles[UserId] and roles[UserId] ~= 46) then
				return self.Added
			end
		end
	end
end

function fn:SetStore()

	if self.IsActive then return end

	if game.PlaceId == self.PlaceId_PlsDonate then
		self.IsActive = true
		self.StoresList = {}
		self:OrdenarModelos()

		self.Tag = 'Stores'

		local stores = self.collS:GetTagged(self.Tag)
		for _,store:BasePart in stores do
			self:Add(store)
		end
		self.collS:GetInstanceAddedSignal(self.Tag):Connect(function(...) self:Add(...) end)
		self.collS:GetInstanceRemovedSignal(self.Tag):Connect(function(...) self:Removed(...) end)
		self.Added.GetChilds = GetChilds

		warn("iniciando pls donate")
	elseif table.find(self.PlaceId_CasaPlaya,game.PlaceId) then

		self.Tag = 'ObjectsPutHouse'
		self.IsActive = true
		self:OrdenarModelos()
		self.Added:GetData()
		self.Added.GetChilds = GetChilds

		if Client then
			self.Added.AttributeChanged:Connect(function(attribute)
				if table.find({"Permisos", "Owner"}, attribute) then
					EventChanged:Fire()
				end
			end)
			EventChanged:Fire()
		else
			local action:RBXScriptConnection
			action = self.Added.DataBaseLoaded:Connect(function()
				action:Disconnect()
				action = nil

				local DataHouse = self.Added.DataBaseHouse:GetStoreData("WorldContentStore") or {}
				local UserIdOwner = tonumber(self.Added.DataBaseHouse.OwnerId)

				for _,Object in DataHouse.Objects or {} do
					local decor = self.AddItem(Object.Name, true, Object)
					local Update = {Colors = {}}

					for index:string, value in decor:GetAttributes() do
						if string.match(index:lower(), "color") then
							table.insert(Update.Colors, {Name = index, Color = value})
						else
							Update[index] = value
						end
					end

					decor.Parent = self.Added.DataObjects

					local decor2 = self:SetDecorPlayer(Object.OwnerPlace, decor)
					if decor2 then
						decor2.ParentStore = self.Added
						task.defer(function()
							decor2:Update(Update)
							self:AddedCaracteristicasDecor(UserIdOwner, self.Added, decor2, true)
						end)
					else
						debris:AddItem(decor, 0)
					end
				end

				self.Added.IsObjectsLoaded = true
			end)
		end

		warn("iniciando casa de playa")
	end
end

function fn:UpdateStore(Player:Player, Base, OpenClose,childs, StoreModel)
	if not self.IsActive or game.PlaceId ~= self.PlaceId_PlsDonate then return end
	local Store = self:GetStore(Base)
	local PlayerStore = self:GetStore(Player)

	if not Client then
		local OpenObject = OpenClose and Player:FindFirstChild("StoresData") and Player:FindFirstChild("StoresData"):FindFirstChild(OpenClose.Name)
		OpenClose = OpenClose==OpenObject and OpenClose or nil
	end

	if Store and not not (not OpenClose or not PlayerStore) then
		if (OpenClose and not Store.Occuped) or (not OpenClose and (Client or Store.Owner == Player)) then
			local LastOwner = Store.Owner
			Store.Owner = OpenClose and Player
			Store.Occuped = OpenClose
			Store.Base:SetAttribute('claimed', not not Store.Occuped)
			Store.IsBuildComplete = nil
			Store.CountBuilds = 0

			local lastDecorchild = Store.DecorChild
			Store.DecorChild = Store.Occuped and (not Client and self.DecorsPlayer[Player.UserId] or Store.Owner==plr and self.DecorsPlayer)

			if not Client then
				Store:Update()
				
				if Store.Occuped then
					for _,objects:StringValue in Player:WaitForChild('InventoryBuild'):GetChildren() do
						if objects:FindFirstChild(Store.Occuped.Name) then
							local Object = self:GetDecorPlayer(Player, objects)
							if not Object then continue end
							Object.ParentStore = Store
							local DataUpdate = Object:GetData()
							if not DataUpdate then continue end
							Object:Update(DataUpdate)
							if Object.Disabled then
								self:AddedCaracteristicasDecor(Player, Store, Object)
							end
						end
					end
				elseif lastDecorchild then
					for _,v in lastDecorchild do
						for _,model in v do
							if model.Disabled then
								model:Delete()
							end
						end
					end
				end

			else
				Store.ChildsBase = OpenClose and childs or {}
				Store.StoreModel = OpenClose and StoreModel or nil
				Store.OwnerChanged:Fire()
				if (Store.Owner or LastOwner) == plr then
					EventChanged:Fire(not not Store.Occuped)
				end
			end
		elseif not Client and not OpenClose and not Store.Occuped and not PlayerStore then
			Events:FindFirstChild('Other'):FindFirstChild('Commands'):FireClient(Player,6,Base)
		end
	end

end

function fn:RayParams(Player, NoModels)
	local r = RaycastParams.new()
	r.IgnoreWater = true
	r.FilterType = Enum.RaycastFilterType.Include
	local list = {}
	NoModels = Client and Player or NoModels
	Player = Client and plr or Player
	local Store = Client and self:GetStore(Player)
	if Store then
		Store:GetParts(list)
		if not NoModels then
			if Store:IsA("House") then
				table.insert(list, Store.ParentObjects)
			elseif Store:IsA("Store") then
				table.insert(list, Store.Decors)
			end
		end
	end
	r.FilterDescendantsInstances = list
	return r
end

function fn:ExitPlayer(Player : Player)
	self:ExitModeConstruccion(Player)
	self:UpdateStore(Player, Player, false)
	local list = self.DecorsPlayer[Player.UserId]
	self.DecorsPlayer[Player.UserId] = nil
	if list then
		for _,section in list do
			for _,data in section do data:Delete() end
		end
	end
end

function fn:AddedPlayer(Player : Player)

	local DataServer
	local Inventory = (Client and plr or Player):WaitForChild('InventoryBuild')

	if not Client then
		self:InsertTableInTable(self.DecorsPlayer,Player.UserId)
	end

	for _,base:StringValue in Inventory:GetChildren() do
		self:SetDecorPlayer(Client and base or Player,base,true)
	end


	if game.PlaceId == self.PlaceId_PlsDonate then
		if not Client then
			for _,store in self.StoresList do
				if store.Occuped then
					store:Update(Player)
				end
			end
		end
	elseif self.Added and self.Added:IsA("House") then
		if not Client then
			DataServer = {}
			for _,section in self.Added.DecorChild do
				for _,Data in section do
					if Data.Disabled then
						table.insert(DataServer, {Boolean = Data.Boolean, Model = Data.Disabled})
					end
				end
			end
		elseif typeof(Player)=="table" then
			for _, value in Player do
				self:SetDecorPlayer(value.Boolean, value.Model)
			end
		end
	end
	if not Client then
		self.StoreEvents:FindFirstChild("StartClientPlayer"):FireClient(Player, DataServer)
	end
end

function fn:GetStoreParts(Player:Player)
	if not self.IsActive then return end
	local storePlayer = self:GetStore(Player or plr)
	if storePlayer then
		return storePlayer:GetParts()
	end
end

function fn:BuyStore(Player:Player, NameStore)
	if not self.IsActive or game.PlaceId ~= self.PlaceId_PlsDonate then return end
	if Client then
		self.StoreEvents:WaitForChild('BuyStore'):FireServer(Player)
	else
		local store = RS:WaitForChild('StoreTemplates'):FindFirstChild(NameStore)
		store = store and require(store:FindFirstChild('Settings'))
		local StoresData = Player:FindFirstChild('StoresData')
		if store and StoresData and not StoresData:FindFirstChild(NameStore) and self.Cobros.charge(Player,store.Price,true) then
			store = store.Data
			self.AddItem(store.Name, store.Value).Parent = StoresData
		end
	end
end

function fn:BuyDecors(Player:Player, Decor:Model, amount)
	if not self.IsActive then return end
	if Client then
		amount = Decor
		Decor = Player
		self.DecorEvents:WaitForChild('BuyDecor'):FireServer(Decor, amount)
	else
		local Model, Data = self.AddedDecor.Added.verificarExistencia(Decor.Name)
		if not Data or Data.IsTool then return end

		local Inventory = Player:WaitForChild('InventoryBuild')

		if typeof(amount) == 'number' then
			for _ = 1, math.max(math.floor(tonumber(amount)) or 1) do
				if self.Cobros.charge(Player,Data.Price,true) then
					local decor = self.AddItem(Data.Data.Name, Data.Data.Value, Data.Data)
					decor.Parent = Inventory
					self:SetDecorPlayer(Player,decor)
				else
					break
				end
			end
		elseif typeof(amount) == 'table' then

			local function addInventory(Parent, IsPlaceHouse)
				local decor = self.AddItem(Data.Data.Name, IsPlaceHouse or Data.Data.Value, Data.Data)
				decor.Parent = Parent
				local data = self:SetDecorPlayer(Player,decor)
				if data then
					data.IsStart = false
					if not amount then return end
					local a = self:UpdateDecor(Player,data.Boolean, amount)
					if a and amount.CreateNewFusion then
						local FusionSearch = self:GetDecorPlayer(Player, amount.CreateNewFusion)
						if FusionSearch then
							local FusionData = FusionSearch:GetData()
							if not FusionData then return end
							FusionData.FusionWith = string.format("%s,%s",data.Boolean.Name,data.Boolean:GetAttribute("UnniqueKey"))
							self:UpdateDecor(Player,FusionSearch.Boolean,FusionData)
						end
					end
					return a
				end
			end

			if game.PlaceId == self.PlaceId_PlsDonate then
				
				if self.Cobros.charge(Player,Data.Price,true) then
					return addInventory(Inventory)
				else
					warn("no money")
				end
				
			elseif self.Added and self.Added:IsA("House") then
				local House = self:GetStore(Player)
				if not House then return end
				
				if Decor:IsDescendantOf(self.Added.DataObjects) then
					local decor2 = self:GetDecorPlayer(Player, Decor)
					if not decor2 then return end
					
					if decor2.Owner==Player.UserId and (not decor2.ComprasFunct or not decor2.ComprasFunct.CuadroSelect)
						or (House.DataBaseHouse and tonumber(House.DataBaseHouse.OwnerId)==Player.UserId) then
						
						debris:AddItem(Decor,0)
						amount = nil
						return addInventory(Inventory, true)
						
					end
					
				elseif self:IsAviableToPlace(self.Added) then
					if Decor:IsDescendantOf(Inventory) then
						debris:AddItem(Decor,0)
						return addInventory(self.Added.DataObjects, true)
					else
						local IsOwner = House.DataBaseHouse and tonumber(House.DataBaseHouse.OwnerId)==Player.UserId
						
						if not IsOwner and not self.donacion.GetState(Player, Data.Price.Coins) then
							return warn("limite alcanzado")
						end
						
						if not self.Cobros.charge(Player,Data.Price,true) then
							return warn("no money")
						end
						
						if not IsOwner then
							self.donacion.Quitar(Player, Data.Price.Coins)
						end
						
						return addInventory(self.Added.DataObjects)
					end
				else
					
					warn("limite de builds alcanzados")
					
				end
			end
		end

	end
end

function fn:SellDecors(Player : Player, Decor)
	if Client then
		self.DecorEvents:FindFirstChild('SellDecor'):FireServer(Player)
	else
		local Decor2 = self:GetDecorPlayer(Player, Decor)
		if Decor2 and not Decor2.Data.IsTool then
			if Decor2.Boolean:IsDescendantOf(Player) or (self.Added:IsA("House") and
				Decor2.Owner==Player.UserId and (not Decor2.ComprasFunct or not Decor2.ComprasFunct.CuadroSelect)
				or (self.Added.DataBaseHouse and tonumber(self.Added.DataBaseHouse.OwnerId)==Player.UserId)) then
				local PriceDevolver = not Decor2.Boolean.Value and Decor2.Data.Price or self.Cobros.Lerp(Decor2.Data.Price, .7)
				debris:AddItem(Decor2.Boolean,0)
				self.Cobros.Give(Player, PriceDevolver, true)
			end
		end
	end
end

function fn:InsertTableInTable(Table, name)
	if not Table or not name then return end
	Table[name] = Table[name] or {}
	return Table[name]
end

function fn:GetDecorPlayer(Player:Player,decor)
	if not self.IsActive then return warn(self.IsActive) end
	decor = Client and Player or decor
	if typeof(decor) ~= "Instance" then return end

	local IsValue = decor:IsA("ValueBase")
	local IsInstance = decor:IsA("Model") or decor:IsA("BasePart") or decor:IsA("Folder")
	if not IsValue and not IsInstance then return end
	
	local list = Client and self.DecorsPlayer:Get() or Player and self.DecorsPlayer[Player.UserId]
	if list then
		for _,section in list do
			for _,data in Client and section.Childs or section do
				if IsValue and data.Boolean == decor then
					return data
				elseif IsInstance and data.Disabled and
					(data.Disabled == decor or decor:IsDescendantOf(data.Disabled)) then
					return data
				end
			end
		end
	end
	
	if self.Added and self.Added:IsA("House") then
		for i,v in self.Added.DecorChild do
			if Client then
				if IsValue and i == decor or
					IsInstance and (decor == v or decor:IsDescendantOf(v)) then
					return {Boolean  = i, Model = v}
				end
			else
				for _,data in v do
					if IsValue and data.Boolean == decor then
						return data
					elseif IsInstance and (decor==data.Disabled or decor:IsDescendantOf(data.Disabled)) then
						return data
					end
				end
			end
		end
	end
	
end
function fn:SetDecorPlayer(Player:Player,decor:StringValue, model)
	if not self.IsActive then return end
	model = Client and decor or model
	decor = Client and Player or decor

	if not decor then return end

	if Client then
		if decor:IsDescendantOf(plr) then
			if not self:GetDecorPlayer(decor) then
				(self.DecorsPlayer:Find(decor.Name) or
					self.DecorsPlayer:Add(decor.Name, self.AddedDecor.new(decor.Name)))
					:Add(decor)
			end
		elseif typeof(model)=="Instance" and self.Added:IsA("House")
			and not self.Added.DecorChild[decor] then
			
			self.Added.DecorChild[decor] = model
			self.Added.DecorChanged:Fire(decor)
			local function Disconnect(Conected)
				for _,v in {decor, model} do
					if Conected and not self.Added.RemovedObjAction[v] then
						self.Added.RemovedObjAction[v] = v.AncestryChanged:Connect(function(_,p) if p then return end Disconnect() end)
					elseif not Conected and self.Added.RemovedObjAction[v] then
						self.Added.RemovedObjAction[v]:Disconnect()
						self.Added.RemovedObjAction[v] = nil
					end
				end
				if not Conected then
					self.Added.DecorChild[decor] = nil
					self.Added.DecorChanged:Fire(decor)
				end
			end
			Disconnect(true)
			
		end
	elseif Player and not self:GetDecorPlayer(typeof(Player)=="number" and {UserId = Player} or Player,decor) then
		local Object = self.AddedDecor.Added.new(decor, Player)
		if not Object then return end

		local list

		if game.PlaceId == self.PlaceId_PlsDonate or (typeof(Player)=="Instance" and decor:IsDescendantOf(Player)) then
			list = self:InsertTableInTable(self:InsertTableInTable(self.DecorsPlayer,Player.UserId), decor.Name)
			if not model then self.DecorEvents:WaitForChild('GetDecor'):FireClient(Player, decor) end
		elseif self.Added:IsA("House") and decor.Parent == self.Added.DataObjects then
			list = self:InsertTableInTable(self.Added.DecorChild, decor.Name)
		end

		if not list then return end

		table.insert(list, Object)
		
		local function UpdateData()
			local IsDestroyed = not decor:IsDescendantOf(game)
			if IsDestroyed then
				if Object.Disabled then Object:Delete() end
				for _,v in Object.actives do v:Disconnect() end
				local index = table.find(list, Object)
				if index then table.remove(list, index) end
			end
			if Object.IsHouseData and self.Added:IsA("House") and self.Added.DataBaseHouse
				and not self.Added.DataBaseHouse.IsDestroyed then
				self.Added.DataBaseHouse:UpdateStore("WorldContentStore", function(Data)
					Data = typeof(Data)=="table" and Data or {}
					Data.Objects = Data.Objects or {}
					local CacheObject = self.comprasFunct.GlobalData:Values(decor)
					for index, dataValue in Data.Objects do
						if dataValue.UnniqueKey == decor:GetAttribute("UnniqueKey") then
							if IsDestroyed then
								table.remove(Data.Objects, table.find(Data.Objects, dataValue))
								return Data
							elseif CacheObject then
								Data.Objects[index] = CacheObject
								return Data
							end
						end
					end
					if not IsDestroyed and CacheObject then
						table.insert(Data.Objects, CacheObject)
					end
					return Data
				end)
			end
		end
		
		table.insert(Object.actives, decor.AncestryChanged:Connect(UpdateData))
		if self.Added:IsA("House") and decor.Parent == self.Added.DataObjects then
			table.insert(Object.actives, Object.DataUpdating:Connect(UpdateData))
		end

		return Object
	end
end

function fn:GetInfoDecordataByBoolean(decor:BoolValue)
	if typeof(decor)=="Instance" then
		local attributes = decor:GetAttributes()
		local Colors = {}
		for index,value in attributes do
			if string.match(index:lower(),'color') and typeof(value) == 'Color3' then
				table.insert(Colors,{Name = index, Color = value})
				attributes[index] = nil
			end
		end
		attributes.Colors = Colors
		return attributes
	end
end

function fn:AddedCaracteristicasDecor(player,store,decor2,House)
	if Client or not decor2 or not decor2.Disabled then return end
	
	local parentTool = decor2.Data.IsTool and workspace:FindFirstChild("InteractableTools")
	decor2.Disabled.Parent = parentTool or store:IsA("Store") and store.Decors or store.ParentObjects
	
	if decor2.Data.IsProductPurchase and not decor2.ComprasFunct then
		local purchaseTable = self.comprasFunct.new(decor2)
		if purchaseTable then

			purchaseTable:Works()
			decor2.ComprasFunct = purchaseTable
			table.insert(self.ComprasList, purchaseTable)

			if store:IsA("House") then
				purchaseTable.Changed:Connect(function() decor2:UpdateData() end)
			end
			
		end
	end

	decor2:BindModelToClose(function()
		if decor2.Disabled then decor2:Delete() end
	end)
	
	if not decor2.IsTagAdded then
		decor2.IsTagAdded = true
		
		if decor2.Data.tag then
			decor2.Disabled:AddTag(decor2.Data.tag)
		elseif decor2.Data.MultiTag then
			local folder = decor2.Disabled:FindFirstChild(decor2.Data.MultiTag)
			if folder then
				for _,v :Model in folder:GetChildren() do
					if v:IsA("Model") then
						v:AddTag(decor2.Data.MultiTag)
					end
				end
			end
		end
		if decor2.Data.TagOn then
			for _,v in decor2.Data.TagOn do
				local ModelPart:Model = decor2.Disabled:FindFirstChild(v)
				if not ModelPart then continue end
				ModelPart:AddTag(v)
			end
		end
		
	end

end

function fn:UpdateDecor(player,decor,update)
	if not self.IsActive then return end

	local IsServer = Client and update
	update = Client and decor or update
	decor = Client and player or decor

	local decor2 = self:GetDecorPlayer(player,decor)
	local store = self:GetStore(Client and plr or player)

	if not store or not decor2 then return warn(decor, decor2, store) end

	decor2.ParentStore = store

	if store:IsA("House") then
		if decor2.IsA then
			if decor2.Boolean:IsDescendantOf(player) then
				if Client then
					return self:BuyDecors(decor2.Boolean, update)
				else
					return self:BuyDecors(player,decor2.Boolean, update)
				end
			elseif update then
				decor2:Update(update, IsServer)
			elseif not Client then
				return self:BuyDecors(player,decor2.Boolean, update)
			end
		elseif Client then
			if update then
				self.DecorEvents.Update:FireServer(decor2.Boolean, update)
			else
				return self:BuyDecors(decor2.Boolean, {})
			end
		end
	elseif store:IsA("Store") then
		if Client or not update or self:IsAviableToPlace(store, decor2) then
			decor2:Update(update, IsServer)
		else
			return warn("sin espacio")
		end
	end

	if Client then return end
	
	if decor2.Disabled then
		self:AddedCaracteristicasDecor(player, store, decor2)
		return decor2.Disabled
	elseif store:IsA("House") then
		return self:BuyDecors(player,decor2.Boolean,{})
	end

end

function fn:IsAviableToPlace(store, decore)
	return store.CountBuilds < self.MaxBuildPlace or (decore and decore.Disabled)
end
----------------------
function fn:GetCompraObject(Object)
	if not self.IsActive then return end
	for _,v in self.ComprasList do
		if v.Object.Disabled and (v.Object.Disabled == Object or (typeof(Object) == 'Instance' and Object:IsDescendantOf(v.Object.Disabled))) then
			return v
		end
	end
end
function fn:AccionarCompras(...)
	if not self.IsActive then return end
	if not Client then
		local parametro = {...}

		local Player,Object,Update = parametro[1],parametro[2],parametro[3]

		local objectTable = self:GetCompraObject(Object)

		if objectTable then
			local IsOwner = typeof(objectTable.Owner)=="number" and Player.UserId == objectTable.Owner
				or Player == objectTable.Owner

			if IsOwner then
				if Update then
					objectTable:Update(Update)
				else
					--Events:FindFirstChild('Other'):FindFirstChild('Commands'):FireClient(Player,6,objectTable.Object.Disabled)
				end
			else
				objectTable:Comprar(Player)
			end
		end

	else
		self.StoreEvents:FindFirstChild('ActionCompras'):FireServer(...)
	end
end
function fn:LikeCuadro(Player, Cuadro)
	if not self.IsActive then return end
	if Client then
		self.StoreEvents:FindFirstChild('LikeCuadro'):FireServer(Player)
	else
		local objectTable = self:GetCompraObject(Cuadro)
		if objectTable and not objectTable.IsInHouse then
			local IsOwner = Player == objectTable.Owner
			if not IsOwner then
				objectTable:Like(Player)
			end
		end
	end
end

function fn:OrdenarModelos()
	if not self.IsActive or Client then return end
	local newFolder = Instance.new("Folder")
	newFolder.Name = "decoration template"

	local otherFolder = game:GetService("ServerStorage"):FindFirstChild("decoration template")

	if otherFolder then
		local function changeParent(folder:Folder)
			if not folder then return end
			if folder:IsA("Folder") then
				for _,child in folder:GetChildren() do
					changeParent(child)
				end
			elseif folder:IsA("Model") and folder:FindFirstChild("Settings") then
				local Data = require(folder:FindFirstChild("Settings"))
				if Data.tag and folder:HasTag(Data.tag) then
					folder:RemoveTag(Data.tag)
				elseif Data.MultiTag then
					local models:Folder = folder:FindFirstChild(Data.MultiTag)
					if models then
						for _,v :Model in folder:GetChildren() do
							if v:IsA("Model") and v:HasTag(Data.MultiTag) then
								v:RemoveTag(Data.MultiTag)
							end
						end
					end
				end
				if Data.TagOn then
					for _,v in Data.TagOn do
						local ModelPart:Model = folder:FindFirstChild(v)
						if ModelPart and ModelPart:HasTag(v) then
							ModelPart:RemoveTag(v)
						end
					end
				end
				
				folder.Archivable = true
				folder.Parent = newFolder
			end
		end

		changeParent(otherFolder:FindFirstChild("Shared"))
		local name = game.PlaceId==self.PlaceId_PlsDonate and "Stores" or self.Added:IsA("House") and "House" or ""
		changeParent(otherFolder:FindFirstChild(name))
		changeParent(otherFolder:FindFirstChild(tostring(game.PlaceId)))

		otherFolder:Destroy()
		debris:AddItem(otherFolder,0)
	end

	if game.PlaceId~=self.PlaceId_PlsDonate and RS:FindFirstChild("StoreTemplates") then
		debris:AddItem(RS:FindFirstChild("StoreTemplates"),0)
	end

	newFolder.Parent = RS
end

function fn:ExitModeConstruccion(Player)
	if not self.IsActive then return end
	if Client then
		self.StoreEvents:FindFirstChild("ExitModeCOnstrccion"):FireServer()
	else
		local list = self.DecorsPlayer[Player.UserId]
		if list then
			for _,section in list do
				for _,data in Client and section.Childs or section do
					data.Boolean.Value = true
				end
			end
		end
		if self.Added and self.Added:IsA("House") then
			for i,v in self.Added.DecorChild do
				for _,data in v do
					if data.Boolean:GetAttribute("OwnerPlace") == Player.UserId then
						data.Boolean.Value = true
					end
				end
			end
		end
	end
end

function fn:ComprarMaterial(Player : Player, Material)
	if Client then
		self.StoreEvents:FindFirstChild("ComprarMaterial"):FireServer(Player)
	else
		local MaterialData = Player:FindFirstChild("Materials")
		local ListMaterials = string.split(MaterialData.Value,",")
		Material = DataDesing.FindMaterial(Material)

		if Material and Material.Price and not table.find(ListMaterials,tostring(Material.Key))
			and self.Cobros.charge(Player,Material.Price,true) then
			table.insert(ListMaterials, Material.Key)
			MaterialData.Value = table.concat(ListMaterials,",")
			self.SentNotification(Player,"Materials",'Compra existosa :)',5,
				2022095747,'rotate',
				8486683243)
		end
	end
end

function fn:ChangeDesing(Player:Player,Data,Valores)
	if Client then
		self.StoreEvents:FindFirstChild('ChangeDesing'):FireServer(Player, Data)
	else
		local store = self:GetStore(Player)
		if store then
			local NewValores = {}
			for index, value in Valores do
				if index~="Material" then
					NewValores[index] = value
				else
					local material = DataDesing.FindMaterial(value)
					if material then
						if (not material.Price and not material.IsWithGamepass) or (material.Price
							and table.find(string.split(Player:FindFirstChild("Materials").Value,","), tostring(material.Key)))
							or (material.IsWithGamepass and self.Added.Monetizacion:IsGamepassOwner(Player,material.IsWithGamepass)) then
							NewValores[index] = value
						end
					end
				end
			end
			store:ChangeDesing(Data,NewValores)
		end
	end
end

function fn:Works()
	if not self.IsActive then return end

	local ClaimEvent = Client and self.StoreEvents:WaitForChild('ClaimStore').OnClientEvent or self.StoreEvents:WaitForChild('ClaimStore').OnServerEvent
	ClaimEvent:Connect(function(...) if #{...} <= 0 then return end self:UpdateStore(...) end)
	local BuyEvent = Client and self.StoreEvents:WaitForChild('BuyStore').OnClientEvent or self.StoreEvents:WaitForChild('BuyStore').OnServerEvent
	BuyEvent:Connect(function(...) if #{...} <= 0 then return end self:BuyStore(...) end)
	local BuyDecorEvent = Client and self.DecorEvents:WaitForChild('BuyDecor').OnClientEvent or self.DecorEvents:WaitForChild('BuyDecor').OnServerEvent
	BuyDecorEvent:Connect(function(...) if #{...} <= 0 then return end self:BuyDecors(...) end)
	local getDecorEvent = Client and self.DecorEvents:WaitForChild('GetDecor').OnClientEvent or self.DecorEvents:WaitForChild('GetDecor').OnServerEvent
	getDecorEvent:Connect(function(...) if #{...} <= 0 then return end self:SetDecorPlayer(...) end)
	local UpdateDecor = Client and self.DecorEvents:WaitForChild('Update').OnClientEvent or self.DecorEvents:WaitForChild('Update').OnServerEvent
	UpdateDecor:Connect(function(...) if #{...} <= 0 then return end self:UpdateDecor(...) end)
	local StartClientPlayer = not Client and self.StoreEvents:WaitForChild('StartClientPlayer').OnServerEvent or self.StoreEvents:WaitForChild('StartClientPlayer').OnClientEvent
	StartClientPlayer:Connect(function(...) self:AddedPlayer(...) end)

	if not Client then
		self.StoreEvents:FindFirstChild("ExitModeCOnstrccion").OnServerEvent:Connect(function(...) self:ExitModeConstruccion(...) end)
		self.StoreEvents:WaitForChild('LikeCuadro').OnServerEvent:Connect(function(...) self:LikeCuadro(...) end)
		self.DecorEvents:WaitForChild('SellDecor').OnServerEvent:Connect(function(...) self:SellDecors(...) end)
		self.StoreEvents:WaitForChild('ChangeDesing').OnServerEvent:Connect(function(...) self:ChangeDesing(...) end)
		self.StoreEvents:WaitForChild('ComprarMaterial').OnServerEvent:Connect(function(...) self:ComprarMaterial(...) end)
		self.DecorEvents:WaitForChild('Delete').OnServerEvent:Connect(function(Player,Base)
			local decor = self:GetDecorPlayer(Player,Base)
			if decor and decor.Disabled and decor.ParentStore then
				if decor.ParentStore:IsA("Store") then
					decor:Delete()
				else
					self:BuyDecors(Player, decor.Boolean, {})
				end
			end
		end)
		self.StoreEvents:WaitForChild('ActionCompras').OnServerEvent:Connect(function(...) self:AccionarCompras(...)  end)
	else
		self.StoreEvents:FindFirstChild('StartClientPlayer'):FireServer()
	end

end

return fn.new()