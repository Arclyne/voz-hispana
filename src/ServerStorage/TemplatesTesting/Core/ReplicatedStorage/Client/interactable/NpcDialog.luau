-- NpcDialog.lua
-- Interactable que consume una "config" de diálogo y usa DialogModule con tu CustomPrompt.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

local Interactable  = require(script.Parent.Interactable)
local DialogModule  = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DialogModule"))

local DialogsFolder = ReplicatedStorage:WaitForChild("Shared"):FindFirstChild("Dialogs")
local Remotes       = ReplicatedStorage:WaitForChild("Events")

local NpcDialog = {}
NpcDialog.__index = NpcDialog
setmetatable(NpcDialog, Interactable)

-- Local helpers --------------------------------------------------------------

local function resolveParts(model: Model)
	-- Donde se ancla el prompt visual (Billboard/adornee) y el hitbox de click:
	local adornee = model:FindFirstChild("Prompt") or model:FindFirstChild("Head") or model.PrimaryPart
	return adornee, model
end

local function loadConfigForModel(model: Model)
	-- 1) Config específica por instancia (ModuleScript hijo "DialogConfig")
	local childConfig = model:FindFirstChild("DialogConfig")
	if childConfig and childConfig:IsA("ModuleScript") then
		return require(childConfig)
	end

	-- 2) Config compartida por id (atributo "DialogId" → ReplicatedStorage/Dialogs/<id>.lua)
	local id = model:GetAttribute("DialogId")
	if id and type(id) == "string" and DialogsFolder then
		local mod = DialogsFolder:FindFirstChild(id)
		if mod and mod:IsA("ModuleScript") then
			return require(mod)
		end
	end

	-- 3) Fallback mínimo
	return {
		displayName = model:GetAttribute("NpcName") or model.Name,
		actionName  = "Hablar",
		start       = 1,
		nodes       = {
			[1] = { text = "Hola.", responses = { "Hasta luego" }, next = "__CLOSE__" }
		},
	}
end

-- API ------------------------------------------------------------------------

function NpcDialog.new(model: Model)
	local self = Interactable.new()
	setmetatable(self, NpcDialog)

	self.model  = model
	self.config = loadConfigForModel(model)
	self._conns = {}

	-- Prompt y hitbox
	local adornee, hitbox = resolveParts(model)
	if adornee then self:setAdornee(adornee) end
	if hitbox  then self:setClickHitbox(hitbox) end

	-- Crea el DialogObject usando TU CustomPrompt (no ProximityPrompt nativo)
	local displayName = self.config.displayName or model:GetAttribute("NpcName") or model.Name
	self.dialogObject = DialogModule.new(displayName, model, self.customPrompt)

	-- Cargar nodos visibles en el DialogModule
	for id, node in pairs(self.config.nodes or {}) do
		-- Solo textos/labels de respuestas
		local labels = {}
		for _, resp in ipairs(node.responses or {}) do
			if typeof(resp) == "string" then
				table.insert(labels, resp)
			elseif typeof(resp) == "table" and typeof(resp.text) == "string" then
				table.insert(labels, resp.text)
			end
		end
		self.dialogObject:addDialog(node.text or "", labels)
	end

	-- Acción rápida "Hablar"
	self.wheel = self:getDefaultWheel()
	local actionName = self.config.actionName or "Hablar"
	self.wheel:setQuickAction(actionName, self._startDialog, self)
	self.wheel.page:addAction(actionName, self._startDialog, self)

	-- Routing de respuesta → next/event
	table.insert(self._conns, self.dialogObject.responded:Connect(function(responseNum, dialogNum)
		self:_handleResponse(responseNum, dialogNum)
	end))

	-- Cuando el diálogo termina (por cierre o por distancia), desbloquear y restaurar UI
	table.insert(self._conns, self.dialogObject.closed:Connect(function(reason)
		self:_closeDialog()
	end))

	-- Si el NPC se destruye, cerrar diálogo por si acaso
	table.insert(self._conns, model.AncestryChanged:Connect(function(_, parent)
		if not parent then self:_closeDialog(true) end
	end))

	return self
