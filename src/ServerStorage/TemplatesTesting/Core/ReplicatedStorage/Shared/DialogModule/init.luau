-- DialogModule.lua
-- Controla la UI de diálogo del NPC. Es agnóstico a ProximityPrompt:
-- recibe un "prompt-like" (tu CustomPrompt) con .enable() / .disable().

local DialogModule = {}
DialogModule.__index = DialogModule

--// Services
local TweenService       = game:GetService("TweenService")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local Players            = game:GetService("Players")
local SoundService 		 = game:GetService("SoundService")
local Debris 			 = game:GetService("Debris")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")

local EventFocus   		 = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Interactable"):WaitForChild("FocusNpcDialog")

--// Locals
local player = Players.LocalPlayer
local TICK_SOUND     = script.sounds.tick
local END_TICK_SOUND = script.sounds.tick2
local maxDistance = 15

-- Helper: reproduce un tick clonando el sonido base
local function playTick(base: Sound)
	if not base or not base:IsA("Sound") then return end
	local s = base:Clone()
	s.Parent = SoundService         -- aseguramos un parent válido de audio
	s:Play()
	Debris:AddItem(s, 2)            -- limpiar automáticamente
end

-- UI: contenedor de respuestas del jugador (debe existir en PlayerGui)
local DIALOG_RESPONSES_UI = player:WaitForChild("PlayerGui")
	:WaitForChild("dialog")
	:WaitForChild("dialogResponses")

-- Asegura que existan N botones numerados "1" .. "N" dentro del contenedor
local function ensureResponseButtons(container: Instance, count: number)
	local template = container:FindFirstChild("template")
	if not template or not template:IsA("GuiButton") then
		warn("[DialogModule] Falta 'template' en dialogResponses (debe ser GuiButton).")
		return
	end
	for i = 1, count do
		local name = tostring(i)
		if not container:FindFirstChild(name) then
			local btn = template:Clone()
			btn.Name = name
			btn.Parent = container
			btn.Visible = false
		end
	end
end

-- Coge texto visible de una respuesta que puede ser string o tabla { text = "...", ... }
local function getResponseText(resp)
	if typeof(resp) == "table" then
		return tostring(resp.text or "")
	end
	return tostring(resp or "")
end

--// Constructor
function DialogModule.new(npcName: string, npc: Model, customPrompt, animation: string?)
	local self = setmetatable({}, DialogModule)

	self.npcName     = npcName
	self.npc         = npc
	self.dialogs     = {}   -- { { text=string, responses={...} }, ... }
	self.dialogOption= 1
	self.active      = false
	self.talking     = false
	self.customPrompt= customPrompt

	-- BillboardGui en "Head/gui" (ajusta si tu jerarquía es distinta)
	self.npcGui      = npc:WaitForChild("Head"):WaitForChild("gui")

	-- Eventos públicos:
	local respondedBE = Instance.new("BindableEvent")
	self.responded    = respondedBE.Event           -- (responseIndex, dialogIndex)
	self._fireResponded = respondedBE

	local closedBE = Instance.new("BindableEvent")
	self.closed     = closedBE.Event                -- (reason: "closed" | "out_of_range" | "exit_quip")
	self._fireClosed= closedBE

	-- Asegura botones 1..9
	ensureResponseButtons(DIALOG_RESPONSES_UI, 9)

	-- Tweens
	self.animNameText    = TweenService:Create(self.npcGui.name,              TweenInfo.new(.3), {TextTransparency = 1})
	self.animNameStroke  = TweenService:Create(self.npcGui.name.UIStroke,     TweenInfo.new(.3), {Transparency = 1})
	self.animArrowText   = TweenService:Create(self.npcGui.arrow,             TweenInfo.new(.3), {TextTransparency = 1})
	self.animArrowStroke = TweenService:Create(self.npcGui.arrow.UIStroke,    TweenInfo.new(.3), {Transparency = 1})
	self.animDialogText  = TweenService:Create(self.npcGui.dialog,            TweenInfo.new(.3), {TextTransparency = 1})
	self.animDialogStroke= TweenService:Create(self.npcGui.dialog.UIStroke,   TweenInfo.new(.3), {Transparency = 1})

	-- Animación opcional del NPC
	if animation ~= nil then
		local newAnimation = Instance.new("Animation")
		newAnimation.AnimationId = animation
		local newAnimLoaded = npc:WaitForChild("Humanoid"):LoadAnimation(newAnimation)
		newAnimLoaded:Play()
	end

	-- Mostrar nombre del NPC
	local nameLabel = self.npcGui:FindFirstChild("name")
	if nameLabel and nameLabel:IsA("TextLabel") then
		nameLabel.Text = tostring(self.npcName)
	end

	-- Efecto flotante del Billboard
	local frameCount = 0
	self._heartbeat = RunService.Heartbeat:Connect(function()
		frameCount += 1
		if self.talking then
			self.npcGui.StudsOffset = Vector3.new(0, 1.6, 0)
		else
			self.npcGui.StudsOffset = Vector3.new(0, math.sin(frameCount/25)/6 + 1.55, 0)
		end
	end)

	return self
