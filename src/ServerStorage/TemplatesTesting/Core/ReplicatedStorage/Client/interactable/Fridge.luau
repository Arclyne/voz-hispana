local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Interactable = require(script.Parent.Interactable)

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage.Events
local fridgeRemote = remotes.Interactable:WaitForChild("Fridge")

local Kitchen = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("Food"):WaitForChild("Kitchen")

local FoodUI = PlayerGui:WaitForChild("FoodUI")
local Container = FoodUI:WaitForChild("Container")
local FoodFrame = Container:WaitForChild("frame")
local ListLayout = FoodFrame:WaitForChild("ListLayout")
local ListContent = ListLayout:WaitForChild("content")
local CloseButton = Container:WaitForChild("CloseButton")
local TemplatesFolder = ListLayout:WaitForChild("Templates")

local DOOR_ANGLE = 90
local DOOR_TWEEN_TIME = 0.6
local MAX_DISTANCE = 20

local doorTweenInfo = TweenInfo.new(
	DOOR_TWEEN_TIME,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.InOut
)

local sectionFrames = {
	Preparada = ListContent:WaitForChild("prepered"),
	Principales = ListContent:WaitForChild("main"),
	Postres = ListContent:WaitForChild("desserts"),
	Todo = ListContent:WaitForChild("All"),
}

local sectionOrder = {
	"Preparada",
	"Principales",
	"Postres",
}

local Fridge = {}
Fridge.__index = Fridge
setmetatable(Fridge, Interactable)

local activeFridge = nil
local distanceConnection = nil
local uiCreated = false

local template = TemplatesFolder:WaitForChild("Template")

local currencyStyles = {
	Coins = {
		TextColor = Color3.fromRGB(249, 187, 31),
		Image = "rbxassetid://16212249913",
		GradientLeft = Color3.fromRGB(255, 255, 84),
		GradientRight = Color3.fromRGB(255, 255, 255),
	},

	Gems = {
		TextColor = Color3.fromRGB(85, 170, 255),
		Image = "rbxassetid://101938447947919",
		GradientLeft = Color3.fromRGB(85, 170, 255),
		GradientRight = Color3.fromRGB(255, 255, 255),
	},
}

local difficultyStyles = {
	["Fácil"] = Color3.fromRGB(81, 255, 69),
	["Medio"] = Color3.fromRGB(198, 172, 23),
	["Difícil"] = Color3.fromRGB(255, 90, 90),
}

template.Visible = false


for _, sectionFrame in pairs(sectionFrames) do
	local content = sectionFrame:WaitForChild("content")
	local layout = content:FindFirstChildOfClass("UIListLayout")

	if layout then
		layout.SortOrder = Enum.SortOrder.LayoutOrder
	else
		warn("[Fridge] No hay UIListLayout en:", content:GetFullName())
	end
end

-- =======================
-- UI
-- =======================

local function setUIVisible(visible)
	FoodUI:SetAttribute("Open", visible)
end

local function getTextObject(parent, name)
	local object = parent:FindFirstChild(name)

	if object and (
		object:IsA("TextLabel")
			or object:IsA("TextButton")
			or object:IsA("TextBox")
		) then
		return object
	end

	return nil
end

