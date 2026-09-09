local StartServer = DateTime.now().UnixTimestampMillis
local donacion = {}

local RS = game:GetService('ReplicatedStorage')
local SS = game:GetService('ServerStorage')
local modules = RS:WaitForChild('Shared')
local Players = game:GetService('Players')

local GlobalDataStore = require(SS:WaitForChild("GlobalDataStore"))

local PlayerDataReplicator = require(SS:WaitForChild('WorldSystem'):WaitForChild('PlayerDataReplicator'))
local PlayerDataService = require(SS:WaitForChild('WorldSystem'):WaitForChild('PlayerDataService'))
local PlayerInit = require(RS:WaitForChild('PlayerInit'))
local Commands = require(modules:WaitForChild('Commands'))
local Karaoke = require(modules:WaitForChild('Karaoke'))
local AddItem = require(modules:WaitForChild('AddValues'))
local VerifyAtt = require(modules:WaitForChild('BreakDown'))
local MovingPlayers = require(modules:WaitForChild("MovingPlayers"))
local BartenderSystem = require(modules:WaitForChild("BartenderSystem"))

local Cobros = require(RS:WaitForChild('Client'):WaitForChild('EconomySystem'):WaitForChild('Collections'))

local ProcesosVentas = {}

local GuideService = require(modules:WaitForChild('GuideService'))

local PaintServer = require(modules:WaitForChild('Paint'):WaitForChild('ServerClient'))

local Tablero = require(modules:WaitForChild('ComprasTablero'))
Tablero.GlobalData = GlobalDataStore
Tablero.DataBase = PlayerDataReplicator

local Monetizacion = require(modules:WaitForChild('Monetization'))
Monetizacion.Cobros = Cobros
Monetizacion.AddItem = AddItem

local Stores = require(modules:WaitForChild('Stores'))
Stores.Cobros = Cobros

if Stores.Added then
	Stores.Added.Monetizacion = Monetizacion
end

Monetizacion.Stores = Stores
GlobalDataStore.VerifyAtt = VerifyAtt

Stores.comprasFunct.Monetizacion = Monetizacion
Stores.comprasFunct.ProcesosVentas = ProcesosVentas
Stores.comprasFunct.Cuadros = PaintServer
Stores.comprasFunct.GlobalData = GlobalDataStore

Stores.comprasFunct.PlayerDataService = PlayerDataService
Stores.comprasFunct.Profiles = require(SS:WaitForChild('WorldSystem'):WaitForChild('Profiles'))
Stores.comprasFunct.DataKit = require(SS:WaitForChild('DataKit'))

PaintServer.Cuadros = Stores.ComprasList

local Jobs = require(modules:WaitForChild("JobSystem"))
Jobs.Monetization = Monetizacion

local AgarreTool = require(modules:WaitForChild("ToolUseManagge"))

local RemoteNotification = RS:WaitForChild('Events'):WaitForChild('Player'):WaitForChild('ShowNotification')

Karaoke.KaraokeDS = GlobalDataStore
Karaoke.CrearCancion.AddItem = AddItem
Karaoke.CrearCancion.VerifyAtt = VerifyAtt

PlayerDataReplicator.KaraokeFactory = Karaoke.CrearCancion

Commands.AdminPanel = Karaoke
Karaoke.Commands = Commands

local NightClub = modules:FindFirstChild("NightClub")
if NightClub then
	NightClub = require(NightClub)
	NightClub.JobSyztem = Jobs
	local CollS = game:GetService("CollectionService")
	local TagNightclub = "NightClub"
	local Base = CollS:GetTagged(TagNightclub)[1]
	if not Base then
		local active
		active = CollS:GetInstanceAddedSignal(TagNightclub):Connect(function(...)
			NightClub = NightClub.new(...)
			active:Disconnect()
			active = nil
		end)
	else
		NightClub = NightClub.new(Base)
	end
end

local RequerestLoadedPlayer = {}
local LoadedCompleteEvent = RS:WaitForChild('Events'):WaitForChild('StartClientPlayer')

function PlayerIsLoaded(Player : Player)
	if typeof(PlayerDataReplicator.DataComplete[Player.UserId]) == "table" then
		LoadedCompleteEvent:FireClient(Player)
	else
		RequerestLoadedPlayer[Player] = true
	end
end

