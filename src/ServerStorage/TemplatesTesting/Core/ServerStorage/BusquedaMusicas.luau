local module = {}

local RS = game:GetService("ReplicatedStorage")
local TextoSettings = require(RS:WaitForChild("Client"):WaitForChild("BusquedaSettings"))
local InsertService = require(RS:WaitForChild("Client"):WaitForChild("InsertService"))
module.UpdateWating = 60 * 2
module.HoltToClean = 60 * 10

module.Guardado = {
	PalabrasGuardadas = 0,
	MaxLoads = 15,
	TimeExhauste = 60,
	Cola = {},
	Secciones = {'Revision','Publicas'},--No cambiar de indices
}

module.cache = {
	Counts = 0,
	MaxLoads = 40,
	TimeExhauste = 60,
	Cola = {},
	
	Success = {
		
		Publicas = {},
		Revision = {},
		Reports = {},
		Bans = {},
		
	},
}

module.Verificaciones = {}
module.KeyUpdating = {}

function module:ClearCache()
	for Palabra, DataCache in self.DataPalabras.Success do
		if self:ElapsedTime(DataCache.StartBusqueda) < module.HoltToClean then continue end
		if DataCache.Data then
			for index,state in DataCache.Data do
				local Selection = self.SolicitacionesKey[index]
				Selection.PreloadSongs.Separate[Palabra] = nil
				Selection:ObtenerMusica("Busqueda", Palabra)
			end
		end
		self.DataPalabras.Success[Palabra] = nil
	end
	for key, date in module.KeyUpdating do
		if self:ElapsedTime(date) < module.HoltToClean then continue end
		module.RemoveCache(self, key)
	end
end

function module:IsAviableToUpdate(Key)
	local DataSong = module.KeyUpdating[Key]
	return not DataSong or self:ElapsedTime(DataSong) >= module.UpdateWating
end

function module:GetAdminData(Data)
	local InfoData = TextoSettings.RemoveInfoRevision(Data, "Denuncias")
	if not InfoData then return end
	module.Sort(self, InfoData.Childs, "DateDenuncia")
	return InfoData
end
function module:GetFechaUpdate(Data, State)
	local InfoData = TextoSettings.GetInfoRevision(Data, "BuzonAdminSong")
	if InfoData then
		module.Sort(self, InfoData.Childs, "ReviewedAt")
	end
	local RevisionFecha = State.Name~="State" and State
		or InfoData and TextoSettings.GetInfoRevision(InfoData, State.KeyRevision)
	return RevisionFecha and RevisionFecha.ReviewedAt or State.RevisionEnviada
end
function module:Sort(Childs, NameAttribute, ascend)
	table.sort(Childs, function(a,b)
		local TimeA = tonumber(a[NameAttribute]) or 0
		local TimeB = tonumber(b[NameAttribute]) or 0
		return TimeA > TimeB
	end)
end
function module:GetCache(Key)
	local Success = module.cache.Success
	for _,section in {"Publicas", "Revision", "Bans"} do
		local DataSong = module.cache.Success[section][Key]
		if DataSong then
			return DataSong, self.SolicitacionesKey[section=="Bans" and "Revision" or section]
		end
	end
end

