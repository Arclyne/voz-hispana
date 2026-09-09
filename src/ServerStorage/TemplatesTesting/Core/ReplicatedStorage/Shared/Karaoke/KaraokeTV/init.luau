local module = {}
module.__index = module

local IsClient = game:GetService('RunService'):IsClient()

local Players = game:GetService('Players')

local RS = game:GetService('ReplicatedStorage')
local Events = RS:WaitForChild('Events'):WaitForChild('Karaoke'):WaitForChild('Televisiones')
local TextoSettings = require(RS:WaitForChild("Client"):WaitForChild("BusquedaSettings"))
local EventCustom = require(RS:WaitForChild("Client"):WaitForChild("Event"))

local RBXScriptSignal = {{'TVAddedEvent','TVAdded'},{'TVRemovedEvent','TVRemoved'}}
local TV = require(script:WaitForChild('TV'))
TV.Events = Events:WaitForChild('Instance')

local FuncionesTV = require(script:WaitForChild('FunctActionsTV'))
local IsA = "PublicSong"

function module.new()
	local self = setmetatable({
		actives = {},
		Televisiones = {},
		maxDistance = 50,
		Events = Events,
		
		PreloadSongs = {
			AllSongs = {
				IsLimit = true,
				NumberPage = 0,
				LastPage = 1,
				ListDatas = {}
			},
			Separate = {},
			cache = {},
		},
		
		BuscadorChanged = IsClient and EventCustom.new() or nil,
		CacheAdded = IsClient and EventCustom.new() or nil,
		CacheRemoved = IsClient and EventCustom.new() or nil,
		DataChange = IsClient and EventCustom.new() or nil,
		
		AntiSpamBusqueda = {},
		SongPorPagina = 10,
		
	}, module)
	
	self.FuncionesTV = FuncionesTV
	TV.Parent = self
	
	return self
end

function module:IsA(text) return IsA == text end
--//Songs funciones principales

function module:GetCacheLoaded(Player, Data)
	if IsClient or not Data or not Data.IsLoaded then return end
	Data = table.clone(Data)
	local Reports = self.RevisarCanciones:GetStorageCache("Report")[Data.Name]
	Data.IsReported = Reports and TextoSettings.GetInfoRevision(Reports, tostring(Player.UserId))
	if not self.Admins:IsAdmin(Player) then
		TextoSettings.RemoveInfoRevision(Data, "BuzonAdminSong")
	end
	return Data
end
function module:GetDataLoaded(Player)
	if IsClient then return end
	local section = table.clone(self:GetStorageCache())
	for key, data in section do
		section[key] = self:GetCacheLoaded(Player, data)
	end
	return section
end

function module:SentCache(Player,Information)
	if IsClient then return end
	Events:WaitForChild('ObtenerMusicas'):FireClient(Player,"cache",Information and {
		IsEspecific = true,
		Key = Information,
		Cache = self:GetCacheLoaded(Player,self:GetStorageCache()[Information]),
	} or self:GetDataLoaded(Player))
end

function module:ObtenerMusica(Page, Information, Player:Player)
	if typeof(Page) == 'number' then
		if not IsClient then
			if Player then
				Events:WaitForChild('ObtenerMusicas'):FireClient(Player,Page,self.PreloadSongs.AllSongs)
			else
				Events:WaitForChild('ObtenerMusicas'):FireAllClients(Page,self.PreloadSongs.AllSongs)
			end
		elseif typeof(Information) == 'table' then
			self.PreloadSongs.AllSongs = Information
			self.DataChange:Fire()
		end
	elseif typeof(Page) == 'string' then
		if Page == 'cache' then
			if not IsClient then
				if Player then
					self:SentCache(Player, Information)
				else
					for _,plr in Players:GetPlayers() do
						self:SentCache(plr, Information)
					end
				end
			elseif typeof(Information) == 'table' then
				if not Information.IsEspecific then
					self.PreloadSongs.cache = Information
				else
					local lastCache = self.PreloadSongs.cache[Information.Key]
					self.PreloadSongs.cache[Information.Key] = Information.Cache
					if lastCache ~= Information.Cache then
						local EventSelected = Information.Cache and self.CacheAdded or self.CacheRemoved
						EventSelected:Fire(Information.Key)
					end
				end
			end
		elseif Page == 'Busqueda' then
			if not IsClient then
				local index = Information or self.PreloadSongs.Separate
				local Cache = Information and self.PreloadSongs.Separate[Information] or nil
				if Player then
					Events:WaitForChild('ObtenerMusicas'):FireClient(Player,Page,index,Cache)
				else
					Events:WaitForChild('ObtenerMusicas'):FireAllClients(Page,index,Cache)
				end
			elseif typeof(Information) == 'table' then
				self.PreloadSongs.Separate = Information
			elseif typeof(Information) == "string" then
				self.PreloadSongs.Separate[Information] = Player
				self.BuscadorChanged:Fire(Information)
			end
		end
	end
