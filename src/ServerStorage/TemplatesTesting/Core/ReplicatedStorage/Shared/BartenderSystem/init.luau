local module = {}
module.__index = module

local CollS = game:GetService("CollectionService")

local TagBarra = "BarraBartender"

local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local RunS = game:GetService("RunService")
local IsClient = RunS:IsClient()
local Players = game:GetService("Players")
local debris = game:GetService("Debris")
local ClientFolder = RS:WaitForChild("Client")

local BarraInstance = require(script:WaitForChild("Instance"))
local EventCustom = require(ClientFolder:WaitForChild("Event"))

function GetEventRemote(Remote : RemoteEvent | RemoteFunction)
	if not Remote then return end
	if Remote:IsA("RemoteEvent") then
		return IsClient and Remote.OnClientEvent or Remote.OnServerEvent
	elseif Remote:IsA("RemoteFunction") then
		return IsClient and Remote.OnClientInvoke or Remote.OnServerInvoke
	end
end

function module.new()
	local self = setmetatable({

		Barras = {},
		actives = {},
		IsActive = false,
		Events = RS:WaitForChild("Events"):WaitForChild("BartenderSystem"),
		TagMenuTools = "MenuBar____",
		
	}, module)
	
	if IsClient then
		self:init()
	else
		self.IsNotFloor = EventCustom.new()
		self.IsNotFloor:Connect(function(uniqueKey)
			task.defer(self.IsNotFloor.Destroy, self.IsNotFloor)
			self.IsNotFloor = uniqueKey
		end)
	end
	
	return self
end

function module:Added(model : Model, NoUpdateInfo)
	if self.Barras[model] then return end
	local insta = BarraInstance.new(model)
	if not insta then return end
	insta.boliche = self
	insta:init()
	self.Barras[model] = insta
	if IsClient and not NoUpdateInfo then insta:SetInfoClient() end
end
function module:Removed(model : Model)
	local insta = self.Barras[model]
	if not insta then return end
	insta:destroy()
	self.Barras[model] = nil
end
function module:Get(model : Model)
	local object = typeof(model)=="Instance" and self.Barras[model]
	return not not (object and object.actives) and object
end

function module:GetDrinks()
	if self.Menu then return end
	local Menu = {}
	local function added(model:Model, Starting)
		if Menu[model.Name] or (not IsClient and model:IsDescendantOf(SS)) then return end
		local Settings = model:FindFirstChild("DataMenu")
		if not Settings then return end
		Settings = require(Settings)
		local list = {
			Model = model,
			Settings = Settings,
			Stack = {},
			Changed = EventCustom.new(),
		}
		Menu[model.Name] = list
	end
	
	local function remove(model:Model)
		local modelExample = Menu[model.Name]
		if modelExample and modelExample.Model == model then
			modelExample:SetAttribute("Deleted", true)
			Menu[model.Name] = nil
		end
	end
	
	for _,v in CollS:GetTagged(self.TagMenuTools) do added(v, true) end
	table.insert(self.actives, CollS:GetInstanceAddedSignal(self.TagMenuTools):Connect(added))
	table.insert(self.actives, CollS:GetInstanceRemovedSignal(self.TagMenuTools):Connect(remove))
	self.Menu = Menu
end

function module:PutDrop(Player : Player, model : Tool)
	if not IsClient and model then
		local drop = self.Drops[Player] and table.find(self.Drops[Player], model)
		if drop then
			table.remove(self.Drops[Player], drop)
		end
	end
end
function module:RemoveDrops(Player : Player)
	if IsClient then return end
	if self.Drops[Player] then
		for _, model in self.Drops[Player] do
			debris:AddItem(model,0)
		end
		self.Drops[Player] = nil
	end
end

