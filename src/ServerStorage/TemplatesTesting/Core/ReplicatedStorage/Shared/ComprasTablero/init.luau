local module = {}
module.__index = module

local Client = game:GetService('RunService'):IsClient()
local Players = game:GetService('Players')
local GroupS = game:GetService('GroupService')
local TextChatService = game:GetService("TextChatService")
local CollS = game:GetService('CollectionService')

export type DataVenta = {
	Creator : {
		CreatorType : string,
		Name : string,
		CreatorTargetId : number,
	},
	PriceInRobux : number,
}

export type MessageServers = {
	Data : {
		PlayerId : {
			UserId : number,
			Name : string,
		},
		
		VendedorId : {
			UserId : number,
			Name : string,
			Type : string,
		},
		
		data : DataVenta,
	},
	
	Sent : number,
}

export type LifeGuis = {
	Life : number,
	Start : number,
	Gui : GuiBase,
}

function module.new()
	local self = setmetatable({
		ComprasGUI = "CompraTableroGUI",
		TopBuyers = "TopBuyersGUI",
		TopSellers = "TopSellersGUI",
		
		Running = require(script.Parent:WaitForChild('Running')),
		Event = script:WaitForChild('Signal'),
		LeaderSignal = script:WaitForChild('Leaderboard'),
		messageService = game:GetService('MessagingService'),
		Settings = require(script:WaitForChild('Settings')),
		Guis = {},
		AnimationsInProcces = {},
		UpdateUpdatePlayer = {},
		MaxDonadores = 100,
		TextCS = game:GetService('TextService'),
	},module)
	
	self.PlaceId_PlsDonate = 82871403803520
	self:Works()
	
	return self
end

--------------------// Donaciones en vivo
function module:FormatNumer(num)
	local numStr = tostring(num)
	local isNegative = numStr:sub(1, 1) == "-"
	if isNegative then
		numStr = numStr:sub(2)
	end
	local dotIndex = numStr:find("%.")
	local intPart = dotIndex and numStr:sub(1, dotIndex - 1) or numStr
	local decimalPart = dotIndex and numStr:sub(dotIndex) or ""
	local formatted = ""
	local count = 0
	for i = #intPart, 1, -1 do
		count = count + 1
		formatted = intPart:sub(i, i) .. formatted
		if count % 3 == 0 and i > 1 then
			formatted = "," .. formatted
		end
	end
	if isNegative then
		formatted = "-" .. formatted
	end
	return formatted .. decimalPart
end

function module:CreateRunning()
	if not Client or game.PlaceId ~= self.PlaceId_PlsDonate then return end
	self.RunningAction = self.RunningAction or self.Running:AddFunct(function()
		local IsInLife
		
		for _,Gui:LifeGuis in self.Guis do
			
			local ElapsedTime = Gui.Life and (tick()-Gui.Start)/Gui.Life or 1
			Gui.Gui.Bar.Line.Size = UDim2.fromScale(1-ElapsedTime,1)

			if ElapsedTime >= 1 then
				Gui.Index = #self.Settings.Colors
			else
				IsInLife = true
			end
			
			Gui.Gui.Bar.Visible = ElapsedTime < 1
		end
		
		if not IsInLife then
			self.Running:ElimineFunct(self.RunningAction)
			self.RunningAction = nil
		end
		
	end)
end
function module:VerifyMax()
	table.sort(self.Guis, function(a,b)
		if a.Index == b.Index then
			return tick()-a.Start < tick()-b.Start
		else
			return a.Index < b.Index
		end
	end)
	
	for index,Value in self.Guis do
		if index == 1 and #self.Guis >= self.MaxDonadores then
			Value.Gui:Destroy()
			table.remove(self.Guis, table.find(self.Guis, Value))
		else
			Value.Gui.LayoutOrder = index
		end
	end

	local Frame = CollS:GetTagged(self.ComprasGUI)[1]
	Frame = Frame and Frame:FindFirstChild('NoMoney')
	if Frame then
		Frame.Visible = #self.Guis <= 0
	end
end

function module:AddProfile(UserId:number, Image:ImageLabel)
	if not UserId or not Image then return end
	if UserId.Type == 'User' then
		Image.Image = Players:GetUserThumbnailAsync(
			UserId.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)
	elseif UserId.Type == 'Group' then
		Image.Image = GroupS:GetGroupInfoAsync(UserId.UserId).EmblemUrl
	end
