local module = {}
module.__index = module

local Players = game:GetService("Players")
local EventCustom = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("Event"))

function module.new(objeto)
	if (typeof(objeto) == 'table' and objeto.Data) then
		local IsHouse = objeto.ParentStore:IsA("House")
		local self = setmetatable({
			Object = objeto,
			Owner = IsHouse and tonumber(objeto.ParentStore.DataBaseHouse.OwnerId) or objeto.ParentStore.Owner,
			Changed = EventCustom.new(),
		}, module)
		self.IsInHouse = IsHouse
		return self
	end
end

function module:GetProduct(ID)
	if typeof(ID)~='number' then return end
	local products = self.Monetizacion.ProductsPlayer[self.Owner.UserId]
	products = products and products.Data or {}
	for _,product in products do
		if product.id == ID then
			return product
		end
	end
end

function module:GetAssetType(product)
	return typeof(product)=='table' and self.Monetizacion.listItems[tostring(product.assetType)]
end

function module:Update(product)
	if self.Destroyed then return warn("modelo destruido") end
	if self.IsLoading then
		task.cancel(self.IsLoading)
		self.IsLoading = nil
	end
	if self.IsInUse then return warn("espera que se compre el cuadro") end

	local OwnerId = typeof(self.Owner) == "number" and self.Owner or self.Owner.UserId
	local Owner = Players:GetPlayerByUserId(OwnerId)

	local _,DataStore:BoolValue = self.Object:GetData()
	if DataStore then
		local cuadro = product.Pintura and Owner and self.Cuadros:GetData(Owner, product.Pintura)
			and (self.CuadroSelect==product.Pintura or self.Cuadros:IsNotCuadroInUse(product.Pintura,self.Object.ParentStore,self.Object.Boolean.Name))
		local Cache = cuadro and self.Cuadros:GetCache(Owner, product.Pintura)
		cuadro = Cache and cuadro

		if self.CuadroSelect and self.IsInHouse then
			self.Cuadros:UnmarkPaint(Owner,self.CuadroSelect,self.Object.UnniqueKey)
		end
		self.CuadroSelect = cuadro and product.Pintura or nil

		self.ProductActive = cuadro and self.Object.Disabled:HasTag("Paint") and self.Cuadros:IsNotPaintInHouse(Owner, product.Pintura)
			and self:GetAssetType(self:GetProduct(product.Product)) and product.Product or nil

		local MarcoUpdating
		if cuadro and product.Marco then
			local index, marcoInstance:BoolValue = self.Cuadros:IsMarcoAviable(Owner, product.Marco)
			if index and marcoInstance then
				marcoInstance:SetAttribute(index, true)
				MarcoUpdating = marcoInstance
			end
		end

		if self.Marco then
			if not self.IsInHouse or Owner then
				local instancia = not self.IsInHouse and self.Marco or Owner:FindFirstChild("MarcosPaint"):FindFirstChild(self.Marco)
				if instancia then
					for index, value in instancia:GetAttributes() do
						if value then
							instancia:SetAttribute(index, false)
							break
						end
					end
				end
			elseif self.IsInHouse and not Owner and not MarcoUpdating then
				MarcoUpdating = {Name = self.Marco}
			end
		end

		self.Marco = MarcoUpdating and (not self.IsInHouse and MarcoUpdating or MarcoUpdating.Name)

		DataStore:SetAttribute('Marco', self.Marco and product.Marco or self.Marco)
		DataStore:SetAttribute('CuadroKey', self.CuadroSelect)
		DataStore:SetAttribute('ProductId', self.ProductActive)

		self.Object.Disabled:SetAttribute("IsLoadPaint", not not self.CuadroSelect)
		self.Object.Disabled:SetAttribute("Marco", self.Marco and product.Marco)

		self.RespaldoCache = Cache
		self.Cuadros:UpdateCuadros(Owner or {UserId = OwnerId}, self.Object.Disabled, Cache)

		if self.CuadroSelect and self.IsInHouse then
			self.Cuadros:MarkPaint(Owner,self.CuadroSelect,self.Object.UnniqueKey)
		end

		self.Changed:Fire()
	else
		warn("no se encontro este dataaaaaaaaaaaaa del cuadro")
	end

