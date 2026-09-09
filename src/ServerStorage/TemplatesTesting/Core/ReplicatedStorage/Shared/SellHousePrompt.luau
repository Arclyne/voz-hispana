--[[
	SellHousePrompt — modal de confirmación para vender una casa.

	Muestra una proforma con el desglose (valor original, comisión, pérdida por
	segunda mano) y el neto que recibe el jugador.

		local SellHousePrompt = require(ReplicatedStorage.Shared.SellHousePrompt)

		SellHousePrompt.open({
			houseName = "playaRoom",
			displayName = "Casa de Playa",
			image = "rbxassetid://...",
			price = 4000,
			currency = "Coins",
		}, function()
			-- el jugador confirmó
		 end)

	El aspecto vive en la plantilla `ReplicatedStorage.Assets.UI.SellHousePrompt`,
	no aquí: se puede restilar entera en el editor mientras se mantengan los
	nombres (Card, Head.HouseImage.NameText, Ticket.Rows.*, Ticket.Total,
	Actions.CancelButton / ConfirmButton).

	Los porcentajes salen de `GeneralConfiguration.HouseSale`. `quote()` es la
	misma cuenta que tendrá que hacer el servidor al confirmar la venta, así que
	es pública a propósito: el cliente no debe ser quien decide cuánto se paga,
	pero sí debe enseñar exactamente lo mismo.
]]

local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = script.Parent

local Kinetic = require(ReplicatedStorage:WaitForChild("Kinetic"))
local GeneralConfiguration = require(ReplicatedStorage:WaitForChild("GeneralConfiguration"))
local InfoCoins = require(Shared:WaitForChild("InfoCoins"))

local CANCEL_ACTION = "SellHousePromptCancel"

-- Si `GeneralConfiguration.HouseSale` no existe todavía, estos son los valores
-- que se anuncian en la propia UI.
local DEFAULT_COMMISSION = 0.05
local DEFAULT_SECOND_HAND = 0.15

local OPEN_SPRING = { tension = 260, friction = 20 }
local CLOSE_SPRING = { tension = 300, friction = 30 }

local SOUND_OPEN = 122948856683895
local SOUND_CLICK = 139037694620957

local SellHousePrompt = {}

export type Quote = {
	original: number,
	commission: number,
	secondHand: number,
	payout: number,
	commissionRate: number,
	secondHandRate: number,
}

export type Options = {
	houseName: string?,
	displayName: string?,
	image: string?,
	price: number?,
	currency: string?,
}

-- Sólo puede haber un modal abierto a la vez.
local active: any = nil

local function comma(value: number): string
	local text = tostring(math.floor(math.abs(value)))
	while true do
		local replaced: number
		text, replaced = text:gsub("^(%d+)(%d%d%d)", "%1,%2")
		if replaced == 0 then break end
	end
	return (value < 0 and "-" or "") .. text
end

local function percent(rate: number): string
	return ("%g%%"):format(rate * 100)
end

--[[
	Desglose de la venta. Las dos deducciones se calculan sobre el valor original
	y se redondean; el neto es la resta, así que el ticket siempre cuadra aunque
	los porcentajes den decimales.
]]
function SellHousePrompt.quote(price: number?): Quote
	local config: any = GeneralConfiguration.HouseSale or {}
	local commissionRate = tonumber(config.CommissionRate) or DEFAULT_COMMISSION
	local secondHandRate = tonumber(config.SecondHandRate) or DEFAULT_SECOND_HAND

	local original = math.max(0, math.floor(tonumber(price) or 0))
	local commission = math.floor(original * commissionRate + 0.5)
	local secondHand = math.floor(original * secondHandRate + 0.5)
	local payout = math.max(0, original - commission - secondHand)

	return {
		original = original,
		commission = commission,
		secondHand = secondHand,
		payout = payout,
		commissionRate = commissionRate,
		secondHandRate = secondHandRate,
	}
end

local function playSound(soundId: number, volume: number)
	-- SoundManager es opcional a propósito: si falta, el modal sigue funcionando.
	local ok, SoundManager = pcall(function()
		return require(Shared:WaitForChild("SoundManager", 5))
	end)
	if not ok or not SoundManager then return end
	pcall(function()
		SoundManager:Play(Players.LocalPlayer, soundId, { Volume = volume })
	end)
end

local function bindMotion(button: GuiButton)
	local ok, ButtonMotion = pcall(function()
		return require(Shared:WaitForChild("ButtonMotion", 5))
	end)
	if ok and ButtonMotion then
		pcall(ButtonMotion.bind, button)
	end
end