local function clearContent(content)
	for _, child in ipairs(content:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

local function clearAllSections()
	for _, sectionFrame in pairs(sectionFrames) do
		local content = sectionFrame:FindFirstChild("content")

		if content then
			clearContent(content)
		end
	end
end

-- =======================
-- Plato
-- =======================

local function getDishData(dishFolder)
	local firstTool = nil
	local displayTool = nil
	local highestStep = 0

	for _, child in ipairs(dishFolder:GetChildren()) do
		if not child:IsA("Tool") then
			continue
		end

		local step = tonumber(child.Name:match("%-%s*(%d+)$"))

		if not step then
			continue
		end

		if step == 1 then
			firstTool = child
		end

		if step > highestStep then
			highestStep = step
			displayTool = child
		end
	end

	if not firstTool then
		warn("[Fridge] No existe el paso 1 de:", dishFolder:GetFullName())
		return nil
	end

	if not displayTool then
		return nil
	end

	local price = firstTool:GetAttribute("Price")
	local difficulty = firstTool:GetAttribute("Dificulty")
	local currency = firstTool:GetAttribute("Currency")

	if typeof(price) ~= "number" then
		warn("[Fridge] Price inválido en:", firstTool:GetFullName())
		return nil
	end

	if typeof(difficulty) ~= "string" or not difficultyStyles[difficulty] then
		warn("[Fridge] Dificulty inválida en:", firstTool:GetFullName(), difficulty)
		return nil
	end

	if typeof(currency) ~= "string" or not currencyStyles[currency] then
		warn("[Fridge] Currency inválida en:", firstTool:GetFullName(), currency)
		return nil
	end

	return {
		Name = dishFolder.Name,
		FirstTool = firstTool,
		DisplayTool = displayTool,
		Price = price,
		Difficulty = difficulty,
		Currency = currency,
	}
end

-- =======================
-- ViewportFrame
-- =======================

local function setupViewport(viewport, tool)
	for _, child in ipairs(viewport:GetChildren()) do
		if child:IsA("Camera") or child:IsA("WorldModel") then
			child:Destroy()
		end
	end

	local worldModel = Instance.new("WorldModel")
	worldModel.Name = "FoodPreview"
	worldModel.Parent = viewport

	local displayModel = Instance.new("Model")
	displayModel.Name = "Display"
	displayModel.Parent = worldModel

	local clone = tool:Clone()
	local hasPart = false

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("BaseScript") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			hasPart = true
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		end
	end

	clone.Parent = displayModel

	if not hasPart then
		worldModel:Destroy()
		return
	end

	local boundingCFrame = displayModel:GetBoundingBox()

	displayModel:PivotTo(
		displayModel:GetPivot() + (-boundingCFrame.Position)
	)

	local _, size = displayModel:GetBoundingBox()
	local largest = math.max(size.X, size.Y, size.Z)

	if largest <= 0 then
		largest = 1
	end

	local camera = Instance.new("Camera")
	camera.Name = "Camera"
	camera.FieldOfView = 35
	camera.CFrame = CFrame.lookAt(
		Vector3.new(
			largest * 1.05,
			largest * 0.7,
			largest * 1.05
		),
		Vector3.zero
	)
	camera.Parent = viewport

	viewport.CurrentCamera = camera
end

-- =======================
-- Crear tarjetas
-- =======================

local function createDishCard(dishData, sectionName, content, layoutOrder)
	local clone = template:Clone()

	clone.Name = dishData.Name
	clone.LayoutOrder = layoutOrder
	clone.Visible = true

	-- Título
	local title = getTextObject(clone, "Tittle")

	if title then
		title.Text = dishData.Name
	end

	-- =======================
	-- Precio / moneda
	-- =======================

	local priceFrame = clone:FindFirstChild("Price")
	local priceText = priceFrame and getTextObject(priceFrame, "TextLabel")
	local priceImage = priceFrame and priceFrame:FindFirstChild("ImageLabel")
	local currencyStyle = currencyStyles[dishData.Currency]

	if priceText then
		priceText.Text = tostring(dishData.Price)
		priceText.TextColor3 = currencyStyle.TextColor

		local gradient = priceText:FindFirstChildOfClass("UIGradient")

		if gradient then
			gradient.Rotation = 0
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(
					0,
					currencyStyle.GradientLeft
				),

				ColorSequenceKeypoint.new(
					1,
					currencyStyle.GradientRight
				),
			})
		end
	end

	if priceImage and priceImage:IsA("ImageLabel") then
		priceImage.Image = currencyStyle.Image
	end

	-- =======================
	-- Dificultad
	-- =======================

	local tag = clone:FindFirstChild("Tag")
	local difficultyText = tag and getTextObject(tag, "Text")
	local difficultyColor = difficultyStyles[dishData.Difficulty]

	if difficultyText then
		difficultyText.Text = dishData.Difficulty
	end

	if tag then
		if tag:IsA("ImageLabel") or tag:IsA("ImageButton") then
			tag.ImageColor3 = difficultyColor
		elseif tag:IsA("GuiObject") then
			tag.BackgroundColor3 = difficultyColor
		end
	end

	-- =======================
	-- Viewport
	-- =======================

	local viewport = clone:FindFirstChild("ViewportFrame")

	if viewport and viewport:IsA("ViewportFrame") then
		setupViewport(viewport, dishData.DisplayTool)
	end

	-- =======================
	-- Compra
	-- =======================

	local buyButton = nil

	if clone:IsA("GuiButton") then
		buyButton = clone
	else
		buyButton = clone:FindFirstChildWhichIsA("GuiButton", true)
	end

	if buyButton then
		buyButton.Activated:Connect(function()
			if not activeFridge then
				return
			end

			fridgeRemote:FireServer(
				activeFridge.model,
				sectionName,
				dishData.Name
			)
		end)
	else
		warn("[Fridge] La tarjeta de", dishData.Name, "no tiene GuiButton")
	end

	clone.Parent = content