function module:actionBarras(action,...)
	local params = {...}
	if action == "StartClient" then
		if not IsClient then
			local Player:Player = params[1]
			local DataClient = {}
			for model, barra in self.Barras do
				local list = {
					model = model,
					InfoClient = barra:GetInfoClient(),
					Stack = {}
				}
				for NameProduct, Data in self.Menu do
					local DataModel = Data.Stack[model] or Data.Settings.MaxStack
					list.Stack[NameProduct] = DataModel
				end
				table.insert(DataClient, list)
			end
			self.Events.StartClient:FireClient(Player, DataClient)
		elseif typeof(params[1]) == "table" then
			for _, dataBarra in params[1] do
				local bar = self:Get(dataBarra.model)
				if not bar then continue end
				bar:SetInfoClient(dataBarra.InfoClient)
				for NameProduct, CountStack in dataBarra.Stack do
					local Menu = self.Menu and self.Menu[NameProduct]
					if not Menu then continue end
					Menu.Stack[dataBarra.model] = CountStack
				end
			end
		end
	elseif action == "InfoClient" then
		local bar = self:Get(params[IsClient and 1 or 2])
		if not bar then return end
		local a,b = not IsClient and 3 or 2, not IsClient and 1 or 3
		bar:SetInfoClient(params[a], params[b])
	elseif action == "ChangeStack" then
		local Product = self.Menu and self.Menu[params[IsClient and 1 or not IsClient and 2]]
		if not Product then return end
		if not IsClient then
			local list = {}
			for model, CountStack in Product.Stack do
				table.insert(list,{index = model, value = CountStack})
			end
			if params[1] then
				self.Events.ChangeStack:FireClient(params[1],params[2],list)
			else
				self.Events.ChangeStack:FireAllClients(params[2],list)
			end
			Product.Changed:Fire()
		elseif typeof(params[2]) == "table" then
			Product.Stack = Product.Stack or {}
			for _,data in params[2] do
				if not data.index then continue end
				local lastStack = Product.Stack[data.index]
				if lastStack ~= data.value then
					Product.Stack[data.index] = data.value
					Product.Changed:Fire(data.index)
				end
			end
		else
			self.Events.ChangeStack:FireServer(params[1])
		end
	elseif not IsClient then
		local Player:Player = params[1]
		if action == "pedir" then
			local Model = params[2]
			local NamePedido = params[3]
			local bar = self:Get(Model)
			if not bar then return end
			bar:Pedir(Player, NamePedido)
		elseif action == "close" then
			local pedidoProcess = self.Pedidos[Player]
			if not pedidoProcess then return end
			pedidoProcess:ClosePedido(Player)
		end
	end
end

function module:init()
	if self.IsActive then return end
	self.IsActive = true

	self:GetDrinks()
	
	for _,model in CollS:GetTagged(TagBarra) do self:Added(model, true) end
	table.insert(self.actives, CollS:GetInstanceAddedSignal(TagBarra):Connect(function(...) self:Added(...) end))
	table.insert(self.actives, CollS:GetInstanceRemovedSignal(TagBarra):Connect(function(...) self:Removed(...) end))
	
	table.insert(self.actives, GetEventRemote(self.Events:WaitForChild("StartClient")):Connect(function(...) self:actionBarras("StartClient",...) end))
	table.insert(self.actives, GetEventRemote(self.Events:WaitForChild("InfoClient")):Connect(function(...) self:actionBarras("InfoClient",...) end))
	table.insert(self.actives, GetEventRemote(self.Events:WaitForChild("ChangeStack")):Connect(function(...) self:actionBarras("ChangeStack",...) end))
	
	if IsClient then
		
		self.Events:WaitForChild("StartClient"):FireServer()
		
	else
		
		self.Pedidos = {}
		self.Drops = {}
		
		table.insert(self.actives, self.Events:WaitForChild("ClosePedido").OnServerEvent:Connect(function(...) self:actionBarras("close",...) end))
		table.insert(self.actives, self.Events:WaitForChild("Pedir").OnServerEvent:Connect(function(...) self:actionBarras("pedir",...) end))
		
		table.insert(self.actives, Players.PlayerRemoving:Connect(function(player)
			self:RemoveDrops(player)
			self:actionBarras("close",player)
		end))
		
	end
end

return module.new()