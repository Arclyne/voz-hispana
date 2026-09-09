local module = {}
module.__index = module

local GlobalDataStoreFake = require(script:WaitForChild("Testeo_GlobalDataStore"))
local IsStudio = game:GetService("RunService"):IsStudio()

local DatasTesteo = {"KaraokeSongsData", "MusicasRating", "RevisionRating"}

local VersionData = 1

function module.new()
	local self = setmetatable({
		
		DataStoreService = game:GetService('DataStoreService'),--//Servicio de base de datos
		PalabrasFunc = require(script.Parent:WaitForChild('BusquedaMusicas')),
		
		Keys = {
			GetDataStore = {
				Letras = 'DataLetrasPlayers',--//Enfocado unicamente en las letras de las musicas [abarca a las musicas Jugador, En revision y Publicas]
				OrderNombre = 'OrderPalabrasDataBase',--//Enfocado en el sistema de busqueda de musicas

				RevisionData = 'DataRevisionSongs',--//Enfocado en las musicas en estado de revision
				PublicSongsData = 'DataSongsPublic',--//Enfocado en las musicas publicas
				
				KaraokeSongsData = "DataSongKaraoke",
				
				SalvarOrderNombre = 'OrderPalabrasInProcess',
				--SalvarElimines = 'ElimacionesDataInProcess_1',
				
				DataPinturas = "DataPinturasPlayers",--//Enfocado en guardar los datos de las pinturas creadas por los jugadores
			},
			GlobalDataStore = {
				MusicasRating = 'RatingSongs',--//Esto será para ordenar las musicas publicas
				RevisionRating = 'RatingRevision',--//Esto será para ordenar las musicas en estado de revision
				DenunciasRating = 'RatingDenuncias',--//para la lista de canciones denunciadas
				BaneosRating = "RatingBaneos",
				
				TopSellers = "RatingSellers",--//para los jugadores que mas venden
				TopBuyers = "RatingBuyers",--//para los jugadores que mas compran				
			}
		},
		
		DataPalabras = {
			PalabrasBuscadas = 0,
			MaxLoads = 20,
			TimeExhauste = 60,
			UpdateSuccess = 60*2,
			Cache = {},--Ejemplo : "Pepito", "Chencho", "Ni idea"
			Success = {},--Ejemplo : ["Juanito"] = DateTime.now()
		},--//Esto lo ocuparé para Guardar las busqueda de musicas, está aqui porque de aqui es facil acceder desde el comando de admins y de los jugadores
		
		AsyncInProcess = {--//Procesos activos de cualquier funcion del DataStore [Util para no hacer un doble guardado]
			Set = {},
			Update = {},
			Get = {},
			Delete = {},
		},
		
		TimeUpdateGlobalData = 60,--//El tiempo requerico para volver a actualizar un GlobalData
		
	}, module)
	
	return self
end

function module:ElapsedTime(number)
	local t = DateTime.now().UnixTimestampMillis
	number = tonumber(number) or t
	return (t - number) / 1000
end

function module:SetSections()
	local KeyVersion = string.format("_Version_%d", VersionData)
	for index,tableTypes in self.Keys do
		for Typeee,KeyRaure in tableTypes do
			if index == 'GetDataStore' then
				if typeof(KeyRaure) == 'string' then
					tableTypes[Typeee] = self.DataStoreService:GetDataStore(KeyRaure..KeyVersion)
				elseif typeof(KeyRaure) == 'Instance' and KeyRaure:IsA('DataStore') then
					continue
				else
					tableTypes[Typeee] = nil
				end
			elseif index == 'GlobalDataStore' and typeof(KeyRaure) == 'string' then
				tableTypes[Typeee] = self.DataStoreService:GetOrderedDataStore(KeyRaure..KeyVersion)
			else
				tableTypes[Typeee] = nil
			end
		end
	end
end

function module:GetSection(Typeee)
	for index,tableTypes in self.Keys do
		for Typeee2,KeyRaure in tableTypes do
			if Typeee == Typeee2 then
				if typeof(KeyRaure) == "string" then return end
				return index, KeyRaure --IsStudio and table.find(DatasTesteo, Typeee) and GlobalDataStoreFake or KeyRaure
			end
		end
	end