end

local currencyOrder = {
	Coins = 1,
	Gems = 2,
}

local function sortDishData(a, b)
	local currencyA = currencyOrder[a.Currency] or math.huge
	local currencyB = currencyOrder[b.Currency] or math.huge

	if currencyA ~= currencyB then
		return currencyA < currencyB
	end

	if a.Price ~= b.Price then
		return a.Price < b.Price
	end

	return a.Name < b.Name
end

local function getSortedDishData(sectionFolder)
	local dishes = {}

	for _, dishFolder in ipairs(sectionFolder:GetChildren()) do
		if not dishFolder:IsA("Folder") then
			continue
		end

		local dishData = getDishData(dishFolder)

		if dishData then
			table.insert(dishes, dishData)
		end
	end

	table.sort(dishes, sortDishData)

	return dishes
end

local function populateUI()
	if uiCreated then
		return
	end

	uiCreated = true

	clearAllSections()

	local allContent = sectionFrames.Todo:WaitForChild("content")
	local allDishes = {}

	for _, sectionName in ipairs(sectionOrder) do
		local sectionFolder = Kitchen:FindFirstChild(sectionName)
		local sectionFrame = sectionFrames[sectionName]

		if not sectionFolder or not sectionFolder:IsA("Folder") then
			warn("[Fridge] No existe sección:", sectionName)
			continue
		end

		local content = sectionFrame:WaitForChild("content")
		local dishes = getSortedDishData(sectionFolder)

		for layoutOrder, dishData in ipairs(dishes) do
			createDishCard(
				dishData,
				sectionName,
				content,
				layoutOrder
			)

			table.insert(allDishes, {
				Data = dishData,
				SectionName = sectionName,
			})
		end
	end

	table.sort(allDishes, function(a, b)
		return sortDishData(a.Data, b.Data)
	end)

	for layoutOrder, entry in ipairs(allDishes) do
		createDishCard(
			entry.Data,
			entry.SectionName,
			allContent,
			layoutOrder
		)
	end
end

-- =======================
-- Puertas
-- =======================

local function clearDoorTween(data)
	if not data then
		return
	end

	if data.Tween then
		data.Tween:Cancel()
	end

	if data.Connection then
		data.Connection:Disconnect()
	end

	if data.Value then
		data.Value:Destroy()
	end
end

function Fridge:tweenDoor(door, targetPivot, side)
	local current = self.doorTweens[side]

	if current then
		clearDoorTween(current)
	end

	local value = Instance.new("CFrameValue")
	value.Value = door:GetPivot()

	local connection = value:GetPropertyChangedSignal("Value"):Connect(function()
		if door.Parent then
			door:PivotTo(value.Value)
		end
	end)

	local animation = TweenService:Create(
		value,
		doorTweenInfo,
		{Value = targetPivot}
	)

	self.doorTweens[side] = {
		Tween = animation,
		Value = value,
		Connection = connection,
	}

	animation.Completed:Once(function()
		if self.doorTweens[side]
			and self.doorTweens[side].Tween == animation then

			connection:Disconnect()
			value:Destroy()
			self.doorTweens[side] = nil
		end
	end)

	animation:Play()
