local module = {}
module.__index = module

local Players = game:GetService("Players")
local IsClient = game:GetService('RunService'):IsClient()
local TextoSettings = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("BusquedaSettings"))
local GroupService : GroupService = not IsClient and game:GetService("GroupService") or nil

function module.new()
	local self = setmetatable({
		RoleService = not IsClient and require(game:GetService('ServerStorage'):WaitForChild('RoleService')) or nil,
		
		CrearCancion = require(script:WaitForChild('CrearCancion')),
		RevisarCanciones = require(script:WaitForChild('RevisarCanciones')),
		TvKaraoke = require(script:WaitForChild('KaraokeTV')),
		
	}, module)

	self.TvKaraoke.RevisarCanciones = self.RevisarCanciones
	self.TvKaraoke.CreacionSong = self.CrearCancion
	self.TvKaraoke.Admins = self
	
	self.CrearCancion.RevisarCanciones = self.RevisarCanciones
	
	self.RevisarCanciones.CreacionSong = self.CrearCancion
	self.RevisarCanciones.TvKaraoke = self.TvKaraoke
	self.RevisarCanciones.Admins = self
	
	return self
end

function module:Fire(Owner:Player,...)
	if IsClient then
		self.Event:FireServer(Owner,...)
	elseif Owner and Owner:IsDescendantOf(game) then
		self.Event:FireClient(Owner,...)
	end
end
function module:GetEvent()
	local Event:RemoteEvent = game:GetService('ReplicatedStorage'):WaitForChild('Events'):WaitForChild('Karaoke'):WaitForChild('Administracion')
	self.Event = Event
	self.Changed = IsClient and Event.OnClientEvent or Event.OnServerEvent
end

function module:FireOnlyAdmins(Remote:RemoteEvent,...)
	if not IsClient and Remote then
		for _,Staff:Player in self.RevisarCanciones.AdminsActive do
			Remote:FireClient(Staff,...)
		end
	end
end
function module:FireNoAdmins(Remote:RemoteEvent,...)
	if not IsClient and Remote then
		for _,NoStaff : Player in Players:GetPlayers() do
			if not table.find(self.RevisarCanciones.AdminsActive, NoStaff) then
				Remote:FireClient(NoStaff,...)
			end
		end
	end
end

function module:GetAdmin(count)
	if not IsClient then
		count = tonumber(count) or 5
		for UserId in self.Admins do
			if count<=0 or math.random(1,3) == 3 then
				return UserId
			end
		end
		return self:GetAdmin(count - 1)
	end
end

function module:IsAdmin(Player:Player, SuperAdmin)
	if IsClient then
		self:Fire('Administracion')
	else
		return self.RoleService:IsRole(Player, SuperAdmin and "KaraokeSuperAdmin" or "KaraokeAdmins")
		--[[local UserId = Player and (typeof(Player)=="number" and Player or Player.UserId)
		local IsAdmin = UserId and self.Admins[UserId]
		return IsAdmin and (not SuperAdmin or IsAdmin==true)]]
	end
end

function module:IntenteSerAdmin(Player:Player)
	if IsClient then
		self:Fire('IntentoExploiter')
	elseif typeof(Player)=="Instance" and
		not self:IsAdmin(Player) then
		Player:Kick('You do not have the administrator role. If you continue trying to gain administrator access, you may be banned.')
	end
end

function module:GetSongByText(Player,Text,Direction)
	Direction = IsClient and Text or Direction or "Revision"
	Text = TextoSettings.LimitCharacter(IsClient and Player or Text, TextoSettings.LimitCharacterBusqueda)
	if not Text then return end
	local indices = TextoSettings.getIndices(Text)
	if not indices then return end
	if IsClient then
		if self.LastPalabra ~= Text then
			self.LastPalabra = Text
			self.Event:FireServer("GetSongByText",Text,Direction)
		end
		local resultados = {}
		
		local Controller = table.find({"Publicas","Reportes"}, Direction) and self.TvKaraoke or self.RevisarCanciones
		
		for index, datos in Controller.PreloadSongs.Separate do
			local Coinciden = false
			for _,coincidencia in indices do
				if string.match(index,coincidencia) then
					Coinciden = true
					break
				end
			end
			if Coinciden  then
				for _,key in datos do
					resultados[key] = (resultados[key] or 0) + 1
				end
			else
				continue
			end
		end
		for _,_ in resultados do
			return resultados, indices
		end
		
		return false, indices
	elseif TextoSettings.PuedeBuscar(Player) then
		self.KaraokeDS.PalabrasFunc.SearchPalabrasClaves(self.KaraokeDS,indices,Direction)
	end
end

function module:Works()
	
	self:GetEvent()
	
	if not IsClient then
		
		self.TvKaraoke.DataStore = self.KaraokeDS
		self.CrearCancion.DataStore = self.KaraokeDS
		self.RevisarCanciones.DataStore = self.KaraokeDS
		
		self.KaraokeDS.SolicitacionesKey = {
			Revision = self.RevisarCanciones,
			Publicas = self.TvKaraoke,
		}
		
		self.Changed:Connect(function(Player:Player,Key,...)
			if Key == 'Administracion' then
				self:Fire(Player,'Administracion',self:IsAdmin(Player))
			elseif Key == 'IntentoExploiter' then
				self:IntenteSerAdmin(Player)
			elseif Key == "GetSongByText" then
				self:GetSongByText(Player,...)
			end
		end)
		
		self.RoleService.RoleAdded:Connect(function(Player : Player, NameRole)
			if NameRole ~= "KaraokeAdmins" then return end
			self.RevisarCanciones:AdminAdded(Player)
		end)
		self.RoleService.RoleRemoved:Connect(function(Player : Player, NameRole)
			if NameRole ~= "KaraokeAdmins" then return end
			self.RevisarCanciones:AdminRemoved(Player)
		end)
		
	else
		self.CrearCancion = self.CrearCancion.new(Players.LocalPlayer:WaitForChild("Biblioteca"))
	end
	
	self.RevisarCanciones:Works()
	self.TvKaraoke:Works()
end

return module.new()