end

-- Añade un diálogo { text = "xxx", responses = { "...", "...", ... } }
function DialogModule:addDialog(dialogText: string, responseOptions: {any})
	table.insert(self.dialogs, { text = dialogText, responses = responseOptions })
end

function DialogModule:sortDialogs(sortFunc)
	table.sort(self.dialogs, sortFunc or function(a, b) return a.text < b.text end)
end

-- Muestra la UI de diálogo y prepara estados
function DialogModule:showGui()
	self.npcGui.AlwaysOnTop = true
	
	self.OriginalPosition = self.npc:GetPivot()
	if player.Character then
		local lockAt = (player.Character:GetPivot().Position-self.OriginalPosition.Position) * Vector3.new(1,0,1)
		self.npc:PivotTo(CFrame.lookAt(self.OriginalPosition.Position, self.OriginalPosition.Position + lockAt.Unit))
	end
	
	EventFocus:FireServer(self.npc, true)

	self.animNameText:Play()
	self.animNameStroke:Play()
	self.animArrowText:Play()
	self.animArrowStroke:Play()

	self.animDialogText:Cancel()
	self.animDialogStroke:Cancel()

	self.npcGui.dialog.TextTransparency = 0
	self.npcGui.dialog.UIStroke.Transparency = 0

	coroutine.wrap(function()
		task.wait(0.3)
		if self.npcGui.name.TextTransparency ~= 1 then return end
		self.npcGui.name.Visible  = false
		self.npcGui.arrow.Visible = false
	end)()
end

-- Oculta la UI y notifica cierre (razón se envía desde quien llame, por defecto "closed")
function DialogModule:hideGui(exitQuip: string?, notActuallyAnExitQuip: boolean?)
	self.active  = false
	self.talking = true
	local softExit = notActuallyAnExitQuip or false

	-- Re-habilita tu CustomPrompt al cerrar
	if self.customPrompt and typeof(self.customPrompt.enable) == "function" then
		self.customPrompt:enable()
	end
	
	if self.OriginalPosition then
		self.npc:PivotTo(self.OriginalPosition)
	end
	
	EventFocus:FireServer(self.npc, false)

	self.talking = false
	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = softExit and 65 or 70
	}):Play()

	-- Ocultar opciones del jugador
	for _, option in DIALOG_RESPONSES_UI:GetChildren() do
		if option:IsA("GuiButton") then
			option.Visible = false
		end
	end

	local dialogObject = self.npcGui.dialog
	if exitQuip then
		dialogObject.TextTransparency = 0
		dialogObject.UIStroke.Transparency = 0
		self.npcGui.name.TextTransparency   = 1
		self.npcGui.name.UIStroke.Transparency = 1
		self.npcGui.arrow.TextTransparency  = 1
		self.npcGui.arrow.UIStroke.Transparency = 1

		local currenttext, skip, arrow = "", false, 0
		dialogObject.Text = ""
		dialogObject.Visible = true
		for _, letter in string.split(exitQuip, "") do
			if dialogObject.Text ~= currenttext and skip == 0 then warn("other dialog happening") break end
			currenttext = currenttext .. letter
			if letter == "<" then skip = true end
			if letter == ">" then skip = false arrow += 1 continue end
			if arrow == 2 then arrow = 0 end
			if skip then continue end
			dialogObject.Text = currenttext .. (arrow == 1 and "</font>" or "")
			playTick(TICK_SOUND)
			task.wait(0.02)
		end
		dialogObject.Text = exitQuip
		if softExit then return end
	end

	task.spawn(function()
		if exitQuip then
			task.wait(2)
			if dialogObject.Text ~= exitQuip then return end
		end

		if self.npcGui.name.TextTransparency ~= 1 then
			self.animNameText:Cancel()
			self.animNameStroke:Cancel()
			self.animArrowText:Cancel()
			self.animArrowStroke:Cancel()
		end

		self.npcGui.name.TextTransparency  = 0
		self.npcGui.name.UIStroke.Transparency = 0
		self.npcGui.arrow.TextTransparency = 0
		self.npcGui.arrow.UIStroke.Transparency = 0
		self.npcGui.name.Visible  = true
		self.npcGui.arrow.Visible = true

		self.animDialogText:Play()
		self.animDialogStroke:Play()
		self.npcGui.AlwaysOnTop = false

		if self._fireClosed then
			self._fireClosed:Fire("closed")
		end
	end)
end