end
function module:AddedDataInGui(Data:Player,tag:Folder)
	if not Data or not tag then return end
	pcall(function() self:AddProfile(Data,tag.Icon) end)
	tag.NamePlayer.Text = Data.Name
end
function module:Color(Price)
	Price = tonumber(Price) or 0
	for i,v in self.Settings.Colors do
		if Price >= v.MayorA then
			return i,v
		end
	end
end

function module:AddCompras(Data : MessageServers, isMessageServers)
	if Client then
		local Parent = CollS:GetTagged(self.ComprasGUI)[1]
		if not Parent then return end
		local Estadistica = Data.Data
		local price = tonumber(Estadistica.PriceInRobux) or 0
		local index,dataGui = self:Color(price)
		local clone = script:WaitForChild('Template'):Clone()
		local text = self:FormatNumer(price)
		local Size = self.TextCS:GetTextSize(text,
			clone.PriceText.AbsoluteSize.Y,
			clone.PriceText.AmounRobux.Font,
			Vector2.new(math.huge,math.huge)).X
		clone.PriceText.Size = UDim2.fromOffset(Size, clone.PriceText.AbsoluteSize.Y)
		clone.PriceText.AmounRobux.Text = text
		clone.PriceText.AmounRobux.TextColor3 = dataGui.Color
		clone.PriceText.RobuxIcon.ImageColor3 = dataGui.Color
		clone.Bar.Line.BackgroundColor3 = dataGui.Color
		self:AddedDataInGui(Estadistica.PlayerId, clone.Comprador)
		self:AddedDataInGui(Estadistica.VendedorId, clone.Vendedor)
		local ListLife = {
			Life = self.Settings.TimeLife[index],
			Start = tick(),
			Gui = clone,
			Index = index,
		}
		clone.Parent = Parent
		table.insert(self.Guis, ListLife)
		self:VerifyMax()
		self:CreateRunning()
	elseif game.PlaceId == self.PlaceId_PlsDonate then
		if isMessageServers then
			self.Event:FireAllClients(Data, 'Products')
		else
			self.messageService:PublishAsync("Products",Data)
		end
	end
end

function module:Descomprimir(Data, Tag)
	if not Data or not Tag then return end
	if Tag == 'Products' then
		self:AddCompras(Data,true)
	end
end
--------------------// Conexion entre servidores
function module:SuscribeCall(Tag)
	if Client then return end
	task.spawn(function()
		self.messageService:SubscribeAsync(Tag, function(messaje) self:Descomprimir(messaje, Tag) end)
	end)
end
--------------------// Leaderboard global
function module:CreateGuiLeaderboard(List:{},index,Parent:ScrollingFrame)
	local clone = script:WaitForChild('TemplateLeaderboard'):Clone()
	clone.LayoutOrder = index
	clone.PositionText.Text = tostring(index):upper()
	clone.NamePlayer.Text = List.Name or ""
	clone.Icon.Image = List.Profile or ""
	clone.Amount.Text = self:FormatNumer(tonumber(List.Total) or 0)
	clone.Parent = Parent
	clone.Amount.IconRobux.Position = UDim2.new(1,-(clone.Amount.TextBounds.X + 1),.5,0)
end

function module:GetStat(Data,Name)
	Data = typeof(Data)=="table" and Data or {}
	Data = Data and Data.stats or {}
	for _,data2 in Data do
		if data2.Name == Name then
			return tonumber(data2.Value) or 0
		end
	end
	return 0
end
function module:SaveChangePlayer(Player:Player, Data)
	if Client or not Player then return end
	if not self.UpdateUpdatePlayer[Player] or tick()-self.UpdateUpdatePlayer[Player] >= 40 then
		self.UpdateUpdatePlayer[Player] = Player:IsDescendantOf(game) and tick() or nil
		Data = typeof(Data)=='table' and Data or (self.DataBase.Bye(Player) or {SaveAllStats = function() return {} end}):SaveAllStats()
		self.GlobalData:SetData("TopSellers", tostring(Player.UserId), self:GetStat(Data,"Sell"))
		self.GlobalData:SetData("TopBuyers", tostring(Player.UserId), self:GetStat(Data,"Buy"))
	elseif not Player:IsDescendantOf(game) then
		self.UpdateUpdatePlayer[Player] = nil
	end
end

