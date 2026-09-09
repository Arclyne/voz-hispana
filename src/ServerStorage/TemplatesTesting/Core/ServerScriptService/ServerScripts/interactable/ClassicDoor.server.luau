local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunS = game:GetService("RunService")
local debris = game:GetService("Debris")
local ListDoors = {}

local remotes = ReplicatedStorage:WaitForChild("Events")
local SignalGames = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SignalsGame"))

local listVerificaciones = {}

local fn = {}
fn.__index = fn

function fn.new(model : Model)
	local self = setmetatable({
		actives = {},
		model = model,
	}, fn)
	table.insert(ListDoors, self)
	self:Init()
	return self
end

function fn:GetOrientation(Position)
	local localPos = Position and self.OriginalPosition:PointToObjectSpace(Position) or Vector3.new(1,0,0)
	return CFrame.Angles(0,math.rad(90*(not self.model:GetAttribute("IsOpen") and math.sign(localPos.X) or 0)),0)
end

function fn:OpenClose(Player : Player, Position)
	if self.actives.TweenActive then return end
	
	local Verificacion = Player and GetVerificacion(self.model)
	if Verificacion then
		if not Verificacion:Verificacion(Player, self.model) then
			return
		end
	end
	
	self.model:SetAttribute("IsActionInProcess", true)
	local tickk = tick()
	local NewPosition = self.OriginalPosition*self:GetOrientation(Player and Player.Character:GetPivot().Position or Position)
	local LastPosition = self.model:GetPivot()
	self.actives.TweenActive = RunS.Heartbeat:Connect(function()
		local ElapsedTime = math.min(tick() - tickk, self.TimeAnimation) / self.TimeAnimation
		self.model:PivotTo(LastPosition:Lerp(NewPosition,ElapsedTime))
		if ElapsedTime >= 1 then
			self.actives.TweenActive:Disconnect()
			self.actives.TweenActive = nil
			self.model:SetAttribute("IsActionInProcess", false)
			self.model:SetAttribute("IsOpen", not self.model:GetAttribute("IsOpen"))
		end
	end)
end

function fn:action(Player : Player, Action)
	if Action == "OpenClose" then
		self:OpenClose(Player)
	end
end
function fn:Init()
	local tag = self.model:GetAttribute("Pertenencia")
	if tag == "NightClub" then
		
		if not listVerificaciones[tag] then
			local moduleInstance = ReplicatedStorage
				:WaitForChild("Shared")
				:FindFirstChild("NightClub")
			listVerificaciones[tag] = moduleInstance and require(moduleInstance) or nil
		end
		
	end
	self.OriginalPosition = self.model:GetPivot()
	self.TimeAnimation = self.model:GetAttribute("TimeAnimation") or 0.5
end
function fn:Destroy()
	Desactive(self.actives)
	table.remove(ListDoors, table.find(ListDoors, self))
	if self.model:IsDescendantOf(game) then
		self.model:PivotTo(self.OriginalPosition)
		self.model:SetAttribute("IsActionInProcess", false)
		self.model:SetAttribute("IsOpen", false)
	end
end

function Desactive(list, ...)
	local all = {...}
	if #all > 0 then
		for _,v in all do
			if list[v] then
				list[v]:Disconnect()
				list[v] = nil
			end
		end
	else
		for _,v in list do
			v:Disconnect()
		end
		table.clear(list)
	end
end
function GetVerificacion(Model, again)
	local tag = Model:GetAttribute("Pertenencia")
	local filtro = tag and listVerificaciones[tag]
	if filtro then
		if tag=="NightClub" then
			if filtro.model then
				return filtro
			elseif not again then
				ActivarModulos(tag)
				return GetVerificacion(Model, true)
			end
		else
			return filtro
		end
	end
end
function ActivarModulos(NameModulo)
	local moduleSelect = listVerificaciones[NameModulo or ""]
	if moduleSelect then
		if NameModulo=="NightClub" then
			if not moduleSelect.model then
				listVerificaciones[NameModulo] = moduleSelect.new()
			end
		end
	end
end
function SearchModel(Model:Model)
	for _, v in ListDoors do
		if v.model == Model then
			return v
		end
	end
end

remotes.Interactable:WaitForChild("ClassicDoor").OnServerEvent:Connect(function(p,m,a)
	local door = SearchModel(m)
	if door then door:action(p,a) end
end)

SignalGames:OnEvent("OpenCloseDoors", function(model, Position)
	local door = SearchModel(model)
	if door then door:OpenClose(false, Position) end
end)

for _,model in CollectionService:GetTagged("ClassicDoor") do fn.new(model) end
CollectionService:GetInstanceAddedSignal("ClassicDoor"):Connect(fn.new)
CollectionService:GetInstanceRemovedSignal("ClassicDoor"):Connect(function(model)
	local door = SearchModel(model)
	if door then door:Destroy() end
end)