end

function module:GetData(NameType, key, pageSize, page)
	local index,section = self:GetSection(NameType)
	if index and section then
		if index == 'GetDataStore' and typeof(key) == 'string' then
			local ProcessKey = NameType .. ":" .. key
			local process = self.AsyncInProcess.Get[ProcessKey]
			if not process then
				local bin = Instance.new("BindableEvent")
				self.AsyncInProcess.Get[ProcessKey] = bin.Event
				local sending = typeof(section)=="table" and index or section
				local n,s = pcall(section.GetAsync,sending,key)
				self.AsyncInProcess.Get[ProcessKey] = nil
				bin:Fire(n,s)
				bin:Destroy()
				return n,s
			else
				local n,s = process:Wait()
				return n, n and (typeof(s)=="table" and table.clone(s) or s)
			end
		elseif index == 'GlobalDataStore' then
			page = math.max(math.floor(tonumber(page) or 1), 1)
			local Ascending = not not key
			pageSize = tonumber(pageSize) or 10
			local KeyProccess = string.format(
				"%sGlobalDataStore_%d_%s",
				section.Name or "testttttt",
				pageSize,
				tostring(Ascending)
			)
			local LastDataKey = self.AsyncInProcess.Get[KeyProccess]
			if not LastDataKey then
				local signal = Instance.new("BindableEvent")
				local newProccess = {
					TimeGetData = DateTime.now().UnixTimestampMillis,
					SortedAsync = nil,
					IsLimit = false,
					Pages = {},
					Searching = signal.Event,
				}
				self.AsyncInProcess.Get[KeyProccess] = newProccess
				local sending = typeof(section)=="table" and {index, KeyProccess} or section
				local success,Data = pcall(section.GetSortedAsync, sending, Ascending, pageSize)
				local Result = {
					IsLimit = true,
					Success = success,
					Data = false,
					Pages = {},
					TotalPages = 0,
				}
				task.defer(function()
					newProccess.Searching = nil
					signal:Fire(Result)
					signal:Destroy()
				end)
				if success then
					newProccess.SortedAsync = Data
					local PageActual = Data:GetCurrentPage()
					
					if #PageActual > 0 then
						table.insert(newProccess.Pages, PageActual)
						newProccess.NumberPage = #newProccess.Pages
						Result.Pages = newProccess.Pages
					else
						newProccess.TimeGetData -= (self.TimeUpdateGlobalData/2)*1000
						newProccess.NumberPage = 0
					end
					
					Result.Data = Result.Pages[page] or false
					Result.TotalPages = newProccess.NumberPage
					Result.IsLimit = Data.IsFinished
					
					return Result.IsLimit and Result or self:GetData(NameType, key, pageSize, page), true
				else
					self.AsyncInProcess.Get[KeyProccess] = nil
					return Result
				end
			elseif LastDataKey.Searching then
				local data = LastDataKey.Searching:Wait()
				return data.Success and self:GetData(NameType, key, pageSize, page) or data, true
			elseif self:ElapsedTime(LastDataKey.TimeGetData) >= self.TimeUpdateGlobalData then
				local bin:BindableEvent = LastDataKey.OrderPage
				if bin then
					bin:Fire()
					bin:Destroy()
				end
				self.AsyncInProcess.Get[KeyProccess] = nil
				return self:GetData(NameType, key, pageSize, page)
			else
				local bin
				if not LastDataKey.OrderPage then
					bin = Instance.new("BindableEvent")
					LastDataKey.OrderPage = bin
				else
					LastDataKey.OrderPage.Event:Wait()
					if LastDataKey ~= self.AsyncInProcess.Get[KeyProccess] then
						return {
							Success = false,
							IsLimit = true,
							TotalPages = 0,
							Pages = {},
						}
					end
				end
				if page > LastDataKey.NumberPage and not LastDataKey.SortedAsync.IsFinished then
					local advance = page - LastDataKey.NumberPage
					for index = 1, advance do
						if LastDataKey.SortedAsync.IsFinished then break end
						local s, ErrorMessage = pcall(LastDataKey.SortedAsync.AdvanceToNextPageAsync, LastDataKey.SortedAsync)
						if not s then
							warn(ErrorMessage)
							break
						end
						table.insert(
							LastDataKey.Pages,
							LastDataKey.SortedAsync:GetCurrentPage()
						)
					end
					LastDataKey.NumberPage = #LastDataKey.Pages
				end
				if bin then
					bin:Fire()
					bin:Destroy()
					LastDataKey.OrderPage = nil
				end
				return {
					IsLimit = LastDataKey.SortedAsync.IsFinished,
					Success = true,
					Data = LastDataKey.Pages[page] or false,
					Pages = LastDataKey.Pages,
					TotalPages = LastDataKey.NumberPage,
				}
			end
		end
	end
