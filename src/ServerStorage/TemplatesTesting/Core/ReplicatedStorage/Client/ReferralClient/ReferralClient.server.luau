--[[
	ReferralClient

	Pinta la seccion de Amigos: la barra de la siguiente recompensa, la fila de
	amigos en progreso y la escalera de recompensas.

	La escalera NO se dibuja a mano: las tarjetas Reward1..Reward14 que hay en el
	editor son la plantilla y el molde visual, pero cuantas se ven y que dan sale
	de ReferralConfig. Anadir un hito en la config anade una tarjeta aqui.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local referralsShared = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Referrals")
local ReferralConfig = require(referralsShared:WaitForChild("ReferralConfig"))
local ProgressRing = require(referralsShared:WaitForChild("ProgressRing"))

local referralEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Referrals")
local GetReferralState = referralEvents:WaitForChild("GetReferralState")
local ClaimReferralReward = referralEvents:WaitForChild("ClaimReferralReward")
local ReferralUpdated = referralEvents:WaitForChild("ReferralUpdated")

local screen = playerGui:WaitForChild("WorldSystemUI")
local friends = screen:WaitForChild("Menu"):WaitForChild("Friends")
local content = friends:WaitForChild("Main"):WaitForChild("Content")

local inProgress = content:WaitForChild("InProgress")
local cardTemplate = inProgress:WaitForChild("Card")
local emptyText = inProgress:WaitForChild("EmptyText")
local counter = content:WaitForChild("TittleFriends"):WaitForChild("Counter")
local partnerPanel = content:WaitForChild("PartnerPanel")

local invites = content:WaitForChild("Invites")
local inviteDescription = invites:WaitForChild("Description")
local shareButton = invites:WaitForChild("ShareButton")
local linkStatus = invites:WaitForChild("LinkStatus")
local ShareReferralLink = referralEvents:WaitForChild("ShareReferralLink")

local RING_EMPTY = Color3.fromRGB(0, 55, 82)
local REFRESH_SECONDS = 15

local REQUIRED_MINUTES = math.floor(ReferralConfig.Settings.RequiredSeconds / 60)
local MINUTES_TEXT = ReferralConfig.Settings.AccumulateAcrossSessions
	and ("%d minutos"):format(REQUIRED_MINUTES)
	or ("%d minutos seguidos"):format(REQUIRED_MINUTES)

-- `friends.Visible` sigue en true cuando lo que se cierra es la tablet entera,
-- y seguir refrescando con la seccion tapada seria gastar lecturas en nada.
local function isSectionShown(): boolean
	local current: Instance? = friends

	while current and not current:IsA("ScreenGui") do
		if current:IsA("GuiObject") and not current.Visible then
			return false
		end
		current = current.Parent
	end

	return current ~= nil and current:IsA("ScreenGui") and current.Enabled
end

-- Cuantas caras caben en la fila sin que se salgan. El contador de arriba dice
-- el total de verdad; esto es solo cuantas se dibujan.
local MAX_VISIBLE_CARDS = 8

local state = nil
local cards: { [number]: any } = {}

--------------------------------------------------------------------------------
-- Utilidades
--------------------------------------------------------------------------------

local function formatNumber(value: number): string
	local text = tostring(math.floor(value))
	local formatted = text:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	return (formatted:gsub("^,", ""))
end

local function plural(count: number, singular: string, pluralWord: string): string
	return count == 1 and singular or pluralWord
end

local function thumbnailFor(userId: number): string
	local ok, url = pcall(function()
		return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)

	return ok and url or ""
end

--------------------------------------------------------------------------------
-- Las tarjetas de la escalera
--------------------------------------------------------------------------------

--[[
	La fila de tarjetas se reconstruye a partir de la config. Se usan las que ya
	estan puestas en el editor como molde y se clonan o se sobran segun haga falta,
	asi que restilar una en el editor restila todas.
]]
local function collectRewardFrames()
	local rows = {}

	for _, child in ipairs(content:GetChildren()) do
		if child:IsA("Frame") and child.Name:match("^FriendRewards%d*$") then
			table.insert(rows, child)
		end
	end

	table.sort(rows, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	local frames = {}

	for _, row in ipairs(rows) do
		local cardsInRow = {}

		for _, child in ipairs(row:GetChildren()) do
			if child:IsA("Frame") and child.Name:match("^Reward%d+$") then
				table.insert(cardsInRow, child)
			end
		end

		-- Estan puestas a mano y numeradas, no ordenadas por LayoutOrder.
		table.sort(cardsInRow, function(a, b)
			return (tonumber(a.Name:match("%d+")) or 0) < (tonumber(b.Name:match("%d+")) or 0)
		end)

		for _, card in ipairs(cardsInRow) do
			table.insert(frames, { frame = card, row = row })
		end
	end

	return frames, rows
end

--[[
	En el editor unas tarjetas tienen texto en el boton y otras un candado, porque
	estaban dibujadas en estados distintos. Aqui se le ponen las dos piezas a todas
	y se ensena la que toque.
]]
local lockTemplate = nil
local textTemplate = nil

local function normalizeClaim(claim: TextButton)
	if not claim:FindFirstChild("TextLabel") and textTemplate then
		local label = textTemplate:Clone()
		label.Parent = claim
	end

	if not claim:FindFirstChild("image") and lockTemplate then
		local lock = lockTemplate:Clone()
		lock.Parent = claim
	end
end

local function paintRewardCard(frame: Frame, reward, claimed: boolean, unlocked: boolean)
	local count = frame:FindFirstChild("FriendCount")
	local countText = count and count:FindFirstChild("Text")

	if countText and countText:IsA("TextLabel") then
		countText.Text = reward.IsDefault and ("+" .. reward.Friends) or tostring(reward.Friends)
	end

	local amount = frame:FindFirstChild("CurrencyReward")

	if amount and amount:IsA("TextLabel") then
		amount.Text = formatNumber(reward.Amount)
		amount.TextColor3 = reward.Currency == "Gems" and ReferralConfig.Colors.GemsText or ReferralConfig.Colors.CoinsText
	end

	-- El dibujo tiene que decir la verdad sobre lo que se cobra.
	local art = frame:FindFirstChild("image")

	if art and art:IsA("ImageLabel") then
		art.Image = reward.Image
			or ReferralConfig.RewardImages[reward.Currency]
			or ReferralConfig.RewardImages.Coins
	end

	local claim = frame:FindFirstChild("Claim")

	if claim and claim:IsA("TextButton") then
		normalizeClaim(claim)

		local canClaim = unlocked and not claimed
		local claimLabel = claim:FindFirstChild("TextLabel")
		local lock = claim:FindFirstChild("image")

		if claimLabel and claimLabel:IsA("TextLabel") then
			claimLabel.Visible = unlocked
			claimLabel.Text = claimed and "Reclamado" or "Reclamar"
		end

		if lock and lock:IsA("ImageLabel") then
			lock.Visible = not unlocked
		end

		claim.Active = canClaim
		claim.AutoButtonColor = canClaim
		claim.BackgroundColor3 = claimed and ReferralConfig.Colors.Idle
			or (canClaim and ReferralConfig.Colors.Completed or Color3.fromRGB(0, 135, 203))
	end
end

--[[
	La escalera se reconstruye entera desde la config. Las tarjetas y la fila que
	hay puestas en el editor se guardan como molde antes de tocar nada, asi que
	restilarlas alli restila todo lo que se genere aqui.
]]
local ladderTemplates = nil

local function captureTemplates()
	if ladderTemplates then
		return ladderTemplates
	end

	local frames, rows = collectRewardFrames()

	if #frames == 0 or #rows == 0 then
		warn("[ReferralClient] No encuentro las tarjetas de recompensa en la seccion de Amigos")
		return nil
	end

	ladderTemplates = {
		card = frames[1].frame:Clone(),
		row = rows[1]:Clone(),
		rows = rows,
		firstOrder = rows[1].LayoutOrder,
	}

	-- Las dos piezas del boton de reclamar, cada una tomada de la tarjeta donde el
	-- diseno la dejo puesta.
	for _, entry in ipairs(frames) do
		local claim = entry.frame:FindFirstChild("Claim")

		if claim then
			local label = claim:FindFirstChild("TextLabel")
			local lock = claim:FindFirstChild("image")

			if label and not textTemplate then
				textTemplate = label:Clone()
			end

			if lock and not lockTemplate then
				lockTemplate = lock:Clone()
			end
		end
	end

	if not lockTemplate then
		local lock = Instance.new("ImageLabel")
		lock.Name = "image"
		lock.BackgroundTransparency = 1
		lock.AnchorPoint = Vector2.new(0.5, 0.5)
		lock.Position = UDim2.fromScale(0.5, 0.5)
		lock.Size = UDim2.fromScale(0.7, 0.7)
		lock.Image = ReferralConfig.LockImage
		lockTemplate = lock
	end

	-- La fila molde se queda sin tarjetas: solo interesa su forma y su estilo.
	for _, child in ipairs(ladderTemplates.row:GetChildren()) do
		if child:IsA("Frame") and child.Name:match("^Reward%d+$") then
			child:Destroy()
		end
	end

	return ladderTemplates
end

local PER_ROW = 7

local function buildLadder(rewards)
	local templates = captureTemplates()
	if not templates then
		return {}
	end

	local neededRows = math.max(1, math.ceil(#rewards / PER_ROW))

	-- Sobran o faltan filas respecto a lo que hay en el editor
	while #templates.rows > neededRows do
		local last = table.remove(templates.rows)
		last:Destroy()
	end

	while #templates.rows < neededRows do
		local row = templates.row:Clone()
		row.Name = "FriendRewards" .. (#templates.rows + 1)
		row.LayoutOrder = templates.firstOrder + #templates.rows
		row.Parent = content
		table.insert(templates.rows, row)
	end

	local frames = {}

	for index, reward in ipairs(rewards) do
		local rowIndex = math.ceil(index / PER_ROW)
		local row = templates.rows[rowIndex]
		local name = "Reward" .. index
		local frame = row:FindFirstChild(name)

		if not frame then
			-- Puede existir con otro numero si la config cambio de tamano: se
			-- recicla la que este libre en esa posicion antes de clonar.
			local existing = {}

			for _, child in ipairs(row:GetChildren()) do
				if child:IsA("Frame") and child.Name:match("^Reward%d+$") then
					table.insert(existing, child)
				end
			end

			table.sort(existing, function(a, b)
				return (tonumber(a.Name:match("%d+")) or 0) < (tonumber(b.Name:match("%d+")) or 0)
			end)

			frame = existing[((index - 1) % PER_ROW) + 1]

			if not frame then
				frame = templates.card:Clone()
				frame.Parent = row
			end

			frame.Name = name
		end

		frame.LayoutOrder = index
		frame.Visible = true
		frames[reward.Id] = frame
	end

	-- Las que sobran de una config anterior
	for _, row in ipairs(templates.rows) do
		for _, child in ipairs(row:GetChildren()) do
			if child:IsA("Frame") and child.Name:match("^Reward%d+$") then
				local number = tonumber(child.Name:match("%d+")) or 0

				if number > #rewards then
					child:Destroy()
				end
			end
		end
	end

	return frames
end

--------------------------------------------------------------------------------
-- Amigos en progreso
--------------------------------------------------------------------------------

local function buildCard(entry)
	local frame = cardTemplate:Clone()
	frame.Name = "Card_" .. entry.UserId
	frame.Visible = true
	frame.Parent = inProgress

	local ring = ProgressRing.new(frame.AvatarBox.Ring, RING_EMPTY)

	frame.PlayerName.Text = entry.Name

	task.spawn(function()
		local url = thumbnailFor(entry.UserId)

		if frame.Parent then
			frame.AvatarBox.Avatar.Image = url
		end
	end)

	return { frame = frame, ring = ring, entry = entry, shownSecs = entry.Seconds }
end

local function paintCard(card)
	local entry = card.entry
	local required = ReferralConfig.Settings.RequiredSeconds

	-- Un amigo ya completado siempre va con el aro entero y dorado: la tarjeta es
	-- un recuerdo de a quien invitaste, no una barra a medias.
	if entry.Completed then
		card.ring:set(1, ReferralConfig.Colors.Completed)
		card.frame.PlayerName.Text = entry.Name
		card.frame.Status.Text = "invitado"
		return
	end

	local seconds = math.clamp(card.shownSecs, 0, required)
	local ratio = required > 0 and seconds / required or 0
	local live = entry.Live ~= false

	local color = ReferralConfig.Colors.InProgress

	if ratio >= 1 then
		color = ReferralConfig.Colors.Completed
	elseif not live then
		color = ReferralConfig.Colors.Idle
	end

	card.ring:set(ratio, color)
	card.frame.PlayerName.Text = entry.Name

	if ratio >= 1 then
		card.frame.Status.Text = "¡completado!"
	elseif seconds <= 0 then
		card.frame.Status.Text = "sin empezar"
	else
		-- Los minutos hechos se ensenan siempre, este jugando o no: son suyos hasta
		-- que venza la ventana.
		card.frame.Status.Text = ("%d/%d min"):format(math.floor(seconds / 60), math.floor(required / 60))
	end
end

--[[
	La fila junta las dos cosas: primero los que estan jugando ahora sus minutos y
	detras las caras de los que ya lo consiguieron.
]]
local function renderFriends(pending, friends)
	local list = {}

	for _, entry in ipairs(pending) do
		table.insert(list, entry)
	end

	for _, entry in ipairs(friends) do
		if #list >= MAX_VISIBLE_CARDS then
			break
		end

		table.insert(list, {
			UserId = entry.UserId,
			Name = entry.Name,
			Completed = true,
		})
	end

	local seen = {}

	for index, entry in ipairs(list) do
		seen[entry.UserId] = true

		local card = cards[entry.UserId]

		if not card then
			card = buildCard(entry)
			cards[entry.UserId] = card
		end

		card.entry = entry
		card.shownSecs = entry.Seconds or 0
		card.frame.LayoutOrder = index
		paintCard(card)
	end

	for userId, card in pairs(cards) do
		if not seen[userId] then
			card.ring:destroy()
			card.frame:Destroy()
			cards[userId] = nil
		end
	end

	emptyText.Visible = #list == 0
end

--------------------------------------------------------------------------------
-- Mi link
--------------------------------------------------------------------------------

local sharing = false

local function setLinkStatus(text: string, isError: boolean)
	linkStatus.Text = text
	linkStatus.TextColor3 = isError and Color3.fromRGB(255, 130, 130) or Color3.fromRGB(255, 220, 120)
end

--[[
	El link lo genera y lo entrega el servidor, asi que esto solo lo pide y espera
	a que conteste. Roblox abre la hoja de compartir del sistema donde la haya y,
	donde no (el PC), copia el link al portapapeles el solo. No hay forma de
	escribir en el portapapeles desde un script, asi que esta es la unica via.
]]
shareButton.Activated:Connect(function()
	if sharing then
		return
	end

	sharing = true
	shareButton.Active = false
	shareButton.AutoButtonColor = false
	setLinkStatus("Preparando tu link…", false)

	ShareReferralLink:FireServer()
end)

ShareReferralLink.OnClientEvent:Connect(function(result)
	sharing = false
	shareButton.Active = true
	shareButton.AutoButtonColor = true

	if result == true then
		setLinkStatus("¡Link listo! Pégalo en Discord o donde quieras.", false)
	elseif result == "studio" then
		setLinkStatus("En Studio no se puede generar el link; en el juego publicado sí.", false)
	else
		setLinkStatus("No se pudo preparar tu link. Inténtalo otra vez.", true)
	end
end)

local function renderLink()
	shareButton.Visible = (state.Link or "") ~= ""
end

--[[
	El panel de creditos solo existe para los creadores: a un jugador normal el
	servidor le manda Partner = nil y ni se entera de que existe.

	Los creditos no se reclaman desde aqui: se pagan a mano en Robux desde el
	grupo, porque un juego de Roblox no puede pagar Robux a un jugador. Esto es la
	cuenta, no la caja.
]]
local function renderPartner()
	local partner = state.Partner

	partnerPanel.Visible = partner ~= nil

	if not partner then
		return
	end

	partnerPanel.Detail.Text = ("%s ganados · %s pagados · %d por amigo"):format(
		formatNumber(partner.Points),
		formatNumber(partner.Paid),
		partner.Rate
	)

	partnerPanel.Owed.Text = formatNumber(partner.Owed)
end

--------------------------------------------------------------------------------
-- Pintado general
--------------------------------------------------------------------------------

local function render()
	if not state then
		return
	end

	renderLink()
	renderPartner()

	inviteDescription.Text = ("Comparte tu link con quien quieras. Cuando entren por él y jueguen %s, te llevas la recompensa."):format(MINUTES_TEXT)

	counter.Text = ("%s %s"):format(
		formatNumber(state.Total),
		plural(state.Total, "invitado", "invitados")
	)

	renderFriends(state.Pending, state.Friends or {})

	local frames = buildLadder(state.Rewards)

	for _, reward in ipairs(state.Rewards) do
		local frame = frames[reward.Id]

		if frame then
			paintRewardCard(frame, reward, reward.Claimed, reward.Unlocked)
			frame:SetAttribute("RewardId", reward.Id)
		end
	end

	local defaultRow = content:FindFirstChild("DefaultFriendRewards")
	local defaultCard = defaultRow and defaultRow:FindFirstChild("Reward15")

	if defaultCard and state.Default then
		defaultRow.Visible = true
		paintRewardCard(defaultCard, {
			Friends = state.Default.From,
			Amount = state.Default.Amount,
			Currency = state.Default.Currency,
			IsDefault = true,
		}, state.Default.Claimable == 0 and state.Default.Earned > 0, state.Default.Claimable > 0)
		defaultCard:SetAttribute("RewardId", "default")
	elseif defaultRow then
		defaultRow.Visible = state.Default ~= nil
	end
end

--------------------------------------------------------------------------------
-- Entrada y refresco
--------------------------------------------------------------------------------

local function refresh()
	local ok, result = pcall(function()
		return GetReferralState:InvokeServer()
	end)

	if ok and typeof(result) == "table" then
		state = result
		render()
	end
end

-- Un solo enganche para todos los botones de reclamar, presente y futuro: se
-- mira el atributo de la tarjeta en el momento del clic.
content.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("TextButton") and descendant.Name == "Claim" then
		descendant.Activated:Connect(function()
			local card = descendant.Parent
			local rewardId = card and card:GetAttribute("RewardId")

			if rewardId then
				ClaimReferralReward:FireServer(rewardId)
			end
		end)
	end
end)

for _, descendant in ipairs(content:GetDescendants()) do
	if descendant:IsA("TextButton") and descendant.Name == "Claim" then
		descendant.Activated:Connect(function()
			local card = descendant.Parent
			local rewardId = card and card:GetAttribute("RewardId")

			if rewardId then
				ClaimReferralReward:FireServer(rewardId)
			end
		end)
	end
end

ReferralUpdated.OnClientEvent:Connect(function(newState)
	if typeof(newState) == "table" then
		state = newState
		render()
	end
end)

refresh()

--[[
	Dos ritmos distintos a proposito.

	El anillo de un amigo que esta jugando avanza en el cliente cada segundo, para
	que se vea vivo. Los datos de verdad se piden al servidor cada 15 s y solo
	mientras la seccion esta abierta: el progreso real vive en el servidor donde
	este jugando ese amigo, y preguntarlo mas seguido no lo haria mas exacto.
]]
task.spawn(function()
	local sinceRefresh = 0

	while true do
		task.wait(1)

		if not isSectionShown() then
			continue
		end

		for _, card in pairs(cards) do
			if card.entry.Online and card.shownSecs < ReferralConfig.Settings.RequiredSeconds then
				card.shownSecs += 1
				paintCard(card)
			end
		end

		sinceRefresh += 1

		if sinceRefresh >= REFRESH_SECONDS then
			sinceRefresh = 0
			refresh()
		end
	end
end)

friends:GetPropertyChangedSignal("Visible"):Connect(function()
	if friends.Visible then
		refresh()
	end
end)