function module:AddCache(Key, Data)
	if not Data then return module.RemoveCache(self, Key) end
	module.cache.Counts += 1
	module.KeyUpdating[Key] = DateTime.now().UnixTimestampMillis
	
	local State = TextoSettings.GetInfoRevision(Data, "State")
	local IsBan = TextoSettings.IsBan(Data)
	
	if State or IsBan then
		local Success = module.cache.Success
		
		local NameSection = State and State.Value and "Publicas" or "Revision"
		local NewSection = self.SolicitacionesKey[NameSection]
		
		local LastData, LastSection = module.GetCache(self, Key)
		if LastSection and (NewSection ~= LastSection or LastData.IsBan ~= not not IsBan) then
			LastSection:GetStorageCache(LastData.IsBan and "Bans")[Key] = nil
			LastSection:ObtenerMusica('cache',LastSection:IsA("PublicSong") and Key or string.format("%s,%s",LastData.IsBan and "bannCache" or "cache",Key))
		end
		
		Success[State and NameSection or "Bans"][Key] = Data
		Data.IsBan = not not IsBan
		Data.PublicacionUpdate = tonumber(module.GetFechaUpdate(self, Data, State or IsBan))
		
		local lastCache = Success.Reports[Key]
		local NewCache = State and State.Value and module.GetAdminData(self, Data) or nil
		if lastCache ~= NewCache then
			Success.Reports[Key] = NewCache
			self.SolicitacionesKey.Revision:ObtenerMusica('cache',string.format("reportCache,%s",Key))
		end
		
		InsertService.SetAsset(Key.."Server",tonumber(Data.Miniatura),function(decal)
			Data.Miniatura = decal and decal.Texture or "rbxassetid://72930319548949"
			Data.IsLoaded = true
			NewSection:ObtenerMusica('cache',NewSection:IsA("PublicSong") and Key or string.format("%s,%s",IsBan and "bannCache" or "cache",Key))
		end, "Decal")
		
	else
		module.RemoveCache(self, Key)
	end
	print(module.cache.Counts .. " datos procesados por AddCache.")
end
function module:RemoveCache(Key)
	local Success = module.cache.Success
	if Success.Reports[Key] then
		Success.Reports[Key] = nil
		self.SolicitacionesKey["Revision"]:ObtenerMusica('cache',string.format("reportCache,%s",Key))
	end
	if Success.Bans[Key] then
		Success.Bans[Key] = nil
		self.SolicitacionesKey["Revision"]:ObtenerMusica('cache',string.format("bannCache,%s",Key))
	end
	if Success.Revision[Key] then
		Success.Revision[Key] = nil
		self.SolicitacionesKey["Revision"]:ObtenerMusica('cache',string.format("cache,%s",Key))
	end
	if Success.Publicas[Key] then
		Success.Publicas[Key] = nil
		self.SolicitacionesKey["Publicas"]:ObtenerMusica('cache',Key)
	end
	for _,v in module.cache.Cola do
		if v.clave == Key then
			if not v.InProcess then
				table.remove(module.cache.Cola, table.find(module.cache.Cola, v))
			end
			break
		end
	end
	module.KeyUpdating[Key] = nil
end

