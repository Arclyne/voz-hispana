local module = {}
module.__index = module

local RunS = game:GetService("RunService")
local NPC = script:WaitForChild("Rig")
local IsClient = RunS:IsClient()
local debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local ClientFolder = RS:WaitForChild("Client")
local Players = game:GetService("Players")

local EventCustom = require(ClientFolder:WaitForChild("Event"))
local CharacterCustom = not IsClient and require(RS:WaitForChild("Shared"):WaitForChild("NPC_Custom"))

local ActionData = not IsClient and require(script:WaitForChild("ActionsBartender"))
local AttributeCustom = IsClient and require(ClientFolder:WaitForChild("Attributes"))
local Disconnects = require(ClientFolder:WaitForChild("Disconnects"))
local cobros = require(ClientFolder:WaitForChild("EconomySystem"):WaitForChild("Collections"))

local InfoClientChanged = {"Occuped"}
local template = IsClient and script:FindFirstChild("Template") or nil

function module.new(model)
	assert(typeof(model)=="Instance" and model:IsA("Model"), "No es un objeto...")
	local self = setmetatable({
		
		model = model,
		Pedidos = {},
		
		AddPedido = EventCustom.new(),
		RemovePedido = EventCustom.new(),
		
		UserBlockPedidos = not IsClient and {} or nil,
		
	}, module)
	
	do 
		if IsClient then
			self.ScreenGui = model:WaitForChild("ModelJob"):WaitForChild("ClickPart"):WaitForChild("Screen"):WaitForChild("SurfaceGui")
			self.ProductFrame = self.ScreenGui:WaitForChild("Frame"):WaitForChild("Products")
		end
	end
	
	return self
end

function module:CreateCharacter()
	if IsClient or not self.actives then return end
	if not self.Character then
		local clone = script:FindFirstChild("Rig"):Clone()
		clone.Parent = self.model
		self.Character = CharacterCustom:add(clone)
		self.Character:PivotTo(self.model:FindFirstChild("CharacterPosition").CFrame)
		self.Character:Decore()
		self.Character.animator:AddAnimation(ActionData.FolderAnimations)
		self:ActionCharacter()
	end
end
function module:RemoveCharacter()
	if IsClient then return end
	if self.Character then
		local cha = self.Character
		self.Character = nil
		debris:AddItem(cha.model,0)
		self:CancelPreparar(cha)
		Disconnects.Only(self.actives, "ChangeWorldPivot")
	end
end

