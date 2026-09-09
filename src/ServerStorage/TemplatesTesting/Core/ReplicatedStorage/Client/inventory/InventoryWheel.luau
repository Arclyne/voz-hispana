local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

local function getToolTexture(toolName)
	local player = Players.LocalPlayer
	local tool = player:FindFirstChild("StarterGear") and player.StarterGear:FindFirstChild(toolName)
		or player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild(toolName)
		or (player.Character and player.Character:FindFirstChild(toolName))

	return tool and tool.TextureId or "rbxasset://textures/ui/GuiImagePlaceholder.png"
end

local shared = ReplicatedStorage:WaitForChild("Shared")
local Trove = require(shared:WaitForChild("Trove"))

local SLOTS_AMOUNT = 8
local ACTIVE_TRANSPARENCY = 0.64
local INACTIVE_TRANSPARENCY = 0.46

-- Detectar PC
local IS_PC = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled

local KEY_MAP = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8
}

local function isActuallyVisible(guiObject)
	if not guiObject.Visible then return false end
	local current = guiObject.Parent
	while current and current:IsA("GuiObject") do
		if not current.Visible then return false end
		current = current.Parent
	end
	if current and current:IsA("ScreenGui") and not current.Enabled then return false end
	return true
end

local function getAngle(v1: Vector2, v2: Vector2): number
	local theta = math.atan2(v2.Y - v1.Y, v2.X - v1.X)
	local angle = math.deg(theta) + 90
	if angle < 0 then angle = angle + 360 elseif angle >= 360 then angle = angle - 360 end
	return angle
end

local function getIndexFromAngle(angle: number)
	return math.round(angle / (360 / SLOTS_AMOUNT) + 0.5)
end

local InventoryWheel = {}
InventoryWheel.__index = InventoryWheel

function InventoryWheel.new(frame)
	local self = setmetatable({}, InventoryWheel)
	self.index = 0
	self.frame = frame
	self.keyboardEnabled = false

	self._items = table.create(SLOTS_AMOUNT)

	self.clicked = Instance.new("BindableEvent")
	self.added = Instance.new("BindableEvent")
	self.removed = Instance.new("BindableEvent")
	-- NUEVO EVENTO: Para sincronizar cantidades con el clon (HUD)
	self.quantityChanged = Instance.new("BindableEvent")

	local function updateActiveSlot()
		for i = 1, SLOTS_AMOUNT do
			local active = self.index == i
			local slot = self.frame:WaitForChild("slot"..i)
			slot.ImageTransparency = active and ACTIVE_TRANSPARENCY or INACTIVE_TRANSPARENCY
		end
	end
	
	local function toV2(p)
		if typeof(p) == "Vector3" then
			return Vector2.new(p.X, p.Y)
		end
		return p -- ya es Vector2
	end
	-- para movil
	local function touchPosToGuiSpace(p)
		local pos = toV2(p)
		local gui = self.frame:FindFirstAncestorOfClass("ScreenGui")
		if gui and gui.IgnoreGuiInset then
			pos = pos + GuiService:GetGuiInset() -- esto es Vector2
		end
		return pos
	end
	
	local function getPointerLocation()
		if IS_PC then
			return UserInputService:GetMouseLocation()
		end

		local touches = UserInputService:GetTouches()
		if #touches > 0 then
			return touchPosToGuiSpace(touches[1].Position)
		end

		return nil
	end

	-- === VISUAL ===
	for i = 1, SLOTS_AMOUNT do
		local slot = self.frame:WaitForChild("slot"..i)

		-- 1. KeyNumber (Solo PC)
		if IS_PC and not slot:FindFirstChild("KeyNumber") then
			local numberLabel = Instance.new("TextLabel")
			numberLabel.Name = "KeyNumber"
			numberLabel.Text = tostring(i)
			numberLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			numberLabel.Position = UDim2.new(0.28, 0, 0.2, 0)
			numberLabel.Size = UDim2.new(0.15, 0, 0.08, 0)
			local rotationAngle = 22.5 + ((i - 1) * 45)
			numberLabel.Rotation = -rotationAngle
			numberLabel.BackgroundTransparency = 1
			numberLabel.TextColor3 = Color3.new(1, 1, 1)
			numberLabel.Font = Enum.Font.GothamBold
			numberLabel.TextScaled = true
			numberLabel.ZIndex = 5
			numberLabel.Parent = slot
		end

		-- 2. QuantityLabel (Para los stacks)
		if not slot:FindFirstChild("QuantityLabel") then
			local qtyLabel = Instance.new("TextLabel")
			qtyLabel.Name = "QuantityLabel"
			qtyLabel.Text = "" 
			qtyLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			-- Posicion y color ajustados (amarillo)
			qtyLabel.Position = UDim2.new(0.28, 0, 0.1, 0)
			qtyLabel.Size = UDim2.new(0.5, 0, 0.08, 0)
			local rotationAngle = 22.5 + ((i - 1) * 45)
			qtyLabel.Rotation = -rotationAngle
			qtyLabel.BackgroundTransparency = 1
			qtyLabel.TextColor3 = Color3.fromRGB(0, 145, 255)
			qtyLabel.Font = Enum.Font.GothamBold
			qtyLabel.TextScaled = true
			qtyLabel.Visible = false
			qtyLabel.ZIndex = 6
			qtyLabel.Parent = slot
		end
	end

	self._trove = Trove.new()

	self._trove:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		-- Teclado: aquí sí respetamos gameProcessed
		if input.UserInputType == Enum.UserInputType.Keyboard and self.keyboardEnabled then
			if not gameProcessed then 
				local keyIndex = KEY_MAP[input.KeyCode]
				if keyIndex then
					local item = self:getItemByIndex(keyIndex)
					self.clicked:Fire(keyIndex, item)
				end
			end
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if isActuallyVisible(self.frame) then
				local idx = self:getIndexAt(UserInputService:GetMouseLocation())
				self.index = idx
				updateActiveSlot()
				if idx > 0 then
					self.clicked:Fire(idx, self:getItemByIndex(idx))
				end
			end
			return
		end

		if input.UserInputType == Enum.UserInputType.Touch then
			if isActuallyVisible(self.frame) then
				local pos = touchPosToGuiSpace(input.Position)
				local idx = self:getIndexAt(pos)
				self.index = idx
				updateActiveSlot()
				if idx > 0 then
					self.clicked:Fire(idx, self:getItemByIndex(idx))
				end
			end
			return
		end
	end))

	
	self._trove:Add(UserInputService.TouchEnded:Connect(function()
		if self.index ~= 0 then
			self.index = 0
			updateActiveSlot()
		end
	end))

	self._trove:Add(RunService.Heartbeat:Connect(function()
		if not isActuallyVisible(self.frame) then return end

		local pointer = getPointerLocation()
		local newIndex = 0
		if pointer then
			newIndex = self:getIndexAt(Vector2.new(pointer.X, pointer.Y))
		end

		local oldIndex = self.index
		self.index = newIndex
		if oldIndex ~= newIndex then
			updateActiveSlot()
		end
	end))

	updateActiveSlot()
	return self
