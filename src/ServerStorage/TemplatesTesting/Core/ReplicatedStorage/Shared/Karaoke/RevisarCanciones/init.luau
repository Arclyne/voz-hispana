local module = {}
module.__index = module

local IsClient = game:GetService('RunService'):IsClient()
local RS = game:GetService("ReplicatedStorage")
local TextoSettings = require(RS:WaitForChild("Client"):WaitForChild("BusquedaSettings"))
local EventCustom = require(RS:WaitForChild("Client"):WaitForChild("Event"))
local HttpService:HttpService = not IsClient and game:GetService("HttpService")

local IsA = "Revisiones"

function module.new()
	local self = setmetatable({
		
		Events = RS:WaitForChild('Events'):WaitForChild('Karaoke'):WaitForChild('RevisarAdmis'),
		MessagingService = not IsClient and game:GetService('MessagingService') or nil,
		SuscribeKey = not IsClient and 'AdminsMessaging' or nil,
		AdminsActive = not IsClient and {} or nil,
		RequerestPublishSong = require(script:WaitForChild('AttributesRequerest')),
		
		MessageAproveSong = 'Congratulations, your music has been accepted.',
		MessageUnban = "Your music has been unbanned, you can now edit it again and apply for it to be published.",
		SectionsCacheNames = {reportCache = "Reports", cache = "Revision", bannCache = "Bans"},
		
		PreloadSongs = {
			AllSongs = {
				IsLimit = true,
				NumberPage = 0,
				LastPage = 1,
				ListDatas = {}
			},
			
			AllReported = {
				IsLimit = true,
				NumberPage = 0,
				LastPage = 1,
				ListDatas = {}
			},
			
			AllBans = {
				IsLimit = true,
				NumberPage = 0,
				LastPage = 1,
				ListDatas = {}
			},
			
			Separate = {},
			
			cache = IsClient and {},
			reportCache  = IsClient and {},
			bannCache  = IsClient and {},
			
		},
		
		BuscadorChanged = IsClient and EventCustom.new() or nil,
		CacheAdded = IsClient and EventCustom.new() or nil,
		CacheRemoved = IsClient and EventCustom.new() or nil,
		DataChange = IsClient and EventCustom.new() or nil,
		
		SongPorPagina = 10,
		
		MessagingActives = {},
		AntiSpamBusqueda = {},
		
		AntiSpamRevision = {
			Cooldown = 60 * 5,
		},
		
	}, module)
	
	return self
end
--//Player Client
function module:IsA(text) return IsA == text end

function module:VerifyRequerimientosMusica(song : Instance)
	if song then
		local Aceptado = true
		local requerimientosFaltantes = {}
		local TotalRequermientos = 0
		for AtributoNecesario,tipoInfo in self.RequerestPublishSong do
			TotalRequermientos += 1
			local Attribute = song:GetAttribute(AtributoNecesario)
			if not Attribute or typeof(Attribute) ~= tipoInfo then
				Aceptado = false
				table.insert(requerimientosFaltantes, AtributoNecesario)
			end
		end
		return Aceptado, requerimientosFaltantes, TotalRequermientos
	end
end
----//Public
function module:ProyectosPendientes(Player:Player)
	if not IsClient and Player and Player:IsDescendantOf(game) then 
		local Biblioteca = Player:FindFirstChild('Biblioteca')
		if Biblioteca and #Biblioteca.Value > 0 then
			self:SuscribeAsync(tostring(Player.UserId)..'KaraokeSongsNotification')
		else
			self:DesuscribeAsync(tostring(Player.UserId)..'KaraokeSongsNotification')
		end
	end
end

function module:Denunciar(Player:Player, KeySound, MessageDenuncia)
	if IsClient then
		self.Events:FindFirstChild('DenunciarMusica'):FireServer(Player,KeySound)
	else
		local list = {
			Success = false,
			ErrorMessage = 'Hubo un error.',
		}
		if typeof(KeySound) ~= 'string' then
			list.ErrorMessage = "Datos erroneos enviados."
			return list
		end
		MessageDenuncia = TextoSettings.LimitCharacter(MessageDenuncia, TextoSettings.LimitCharacterReport)
		if not MessageDenuncia then
			list.ErrorMessage = "No puedes enviar un mensaje vacio."
			return list
		end
		
		local KaraokeData = Player:FindFirstChild("Biblioteca")
		if not KaraokeData then return list end

		local IsAviableCooldown, faltante = TextoSettings.IsAviableCooldown(KaraokeData:GetAttribute('CooldownReport'), 60)
		if not IsAviableCooldown then
			list.ErrorMessage = string.format("Espera %s para un nuevo reporte.", TextoSettings.FormatTime(faltante))
			return list
		end
		
		local CacheData = self.TvKaraoke:GetStorageCache()[KeySound]
		if not CacheData then
			list.ErrorMessage = "No data found."
			return list
		end
		local LocalData = CacheData and self:GetStorageCache("Report")[KeySound]
		if LocalData and TextoSettings.GetInfoRevision(LocalData, tostring(Player.UserId)) then
			list.ErrorMessage = "Ya has reportado esta musica."
			return list
		end
		
		KaraokeData:SetAttribute('CooldownReport', DateTime.now().UnixTimestampMillis)
		
		local success,DataCloneImage = self.DataStore:UpdateData('KaraokeSongsData',KeySound,function(LastData)
			if not LastData then
				list.ErrorMessage = 'No pudimos encontrar los datos de la musica.'
				return LastData
			end
			local State = TextoSettings.GetInfoRevision(LastData)
			if not State or not State.Value then
				list.ErrorMessage = 'No puedes reportar una musica privada.'
				return LastData
			end
			local Denuncias = TextoSettings.CreateInfoRevision(LastData,'Denuncias')
			local RevisioLast = TextoSettings.GetInfoRevision(Denuncias,tostring(Player.UserId))
			if not RevisioLast then
				Denuncias.Childs[tostring(Player.UserId)] = {
					Name = tostring(Player.UserId),
					Value = MessageDenuncia,
					DateDenuncia = tostring(DateTime.now().UnixTimestamp),
				}
				list.Success = true
				list.ErrorMessage = "Se ha reportado la musica."
			else
				list.ErrorMessage = 'Ya has reportado esta musica.'
			end
			return LastData
		end)
		if success then
			if list.Success then
				self.DataStore:UpdateData('DenunciasRating',KeySound,function(LastData) return (tonumber(LastData) or 0) + 1 end)
				self:PublishAsync('AdministracionGlobal',{
					Parametros = {KeySound, game.JobId},
					KeyFuncion = 'EliminarKeyDeCache',
				})
			end
			self.DataStore.PalabrasFunc.AddCache(self.DataStore,KeySound,DataCloneImage)
		end
		return list
	end