end

function module:Comprar(Player:Player)
	if self.Destroyed or self.IsLoading or self.IsInHouse then return end
	if typeof(Player) == 'Instance' and Player:IsA('Player') and Player:IsDescendantOf(game) then
		if Player ~= self.Owner and self.ProductActive and not self.IsInUse then

			if not self.ProcesosVentas[Player.UserId] then

				local Product = self:GetProduct(self.ProductActive)
				local assetType = self:GetAssetType(Product)

				local procesoVenta = Product and {

					PlayerId = {--//el que compra
						UserId = Player.UserId,
						Name = Player.Name,
						Type = 'User',
					},

					PriceInRobux = tonumber(Product.price) or 0,

					VendedorId = {--//el que vende
						UserId = self.Owner.UserId,
						Name = self.Owner.Name,
						Type = 'User',
					},

					Objeto = self,
				}

				if assetType == Enum.InfoType.GamePass then
					local mark = self.Monetizacion:MarkPrompt(Player,self.ProductActive,assetType)
					if mark then
						warn('comprar producto')
						mark:BindToClose(function(a,b,c,state)
							if state == "Closed" then
								self.Monetizacion:VerifyVentasPlayer(a,b,c)
							end
						end)
						self.IsInUse = Player
						self.ProcesosVentas[Player.UserId] = procesoVenta
						self.Monetizacion.MPS:PromptGamePassPurchase(Player, self.ProductActive)
					else
						warn("tienes un producto activo en compra")
					end
				elseif assetType == Enum.InfoType.Asset then
					local mark = self.Monetizacion:MarkPrompt(Player,self.ProductActive,assetType)
					if mark then
						warn('comprar gamepass')
						mark:BindToClose(function(a,b,c,state)
							if state == "Closed" then
								self.Monetizacion:VerifyVentasPlayer(a,b,c)
							end
						end)
						self.IsInUse = Player
						self.ProcesosVentas[Player.UserId] = procesoVenta
						self.Monetizacion.MPS:PromptPurchase(Player, self.ProductActive)
					else
						warn("tienes un producto activo en compra")
					end
				else
					warn('producto no encontrado')
				end

			end

		else
			warn('no hay producto en venta')
		end
	else
		warn('no es un jugador')
	end
end

function module:Like(Player:Player)
	if self.Destroyed or self.IsLoading or self.IsInHouse then return end
	if self.CuadroSelect then
		local Cache = self.Cuadros.GlobalDataCache[self.Owner]
		Cache = Cache and Cache[self.CuadroSelect or "NotFound"]
		if Cache then
			local format = self.Cuadros.Format.format(Cache)
			local extras = self.Cuadros.Format.GetInfoExtra(format[5])
			local likes = self.Cuadros.Format.GetInfoExtra(extras[1]) or {}
			if not table.find(likes, tostring(Player.UserId)) then
				self.Cuadros:like(Player, self.CuadroSelect)
				table.insert(likes, tostring(Player.UserId))
				extras[1] = string.format("{%s}", table.concat(likes,','))
				extras = string.format("(%s)", table.concat(extras,","))
				format[5] = extras
				format = self.Cuadros.Format.InvertFormat(format)
				self.Cuadros:AddedCache(self.Owner,self.CuadroSelect,format)
				self.Cuadros:UpdateCuadros(self.Owner, self.Object.Disabled, format)
				self.RespaldoCache = format
			end
		end
	end
end

local SEND_RETRIES = 5

