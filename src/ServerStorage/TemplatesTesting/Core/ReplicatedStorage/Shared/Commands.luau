local module = {}
module.__index = module

local IsClient = game:GetService('RunService'):IsClient()
local RS = game:GetService('ReplicatedStorage')
local Events = RS:WaitForChild('Events')

function module.new()
	local self = setmetatable({
		Event = Events.Other:WaitForChild('Commands'),
		TextChatS = game:GetService("TextChatService"),
		actives = {},
		Commands = {
			{
				text = {'crearcancion','create'},
				typee = 1,
			},
			{
				text = {'canciones','songs'},
				typee = 2,
			},
			{
				text = {'revisarcanciones','revisar'},
				typee = 3,
				IsWihAdmin = true,
			},
			{
				text = {'musicaspublicas',"publicsong"},
				typee = 4,
			},
			{
				text = {'reportes','report'},
				typee = 5,
				IsWihAdmin = true,
			},
			--//el 6 ya está reservado para seleccionar los diseños de las tiendas
			--//el 7 ya está reservado para el alquiler de las salas del karaoke
			--//el 8 ya está reservado para la compra de los diseños de las salas del karaoke
			--//el 9 ya está reservado para el uso de el bar
			{
				text = {'musicasbaneadas','banssongs'},
				typee = 10,
				IsWihAdmin = true,
				SuperAdmin = true,
			},
		}
	},module)
	
	return self
end

function module:Fire(...)
	if IsClient then
		self.Event:FireServer(...)
	else
		self.Event:FireClient(...)
	end
end

function module:SearchCommand(message,player:Player)
	if string.sub(message,1,1) == '/' then
		local NewText = string.sub(message,#message > 1 and 2 or 1,#message)
		for _,Commands in self.Commands do
			for _,Text in Commands.text do
				if NewText == Text then
					if not Commands.IsWihAdmin or self.AdminPanel:IsAdmin(player, Commands.SuperAdmin) then
						return Commands.typee
					end
				end
			end
		end
	end
end

function module:PlayerAdded(Player:Player)
	if Player and not self.actives[Player.UserId] then
		self.actives[Player.UserId] = Player.Chatted:Connect(function(message : string,receptor:Player)
			local typee = self:SearchCommand(message, (not receptor or receptor == Player) and Player)
			if typee and (not receptor or receptor == Player) then
				self:Fire(Player,typee)
			end
		end)
	end
end

function module:PlayerRemoving(Player:Player)
	if Player and self.actives[Player.UserId] then
		self.actives[Player.UserId]:Disconnect()
		self.actives[Player.UserId] = nil
	end
end

function module:Works()
	if IsClient then
		local TextChatCommands = self.TextChatS:WaitForChild('TextChatCommands')
		
		for _,Commands in self.Commands do
			if Commands.IsWihAdmin then continue end
			for index = 1,#Commands.text, 2 do
				local new = Instance.new('TextChatCommand')
				new.Name = 'Command_Karaoke'..index
				new.PrimaryAlias = '/'..Commands.text[index]
				new.SecondaryAlias = '/'..(Commands.text[index + 1] or Commands.text[index]..'Second')
				new.Parent = TextChatCommands
			end
		end
		
		self.TextChatS.OnIncomingMessage = function(message)
			if string.sub(message.Text,1,1) == '/' then
				local props = Instance.new("TextChatMessageProperties")
				props.Text = " "
				return props
			end 
		end
		
	else
		
		self.Event.OnServerEvent:Connect(function(Player:Player, number, option)
			if typeof(number)=="number" then
				self:Fire(Player, number, option)
			end
		end)
		
	end
end

return module.new()