end
function module:PublishRevisarMusic(Player:Player)
	if IsClient then
		self.Events:FindFirstChild('PublishRevisarMusic'):FireServer()
	else
		local list = {
			Success = false,
			ErrorMessage = 'Hubo un error.',
		}
		
		local Karaokedata = self.DataStore.DataBase.DataComplete[Player.UserId]
		Karaokedata = typeof(Karaokedata)=="table" and Karaokedata.karaoke
		if not Karaokedata or not Karaokedata.IsActive or Karaokedata:IsDataStoreChange() then return list end
		
		local Song = Karaokedata.SongActive
		if not Song then
			list.ErrorMessage = "Musica no encontrada."
			return list
		end
		
		if Karaokedata:InvalidEdit(Karaokedata.SongActive) or Karaokedata:IsIdInSounds(Song.Name) then
			list.ErrorMessage = "No es posible publicar esta cancion."
			return list
		end
		local successRequerimientos, requerimientos = self:VerifyRequerimientosMusica(Song)
		if not successRequerimientos then
			list.ErrorMessage = "Informacion incompleta"
			return list
		end
		local sound:Sound = Song:FindFirstChild("Recursos")
		sound = sound and sound:FindFirstChild("SoundId")
		sound = sound and sound:GetAttribute("Id") == tonumber(Song:GetAttribute("SoundId")) and sound.IsLoaded
		if not sound then
			list.ErrorMessage = "La musica no está disponible."
			return list
		end
		
		local IsAviableCooldown, faltante = TextoSettings.IsAviableCooldown(Karaokedata.Songs:GetAttribute('Cooldown'), self.AntiSpamRevision.Cooldown)
		if not IsAviableCooldown then
			list.ErrorMessage = string.format("Espera %s para enviar una nueva cancion.", TextoSettings.FormatTime(faltante))
			return list
		end
		
		Song:SetAttribute("IsLast", nil)
		Karaokedata.Songs:SetAttribute('Cooldown', DateTime.now().UnixTimestampMillis + ((30-self.AntiSpamRevision.Cooldown) * 1000))
		
		local relase = Karaokedata:AddUseDataStore("PublishRevisarMusic")
		
		local success, Data
		local SavingLetter = Karaokedata:ExitEditedLyric()
		if SavingLetter.Success then
			success = true
			Data = SavingLetter.Data
		elseif SavingLetter.ErrorDataStore then
			relase()
			list.ErrorMessage = SavingLetter.ErrorMessage
			return list
		elseif Song:GetAttribute("IsLyricData") then
			success, Data = self.DataStore:GetData('Letras', Song.Name)
		else
			relase()
			list.ErrorMessage = "No hay letras."
			return list
		end
		if success then
			if not Data or #Data <= 0 then
				relase()
				list.ErrorMessage = "Tu musica no contiene letra."
				return list
			end
		else
			relase()
			return list
		end
		local State = {
			Name = 'State',
			Value = false,
			RevisionEnviada = tostring(DateTime.now().UnixTimestamp),
			Owner = tostring(Player.UserId),
			KeyRevision = HttpService:GenerateGUID(true),
		}
		local DataSong = self.DataStore:Values(Song)
		DataSong.Childs = DataSong.Childs or {}
		table.insert(DataSong.Childs, State)
		local nice, NewData = self.DataStore:UpdateData("KaraokeSongsData", Song.Name, function(Lastdata)
			if Lastdata then
				DataSong = table.clone(Lastdata)
				list.ErrorMessage = "La musica ya está publicada."
				return Lastdata
			end
			list.ErrorMessage = "Musica enviada con exito."
			list.Success = true
			return table.clone(DataSong)
		end)
		if nice then
			Karaokedata.Songs:SetAttribute('Cooldown', DateTime.now().UnixTimestampMillis)
			if list.Success then
				Karaokedata:AddedIdToSongs(Song.Name)
				Karaokedata.AddItem(State.Name,State.Value,State).Parent = Song
				self:ProyectosPendientes(Player)
				self.DataStore:SetData('RevisionRating',Song.Name,tonumber(State.RevisionEnviada))
				local palabras = TextoSettings.getIndices(TextoSettings.GetTextIndiceSong(NewData))
				if palabras then
					self.DataStore.PalabrasFunc.GuardarPalabrasClaves(self.DataStore,{
						key = Song.Name,
						claves = palabras,
					})
				end
			else
				self:CallbackDataPlayer(Player.UserId, NewData)
			end
		end
		relase()
		return list
	end