function module:ClosePurchased(was)
	if was and self.IsInUse then
		local cache
		local keyCuadro = self.CuadroSelect
		local buyer = self.IsInUse
		local ownerId = typeof(self.Owner) == "number" and self.Owner or self.Owner.UserId
		local venta = self.ProcesosVentas[buyer.UserId]

		cache = self.Cuadros.GlobalDataCache[self.Owner]
		cache = cache and cache[keyCuadro]

		local function quitarDelVendedor(data)
			local index = table.find(data.paints.keys, keyCuadro)
			if index then
				table.remove(data.paints.keys, index)
			end
			return data
		end

		local function darAlComprador(data)
			if not table.find(data.paints.keys, keyCuadro) then
				table.insert(data.paints.keys, keyCuadro)
			end
			return data
		end

		local sellerStore = self.PlayerDataService.get(self.Owner)
		local buyerStore = self.PlayerDataService.get(buyer)
		local poseemosAmbos = sellerStore and sellerStore:canWrite() and buyerStore and buyerStore:canWrite()

		if poseemosAmbos then
			local moved, motivo = self.DataKit.transfer(
				{ store = sellerStore, update = quitarDelVendedor },
				{ store = buyerStore, update = darAlComprador }
			)
			if not moved then
				warn("[Compras] transfer del cuadro falló:", motivo)
			end

			local data = self.Cuadros.DataPlayer[self.Owner]
			if data then
				local index = table.find(data, keyCuadro)
				if index then
					table.remove(data, index)
					self.Cuadros:Load(self.Owner)
				end
			end
			self.Cuadros:RemoveCache(self.Owner, keyCuadro)

			if self.Marco then
				local function changed(IsChanged)
					for index, value in self.Marco:GetAttributes() do
						if (value or IsChanged) then
							self.Marco:SetAttribute(index, nil)
							return
						end
					end
					changed(true)
				end
				changed()
			end

		else
			local payload = {
				kind = "paintSold",
				keyCuadro = keyCuadro,
				marco = self.Marco and self.Marco.Name,
				price = venta and venta.PriceInRobux,
				buyerId = buyer.UserId,
				sellerHere = Players:GetPlayerByUserId(ownerId) ~= nil,
			}

			local sent = self.Profiles.WorldsPlayer.send(tostring(ownerId), payload)
			local intento = 1
			while not sent and intento <= SEND_RETRIES do
				task.wait(self.Cuadros.ColaLoad.TimeExhauste / self.Cuadros.ColaLoad.MaxLoads)
				intento += 1
				sent = self.Profiles.WorldsPlayer.send(tostring(ownerId), payload)
			end

			if not sent then
				warn("[Compras] no se pudo encolar la baja del cuadro", keyCuadro, "para", ownerId)
			end

			if buyerStore and buyerStore:canWrite() then
				buyerStore:update(darAlComprador)
			end
		end

		local data = self.Cuadros.DataPlayer[self.IsInUse]
		if data then
			table.insert(data, keyCuadro)
			self.Cuadros:Load(self.IsInUse, data)
		end

		local esperar = task.wait
		local timee = self.Cuadros.ColaLoad.TimeExhauste/self.Cuadros.ColaLoad.MaxLoads

		local function GetData()
			local Sucesss,DataPintura = true, cache
			if not DataPintura then
				Sucesss,DataPintura = self.GlobalData:GetData("DataPinturas", keyCuadro)
				if Sucesss and not DataPintura then
					DataPintura = self.RespaldoCache
				end
			end
			DataPintura = self.Cuadros.Format.SeguridadFormato(DataPintura)
			if Sucesss and DataPintura then
				DataPintura = self.Cuadros.Format.InvertFormat(self.Cuadros.Format.change(DataPintura,self.IsInUse.UserId,3))
				local function Cambiar()
					local success,_ = self.GlobalData:SetData('DataPinturas', keyCuadro, DataPintura)
					if not success then
						warn('error al cambiar de dueño este cuadro, intentando de nuevo.')
						Cambiar(esperar(timee))
					else
						warn('Se ha cambiado el dueño del cuadro')
						self.Cuadros:AddedCache(self.IsInUse,keyCuadro,DataPintura)
					end
				end
				Cambiar()
			elseif not Sucesss then
				warn('error al obtener el dato del cuadro, intentando de nuevo.')
				GetData(esperar(timee))
			else
				warn('lo siento, el cuadro no existe.')
			end
		end

		GetData()
		self.IsInUse = nil

		self:Update({})

		for _,data in self.Cuadros.Cuadros do
			if data.CuadroSelect == keyCuadro then
				data:Update({})
			end
		end

	end

	self.IsInUse = nil
end

