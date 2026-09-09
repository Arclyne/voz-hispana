local module = {}

local IsClient = game:GetService('RunService'):IsClient()
local RS = game:GetService('ReplicatedStorage')
local HttpService:HttpService = not IsClient and game:GetService("HttpService") or nil

local TextoSettings = require(RS:WaitForChild("Client"):WaitForChild("BusquedaSettings"))
local EventCustom = require(RS:FindFirstChild("Client"):WaitForChild("Event"))

local Events = RS:WaitForChild('Events'):WaitForChild('Karaoke')

module.__index = module
module.AttributesFuncts = not IsClient and require(script:WaitForChild('Attributes')) or nil

function module.new(Biblioteca:BoolValue)
	local self = setmetatable({
		IsActive = true,
		actives = {},
		TypesList = require(script:WaitForChild('Generos')),
		Owner = Biblioteca.Parent,
		Songs = Biblioteca,
		TextoSettings = TextoSettings,
		
		ColaLoad = not IsClient and {
			Counts = 0,
			MaxLoads = 20,
			TimeExhauste = 60,
		} or nil,
		
		SongActive = false,
		
		SongChange = IsClient and EventCustom.new() or nil,
		
		UsesDataStores = {},
		
	},module)
	
	self:CreateEvent()
	self:Works()
	
	return self
end

function module:CreateNewSong(song,server)
	if IsClient then
		if not server then
			return self:Fire('CreateNewSong',song)
		else
			self.SongActive = song
			self.SongChange:Fire()
		end
	elseif self.SongActive and song==self.SongActive then
		return self:Fire("CreateNewSong",song,true)
	else
		song = typeof(song)=="Instance" and song
		
		self:UpdateLastSong()
		self:ExitEditedLyric()
		
		if song and song.Parent==self.Songs then
			self.SongActive = song
			return self:Fire('CreateNewSong',song,true)
		else
			song = false
			for _,SongPlayer:BoolValue in self.Songs:GetChildren() do
				if SongPlayer:GetAttribute('IsLast') then
					if song then
						SongPlayer:Destroy()
					else
						song = SongPlayer
					end
				end
			end
			if not song then
				song = self.AddItem(HttpService:GenerateGUID(true),false,{
					OwnerSong = self.Owner.UserId,
					IsLast = true,
					IsLyricData = false,
				})
				song.Parent = self.Songs
				self:AddedRecourses(song)
			end
			self.SongActive = song
			return self:Fire('CreateNewSong',song,true)
		end
	end
end

function module:UpdateLastSong()
	if not self.SongActive then return end
	if IsClient then
		return self:Fire('UpdateLastSong')
	else
		local lastSong = (not not self.SongActive) and self.SongActive:GetAttribute("IsLast") and self.SongActive
		if lastSong then
			local Aceptado, requerimientosFaltantes, TotalRequermientos = self.RevisarCanciones:VerifyRequerimientosMusica(lastSong)
			if Aceptado or #requerimientosFaltantes < TotalRequermientos then
				lastSong:SetAttribute("IsLast", nil)
			end
		end
		self:Fire('UpdateLastSong')
	end
end

function module:InvalidEdit(song:BoolValue)
	assert(typeof(song) == "Instance", "Datos erroneos")
	return not not (TextoSettings.GetInfoRevision(song) or TextoSettings.IsBan(song))
end

function module:GetStatesSong(song)
	assert(typeof(song) == "Instance", "Datos erroneos")
	return TextoSettings.GetInfoRevision(song) , TextoSettings.IsBan(song)
end

function module:DesingSongGui(InRevision, IsBanned)
	return {
		State = IsBanned and 'Disabled 🔴' or InRevision and
			(InRevision.Value and 'PÚBLICO 🟢' or 'POR REVISAR 🟡') or 'PRIVADO 🔴',
		ColorText = IsBanned and Color3.fromRGB(138, 0, 0) or InRevision and
			(InRevision.Value and Color3.fromRGB(81, 255, 69) or Color3.fromRGB(255, 255, 0)) or Color3.fromRGB(255, 129, 129),
	}
end

function module:ModificarTimeLine(Data, TimeLength)
	if not Data or #Data <= 0 then return false, false end
	local IsModificado = false
	for index = #Data, 1, -1 do
		local letra = Data[index]
		if letra.EndTime > TimeLength then
			IsModificado = true
			if TimeLength-letra.StartTime >= .1 then
				letra.EndTime = TimeLength
			else
				table.remove(Data, table.find(Data, letra))
				continue
			end
		end
		if letra.Text == "/continue" then
			IsModificado = true
			table.remove(Data, table.find(Data, letra))
		end
	end
	return #Data>0 and Data, IsModificado