end

function module:UpdateData(NameType, key, functionActive)
	local index,section = self:GetSection(NameType)
	if index and section and typeof(key) == 'string' then
		if (index == 'GetDataStore' or index == 'GlobalDataStore') and typeof(functionActive) == 'function' then
			local ProcessKey = NameType .. ":" .. key
			local process = self.AsyncInProcess.Get[ProcessKey]
			if not process then
				local bin = Instance.new("BindableEvent")
				self.AsyncInProcess.Get[ProcessKey] = bin.Event
				local sending = typeof(section)=="table" and index or section
				local DataActualizado
				local n,s = pcall(section.UpdateAsync,sending,key,function(lastData)
					DataActualizado = functionActive(lastData)
					return DataActualizado
				end)
				self.AsyncInProcess.Get[ProcessKey] = nil
				bin:Fire()
				bin:Destroy()
				return n, n and (typeof(DataActualizado)=="table" and table.clone(DataActualizado) or DataActualizado) or s
			else
				process:Wait()
				return self:UpdateData(NameType, key, functionActive)
			end
		end
	end
end
function module:SetData(NameType, key, Data)
	local index,section = self:GetSection(NameType)
	if index and section and typeof(key) == 'string' then
		if (index == 'GetDataStore' and Data ~= nil) or (index == 'GlobalDataStore' and typeof(Data) == 'number') then
			local ProcessKey = NameType .. ":" .. key
			local process = self.AsyncInProcess.Get[ProcessKey]
			if not process then
				local bin = Instance.new("BindableEvent")
				self.AsyncInProcess.Get[ProcessKey] = bin.Event
				local sending = typeof(section)=="table" and index or section
				local n,s = pcall(section.SetAsync,sending,key,Data)
				self.AsyncInProcess.Get[ProcessKey] = nil
				bin:Fire()
				bin:Destroy()
				return n, n and (typeof(Data)=="table" and table.clone(Data) or Data) or s
			else
				process:Wait()
				return self:SetData(NameType, key, Data)
			end
		else
			return false, "Datos erroneos"
		end
	end
end
function module:DeleteData(NameType, key)
	local index,section = self:GetSection(NameType)
	if index and section and typeof(key) == 'string' then
		local ProcessKey = NameType .. ":" .. key
		local process = self.AsyncInProcess.Get[ProcessKey]
		if not process then
			local bin = Instance.new("BindableEvent")
			self.AsyncInProcess.Get[ProcessKey] = bin.Event
			local sending = typeof(section)=="table" and index or section
			local n,s = pcall(section.RemoveAsync,sending,key)
			self.AsyncInProcess.Get[ProcessKey] = nil
			bin:Fire(n,s)
			bin:Destroy()
			return n,s
		else
			return process:Wait()
		end
	end
end

function module:Values(Value : ValueBase)
	if Value and Value:IsA('ValueBase') then
		local list2 = {}
		list2.Name = Value.Name
		list2.Value = Value.Value
		for index, Value in Value:GetAttributes() do
			Value = self.VerifyAtt.Set(Value)
			list2[index] = Value
		end
		list2.Childs = self:chainOfValues(Value)
		return list2
	end
end

function module:chainOfValues(folder : BoolValue)
	if folder and #folder:GetChildren() > 0 then
		local list = {}
		for _,Rol : BoolValue in folder:GetChildren() do
			local list2 = self:Values(Rol)
			table.insert(list, list2)
		end
		return list
	end
end

return module.new()