local function finish(confirmed: boolean)
	local state = active
	if not state then return end
	active = nil

	ContextActionService:UnbindAction(CANCEL_ACTION)
	for _, connection in state.connections do
		connection:Disconnect()
	end
	table.clear(state.connections)

	if state.gui.Parent then
		state.scaleMotion:start({ Scale = 0.92, config = CLOSE_SPRING })
		state.dimMotion:start({ BackgroundTransparency = 1, config = CLOSE_SPRING })
		state.cardMotion
			:start({ Position = state.restPosition + UDim2.fromScale(0, 0.03), config = CLOSE_SPRING })
			:andThen(function()
				state.gui:Destroy()
			 end)
		-- Red de seguridad: si el resorte no llega a reposo (pausas, respawn), el
		-- ScreenGui no se queda colgado encima de la pantalla.
		Debris:AddItem(state.gui, 2)
	end

	if confirmed and state.onConfirm then
		task.spawn(state.onConfirm, state.quote)
	end
end

--[[
	Cierra el modal sin confirmar. Seguro de llamar aunque no haya nada abierto.
]]
function SellHousePrompt.close()
	finish(false)
end

--[[
	¿Hay un modal abierto ahora mismo?
]]
function SellHousePrompt.isOpen(): boolean
	return active ~= nil
end

function SellHousePrompt.open(options: Options, onConfirm: ((quote: Quote) -> ())?): boolean
	if active then return false end

	local player = Players.LocalPlayer
	local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return false end

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local uiFolder = assets and assets:FindFirstChild("UI")
	local template = uiFolder and uiFolder:FindFirstChild("SellHousePrompt")
	if not template then
		warn("[SellHousePrompt] falta la plantilla ReplicatedStorage.Assets.UI.SellHousePrompt")
		return false
	end

	local quote = SellHousePrompt.quote(options.price)

	local gui = template:Clone()
	local card = gui.Card
	local dim = gui.Dim
	local ticket = card.Ticket
	local rows = ticket.Rows

	-- Cabecera
	local image = card.Head.HouseImage
	if options.image then
		image.Image = options.image
	end
	image.NameText.Text = options.displayName or options.houseName or ""

	-- Proforma. Las etiquetas llevan el porcentaje real, no el de la plantilla.
	rows.Original.Value.Text = comma(quote.original)
	rows.Commission.Label.Text = ("Comisión de venta (%s)"):format(percent(quote.commissionRate))
	rows.Commission.Value.Text = quote.commission > 0 and ("-%s"):format(comma(quote.commission)) or "0"
	rows.SecondHand.Label.Text = ("Pérdida de valor 2ª mano (%s)"):format(percent(quote.secondHandRate))
	rows.SecondHand.Value.Text = quote.secondHand > 0 and ("-%s"):format(comma(quote.secondHand)) or "0"

	ticket.Total.Right.Amount.Text = comma(quote.payout)

	local coin = InfoCoins[options.currency or "Coins"]
	if coin then
		ticket.Total.Right.Icon.Image = coin.Icon
		ticket.Total.Right.Amount.TextColor3 = coin.Color
	end

	-- Estado de reposo leído de la plantilla ANTES de pisarlo, para que restilar
	-- la tarjeta en el editor cambie también el destino de la animación.
	local restPosition = card.Position
	local restDim = dim.BackgroundTransparency
	local scale = card:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", card)

	scale.Scale = 0.88
	card.Position = restPosition + UDim2.fromScale(0, 0.035)
	dim.BackgroundTransparency = 1

	gui.Parent = playerGui

	local connections = {}

	active = {
		gui = gui,
		card = card,
		dim = dim,
		quote = quote,
		onConfirm = onConfirm,
		restPosition = restPosition,
		connections = connections,
		scaleMotion = Kinetic.animate(scale, { Scale = 1, config = OPEN_SPRING }),
		cardMotion = Kinetic.animate(card, { Position = restPosition, config = OPEN_SPRING }),
		dimMotion = Kinetic.animate(dim, { BackgroundTransparency = restDim, config = { tension = 210, friction = 26 } }),
	}

	playSound(SOUND_OPEN, 0.1)

	local cancelButton = card.Actions.CancelButton
	local confirmButton = card.Actions.ConfirmButton
	bindMotion(cancelButton)
	bindMotion(confirmButton)

	table.insert(connections, cancelButton.Activated:Connect(function()
		playSound(SOUND_CLICK, 0.2)
		finish(false)
	end))

	table.insert(connections, confirmButton.Activated:Connect(function()
		playSound(SOUND_CLICK, 0.2)
		finish(true)
	end))

	table.insert(connections, dim.Activated:Connect(function()
		finish(false)
	end))

	-- Si el jugador respawnea o algo destruye el ScreenGui por fuera, el estado
	-- no puede quedarse creyendo que sigue abierto.
	table.insert(connections, gui.AncestryChanged:Connect(function()
		if not gui:IsDescendantOf(game) and active and active.gui == gui then
			finish(false)
		end
	end))

	ContextActionService:BindActionAtPriority(CANCEL_ACTION, function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			finish(false)
		end
		return Enum.ContextActionResult.Sink
	end, false, 3000, Enum.KeyCode.Escape, Enum.KeyCode.ButtonB)

	return true
end

return SellHousePrompt
