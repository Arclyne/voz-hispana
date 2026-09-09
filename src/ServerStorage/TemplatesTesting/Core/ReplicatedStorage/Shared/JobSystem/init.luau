local module = {}

local IsClient = game:GetService('RunService'):IsClient()
local LocalPlayer:Player = IsClient and game:GetService('Players').LocalPlayer or nil
local RS = game:GetService('ReplicatedStorage')
local Events = RS:WaitForChild('Events'):WaitForChild('Jobs')
local CollS = game:GetService('CollectionService')

local ClientFolder = RS:WaitForChild("Client")

local cobros = not IsClient and require(ClientFolder:WaitForChild("EconomySystem"):WaitForChild('Collections'))
local disconnect = require(ClientFolder:WaitForChild('Disconnects'))
local condicionales = require(script:WaitForChild('ConditionsUses'))
local debris = game:GetService('Debris')
local EventCustom = require(ClientFolder:WaitForChild("Event"))

local signalsGame = require(RS:WaitForChild("Shared"):WaitForChild("SignalsGame"))
local tagSignalJob = "JobsSystemSignal"

local UpdateStateJob = IsClient and Instance.new('BindableEvent', script) or nil

module.UsosPlayer = not IsClient and {}
module.StateJobChanged = UpdateStateJob and UpdateStateJob.Event or nil

module.modules = {
	BarraBartender = {
		module = require(script:WaitForChild('Bartender')),
		IsGroup = true,
		Instances = {},
	},
	ClearFloors = {
		module = require(script:WaitForChild('LimpiarPiso')),
		IsGroup = true,
		Instances = {},
	},
	CajasWork = {
		module = require(script:WaitForChild('CajasTransport')),
		IsGroup = true,
		Instances = {},
	},
	ButtonVipMoney = {
		module = require(script:WaitForChild("ButtonMoney")),
		Instances = {},
	}
}

function module.Get(tag)
	if typeof(tag) == "table" then
		for index, tagS in module.modules do
			if tagS == tag or tagS.Instances == tag then
				return tagS
			end
		end
	else
		return typeof(tag)=="string" and module.modules[tag]
	end
end

function module.SearchModel(tag,object)
	if typeof(tag) == 'table' then
		if typeof(object)=="Instance" then
			if module.Get(tag).IsGroup then
				for _,v in tag do
					if v.model == object then return v end
					if v.Group then
						for _, model in v.Group do
							if model == object then
								return v
							end
						end
					end
					break
				end
			else
				return tag[object]
			end
		elseif typeof(object) == "string" then
			for _,v in tag do if v.UniqueKey == object then return v end end
		end
	elseif typeof(tag)=="string" and module.modules[tag] then
		return module.SearchModel(module.modules[tag].Instances, object)
	end
end

function EliminarEspacios(Text:string)
	if typeof(Text) == 'string' and #Text > 0 then
		local EliminarEspacios = Text:match("^%s*(.-)%s*$")
		return #EliminarEspacios > 0 and EliminarEspacios
	end
end