function module:destroy()
	if self.Destroyed then return end
	if self.IsLoading then task.cancel(self.IsLoading) end
	self.Destroyed = true

	self.Changed:Destroy()

	if not self.IsInHouse then
		if self.Marco then
			for index, value in self.Marco:GetAttributes() do
				if value then
					self.Marco:SetAttribute(index, false)
					break
				end
			end
		end
	else
		local OwnerId = typeof(self.Owner) == "number" and self.Owner or self.Owner.UserId
		local Owner = Players:GetPlayerByUserId(OwnerId)
		if Owner then
			if self.CuadroSelect then
				self.Cuadros:UnmarkPaint(Owner,self.CuadroSelect,self.Object.UnniqueKey)
			end
			if self.Marco then
				local instanciaMarco = Owner:FindFirstChild("MarcosPaint"):FindFirstChild(self.Marco)
				if instanciaMarco then
					for index, value in instanciaMarco:GetAttributes() do
						if value then
							instanciaMarco:SetAttribute(index, false)
							break
						end
					end
				end
			end

		elseif self.CuadroSelect then
			warn("esto no deberia de pasar, error catastrofico si se printea esto")
		end
	end
	
	local index = table.find(self.Cuadros.Cuadros, self)
	if index then table.remove(self.Cuadros.Cuadros, index) end
	self.Object.ComprasFunct = nil
end

function module:Works()
	if self.Object and self.Object.Disabled then

		local OwnerId = typeof(self.Owner) == "number" and self.Owner or self.Owner.UserId
		local Owner = Players:GetPlayerByUserId(OwnerId)

		self.Object.Disabled:SetAttribute('Owner', OwnerId)

		local DataLoad,DataStore:BoolValue = self.Object:GetData()

		if DataStore then

			local data = Owner and self.Cuadros:GetData(Owner, DataLoad.CuadroKey) or self.IsInHouse

			self.CuadroSelect = data and DataLoad.CuadroKey or nil
			self.ProductActive = self.CuadroSelect and DataLoad.ProductId or nil
			DataStore:SetAttribute('CuadroKey', self.CuadroSelect)
			DataStore:SetAttribute('ProductId', self.ProductActive)
			self.Object.Disabled:SetAttribute("IsLoadPaint", not not self.CuadroSelect)
			local MarcoUpdating = self.CuadroSelect and DataLoad.Marco
			if MarcoUpdating then
				if self.IsInHouse then
					self.Marco = MarcoUpdating
				else
					local index, marcoInstance:BoolValue = self.Cuadros:IsMarcoAviable(Owner, MarcoUpdating)
					if index and marcoInstance then
						marcoInstance:SetAttribute(index, true)
						self.Marco = marcoInstance
					else
						MarcoUpdating = nil
					end
				end
			end
			self.Object.Disabled:SetAttribute("Marco", MarcoUpdating)

			if self.CuadroSelect then
				local key = self.CuadroSelect
				local startTime = tick()

				local function LoadedHouse()
					local Sucess, Cache = self.Cuadros.DataBase:GetData("DataPinturas",self.CuadroSelect)
					print(Sucess, Cache)
					if Sucess then
						self.IsLoading = nil
						if Cache and self.Cuadros.Format.IsOwner(OwnerId, Cache) then
							self.Cuadros:UpdateCuadros({UserId = OwnerId}, self.Object.Disabled, Cache)
						else
							self:Update({})
						end
					else
						LoadedHouse(task.wait(1))
					end
				end

				self.IsLoading = task.spawn(function()
					if Owner then
						while task.wait(.2) do
							if key~=self.CuadroSelect then break end

							local Cache = self.Cuadros.GlobalDataCache[Owner]
							Cache = Cache and Cache[key]

							if Cache or tick()-startTime>=30 or not self.Object.Disabled or not Owner.Parent then

								if Cache then
									self.Cuadros:UpdateCuadros(Owner, self.Object.Disabled, Cache)
								elseif self.Object.Disabled then
									if not Owner.Parent and self.IsInHouse then
										return LoadedHouse(task.wait(.5))
									else
										self.IsLoading = nil
										self:Update({})
									end
								end

								break
							end
						end
					elseif self.IsInHouse then
						return LoadedHouse(task.wait(.5))
					end
					self.IsLoading = nil
				end)
			end

		end

	end
end

return module