end
---//
function module:EliminarKeyDeCache(key, JobId)
	if not IsClient and typeof(key) == 'string' then
		if JobId ~= game.JobId then
			local Success, Data = self.DataStore:GetData("KaraokeSongsData", key)
			local palabrasfun = self.DataStore.PalabrasFunc
			if Success then
				if Data then
					palabrasfun.AddCache(self.DataStore,key, Data)
				else
					palabrasfun.RemoveCache(self.DataStore,key)
				end
			else
				palabrasfun.RemoveCache(self.DataStore,key)
				palabrasfun.AddToLoadCache(self.DataStore, {
					clave = key,
					origin = "Actualizacion Administracion",
				})
			end
		end
	end
end
function module:CallbackDataPlayer(UserId, KeyMusica, count)
	if IsClient or typeof(UserId) ~= 'number' then return end
	local Player : Player = game:GetService('Players'):GetPlayerByUserId(UserId)
	if not Player then return warn("no player") end

	local Karaokedata = self.DataStore.DataBase.DataComplete[Player.UserId]
	Karaokedata = typeof(Karaokedata)=="table" and Karaokedata.karaoke
	if not Karaokedata or not Karaokedata.IsActive then return end
	
	local Success, Data = true, false
	local relase
	
	if typeof(KeyMusica) == "string" then
		relase = Karaokedata:AddUseDataStore("CallbackDataPlayer")
		Success, Data = self.DataStore:GetData("KaraokeSongsData", KeyMusica)
	elseif typeof(KeyMusica) == "table" then
		relase = Karaokedata:AddUseDataStore("CallbackDataPlayer")
		Data = KeyMusica
	else
		return
	end
	
	if Success then
		if Data then
			TextoSettings.RemoveInfoRevision(Data, "Denuncias")
			local LocalData : BoolValue = Karaokedata.Songs:FindFirstChild(Data.Name)
			if LocalData then LocalData:Destroy() end
			local NewData = Karaokedata.AddItem(Data.Name,Data.Value,Data)
			NewData.Parent = Karaokedata.Songs
			if not TextoSettings.GetInfoRevision(Data)
				and not TextoSettings.IsBan(Data) then
				Karaokedata:DeleteIdToSongs(Data.Name)
				self.DataStore:DeleteData('KaraokeSongsData', Data.Name)
			else
				Karaokedata:AddedIdToSongs(Data.Name)
			end
			Karaokedata:AddedRecourses(NewData)
			if Karaokedata.SongActive == LocalData then
				Karaokedata.SongActive = NewData
				Karaokedata:Fire("CreateNewSong", NewData, true)
			end
			if typeof(KeyMusica) == "string" then
				self.SentNotification(Player,"Server",`Un admin ha revisado la cancion "{Data.NameSong}".`,5,2022095747,'rotate',8486683243)
				self:ProyectosPendientes(Player)
			end
		else
			Karaokedata:DeleteIdToSongs(Data.Name)
		end
	elseif not count or count < 3 then
		count = (count or 0) + 1
		task.delay(2, self.CallbackDataPlayer, self, UserId, KeyMusica, count)
	end
	
	relase()
end

function module:DetectarBan(texto)
	local comando, argumento = texto:match("^/(%S+)%s*(.*)$")
	return comando == "ban", comando and argumento or texto
end
function module:GetBuzonAdminSong(Staff:Player,versionRevision,MessageWarn,Status)
	if not IsClient and typeof(MessageWarn) == 'string' then
		local ban,text = self:DetectarBan(MessageWarn)
		return {
			Name = versionRevision,
			ReviewerUserId = tostring(Staff.UserId),
			ReviewedAt = tostring(DateTime.now().UnixTimestamp),
			Value = not not Status,
			IsBan = ban,
			Message = text,
		}
	end
