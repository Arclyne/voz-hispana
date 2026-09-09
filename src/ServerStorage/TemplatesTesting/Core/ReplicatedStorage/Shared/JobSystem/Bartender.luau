local module = {}
module.__index = module

local RunS = game:GetService('RunService')
local RS = game:GetService("ReplicatedStorage")

local IsClient = RunS:IsClient()
local Players = game:GetService("Players")
local LocalPlayer:Player = IsClient and Players.LocalPlayer or nil

local Barra = require(RS:WaitForChild("Shared"):WaitForChild("BartenderSystem"))
local HTTPS : HttpService = not IsClient and game:GetService("HttpService")

local savedMetatable

function module.new(model : Model)
	if not model:GetAttribute("IsWork") then return model:SetAttribute("vacant", nil) end
	
	if savedMetatable then
		table.insert(savedMetatable.Group, model)
		savedMetatable:AddedNew(model)
		return savedMetatable
	else
		local self = setmetatable({
			Tag = 'BarraBartender',
			model = model,
			WhiteList = {"trabajar","renunciar","Preparar","ObtenerModelo"},
			Occupant = not IsClient and {},
			Group = {model},
			Union = {},
			TimeWatingClient = 120,
		},module)
		
		savedMetatable = self
		
		if not IsClient then
			self.UniqueKey = HTTPS:GenerateGUID(true)
			model:SetAttribute("IsSelectedModel", self.UniqueKey)
		end
		
		self:AddedNew(model)
		
		return self
	end
end

function module:AddedNew(model : Model)
	local BarraObject = Barra.Barras[model]
	if not BarraObject then return end
	if IsClient then
		model:SetAttribute("empleados", self.Occupant and LocalPlayer.UserId or nil)
		self.model = model:GetAttribute("IsSelectedModel") and model or self.model
		if not self.UniqueKey and self.model then
			self.UniqueKey = self.model:GetAttribute("IsSelectedModel")
		end
	else
		model:SetAttribute("vacant", self.OpenBar and self:CountPlayersWorking() < self.OpenBar)
		for _,_ in self.Occupant do BarraObject:RemoveCharacter() break end
	end
end
function module:CountPlayersWorking()
	if IsClient then return 0 end
	local num = 0
	for _,_ in self.Occupant do num += 1 end
	return num
end

function module:finished(Player:Player, IsInUpdate)
	if IsClient then
		if self.Occupant then
			local Occupant = self.Occupant
			self.Occupant = false

			if Occupant.ModelOrder then
				Occupant.ModelOrder:SetAttribute("Preparando", nil)
				Occupant.ModelOrder:SetAttribute("EnabledPrompt", nil)
				Occupant.ModelOrder.ModelJob.BillboardGui.Enabled = false
			end
			
			if Occupant.HiglightSelect then self.debris:AddItem(Occupant.HiglightSelect,0) end
			if Occupant.Player and Occupant.Player.Character then Occupant.Player.Character:SetAttribute("Entrega", true) end
			
			self.disconnect.All(Occupant.actives)
			
			for _, model in self.Group do
				local BarraObject = Barra.Barras[model]
				if not BarraObject then continue end
				model:SetAttribute("empleados", nil)
				BarraObject:OffScreen()
			end
			self:MarkUse()
		end
	elseif self.Occupant[Player] then
		local Occupant = self.Occupant[Player]
		self.Occupant[Player] = nil
		Occupant.BindableEvent:Fire()
		Occupant.BindableEvent:Destroy()
		self.disconnect.All(Occupant.actives)
		if Occupant.ProcessPreparacion then
			local dataaa = Barra.Pedidos[Occupant.ProcessPreparacion]
			if dataaa then dataaa:CancelPreparar(Player) end
		end
		
		if Player:IsDescendantOf(game) then
			self:Fire(Player,self.model,'renunciar',true)
		end
		for _, model in self.Group do
			local BarraObject = Barra.Barras[model]
			if not BarraObject then continue end
			BarraObject:BlockUsePedido(Player, false)
		end
		if self.Union.CajasWork then self.Union.CajasWork:finished(Player) end
		if not IsInUpdate then
			self:UpdateStateVacant()
		elseif self.Union.ClearFloors then
			self.Union.ClearFloors:Update()
		end
	end
