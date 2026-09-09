local module = {}
module.__index = module

local client = game:GetService('RunService'):IsClient()
local Players = game:GetService("Players")
local LocalPlayer = client and Players.LocalPlayer

local MarkAdded = not client and require(script:WaitForChild("MarkAdded"))

module.Gamepass = {
	Premium = {
		Id = 838203071,
		PriceInRobux = 0,
		Icon = nil,
		Owner = not client and {} or nil,
		IsPurchase = client and Instance.new('BindableEvent'),
	},
	Material = {
		Id = 1931276289,
		PriceInRobux = 0,
		Icon = nil,
		Owner = not client and {} or nil,
		IsPurchase = client and Instance.new('BindableEvent'),
	},
	Vip = {
		Id = 1934283521,
		PriceInRobux = 150,
		Icon = nil,
		Owner = not client and {} or nil,
		IsPurchase = client and Instance.new('BindableEvent'),
	}
}

module.Products = {
	--[[VipButtonMoney = {
		Id = 3608698947,
		PriceInRobux = 5,
		Amount = {Credit = 150},
		Icon = 'rbxassetid://118177478762142',
		["Type"] = "Coins",
	},]]
}

module.ProductsPlayer = {}

function module:IsGamepassOwner(Player : Player, Gamepass)
	Gamepass = self:SearchGamePass(client and Player or Gamepass)
	Player = client and LocalPlayer or Player
	if Gamepass then
		local OwnerValue = (client and Gamepass.Owner) or (not client and Gamepass.Owner[Player.UserId])
		if OwnerValue==nil and not client then
			Gamepass.Owner[Player.UserId] = self.MPS:UserOwnsGamePassAsync(Player.UserId, Gamepass.Id)
			OwnerValue = Gamepass.Owner[Player.UserId]
			self.Events.Gamepass:FireClient(Player, self:VerifyGamepass(Player))
		end
		return not not OwnerValue
	end
end

function module:SearchGamePass(option)
	for index,value in self.Gamepass do
		if index == option or value.Id == option then return value end
	end
end
function module:SearchProduct(option)
	for index,value in self.Products do
		if index == option or value.Id == option or value == option then return value end
	end
end

function module:GetIcon(ID,Type)
	local nice, err = pcall(function()
		local product = self.MPS:GetProductInfo(ID, Type)
		return product
	end)
	return nice and err
end

function module:PurchaseProduct(Player, product)
	product = client and Player or product
	if client then
		local gamepass = self:SearchGamePass(product)
		if gamepass then
			return self.MPS:PromptGamePassPurchase(LocalPlayer,gamepass.Id)
		end
		local Product = self:SearchProduct(product)
		if Product then
			return self.MPS:PromptProductPurchase(LocalPlayer,Product.Id)
		end
	else
		self.Events:FindFirstChild("PurchaseProduct"):FireClient(Player, product)
	end
end

function module:VerifyGamepass(Player:Player)
	local list = {}
	if client and Player then
		for _,gamepass in Player do
			local pass = self:SearchGamePass(gamepass.ID)
			if pass then
				pass.Owner = gamepass.Was
				pass.Icon = gamepass.Icon
				pass.PriceInRobux = gamepass.Price
				if gamepass.Was and not gamepass.IsSiganalDone then
					gamepass.IsSiganalDone = not gamepass.IsSiganalDone
					pass.IsPurchase:Fire()
				end
			end
		end
	elseif not client and Player then
		for index,value in self.Gamepass do
			local was = value.Owner[Player.UserId] == nil and self.MPS:UserOwnsGamePassAsync(Player.UserId, value.Id) or value.Owner[Player.UserId]
			value.Owner[Player.UserId] = was
			self.Gamepass[index].DataPass = self.Gamepass[index].DataPass or self:GetIcon(value.Id, Enum.InfoType.GamePass)
			local Datas = self.Gamepass[index].DataPass or {}
			local list2 = {
				ID = value.Id,
				Was = was,
				Icon = string.format(self.FormatIcon, (tonumber(Datas.IconImageAssetId) or 0)),
				Price = Datas.PriceInRobux or 0,
			}
			if was and self.BeneficiosFuncs[index] then
				self.BeneficiosFuncs[index](self, Player)
			end
			table.insert(list, list2)
		end

	end
	return list
end