end
----//Staff
function module:Desbanear(Staff:Player,KeySound)
	if IsClient then
		self.Events:FindFirstChild('Desbanear'):FireServer(Staff)
	else
		local list = {
			Success = false,
			ErrorMessage = 'Hubo un error.',
		}
		
		if not self.Admins:IsAdmin(Staff, true) then
			if self.Admins:IsAdmin(Staff) then
				list.ErrorMessage = "No role for this action."
				return list
			else
				return self.Admins:IntenteSerAdmin(Staff)
			end
		end
		
		local CacheData = self:GetStorageCache("Ban")[KeySound]
		if not CacheData and Staff then
			list.ErrorMessage = "No existe la data localmente."
			return list
		end
		
		local success,DataCloneImage = self.DataStore:UpdateData('KaraokeSongsData',KeySound,function(LastData)
			if not LastData then
				list.ErrorMessage = 'No pudimos encontrar los datos de la musica.'
				return LastData
			end
			local State = TextoSettings.GetInfoRevision(LastData)
			if State then
				list.ErrorMessage = 'No se puede desbanear una musica que no ha sido baneada.'
				return LastData
			end
			
			local Ban = TextoSettings.IsBan(LastData)
			if not Ban then
				list.ErrorMessage = "La musica ya fue revisada."
				return list
			end
			Ban.UnBan = true
			local BuzonData = TextoSettings.CreateInfoRevision(LastData,"BuzonAdminSong")
			local BuzonToPlayer = self:GetBuzonAdminSong(Staff,HttpService:GenerateGUID(true),self.MessageUnban,true)
			BuzonToPlayer.Moderada = "Unban"
			table.insert(BuzonData.Childs, BuzonToPlayer)
			list.Success = true
			return LastData
		end)
		
		if success then
			if list.Success then
				self:PublishAsync(tostring(DataCloneImage.OwnerSong)..'KaraokeSongsNotification',{
					Parametros = {DataCloneImage.OwnerSong, KeySound},
					KeyFuncion = 'CallbackDataPlayer',
				})
				self:PublishAsync('AdministracionGlobal',{
					Parametros = {KeySound, game.JobId},
					KeyFuncion = 'EliminarKeyDeCache',
				})
				self.DataStore:DeleteData('BaneosRating',KeySound)
				local palabras = TextoSettings.getIndices(TextoSettings.GetTextIndiceSong(DataCloneImage))
				if palabras then
					self.DataStore.PalabrasFunc.GuardarPalabrasClaves(self.DataStore,{
						key = KeySound,
						claves = palabras,
					})
				end
				list.ErrorMessage = "Se ha desbaneado la musica con exito."
			end
			self.DataStore.PalabrasFunc.AddCache(self.DataStore,KeySound, DataCloneImage)
		end
		return list
	end
end

function module:ActionSongDenunce(Staff:Player,KeySound, MessageWarn)
	if IsClient then
		self.Events:FindFirstChild('AccionarDenuncias'):FireServer(Staff, KeySound)
	else
		local list = {
			Success = false,
			ErrorMessage = 'Hubo un error.',
			
			IsReported = false,
			
		}
		
		if typeof(KeySound) ~= 'string' then
			list.ErrorMessage = "Datos erroneos enviados."
			return list
		end
		
		if MessageWarn then
			MessageWarn = TextoSettings.VerificarTexto(MessageWarn, true)
			if not MessageWarn then
				list.ErrorMessage = "No puedes enviar un mensaje vacio."
				return list
			end
		end
		if Staff and not self.Admins:IsAdmin(Staff) then
			return self.Admins:IntenteSerAdmin(Staff)
		end
		
		local CacheData = self:GetStorageCache("Report")[KeySound]
		if not CacheData and Staff then
			list.ErrorMessage = "La musica no tiene reportes disponibes."
			return list
		end
		local success,DataCloneImage = self.DataStore:UpdateData('KaraokeSongsData',KeySound,function(LastData)
			if not LastData then
				list.ErrorMessage = 'No pudimos encontrar los datos de la musica.'
				return LastData
			end
			local State = TextoSettings.GetInfoRevision(LastData)
			if not State or not State.Value then
				list.ErrorMessage = 'La musica está privada.'
				return LastData
			end
			list.OwnerSound = tonumber(State.Owner)
			local Denuncias = TextoSettings.GetInfoRevision(LastData,'Denuncias')
			
			if Denuncias then
				list.IsReported = true
				table.remove(LastData.Childs, table.find(LastData.Childs,Denuncias))
			elseif not MessageWarn or Staff then
				list.ErrorMessage = "La musica ya fue atendida por otro admin."
				return LastData
			end
			
			if MessageWarn then
				table.remove(LastData.Childs, table.find(LastData.Childs,State))
				local BuzonData = TextoSettings.CreateInfoRevision(LastData,"BuzonAdminSong")
				local BuzonToPlayer = self:GetBuzonAdminSong(Staff or {UserId = 1},HttpService:GenerateGUID(true),MessageWarn,false)
				BuzonToPlayer.Moderada = 'Moderada'..(BuzonToPlayer.IsBan and ' & Banned' or '')
				list.IsBanned = BuzonToPlayer.IsBan
				table.insert(BuzonData.Childs, BuzonToPlayer)
			end
			
			list.Success = true
			return LastData
		end)
		if success then
			if list.Success then
				
				if list.IsReported then
					self.DataStore:DeleteData('DenunciasRating',KeySound)
				end
				
				self:PublishAsync(tostring(list.OwnerSound)..'KaraokeSongsNotification',{
					Parametros = {list.OwnerSound, KeySound},
					KeyFuncion = 'CallbackDataPlayer',
				})
				self:PublishAsync('AdministracionGlobal',{
					Parametros = {KeySound, game.JobId},
					KeyFuncion = 'EliminarKeyDeCache',
				})
				
				if MessageWarn then
					self.DataStore:DeleteData('MusicasRating',KeySound)
					
					if list.IsBanned then
						self.DataStore:SetData('BaneosRating',KeySound,DateTime.now().UnixTimestamp)
					end
					
					local palabras = TextoSettings.getIndices(TextoSettings.GetTextIndiceSong(DataCloneImage))
					if palabras then
						self.DataStore.PalabrasFunc.GuardarPalabrasClaves(self.DataStore,{
							key = KeySound,
							claves = palabras,
						})
					end
					
				end
				
				list.ErrorMessage = string.format(
					"Se ha %s %s con exito.",
					MessageWarn and "moderado" or "descartado",
					MessageWarn and "la canción" or "el reporte"
				)
				
			end
			self.DataStore.PalabrasFunc.AddCache(self.DataStore,KeySound, DataCloneImage)
		end
		return list
	end
