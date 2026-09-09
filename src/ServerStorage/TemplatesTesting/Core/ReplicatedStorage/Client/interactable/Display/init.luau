local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)
local VideoPlayer = require(script.VideoPlayer)
local Videos = require(script.Videos)
local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))

local function tblValues<K, T>(tbl: { [K]: T }): { T }
	local values = {}
	for _, v in tbl do
		table.insert(values, v)
	end
	return values
end

local function getVideoSequence(name: string): { string }
	local video = Videos.YouBlox
	if Videos.Movies[name] then
		video = Videos.Movies[name]
	elseif Videos.Series[name] then
		video = Videos.Series[name]
	end
	return video
end

local remotes = ReplicatedStorage.Events

local Display = {}
Display.__index = Display
setmetatable(Display, Interactable)

function Display.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, Display)

	local screen = model:WaitForChild("Screen")

	self.player = VideoPlayer.new(screen:FindFirstChildOfClass("SurfaceGui"))
	self.player:preload(Videos.YouBlox)
	self.player:preloadArray(tblValues(Videos.Movies))
	self.player:preloadArray(tblValues(Videos.Series))

	self.model = model
	self.wheel = self:getDefaultWheel()
	
	self:setAdornee(model:WaitForChild("Prompt"))
	self:setClickHitbox(model)
	
	model.AttributeChanged:Connect(function(Attribute)
		if Attribute == 'Video' then
			self:_play()
		elseif Attribute == 'On' then
			if model:GetAttribute("On") then
				self:_on()
			else
				self:_off()
			end
		elseif Attribute == 'Karaoke' then
			self:_Karaoke()
		elseif Attribute == "PrivateTV" then
			self:Initttt()
		end
	end)

	if model:GetAttribute("On") then
		self:_on()
	end
	if model:GetAttribute("PrivateTV")~=nil then
		self:Initttt()
	end

	remotes.Interactable.Display:FireServer(self.model, 'AgregarAKaraoke')
	
	return self
end

function Display:Initttt()
	self.wheel:removePage("Películas")
	self.wheel:removePage("Series")
	self.wheel.page:removeAction("Encender")
	self.wheel.page:removeAction("Apagar")
	self.wheel.page:removeAction("YouBlox")
	if self.model:GetAttribute('PrivateTV') then
		self.wheel:setQuickAction("KARAOKE", self.Karaoke, self)
	else
		self.wheel:setQuickAction("Encender", self.on, self)
		self.wheel.page:addAction("Encender", self.on, self)
		self.wheel.page:addAction("YouBlox", self.play, self, "YouBlox")
		local moviesPage = self.wheel:addPage("Películas")
		for name in Videos.Movies do
			moviesPage:addAction(name, self.play, self, name)
		end
		local seriesPage = self.wheel:addPage("Series")
		for name in Videos.Series do
			seriesPage:addAction(name, self.play, self, name)
		end
	end
	self.wheel.page:addAction("KARAOKE", self.Karaoke, self)
end

function Display:_play()
	local video = getVideoSequence(self.model:GetAttribute("Video"))
	if video and not self.model:GetAttribute('Karaoke') then
		self.player:play(video)
	end
end

function Display:_on()
	if self.model:GetAttribute('Karaoke') or self.model:GetAttribute('PrivateTV') then return end
	self.wheel:setQuickAction("Apagar", self.off, self)
	self.wheel.page:addAction("Apagar", self.off, self)
	self.wheel.page:removeAction("Encender")
	if self.player.current then
		self.player:resume()
		self.player:show()
		SoundManager:Play(nil, 139464282770830, { Volume = 1 }, self.model)
	else
		self:_play()
	end
end

function Display:_off()
	if self.model:GetAttribute('Karaoke') or self.model:GetAttribute('PrivateTV') then return end
	self.wheel:setQuickAction("Encender", self.on, self)
	self.wheel.page:addAction("Encender", self.on, self)
	self.wheel.page:removeAction("Apagar")
	self.player:pause()
	self.player:hide()
	SoundManager:Play(nil, 139464282770830, { Volume = 1 }, self.model)
end

function Display:_Karaoke()
	if self.model:GetAttribute('Karaoke') then
		self.wheel.page:removeAction("Encender")
		self.wheel.page:removeAction("Apagar")
		self.player:pause()
		self.player:hide()
	elseif self.model:GetAttribute("On") then
		self:_on()
	else
		self:_off()
	end
end

function Display:play(name: string)
	if self.model:GetAttribute('Karaoke') or self.model:GetAttribute('PrivateTV') then return end
	remotes.Interactable.Display:FireServer(self.model, name)
	self.model:SetAttribute("Video", name)
	self.model:SetAttribute("On", true)
end

function Display:on()
	if self.model:GetAttribute('Karaoke') or self.model:GetAttribute('PrivateTV') then return end
	remotes.Interactable.Display:FireServer(self.model, true)
	self.model:SetAttribute("On", true)
end

function Display:off()
	if self.model:GetAttribute('Karaoke') or self.model:GetAttribute('PrivateTV') then return end
	remotes.Interactable.Display:FireServer(self.model, false)
	self.model:SetAttribute("On", false)
end

function Display:Karaoke()
	remotes.Interactable.Display:FireServer(self.model, 'KARAOKE')
end

return Display