end

function NpcDialog:_startDialog()
	self:lockWheel("default")
	-- No hace falta self.customPrompt:disable() aquí: lo hace DialogModule al abrir
	local startId = self.config.start or 1
	self.dialogObject:triggerDialog(Players.LocalPlayer, startId)
	self:disable()
end

-- Resuelve transiciones y eventos definidos en la config
function NpcDialog:_handleResponse(respIdx: number, dialogId: number)
	local node = (self.config.nodes or {})[dialogId]
	if not node then
		self:_closeDialog()
		return
	end

	local resp   = node.responses and node.responses[respIdx]
	local choice = typeof(resp) == "table" and resp or nil

	local function goNext(nxt)
		if typeof(nxt) == "number" then
			self.dialogObject:triggerDialog(Players.LocalPlayer, nxt)
			return true
		elseif typeof(nxt) == "string" then
			if nxt == "__CLOSE__" then
				self.dialogObject:hideGui()
				self:_closeDialog()
				return true
			elseif string.sub(nxt, 1, 14) == "__CLOSE_WITH__" then
				local msg = string.sub(nxt, 15)
				self.dialogObject:hideGui(msg ~= "" and msg or nil)
				self:_closeDialog()
				return true
			elseif string.sub(nxt, 1, 9) == "__EVENT__" then
				local eventName = string.gsub(nxt, "^__EVENT__:?","")
				self:_dispatchEvent(eventName, { dialogId = dialogId, responseIndex = respIdx, response = choice })
				-- cerrar por defecto salvo que config pida "stay"
				if self.config.afterEvent == "stay" and node.afterEvent ~= "close" then
					return false
				else
					self.dialogObject:hideGui()
					self:_closeDialog()
					return true
				end
			end
		end
		return false
	end

	-- 1) transición/evento específico de la opción
	if choice then
		if choice.event and type(choice.event) == "string" then
			goNext("__EVENT__:" .. choice.event); return
		end
		if choice.next and goNext(choice.next) then return end
	end

	-- 2) transición por función del nodo
	if typeof(node.next) == "function" then
		local nxt = node.next(respIdx, choice)
		if goNext(nxt) then return end
	end

	-- 3) transición literal del nodo
	if node.next ~= nil and goNext(node.next) then return end

	-- Fallback: cerrar
	self.dialogObject:hideGui()
	self:_closeDialog()
end

function NpcDialog:_dispatchEvent(eventName: string, ctx)
	local context = {
		model        = self.model,
		player       = Players.LocalPlayer,
		remotes      = Remotes,
		dialogObject = self.dialogObject,
		config       = self.config,
		payload      = ctx,
	}

	-- Handler cliente opcional
	if self.config.onEvent and typeof(self.config.onEvent) == "function" then
		local ok, err = pcall(self.config.onEvent, context, eventName)
		if not ok then warn("[NpcDialog] onEvent error:", err) end
	end

	-- Evento genérico al servidor (opcional)
	local generic = Remotes:FindFirstChild("NpcDialogGeneric")
	if generic and generic:IsA("RemoteEvent") then
		generic:FireServer(self.model, eventName, ctx)
	end
end

function NpcDialog:_closeDialog(force: boolean?)
	if self.dialogObject and force then
		pcall(function() self.dialogObject:hideGui() end)
	end
	self:unlock()

	-- Si el prompt visual está en rango y no hay páginas activas, puede mostrarse
	if self.promptIsVisible and self.selectedWheel and not self.selectedWheel:getActivePage() then
		-- enable ya lo hace DialogModule; aquí solo mostramos si quieres feedback instantáneo:
		self.customPrompt:show()
	end
	self:enable()
end

function NpcDialog:onDestroy()
	for _, c in ipairs(self._conns) do
		if c and c.Disconnect then c:Disconnect() end
	end
	self._conns = {}

	if self.dialogObject and typeof(self.dialogObject.destroy) == "function" then
		self.dialogObject:destroy()
	end
end

return NpcDialog
