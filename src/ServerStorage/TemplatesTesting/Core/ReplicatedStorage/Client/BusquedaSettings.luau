local module = {}

local IsClient = game:GetService('RunService'):IsClient()

module.AntiSpamBusqueda = {}

-----------------Musicas

module.LimitCharacterReport = 350
module.LimitCharacterBusqueda = 35

-----------DAteTime
function module.ElapsedTime(number)
	local t = DateTime.now().UnixTimestampMillis
	number = tonumber(number) or t
	return (t - number) / 1000
end
function module.IsAviableCooldown(number, HoldTime)
	HoldTime = tonumber(HoldTime) or 0
	local Elapsed = module.ElapsedTime(number)
	return not number or Elapsed>=HoldTime, math.max(0, HoldTime - Elapsed)
end
function module.FormatDateTime(timestamp)
	timestamp = tonumber(timestamp) or nil
	local dateTime = timestamp and DateTime.fromUnixTimestamp(timestamp)
	dateTime = dateTime and dateTime:ToUniversalTime()
	return dateTime and string.format("%02d/%02d/%d", dateTime.Day, dateTime.Month, dateTime.Year)
end
function module.ParseDate(dateString)
	if typeof(dateString) ~= 'string' then return end
	local day, month, year = dateString:match("(%d%d)/(%d%d)/(%d%d%d%d)")
	if not day or not month or not year then return end
	day, month, year = tonumber(day), tonumber(month), tonumber(year)
	local success, dateTime = pcall(function()
		return DateTime.fromUniversalTime(year, month, day).UnixTimestamp
	end)
	if success then return dateTime end
end
function module.FormatTime(timee)
	timee = math.max(math.floor(tonumber(timee) or 0),0)
	local hour = math.floor(timee / 3600)
	local minutes = math.floor((timee % 3600) / 60)
	local seconds = timee % 60
	if hour > 0 then
		return string.format('%02d:%02d:%02d', hour, minutes, seconds)
	elseif minutes > 0 then
		return string.format('%02d:%02d', minutes, seconds)
	else
		return string.format('%02d', seconds)
	end
end
-------------------------------------------Datas
function module.CreateInfoRevision(Info,search)
	assert(typeof(Info)=="table" and typeof(search)=="string", "datos erroneos")
	local date = module.GetInfoRevision(Info, search)
	if not date then
		date = {
			Name = search,
			Value = false,
			Childs = {}
		}
		Info.Childs = Info.Childs or {}
		table.insert(Info.Childs, date)
	end
	return date
end

function module.RemoveInfoRevision(Info,search)
	assert(typeof(search)=="string", "datos erroneos")
	local date = module.GetInfoRevision(Info, search)
	if typeof(date) == "table" then
		table.remove(Info.Childs, table.find(Info.Childs, date))
		return date
	end
end

function module.GetInfoRevision(Info,search)
	search = typeof(search)=="string" and search or 'State'
	if typeof(Info) == 'table' then
		local child = Info.Childs
		if not child then return end
		if Info[search] then return Info[search] end
		for _,state in child do
			if state.Name == search then
				return state
			end
		end
	elseif typeof(Info) == "Instance" then
		return Info:FindFirstChild(search)
	end
end

function module.IsBan(Info)
	local Datas = module.GetInfoRevision(Info, "BuzonAdminSong")
	if not Datas then return false end
	Datas = typeof(Datas)=="table" and Datas.Childs
		or typeof(Datas)=="Instance" and Datas:GetChildren()
	if not Datas or #Datas <= 0 then return false end
	for _, Revision in Datas do
		if typeof(Revision) == "table" then
			if not Revision.IsBan or Revision.UnBan then continue end
			return Revision
		elseif typeof(Revision) == "Instance" then
			if not Revision:GetAttribute("IsBan") or Revision:GetAttribute("UnBan") then continue end
			return Revision
		end
	end
	return false
end

----------------------------------------

function module.PuedeBuscar(Player:Player)
	if not IsClient and typeof(Player) == 'Instance' and Player:IsA('Player') then
		local now = DateTime.now().UnixTimestampMillis
		module.AntiSpamBusqueda[Player.UserId] = module.AntiSpamBusqueda[Player.UserId] or {count = 0, DateT = now,ConteoBurst = 0}
		local datos = module.AntiSpamBusqueda[Player.UserId]
		local ElapsedTime = module.ElapsedTime(datos.DateT)
		if ElapsedTime < 3 then
			datos.ConteoBurst += 1
		else
			datos.ConteoBurst = 0
		end
		if ElapsedTime < 60 then
			datos.count += 1
		else
			datos.count = 1
		end
		if datos.ConteoBurst >= 5 then
			Player:Kick("Búsquedas demasiado rápidas. Intenta más despacio.")
			return
		end
		if datos.count > 20 then
			return
		end
		return true
	end
end

function module.quitarAcentos(palabra)
	local acentos = {
		["á"] = "a", ["é"] = "e", ["í"] = "i", ["ó"] = "o", ["ú"] = "u",
		["Á"] = "A", ["É"] = "E", ["Í"] = "I", ["Ó"] = "O", ["Ú"] = "U",
		["ñ"] = "n", ["Ñ"] = "N" 
	}
	return (palabra:gsub("[%z\1-\127\194-\244][\128-\191]*", function(c)
		return acentos[c] or c
	end))
end
function module.VerificarTexto(Text:string, noAcent)
	if typeof(Text) == 'string' and #Text > 0 then
		local EliminarEspacios = Text:match("^%s*(.-)%s*$")
		return #EliminarEspacios > 0 and (noAcent and EliminarEspacios or module.quitarAcentos(EliminarEspacios))
	end
end
function module.LimitCharacter(text, count)
	if typeof(count)~="number" or count<=0 or typeof(text)~="string" then return "" end
	text = module.VerificarTexto(text, true)
	return text and (#text > count and string.sub(text,0,count) or text)
end

function module.GetTextIndiceSong(Song:Instance)
	local Data = typeof(Song)=="Instance" and Song:GetAttributes() or typeof(Song)=="table" and Song
	if not Data then
		return warn("No se encontro indices")
	end
	local text = ""
	for _,v in {"NameSong", "Artista", "Genero", "Language"} do
		if Data[v] then
			text = text.." "..Data[v]
		end
	end
	return #text>0 and text
end

function ReducirRepeticionesConsecutivas(palabra)
	if typeof(palabra) ~= "string" or #palabra == 0 then
		return ""
	end
	for i = 1, #palabra // 2 do
		local patron = palabra:sub(1, i)
		local cantidad = #palabra // #patron

		if cantidad * #patron == #palabra then
			local repetido = patron:rep(cantidad)

			if repetido == palabra then
				return patron
			end
		end
	end
	return palabra
end

function module.getIndices(Text)
	Text = module.VerificarTexto(Text)
	if not Text then return end
	local indices = {}
	Text = Text:gsub("[%p]", " ")
	for palabra in Text:gmatch("%S+") do
		palabra = ReducirRepeticionesConsecutivas(palabra:lower())
		if #palabra <= 2 or table.find(indices, palabra) then
			continue
		end
		table.insert(indices, palabra)
	end
	return #indices > 0 and indices
end

return module