end

function module:EditedLyric()
	if not IsClient then
		if not self.SongActive or self.SongActive:FindFirstChild("Lyrics") then return self:Fire('EditedLyric') end
		if self:InvalidEdit(self.SongActive) then return self:Fire('EditedLyric') end
		local Sound:Sound = self.SongActive:FindFirstChild('Recursos'):FindFirstChild('SoundId')
		if not Sound or not Sound.IsLoaded then return self:Fire('EditedLyric') end
		local IsLyricData = self.SongActive:GetAttribute("IsLyricData")
		local Lyric = self.AddItem('Lyrics',false,{
			IsLoaded = not IsLyricData,
			Loading = not not IsLyricData,
			IsChange = false,
		})
		Lyric.Parent = self.SongActive
		if not IsLyricData then return self:Fire('EditedLyric') end
		local relase = self:AddUseDataStore("LoadingLetter")
		local success, Data = self.DataStore:GetData('Letras', self.SongActive.Name)
		if success and Lyric.Parent then
			local DataRevisada,IsModificado = self:ModificarTimeLine(Data, Sound.TimeLength)
			if DataRevisada and #DataRevisada > 0 then
				for _,child in DataRevisada do
					self.AddItem(child.Name, child.Value, child).Parent = Lyric
				end
			end
			Lyric:SetAttribute("IsChange", IsModificado)
			Lyric:SetAttribute("IsLoaded", true)
		elseif Lyric.Parent then
			Lyric:Destroy()
		end
		Lyric:SetAttribute("Loading", false)
		relase()
	end
	return self:Fire('EditedLyric')
end

function module:ExitEditedLyric()
	if IsClient then return end
	local ActionGuardado = self.ExitGuardado
	if ActionGuardado then return ActionGuardado:Wait() end
	local list = {
		Success = false, 
		ErrorMessage = "Hubo un error."
	}
	local SongActive:BoolValue = self.SongActive
	if not SongActive then
		list.ErrorMessage = "No song active"
		return list
	end
	local Lyrics:BoolValue = SongActive:FindFirstChild("Lyrics")
	if not Lyrics then
		list.ErrorMessage = "No hay letra disponible"
		return list
	end
	
	local Sound:Sound = SongActive:FindFirstChild("Recursos")
	Sound = Sound and Sound:FindFirstChild("SoundId")
	
	if Sound and not Sound:IsDescendantOf(game) then
		Sound.Parent = RS
	end
	
	local relase = self:AddUseDataStore("SavingSong")
	
	for _,AttributesRequest in {"CopyPaste", "Loading"} do
		if Lyrics:GetAttribute(AttributesRequest) then
			Lyrics:GetPropertyChangedSignal(AttributesRequest):Wait()
		end
	end
	
	local Data = Sound and Sound.IsLoaded
		and self.DataStore:Values(Lyrics)
	Data = Data and Data.Childs
	
	if Data then
		local modificado
		Data, modificado = self:ModificarTimeLine(Data, Sound.TimeLength)
		if modificado then Lyrics:SetAttribute("IsChange", true) end
	end
	
	if not Lyrics:GetAttribute("IsChange") then
		if Sound and Sound.Parent == RS then
			Sound:Destroy()
		end
		Lyrics:Destroy()
		list.Data = Data
		list.Success = true
		list.ErrorMessage = "No se han hecho cambios"
		relase()
		return list
	end
	
	local bin = Instance.new("BindableEvent")
	self.ExitGuardado = bin.Event
	
	if Data then
		local success,NewDataCache = self.DataStore:SetData('Letras',SongActive.Name, Data)
		list.ErrorDataStore = not success
		list.Success = success
		list.ErrorMessage = success and "Cambios registrados" or NewDataCache
		list.Data = NewDataCache
		if success then SongActive:SetAttribute("IsLyricData",NewDataCache and true) end
	elseif SongActive:GetAttribute("IsLyricData") then
		local success,MessageError = self.DataStore:DeleteData('Letras',SongActive.Name)
		list.ErrorDataStore = not success
		list.Success = success
		list.ErrorMessage = success and "Data eliminada" or MessageError
		if success then SongActive:SetAttribute("IsLyricData",false) end
	else
		list.Success = true
		list.ErrorMessage = "Data limpia."
	end
	
	if Sound and Sound.Parent == RS then
		Sound:Destroy()
	end
	
	Lyrics:Destroy()
	self.ExitGuardado = nil
	bin:Fire(table.clone(list))
	bin:Destroy()
	relase()
	
	return list
