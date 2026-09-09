local module = {}
module.__index = module

local RunS = game:GetService('RunService')

local IsClient = RunS:IsClient()
local Players = game:GetService("Players")
local LocalPlayer:Player = IsClient and Players.LocalPlayer or nil
local HTTPS : HttpService = not IsClient and game:GetService("HttpService")

local RS = game:GetService("ReplicatedStorage")
local modelBox = RS:WaitForChild("Assets"):WaitForChild("Models"):WaitForChild("BoxTools")

local savedMetatable = {}

function module.new(model : Model)
	local UniqueId = model:GetAttribute("GroupId")
	
	if not UniqueId or not savedMetatable[UniqueId] then
		local self = setmetatable({
			Tag = 'CajasWork',
			model = model,
			WhiteList = {"trabajar", "renunciar", "GiveBox", "SetFinishLocation", "SetBox"},
			Occupant = not IsClient and {},
		},module)
		if UniqueId then
			self.Group = {model}
			
			if not IsClient then
				
				self.UniqueKey = UniqueId
				model:SetAttribute("IsSelectedModel", self.UniqueKey)
				
			else
				
				self:AddedNew(model)
				
			end
			
			savedMetatable[UniqueId] = self
		end
		
		if not IsClient then model:SetAttribute("conditional", "NoSignalClient") end
		
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
		self:AttributesUpdating()
	else
		model:SetAttribute("conditional", "NoSignalClient")
	end
end

function module:finished(Player, state)
	if IsClient then
		if self.Occupant then
			self.Occupant = false
			if not self.Groupdata then self:MarkUse() end
			self:AttributesUpdating()
		end
	elseif self.Occupant[Player] then

		local Occupant = self.Occupant[Player]
		self.Occupant[Player] = nil

		Occupant.BindableEvent:Fire()
		Occupant.BindableEvent:Destroy()
		self.disconnect.All(Occupant.actives)
		
		if Occupant.AnimationIdle then Occupant.AnimationIdle:Stop() end
		if Occupant.Tool then self.debris:AddItem(Occupant.Tool,0) end
		if Occupant.callBack then task.defer(Occupant.callBack, state or "Cancel") end
		
		if Player:IsDescendantOf(game) then
			self:Fire(Player,self.model,'renunciar',true)
		end
		
	end
end

function module:SetBox(Player)
	if IsClient then
		if self.Occupant and self.Occupant.Tool then
			self:Fire(self.model,'SetBox')
		end
	elseif self.Occupant[Player] and self.Occupant[Player].Tool then
		self:finished(Player, "Success")
	end
end

function module:GiveBox(Player)
	if IsClient and self:IsUse() then
		if Player == nil then
			self:Fire(self.model,'GiveBox')
		else
			self.Occupant.Tool = Player
			self:AttributesUpdating()
		end
	elseif not IsClient and self.Occupant[Player] then
		local data = self.Occupant[Player]
		if not data.Tool then
			
			local Character : Model, Humanoid : Humanoid = self:GetCharacter(Player)
			if not Humanoid then return end
			
			local clone : Tool = (data.NameTool and (modelBox:FindFirstChild(data.NameTool) or modelBox:FindFirstChild("Box")) or
				modelBox:GetChildren()[math.random(1,#modelBox:GetChildren())]):Clone()

			local LoadAnimation = Humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(script:FindFirstChild("Idle"))
			
			data.actives["BoxActive"] = clone.AncestryChanged:Connect(function(_, parent)
				if parent then return end
				self.disconnect.Group(data.actives, {"BoxActive", "Animator"})
				self.Event:FireClient(Player,self.model,'GiveBox',false)
				data.Tool = nil
				LoadAnimation:Stop()
				data.AnimationIdle = nil
			end)
			
			data.actives["Animator"] = LoadAnimation.Changed:Connect(function()
				if LoadAnimation.IsPlaying then
					Humanoid:EquipTool(clone)
					self:Fire(Player,self.model,'GiveBox',clone)
				end
			end)
			
			data.Tool = clone
			LoadAnimation:Play()
			data.AnimationIdle = LoadAnimation
			
		end
	end
end

function module:SetFinishLocation(Player,listTables)
	listTables = IsClient and Player or listTables
	if typeof(listTables) ~= "table" then return end
	if IsClient then
		if listTables == self.ListFinishLocation then
			local active = self.Occupant and self.Occupant.Tool and true
			for _,model in self.ListFinishLocation do
				model:SetAttribute("BoxLocation", active)
			end
		else
			if self.ListFinishLocation then
				for _,model in self.ListFinishLocation do
					model:SetAttribute("BoxLocation", nil)
				end
			end
			local active = self.Occupant and self.Occupant.Tool and true
			for _,model in listTables do
				model:SetAttribute("BoxLocation", active)
			end
			self.ListFinishLocation = listTables
		end
	else
		self:Fire(Player,self.model,'SetFinishLocation',listTables)
	end
end

function module:AttributesUpdating()
	if self.Group then
		local Attribute = self.Occupant and not self.Occupant.Tool
		for _,model in self.Group do
			model:SetAttribute("Occuped", Attribute)
		end
	else
		self.model:SetAttribute("Occuped", self.Occupant and not self.Occupant.Tool)
	end
	self:SetFinishLocation(self.ListFinishLocation)
end

function module:trabajar(Player:Player, callBack)
	if IsClient then
		if ((not self.Groupdata and not self:IsUse()) or (self.Groupdata and self:IsUse() == self.Groupdata))
			and not self.Occupant then
			
			if not Player then
				self:Fire(self.model,'trabajar')
			else
				self.Occupant = {Tool = false}
				if not self.Groupdata then self:MarkUse() end
				self:AttributesUpdating()
			end
			
		end
	elseif not self.Occupant[Player]
		and ((self.Groupdata and self.UsosPlayer[Player] == self.Groupdata)
		or (not self.Groupdata and not self.UsosPlayer[Player])) then
		
		local list = {
			Player = Player,
			BindableEvent = self.EventCustom.new(),
			actives = {},
			callBack = typeof(callBack)=="function" and callBack or nil,
		}

		table.insert(list.actives, Player.AncestryChanged:Connect(function() self:finished(Player, "Cancel") end))
		self.Occupant[Player] = list
		
		if self.Groupdata then
			self:Fire(Player,self.model,'trabajar',true)
		end
		
		return list.BindableEvent
	end
end

function module:renunciar(Player : Player)
	if not IsClient or Player then
		self:finished(Player, "Cancel")
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
