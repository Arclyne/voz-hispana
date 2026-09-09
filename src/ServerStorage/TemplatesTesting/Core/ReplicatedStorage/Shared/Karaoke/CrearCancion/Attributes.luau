local module = {}

local Debris = game:GetService('Debris')
local InsertService = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("InsertService"))

setmetatable(module,{
	__index = function(_,NameAttribute) return function(_,Song:BoolValue,Value)
			Song:SetAttribute(NameAttribute, Value)
		end
	end
})

function module:SoundId(Song:BoolValue,Value)
	Value = tonumber(Value)
	local LastValue = Song:GetAttribute("SoundId")
	local sound = Song:FindFirstChild("Recursos"):FindFirstChild("SoundId")
	if Value and (Value~=LastValue or not sound) then
		local lyric = Song:FindFirstChild("Lyrics")
		if lyric then lyric:SetAttribute("IsChange", true) end
		if not sound then
			sound = Instance.new("Sound")
			sound.Name = 'SoundId'
			sound.Volume = 2
			sound.Parent = Song:FindFirstChild('Recursos')
		end
		sound:SetAttribute("Id", tonumber(Value))
		sound.SoundId = string.format("rbxassetid://%d",Value)
		Song:SetAttribute("SoundId", Value)
	else
		if sound then Debris:AddItem(sound,0) end
		Song:SetAttribute('SoundId',nil)
	end
end

function module:Miniatura(Song:BoolValue,Value)
	Value = tonumber(Value)
	local LastValue = Song:GetAttribute("Miniatura")
	local miniatura = Song:FindFirstChild("Recursos"):FindFirstChild("Miniatura")
	if Value ~= LastValue or not miniatura then
		if miniatura then
			Debris:AddItem(miniatura,0)
		end
		InsertService.UpdateAsset(Song.Name.."Local", Value, function(NewMiniatura)
			if NewMiniatura then
				NewMiniatura.Name = 'Miniatura'
				NewMiniatura.Parent = Song:FindFirstChild('Recursos')
			end
			Song:SetAttribute("Miniatura", NewMiniatura and Value or nil)
		end, "Decal")
	end
	
end

function module:Genero(Song:BoolValue,Value)
	local generos = {}
	local texto = (typeof(Song) == 'Instance' and Song:GetAttribute('Genero')) or (typeof(Song) == 'string' and Song) or ''
	for genero in texto:gmatch("([^,]+)") do
		table.insert(generos, genero:match("^%s*(.-)%s*$"))
	end
	if Value and table.find(self.TypesList.Generos, Value) then
		local index = table.find(generos,Value)
		if not index then table.insert(generos, Value) else table.remove(generos,index) end
	end
	return #generos > 0 and table.concat(generos,',') or nil
end

function module:Language(Song:BoolValue,Value)
	local IdiomaSelected = Value and table.find(self.TypesList.Lenguajes, Value) and Value or self.TypesList.Lenguajes[1]
	Song:SetAttribute("Language", Value)
end

function module:Fechalanzamiento(Song:BoolValue,Value)
	local NewValue = tonumber(Value) or self.TextoSettings.ParseDate(Value)
	Song:SetAttribute("Fechalanzamiento", NewValue and tostring(NewValue) or nil)
end

function module:UltimaModificacionLyrics(Song:BoolValue,Value)
	local LetrasValue = Song == self.SongActive and Song:FindFirstChild('Lyrics')
	if LetrasValue then LetrasValue:SetAttribute("IsChange", true) end
	Song:SetAttribute("UltimaModificacionLyrics", Value)
end

return module
