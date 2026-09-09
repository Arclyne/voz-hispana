local module = {}
module.__index = module

local RunS = game:GetService('RunService')

local IsClient = RunS:IsClient()
local Players = game:GetService("Players")
local LocalPlayer:Player = IsClient and Players.LocalPlayer or nil
local HTTPS : HttpService = not IsClient and game:GetService("HttpService")

local RS = game:GetService("ReplicatedStorage")
local Positions = not IsClient and require(RS:WaitForChild("Client"):WaitForChild("Posicionamientos"))
local modelTrash = RS:WaitForChild("Assets"):WaitForChild("Models"):WaitForChild("Trashes")

local timeSpawned = {12, 30}
local savedMetatable = {}

function module.new(model : Model)
	local UniqueId = model:GetAttribute("GroupId")
	if not UniqueId or not savedMetatable[UniqueId] then
		local self = setmetatable({
			Tag = 'ClearFloors',
			model = model,
			WhiteList = not UniqueId and {"trabajar", "renunciar"} or {},
			Occupant = not IsClient and not UniqueId and {},
		},module)
		if UniqueId then
			self.Group = {model}
			if not IsClient then
				self.UniqueKey = UniqueId
				model:SetAttribute("IsSelectedModel", self.UniqueKey)

				local rayparams = RaycastParams.new()
				rayparams.FilterType = Enum.RaycastFilterType.Include
				rayparams.FilterDescendantsInstances = self.Group
				self.ParamsFloor = rayparams
				
			else
				
				self:AddedNew(model)
				
			end
			savedMetatable[UniqueId] = self
		end
		return self
	elseif savedMetatable[UniqueId] then
		table.insert(savedMetatable[UniqueId].Group, model)
		savedMetatable[UniqueId]:AddedNew(model)
		return savedMetatable[UniqueId]
	end
end

function module:AddedNew(model : Model)
	if not self.Group then return end
	if IsClient then
		self.model = model:GetAttribute("IsSelectedModel") and model or self.model
		self.UniqueKey = self.UniqueKey or model:GetAttribute("GroupId")
		if not self.Groupdata then
			self.Groupdata = self:GetInfoInstance(self.UniqueKey, model:GetAttribute("JobId") or "")
		end
		if self.Groupdata then self.Groupdata.Union[self.Tag] = self end
	end
end

function module:finished(Player)
	if self.Groupdata then return end
	
	if IsClient then
		if self.Occupant then
			self.Occupant = false
			self:MarkUse()
		end
	elseif self.Occupant[Player] then

		local Occupant = self.Occupant[Player]
		self.Occupant[Player] = nil

		Occupant.BindableEvent:Fire()
		Occupant.BindableEvent:Destroy()
		self.disconnect.All(Occupant.actives)
		
		if Player:IsDescendantOf(game) then
			self:Fire(Player,self.model,'renunciar',true)
		end

		self:Update()
	end
end

function module:trabajar(Player:Player)
	if self.Groupdata then return end
	
	if IsClient then
		if not self:IsUse() and not self.Occupant then
			if not Player then
				self:Fire(self.model,'trabajar')
			else
				self.Occupant = true
				self:MarkUse()
			end
		end
	elseif not self.Occupant[Player]
		and not self.UsosPlayer[Player] then
		
		local list = {
			Player = Player,
			BindableEvent = self.EventCustom.new(),
			actives = {}
		}

		table.insert(list.actives, Player.AncestryChanged:Connect(function() self:finished(Player) end))
		
		self.Occupant[Player] = list
		
		self:Update()

		return list.BindableEvent
		
	end
end

function module:Update()
	local IsActive = false
	if self.actives then
		local Occupant = self.Groupdata and self.Groupdata.Occupant or self.Occupant
		for plr,_ in Occupant do
			IsActive = IsActive or {}
			table.insert(IsActive, tostring(plr.UserId))
		end
	end
	
	if IsActive then
		local StringPlayers = table.concat(IsActive,",")
		if not self.trashes then
			local list = {trash = {}, delayyy = {}, PlayersActive = IsActive}
			local function create(BasePart, trash)
				if not self.actives then return end
				if trash and list.delayyy[trash] then list.delayyy[trash] = nil end
				local index = trash and table.find(list.trash, trash)
				local clone = modelTrash:GetChildren()[math.random(1, #modelTrash:GetChildren())]:Clone()
				local Size = BasePart.Size / 2

				local randomOrientation = CFrame.Angles(0,math.rad(math.random(0, 360)),0)
				local randomPosition = BasePart.CFrame:PointToWorldSpace(Vector3.new(math.random(-Size.X, Size.X),Size.Y + 1,math.random(-Size.Z, Size.Z)))

				clone:PivotTo(Positions.GetPosition(clone.PrimaryPart, CFrame.new(randomPosition) * randomOrientation, self.ParamsFloor, false, "Floors"))

				if index then
					list.trash[index] = clone
				else
					table.insert(list.trash, clone)
				end

				clone:SetAttribute("WhiteList", StringPlayers)
				clone.Parent = BasePart

				self.actives[clone] = clone.AncestryChanged:Connect(function(_, parent)
					if parent then return end
					self.disconnect.Only(self.actives, clone)
					list.delayyy[clone] = task.delay(math.random(table.unpack(timeSpawned)), create, BasePart, clone)
					if clone:GetAttribute("IsComplete") then
						local Player = Players:GetPlayerByUserId(clone:GetAttribute("PlayerCleaning") or 0)
						if not Player or not table.find(list.PlayersActive,tostring(Player.UserId)) then return warn("no se encontro el jugador") end
						self.cobros.Give(Player,{Coins = 20},true)
					end
				end)

				clone:AddTag("Pee")
			end

			if self.Group then
				for _,v in self.Group do
					for _ = 1, 10 do
						local id = HTTPS:GenerateGUID(true)
						list.delayyy[id] = task.delay(math.random(table.unpack(timeSpawned)), create, v, id)
					end
				end
			else
				for _ = 1, 10 do
					local id = HTTPS:GenerateGUID(true)
					list.delayyy[id] = task.delay(math.random(table.unpack(timeSpawned)), create, self.model, id)
				end
			end

			self.trashes = list
		else
			self.trashes.PlayersActive = IsActive
			for _, model : Model in self.trashes.trash do
				if model:IsDescendantOf(game) then
					model:SetAttribute("WhiteList", StringPlayers)
				end
			end
		end
	elseif not IsActive and self.trashes then
		
		local trashes = self.trashes
		self.trashes = nil
		
		for index, model : Model in trashes.trash do
			self.disconnect.Only(self.actives, model)
			if model:IsDescendantOf(game) then
				model:Destroy()
				self.debris:AddItem(model, 0)
			end
		end
		for _, d in trashes.delayyy do task.cancel(d) end
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

function module:enabled()
	if self.actives then return end
	self.actives = {}
	if self.UniqueKey and not self.Groupdata then
		self.Groupdata = self:GetInfoInstance(self.UniqueKey, self.model:GetAttribute("JobId") or "")
	end
	if self.Groupdata then
		self.Groupdata.Union[self.Tag] = self
	end
end

function module:disabled()
	if not self.actives then return end
	self.actives = self.disconnect.All(self.actives)
end

function module:destroy(model : Model)
	if not self.Group then return end
	local index = model and table.find(self.Group, model)
	if index then
		table.remove(self.Group, index)
	end
end

return module
