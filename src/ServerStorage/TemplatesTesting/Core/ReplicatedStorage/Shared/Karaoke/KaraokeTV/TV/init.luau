local module = {}
module.__index = module

local IsClient = game:GetService('RunService'):IsClient()
local TemplateGui = script:WaitForChild('KaraokeTemplate')
local Players = game:GetService('Players')
local LocalPlayer = IsClient and Players.LocalPlayer
local ZonaSystem = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("AreaSystem"))
local debirs = game:GetService("Debris")

local idVideos = { "rbxassetid://5608360493", "rbxassetid://5608369138" }

function module.new(Model : Model)
	local Screen = typeof(Model) == 'Instance' and Model:IsA('Model') and Model:FindFirstChild('Screen') and Model:FindFirstChild('Screen'):FindFirstChildOfClass('SurfaceGui')
	if Screen then
		local self = setmetatable({
			
			Model = Model,
			Screen = Screen,
			IsActive = false,
			actives = {},
			
			MusicInQueen = {},
			listening = {},
			skips = {},
			
		},module)
		
		self:On()
		
		return self
	end
end

local function CreateMessage(...)
	local Missing = {}
	for _, Data in {...} do
		if not Data.Exists then
			table.insert(Missing, Data.Message)
		end
	end
	if #Missing == 0 then
		return
	elseif #Missing == 1 then
		return Missing[1]
	elseif #Missing == 2 then
		return Missing[1] .. " y " .. Missing[2]
	else
		local Last = table.remove(Missing)
		return table.concat(Missing, ", ") .. " y " .. Last
	end
end

function RemoveActive(active,...)
	if typeof(active)~="table" then return end
	local all = {...}
	if #all > 0 then
		for _,index in all do
			if active[index] then
				active[index]:Disconnect()
				active[index] = nil
			end
		end
	else
		for _,v in active do
			v:Disconnect()
		end
		table.clear(active)
	end
end

function module:PlaySound(key, assetId, Playing)
	if IsClient then return end
	local newSong = Instance.new('Sound')
	newSong.Name = key
	newSong.SoundId = "" or string.format("rbxassetid://%d",tonumber(assetId))
	newSong.Volume = 0
	newSong.PlayOnRemove = false
	newSong.Playing = not not Playing
	newSong.RollOffMaxDistance = math.huge
	return newSong
end

function module:Reproducir()
	if IsClient then return end
	if self.Activekaraoke then
		if not self.Activekaraoke.SongInProccess then
			local SelectKey = self.MusicInQueen[1]
			local CacheSound = SelectKey and self.Parent.DataStore.PalabrasFunc.cache.Success.Publicas[SelectKey]
			if CacheSound then
				local list = {
					SelectKey = SelectKey,
					CacheSound = CacheSound,
					TimeStart = DateTime.now().UnixTimestampMillis,
				}
				self.Activekaraoke.SongInProccess = list
				local sound:Sound = self:PlaySound(SelectKey,CacheSound.SoundId)
				sound.Parent = self.Model:WaitForChild('Screen')
				list.sound = sound
				
				local listClient = table.clone(list)
				listClient.gui = self.Activekaraoke.gui
				self.Events.reproducir:FireAllClients(listClient, self.Model)
				
				list.SearchLyric = task.spawn(function()
					local success,dataLyric = self.DataStore:GetData('Letras',SelectKey)
					if success then
						if dataLyric and #dataLyric > 0 then
							list.Letra = self.CreacionSong:GetLyric(dataLyric)
						else
							list.NoLetra = true
						end
					else
						self:Reproducir()
					end
				end)
				self.actives['EndedSong'] = sound.Ended:Connect(function()
					local clone = script:FindFirstChild('RewardOut'):Clone()
					clone.Parent = sound.Parent
					clone.PlayOnRemove = true
					debirs:AddItem(clone,0)
					list.Ending = DateTime.now().UnixTimestampMillis
				end)
			elseif SelectKey then
				table.remove(self.MusicInQueen,1)
				self.Events.RemovedSong:FireAllClients(self.Model,SelectKey)
				self:Reproducir()
			end
		else
			RemoveActive(self.actives,"EndedSong")
			local list = self.Activekaraoke.SongInProccess
			table.remove(self.MusicInQueen,table.find(self.MusicInQueen, list.SelectKey))
			if list.SearchLyric then task.cancel(list.SearchLyric) end
			self.Events.RemovedSong:FireAllClients(self.Model,list.SelectKey)
			debirs:AddItem(list.sound,0)
			self.Activekaraoke.SongInProccess = nil
			if #self.MusicInQueen > 0 then
				self:Reproducir()
			else
				self:EndedKaraoke()
			end
		end
		
		self.skips = {}
		self.Events.Skip:FireAllClients(self.skips,self.Model)
	end
end

function module:ElapsedTime(t)
	local ela = DateTime.now().UnixTimestampMillis
	return (ela - (tonumber(t) or ela)) / 1000
end
function module:Cancelar()
	if IsClient then return end
	self:Reproducir(true)
end

