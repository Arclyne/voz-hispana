local fn = {}
fn.__index = fn

local Client = game:GetService('RunService'):IsClient()
local plr = Client and game:GetService('Players').LocalPlayer
local RS = game:GetService('ReplicatedStorage')
local Events = RS:WaitForChild('Events'):WaitForChild('Stores')

local Changes = require(script.Parent:WaitForChild('ColorTexture'))
local AddItem = require(RS.Shared:WaitForChild('AddValues'))
local MovingPlayers = require(RS:FindFirstChild("Shared"):FindFirstChild("MovingPlayers"))
local EventCustom = require(RS:WaitForChild("Client"):WaitForChild("Event"))

local debris = game:GetService('Debris')
local IsA = "Store"

function fn.new(Base:BasePart)
	local self = setmetatable({
		Base = Base,
		actives = {},
		
		PosiAtt = Base:WaitForChild('PositionATT',30).WorldCFrame,
		Store = Base:WaitForChild('Store',30),
		Decors = Base:WaitForChild('Decors',30),
		CFrameBase = Base:WaitForChild('PositionStore', 30).WorldCFrame,
		
		Occuped = false,
		Owner = false,
		ChildsBase = {},
		
		StoreTemplates = RS:WaitForChild('StoreTemplates'),
	}, fn)
	
	self.OwnerChanged = Client and EventCustom.new() or nil
	self.AngleBase = ({self.CFrameBase:ToOrientation()})[2]
	self.SizeBase = Vector3.new(36.1, 17.2, 58.6)
	
	self:Builds()
	
	return self
end

function fn:IsA(t) return t == IsA end

function fn:RetirarJugadores()
	for _, player in game:GetService('Players'):GetPlayers() do
		local Cha = player.Character
		if Cha and Cha:GetPivot() then
			local PosiCha = self.CFrameBase:ToObjectSpace(Cha:GetPivot())
			local BaseSize = self.SizeBase / 2
			if PosiCha.X > - BaseSize.X and PosiCha.X <  BaseSize.X and
				PosiCha.Y > - BaseSize.Y and PosiCha.Y < BaseSize.Y and
				PosiCha.Z > - BaseSize.Z and PosiCha.Z < BaseSize.Z then
				MovingPlayers:move(player, self.PosiAtt)
			end
		end
	end
	self.StoreModel = nil
	self.ChildsBase = {}
	for index,v : RBXScriptConnection in self.actives do
		if typeof(v) == 'RBXScriptConnection' then
			v:Disconnect()
		end
		self.actives[index] = nil
	end
end

function fn:ChangeColorTexture()
	if not self.StoreModel or not self.Occuped then return end
	for _,parts in self.StoreModel.Settings.Data.Childs do
		local value:BoolValue = self.Occuped:FindFirstChild(parts.Name)
		
		if not value then
			value = AddItem(parts.Name,parts.Value,parts)
			value.Parent = self.Occuped
		end
		
		local Base = self.StoreModel.model:FindFirstChild(value.Name, true)
		
		if not Base then continue end

		table.insert(self.ChildsBase, {
			Value = value,
			Model = Base,
			Data = parts,
			EditColor = true,
		})

		table.insert(self.actives,value.AttributeChanged:Connect(function(index)
			if not Changes[index] then return end
			Changes[index](self, Base, value:GetAttribute(index))
		end))
		for index,_ in parts do
			if not Changes[index] then continue end
			Changes[index](self, Base, value:GetAttribute(index))
		end
	end
end

function fn:FindFirstChild(Name)
	for _,v in self.ChildsBase do
		if v.Value.Name == Name then
			return v
		end
	end
end

function fn:RemoveWithGamepass()
	if Client or not self.Owner then return end
	
	local TieneElPremiun = self.Monetizacion.Gamepass.Premium.Owner[self.Owner.UserId]
	
	if TieneElPremiun and self.Occuped and self.StoreModel then
		for _,BasePart:BasePart in self.StoreModel.model:GetDescendants() do
			if BasePart:IsA('BasePart') then
				if BasePart:GetAttribute('RemoveWithGamepass') then
					debris:AddItem(BasePart,0)
				elseif BasePart:GetAttribute("AddWithGamepass") then
					BasePart:SetAttribute("NoPut", false)
				end
			end
		end
	end
	
end

function fn:GetStore()
	if not Client and not self.IsBuildComplete then
		local model = self.StoreTemplates:FindFirstChild(self.Occuped and self.Occuped.Name or "Simple")
		model = model and model:Clone()
		
		if model then
			model:PivotTo(self.CFrameBase)
			model.Parent = self.Store

			self.StoreModel = {model = model, Settings = require(model:WaitForChild('Settings'))}
			self:RemoveWithGamepass()
			self:ChangeColorTexture()
			self.IsBuildComplete = true

			debris:AddItem(model:FindFirstChild('Settings'),0)
		end
	end
end

function fn:Builds()
	if Client or self.IsBuildComplete then return end
	
	local condicion = not not (self.Occuped and self.Owner)
	self.Base.Transparency = condicion and 1 or 0
	self.Base.CanCollide = not condicion
	
	self.Store:ClearAllChildren()
	--self.Decors:ClearAllChildren()

	self:GetStore()
	
	if not condicion then
		self:RetirarJugadores()
	end
end

function fn:Update(Open_Close)
	if Client then
		Events:WaitForChild('ClaimStore'):FireServer(self.Base, Open_Close)
	else
		if Open_Close then
			Events:WaitForChild('ClaimStore'):FireClient(Open_Close, self.Owner,self.Base,self.Occuped,self.ChildsBase,self.StoreModel)
		else
			self:Builds()
			Events:WaitForChild('ClaimStore'):FireAllClients(self.Owner,self.Base,self.Occuped,self.ChildsBase,self.StoreModel)
		end
	end
end

function fn:ChangeDesing(Base, ColorTexture)
	if Client then
		Events:WaitForChild('ChangeDesing'):FireServer(Base,ColorTexture)
	elseif Base and ColorTexture then
		for _,v in self.ChildsBase do
			if Base == v.Value or Base == v.Model then
				for Name,Valor in ColorTexture do
					if not Changes[Name] then continue end
					v.Value:SetAttribute(Name, Valor)
				end
				break
			end
		end
	end
end

function fn:GetParts()
	if self.StoreModel then
		local modelTemplate = self.StoreModel.model
		local list = {
			Walls = self.GetChilds(modelTemplate:FindFirstChild("Hitbox"), "Walls", self.GetChilds(modelTemplate, "Walls")),
			Floors = self.GetChilds(modelTemplate, "Floors"),
			Ceiling = self.GetChilds(modelTemplate, "Ceiling"),
			NoCollition = self.GetChilds(modelTemplate:FindFirstChild("Hitbox"), "NoCollitions"),
		}
		return list
	end
end

return fn
