local module = {}
module.__index = module

local RS = game:GetService("ReplicatedStorage")
local eventCustom = require(RS:WaitForChild("Client"):WaitForChild("Event"))
local Players = game:GetService("Players")
local Running = require(RS:WaitForChild("Shared"):WaitForChild("Running"))

local dataParts = {}
local RunActive
local Updating

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

function Updating()
	RunActive = RunActive or Running:AddFunct(function()
		local IsEnd = true
		for _, Area in dataParts do
			if Area.IsDestroyed then continue end
			IsEnd = false
			break
		end
		if IsEnd then
			RunActive = Running:ElimineFunct(RunActive)
		else
			for _, Player : Player in Players:GetPlayers() do
				local Position = Player.Character and Player.Character:GetPivot().Position
				for _, area in dataParts do
					task.defer(area.UpdatePlayer, area, Player, Position)
				end
			end
		end
	end, .3)
end

function added(self)
	local actives = {}
	table.insert(actives, self.model.AncestryChanged:Connect(function(_, parent)
		if parent then return end
		Desactive(actives)
		self:destroy()
		dataParts[self.model] = nil
	end))
end

--------------------Funciones plataforma
function module.new(BasePart :  BasePart)
	assert(typeof(BasePart) == "Instance" and BasePart:IsA("BasePart"), "Only BaseParts.")
	if not dataParts[BasePart] then
		local self = setmetatable({
			model = BasePart,
			Players = {},
			PlayerAdded = eventCustom.new(),
			PlayerRemoved = eventCustom.new(),
		},  module)
		dataParts[BasePart] = self
		added(self)
		Updating()
	end
	return dataParts[BasePart]
end

function module:Added(Player : Player)
	if self.IsDestroyed then return end
	if not self.Players[Player.UserId] then
		local list = {
			EntryTime = DateTime.now().UnixTimestampMillis,
			Player = Player,
		}
		list.PlayerRemoving = Player.AncestryChanged:Connect(function()
			self:Removed(Player)
		end)
		self.Players[Player.UserId] = list
		self.PlayerAdded:Fire(Player)
	end
end
function module:Removed(Player : Player)
	if self.IsDestroyed then return end
	local Data = self.Players[Player.UserId]
	if Data then
		Desactive(Data,"PlayerRemoving")
		self.PlayerRemoved:Fire(Data.Player)
		self.Players[Player.UserId] = nil
	end
end
function module:GetPlayer(Player : Player)
	return self.Players[Player.UserId]
end

function module:GetPlayers()
	local list = {}
	for _, data in self.Players do
		table.insert(list, data.Player)
	end
	return list
end

function module:UpdatePlayer(player, position)
	local inside = self.Players[player.UserId]
	if inside then
		if not position or self:IsOut(position) then
			self:Removed(player)
		end
	elseif position and self:IsInArea(position) and self:IsInside(position) then
		self:Added(player)
	end
end

function module:IsInside(Position : Vector3)
	return Position and (self.model:GetClosestPointOnSurface(Position)-Position).Magnitude < .1
end

function module:IsOut(Position : Vector3)
	return not self:IsInside(Position)
end

function module:IsInArea(Position : Vector3)
	return (self.model.Position - Position).Magnitude < self.model.Size.Magnitude * .75
end

function module:destroy()
	if self.IsDestroyed then return end
	for UserId, Data in self.Players do
		self.PlayerRemoved:Fire(Data.Player)
	end
	self.PlayerAdded:Destroy()
	self.PlayerRemoved:Destroy()
	table.clear(self)
	self.IsDestroyed = true
end
---------------------------------------

return module