end

function Fridge:setDoorsOpen(open)
	if open then
		self:tweenDoor(
			self.leftDoor,
			self.leftClosedPivot * CFrame.Angles(0, math.rad(DOOR_ANGLE), 0),
			"Left"
		)

		self:tweenDoor(
			self.rightDoor,
			self.rightClosedPivot * CFrame.Angles(0, math.rad(-DOOR_ANGLE), 0),
			"Right"
		)
	else
		self:tweenDoor(
			self.leftDoor,
			self.leftClosedPivot,
			"Left"
		)

		self:tweenDoor(
			self.rightDoor,
			self.rightClosedPivot,
			"Right"
		)
	end
end

-- =======================
-- Distancia
-- =======================

local function stopDistanceCheck()
	if distanceConnection then
		distanceConnection:Disconnect()
		distanceConnection = nil
	end
end

local function startDistanceCheck(fridge)
	stopDistanceCheck()

	local elapsed = 0

	distanceConnection = RunService.Heartbeat:Connect(function(deltaTime)
		elapsed += deltaTime

		if elapsed < 0.2 then
			return
		end

		elapsed = 0

		if activeFridge ~= fridge then
			stopDistanceCheck()
			return
		end

		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")

		if not root then
			fridge:close()
			return
		end

		local distance = (
			root.Position - fridge.model:GetPivot().Position
		).Magnitude

		if distance > MAX_DISTANCE then
			fridge:close()
		end
	end)
end

-- =======================
-- Interactable
-- =======================

function Fridge:updateAction()
	self.wheel.page:removeAction("Abrir")
	self.wheel.page:removeAction("Cerrar")

	if self.opened then
		self.wheel:setQuickAction("Cerrar", self.close, self)
		self.wheel.page:addAction("Cerrar", self.close, self)
	else
		self.wheel:setQuickAction("Abrir", self.open, self)
		self.wheel.page:addAction("Abrir", self.open, self)
	end
end

function Fridge.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, Fridge)

	self.model = model
	self.wheel = self:getDefaultWheel()

	self.leftDoor = model:WaitForChild("LeftDoor")
	self.rightDoor = model:WaitForChild("RightDoor")

	self.leftClosedPivot = self.leftDoor:GetPivot()
	self.rightClosedPivot = self.rightDoor:GetPivot()

	self.opened = false
	self.doorTweens = {}

	local promptHolder = model:FindFirstChild("PromptHolder")
		or model:FindFirstChild("Primary")

	if not promptHolder then
		warn("[Fridge] " .. model.Name .. " necesita PromptHolder o Primary")
	else
		self:setAdornee(promptHolder)
	end

	self:setClickHitbox(model)

	self:updateAction()

	return self
end

function Fridge:open()
	if self.opened then
		return
	end

	if activeFridge and activeFridge ~= self then
		activeFridge:close()
	end

	populateUI()

	self.opened = true
	activeFridge = self

	self:updateAction()

	self:setDoorsOpen(true)
	setUIVisible(true)

	startDistanceCheck(self)
end

function Fridge:close()
	if not self.opened then
		return
	end

	self.opened = false

	self:updateAction()

	if activeFridge == self then
		activeFridge = nil
	end

	stopDistanceCheck()

	setUIVisible(false)
	self:setDoorsOpen(false)
end

setUIVisible(false)

if CloseButton:IsA("GuiButton") then
	CloseButton.Activated:Connect(function()
		if activeFridge then
			activeFridge:close()
		end
	end)
else
	warn("[Fridge] CloseButton no es un GuiButton")
end

return Fridge