function module.init(Empezar)
	if module.IsInit then return end
	module.IsInit = true
	
	for tag,value in module.modules do
		
		value.module.cobros = cobros
		value.module.disconnect = disconnect
		value.module.debris = debris
		value.module.UsosPlayer = not IsClient and module.UsosPlayer or nil
		value.module.Monetization = module.Monetization
		value.module.EventCustom = EventCustom
		value.module.signalsGame = signalsGame
		value.module.tagSignalJob = tagSignalJob
		
		function value.module:GetInfoInstance(Object, tagSearch)
			if Object == self.model then return self end
			if tagSearch then
				return module.SearchModel(tagSearch, Object)
			else
				for tagggggg,section in module.modules do
					local busqueda = module.SearchModel(section.Instances, Object)
					if busqueda then return busqueda end
				end
			end
		end
		
		function value.module:GetCharacter(Player2:Player)
			Player2 = Player2 or IsClient and LocalPlayer
			if typeof(Player2) == 'Instance' and Player2:IsA('Player') and Player2:IsDescendantOf(game) then
				local Character = Player2.Character
				local Humanoid : Humanoid = Character and Character:FindFirstChild('Humanoid')
				local verify = Humanoid and Humanoid.Health > 0 and Character
				return verify, verify and Humanoid
			end
		end

		function value.module:IsA(name)
			return name == tag
		end
		
		if IsClient then
			function value.module:MarkUse()
				if module.UsosPlayer and module.UsosPlayer ~= self then return end
				local LastState = not not module.UsosPlayer
				module.UsosPlayer = self.Occupant and self
				if LastState ~= not not module.UsosPlayer then UpdateStateJob:Fire() end
			end
			function value.module:IsUse()
				return module.UsosPlayer
			end
			function value.module:IsWork()
				return module.UsosPlayer == self
			end
		end
		
		function value.module:Fire(...)
			if IsClient then
				self.Event:FireServer(...)
			else
				local plr = ({...})[1]
				if plr and typeof(plr) == "Instance" and plr:IsA("Player") then
					self.Event:FireClient(...)
				else
					self.Event:FireAllClients(...)
				end
			end
		end
		
		local Event : RemoteEvent
		
		if IsClient then
			Event = Events:WaitForChild(tag..'Event')
		else
			Event = Instance.new('RemoteEvent')
			Event.Name = tag..'Event'
			Event.Parent = Events
		end
		
		local OnEvent = IsClient and Event.OnClientEvent or Event.OnServerEvent

		local function remove(modelo)
			local metadata = modelo and value.Instances[modelo]
			if metadata then
				value.Instances[modelo] = nil
				if metadata.destroy then
					metadata:destroy(modelo)
				else
					metadata:disabled()
					table.clear(metadata)
				end
			end
		end
		
		local function add(modelo)
			if not modelo or value.Instances[modelo] then return end
			local instancee = value.module.new(modelo)
			if instancee then
				instancee.Event = Event
				value.Instances[modelo] = instancee
				if module.IsEnabled then instancee:enabled() end
			end
		end
		
		for _,modelo in CollS:GetTagged(tag) do add(modelo) end
		
		CollS:GetInstanceAddedSignal(tag):Connect(function(modelo)
			if not module.SearchModel(value.Instances, modelo) then
				add(modelo)
			end
		end)
		CollS:GetInstanceRemovedSignal(tag):Connect(remove)
		
		local function Interaccion(Player:Player, Object:Model,Key,...)
			local Parametros = {...}
			table.insert(Parametros,1,not IsClient and Player or Key)
			Key = IsClient and Object or Key
			Object = IsClient and Player or Object
			
			local getMetatable = module.SearchModel(value.Instances, Object)

			if not getMetatable then
				return warn('model not found.')
			elseif typeof(Key) ~= "string" then
				return warn("key is not string")
			end

			if getMetatable.actives then

				local funcionn = getMetatable[Key]

				if typeof(funcionn) == "function" then

					if not table.find(getMetatable.WhiteList,Key) then
						if not IsClient then
							Player:Kick("Exploiter detected.")
						end
						return warn("no se permite esta funcion")
					end

					local condicionalTag = string.split(getMetatable.model:GetAttribute('conditional') or 'NoConditional',",")
					for _,condicional in condicionalTag do
						local modifi = EliminarEspacios(condicional)
						if modifi then
							if not condicionales[string.format("%s_%s",modifi,Key)](getMetatable, Player) then return warn(modifi) end
						end
					end
					
					local DoneEvent:RBXScriptSignal, SentMessageClient, unpackAction  = funcionn(getMetatable,table.unpack(Parametros))

					if not IsClient and DoneEvent then
						Event:FireClient(Player,Object,Key,unpackAction and typeof(SentMessageClient)=="table" and table.unpack(SentMessageClient) or SentMessageClient or true)
						local LastTrabajo = module.UsosPlayer[Player]
						local EventActive : RBXScriptConnection
						EventActive = DoneEvent:Connect(function()
							EventActive = disconnect.Disconnect(EventActive)
							if module.UsosPlayer[Player] == getMetatable then
								module.UsosPlayer[Player] = nil
							end
						end)
						module.UsosPlayer[Player] = getMetatable
						if LastTrabajo then LastTrabajo:renunciar(Player) end
					end
				else
					
					warn("no es una funcion")
					
				end
			else
				
				warn("no está activo")
				
			end
		end
		
		OnEvent:Connect(Interaccion)
		
		if not IsClient then
			value.ServerEvent = Instance.new("BindableFunction")
			value.ServerEvent.OnInvoke = Interaccion
		end
		
	end
	
	if Empezar then
		module.enabled()
	end
	
end

function module.enabled()
	if module.IsEnabled then return end
	module.IsEnabled = true
	
	for tag,value in module.modules do
		for _,metatable in value.Instances do
			metatable:enabled()
		end
	end
	
end

function module.disabled()
	if not module.IsEnabled then return end
	module.IsEnabled = false
	
	for tag,value in module.modules do
		for _,metatable in value.Instances do
			metatable:disabled()
		end
	end
end

return module