end

function module:Edited(Option)
	if self.SongActive and typeof(Option) == 'table' and not IsClient then
		if not self:InvalidEdit(self.SongActive) then
			for index,value in Option do
				local requerest = self.RevisarCanciones.RequerestPublishSong[index]
				if not requerest then continue end
				value = typeof(value)==requerest and value or nil
				if index == 'Genero' then
					self.SongActive:SetAttribute(index,self.AttributesFuncts[index](self,self.SongActive,value))
				else
					self.AttributesFuncts[index](self,self.SongActive,value)
				end
			end
		end
	end
	return self:Fire('Edited',IsClient and Option)
end
function module:ReadBuzon()
	if not self.SongActive then return end
	if IsClient then
		return self:Fire('ReadBuzon')
	else
		local buzon:BoolValue  = self.SongActive:FindFirstChild('BuzonAdminSong')
		if buzon then
			for _,child in buzon:GetChildren() do
				child:SetAttribute('Read', true)
			end
		end
	end
end

function module:Delete(Object)
	Object = Object or self.SongActive
	if IsClient then
		return self:Fire('Delete', Object)
	elseif self.SongActive and Object and
		(Object == self.SongActive or Object:IsDescendantOf(self.SongActive)) then
		
		local InRevision = TextoSettings.GetInfoRevision(self.SongActive)
		if InRevision then return self:Fire('CreateNewSong',self.SongActive,true) end

		if self.SongActive == Object then
			
			local IsBanned = TextoSettings.IsBan(Object)
			local IsdataLetter = Object:GetAttribute("IsLyricData")
			local Key = Object.Name
			
			if not IsBanned and not IsdataLetter then
				self.SongActive = nil
				Object:Destroy()
				return self:Fire('CreateNewSong',nil,true)
			end
			
			local IsAviableCooldown, faltante = TextoSettings.IsAviableCooldown(self.Songs:GetAttribute('CooldownDelete'), 60)
			if not IsAviableCooldown then
				self:Fire("CreateNewSong", self.SongActive, true)
				return self.RevisarCanciones:SendMessagePlayer(self.Owner, {
					Success = false,
					ErrorMessage = string.format("Espera %s para eliminar una nueva cancion.", TextoSettings.FormatTime(faltante)),
				})
			end
			self.Songs:SetAttribute('CooldownDelete', DateTime.now().UnixTimestampMillis)

			self.SongActive = nil	
			Object:Destroy()
			
			local relase = self:AddUseDataStore("RemoverSong")
			
			if IsdataLetter then
				self.DataStore:DeleteData('Letras',Key)
			end
			
			if IsBanned then
				self:DeleteIdToSongs(Key)
				self.RevisarCanciones:PublishAsync('AdministracionGlobal',{
					Parametros = {Key, game.JobId},
					KeyFuncion = 'EliminarKeyDeCache',
				})
				self.DataStore:DeleteData("KaraokeSongsData", Key)
				self.DataStore:DeleteData("BaneosRating", Key)
				local palabras = TextoSettings.getIndices(TextoSettings.GetTextIndiceSong(Object))
				if palabras then
					self.DataStore.PalabrasFunc.GuardarPalabrasClaves(self.DataStore,{
						key = Key,
						claves = palabras,
					})
				end
			end

			relase()
			
			return self:Fire('CreateNewSong',nil,true)
			
		else
			
			local letras = self.SongActive:FindFirstChild("Lyrics")
			if letras and Object:IsDescendantOf(letras) then
				Object:Destroy()
				letras:SetAttribute("IsChange", true)
				self:Edited({UltimaModificacionLyrics = tostring(DateTime.now().UnixTimestamp)})
			end
			
		end
		
	end
end