function module:ActionCharacter(intent)
	if not self.actives or IsClient or not self.Character then return end
	Disconnects.Only(self.actives, "ChangeWorldPivot")
	
	local PointRuta = self.model:FindFirstChild("CharacterPosition")
	local Ocupant = self.Character.Ocupant
	local CharacterPosition:BasePart = self.model:FindFirstChild("CharacterPosition")
	local Size = CharacterPosition.Size / 2
	
	if Ocupant then
		if Ocupant.Occuped == self.Character then
			if not Ocupant.Starting then
				Ocupant.Starting = true
				local ruta = self.Character.FormatPath.FormatPath(Ocupant.Settings.Preparacion)
				if intent then
					table.insert(ruta, 1, {
						Action = "WalkTo",
						Process = CharacterPosition.CFrame:ToWorldSpace(CFrame.new(math.random(-Size.X,Size.X),0,math.random(-Size.Z,Size.Z))),
					})
				end
				table.insert(ruta, {
					Action = "WalkTo",
					Process = CharacterPosition.CFrame,
				})
				table.insert(ruta, {
					Action = "HoldTo",
					Process = "giveBebida",
				})
				local count = 0
				
				local function add()
					count += 1
					local info = ruta[count]
					
					self.Character[info.Action](self.Character, self.Character.FormatPath.GetInfo(self.Character, info, PointRuta), function(state)
						if state == "Begin" then
							if info.Action == "HoldTo" and not tonumber(info.Process) then
								self.Character.animator:PlayAnimation(info.Process)
							end
						elseif state == "Complete" then
							if count >= #ruta then
								Ocupant.Completed = true
								self:CancelPreparar()
							else
								add()
							end
						elseif state == "Error" and (self.Character and self.Character.Ocupant == Ocupant) then
							task.defer(function()
								Ocupant.Starting = false
								self:ActionCharacter(true)
							end)
						end
					end)
					
				end
				
				add()
				self.actives.ChangeWorldPivot = self.model:GetPropertyChangedSignal("WorldPivot"):Connect(function()
					count = count<=0 and 0 or count-1
					add()
				end)
				
			end
			return
		else
			self.Character.Ocupant = nil
		end
	end
	
	for player,pedido in self.Pedidos do
		if not pedido.Occuped then
			return self:Preparar(false, player)
		end
	end
	
	local ruta = not intent and self.Character.FormatPath.FormatPath(ActionData.IdleAction[math.random(1, #ActionData.IdleAction)]) or {
		{Action = "WalkTo", Process = CharacterPosition.CFrame:ToWorldSpace(CFrame.new(math.random(-Size.X,Size.X),0,math.random(-Size.Z,Size.Z)))}
	}
	local count = 0
	
	local function add()
		count += 1
		local info = ruta[count]
		self.Character[info.Action](self.Character, self.Character.FormatPath.GetInfo(self.Character, info, PointRuta), function(state)
			if state == "Begin" then
				if info.Action == "HoldTo" and not tonumber(info.Process) then
					self.Character.animator:PlayAnimation(info.Process)
				end
			elseif state == "Complete" then
				if count >= #ruta then
					self:ActionCharacter()
				else
					add()
				end
			elseif state == "Error" and (self.Character and not self.Character.Ocupant) then
				self:ActionCharacter(true)
				--task.defer(self.ActionCharacter, self, true)
			end
		end)
	end
	
	add()
	self.actives.ChangeWorldPivot = self.model:GetPropertyChangedSignal("WorldPivot"):Connect(function()
		count = count<=0 and 0 or count-1
		add()
	end)
end

function module:OnScreen()
	if not IsClient or not self.actives or self.IsScreenOn then return end
	self.IsScreenOn = {}
	
	local function added(id)
		local data = self.Pedidos[id]
		if not data or self.IsScreenOn[id] then return end
		
		local list = {}
		
		local clone = template:Clone()
		clone.NamePlayer.Text = data.Pedidor.DisplayName
		clone.ToolImage.Image = data.Model.TextureId
		clone.NameProduct.Text = data.Settings.Name
		clone.State.BackgroundColor3 = data.Occuped and Color3.fromRGB(170, 0, 0) or Color3.fromRGB(0, 170, 0)
		
		task.spawn(function()
			local success, image = pcall(Players.GetUserThumbnailAsync, Players, data.Pedidor.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			clone.profile.Image = success and image or ""
		end)
		
		self.actives[id] = data.AttributeChanged:Connect(function(attribute)
			if attribute == "Occuped" then
				clone.State.BackgroundColor3 = data.Occuped and Color3.fromRGB(170, 0, 0) or Color3.fromRGB(0, 170, 0)
			end
		end)

		clone.Parent = self.ProductFrame
		list.gui = clone
		self.IsScreenOn[id] = list
	end
	
	for index in self.Pedidos do added(index) end
	self.actives.AddedClient = self.AddPedido:Connect(added)
	self.actives.RemovedClient = self.RemovePedido:Connect(function(index)
		local data = self.IsScreenOn[index]
		if not data then return end
		data.gui:Destroy()
		debris:AddItem(data.gui,0)
		Disconnects.Only(self.actives, index)
	end)

	self.ScreenGui.Enabled = true
end
function module:OffScreen()
	if not self.IsScreenOn then return end
	Disconnects.Group(self.actives, {"AddedClient", "RemovedClient"})
	self.ScreenGui.Enabled = false
	for id,data in self.IsScreenOn do
		data.gui:Destroy()
		debris:AddItem(data.gui,0)
		Disconnects.Only(self.actives, id)
	end
	self.IsScreenOn = nil
end

function module:Pedir(Player : Player, NamePedido)
	if not self.actives then return end
	NamePedido = IsClient and Player or NamePedido
	local InfoPedido = self.boliche.Menu[NamePedido]
	if not InfoPedido then return end
	if IsClient then
		self.boliche.Events.Pedir:FireServer(self.model, NamePedido)
	elseif not self.boliche.Pedidos[Player]
		and not self.UserBlockPedidos[Player] then
		if cobros.charge(Player, InfoPedido.Settings.Price, true) then
			local list = table.clone(InfoPedido)
			list.Stack = nil
			self.Pedidos[Player] = list
			self.boliche.Pedidos[Player] = self
			self.AddPedido:Fire(Player)
		else
			warn("no hay plata")
		end
	else
		warn("ya tienes un pedido en proceso o estas chambeando", self.boliche.Pedidos, self.UserBlockPedidos)
	end
end
function module:ClosePedido(Player : Player)
	if not self.actives then return end
	if IsClient then
		self.boliche.Events.ClosePedido:FireServer()
	else
		local pedido = self.Pedidos[Player]
		if not pedido then return warn("no tienes pedidos pendiente") end
		self.Pedidos[Player] = nil
		self.boliche.Pedidos[Player] = nil
		if pedido.Occuped then
			if pedido.Occuped == self.Character then
				self.Character.Ocupant = nil
				self:ActionCharacter()
			else
				pedido.Starting:Fire(pedido.Completed and "Complete" or pedido.Incomplete and "Incomplete" or "Cancel")
				pedido.Starting:Destroy()
			end
		end
		self.RemovePedido:Fire(Player)
	end
end
function module:GetPedido(NameOrder)
	for i, v in self.Pedidos do
		if v.Model.Name == NameOrder and not v.Occuped then
			return i
		end
	end
end
function module:GetPlayerOccuped(Player : Player)
	for PlayerPedidor, pedido in self.Pedidos do
		if pedido.Occuped == Player then
			return PlayerPedidor, pedido
		end
	end
end
function module:Preparar(Player : Player, pedido : Player)
	if not self.actives or IsClient or not pedido then return end
	if not Player then
		if not self.Character or self.Character.Ocupant then return end
		Player = self.Character
	end
	local Infopedido = self.Pedidos[pedido]
	if not Infopedido or Infopedido.Occuped then return end
	Infopedido.Occuped = Player
	if Player == self.Character then
		Player.Ocupant = Infopedido
		self:ActionCharacter()
	else
		Infopedido.Starting = EventCustom.new()
	end
	self:SetInfoClient(pedido)
	return Infopedido.Starting
end
function module:CancelPreparar(Player : Player)
	if not self.actives or IsClient then return end
	Player = Player or self.Character
	if not Player then return warn("no hay jugador") end
	local PlayerPedidor, pedido = self:GetPlayerOccuped(Player)
	if not PlayerPedidor then return warn("el jugador no esta haciendo ninguna preparacion", Player) end
	
	if pedido.Completed then
		self:Drop(PlayerPedidor, pedido)
		self:ClosePedido(PlayerPedidor)
	else
		if typeof(pedido.Starting) == "table" then
			pedido.Starting:Fire(pedido.Incomplete and "Incomplete" or "Cancel")
			pedido.Starting:Destroy()
		end
		pedido.Starting = false
		pedido.Occuped = nil
		self:ActionCharacter()
		self:SetInfoClient(PlayerPedidor)
	end
end
function module:BlockUsePedido(Player:Player, State)
	if IsClient or not Player then return end
	self.UserBlockPedidos[Player] = State or nil
end

function module:CountOrders(NameOrder)
	if not NameOrder then
		local list = {}
		for _, v in self.Pedidos do
			if v.Occuped then continue end
			list[v.Model.Name] = (list[v.Model.Name] or 0) + 1
		end
		return list
	else
		local num = 0
		for _, v in self.Pedidos do
			if v.Model.Name == NameOrder and not v.Occuped then
				num += 1
			end
		end
		return num
	end
end

function module:GetInfoClient(PlayerPedido)
	if not self.actives then return end
	if not PlayerPedido then
		if not IsClient then
			local result = {}
			for PlayerPedidor, _ in self.Pedidos do
				result[tostring(PlayerPedidor.UserId)] = self:GetInfoClient(PlayerPedidor)
			end
			return result
		else
			return self.Pedidos
		end
	elseif not IsClient then
		if typeof(PlayerPedido) == "string" then
			PlayerPedido = tonumber(PlayerPedido)
			if PlayerPedido then
				for Player,_ in self.Pedidos do if Player.UserId == PlayerPedido then return self:GetInfoClient(Player) end end
			end
		else
			local pedido = self.Pedidos[PlayerPedido]
			if pedido then
				local copia = table.clone(pedido)
				copia.Pedidor = PlayerPedido
				copia.Starting = nil
				copia.Occuped = pedido.Occuped and (pedido.Occuped==self.Character and self.Character.model or pedido.Occuped) or false
				return copia
			end
		end
	else
		return PlayerPedido and self.Pedidos[PlayerPedido] or false
	end
	return false
end
function module:SetInfoClient(Index, Value)
	if not self.actives then return end
	if not IsClient then
		local Player:Player = typeof(Value)=="Instance" and Value:IsA("Player") and Value
		if Player then
			if Index then
				local NewIndex = typeof(Index)=="Instance" and Index:IsA("Player") and tostring(Index.UserId) or Index
				self.boliche.Events.InfoClient:FireClient(Player,self.model,NewIndex,self:GetInfoClient(Index))
			else
				self.boliche.Events.InfoClient:FireClient(Player,self.model,self:GetInfoClient())
			end
		elseif Index then
			local NewIndex = typeof(Index)=="Instance" and Index:IsA("Player") and tostring(Index.UserId) or Index
			self.boliche.Events.InfoClient:FireAllClients(self.model,NewIndex, self:GetInfoClient(Index))
		else
			self.boliche.Events.InfoClient:FireAllClients(self.model,self:GetInfoClient())
		end
	else
		if typeof(Index) == "table" then
			for index2, value2 in Index do self:SetInfoClient(index2, value2) end
			for index2,_ in self.Pedidos do
				if not Index[index2] then self:SetInfoClient(index2) end
			end
		elseif typeof(Index)=="string" then
			local LastInfo = self.Pedidos[Index]
			if LastInfo then
				if typeof(Value) == "table" then
					for _, nameAttribute in InfoClientChanged do
						LastInfo:SetAttribute(nameAttribute, Value[nameAttribute])
					end
				else
					LastInfo:SetAttribute("Deleted", true)
					self.Pedidos[Index] = nil
					self.RemovePedido:Fire(Index)
				end
			elseif typeof(Value) == "table" then
				AttributeCustom.new(Value)
				for _, nameAttribute in InfoClientChanged do
					local attribute = Value[nameAttribute]
					Value[nameAttribute] = nil
					Value:SetAttribute(nameAttribute, attribute)
				end
				self.Pedidos[Index] = Value
				self.AddPedido:Fire(Index)
			end
		elseif Index == nil then
			self.boliche.Events.InfoClient:FireServer(self.model)
		end
	end
end

function module:Drop(Player:Player,pedido)
	if not self.actives then return end
	if IsClient or not pedido then return end
	local PartPosition = self.model:FindFirstChild("PositionFood")
	local size = PartPosition.Size / 2
	local folder = RS:FindFirstChild("Assets"):FindFirstChild("ToolsModels")
	local clone:Tool = folder:FindFirstChild(pedido.Model.Name):Clone()
	local SizePart = clone.PrimaryPart and clone.PrimaryPart.Size or clone:GetExtentsSize()
	clone:PivotTo(PartPosition.CFrame:ToWorldSpace(CFrame.new(math.random(-size.X,size.X),0,math.random(-size.Z, size.Z))) * CFrame.new(0,SizePart.Y / 2,0))
	clone.Parent = workspace:FindFirstChild("InteractableTools") or workspace
	
	self.boliche.Drops[Player] = self.boliche.Drops[Player] or {}
	table.insert(self.boliche.Drops[Player], clone)
	
	clone:SetAttribute("owner", Player.Name)
	clone:SetAttribute("inventory", false)
	clone:SetAttribute("IsBebidaBartender", true)
	clone:AddTag("ToolInteractable")
end

function module:CountStackProduct(NameProduct)
	local product = NameProduct and self.boliche.Menu and self.boliche.Menu[NameProduct]
	return product and product.Stack[self.model] or 0
end

function module:StackInit()
	if IsClient then return end
	for NameProduct, Data in self.boliche.Menu do
		Data.Stack[self.model] = Data.Settings.MaxStack
	end
end
function module:StackDestroy()
	for NameProduct, Data in self.boliche.Menu do Data.Stack[self.model] = nil end
end
function module:TakeProduct(NameProduct)
	if IsClient then return end
	local product = NameProduct and self.boliche.Menu and self.boliche.Menu[NameProduct]
	if not product then return end
	local Count = product.Stack[self.model]
	if Count and Count > 0 then
		product.Stack[self.model] -= 1
		self.boliche:actionBarras("ChangeStack",false,NameProduct)
		return true
	end
end
function module:ReponerStack(NameProduct)
	if IsClient then return end
	local product = NameProduct and self.boliche.Menu and self.boliche.Menu[NameProduct]
	if not product then return end
	local Count = product.Stack[self.model]
	if Count and Count <= 0 then
		product.Stack[self.model] = product.Settings.MaxStack
		self.boliche:actionBarras("ChangeStack",false,NameProduct)
		return true
	end
end

function module:ReplenishStack(NameProduct)
	if IsClient then return end
	
end

function module:init()
	if self.actives then return end
	self.actives = {}
	
	table.insert(self.actives, self.AddPedido:Connect(function(order)
		if not IsClient then
			self:SetInfoClient(order)
			self:ActionCharacter()
		else
			--print(order, self:GetInfoClient(order))
		end
	end))
	table.insert(self.actives, self.RemovePedido:Connect(function(order)
		if not IsClient then
			self:SetInfoClient(order)
		else
			--print(order, self:GetInfoClient(order))
		end
	end))
	
	if not IsClient then
		
		self:CreateCharacter()
		self:StackInit()
		
	else
		AttributeCustom.new(self)
	end
	
end
function module:destroy()
	if not self.actives then return end
	self.actives = Disconnects.All(self.actives)
	
	self:StackDestroy()
	
	if not IsClient then
		
		self:RemoveCharacter()
		for i,_ in self.Pedidos do self:ClosePedido(i) end
		
	else
		
		self:SetAttribute("Deleted", true)
		self:OffScreen()
		
	end
end

return module
