local module = {}
local IsClient = game:GetService('RunService'):IsClient()
local Players = game:GetService("Players")
local LocalPlayer = IsClient and Players.LocalPlayer
local PlayerAdded

setmetatable(module,{__index = function() return function() end end})

function ClearActives(actives)
	if typeof(actives) == 'table' then
		for _,v:RBXScriptConnection in actives do if typeof(v) == 'RBXScriptConnection' then v:Disconnect() end end
	end
end
function ClearActive(actives, Name)
	if typeof(actives) == 'table' and typeof(actives[Name]) == 'RBXScriptConnection' then
		actives[Name]:Disconnect()
		actives[Name] = nil
	end
end
function module:SetOwner(Player:Player,Model:Model)
	local Television = self:FindTV(Model)
	if not Television then Television = self:Added(Model) end
	if Television then
		if not IsClient and Player then
			for _,OtherTelevisiones in self:GetTvs() do
				if OtherTelevisiones ~= Television and OtherTelevisiones.Owner == Player then
					if not OtherTelevisiones.PrivateTV then
						module.SetOwner(self,nil,OtherTelevisiones.Model)
					else
						return
					end
				end
			end
		end
		if Player and not Television.Owner then
			Television.Owner = Player
			ClearActive(Television.actives,'OwnerExit')
			Television.actives['OwnerExit'] = Player.AncestryChanged:Connect(function(_,parent)
				if not parent then module.SetOwner(self,nil,Model) end
			end)
		elseif ((not Player and Television.Owner) or (Player == Television.Owner and not IsClient)) and not Television.PrivateTV then
			Television.Owner = nil
			ClearActive(Television.actives,'OwnerExit')
		end
		if not IsClient then
			Television.Events:FindFirstChild('SetOwner'):FireAllClients(Television.Owner,Television.Model)
		else
			Television.ChangeEvent:Fire('Owner')
		end
	end
end
function module:AddedSong(Player,Model,KeySong)
	KeySong = IsClient and Model or KeySong
	Model = IsClient and Player or Model
	local Television = self:FindTV(Model)
	if not Television then Television = self:Added(Model) end
	if Television and typeof(KeySong) == 'string' then
		local InfoInCache = (not IsClient and self.DataStore.PalabrasFunc.cache.Success.Publicas or self.PreloadSongs.cache)[KeySong]
		local SearchInCole = table.find(Television.MusicInQueen,KeySong)
		if (IsClient or InfoInCache) and not SearchInCole then
			table.insert(Television.MusicInQueen,KeySong)
			if not IsClient then
				Television.Events:FindFirstChild('AddedSong'):FireAllClients(Television.Model,KeySong)
				Television:StartKaraoke()
			else
				Television.ChangeEvent:Fire('AddedSong')
			end
		end
	end
end
function module:RemovedSong(Player,Model,KeySong)
	KeySong = IsClient and Model or KeySong
	Model = IsClient and Player or Model
	local Television = self:FindTV(Model)
	if not Television then Television = self:Added(Model) end
	if Television and typeof(KeySong) == 'string' then
		local SearchInCole = table.find(Television.MusicInQueen,KeySong)
		if SearchInCole then
			table.remove(Television.MusicInQueen,SearchInCole)
			if not IsClient then
				Television.Events:FindFirstChild('RemovedSong'):FireAllClients(Television.Model,KeySong)
			else
				Television.ChangeEvent:Fire('RemovedSong')
			end
		end
	end
end
function module:Skip(Player,Model)
	local Television = self:FindTV(Model)
	if not Television then Television = self:Added(Model) end
	if Television then
		if not IsClient then
			local HayUnaMusica = Television.Activekaraoke and Television.Activekaraoke.SongInProccess
			if HayUnaMusica then
				local IsListening = table.find(Television.listening, Player)
				if IsListening and typeof(Player) == 'Instance' and Player:IsA('Player') then
					local indexSkip = table.find(Television.skips, Player)
					if indexSkip then
						table.remove(Television.skips, indexSkip)
					else
						table.insert(Television.skips, Player)
						if Player == Television.Owner or #Television.skips >= #Television.listening - (Television.Owner and 1 or 0) then Television:Reproducir() end
					end
				end
				Television.Events:FindFirstChild('Skip'):FireAllClients(Television.skips, Television.Model)
			end
		else
			Television.skips = Player
			Television.ChangeEvent:Fire('Skip')
		end
	end