end

function module:AprovarRechazarMusicaAction(Staff:Player,KeySound,RechazoMessage)
	if IsClient then
		self.Events:FindFirstChild('ApReMusica'):FireServer(Staff,KeySound)
	else
		local list = {
			Success = false,
			ErrorMessage = 'Hubo un error.',
		}
		if not self.Admins:IsAdmin(Staff) then
			return self.Admins:IntenteSerAdmin(Staff)
		end
		if typeof(KeySound) ~= 'string' then
			list.ErrorMessage = "Datos erroneos enviados."
			return list
		end
		local InfoStateLocal = TextoSettings.GetInfoRevision(self:GetStorageCache()[KeySound])
		if not InfoStateLocal then
			list.ErrorMessage = "No data found."
			return list
		end
		local success,DataCloneImage = self.DataStore:UpdateData('KaraokeSongsData',KeySound,function(LastData)
			if not LastData then
				list.ErrorMessage = "No se encontro la data de la musica."
				return
			end
			local InfoState = TextoSettings.GetInfoRevision(LastData)
			if not InfoState or InfoState.KeyRevision ~= InfoStateLocal.KeyRevision then
				list.ErrorMessage = "El estado de la revision no existe o es diferente."
				return LastData
			end
			local BuzonData = TextoSettings.CreateInfoRevision(LastData,"BuzonAdminSong")
			local RevisionBuzon = TextoSettings.GetInfoRevision(BuzonData,InfoState.KeyRevision)
			if RevisionBuzon then
				list.ErrorMessage = "La musica ya ha sido revisada."
				return LastData
			end
			local MessageBuzon = self:GetBuzonAdminSong(Staff,InfoState.KeyRevision,RechazoMessage or self.MessageAproveSong, not RechazoMessage)
			if not MessageBuzon then
				list.ErrorMessage = "Hubo un error al conseguir el check de la revision."
				return LastData
			end
			table.insert(BuzonData.Childs, MessageBuzon)
			if RechazoMessage then
				list.IsBanned = MessageBuzon.IsBan
				table.remove(LastData.Childs, table.find(LastData.Childs, InfoState))
			else
				InfoState.Value = true
			end
			list.Success = true
			return LastData
		end)
		if success then
			if list.Success then
				self.DataStore:DeleteData('RevisionRating',KeySound)
				self:PublishAsync(tostring(InfoStateLocal.Owner)..'KaraokeSongsNotification',{
					Parametros = {tonumber(InfoStateLocal.Owner), KeySound},
					KeyFuncion = 'CallbackDataPlayer',
				})
				self:PublishAsync('AdministracionGlobal',{
					Parametros = {KeySound, game.JobId},
					KeyFuncion = 'EliminarKeyDeCache',
				})

				if not RechazoMessage or list.IsBanned then
					if not RechazoMessage then
						self.DataStore:SetData('MusicasRating',KeySound,0)
						local palabras = TextoSettings.getIndices(TextoSettings.GetTextIndiceSong(DataCloneImage))
						if palabras then
							self.DataStore.PalabrasFunc.GuardarPalabrasClaves(self.DataStore,{
								key = KeySound,
								claves = palabras,
							})
						end
					else
						self.DataStore:SetData('BaneosRating',KeySound,DateTime.now().UnixTimestamp)
					end
					
				end
				list.ErrorMessage = string.format("Se ha %s la canción con exito.", RechazoMessage and "moderado" or "publicado")
			end
			
			self.DataStore.PalabrasFunc.AddCache(self.DataStore,KeySound, DataCloneImage)
		end
		return list
	end
end

--//Back-end administracion

function module:GetCacheLoaded(Data)
	return (not not Data) and (Data.Name == "Denuncias" or Data.IsLoaded) and Data
end

function module:GetDataLoaded(Player)
	if IsClient then return end
	local CacheData = self.DataStore.PalabrasFunc.cache.Success
	local DataEnvio = {}
	for NameSectionClient,NameSection in self.SectionsCacheNames do
		if self.Admins:IsAdmin(Player, NameSection == "Bans") then continue end
		if NameSection == "Reports" then
			DataEnvio[NameSectionClient] = CacheData[NameSection]
		else
			local cloneData = table.clone(CacheData[NameSection])
			for key, data in cloneData do
				cloneData[key] = self:GetCacheLoaded(data)
			end
			DataEnvio[NameSectionClient] = cloneData
		end
	end
	return DataEnvio
end

