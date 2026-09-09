local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryItem = require(script.InventoryItem)
local Players = game:GetService("Players")

local function getToolTexture(toolName)
	local player = Players.LocalPlayer
	local tool = player:FindFirstChild("StarterGear") and player.StarterGear:FindFirstChild(toolName)
		or player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild(toolName)
		or (player.Character and player.Character:FindFirstChild(toolName))

	return tool and tool.TextureId or "rbxasset://textures/ui/GuiImagePlaceholder.png"
end

local InventoryList = {}
InventoryList.__index = InventoryList

function InventoryList.new(frame)
	local self = setmetatable({}, InventoryList)
	self.frame = frame
	self.dropped = Instance.new("BindableEvent")
	self._items = {} -- Diccionario: [id] = InventoryItem (objeto)
	self._counts = {} -- Nuevo: Diccionario [id] = numero

	return self
end

function InventoryList:addItem(id, totalCount)
	-- Guardamos la cuenta actual
	self._counts[id] = totalCount or 1

	if self._items[id] then
		-- Si ya existe visualmente, solo actualizamos el número
		self._items[id]:setAmount(self._counts[id])
	else
		-- Si no existe, creamos el slot
		local newItem = InventoryItem.new()
		newItem.frame.Name = id
		newItem.frame.Parent = self.frame
		newItem:setImage(getToolTexture(id))
		newItem:setAmount(self._counts[id]) -- Setear cantidad inicial

		newItem.dropped.Event:Connect(function(location)
			self.dropped:Fire(id, location)
		end)

		self._items[id] = newItem
	end
end

function InventoryList:removeItem(id)
	-- NOTA: En tu sistema, "removeItem" se usa cuando se mueve a la Wheel.
	-- Si se mueve a la wheel, desaparece de la lista completamente.
	if self._items[id] then
		self._items[id]:destroy()
		self._items[id] = nil
		self._counts[id] = nil
	end
end

-- Helper para saber si la lista tiene un item
function InventoryList:hasItem(id)
	return self._items[id] ~= nil
end

return InventoryList