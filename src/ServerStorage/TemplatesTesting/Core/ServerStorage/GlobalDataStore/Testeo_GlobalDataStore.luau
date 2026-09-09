local module = {}
module.__index = module
local HTTPS = game:GetService("HttpService")

local listCache = {}

local function GetSection(section)
	local sectiondata = listCache[section]
	if not sectiondata then
		sectiondata = {}
		listCache[section] = sectiondata
	end
	return sectiondata
end

function module.GetSortedAsync(dataSection,Ascending, pageSize)
	local section = GetSection(dataSection[1])
	local self = section[dataSection[2]]
	if not self then
		self = setmetatable({
			Ascending = not Ascending,
			pageSize = pageSize,
			TotalPages = math.random(1, 2),
			PagesSaveds = {},
		}, module)
		self.value = self.Ascending and 0 or (pageSize * self.TotalPages)
		section[dataSection[2]] = self
	end
	self.CountPage = 1
	self.IsFinished = self.CountPage>=self.TotalPages
	return self
end
function module:GetCurrentPage()
	if self.TotalPages <= 0 then return {} end
	local page = self.PagesSaveds[self.CountPage]
	if not page then
		page = {}
		if not self.IsFinished or self.TotalPages > 0 then
			local count = self.CountPage<self.TotalPages and self.pageSize or math.random(1, self.pageSize)
			for i = 1, count do
				self.value += self.Ascending and 1 or -1
				table.insert(page, {
					key = tostring(HTTPS:GenerateGUID(true)),
					value = tonumber(self.value),
				})
			end
		end
		self.PagesSaveds[self.CountPage] = page
	end
	return page
end
function module:AdvanceToNextPageAsync()
	if self.CountPage<self.TotalPages then
		self.CountPage += 1
		self.IsFinished = self.CountPage>=self.TotalPages
	end
end

---
local count = 0
local htt = game:GetService("HttpService")

function DetectarBan(texto)
	local comando, argumento = texto:match("^/(%S+)%s*(.*)$")
	return comando == "ban", comando and argumento or texto
end
function GetBuzonAdminSong(versionRevision,MessageWarn,Status)
	local ban,text = DetectarBan(MessageWarn)
	return {
		Name = versionRevision or htt:GenerateGUID(true),
		ReviewerUserId = 1644684719,
		ReviewedAt = tostring(DateTime.now().UnixTimestamp),
		Value = not not Status,
		IsBan = ban,
		Message = text,
	}
end
function GetDenucia(UserId, MessageDenuncia)
	return {
		Name = tonumber(UserId) or 1644684719,
		Value = MessageDenuncia,
		DateDenuncia = tostring(DateTime.now().UnixTimestamp),
	}
end

local function createTestData(key)
	count += 1
	local dddd = DateTime.now().UnixTimestamp
	
	local State = {
		Name = 'State',
		Value = false,
		RevisionEnviada = tostring(DateTime.now().UnixTimestamp),
		Owner = 173461994,
		KeyRevision = htt:GenerateGUID(true),
	}
	
	return {
		["Name"] = key,
		["Value"] = false,
		['NameSong'] = string.format("Test create #%d", count),
		['Description'] = 'solo para pruebas',
		['Artista'] = 'leoooo',
		['Genero'] = 'Pop',
		['Fechalanzamiento'] = DateTime.now().UnixTimestamp,
		['Miniatura'] = 6319951718,
		['SoundId'] = 138409967057445,
		['UltimaModificacionLyrics'] = tostring(dddd),
		["Language"] = "Español",
		
		["Testeooo"] = true,
		
		["Childs"] = {
			State,
			
			{
				Name = 'BuzonAdminSong',
				Value = false,
				Childs = {
					GetBuzonAdminSong(nil, "Test rechazo"),
					GetBuzonAdminSong(nil, "/ban Test baneooo"),
					GetBuzonAdminSong(State.KeyRevision, "Test aceptacion", true),
				}
			},
			{
				
				Name = 'Denuncias',
				Value = false,
				Childs = {
					GetDenucia(nil, "hola"),
					GetDenucia(1670242707, "chau"),
					GetDenucia(173461994, "awiydayiwhd"),
				}
				
			},
		}
	}
	
end

function module.GetAsync(section,key)
	section = GetSection(section)
	local data = section[key]
	if not data then
		data = createTestData(key)
		section[key] = data
	end
	return data
end
function module.RemoveAsync(section,key)
	GetSection(section)[key] = nil
end
----
function module.UpdateAsync(section,key,FunctionChange)
	assert(typeof(FunctionChange)=="function", "Solo funciones")
	GetSection(section)[key] = FunctionChange(module.GetAsync(section, key))
end

function module.SetAsync(section,key,data)
	GetSection(section)[key] = data
end


return module
