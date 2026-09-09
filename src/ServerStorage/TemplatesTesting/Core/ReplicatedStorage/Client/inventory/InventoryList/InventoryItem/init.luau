local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local Trove = require(ReplicatedStorage.Shared.Trove)

local player = Players.LocalPlayer

local InventoryItem = {}
InventoryItem.__index = InventoryItem

function InventoryItem.new()
	local self = setmetatable({}, InventoryItem)

	self.frame = script.frame:Clone()
	self.item = self.frame.item
	self.icon = self.item.icon
	self.dropped = Instance.new("BindableEvent")

	self._trove = Trove.new()
	self._clone = nil

	self._dragStartLocation = nil
	self._cloneStartPosition = nil

	-- El item NO se mueve automáticamente.
	-- Nosotros moveremos el clon usando la posición real del dedo.
	self.item.dragger.ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset

	-- Inicializar cantidad (oculta si es 1)
	self:setAmount(1)

	self._trove:Add(self.item.dragger.DragStart:Connect(function(location)
		self:_handleDragStart(location)
	end))

	self._trove:Add(self.item.dragger.DragContinue:Connect(function(location)
		self:_handleDragUpdate(location)
	end))

	self._trove:Add(self.item.dragger.DragEnd:Connect(function(location)
		self:_handleDragStop(location)
	end))

	return self
end

function InventoryItem:_handleDragStart(location)
	local viewportSize = workspace.Camera.ViewportSize
	local absolutePosition = self.frame.AbsolutePosition
	local absoluteSize = self.frame.AbsoluteSize

	local gui = self.frame:FindFirstAncestorOfClass("ScreenGui")

	if gui and gui.IgnoreGuiInset then
		absolutePosition += GuiService:GetGuiInset()
	end

	local itemPosition = absolutePosition / viewportSize
	local itemSize = absoluteSize / viewportSize

	-- Clonamos el ITEM completo
	self._clone = self.item:Clone()

	self._clone.Position = UDim2.fromScale(
		itemPosition.X,
		itemPosition.Y
	)

	self._clone.Size = UDim2.fromScale(
		itemSize.X,
		itemSize.Y
	)

	self._clone.ZIndex = 1e6

	-- El clon no necesita UIDragDetector
	local cloneDragger = self._clone:FindFirstChild("dragger")

	if cloneDragger then
		cloneDragger:Destroy()
	end

	self._clone.Parent = gui

	-- Guardamos dónde empezó el dedo/mouse
	self._dragStartLocation = location

	-- Guardamos dónde estaba el clon al empezar
	self._cloneStartPosition = self._clone.Position

	-- IMPORTANTE:
	-- NO ocultamos item porque contiene el UIDragDetector.
	-- Solo ocultamos la imagen visual.
	self.icon.Visible = false
	self.item.stroke.Enabled = false
end

function InventoryItem:_handleDragUpdate(location)
	if not self._clone then
		return
	end

	if not self._dragStartLocation then
		return
	end

	if not self._cloneStartPosition then
		return
	end

	-- Movimiento exacto realizado por el dedo/mouse
	local delta = location - self._dragStartLocation

	local startPosition = self._cloneStartPosition

	self._clone.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end

function InventoryItem:_handleDragStop(location)
	if self._clone then
		self._clone:Destroy()
		self._clone = nil
	end

	self._dragStartLocation = nil
	self._cloneStartPosition = nil

	-- Volvemos a mostrar el icono original
	self.icon.Visible = true
	self.item.stroke.Enabled = true
	
	self.dropped:Fire(location)
end

function InventoryItem:setImage(image: string)
	self.icon.Image = image
end

function InventoryItem:setAmount(amount: number)
	-- Busca el label llamado "number"
	local numberLabel = self.frame:FindFirstChild("number")

	if numberLabel then
		if amount > 1 then
			numberLabel.Visible = true
			numberLabel.Text = "x" .. tostring(amount)
		else
			numberLabel.Visible = false
		end
	end
end

function InventoryItem:destroy()
	self._trove:Destroy()

	if self._clone then
		self._clone:Destroy()
		self._clone = nil
	end

	self.frame:Destroy()
end

return InventoryItem