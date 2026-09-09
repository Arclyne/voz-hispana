local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local CooldownShared = require(ReplicatedStorage.Shared.Cooldown:WaitForChild("CooldownShared"))

local remotes = ReplicatedStorage:WaitForChild("Events")
local rouletteRemotes = remotes:WaitForChild("Roulette")
local requestSpinRF = rouletteRemotes:WaitForChild("RequestSpin")

local player = Players.LocalPlayer

local GUI_NAME = "Roulette"
local FREE_SPIN_KEY = "RouletteFreeSpin"

local BASE_BLUE = Color3.fromRGB(48, 148, 255)
local DARK_BLUE = Color3.fromRGB(19, 59, 102) -- oscurecido

local PRODUCT_IDS = {
	Buy1Spins = 3537141632,
	Buy5Spins = 3537141894,
	Buy10Spins = 3537142253,
}

local controller = {}
controller._setup = false
controller._currentModel = nil

local gui, frame
local spinsBtn, freeBtn, closeBtn
local buy1Btn, buy5Btn, buy10Btn

local spinsTextLabel, freeTextLabel
local spinsStat, cooldownsFolder

local function getGui()
	if gui and gui.Parent then return gui end
	gui = player.PlayerGui:WaitForChild(GUI_NAME)

	-- según tu screenshot: Roulette > Container > Frame > ...
	frame = gui:WaitForChild("Container"):WaitForChild("Frame")

	spinsBtn = frame:WaitForChild("Spins")
	freeBtn = frame:WaitForChild("FreeSpin")

	buy1Btn = frame:WaitForChild("Buy1Spins")
	buy5Btn = frame:WaitForChild("Buy5Spins")
	buy10Btn = frame:WaitForChild("Buy10Spins")

	closeBtn = frame.Parent:WaitForChild("CloseButton")

	spinsTextLabel = spinsBtn:WaitForChild("TextLabel")
	freeTextLabel = freeBtn:WaitForChild("TextLabel")

	cooldownsFolder = player:WaitForChild("Cooldowns")
	spinsStat = player:WaitForChild("leaderstats"):WaitForChild("Spins")

	return gui
end

local function setGuiVisible(on: boolean)
	getGui()
	gui.Enabled = on
end

local function formatFree(remaining: number)
	-- Para botón mejor “compacto”
	return CooldownShared.FormatRemaining(remaining)
end

local function updateSpinsText()
	local spins = tonumber(spinsStat.Value) or 0
	spinsTextLabel.Text = ("x%d Spins"):format(spins)

	-- opcional: si no hay spins, oscurece el botón
	if spins <= 0 then
		spinsBtn.BackgroundColor3 = DARK_BLUE
	else
		spinsBtn.BackgroundColor3 = BASE_BLUE
	end
end

local function updateFreeSpinButton()
	local v = cooldownsFolder:FindFirstChild(FREE_SPIN_KEY)
	local expire = v and v.Value or 0
	local remaining = CooldownShared.GetRemainingSeconds(expire)

	if remaining > 0 then
		freeTextLabel.Text = formatFree(remaining)
		freeBtn.BackgroundColor3 = DARK_BLUE
	else
		freeTextLabel.Text = "Free Spin"
		freeBtn.BackgroundColor3 = BASE_BLUE
	end
end

local function canPaidSpin(): boolean
	return (tonumber(spinsStat.Value) or 0) > 0
end

local function setupBuyButton(btn: TextButton, key: string)
	btn.Activated:Connect(function()
		local productId = PRODUCT_IDS[key]
		if not productId then
			warn("ProductId no definido para", key)
			return
		end
		MarketplaceService:PromptProductPurchase(player, productId)
	end)
end

local function safeRequest(mode: string)
	if controller._requesting then return end
	if not controller._currentModel then return end

	-- ✅ UX: si el modelo está “Started”, casi seguro está ocupada
	if controller._currentModel:GetAttribute("Started") then
		print("La ruleta está ocupada.")
		return
	end

	controller._requesting = true
	local ok, reason, extra = requestSpinRF:InvokeServer(controller._currentModel, mode)
	controller._requesting = false

	if ok then
		setGuiVisible(false)
		return
	end

	-- feedback local
	if reason == "BUSY" then
		print("La ruleta está ocupada.")
	elseif reason == "NO_SPINS" then
		print("No tienes spins.")
	elseif reason == "FREE_COOLDOWN" then
		print("Free Spin en cooldown:", extra)
	else
		print("Roulette failed:", reason, extra)
	end

	updateSpinsText()
	updateFreeSpinButton()
end


function controller.Open(model: Model)
	getGui()
	controller._currentModel = model
	setGuiVisible(true)

	updateSpinsText()
	updateFreeSpinButton()
end

function controller.Close()
	controller._currentModel = nil
	setGuiVisible(false)
end

function controller.Init()
	if controller._setup then return end
	controller._setup = true

	getGui()
	gui.Enabled = false

	-- Close
	closeBtn.Activated:Connect(function()
		controller.Close()
	end)

	-- Paid spin
	spinsBtn.Activated:Connect(function()
		if not canPaidSpin() then
			updateSpinsText()
			return
		end
		safeRequest("Paid")
	end)

	-- Free spin
	freeBtn.Activated:Connect(function()
		-- Si está en cooldown, no pedir al server (UX)
		local v = cooldownsFolder:FindFirstChild(FREE_SPIN_KEY)
		local expire = v and v.Value or 0
		local remaining = CooldownShared.GetRemainingSeconds(expire)
		if remaining > 0 then
			return
		end

		safeRequest("Free")
	end)

	-- Dev products
	setupBuyButton(buy1Btn, "Buy1Spins")
	setupBuyButton(buy5Btn, "Buy5Spins")
	setupBuyButton(buy10Btn, "Buy10Spins")

	-- Reacciones a cambios
	spinsStat:GetPropertyChangedSignal("Value"):Connect(function()
		if gui.Enabled then updateSpinsText() end
	end)

	cooldownsFolder.ChildAdded:Connect(function(child)
		if child.Name == FREE_SPIN_KEY and gui.Enabled then
			updateFreeSpinButton()
		end
	end)

	-- Update loop SOLO cuando está visible
	local acc = 0
	RunService.Heartbeat:Connect(function(dt)
		if not gui.Enabled then return end
		acc += dt
		if acc < 0.2 then return end
		acc = 0

		updateFreeSpinButton()
	end)
end

return controller