end

function reproducirOClose(self, listTelevisiones)
	if self then
		local EstaEscuchando = self.reproducirList and table.find(self.listening, LocalPlayer)
		if EstaEscuchando then
			self:StartKaraoke()
		else
			self:EndedKaraoke()
		end

	end
	
	if listTelevisiones then
		local NoEscuchar = {}

		for _, television in listTelevisiones do
			if #television.listening > 0 then
				if not table.find(television.listening, LocalPlayer) then
					for _, plr in television.listening do
						if not table.find(NoEscuchar, plr) then
							table.insert(NoEscuchar, plr)
						end
					end
				else
					for _, PlayerLisen in Players:GetPlayers() do
						local AudioDeviceInput:AudioDeviceInput = PlayerLisen ~= LocalPlayer and PlayerLisen:FindFirstChild("AudioDeviceInput")
						if AudioDeviceInput then
							AudioDeviceInput.Muted = not table.find(television.listening, PlayerLisen)
						end
					end
					return
				end
			end
		end

		for _, PlayerLisen in Players:GetPlayers() do
			local AudioDeviceInput:AudioDeviceInput = PlayerLisen ~= LocalPlayer and PlayerLisen:FindFirstChild("AudioDeviceInput")
			if AudioDeviceInput then
				AudioDeviceInput.Muted = not not table.find(NoEscuchar, PlayerLisen)
			end
		end
		
		if not PlayerAdded then
			PlayerAdded = Players.PlayerAdded:Connect(function(playerrrr)
				repeat task.wait(.01)
				until not playerrrr:IsDescendantOf(game) or playerrrr:FindFirstChild("AudioDeviceInput")
				if playerrrr:IsDescendantOf(game) then
					reproducirOClose(nil, listTelevisiones)
				end
			end)
		end
		
	end
end

function module:listening(Player,Model)
	local Television = self:FindTV(Model)
	if not Television then Television = self:Added(Model) end
	if Television then
		if IsClient then
			Television.listening = Player
			Television.ChangeEvent:Fire('listening')
			reproducirOClose(Television, self.Televisiones)
		end
	end
end
function module:reproducir(Player,Model)
	local Television = self:FindTV(Model)
	if not Television then Television = self:Added(Model) end
	if Television then
		if IsClient then
			Television.reproducirList = Player
			Television.ChangeEvent:Fire('reproducir')
			reproducirOClose(Television, self.Televisiones)
		end
	end
end

function module:init(Player, Model)
	local Television = self:FindTV(Model)
	if not Television then Television = self:Added(Model) end
	if Television then
		if IsClient then
			Television.listening = Player.listening or Television.listening
			Television.skips = Player.skips or Television.skips
			Television.MusicInQueen = Player.MusicInQueen or Television.MusicInQueen
			Television.Owner = Player.Owner or Television.Owner
			Television.reproducirList = Player.reproducirList or Television.reproducirList
			reproducirOClose(Television, self.Televisiones)
			Television.ChangeEvent:Fire('Alldata')
		else
			local reproducirList = Television.Activekaraoke and
				Television.Activekaraoke.SongInProccess and table.clone(Television.Activekaraoke.SongInProccess)
			if reproducirList then
				reproducirList.gui = Television.Activekaraoke.gui
				reproducirList.SearchLyric = nil
			end
			
			Television.Events:FindFirstChild('init'):FireClient(Player,{
				listening = Television.listening,
				skips = Television.skips,
				MusicInQueen = Television.MusicInQueen,
				Owner = Television.Owner,
				reproducirList = reproducirList,
			}, Television.Model)
			
		end
	end
end

return module