function module:SentCache(Player,Information)
	if IsClient then return end
	if not Information then
		self.Events:FindFirstChild('ObtenerMusicas'):FireClient(Player,"cache",self:GetDataLoaded(Player))
	elseif typeof(Information) == "string" then
		local TextFormat = string.split(Information, ",")
		if #TextFormat ~= 2 then return end
		local DataSelected = self.DataStore.PalabrasFunc.cache.Success[self.SectionsCacheNames[TextFormat[1]] or ""]
		if not DataSelected or not self.Admins:IsAdmin(Player, TextFormat[1] == "bannCache") then return end
		self.Events:FindFirstChild('ObtenerMusicas'):FireClient(Player,"cache",{
			IsEspecific = true,
			Selected = TextFormat[1],
			Key = TextFormat[2],
			Cache = self:GetCacheLoaded(DataSelected[TextFormat[2]]),
		})
	end
end

function module:ObtenerMusica(Page, Information, StaffRequerest:Player)
	if typeof(Page) == 'number' then
		local Selection = Page == 0 and "AllSongs" or Page == 1 and "AllReported" or Page == 2 and "AllBans"
		if not Selection then return end
		if not IsClient then
			if StaffRequerest then
				if self.Admins:IsAdmin(StaffRequerest, Page == 2) then
					self.Events:FindFirstChild('ObtenerMusicas'):FireClient(StaffRequerest,Page,self.PreloadSongs[Selection])
				else
					self.Admins:IntenteSerAdmin(StaffRequerest)
				end
			elseif Page ~= 2 then
				self.Admins:FireOnlyAdmins(self.Events:FindFirstChild('ObtenerMusicas'),Page,self.PreloadSongs[Selection])
			else
				for _,Admin in self.AdminsActive do
					if self.Admins:IsAdmin(Admin, true) then
						self.Events:FindFirstChild('ObtenerMusicas'):FireClient(Admin,Page,self.PreloadSongs[Selection])
					end
				end
			end
		elseif typeof(Information) == 'table' then
			self.PreloadSongs[Selection] = Information
			self.DataChange:Fire(Selection)
		elseif Information == true then
			self.Events:FindFirstChild('ObtenerMusicas'):FireServer(Page)
		end
	elseif typeof(Page) == 'string' then
		if Page == 'cache' then
			if not IsClient then
				if StaffRequerest then
					if self.Admins:IsAdmin(StaffRequerest) then
						self:SentCache(StaffRequerest, Information)
					else
						self.Admins:IntenteSerAdmin(StaffRequerest)
					end
				else
					for _,Admin in self.AdminsActive do
						self:SentCache(Admin, Information)
					end
				end
			elseif typeof(Information) == 'table' then
				if not Information.IsEspecific then
					for index, value in Information do
						self.PreloadSongs[index] = value
					end
				else
					local lastCache = self.PreloadSongs[Information.Selected][Information.Key]
					self.PreloadSongs[Information.Selected][Information.Key] = Information.Cache
					if lastCache ~= Information.Cache then
						local EventSelected = Information.Cache and self.CacheAdded or self.CacheRemoved
						EventSelected:Fire(Information.Key, Information.Selected)
					end
				end
			elseif Information == true then
				self.Events:FindFirstChild('ObtenerMusicas'):FireServer(Page)
			end
		elseif Page == 'Busqueda' then
			if not IsClient then
				local index = Information or self.PreloadSongs.Separate
				local Cache = Information and self.PreloadSongs.Separate[Information] or nil
				if StaffRequerest then
					if self.Admins:IsAdmin(StaffRequerest) then
						self.Events:FindFirstChild('ObtenerMusicas'):FireClient(StaffRequerest,Page,index,Cache)
					else
						self.Admins:IntenteSerAdmin(StaffRequerest)
					end
				else
					self.Admins:FireOnlyAdmins(self.Events:FindFirstChild('ObtenerMusicas'),Page,index,Cache)
				end
			elseif typeof(Information) == 'table' then
				self.PreloadSongs.Separate = Information
			elseif typeof(Information) == "string" then
				self.PreloadSongs.Separate[Information] = StaffRequerest
				self.BuscadorChanged:Fire(Information)
			elseif Information == true then
				self.Events:FindFirstChild('ObtenerMusicas'):FireServer(Page)
			end
		end
	end
end

function module:GetStorageCache(Reports)
	if IsClient then
		local Direction = Reports=="Report" and "reportCache" or "bannCache"
		return self.PreloadSongs[Reports and Direction or "cache"]
	else
		local Direction = Reports=="Report" and "Reports" or "Bans"
		return self.DataStore.PalabrasFunc.cache.Success[Reports and Direction or "Revision"]
	end
end
function module:IsAviableToUpdate(SuperAdmin)
	if not SuperAdmin or #self.AdminsActive==0 then return #self.AdminsActive > 0 end
	for _,Admin in self.AdminsActive do
		if self.Admins:IsAdmin(Admin, true) then
			return true
		end
	end
end

function module:UpdateMusicas()
	if not IsClient then
		if self:IsAviableToUpdate() then
			if not self.UpdateMusicasUpdate then
				self.UpdateMusicasUpdate = task.spawn(function()
					self:CargarMusicasServer(self.PreloadSongs.AllSongs.LastPage)
					self:CargarMusicaReport(self.PreloadSongs.AllReported.LastPage)
					self:CargarMusicasBaneadas(self.PreloadSongs.AllBans.LastPage)
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
					LastPage = 1,
					ListDatas = {}
				},
				AllReported = {
					IsLimit = true,
					NumberPage = 0,
					LastPage = 1,
					ListDatas = {}
				},
				AllBans = {
					IsLimit = true,
					NumberPage = 0,
					LastPage = 1,
					ListDatas = {}
				},
				Separate = {},
			}
			self:UpdateMusicas()
		end
	end