end

function InventoryWheel:EnableKeyboard(enabled)
	self.keyboardEnabled = enabled
end

-- Actualiza visuales y avisa a los clones
function InventoryWheel:updateSlotVisuals(index, amount)
	local slot = self.frame:FindFirstChild("slot"..index)
	if slot then
		local qtyLabel = slot:FindFirstChild("QuantityLabel")
		if qtyLabel then
			if amount and amount > 1 then
				qtyLabel.Visible = true
				qtyLabel.Text = "x"..tostring(amount)
			else
				qtyLabel.Visible = false
			end
		end
	end
	-- Disparamos evento para que el Clon se entere
	self.quantityChanged:Fire(index, amount)
end

function InventoryWheel:getFirstEmptySlot()
	for i = 1, SLOTS_AMOUNT do
		if self._items[i] == nil then
			return i
		end
	end
	return nil
end

function InventoryWheel:getSlotOfItem(id)
	for index, storedId in pairs(self._items) do
		if storedId == id then return index end
	end
	return nil
end

function InventoryWheel:addItem(index: number, id: string, amount: number)
	local existingSlot = self:getSlotOfItem(id)
	if existingSlot and existingSlot ~= index then
		return false
	end

	if self._items[index] and self._items[index] ~= id then 
		self.removed:Fire(index) 
	end

	self.frame:WaitForChild("slot"..index):WaitForChild("image").Image = getToolTexture(id)
	
	-- Actualizamos visuales (esto disparará quantityChanged también)
	self:updateSlotVisuals(index, amount)

	self._items[index] = id
	-- IMPORTANTE: Pasamos 'amount' en el evento added
	self.added:Fire(index, id, amount)
	return true
end

function InventoryWheel:getItemByIndex(index: number)
	return self._items[index]
end

function InventoryWheel:removeItemByIndex(index: number)
	local slot = self.frame:WaitForChild("slot"..index)
	slot:WaitForChild("image").Image = ""
	if slot:FindFirstChild("QuantityLabel") then
		slot.QuantityLabel.Visible = false
	end

	self._items[index] = nil
	self.removed:Fire(index)
end

function InventoryWheel:removeItemById(id: string)
	local items = table.clone(self._items)
	for index, _id in items do
		if _id == id then self:removeItemByIndex(index) end
	end
end

function InventoryWheel:getIndexAt(location: Vector2)
	local absolutePosition = self.frame.AbsolutePosition
	local absoluteSize = self.frame.AbsoluteSize
	local gui = self.frame:FindFirstAncestorOfClass("ScreenGui")
	if gui and gui.IgnoreGuiInset then absolutePosition = absolutePosition + GuiService:GetGuiInset() end
	local framePosition = absolutePosition + absoluteSize / 2
	local inFrame = location.X >= (framePosition.X - absoluteSize.X/2) and location.X <= (framePosition.X + absoluteSize.X/2)
		and location.Y >= (framePosition.Y - absoluteSize.Y/2) and location.Y <= (framePosition.Y + absoluteSize.Y/2)

	if inFrame then
		return getIndexFromAngle(getAngle(framePosition, location))
	end
	return 0
end

function InventoryWheel:clone(frame)
	local cloneWheel = InventoryWheel.new(frame)

	-- CORRECCIÓN AQUI:
	-- 1. Al añadir, pasamos también el 'amount' al clon
	self.added.Event:Connect(function(index, id, amount) 
		cloneWheel:addItem(index, id, amount or 1) 
	end)

	-- 2. Al borrar, borramos en el clon
	self.removed.Event:Connect(function(index) 
		cloneWheel:removeItemByIndex(index) 
	end)

	-- 3. NUEVO: Si solo cambia la cantidad (sin añadir/borrar), actualizamos el clon
	self.quantityChanged.Event:Connect(function(index, amount)
		cloneWheel:updateSlotVisuals(index, amount)
	end)

	return cloneWheel
end

return InventoryWheel