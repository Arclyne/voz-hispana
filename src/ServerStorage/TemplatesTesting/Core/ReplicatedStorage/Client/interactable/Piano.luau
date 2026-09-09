local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Interactable = require(script.Parent.Interactable)
local promptText = require(ReplicatedStorage.Shared.promptText)

local MUSICAL_GENRES = {
	Trap = {
		["Nombre canción"] = 1111,
	},
	Pop = {
		["Nombre canción"] = 1111,
	},
	["Electrónica"] = {
		["Nombre canción"] = 1111,
	},
	["90's"] = {
		["Nombre canción"] = 1111,
	},
}

local player = Players.LocalPlayer
local remotes = ReplicatedStorage.Events

local MusicPlayer = {}
MusicPlayer.__index = MusicPlayer

setmetatable(MusicPlayer, Interactable)

function MusicPlayer.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, MusicPlayer)

	self.model = model
	self.emitter = model.Emitter:FindFirstChildOfClass("Sound")
	self.wheel = self:getDefaultWheel()
	self.wheel:setQuickAction("Custom ID", self.playCustom, self)
	self.wheel.page:addAction("Custom ID", self.playCustom, self)
	
	for genre, ids in MUSICAL_GENRES do
		local genrePage = self.wheel:addPage(genre)
		for name, id in ids do
			genrePage:addAction(name, self.playSong, self, id)
		end
	end

	self:setAdornee(model.Prompt)
	self:setClickHitbox(model)

	return self
end

function MusicPlayer:playCustom()
	promptText("Ingrese una ID", "ID", function(text)
		local id = tonumber(text)
		if id then
			self:playSong(id)
		else
			print(`malformed number: {text}`)
		end
	end)
end

function MusicPlayer:playSong(id)
	remotes.Interactable.MusicPlayer:FireServer(self.model, id)
end

return MusicPlayer