function module:GetLeaderboard(index)
	if Client then return end
	local result = self.GlobalData:GetData(index,false,20,1)
	result = typeof(result)=='table' and result
	result = result and result.Data or {}
	local list = {}
	for _,Player in result do
		local success, name = pcall(function()
			return Players:GetNameFromUserIdAsync(tonumber(Player.key))
		end)
		table.insert(list,{
			Profile = Players:GetUserThumbnailAsync(tonumber(Player.key),Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100),
			Name = success and name or "Unknown",
			Total = tostring(Player.value),
		})
	end
	return list
end
function module:ClearChildUI(tag)
	for _,Scroll in CollS:GetTagged(tag or "no search") do
		if Scroll:FindFirstChild('List') then
			for _,v in Scroll:FindFirstChild('List'):GetChildren() do
				if v:IsA('GuiBase') then
					v:Destroy()
				end
			end
		end
	end
end
function module:UpdateLeaderboards(...)
	if game.PlaceId ~= self.PlaceId_PlsDonate then return end
	local parametro = {...}
	if not Client then
		self.SpawnUpdateLeaderboard = self.SpawnUpdateLeaderboard or task.spawn(function()
			while true do
				for _,Player:Player in Players:GetPlayers() do
					if self.DataBase.DataComplete[Player.UserId] then
						self:SaveChangePlayer(Player)
					end
				end
				local list = {}
				for index,value in {Buyings = "TopBuyers",Sellers ="TopSellers"} do
					list[index] = self:GetLeaderboard(value)
				end
				self.LeaderActual = list
				self.LeaderSignal:FireAllClients(self.LeaderActual)
				task.wait(60 * 3)
			end
		end)
		local Player:Player = parametro[1]
		if typeof(Player)=='Instance' and Player:IsA('Player') and Player:IsDescendantOf(game) then
			self.LeaderSignal:FireClient(Player,self.LeaderActual or {})
		else
			self.LeaderSignal:FireAllClients(self.LeaderActual or {})
		end
	else
		local Data = parametro[1]
		if typeof(Data) == 'table' then
			self:ClearChildUI(self.TopBuyers)
			self:ClearChildUI(self.TopSellers)
			
			local NoHayGui = true
			for index,data in Data.Buyings or {} do
				if (tonumber(data.Total) or 0) <= 0 then continue end
				NoHayGui = false
				for _,Scroll in CollS:GetTagged(self.TopBuyers) do
					if Scroll:FindFirstChild('List') then
						self:CreateGuiLeaderboard(data,index,Scroll:FindFirstChild("List"))
					end
				end
			end
			for _,Scroll in CollS:GetTagged(self.TopBuyers) do
				if Scroll:FindFirstChild('NoPlayers') then
					Scroll:FindFirstChild('NoPlayers').Visible = NoHayGui
				end
			end
			
			
			NoHayGui = true
			for index,data in Data.Sellers or {} do
				if (tonumber(data.Total) or 0) <= 0 then continue end
				NoHayGui = false
				for _,Scroll in CollS:GetTagged(self.TopSellers) do
					if Scroll:FindFirstChild('List') then
						self:CreateGuiLeaderboard(data,index,Scroll:FindFirstChild("List"))
					end
				end
			end
			for _,Scroll in CollS:GetTagged(self.TopSellers) do
				if Scroll:FindFirstChild('NoPlayers') then
					Scroll:FindFirstChild('NoPlayers').Visible = NoHayGui
				end
			end
			
		end
	end
end
--------------------// Mensajes (not found)
function module:SetMessage(Message)
	if not Client then
		script:FindFirstChild('Message'):FireAllClients(Message)
	elseif Message then
		local systemChannel : TextChannel = TextChatService.TextChannels:FindFirstChild("RBXSystem")
		if not systemChannel then return end
		systemChannel:DisplaySystemMessage(Message)
	end
end

function module:Works()
	if game.PlaceId ~= self.PlaceId_PlsDonate then return end
	local LeaderSignal = Client and self.LeaderSignal.OnClientEvent or self.LeaderSignal.OnServerEvent
	LeaderSignal:Connect(function(...) self:UpdateLeaderboards(...) end)
	
	if Client then
		self.Event.OnClientEvent:Connect(function(...) self:Descomprimir(...) end)
		--script:WaitForChild('Message').OnClientEvent:Connect(function(...) self:SetMessage(...) end)
		self.LeaderSignal:FireServer()
	else
		self:SuscribeCall('Products')
	end
end

return module.new()
