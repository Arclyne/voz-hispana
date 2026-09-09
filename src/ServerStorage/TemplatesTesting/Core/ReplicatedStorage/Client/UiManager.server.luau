--[[
    UiManager
    ---------------
    Este script incluye el manejo de parte de la interfaz principal del juego.
    Sería bueno juntarlo todo a futuro.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShopHighlight = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ShopHighlight"))

local player = Players.LocalPlayer

-- Esperamos a que carguen los leaderstats y los valores
local leaderstats = player:WaitForChild("leaderstats")
local coinsValue = leaderstats:WaitForChild("Coins")
local gemsValue = leaderstats:WaitForChild("Gems")

-- REFERENCIAS DE UI (Restauradas a tu versión funcional)
local playerGui = player:WaitForChild("PlayerGui")
-- Esperamos a que cargue la UI principal
local menuFrame = playerGui:WaitForChild("WorldSystemUI"):WaitForChild("Menu")
local lymMain = playerGui:WaitForChild("LymMain")
local sendCashPlayer = lymMain:WaitForChild("Frames"):WaitForChild("SendCashPlayer")

local MENU_SECTIONS = { "Friends", "Home", "Inventory", "Settings", "Shop", "Worlds" }

--[[
	La cartera vive fuera del scroll en las secciones con cabecera fija y dentro de
	`Main` en las que todavía no la tienen, así que se busca en los dos sitios en
	vez de fijar una ruta. Sondeo con tope y no WaitForChild: apuntar a una sola de
	las dos rutas colgaría para siempre en la otra.
]]
local function findWallet(section)
	local deadline = os.clock() + 10

	repeat
		local main = section:FindFirstChild("Main")
		local topBar = section:FindFirstChild("TopBar") or (main and main:FindFirstChild("TopBar"))
		local wallet = topBar and topBar:FindFirstChild("wallet")
		if wallet then
			return wallet
		end
		task.wait()
	until os.clock() > deadline

	warn("[UiManager] no se encontró la cartera en " .. section.Name)
	return nil
end

local function walletLabels(childName)
	local labels = {}

	for _, sectionName in ipairs(MENU_SECTIONS) do
		local wallet = findWallet(menuFrame:WaitForChild(sectionName))
		local label = wallet and wallet:WaitForChild(childName, 10)
		if label then
			table.insert(labels, label)
		end
	end

	table.insert(labels, sendCashPlayer:WaitForChild("wallet"):WaitForChild(childName))
	return labels
end

local coinTexts = walletLabels("coins")
local gemTexts = walletLabels("gems")

-- Todos los botones + de la tablet abren la tienda y llevan directamente a
-- GAMEPASSES, donde están los paquetes de monedas y gemas.
local CURRENCY_SCROLL_DELAY = 0.45
local currentSection = menuFrame:WaitForChild("CurrentSection")

local function openCurrencyShop()
	if currentSection.Value ~= "Shop" then
		currentSection.Value = "Shop"
	end

	task.delay(CURRENCY_SCROLL_DELAY, function()
		local shop = menuFrame:FindFirstChild("Shop")
		local main = shop and shop:FindFirstChild("Main")
		local content = main and main:FindFirstChild("Content")
		local gamepassesTitle = content and content:FindFirstChild("Title4")

		if not (main and gamepassesTitle) then
			warn("[UiManager] no se encontró la sección GAMEPASSES")
			return
		end

		ShopHighlight.scrollToSection(main, gamepassesTitle)
	end)
end

local connectedBuyMore = {}
for _, sectionName in ipairs(MENU_SECTIONS) do
	local wallet = findWallet(menuFrame:WaitForChild(sectionName))
	local buyMore = wallet and wallet:FindFirstChild("BuyMore")

	if buyMore and buyMore:IsA("GuiButton") and not connectedBuyMore[buyMore] then
		connectedBuyMore[buyMore] = true
		buyMore.Activated:Connect(openCurrencyShop)
	end
end

local sendCashWallet = sendCashPlayer:WaitForChild("wallet")
local sendCashBuyMore = sendCashWallet:FindFirstChild("BuyMore")
if sendCashBuyMore and sendCashBuyMore:IsA("GuiButton") then
	sendCashBuyMore.Activated:Connect(openCurrencyShop)
end

-- FUNCIONES DE FORMATO

-- 1. Función para poner comas (ej: 9999 -> 9,999)
local function CommaValue(amount)
	local formatted = tostring(amount)
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

-- 2. Función principal que decide si usar K/M/B o Comas
local function FormatNumber(n)
	n = tonumber(n)
	if not n then return "0" end 

	if n >= 1000000000 then -- 1B+
		return string.format("%.1fB", n / 1000000000)
	elseif n >= 1000000 then -- 1M+
		return string.format("%.1fM", n / 1000000)
	elseif n >= 10000 then -- 10K+ (Aquí empieza la abreviación)
		return string.format("%.1fK", n / 1000)
	else
		-- Si es MENOR de 10k (ej: 9,999), usa comas
		return CommaValue(n)
	end
end

-- Función genérica para actualizar una lista de textos
local function UpdateLabels(labelList, newValue)
	local formattedText = FormatNumber(newValue) 

	for _, label in ipairs(labelList) do
		if label and (label:IsA("TextLabel") or label:IsA("TextButton")) then
			label.Text = formattedText
		end
	end
end

-- LOGICA DE ACTUALIZACIÓN

-- 1. Actualización Inicial
UpdateLabels(coinTexts, coinsValue.Value)
UpdateLabels(gemTexts, gemsValue.Value)

-- 2. Conectar eventos para cambios futuros
coinsValue.Changed:Connect(function(newVal)
	UpdateLabels(coinTexts, newVal)
end)

gemsValue.Changed:Connect(function(newVal)
	UpdateLabels(gemTexts, newVal)
end)