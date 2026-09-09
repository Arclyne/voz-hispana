-- Este es el interactuable de las tools que colocamos en superficies

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Interactable = require(script.Parent.Interactable)

local remotes = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Interactable")
local player = Players.LocalPlayer

local ToolInteractable = {}
ToolInteractable.__index = ToolInteractable
setmetatable(ToolInteractable, Interactable)

local function getEquippedTool(): Tool?
	local character = player.Character
	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Tool")
end

local function hasOpenAnimation(model: Model): boolean
	local openAnimationId = model:GetAttribute("OpenAnimationId") or model:GetAttribute("OpenIDAnim")
	return type(openAnimationId) == "string" and openAnimationId ~= ""
end

function ToolInteractable.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, ToolInteractable)

	self.model = model
	self.wheel = self:getDefaultWheel()
	self._connections = {}
	self._equippedAttrConnection = nil

	self:setAdornee(model:WaitForChild("PromptHolder"))
	self:setClickHitbox(model)

	local function update()
		self:updateOwnershipAndActions()
	end

	table.insert(self._connections, model:GetAttributeChangedSignal("owner"):Connect(update))
	table.insert(self._connections, model:GetAttributeChangedSignal("ServingsLeft"):Connect(update))
	table.insert(self._connections, model:GetAttributeChangedSignal("TotalServings"):Connect(update))
	table.insert(self._connections, model:GetAttributeChangedSignal("FoodServings"):Connect(update))
	table.insert(self._connections, model:GetAttributeChangedSignal("PortionToolName"):Connect(update))
	table.insert(self._connections, model:GetAttributeChangedSignal("OpenAnimationId"):Connect(update))
	table.insert(self._connections, model:GetAttributeChangedSignal("OpenIDAnim"):Connect(update))
	table.insert(self._connections, model:GetAttributeChangedSignal("Opened"):Connect(update))
	table.insert(self._connections, model:GetAttributeChangedSignal("Opening"):Connect(update))

	local function bindCharacter(character: Model)
		table.insert(self._connections, character.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then
				self:watchEquippedTool()
				update()
			end
		end))

		table.insert(self._connections, character.ChildRemoved:Connect(function(child)
			if child:IsA("Tool") then
				self:watchEquippedTool()
				update()
			end
		end))

		self:watchEquippedTool()
		update()
	end

	if player.Character then
		bindCharacter(player.Character)
	end

	table.insert(self._connections, player.CharacterAdded:Connect(bindCharacter))

	update()

	return self
end

function ToolInteractable:getPortionToolName(): string
	local portionToolName = self.model:GetAttribute("PortionToolName")

	if type(portionToolName) == "string" and portionToolName ~= "" then
		return portionToolName
	end

	return self.model.Name
end

function ToolInteractable:isOwnerAllowed(): boolean
	local owner = self.model:GetAttribute("owner")

	if owner and type(owner) == "string" and owner ~= "" and owner ~= player.Name then
		return false
	end

	return true
end

function ToolInteractable:watchEquippedTool()
	if self._equippedAttrConnection then
		self._equippedAttrConnection:Disconnect()
		self._equippedAttrConnection = nil
	end

	local tool = getEquippedTool()
	if not tool then
		return
	end

	self._equippedAttrConnection = tool:GetAttributeChangedSignal("ServingsLeft"):Connect(function()
		self:updateOwnershipAndActions()
	end)
end

function ToolInteractable:canReturnServing(): boolean
	if self.model:GetAttribute("FoodServings") ~= true then
		return false
	end

	if hasOpenAnimation(self.model) and self.model:GetAttribute("Opened") ~= true then
		return false
	end

	local equippedTool = getEquippedTool()
	if not equippedTool then
		return false
	end

	if equippedTool.Name ~= self:getPortionToolName() then
		return false
	end

	local toolServings = equippedTool:GetAttribute("ServingsLeft") or 0
	if toolServings <= 0 then
		return false
	end

	local servingsLeft = self.model:GetAttribute("ServingsLeft") or 0
	local totalServings = self.model:GetAttribute("TotalServings") or servingsLeft

	if servingsLeft >= totalServings then
		return false
	end

	return true
end

function ToolInteractable:clearActions()
	self.wheel.page:removeAction("Recoger")
	self.wheel.page:removeAction("Coger porción")
	self.wheel.page:removeAction("Dejar porción")
	self.wheel.page:removeAction("Abrir")
end

function ToolInteractable:updateOwnershipAndActions()
	if not self:isOwnerAllowed() then
		self:disable()
		return
	end

	self:enable()
	self:clearActions()

	local isFoodServings = self.model:GetAttribute("FoodServings") == true

	if not isFoodServings then
		self.wheel:setQuickAction("Recoger", self.pickup, self)
		self.wheel.page:addAction("Recoger", self.pickup, self)
		return
	end

	local requiresOpen = hasOpenAnimation(self.model)
	local opened = self.model:GetAttribute("Opened") == true
	local opening = self.model:GetAttribute("Opening") == true

	if requiresOpen and not opened then
		if opening then
			self:disable()
			return
		end

		self.wheel:setQuickAction("Abrir", self.openContainer, self)
		self.wheel.page:addAction("Abrir", self.openContainer, self)
		self.wheel.page:addAction("Recoger", self.pickup, self)
		return
	end

	local servingsLeft = self.model:GetAttribute("ServingsLeft") or 0
	local canReturnServing = self:canReturnServing()

	if servingsLeft > 0 then
		self.wheel:setQuickAction("Coger porción", self.takeServing, self)
		self.wheel.page:addAction("Coger porción", self.takeServing, self)
	else
		self.wheel:setQuickAction("Recoger", self.pickup, self)
	end

	if canReturnServing then
		self.wheel.page:addAction("Dejar porción", self.returnServing, self)
	end

	self.wheel.page:addAction("Recoger", self.pickup, self)
end

function ToolInteractable:openContainer()
	remotes.OpenFoodContainer:FireServer(self.model)
end

function ToolInteractable:takeServing()
	remotes.TakeFoodServing:FireServer(self.model)
end

function ToolInteractable:returnServing()
	remotes.ReturnFoodServing:FireServer(self.model)
end

function ToolInteractable:pickup()
	remotes.PickupTool:FireServer(self.model)
	self:disable()
end

function ToolInteractable:onDestroy()
	if self._equippedAttrConnection then
		self._equippedAttrConnection:Disconnect()
		self._equippedAttrConnection = nil
	end

	for _, connection in self._connections do
		connection:Disconnect()
	end

	self._connections = {}
end

return ToolInteractable