end

function module:GetStorageCache()
	if IsClient then
		return self.PreloadSongs.cache
	else
		return self.DataStore.PalabrasFunc.cache.Success.Publicas
	end
end

function module:IsAviableToUpdate()
	return #Players:GetPlayers() > 0
end

function module:UpdateMusicas()
	if not IsClient then
		if self:IsAviableToUpdate() then
			if not self.UpdateMusicasUpdate then
				self.UpdateMusicasUpdate = task.spawn(function()
					self:CargarMusicasServer(self.PreloadSongs.AllSongs.LastPage)
					task.wait(self.DataStore.TimeUpdateGlobalData + 1)
					self.UpdateMusicasUpdate = nil
					self:UpdateMusicas()
				end)
			end
		elseif self.UpdateMusicasUpdate then
			task.cancel(self.UpdateMusicasUpdate)
			self.UpdateMusicasUpdate = nil
			self.PreloadSongs = {
				AllSongs = {
					IsLimit = true,
					NumberPage = 0,
					ListDatas = {}
				},
				Separate = {},
				cache = {},
			}
			TV.PreloadSongs = self.PreloadSongs
			self:UpdateMusicas()
		end
	end
end

function module:CargarMusicasServer(Page, Player:Player)
	if IsClient then
		self.Events:FindFirstChild('CargarMusicas'):FireServer(Page)
	elseif typeof(Page) == 'number' then
		local Data,NewData = self.DataStore:GetData('MusicasRating',false,self.SongPorPagina,Page)
		if Data.Success then
			self.PreloadSongs.AllSongs.NumberPage = Data.TotalPages
			self.PreloadSongs.AllSongs.IsLimit = Data.IsLimit
			self.PreloadSongs.AllSongs.ListDatas = NewData and {} or self.PreloadSongs.AllSongs.ListDatas
			self.PreloadSongs.AllSongs.LastPage = math.max(Data.TotalPages, 1)
			if Data.TotalPages > 0 then
				for index,info in Data.Pages do
					if not self.PreloadSongs.AllSongs.ListDatas[index] then
						local list = {}
						for _,keySong in info do
							local Key = tostring(keySong.key)
							table.insert(list,Key)
							self.DataStore.PalabrasFunc.AddToLoadCache(self.DataStore, {
								clave = Key,
								ExtraData = {
									reproducciones = tonumber(keySong.value),
								},
								origin = "MusicasRating",
							})
						end
						self.PreloadSongs.AllSongs.ListDatas[index] = list
					end
				end
			else
				warn('no hay musicas publicas disponible')
			end
			self:ObtenerMusica(0,nil,Player)
		else
			warn(Data)
		end
	end
end

--//TV instances
function module:Removed(Model : Model)
	local VerificarExistencia = self:FindTV(Model)
	if VerificarExistencia then
		VerificarExistencia:Off()
		table.remove(self.Televisiones, table.find(self.Televisiones, VerificarExistencia))
	end