function module:AddToLoadCache(Key, forceCLose)
	if typeof(Key) == 'table' and typeof(Key.clave) == 'string' then
		if module.IsAviableToUpdate(self,Key.clave) then
			local InCole = false
			for _,v in module.cache.Cola do
				if v.clave == Key.clave then
					v.prioridad = Key.prioridad
					if typeof(Key.ExtraData) == "table" then
						if v.ExtraData then
							for index, value in Key.ExtraData do
								v.ExtraData[index] = value
							end
						else
							v.ExtraData = Key.ExtraData
						end
					end
					InCole = true
					break
				end
			end
			if not InCole then
				table.insert(module.cache.Cola,Key)
			end
		elseif typeof(Key.ExtraData) == "table" then
			local DataSong, section = module.GetCache(self, Key.clave)
			if DataSong then
				local IsChange = false
				for index, value in Key.ExtraData do
					if DataSong[index] ~= value then
						IsChange = true
						DataSong[index] = value
					end
				end
				if IsChange then
					section:ObtenerMusica('cache',section:IsA("PublicSong") and Key.clave or string.format("cache,%s",Key.clave))
				end
			end
		end
	end
	
	table.sort(module.cache.Cola,function(a,b) return (a.prioridad or 3) < (b.prioridad or 3) end)
	
	if not forceCLose and #module.cache.Cola > 0 and not module.cache.spawnAction then
		module.cache.spawnAction = task.spawn(function()
			local selection = module.cache.Cola[1]
			if selection then
				warn("Origin busqueda: ",selection.clave, selection.origin or "Desconocido")
				selection.InProcess = true
				local Success, Data = self:GetData("KaraokeSongsData", selection.clave)
				if Success then
					if Data then
						if Data.Testeooo then
							local State = TextoSettings.GetInfoRevision(Data, "State")
							if State then
								State.Value = selection.origin=="MusicasRating"
							end
						end
						if typeof(selection.ExtraData) == "table" then
							for index, value in selection.ExtraData do
								Data[index] = value
							end
						end
						module.AddCache(self, selection.clave, Data)
					else
						module.RemoveCache(self, selection.clave)
					end
					table.remove(module.cache.Cola,table.find(module.cache.Cola,selection))
				end
				task.wait(module.cache.TimeExhauste/module.cache.MaxLoads * (not Success and 2 or 1))
			end
			module.cache.spawnAction = nil
			module.AddToLoadCache(self)
		end)
	elseif (#module.cache.Cola == 0 or forceCLose) and module.cache.spawnAction then
		task.cancel(module.cache.spawnAction)
		module.cache.spawnAction = nil
	end
end

function module:SearchPalabrasClaves(Palabra, Section)
	if typeof(Palabra) == 'string' then Palabra = {Palabra} end
	if typeof(Palabra) == 'table' and #Palabra > 0 then
		for _,busqueda in Palabra do
			if typeof(busqueda) ~= 'string' then continue end
			local InCola = table.find(self.DataPalabras.Cache,busqueda)
			if not InCola then
				local DataPalabraSuccess = self.DataPalabras.Success[busqueda]
				if not DataPalabraSuccess or self:ElapsedTime(DataPalabraSuccess.StartBusqueda) >= self.DataPalabras.UpdateSuccess then
					table.insert(self.DataPalabras.Cache,busqueda)
				elseif Section and DataPalabraSuccess and DataPalabraSuccess.Data and DataPalabraSuccess.Data[Section] then
					local sectionSelected = self.SolicitacionesKey[Section]
					if sectionSelected:IsAviableToUpdate() then
						for _, keyLoaded in DataPalabraSuccess.Data[Section] do
							module.AddToLoadCache(self, {
								clave = keyLoaded,
								prioridad = 1,
							})
						end
					end
				end
			end
		end
	end
	if #self.DataPalabras.Cache > 0 and not self.DataPalabras.SpawnFunct then
		table.sort(self.DataPalabras.Cache,function(a,b) return #a < #b end)
		self.DataPalabras.SpawnFunct = task.spawn(function()
			local selectt = self.DataPalabras.Cache[1]
			if selectt then
				local success, Data = self:GetData('OrderNombre', selectt)
				table.remove(self.DataPalabras.Cache, table.find(self.DataPalabras.Cache, selectt))
				local List = {
					StartBusqueda = DateTime.now().UnixTimestampMillis,
					Data = success and Data,
				}
				self.DataPalabras.Success[selectt] = List
				if List.Data then
					for index,state in Data do
						local Selection = self.SolicitacionesKey[index]
						if not Selection:IsAviableToUpdate() then continue end
						
						for _,keyLoaded in state do
							module.AddToLoadCache(self, {
								clave = keyLoaded,
								prioridad = index == Section and 1 or 2,
								origin = "OrderNombre",
							})
						end
						Selection.PreloadSongs.Separate[selectt] = state
						Selection:ObtenerMusica("Busqueda", selectt)
					end
					self.DataPalabras.PalabrasBuscadas += 1
				end
				task.wait(self.DataPalabras.MaxLoads / self.DataPalabras.TimeExhauste)
			end
			self.DataPalabras.SpawnFunct = nil
			module.SearchPalabrasClaves(self)
		end)
	elseif #self.DataPalabras.Cache == 0 and self.DataPalabras.SpawnFunct then
		task.cancel(self.DataPalabras.SpawnFunct)
		self.DataPalabras.SpawnFunct = nil
	end
end

function module:GuardarPalabrasClaves(DataSave)
	
	if typeof(DataSave) == 'table' and typeof(DataSave.key) == 'string' and typeof(DataSave.claves) == 'table' then
		for _,PalabraBuscar in DataSave.claves do
			if typeof(PalabraBuscar) ~= 'string' then continue end
			local NoHayCola = true
			for _,Cola in module.Guardado.Cola do
				if Cola.Palabra == PalabraBuscar then
					NoHayCola = false
					if not table.find(Cola.keys,DataSave.key) then
						table.insert(Cola.keys,DataSave.key)
					end
					break
				end
			end
			if NoHayCola then
				local list = {
					keys = {DataSave.key},
					Palabra = PalabraBuscar,
				}
				table.insert(module.Guardado.Cola, list)
			end
		end
	end
	
	if #module.Guardado.Cola > 0 and not module.Guardado.taskGuardado then
		module.Guardado.taskGuardado = task.spawn(function()
			local EsperarNext = 0
			local selectt = module.Guardado.Cola[1]
			if selectt then
				if #selectt.keys > 0 then
					local KeySelect = selectt.keys[1]
					if KeySelect then
						local Section
						local sucess,data = self:GetData('KaraokeSongsData',KeySelect)
						if sucess then
							if data then
								local State = TextoSettings.GetInfoRevision(data)
								if State then
									Section = State.Value and "Publicas" or "Revision"
								else
									Section = TextoSettings.IsBan(data) and "Revision"
								end
							else
								Section = false
							end
						end
						EsperarNext = (module.Guardado.TimeExhauste/module.Guardado.MaxLoads) * (sucess and 1 or 2)
						if Section ~= nil then
							sucess,data = self:UpdateData('OrderNombre',selectt.Palabra,function(LastData)
								local clone = LastData or {}
								for _,v in module.Guardado.Secciones do
									clone[v] = clone[v] or {}
									local index = table.find(clone[v], KeySelect)
									if Section == v and not index then
										print(`guardando la musica {KeySelect} en la seccion {Section} con la palabra: {selectt.Palabra}`)
										table.insert(clone[v],KeySelect)
									elseif Section ~= v and index then
										table.remove(clone[v],index)
									end
								end
								return clone
							end)
							if not sucess then
								EsperarNext = (module.Guardado.TimeExhauste/module.Guardado.MaxLoads) * 2
							else
								local index = table.find(selectt.keys, KeySelect)
								if index then
									table.remove(selectt.keys, index)
								end
							end
						end
						
					end
				else
					table.remove(module.Guardado.Cola, table.find(module.Guardado.Cola,selectt))
					if selectt.IsRecuperado then
						local sucess,ErrorMessage = self:UpdateData('SalvarOrderNombre','AllData',function(LastData)
							if not LastData then return end
							for _,Cola in LastData do
								if Cola.Palabra == selectt.Palabra then
									table.remove(LastData, table.find(LastData, Cola))
									break
								end
							end
							return LastData
						end)
						if not sucess then
							warn(ErrorMessage)
						end
					end
				end
			end
			task.wait(EsperarNext)
			module.Guardado.taskGuardado = nil
			module.GuardarPalabrasClaves(self)
		end)
	elseif #module.Guardado.Cola == 0 and module.Guardado.taskGuardado then
		task.cancel(module.Guardado.taskGuardado)
		module.Guardado.taskGuardado = nil
	end
end

function module:SalvarPalabrasClave()
	local sucess,data = self:GetData('SalvarOrderNombre','AllData')
	if sucess and data and #data > 0 then
		print("recuperando letras no guardadas: ", data)
		for _,v in data do
			table.insert(module.Guardado.Cola,v)
		end
		module.GuardarPalabrasClaves(self)
	elseif not sucess then
		warn(data)
	end
end

function module:RecuperarPalabrasClave()
	if #module.Guardado.Cola > 0 then
		local clone = table.clone(module.Guardado.Cola)
		module.Guardado.Cola = {}
		module.GuardarPalabrasClaves(self)
		local sucess,data = self:UpdateData('SalvarOrderNombre','AllData',function(LastData)
			local cloneNewData = LastData or {}
			for _,DataSave in clone do
				if DataSave.IsRecuperado then continue end
				local NoHayCola = true
				for _,Cola in cloneNewData do
					if Cola.Palabra == DataSave.Palabra then
						NoHayCola = false
						for _,key in DataSave.keys do
							if not table.find(Cola.keys,key) then
								table.insert(Cola.keys,key)
							end
						end
						break
					end
				end
				if NoHayCola then
					local cloneDataSave = table.clone(DataSave)
					cloneDataSave.IsRecuperado = true
					table.insert(cloneNewData, cloneDataSave)
				end
			end
			
			print("guardando palabras no guardadas: ", clone)
			return cloneNewData
		end)
	end
end

return module