function module:Cut(Letra:StringValue,Corte:number)
	if IsClient then
		return self:Fire('Cut',Letra,Corte)
	elseif typeof(Letra)=="Instance" and typeof(Corte)=="number" then
		if not self:InvalidEdit(self.SongActive) then
			local LeftStart = Letra:GetAttribute('StartTime') or 0
			local LeftEnd = Corte
			local RightStart = Corte
			local RightEnd = Letra:GetAttribute('EndTime') or 0
			if LeftEnd-LeftStart >= .1 and RightEnd-RightStart >= .1 then
				self:Edited({UltimaModificacionLyrics = tostring(DateTime.now().UnixTimestamp)})
				self:Lyric(Letra,{EndTime = Corte})
				self:Lyric(Corte,{
					EndTime = RightEnd,
					Text = Letra.Value
				})
			end
		end
	end
end

-----------------------------------------------------------//Front end visibilidad letras

function module:SortLyrics(Sorted)
	Sorted = typeof(Sorted)=="table" and Sorted
	if not Sorted then
		local SongActive = self.SongActive
		if not SongActive then return {} end
		Sorted = SongActive:FindFirstChild("Lyrics")
		Sorted = Sorted and Sorted:GetChildren()
	end
	if not Sorted or #Sorted == 0 then return {} end
	local list = {}
	for _,letra:StringValue in Sorted do
		local list2 = typeof(letra) == 'Instance' and letra:GetAttributes() or table.clone(letra)
		list2.letra = letra.Value
		list2.Ending = letra.Value == '/n'
		table.insert(list,list2)
	end
	table.sort(list, function(a,b)
		return a.StartTime < b.StartTime
	end)
	return list
end