end
function module:Added(Model : Model)
	local VerificarExistencia = self:FindTV(Model)
	if not VerificarExistencia then
		local TvInstance = TV.new(Model)
		if TvInstance then
			table.insert(self.Televisiones, TvInstance)
			table.insert(TvInstance.actives, TvInstance.Model.AncestryChanged:Connect(function(_,Parent)
				if not Parent then self:Removed(TvInstance.Model) end
			end))
			if not IsClient then Events:FindFirstChild('TVAdded'):FireAllClients(TvInstance.Model) end
			return TvInstance
		end
	end
end
function module:GetTvs(OnlyModel)
	local list = {}
	for _,TV in self.Televisiones do
		if TV.IsActive then table.insert(list, OnlyModel and TV.Model or TV) end
	end
	return list
end
function module:FindTV(Model : Model, OnlyActives)
	for _,TV in self.Televisiones do
		if TV.Model == Model and (not OnlyActives or TV.IsActive) then
			return TV
		end
	end
end
--//
function module:Works()
	if self.IsActive then return end
	self.IsActive = true
	
	TV.maxDistance = self.maxDistance
	
	if IsClient then
		table.insert(self.actives, Events:WaitForChild('ObtenerMusicas').OnClientEvent:Connect(function(...) self:ObtenerMusica(...) end))
		table.insert(self.actives, Events:WaitForChild('GetTelevisiones').OnClientEvent:Connect(function(list)
			if typeof(list) then for _,TVmodel in list do self:Added(TVmodel) end end
		end))
		table.insert(self.actives, Events:WaitForChild('TVAdded').OnClientEvent:Connect(function(...) self:Added(...) end))
		table.insert(self.actives, Events:WaitForChild('TVRemoved').OnClientEvent:Connect(function(...) self:Removed(...) end))
		Events:FindFirstChild('GetTelevisiones'):FireServer()
		Events:FindFirstChild('ObtenerMusicas'):FireServer(0)
		Events:FindFirstChild('ObtenerMusicas'):FireServer('cache')
		Events:FindFirstChild('ObtenerMusicas'):FireServer('Busqueda')
		
		--[[self.BuscadorAdded:Connect(function(key)
			print(self.PreloadSongs.Separate[key])
		end)
		self.CacheAdded:Connect(function(key)
			print(self.PreloadSongs.cache[key])
		end)
		self.CacheRemoved:Connect(function(key)
			print(self.PreloadSongs.cache[key])
		end)
		self.DataChange:Connect(function()
			print(self.PreloadSongs.AllSongs)
		end)]]
		
	else
		TV.CreacionSong = self.CreacionSong
		TV.DataStore = self.DataStore
		TV.Running = self.Running
		table.insert(self.actives,self.Events:FindFirstChild('ObtenerMusicas').OnServerEvent:Connect(function(usuario,t,b) self:ObtenerMusica(t,b,usuario) end))
		table.insert(self.actives, Events:WaitForChild('GetTelevisiones').OnServerEvent:Connect(function(Player:Player)
			Events:FindFirstChild('GetTelevisiones'):FireClient(Player, self:GetTvs(true))
		end))
		table.insert(self.actives, Events:FindFirstChild('CargarMusicas').OnServerEvent:Connect(function(Player:Player, Page)
			self:CargarMusicasServer(Page, Player)
		end))
		Events:FindFirstChild('GetTelevisiones'):FireAllClients(self:GetTvs(true))
	end
	for _,Remotes in Events:WaitForChild('Instance'):GetChildren() do
		if Remotes:IsA('RemoteEvent') then
			local EventActive = IsClient and Remotes.OnClientEvent or Remotes.OnServerEvent
			table.insert(self.actives, EventActive:Connect(function(...) FuncionesTV[Remotes.Name](self,...) end))
		elseif Remotes:IsA('RemoteFunction') then
			local EventActive = IsClient and Remotes.OnClientInvoke or Remotes.OnServerInvoke
			EventActive = function(...) return FuncionesTV[Remotes.Name](self,...) end
		end
	end
end

return module.new()