function module:ViewLetra(position, letra)
	if not IsClient and position and letra then
		for _,lyric in letra do
			if lyric.StartTime and lyric.EndTime and #lyric.Lyrics > 0 then
				if position >= lyric.StartTime and position < lyric.EndTime then
					local letra2 = ''
					for _,extras in lyric.Lyrics do
						local ElapsedTime = math.max(position - extras.StartTime, 0)
						local TimeEnd = extras.EndTime - extras.StartTime
						local now = math.min(ElapsedTime / TimeEnd, 1)
						local letraactual = math.round(now * #extras.letra)
						local IsEnding = extras.Ending and position >= extras.StartTime and position < extras.EndTime
						local lyricsss = IsEnding and '<font color="rgb(0, 0, 255)">'..extras.letra..'</font>' or
							not extras.Ending and '<font color="rgb(0, 0, 255)">'..string.sub(extras.letra,0,letraactual)..'</font><font color="rgb(81, 255, 69)">'..(letraactual+1 <= #extras.letra and
								string.sub(extras.letra,letraactual+1,#extras.letra) or '')..'</font>' or ''
						letra2 = IsEnding and lyricsss or letra2..(#letra2 > 0 and ' ' or '')..lyricsss
					end
					return letra2
				end
			end
		end
	end
	return '♪♪♪♪♪♪♪♪♪♪♪♪'
end

function module:Distance(Object)
	local typeObject = typeof(Object) == 'Instance' and (Object:IsA('Model') or Object:IsA('BasePart')) and Object:GetPivot()
	if not typeObject then return end
	local IsObject = self.PrivateTV and self.PrivateTV.IsRent.SalaModel:FindFirstChild("listening") or self.Model:FindFirstChild("listening")
	if IsObject then
		local list = {model = IsObject}
		return ZonaSystem.IsInArea(list, typeObject.Position) and ZonaSystem.IsInside(list, typeObject.Position)
	else
		local magnitude = (typeObject.Position-self.Model:GetPivot().Position).Magnitude
		return magnitude <= self.maxDistance and magnitude
	end
end

function module:IsChanged(NewList)
	if #self.listening ~= #NewList then return true end
	for i, v in ipairs(self.listening) do
		if v ~= NewList[i] then return true end
	end
	return false
end

function module:UpdateOwner()
	if not IsClient and not self.PrivateTV and (self.Owner and not self:Distance(self.Owner.Character)) then
		self.Owner = nil
		self.Events.SetOwner:FireAllClients(self.Owner,self.Model)
	end
end

function module:UpdateListening()
	if IsClient then return end
	local NewList = {}
	for _,plr in Players:GetPlayers() do
		if self:Distance(plr.Character) then
			table.insert(NewList,plr)
		end
	end
	table.sort(NewList,function(a,b) return a.UserId < b.UserId end)
	if self:IsChanged(NewList) then
		local NewSkips = {}
		for _,plrSkip in self.skips do
			if typeof(plrSkip) == 'Instance' and
				plrSkip:IsA('Player') and plrSkip:IsDescendantOf(game) and table.find(NewList, plrSkip) then
				table.insert(NewSkips, plrSkip)
			end
		end
		self.skips = NewSkips
		self.listening = NewList
		self.Events.Skip:FireAllClients(self.skips,self.Model)
		self.Events.listening:FireAllClients(self.listening,self.Model)
	end
end

function module:RunningActive()
	if IsClient then return end
	if self.Activekaraoke then
		local SongActive = self.Activekaraoke.SongInProccess
		local AllLoaded = SongActive and SongActive.sound and SongActive.sound.IsLoaded and SongActive.Letra
		
		local ElapsedStart = self:ElapsedTime(SongActive.TimeStart)
		local ElapsedEnding = SongActive.Ending and self:ElapsedTime(SongActive.Ending) > 5
		
		local StartIsOn = AllLoaded and ElapsedStart > 5
		
		if AllLoaded then
			if not SongActive.sound.IsPlaying
				and not SongActive.IsPlaying and 
				ElapsedStart > 5 then
				SongActive.IsPlaying = true
				SongActive.sound:Play()
			end
		elseif ElapsedStart > 20 and not SongActive.ReportarSong then
			SongActive.ReportarSong = true
			local Message = CreateMessage(
				{
					Exists = SongActive.sound.IsLoaded,
					Message = "El sonido no está disponible"
				},
				{
					Exists = not SongActive.NoLetra,
					Message = "no existen datos de las letras"
				}
			)
			if Message then
				task.spawn(function()
					print(self.Parent.RevisarCanciones:ActionSongDenunce(false,SongActive.SelectKey,Message))
				end)
			end
		end
		
		if AllLoaded and SongActive.sound.TimePosition >= SongActive.sound.TimeLength/2 and not SongActive.AumentarReproduccion then
			SongActive.AumentarReproduccion = true
			task.spawn(function()
				self.DataStore:UpdateData('MusicasRating',SongActive.SelectKey,function(lastData)
					local Total = (tonumber(lastData) or 0) + 1
					return Total
				end)
			end)
		end
		
		local gui = self.Activekaraoke.gui
		gui.Loading.IconSong.Image = AllLoaded and self.Activekaraoke.SongInProccess.CacheSound.Miniatura or ''
		gui.Loading.NameArtist.Text = AllLoaded and self.Activekaraoke.SongInProccess.CacheSound.Artista or 'Artista desconocido'
		gui.Loading.NameSong.Text = AllLoaded and self.Activekaraoke.SongInProccess.CacheSound.NameSong or 'Musica desconocida'
		
		gui.Loading.Visible = not (StartIsOn or SongActive.Ending)
		gui.Loading.Load.Rotation = not (StartIsOn or SongActive.Ending) and (tick()*360) % 360 or 0
		gui.Letras.Visible = not not (AllLoaded and ElapsedStart > 5 and not SongActive.Ending)
		if gui.Letras.Visible then
			gui.Letras.Text = self:ViewLetra(SongActive.sound.TimePosition, AllLoaded)
		end
		
		gui.End.Visible = not not SongActive.Ending
		if (ElapsedEnding or SongActive.ReportarSong)
			and not SongActive.ChangeNewMusic then
			SongActive.ChangeNewMusic = true
			self:Reproducir()
		end
		
		self:UpdateListening()
		self:UpdateOwner()
	end
end

function module:StartKaraoke(Close)
	if not IsClient then
		if #self.MusicInQueen > 0 and not self.Activekaraoke then
			self.Activekaraoke = {}
			local Gui = TemplateGui:Clone()
			Gui.Parent = self.Screen
			self.Activekaraoke.gui = Gui
			if not self.PrivateTV then
				self.RunningAction = self.Running:AddFunct(function(...) self:RunningActive(...) end)
			end
			self:Reproducir()
		end
		self.Model:SetAttribute('Karaoke', not not self.Activekaraoke)
	elseif self.reproducirList then

		RemoveActive(self.actives,"EndedVideo","StartMusic","EndMusic")
		
		local videFrame:VideoFrame = self.reproducirList.gui.BackVideo
		local Sound:Sound = self.reproducirList.sound
		
		videFrame.Volume = 0
		
		self.actives['EndedVideo'] = videFrame.Ended:Connect(function()
			videFrame.Visible = true
			videFrame.Video = idVideos[math.random(1, #idVideos)]
			videFrame.Playing = true
		end)
		self.actives['StartMusic'] = Sound.Played:Connect(function()
			videFrame.Visible = true
			videFrame.Video = idVideos[math.random(1, #idVideos)]
			videFrame.Playing = true
		end)
		self.actives['EndMusic'] = Sound.Ended:Connect(function()
			videFrame:Pause()
			videFrame.Visible = false
		end)
		
		if Sound.IsPlaying then
			videFrame.Visible = true
			videFrame.Video = idVideos[math.random(1, #idVideos)]
			videFrame.Playing = true
		end
		
		Sound.Volume = 1
	end
end
function module:EndedKaraoke()
	if not IsClient then
		self.RunningAction = self.Running:ElimineFunct(self.RunningAction)
		if self.Activekaraoke then
			self.Events.reproducir:FireAllClients(false,self.Model)
			debirs:AddItem(self.Activekaraoke.gui,0)
			self:Cancelar()
		end
		self.listening = {}
		self.Activekaraoke = nil
		self.Model:SetAttribute('Karaoke', self.Activekaraoke)
		self.Events.listening:FireAllClients(self.listening,self.Model)
	elseif self.reproducirList then
		RemoveActive(self.actives,"EndedVideo","StartMusic","EndMusic")
		if self.reproducirList.gui and self.reproducirList.gui:FindFirstChild("BackVideo") then
			self.reproducirList.gui.BackVideo:Pause()
			self.reproducirList.gui.BackVideo.Visible = false
		end
		if self.reproducirList.sound then
			self.reproducirList.sound.Volume = 0
		end
	end
end

function module:ClaimOwner()
	if IsClient then self.Events.SetOwner:FireServer(self.Model) end
end
function module:AddedSongCola(Key)
	if IsClient then self.Events.AddedSong:FireServer(self.Model,Key) end
end
function module:Skip()
	if IsClient then self.Events.Skip:FireServer(self.Model) end
end

function module:Off()
	if not self.IsActive then return end
	self.IsActive = false
	self:EndedKaraoke()
	if IsClient then debirs:AddItem(self.ChangeEvent,0) end
	for _,v:RBXScriptConnection in self.actives do v:Disconnect() end
end
function module:On()
	if self.IsActive then return end
	self.IsActive = true
	if IsClient then
		local blindade = Instance.new('BindableEvent', script)
		self.ChangeEvent = blindade
		self.Changed = blindade.Event
		self.Events.init:FireServer(self.Model)
	else
		
		if self.SalasRent then
			for _,sala in self.SalasRent.Salas do
				if sala.IsRent and sala.IsRent.SalaModel
					and sala.IsRent.SalaModel:IsAncestorOf(self.Model) then
					self.PrivateTV = sala
					self.Model:SetAttribute("PrivateTV", true)
					task.delay(1,sala.AddedTV,sala,self)
				end
			end
		end
		
		if self.Model:GetAttribute("PrivateTV")==nil then
			self.Model:SetAttribute("PrivateTV", false)
		end
	end
end

return module