function module:GetLyric(Sorted)
	local Lyrics = self:SortLyrics(Sorted)
	local list = {}
	local function GetAllLyric(section)
		if section then
			local letra = ''
			for _,v in section.Lyrics do
				if v.letra ~= '/n' and v.letra ~= '' then
					letra = letra..(#letra > 0 and ' ' or '')..v.letra
				end
			end
			return #letra > 0 and letra or ''
		end
		return ''
	end
	for index,letra in Lyrics do
		local seccionActual = list[#list]
		local letraN = letra.letra == '/n'
		if letraN or not seccionActual then
			if seccionActual then
				seccionActual.EndTime = letra.EndTime
				letra.letra = letraN and GetAllLyric(seccionActual) or letra.letra
				table.insert(seccionActual.Lyrics, letra)
			end
			if index < #Lyrics or #Lyrics == 1 then
				table.insert(list, {
					StartTime = not letraN and letra.StartTime,
					EndTime = not letraN and letra.EndTime,
					Lyrics = {},
				})
			else
				continue
			end
			if seccionActual then
				continue
			end
		end
		seccionActual = list[#list]
		seccionActual.StartTime = (not seccionActual.StartTime or seccionActual.StartTime > letra.StartTime) and letra.StartTime or seccionActual.StartTime
		seccionActual.EndTime = (not seccionActual.EndTime or seccionActual.EndTime < letra.EndTime) and letra.EndTime or seccionActual.EndTime
		letra.letra = letra.letra == '/n' and GetAllLyric(seccionActual) or letra.letra
		table.insert(seccionActual.Lyrics, letra)
	end
	return list
end

-----------------------------------------------------------//editor de letras

function module:Lyric(Letra,Option)
	if IsClient then
	 	return self:Fire('Lyric',Letra,Option)
	elseif self.SongActive  then
		local LetrasValue:BoolValue = self.SongActive:FindFirstChild('Lyrics')
		local Sound:Sound = self.SongActive:FindFirstChild('Recursos'):FindFirstChild('SoundId')
		if not LetrasValue or not Sound or not Sound.IsLoaded then return self:Fire("Lyric") end
		
		if self:InvalidEdit(self.SongActive)  then return self:Fire("Lyric") end
		
		if typeof(Letra) == 'Instance' and Letra.Parent == LetrasValue then
			if typeof(Option) == 'table' then
				local LastLetra = Letra.Value
				Letra.Value = not Option.Value and Letra.Value or TextoSettings.VerificarTexto(Option.Value) or ""
				local LastStartTime = Letra:GetAttribute("StartTime")
				local StartTime = tonumber(Option.StartTime) or LastStartTime
				local LastEndTime = Letra:GetAttribute("EndTime")
				local EndTime = tonumber(Option.EndTime) or LastEndTime
				if LastStartTime ~= StartTime or LastEndTime ~= EndTime then
					if EndTime > StartTime and EndTime-StartTime > .1 then
						local limitaciones = self:GetLetrasCerca((LastStartTime + LastEndTime) / 2, Letra)
						if limitaciones then
							Letra:SetAttribute("StartTime", math.clamp(StartTime, limitaciones.StartTime, LastEndTime - .1))
							Letra:SetAttribute("EndTime", math.clamp(EndTime, LastStartTime + .1, limitaciones.EndTime))
						elseif LastLetra == Letra.Value then
							return
						end
					elseif LastLetra == Letra.Value then
						return
					end
				elseif LastLetra == Letra.Value then
					return
				end
				self:Edited({UltimaModificacionLyrics = tostring(DateTime.now().UnixTimestamp)})
			end
		elseif typeof(Letra) == 'number' then
			Option = typeof(Option) == 'table' and Option or nil
			local limitaciones = self:GetLetrasCerca(Letra)
			if limitaciones then
				limitaciones.Option = limitaciones.Option - math.max(limitaciones.Option + .1 - limitaciones.EndTime,0)
				local list = {
					StartTime = math.clamp(limitaciones.Option,limitaciones.StartTime,limitaciones.EndTime),
				}
				list.EndTime = math.clamp(Option and tonumber(Option.EndTime) or list.StartTime + .5,limitaciones.StartTime+.1,limitaciones.EndTime)
				self.AddItem('Lyrics',TextoSettings.VerificarTexto(Option and Option.Text, true) or '',list).Parent = LetrasValue
				self:Edited({UltimaModificacionLyrics = tostring(DateTime.now().UnixTimestamp)})
			end
		elseif Letra == 'CopyPaste' and typeof(Option) == 'table' then
			if LetrasValue:GetAttribute("CopyPaste") then return self:Fire("Lyric") end
			
			LetrasValue:SetAttribute("CopyPaste", true)
			for index,value in Option do
				if typeof(value) == 'table' then
					self:Lyric(tonumber(value.StartTime), value)
				end
				task.wait()
			end
			LetrasValue:SetAttribute("CopyPaste", nil)
			
			self:Fire("Lyric")
			
		elseif Letra == 'MoveAllLyricts' and typeof(Option) == 'number' then
			
			local len = self:GetLenLyric(LetrasValue, Sound)
			if not len then
				return self:Fire("Lyric")
			end
			local Diference = Option - len.Position
			local MinDifference = -len.StartTime
			local MaxDifference = Sound.TimeLength - len.EndTime
			Diference = math.clamp(
				Diference,
				MinDifference,
				MaxDifference
			)
			if Diference == 0 then
				return self:Fire("Lyric")
			end
			for _,letraData in LetrasValue:GetChildren() do
				letraData:SetAttribute("StartTime", letraData:GetAttribute("StartTime") + Diference)
				letraData:SetAttribute("EndTime", letraData:GetAttribute("EndTime") + Diference)
			end
			self:Fire("Lyric")
			
		elseif Letra == "clear" then
			local Childs = LetrasValue:GetChildren()
			if #Childs <= 0 then return self:Fire("Lyric") end
			LetrasValue:ClearAllChildren()
			self:Edited({UltimaModificacionLyrics = tostring(DateTime.now().UnixTimestamp)})
			self:Fire("Lyric")
		end
	end
end

function module:GetNewStartTime(Lyric, TimePosition)
	local StartTime = Lyric:GetAttribute('StartTime')
	local EndTime = Lyric:GetAttribute("EndTime")
	if TimePosition >= StartTime and TimePosition <= EndTime then
		if math.abs(TimePosition-StartTime) < math.abs(TimePosition-EndTime) then
			return StartTime
		end
		return EndTime
	end
	return TimePosition
end

function module:GetLenLyric(LetrasValue, Sound:Sound)
	local IsTable = typeof(LetrasValue) == "table"
	if not Sound or not Sound.IsLoaded or (IsTable and #LetrasValue==0)
		or (not IsTable and #LetrasValue:GetChildren()==0) then return end
	local list = {
		StartTime = Sound.TimeLength,
		EndTime = 0,
	}
	for _,value in IsTable and LetrasValue or LetrasValue:GetChildren() do
		local StartTime = not IsTable and value:GetAttribute("StartTime") or value.StartTime
		local EndTime = not IsTable and value:GetAttribute("EndTime") or value.EndTime
		list.StartTime = StartTime<list.StartTime and StartTime or list.StartTime
		list.EndTime = EndTime>list.EndTime and EndTime or list.EndTime
	end
	return list.EndTime>list.StartTime and list.StartTime>=0
		and list.EndTime<=Sound.TimeLength and {
			Size = list.EndTime - list.StartTime,
			Position = (list.StartTime + list.EndTime) / 2,
			StartTime = list.StartTime,
			EndTime = list.EndTime,
	}
end

function module:GetLetrasCerca(TimePosition, Exclude)
	local SoundId = typeof(TimePosition) == "number"
		and self.SongActive
		and self.SongActive:FindFirstChild("Recursos")
		and self.SongActive.Recursos:FindFirstChild("SoundId")

	if not SoundId or not SoundId.IsLoaded then
		return
	end

	local Lyrics = self.SongActive:FindFirstChild("Lyrics")
	if not Lyrics then
		return
	end

	local StartTime = 0
	local EndTime = SoundId.TimeLength

	for _, Lyric: StringValue in Lyrics:GetChildren() do
		if Lyric == Exclude then
			continue
		end

		local NewTime = self:GetNewStartTime(Lyric, TimePosition)

		if NewTime ~= TimePosition then
			return self:GetLetrasCerca(NewTime, Exclude)
		end

		local LyricStart = Lyric:GetAttribute("StartTime")
		local LyricEnd = Lyric:GetAttribute("EndTime")

		if LyricEnd <= TimePosition then
			if LyricEnd > StartTime then
				StartTime = LyricEnd
			end
		elseif LyricStart >= TimePosition then
			if LyricStart < EndTime then
				EndTime = LyricStart
			end
		end
	end

	if EndTime > StartTime and EndTime - StartTime >= 0.1 then
		return {
			StartTime = StartTime,
			EndTime = EndTime,
			Option = TimePosition,
		}
	end
end

-----------------------------------------------------------

function module:Fire(NameType,...)
	if IsClient then
		self.Event:FireServer(NameType,...)
	elseif self.Owner and self.Owner:IsDescendantOf(game) then
		self.Event:FireClient(self.Owner,NameType,...)
	end
	return NameType
end

function module:CreateEvent()
	local Event:RemoteEvent
	
	if IsClient then
		Event = Events:WaitForChild(tostring(self.Owner.UserId))
	else
		Event = Instance.new('RemoteEvent')
		Event.Name = tostring(self.Owner.UserId)
		Event.Parent = Events
	end
	
	self.Event = Event
	self.Changed = IsClient and Event.OnClientEvent or Event.OnServerEvent
end

function module:AddUseDataStore(Key)
	assert(typeof(Key) == "string", "only string")
	assert(not IsClient, "only server")
	self.UsesDataStores[Key] = (self.UsesDataStores[Key] or 0) + 1
	self.Songs:SetAttribute(Key, "DataStore")
	local IsClose = false
	return function()
		if IsClose then return end
		IsClose = true
		self:RemoveUseDataStore(Key)
	end
end
function module:RemoveUseDataStore(Key)
	assert(typeof(Key) == "string", "only string")
	assert(not IsClient, "only server")
	if not self.UsesDataStores[Key] then return end
	local Count = self.UsesDataStores[Key] - 1
	self.Songs:SetAttribute(Key, Count>0 and "DataStore" or nil)
	self.UsesDataStores[Key] = Count>0 and Count or nil
end
function module:HoldToClose()
	assert(not IsClient, "only server")
	if self.IsActive or self.IsHoldToCloseUse then return end
	self.IsHoldToCloseUse = true
	print(self:ExitEditedLyric())
	self:SaveSongsClose()
	for index in self.UsesDataStores do
		if self.Songs:GetAttribute(index) then
			self.Songs:GetAttributeChangedSignal(index):Wait()
		end
	end
	return true
end
function module:IsDataStoreChange()
	if IsClient then
		for _,_ in self.UsesDataStores do
			return true
		end
	else
		for _,value in self.Songs:GetAttributes() do
			if value == "DataStore" then return true end
		end
	end
end

function module:SaveSongsClose()
	assert(not IsClient, "only server")
	if self.IsActive or self.SongsSaveInProcess then return end
	self.SongsSaveInProcess = true
	local ids = self:GetIds()
	local InstancesDeletes = {"Recursos", "Lyrics"}
	local OnlyLast = false
	for _,Song:BoolValue in self.Songs:GetChildren() do
		if ids and table.find(ids, Song.Value) then
			Song:Destroy()
			continue
		end
		for _,v in InstancesDeletes do
			local object = Song:FindFirstChild(v)
			if object then object:Destroy() end
		end
		if not Song:GetAttribute("IsLast") then continue end
		local Aceptado, requerimientosFaltantes, TotalRequermientos = self.RevisarCanciones:VerifyRequerimientosMusica(Song)
		if Aceptado or #requerimientosFaltantes < TotalRequermientos then
			Song:SetAttribute("IsLast", nil)
		elseif not OnlyLast then
			OnlyLast = true
		else
			Song:Destroy()
		end
	end
end

function module:Exit()
	if not self.IsActive or IsClient then return end
	self.IsActive = false

	for _,v:RBXScriptConnection in self.actives do v:Disconnect() end
	if self.Loading then task.cancel(self.Loading) end

	self:HoldToClose()

	self.Event:Destroy()
end

function module:AddedRecourses(SongPlayer)
	if IsClient or not SongPlayer or SongPlayer.Parent ~= self.Songs then return end
	local insta = SongPlayer:FindFirstChild("Recursos")
	if not insta then
		insta = Instance.new('Folder')
		insta.Name = 'Recursos'
		insta.Parent = SongPlayer
	end
	task.spawn(function()
		for index,Value in SongPlayer:GetAttributes() do
			if not self.RevisarCanciones.RequerestPublishSong[index] then continue end
			self.AttributesFuncts[index](self,SongPlayer,Value)
		end
	end)
end

function module:GetIds()
	return #self.Songs.Value>0 and string.split(self.Songs.Value, ",")
end
function module:DeleteIdToSongs(id)
	if IsClient or not self.IsActive or not id then return end
	local ids = self:GetIds()
	local index = ids and table.find(ids, id)
	if index then
		table.remove(ids, index)
		self.Songs.Value = table.concat(ids,",")
	end
end
function module:AddedIdToSongs(id)
	if IsClient or not self.IsActive or not id then return end
	local ids = self:GetIds() or {}
	if not table.find(ids, id) then
		table.insert(ids, id)
		self.Songs.Value = table.concat(ids,",")
	end
end
function module:IsIdInSounds(id)
	if IsClient or not self.IsActive or not id then return end
	local ids = self:GetIds()
	return ids and table.find(ids, id)
end

function module:LoadMusics()
	if IsClient or not self.IsActive or self.Loading then return end
	local ids = self:GetIds()
	if not ids then return end
	self.Loading = task.spawn(function()
		local function siguiente(number)
			local Id = ids[number]
			if not Id or not self.IsActive then return end
			if self.Songs:FindFirstChild(Id) then
				siguiente(number + 1)
			else
				local success, Data = self.DataStore:GetData('KaraokeSongsData', Id)
				local TimeHold = (self.ColaLoad.TimeExhauste/self.ColaLoad.MaxLoads) * (not success and 2 or 1)
				if success then
					self.ColaLoad.Counts += 1
					if Data then
						self.RevisarCanciones:CallbackDataPlayer(self.Owner.UserId, Data)
					else
						self:DeleteIdToSongs(Id)
					end
					siguiente(task.wait(TimeHold) and (number + 1))
				else
					siguiente(task.wait(TimeHold) and number)
				end
			end
		end
		siguiente(1)
		self.RevisarCanciones:ProyectosPendientes(self.Owner)
		self.Loading = nil
	end)
end

function module:Works()
	table.insert(self.actives,self.Changed:Connect(function(Player:Player,Key:string,...)
		if self:IsDataStoreChange() then return not IsClient and self:Fire("Error") end
		if IsClient then
			if Player == 'CreateNewSong' then
				self:CreateNewSong(Key,...)
			end
		elseif Player == self.Owner then
			if Key == 'CreateNewSong' then
				self:CreateNewSong(...)
			elseif Key == 'Edited' then
				self:Edited(...)
			elseif Key == 'Delete' then
				self:Delete(...)
			elseif Key == 'Lyric' then
				self:Lyric(...)
			elseif Key == 'Cut' then
				self:Cut(...)
			elseif Key == 'EditedLyric' then
				self:EditedLyric()
			elseif  Key == 'ReadBuzon' then
				self:ReadBuzon()
			elseif  Key == 'UpdateLastSong' then
				self:UpdateLastSong()
			end
		end
	end))
	if not IsClient then
		self:LoadMusics()
		for _,SongPlayer:BoolValue in self.Songs:GetChildren() do self:AddedRecourses(SongPlayer) end
	end
end

return module