end

function module:CargarMusicasServer(Page, Player:Player)
	if IsClient then
		self.Events:FindFirstChild('CargarMusicas'):FireServer("CargarMusicasServer",Page)
	elseif #self.AdminsActive > 0 and typeof(Page) == 'number' then
		local Data,NewData = self.DataStore:GetData('RevisionRating',true,self.SongPorPagina,Page)
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
								origin = "RevisionRating",
							})
						end
						self.PreloadSongs.AllSongs.ListDatas[index] = list
					end
				end
			else
				warn("No hay musicas en revision en este momento")
			end
			self:ObtenerMusica(0,nil,Player)
		else
			warn(Data)
		end
	end
end

function module:CargarMusicaReport(Page, Player)
	if IsClient then
		self.Events:FindFirstChild('CargarMusicas'):FireServer("CargarMusicaReport",Page)
	elseif #self.AdminsActive > 0 and typeof(Page) == 'number' then
		local Data,NewData = self.DataStore:GetData('DenunciasRating',true,self.SongPorPagina,Page)
		if Data.Success then
			self.PreloadSongs.AllReported.NumberPage = Data.TotalPages
			self.PreloadSongs.AllReported.IsLimit = Data.IsLimit
			self.PreloadSongs.AllReported.ListDatas = NewData and {} or self.PreloadSongs.AllReported.ListDatas
			self.PreloadSongs.AllReported.LastPage = math.max(Data.TotalPages, 1)
			if Data.TotalPages > 0 then
				for index,info in Data.Pages do
					if not self.PreloadSongs.AllReported.ListDatas[index] then
						local list = {}
						for _,keySong in info do
							local Key = tostring(keySong.key)
							table.insert(list,Key)
							self.DataStore.PalabrasFunc.AddToLoadCache(self.DataStore, {
								clave = Key,
								origin = "DenunciasRating",
								ExtraData = {
									reportes = tonumber(keySong.value),
								},
							})
						end
						self.PreloadSongs.AllReported.ListDatas[index] = list
					end
				end
			else
				warn("No hay musicas con reporte disponible")
			end
			self:ObtenerMusica(1,nil,Player)
		else
			warn(Data)
		end
	end
end

function module:CargarMusicasBaneadas(Page, Player:Player)
	if IsClient then
		self.Events:FindFirstChild('CargarMusicas'):FireServer("CargarMusicasBaneadas",Page)
	elseif  self:IsAviableToUpdate(true) and typeof(Page) == 'number' then
		local Data,NewData = self.DataStore:GetData('BaneosRating',true,self.SongPorPagina,Page)
		if Data.Success then
			self.PreloadSongs.AllBans.NumberPage = Data.TotalPages
			self.PreloadSongs.AllBans.IsLimit = Data.IsLimit
			self.PreloadSongs.AllBans.ListDatas = NewData and {} or self.PreloadSongs.AllBans.ListDatas
			self.PreloadSongs.AllBans.LastPage = math.max(Data.TotalPages, 1)
			if Data.TotalPages > 0 then
				for index,info in Data.Pages do
					if not self.PreloadSongs.AllBans.ListDatas[index] then
						local list = {}
						for _,keySong in info do
							local Key = tostring(keySong.key)
							table.insert(list,Key)
							self.DataStore.PalabrasFunc.AddToLoadCache(self.DataStore, {
								clave = Key,
								origin = "BaneosRating",
							})
						end
						self.PreloadSongs.AllBans.ListDatas[index] = list
					end
				end
				print(self.PreloadSongs.AllBans)
			else
				warn("No hay musicas baneadas en este momento")
			end
			self:ObtenerMusica(2,nil,Player)
		else
			warn(Data)
		end
	end
end

function module:ViewLyric(Player:Player,Key)
	if IsClient then
		self.Events:FindFirstChild('ViewLyric'):FireServer(Player)
	elseif Player and Player:IsDescendantOf(game) and typeof(Key) == 'string' then
		if self.Admins:IsAdmin(Player) then
			local success,Lyric = self.DataStore:GetData('Letras',Key)
			self.Events:FindFirstChild('ViewLyric'):FireClient(Player,success and Lyric)
		else
			self.Admins:IntenteSerAdmin(Player)
		end
	end
end

function module:SuscribeAsync(ClaveSuscribe : string)
	if not IsClient and typeof(ClaveSuscribe) == 'string' and not self.MessagingActives[ClaveSuscribe] then
		task.spawn(function()
			self.MessagingActives[ClaveSuscribe] = self.MessagingService:SubscribeAsync(ClaveSuscribe,function(...) self:ReciveAsync(...) end)
			--print('se ha añadido punto comunicacion global para: '..ClaveSuscribe)
		end)
	end
end
function module:DesuscribeAsync(ClaveSuscribe : string)
	if self.MessagingActives[ClaveSuscribe] then
		self.MessagingActives[ClaveSuscribe]:Disconnect()
		self.MessagingActives[ClaveSuscribe] = nil
		--print('se ha removido punto comunicacion global para: '..ClaveSuscribe)
	end