function PlayerAdded(Player : Player)
	if PlayerDataReplicator.DataComplete[Player.UserId] then return  end
	PlayerDataReplicator.DataComplete[Player.UserId] = 'no complete'

	PlayerDataService.load(Player):onDelivered():Connect(function(message)
		if typeof(message) ~= 'table' or message.kind ~= 'paintSold' then return end

		PaintServer:VentaRemota(Player, message)

		if message.sellerHere then return end

		local price = tonumber(message.price)
		if price and price > 0 then
			Cobros.Give(Player, {Sell = price}, true)
		end

		SentNotification(Player,"Sistema de cuadros",'Han comprado un cuadro tuyo.',5,
			2022095747,'rotate',
			8486683243)
	end)

	local list, errorMessage = PlayerDataReplicator.hydrate(Player)

	if not list then
		PlayerDataReplicator.DataComplete[Player.UserId] = nil
		Player:Kick('Error loading DataBase')
		return warn("Error cargando datos de " .. Player.Name .. ": " .. tostring(errorMessage))
	end

	local success, err = pcall(function()
		local perfilPaints = PlayerDataService.get(Player)
		perfilPaints = perfilPaints and perfilPaints:get().paints
		PaintServer:Load(Player, perfilPaints and table.clone(perfilPaints.keys) or {})
	end)

	if not success then
		PlayerDataReplicator.DataComplete[Player.UserId] = nil
		Player:Kick('Error loading DataBase')
		return warn("Error cargando cuadros de " .. Player.Name .. ": " .. tostring(err))
	end

	Commands:PlayerAdded(Player)
	list.Agarre = AgarreTool.new(Player)
	PlayerDataReplicator.DataComplete[Player.UserId] = list
	PlayerDataReplicator.markReady(Player)
	Karaoke.RevisarCanciones:AdminAdded(Player)
	Karaoke.TvKaraoke:UpdateMusicas()
	donacion.UpdateDonacion(Player)
	MovingPlayers:add(Player)

	PlayerIsLoaded(Player)
end

PlayerDataReplicator.setExitSequence(function(Player)
	Stores:ExitPlayer(Player)
	Monetizacion:PlayerRemoving(Player)
	Commands:PlayerRemoving(Player)
	Karaoke.RevisarCanciones:AdminRemoved(Player)
	Karaoke.TvKaraoke:UpdateMusicas()
	MovingPlayers:remove(Player)

	if NightClub then NightClub:Exit(Player) end

	local DataComplete = PlayerDataReplicator.DataComplete[Player.UserId]
	if typeof(DataComplete) == 'table' then
		PlayerDataReplicator.DataComplete[Player.UserId] = "Guardando"
		for _,v in DataComplete do
			if v.Exit then pcall(v.Exit, v, Player) end
		end
	end

	local paints = PaintServer:PlayerRemoving(Player)
	local store = PlayerDataService.get(Player)
	if store and store:canWrite() and typeof(paints) == 'table' then
		store:update(function(data)
			data.paints.keys = paints
			return data
		end)
	end

	return nil
end)

function PlayerRemoving(Player)
	RequerestLoadedPlayer[Player] = nil
	local DataComplete = PlayerDataReplicator.DataComplete[Player.UserId]
	
	if not DataComplete or table.find({"no complete", "Guardando"}, DataComplete) then return end
	
	PlayerDataReplicator.finalize(Player)

	PlayerDataReplicator.DataComplete[Player.UserId] = nil
end

function SentNotification(Player:Player,...)
	if typeof(Player) == 'Instance' and Player:IsA('Player') and Player:IsDescendantOf(game) then
		RemoteNotification:FireClient(Player,...)
	end
end

local SalvarBucle

function Init()
	
	BartenderSystem:init()
	Jobs.init(true)
	
	LoadedCompleteEvent.OnServerEvent:Connect(PlayerIsLoaded)

	Players.PlayerRemoving:Connect(PlayerRemoving)
	PlayerInit.Connect(PlayerAdded)

	game:BindToClose(function()
		Jobs.disabled()
		
		if Tablero.SpawnUpdateLeaderboard then
			task.cancel(Tablero.SpawnUpdateLeaderboard)
			Tablero.SpawnUpdateLeaderboard = nil
		end
		if SalvarBucle then task.cancel(SalvarBucle) end

		for _, Player in ipairs(Players:GetPlayers()) do
			task.spawn(PlayerRemoving, Player)
		end
		
		local SearchPalabras = GlobalDataStore.DataPalabras.SpawnFunct
		if SearchPalabras then
			task.cancel(SearchPalabras)
		end

		GlobalDataStore.PalabrasFunc.RecuperarPalabrasClave(GlobalDataStore)
		
		local function CountDatasCompletes()
			local Count = 0
			for UserId, process in PlayerDataReplicator.DataComplete do
				if process and process ~= "no complete" then
					Count += 1
				end
			end
			return Count
		end
		
		local timeout = tick()
		while CountDatasCompletes() > 0 and tick()-timeout < 30 do
			task.wait(.5)
		end
		
		
		warn("se cerró el servidor...")
	end)

	SalvarBucle = task.spawn(function()
		while true do
			-- Podrías añadir un AutoSave aquí si quisieras
			GlobalDataStore.PalabrasFunc.SalvarPalabrasClave(GlobalDataStore)
			GlobalDataStore.PalabrasFunc.ClearCache(GlobalDataStore)
			
			task.wait(60 * 5)
		end
	end)
end

GlobalDataStore.DataBase = PlayerDataReplicator
GlobalDataStore:SetSections()

Karaoke.RevisarCanciones.SentNotification = SentNotification
Stores.SentNotification = SentNotification

Karaoke.TvKaraoke.Running = require(modules:WaitForChild('Running'))
Karaoke:Works()

PaintServer.DataBase = GlobalDataStore
PaintServer.SentNotification = SentNotification

Commands:Works()