end

function module:Preparar(Player : Player, model : Model, NameProduct)
	if IsClient then
		if not self.Occupant then return end
		if not NameProduct then
			self:Fire(self.model,'Preparar', Player, model)
		else
			if self.Occupant.ModelOrder then
				self.disconnect.Only(self.Occupant.actives, "ChangeStack")
				self.Occupant.ModelOrder.ModelJob.BillboardGui.Enabled = false
				self.Occupant.ModelOrder:SetAttribute("Preparando", nil)
				self.Occupant.ModelOrder:SetAttribute("EnabledPrompt", nil)
				self.Occupant.ModelOrder = nil
			end
			
			self.Occupant.Player = Player
			self.Occupant.ModelOrder = model
			
			if model then
				model:SetAttribute("Preparando", true)
				local BarraObject = Barra:Get(model)
				if not BarraObject then return warn("no hay esa barra") end
				local Pedidodata = BarraObject.Pedidos[tostring(Player.UserId)]
				if not Pedidodata then return warn("no hay ese pedido pa") end
				local Menu = Barra.Menu[Pedidodata.Model.Name]
				if not Menu then return warn("no hay menu") end
				model.ModelJob.BillboardGui.TextLabel.Text = string.format("%d/%d",Menu.Stack[model] or 0, Menu.Settings.MaxStack)
				self.Occupant.actives.ChangeStack = Menu.Changed:Connect(function()
					model.ModelJob.BillboardGui.TextLabel.Text = string.format("%d/%d",Menu.Stack[model] or 0, Menu.Settings.MaxStack)
				end)
				model.ModelJob.BillboardGui.Enabled = true
			end
		end
	else
		local data = self.Occupant[Player]
		if not data or data.ProcessPreparacion then return warn("no estas trabajando o ya estas haciendo una tarea") end
		if self.Union.CajasWork and self.Union.CajasWork.Occupant[Player] then return warn("estas trabajando repartiendo cajas") end
		local BarraObject = Barra:Get(model)
		if not BarraObject then return warn("no existe esa barra") end
		local index = BarraObject:GetPedido(NameProduct)
		if not index then return warn("no existe ese pedido") end
		
		local Pedidodata = Barra.Menu[NameProduct]
		if Pedidodata.Stack[model] <= 0 then return self:RepairStack(Player, NameProduct, model) end
		
		local success = BarraObject:Preparar(Player, index)
		if not success then return warn("no es posible trabajar en esa tarea") end
		
		data.ProcessPreparacion = index
		data.BarraObject = BarraObject
		data.StartTime = tick()
		
		data.actives.running = RunS.Heartbeat:Connect(function()
			if tick()-data.StartTime >= self.TimeWatingClient then
				BarraObject.Pedidos[index].Incomplete = true
				BarraObject:ClosePedido(data.ProcessPreparacion)
			end
		end)
		
		data.actives.EventStateOrder = success:Connect(function(state)
			
			data.ProcessPreparacion = nil
			data.BarraObject = nil
			self.disconnect.Group(data.actives, {"EventStateOrder","ChangeParentTool"})
			self.Event:FireClient(Player,self.model,'Preparar', false, false, true)
			if data.Tool then
				self.debris:AddItem(data.Tool,0)
				data.Tool = nil
			end
			
			if state == "Complete" then
				self.cobros.Give(Player,self.cobros.Lerp(Pedidodata.Settings.Price, .5),true)
			elseif state == "Cancel" then
				warn("el jugador cancelo el pedido")
			elseif state == "Incomplete" then
				warn("despedido")
				self:finished(Player)
			end
			
		end)
		
		self:Fire(Player,self.model,'Preparar', index, model, true)
	end