function module:PlayerRemoving(Player:Player)
	if not client then
		for _,value in self.Gamepass do
			value.Owner[Player.UserId] = nil
		end
		if self.ProductsPlayer[Player.UserId] and self.ProductsPlayer[Player.UserId].CargadoActive then
			task.cancel(self.ProductsPlayer[Player.UserId].CargadoActive)
		end
		self.ProductsPlayer[Player.UserId] = nil
		self:UnmarkPrompt(Player)
	end
end

function module:AddedProductPlayer(Player:Player, ProductId : number, InfoType : Enum.InfoType)
	if client then
		
		self.Events.AddedProductPlayer:FireServer(Player, ProductId)
		
	elseif typeof(ProductId) == 'number' and typeof(InfoType) == 'EnumItem' then
		
		local InventoryItems = Player and Player:FindFirstChild('InventoryItemsProucts')
		
		if InventoryItems and not InventoryItems:FindFirstChild(tostring(ProductId)) then
			
			local productss = self.ProductsPlayer[Player.UserId]
			productss = productss and productss.Data or {}
			
			for _,productDone in productss do
				if productDone.ProductId == ProductId then return end
			end
			
			local product = self.RecolectarInfo.LoadProductInfo(ProductId, InfoType)
			
			if product and self.listItems[tostring(product.assetType)] then
				
				self.AddItem(tostring(ProductId), InfoType.Name).Parent = InventoryItems
				
				if not self.ProductsPlayer[Player.UserId] then
					self:GetProductPlayer(Player)
				else
					table.insert(productss, product)
					self.Events.ProductsPlayer:FireClient(Player,productss)
				end
				
			end
			
		end
	end
end

function module:GetProductPlayer(Player:Player)
	if client then
		if Player then
			self.ProductsPlayer = Player
		else
			self.Events.ProductsPlayer:FireServer()
		end
	elseif Player then
		local DataLastUpdate = self.ProductsPlayer[Player.UserId]
		if not DataLastUpdate or (DateTime.now().UnixTimestampMillis-DataLastUpdate.Cargado) / 1000 >= 60 then
			local newAdded = {
				Cargado = DateTime.now().UnixTimestampMillis,
				Data = {},
			}
			newAdded.CargadoActive = task.spawn(function()
				
				newAdded.Data = self.RecolectarInfo.loadItems(Player)
				
				for _,product : StringValue in Player:WaitForChild('InventoryItemsProucts'):GetChildren() do
					--local productSearched = self:GetIcon(tonumber(product.Name), Enum.InfoType[product.Value])
					local productSearched = self.RecolectarInfo.LoadProductInfo(tonumber(product.Name), Enum.InfoType[product.Value])
					if productSearched and self.listItems[tostring(productSearched.assetType)] then
						table.insert(newAdded.Data, productSearched)
					else
						product:Destroy()
					end
				end
				
				table.sort(newAdded.Data, function(a,b) return a.price < b.price end)
				
				if Player:IsDescendantOf(game) then
					self.Events.ProductsPlayer:FireClient(Player,newAdded.Data)
				end
				
				newAdded.CargadoActive = nil
			end)
			
			self.ProductsPlayer[Player.UserId] = newAdded
		end
	end
end

function module:VerificarCompraProduct(Info)
	local Player = Players:GetPlayerByUserId(Info.PlayerId)
	if not Player then return end
	
	for _,product in self.Products do
		if product.Id == Info.ProductId then
			if product.Type == "Coins" then
				self.Cobros.Give(Player,product.Amount,true)
				return true
			elseif product.Type == "Event" then
				local evento = self.BeneficiosFuncs[product.Name]
				if not evento then return end
				task.defer(evento, self, Player)
				return true
			else
				return
			end
		end
	end
	
end

-----------------
function module:MarkPrompt(Player : Player, Id, InfoType)
	if client or not Player or self.PromptsPlayer[Player] then return end
	local data = MarkAdded.new(Player, Id, InfoType)
	self.PromptsPlayer[Player] = data
	return data
end
function module:UnmarkPrompt(Player : Player, Id, was, InfoType)
	if client or not Player or not self.PromptsPlayer[Player] then return end
	self.PromptsPlayer[Player]:decition(Id, was, InfoType)
	self.PromptsPlayer[Player] = nil
end
-----------------