function Monetizacion:VerifyVentasPlayer(Comprador:Player,ID,Was)
	local data = ProcesosVentas[Comprador.UserId]

	if data then
		local Object = data.Objeto
		data.Objeto = nil

		if Was then
			local Vendedor = Players:GetPlayerByUserId(data.VendedorId and data.VendedorId.UserId or 0)

			Tablero:AddCompras(data)

			warn('['..Comprador.Name..' has purchased an item for '..tostring(data.PriceInRobux)..'RBX from '..data.VendedorId.Name..']')

			SentNotification(Comprador,"Server",'Has comprado este producto',5,
				2022095747,'rotate',
				8486683243)
			SentNotification(Vendedor,"Server",'Te han comprado un cuadro',5,
				2022095747,'rotate',
				8486683243)

			Cobros.Give(Comprador,{Buy = data.PriceInRobux}, true)
			Cobros.Give(Vendedor,{Sell = data.PriceInRobux}, true)
		else

			SentNotification(Comprador,"Server",'cancelaste la compra',5,
				2022095747,'rotate',
				8486683243)

		end

		Object:ClosePurchased(Was)

	elseif Comprador:IsDescendantOf(game) then
		
		warn('se compro un producto que no esta registrado.')
		
	else
		for _,dataVenta in ProcesosVentas do
			if dataVenta.VendedorId and dataVenta.VendedorId.UserId==Comprador.UserId then
				SentNotification(dataVenta.Objeto.IsInUse,"Server",'El jugador acaba de abandonar el juego, hay mucho riesgo al comprar si el jugador no esta en el servidor.',5,
					2022095747,'rotate',
					8486683243)
			end
		end
	end

	ProcesosVentas[Comprador.UserId] = nil
end

------------------//Sistema de donacion de dinero
local UpdateTime = 24*60*60--//24 horas
local MaxAmountSend = 1000

function donacion.GetElapsedTime(ElapsedTime)
	local now = DateTime.now().UnixTimestampMillis
	ElapsedTime = tonumber(ElapsedTime) or now
	return (now - ElapsedTime) / 1000
end
function donacion.UpdateDonacion(Player: Player)
	local Cash = Player:FindFirstChild("leaderstats"):FindFirstChild("Coins")
	if not Cash:GetAttribute("ElapsedTime") or donacion.GetElapsedTime(Cash:GetAttribute("ElapsedTime")) >= UpdateTime then
		Cash:SetAttribute("ElapsedTime", tostring(DateTime.now().UnixTimestampMillis))
		Cash:SetAttribute("AmountSending", tostring(0))
	end
end
function donacion.GetState(Player:Player, Cantidad)
	donacion.UpdateDonacion(Player)
	local Cash = Player:FindFirstChild("leaderstats"):FindFirstChild("Coins")
	local SumaTotal = (tonumber(Cash:GetAttribute("AmountSending")) or 0) + Cantidad
	return SumaTotal <= MaxAmountSend
end
function donacion.Quitar(Player:Player, Cantidad)
	if typeof(Cantidad)=="number" and Cantidad>0 then
		donacion.UpdateDonacion(Player)
		Cantidad = math.round(Cantidad)
		local Cash = Player:FindFirstChild("leaderstats"):FindFirstChild("Coins")
		local SumaTotal = (tonumber(Cash:GetAttribute("AmountSending")) or 0) + Cantidad
		if SumaTotal <= MaxAmountSend and Cobros.charge(Player, {Coins = Cantidad}, true) then
			Cash:SetAttribute("AmountSending", tostring(SumaTotal))
			return true
		end
	end
end
function donacion.Donar(Player:Player, Receptor : Player, Cantidad)
	if typeof(Cantidad)=="number" and Cantidad>0
		and typeof(Receptor)=="Instance" and Receptor:IsA("Player") and Receptor:IsDescendantOf(game) then
		Cantidad = math.round(Cantidad)
		local Cash = Player:FindFirstChild("leaderstats"):FindFirstChild("Coins")
		local CashReceptor = Player:FindFirstChild("leaderstats"):FindFirstChild("Coins")
		donacion.UpdateDonacion(Player)
		local SumaTotal = (tonumber(Cash:GetAttribute("AmountSending")) or 0) + Cantidad
		if SumaTotal <= MaxAmountSend and Cobros.charge(Player, {Coins = Cantidad}, true) then
			Cobros.Give(Receptor, {Coins = Cantidad}, true)
			Cash:SetAttribute("AmountSending", tostring(SumaTotal))
			SentNotification(Player,"Server",`Has donado ${Cantidad} al jugador {Receptor.DisplayName}`,5,
				2022095747,'rotate',
				8486683243)
			SentNotification(Receptor,"Server",`El jugador {Player.DisplayName} te ha donado ${Cantidad}`,5,
				2022095747,'rotate',
				8486683243)
			return
		end
	end
	SentNotification(Player,"Server",`Upss, Hubo un error al momento de la transacción`,5,
		2022095747,'rotate',
		8486683243)
end

RS:WaitForChild("Events"):WaitForChild("DonarCoins").OnServerEvent:Connect(donacion.Donar)
Stores.donacion = donacion
-------------------------------

Init()