-- Inicia el diálogo en el índice indicado (o el actual)
function DialogModule:triggerDialog(playerArg: Player?, questionNumber: number?)
	-- Desactiva tu prompt mientras se habla (para que no moleste la overlay)
	if self.customPrompt and typeof(self.customPrompt.disable) == "function" then
		self.customPrompt:disable()
	end

	self:showGui()

	if #self.dialogs == 0 then
		warn("No dialogs available for NPC: " .. self.npcName)
		return
	end

	local dialogNum = questionNumber or self.dialogOption
	local dialog = self.dialogs[dialogNum]

	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = 65 }):Play()

	task.spawn(function()
		self.talking = true

		-- Escribe el texto con efecto
		local dialogObject = self.npcGui.dialog
		dialogObject.Visible = true
		dialogObject.Text = ""
		local currenttext, skip, arrow = "", false, 0
		for _, letter in string.split(dialog.text, "") do
			currenttext = currenttext .. letter
			if letter == "<" then skip = true end
			if letter == ">" then skip = false arrow += 1 continue end
			if arrow == 2 then arrow = 0 end
			if skip then continue end
			dialogObject.Text = currenttext .. (arrow == 1 and "</font>" or "")
			playTick(TICK_SOUND)
			task.wait(0.02)
		end
		dialogObject.Text = dialog.text
		self.talking = false

		-- Teclas numéricas 1..9
		local keyboardInputs = {
			Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three,
			Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six,
			Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine,
		}

		-- Renderiza opciones (1..N)
		local uiResponses = DIALOG_RESPONSES_UI
		local responseNum = nil

		for i, response in ipairs(dialog.responses) do
			local option = uiResponses:FindFirstChild(tostring(i))
			if not option or not option:IsA("GuiButton") then
				warn(("[DialogModule] Falta botón %d en dialogResponses"):format(i))
				break
			end

			local label = getResponseText(response)
			option.text.Text = ("<font color='rgb(121, 197, 255)'>%d.)</font> ''%s''"):format(i, label)
			option.Size = UDim2.fromScale(option.Size.X.Scale, .4)
			option.text.Position = UDim2.new(0.02, 0, 0.5, 0)
			option.Visible = true

			TweenService:Create(option, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(option.Size.X.Scale, 0, 0.35, 0)
			}):Play()

			local enterCon = option.MouseEnter:Connect(function()
				TweenService:Create(option, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(option.Size.X.Scale + (option.Size.X.Scale * .05), 0, 0.4, 0)
				}):Play()
				TweenService:Create(option.text, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.new(0.06, 0, 0.5, 0)
				}):Play()
				playTick(END_TICK_SOUND)
			end)

			local leaveCon = option.MouseLeave:Connect(function()
				TweenService:Create(option, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(option.Size.X.Scale, 0, 0.35, 0)
				}):Play()
				TweenService:Create(option.text, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.new(0.02, 0, 0.5, 0)
				}):Play()
			end)

			local chooseCon = option.MouseButton1Down:Connect(function()
				if not self.active then return end
				self.active = false
				responseNum = i
				self._fireResponded:Fire(i, dialogNum)
				playTick(TICK_SOUND)
			end)

			local numberpressCon = UserInputService.InputBegan:Connect(function(input, gameprocessed)
				if gameprocessed then return end
				if input.UserInputType == Enum.UserInputType.Keyboard then
					local numberinput = table.find(keyboardInputs, input.KeyCode)
					if (numberinput ~= nil and numberinput == i) then
						if not self.active then return end
						self.active = false
						responseNum = i
						self._fireResponded:Fire(i, dialogNum)
						playTick(TICK_SOUND)
					end
				end
			end)

			coroutine.wrap(function()
				repeat task.wait() until responseNum ~= nil
				enterCon:Disconnect(); leaveCon:Disconnect(); chooseCon:Disconnect(); numberpressCon:Disconnect()
				option.Visible = false
			end)()

			playTick(END_TICK_SOUND)
			task.wait(0.2)
		end

		self.active = true

		-- Salida por distancia
		while self.active do
			local Character = player.Character
			if not Character then break end
			local OriginalPosition = self.OriginalPosition
			if not OriginalPosition then break end
			local lockAt = Character:GetPivot().Position-OriginalPosition.Position
			local distance = lockAt.Magnitude
			if distance > maxDistance then
				self:hideGui()
				if self._fireClosed then self._fireClosed:Fire("out_of_range") end
				break
			end
			lockAt *= Vector3.new(1,0,1)
			local alpha = 10 * task.wait()
			if not self.active then break end
			self.npc:PivotTo(self.npc:GetPivot():Lerp(CFrame.lookAt(OriginalPosition.Position, OriginalPosition.Position + lockAt.Unit), alpha))
		end
	end)
end

function DialogModule:nextOption()
	self.dialogOption += 1
	if #self.dialogs < self.dialogOption then
		warn("No next dialog option for, " .. self.npcName)
		self.dialogOption -= 1
	end
	return self.dialogOption
end

return DialogModule