function module:Works()
	local EventProductPlayer = client and self.Events.ProductsPlayer.OnClientEvent or self.Events.ProductsPlayer.OnServerEvent
	EventProductPlayer:Connect(function(...) self:GetProductPlayer(...) end)
	
	if client then
		self.MPS.PromptBulkPurchaseFinished:Connect(function(Player : Player)
			if Player == LocalPlayer then
				self.Events.PromptBulkPurchaseFinished:FireServer()
			end
		end)
		self.Events:FindFirstChild("PurchaseProduct").OnClientEvent:Connect(function(...) self:PurchaseProduct(...) end)
		self.Events.Gamepass.OnClientEvent:Connect(function(...) self:VerifyGamepass(...) end)
		self.Events.Gamepass:FireServer()
		self:GetProductPlayer()
	else
		self.Events.AddedProductPlayer.OnServerEvent:Connect(function(...) self:AddedProductPlayer(...) end)
		self.Events.ProductsPlayer.OnServerEvent:Connect(function(...) self:GetProductPlayer(...) end)
		self.Events.PromptBulkPurchaseFinished.OnServerEvent:Connect(function(Player) self:UnmarkPrompt(Player) end)
		self.Events.Gamepass.OnServerEvent:Connect(function(Player)
			self.Events.Gamepass:FireClient(Player, self:VerifyGamepass(Player))
		end)
		self.MPS.PromptGamePassPurchaseFinished:Connect(function(Player,ID,Was)
			self:UnmarkPrompt(Player, ID, Was, Enum.InfoType.GamePass)
			local pass = self:SearchGamePass(ID)
			if not pass then
				self:VerifyVentasPlayer(Player,ID,Was,Enum.InfoType.GamePass)
			elseif Was then
				pass.Owner[Player.UserId] = Was
				self.Events.Gamepass:FireClient(Player, self:VerifyGamepass(Player))
			end
		end)
		self.MPS.PromptPurchaseFinished:Connect(function(a,b,c)
			self:UnmarkPrompt(a, b, c, Enum.InfoType.Asset)
			self:VerifyVentasPlayer(a,b,c,Enum.InfoType.Asset)
		end)
		---------------------------------------------------------------------------------------
		--ESTO SE ESTA USANDO PARA CANCELAR ALGUNA ACCION CASO QUE SE HAYAN MEZCLADOS LOS PROMPTSPURCHASES Y ASI MEJORAR LA SEGURIDAD EN CIERRES DE PROMPTS DE ROBLOX
		self.MPS.PromptProductPurchaseFinished:Connect(function(UserId : number, ProductId : number, Was : boolean)
			self:UnmarkPrompt(Players:GetPlayerByUserId(UserId), ProductId, Was, Enum.InfoType.Product)
		end)
		self.MPS.PromptBundlePurchaseFinished:Connect(function(Player : Player, bundleId : number, Was : boolean)
			self:UnmarkPrompt(Player, bundleId, Was, Enum.InfoType.Bundle)
		end)
		self.MPS.PromptSubscriptionPurchaseFinished:Connect(function(Player : Player, suscribeId : string, Was : boolean)
			self:UnmarkPrompt(Player, suscribeId, Was, Enum.InfoType.Subscription)
		end)
		self.MPS.PromptRobloxSubscriptionPurchaseFinished:Connect(function(Player : Player, Was : boolean)
			self:UnmarkPrompt(Player, false, Was, Enum.InfoType.Subscription)
		end)
		---------------------------------------------------------------------------------------
	end
end

function module.new()
	local self = setmetatable({
		MPS = game:GetService('MarketplaceService'),
		Events = game:GetService('ReplicatedStorage'):WaitForChild('Events'):WaitForChild('Monetization'),
		BeneficiosFuncs = not client and require(script:WaitForChild('Beneficios')),
		RecolectarInfo = not client and require(script:WaitForChild('MainModule')),
		ActivePlayer = {},
		PromptsPlayer = {},
		FormatIcon = "rbxthumb://type=Asset&id=%d&w=420&h=420",
		listItems = {
			["11"] = Enum.InfoType.Asset,
			["12"] = Enum.InfoType.Asset,
			["0"] = Enum.InfoType.GamePass,
			["34"] = Enum.InfoType.GamePass,
		},
	}, module)
	
	self:Works()
	
	return self
end

return module.new()