end

function module:RepairStack(Player : Player, NameProduct, model)
	if IsClient or not self.Occupant[Player] or not self.Union.CajasWork then return end
	local Occupant = self.Occupant[Player]
	
	local BarraObject = Barra:Get(model)
	if not BarraObject then return warn("no existe esa barra") end
	local index = BarraObject:CountStackProduct(NameProduct)
	if not index or index > 0 then return warn("no hay productos disponible", NameProduct) end
	
	local function CallBack(State)
		if self.Occupant[Player] == Occupant then
			
			self.disconnect.Only(Occupant.actives, "ChangeStackRepair")
			
			if State == "Success" then
				
				BarraObject:ReponerStack(NameProduct)
				
			end
			
		end
	end
	
	if self.Union.CajasWork:trabajar(Player, CallBack) then
		
		self.Union.CajasWork:SetFinishLocation(Player, {model})
		
		local menu = Barra.Menu[NameProduct]
		
		Occupant.actives.ChangeStackRepair = menu.Changed:Connect(function()
			if menu.Stack[model] > 0 then
				self.Union.CajasWork:finished(Player)
			end
		end)
		
	end 
	
end

function module:ObtenerModelo(Player : Player)
	if IsClient then
		if not self.Occupant then return end
		if Player == nil then
			self:Fire(self.model,'ObtenerModelo')
		elseif Player then
			if self.Occupant.ModelOrder then
				self.Occupant.ModelOrder:SetAttribute("Preparando", true)
				self.Occupant.ModelOrder:SetAttribute("EnabledPrompt", true)
			end
		else
			if self.Occupant.ModelOrder then
				self.Occupant.ModelOrder:SetAttribute("EnabledPrompt", nil)
			end
		end
	else
		local data = self.Occupant[Player]
		if not data or not data.ProcessPreparacion then return warn("no estas trabajando o no estas haciendo una tarea...") end
		if data.Tool then return warn("Ya tienes la Tool") end
		
		local Pedidodata = data.BarraObject.Pedidos[data.ProcessPreparacion]
		if not Pedidodata then return warn("no existe pedido actual") end
		
		if not data.BarraObject:TakeProduct(Pedidodata.Model.Name) then return self:RepairStack(Player, Pedidodata.Model.Name, data.BarraObject.model) end
		
		local _,Humanoid:Humanoid = self:GetCharacter(Player)
		if not Humanoid then return warn("no hay humanoid") end 
		
		local clone:Tool = Pedidodata.Model:Clone()
		clone:SetAttribute("owner", data.ProcessPreparacion.Name)
		clone:SetAttribute("IsBebidaBartender", true)
		clone:SetAttribute("inventory", false)
		clone:RemoveTag(Barra.TagMenuTools)
		
		Humanoid:EquipTool(clone)
		
		data.actives.ChangeParentTool = clone.AncestryChanged:Connect(function()
			
			self.disconnect.Only(data.actives, "ChangeParentTool")
			data.Tool = nil
			
			if not clone:IsDescendantOf(game) and clone:GetAttribute("IsPlace") then
				Pedidodata.Completed = true
				data.BarraObject:ClosePedido(data.ProcessPreparacion)
			else
				self.debris:AddItem(clone,0)
				self.Event:FireClient(Player,self.model,'ObtenerModelo',false)
			end
			
		end)

		data.Tool = clone
		
		self:Fire(Player,self.model,'ObtenerModelo',clone)
	end
end

