local module = {}
module.__index = module

local RunS = game:GetService('RunService')

local IsClient = RunS:IsClient()
local Player:Player = IsClient and game:GetService('Players').LocalPlayer or nil

function module.new(model : Model)
	local self = setmetatable({
		Tag = 'PlantillaExample',
		model = model,
		WhiteList = {"trabajar", "renunciar"},
	},module)
	
	return self
end

function module:finished()
	if IsClient then
		if self.Occupant then
			self.Occupant = false
			self:MarkUse()
		end
	elseif self.Occupant[Player] then

		local Occupant = self.Occupant[Player]
		self.Occupant[Player] = nil

		Occupant.BindableEvent:Fire()
		Occupant.BindableEvent:Destroy()
		self.disconnect.All(Occupant.actives)
		

		if Player:IsDescendantOf(game) then
			self.Event:FireClient(Player,self.model,'renunciar',true)
		end
		
	end
end

function module:trabajar(Player2:Player)
	if IsClient then
		if not self:IsUse() and not self.Occupant then
			if not Player then
				self.Event:FireServer(self.model,'trabajar')
			else
				self.Occupant = true
				self:MarkUse()
			end
		end
	elseif not self.Occupant and Player2 and not self.UsosPlayer[Player2] then
		
		local Character:Model,Humanoid:Humanoid = self:GetCharacter(Player2)
		
		if Character and Humanoid then
			
			local list = {
				Player = Player2,
				Character = Character,
				Humanoid = Humanoid,
				BindableEvent = self.EventCustom.new(),
				actives = {}
			}

			self.Occupant = list

			return list.BindableEvent
			
		end
		
	end
end

function module:renunciar(Player : Player)
	if not IsClient or Player then
		self:finished(Player)
	elseif self.Occupant then
		if not self.actives then
			self:finished()
		else
			self.Event:FireServer(self.model,'renunciar')
		end
	end
end

function module:enabled()
	if self.actives then return end
	self.actives = {}
end

function module:disabled()
	if not self.actives then return end
	self.actives = self.disconnect.All(self.actives)
end

return module
