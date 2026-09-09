--[=[
	Resuelve los roles de un jugador contra un grupo de Roblox, con caché.

	Es la única fuente de autorización del juego: no hay ninguna lista de `UserId` en el
	código. Los comandos de eventos, la moderación de karaoke y las tiendas preguntan aquí.

	Dos propiedades que conviene tener presentes:

	* **Falla cerrado.** Si la consulta a `GroupService` falla, el resultado es una tabla de
	  roles vacía, no un pase libre. Es lo contrario de lo que hacen el control de chat de
	  voz y el filtrado de texto, que fallan abiertos.
	* **Cachea 50 segundos** (`TimeHold`). Conceder un rango se nota casi al momento;
	  **retirarlo tarda hasta ese tiempo en surtir efecto**. Está registrado como
	  BUG-CANDIDATE-017 en el plan de verificación.

	@class RoleService
	@server
]=]
local module = {}
module.__index = module

local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")

local EventCustom = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("Event"))

local function GetElapsedTime(t)
	return (DateTime.now().UnixTimestampMillis - t) / 1000
end

function module.new()
	local self = setmetatable({
		GroupId = 16663699,
		Usuarios = {},
		RangosData = require(script:WaitForChild("RolesGroup")),
		TimeHold = 50,
		
		Added = EventCustom.new(),
		Removing = EventCustom.new(),
		Changed = EventCustom.new(),
		
		Joined = EventCustom.new(),
		Left = EventCustom.new(),
		
		RoleAdded = EventCustom.new(),
		RoleRemoved = EventCustom.new(),
	}, module)
	
	task.spawn(function()
		while task.wait(10) do
			self:Updating()
		end
	end)
	
	return self
end
function module:IsRole(Player:Player,NameRole)
	assert(typeof(NameRole) == "string", "Only string")
	return self:GetInfoPlayer(Player).Roles[NameRole] or false
end
function module:GetInfoPlayer(Player)
	return self:PlayerAdded(Player)
end
function module:GetRoles(Roles)
	if typeof(Roles) ~= "table" or #Roles==0 then return {} end
	local RolesList = {}
	local actualRoes = {}
	for _,DataRole in Roles do
		actualRoes[tonumber(DataRole.Id)] = true
	end
	for NameRole, Ids in self.RangosData do
		for RoleIde in Ids do
			if actualRoes[RoleIde] then
				RolesList[NameRole] = true
				break
			end
		end
	end
	return RolesList
end
function module:CompareRole(Player:Player, NewRoles, LastRoles)
	for NameRole in NewRoles do
		if not LastRoles[NameRole] then
			self.RoleAdded:Fire(Player, NameRole)
		end
	end
	for NameRole in LastRoles do
		if not NewRoles[NameRole] then
			self.RoleRemoved:Fire(Player, NameRole)
		end
	end
end
function module:PlayerAdded(Player : Player)
	local LastData = self.Usuarios[Player.UserId]
	if not LastData or GetElapsedTime(LastData.UpdateTime) >= self.TimeHold then
		local Sucess, DataGroup = pcall(GroupService.GetRolesInGroupAsync, GroupService, Player.UserId, self.GroupId)
		local NewData = {
			UpdateTime = DateTime.now().UnixTimestampMillis,
			IsMember = Sucess and DataGroup and DataGroup.IsMember,
			Member = Player,
			Roles = self:GetRoles(Sucess and DataGroup and DataGroup.Roles),
		}
		self.Usuarios[Player.UserId] = NewData
		if not LastData then
			self.Added:Fire(Player)
		else
			if NewData.IsMember ~= LastData.IsMember then
				local EventSelected = NewData.IsMember and self.Joined or self.Left
				EventSelected:Fire(Player)
			end
			self:CompareRole(Player, NewData.Roles, LastData.Roles)
			self.Changed:Fire(Player)
		end
		LastData = NewData
	end
	return LastData
end
function module:PlayerRemoving(UserId)
	local LastData = self.Usuarios[UserId]
	if LastData then
		self.Usuarios[UserId] = nil
		self.Removing:Fire(LastData.Member)
	end
end
function module:Updating()
	for UserId,Data in self.Usuarios do
		local Player:Player = Players:GetPlayerByUserId(UserId)
		if Player then
			self:PlayerAdded(Player)
		else
			self:PlayerRemoving(UserId)
		end
	end
end
return module.new()