function module:trabajar(Player:Player)
	if IsClient then
		if not self:IsUse() and not self.Occupant then
			if not Player then
				self:Fire(self.model,'trabajar')
			else
				self.Occupant = {actives = {}}
				for _, model in self.Group do
					local BarraObject = Barra.Barras[model]
					if not BarraObject then continue end
					model:SetAttribute("empleados", LocalPlayer.UserId)
					BarraObject:OnScreen()
				end
				self:MarkUse()
			end
		end
	elseif (self.OpenBar and self:CountPlayersWorking() < self.OpenBar)
		and not self.UsosPlayer[Player]
		and not self.Occupant[Player] then
		
		local list = {
			
			Player = Player,
			actives = {},
			BindableEvent = self.EventCustom.new(),
			ProcessPreparacion = false,
			
		}
		
		table.insert(list.actives, Player.AncestryChanged:Connect(function()
			self:finished(Player)
			self.signalsGame:Fire(self.tagSignalJob, self.Tag, Player,"cancel")
		end))
		
		self.Occupant[Player] = list
		Barra:RemoveDrops(Player)
		--Barra:actionBarras("close",Player)
		
		if self.Union.ClearFloors then self.Union.ClearFloors:Update() end
		
		for _, model in self.Group do
			local BarraObject = Barra.Barras[model]
			if not BarraObject then continue end
			BarraObject:BlockUsePedido(Player, true)
		end
		
		self:UpdateStateVacant()
		
		self.signalsGame:Fire(self.tagSignalJob, self.Tag, Player,"start")
		
		return list.BindableEvent
	end
end

function module:renunciar(Player : Player)
	if not IsClient or Player then
		self:finished(Player)
	elseif self.Occupant then
		if not self.actives then
			self:finished()
		else
			self:Fire(self.model,'renunciar')
		end
	end
end

function module:UpdateStateVacant()
	if IsClient then return end
	local PlayersCount = #Players:GetPlayers()
	self.OpenBar = math.min(3, math.ceil(PlayersCount / 10))
	local PlayersWorking = self:CountPlayersWorking()
	
	if not self.OpenBar then
		for Player:Player, _ in self.Occupant do
			self:finished(Player, true)
			self.signalsGame:Fire(self.tagSignalJob, self.Tag, Player ,"cancel")
		end
	elseif PlayersWorking > self.OpenBar then
		local restar = PlayersWorking - self.OpenBar
		local count = 0
		for Player:Player, _ in self.Occupant do
			count += 1
			self:finished(Player, true)
			self.signalsGame:Fire(self.tagSignalJob, self.Tag, Player ,"cancel")
			if count >= restar then break end
		end
	end
	
	local ActiveOtherPlayers = self.OpenBar and PlayersWorking < self.OpenBar
	
	for _, model in self.Group do
		local BarraObject = Barra.Barras[model]
		if not BarraObject then continue end
		model:SetAttribute("vacant", ActiveOtherPlayers)
		if PlayersWorking > 0 and BarraObject.Character then
			BarraObject:RemoveCharacter()
		elseif PlayersWorking <= 0 and not BarraObject.Character then
			BarraObject:CreateCharacter()
		end
	end

	if self.Union.ClearFloors then self.Union.ClearFloors:Update() end
end

function module:enabled()
	if self.actives then return end
	self.actives = {}
	if not IsClient then

		self:UpdateStateVacant()
		table.insert(self.actives, Players.PlayerAdded:Connect(function() self:UpdateStateVacant() end))
		table.insert(self.actives, Players.PlayerRemoving:Connect(function() self:UpdateStateVacant() end))
		if typeof(Barra.IsNotFloor) ~= "string" then task.defer(Barra.IsNotFloor.Fire, Barra.IsNotFloor, self.UniqueKey) end
		
	end
end

function module:disabled()
	if not self.actives then return end
	self.actives = self.disconnect.All(self.actives)
	if not IsClient then
		for Player:Player, _ in self.Occupant do
			self:finished(Player)
			self.signalsGame:Fire(self.tagSignalJob, self.Tag, Player ,"cancel")
		end
	elseif self.Occupant then
		self:renunciar()
	end
end

function module:destroy(model : Model)
	local index = model and table.find(self.Group, model)
	if index then
		table.remove(self.Group, index)
		
		if model:IsDescendantOf(game) then
			if not IsClient then
				model:SetAttribute("vacant", nil)
			else
				model:SetAttribute("empleados", nil)
			end
		end
		
	end
end

return module