end
function module:PublishAsync(ClaveSuscribe, InfoData)
	if typeof(ClaveSuscribe) == 'string' and typeof(InfoData) == 'table' and not IsClient then
		task.spawn(function() self.MessagingService:PublishAsync(ClaveSuscribe,InfoData) end)
		--print('Se ha enviado mensaje a: '..ClaveSuscribe)
	end
end
function module:ReciveAsync(InfoData)
	if typeof(InfoData) == 'table' and not IsClient then
		--print('Mensaje recibido pa: ', InfoData)
		local Message = InfoData.Data
		local funcionEsperada = self[Message.KeyFuncion or '']
		if funcionEsperada and typeof(funcionEsperada) == 'function' then
			funcionEsperada(self,table.unpack(Message.Parametros))
		end
	end
end

function module:AdminAdded(Player:Player)
	if not IsClient and Player and Player:IsDescendantOf(game) then
		if not table.find(self.AdminsActive, Player) and self.Admins:IsAdmin(Player) then
			table.insert(self.AdminsActive, Player)
			self:UpdateMusicas()
			self:SuscribeAsync('AdministracionGlobal')
		end
	end
end
function module:AdminRemoved(Player:Player)
	if not IsClient and Player then
		local index = table.find(self.AdminsActive, Player)
		if index then
			table.remove(self.AdminsActive, index)
			if #self.AdminsActive == 0 then
				self:DesuscribeAsync('AdministracionGlobal')
				self:UpdateMusicas()
			end
		end
		
		if not Player.Parent then
			
			self.Admins.RoleService:PlayerRemoving(Player.UserId)
			for index,_ in self.MessagingActives do
				if string.match(index, tostring(Player.UserId)) then self:DesuscribeAsync(index) end
			end
			
		end
		
	end
end

function module:SendMessagePlayer(Player : Player, list)
	if not IsClient and typeof(list) == "table" and Player:IsDescendantOf(game) then
		self.SentNotification(Player,"Karaoke",
			list.ErrorMessage or "No info notification",15,
			2022095747,'rotate',
			8486683243)
	end
end

--//
function module:Works()
	if not IsClient then
		
		self.Events:FindFirstChild('CargarMusicas').OnServerEvent:Connect(function(Staff, TypeBusqueda, Page)
			if TypeBusqueda == "CargarMusicasServer" then
				self:CargarMusicasServer(Page, Staff)
			elseif TypeBusqueda == "CargarMusicaReport" then
				self:CargarMusicaReport(Page, Staff)
			elseif TypeBusqueda == "CargarMusicasBaneadas" then
				self:CargarMusicasBaneadas(Page, Staff)
			elseif self.Admins:IsAdmin(Staff) then
				self:UpdateMusicas()
			end
		end)
		--Desbanear
		self.Events:FindFirstChild('ObtenerMusicas').OnServerEvent:Connect(function(Staff,t,b) self:ObtenerMusica(t,b,Staff) end)
		self.Events:FindFirstChild('ViewLyric').OnServerEvent:Connect(function(...) self:ViewLyric(...) end)
		
		self.Events:FindFirstChild('Desbanear').OnServerEvent:Connect(function(Player,...)
			local list = self:Desbanear(Player, ...)
			self:SendMessagePlayer(Player,list)
			self.Events:FindFirstChild('Desbanear'):FireClient(Player, list)
		end)
		self.Events:FindFirstChild('AccionarDenuncias').OnServerEvent:Connect(function(Player,...)
			local list = self:ActionSongDenunce(Player, ...)
			self:SendMessagePlayer(Player,list)
			self.Events:FindFirstChild('AccionarDenuncias'):FireClient(Player, list)
		end)
		self.Events:FindFirstChild('ApReMusica').OnServerEvent:Connect(function(Player,...)
			local list = self:AprovarRechazarMusicaAction(Player, ...)
			self:SendMessagePlayer(Player,list)
			self.Events:FindFirstChild('ApReMusica'):FireClient(Player, list)
		end)
		self.Events:FindFirstChild('DenunciarMusica').OnServerEvent:Connect(function(Player,...)
			local list = self:Denunciar(Player, ...)
			self:SendMessagePlayer(Player,list)
			self.Events:FindFirstChild('DenunciarMusica'):FireClient(Player, list)
		end)
		self.Events:FindFirstChild('PublishRevisarMusic').OnServerEvent:Connect(function(Player, ...)
			local list = self:PublishRevisarMusic(Player, ...)
			self:SendMessagePlayer(Player,list)
			self.Events:FindFirstChild('PublishRevisarMusic'):FireClient(Player, list)
		end)
		
	else
		local revisarAdmin:RBXScriptConnection
		revisarAdmin = self.Admins.Changed:Connect(function(Key,IsAdmin)
			if Key == 'Administracion' then
				revisarAdmin:Disconnect()
				revisarAdmin = nil
				if IsAdmin then
					self.Events:WaitForChild('ObtenerMusicas').OnClientEvent:Connect(function(...) self:ObtenerMusica(...) end)
					self:ObtenerMusica(0,true)
					self:ObtenerMusica(1,true)
					self:ObtenerMusica(2,true)
					self:ObtenerMusica('cache',true)
					self:ObtenerMusica('Busqueda',true)
				end
			end
		end)
		
		self.Admins:IsAdmin()
	end
end
return module.new()
