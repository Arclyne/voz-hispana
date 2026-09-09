local module = {}
module.__index = module

local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folderSounds = Instance.new("Folder", game:GetService("ReplicatedStorage"))
folderSounds.Name = "SoundsAnimatorButtons"

local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))
local ButtonMotion = require(ReplicatedStorage.Shared:WaitForChild("ButtonMotion"))

function clear(active)
	if typeof(active) == 'table' then
		for _,v : RBXScriptConnection in active do
			if typeof(v) == 'RBXScriptConnection' then
				v:Disconnect()
			end
		end
		table.clear(active)
	end
end
function crearTween(object,timeani,final)
	return TweenService:Create(object,TweenInfo.new(timeani,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),final)
end

function AddObjectInList(Object, listFinal, ListBusqueda)
	if typeof(Object) == 'Instance' and typeof(listFinal) == 'table' and typeof(ListBusqueda) == 'table' then

		local unselectAnis = {}

		for _,dataTween in ListBusqueda do
			if dataTween.Object == Object then

				for index, value in listFinal do
					if not dataTween.DataEnd[index] then
						dataTween.DataEnd[index] = value
						unselectAnis[index] = Object[index]
					end
				end

				return unselectAnis
			end
		end

		for index,_ in listFinal do
			unselectAnis[index] = Object[index]
		end

		table.insert(ListBusqueda, {
			Object = Object,
			DataEnd = listFinal,
		})

		return unselectAnis

	end
end

local function PlaySound(soundOrId, volume)
	volume = volume or 0.2

	-- si te pasan un Sound instance
	if typeof(soundOrId) == "Instance" and soundOrId:IsA("Sound") then
		-- intenta sacar el id numérico del SoundId (rbxassetid://123)
		local id = tonumber(string.match(soundOrId.SoundId or "", "%d+"))
		if id then
			SoundManager:Play(nil, id, { Volume = volume })
		else
			-- fallback: clonarlo y play normal si no hay id parseable
			local clone = soundOrId:Clone()
			clone.Parent = game:GetService("SoundService")
			clone:Play()
			clone.Ended:Connect(function() clone:Destroy() end)
		end
		return
	end

	-- si te pasan un id directo
	if table.find({ "number", "string" }, typeof(soundOrId)) then
		SoundManager:Play(nil, soundOrId, { Volume = volume })
	end
end

-------------------------------------------------------------------------------------------------

function module.new(Button)
	if typeof(Button) == 'Instance' and (Button:IsA('TextButton') or Button:IsA('ImageButton')) then

		local self = setmetatable({
			gui = Button,

			enabled = false,
			TimeAni = .15,

			downAnis = {},
			selectAnis = {},
			unselectAnis = {},
			enterAnis = {},

			AnimProcess = {},

			ClickSound = nil,
			HoverSound = nil,
			SelectSound = nil,

			Bindable = Instance.new('BindableEvent', script),

		}, module)

		self.MouseButton1Click = self.Bindable.Event

		-- Este botón pasa a tener animación propia, así que el genérico de la
		-- tablet (ButtonMotion) se aparta: las dos juntas se sumarían. El unbind
		-- cubre el caso de que el barrido global se haya adelantado a este new(),
		-- y va ANTES de tocar AutoButtonColor porque restaura el valor original.
		Button:SetAttribute(ButtonMotion.SKIP_ATTRIBUTE, true)
		ButtonMotion.unbind(Button)

		Button.AutoButtonColor = false

		Button.AncestryChanged:Connect(function(_,parent)
			if parent then return end
			self:removed()
		end)

		return self

	end
end

-------------------------------------------------------------------------------------------------

function module:ChangeTimeAnimation(number)
	self.TimeAni = tonumber(number) or self.TimeAni
end

-------------------------------------------------------------------------------------------------

function module:DownAction(Frame, Action)
	Frame = typeof(Frame)=='Instance' and Frame or self.gui
	Action = typeof(Action)=='table' and Action or {}
	local data = AddObjectInList(Frame,Action,self.downAnis)
	if data then
		self:UnSelectedAction(Frame, data)
	end
end
function module:EnterAction(Frame, Action)
	Frame = typeof(Frame)=='Instance' and Frame or self.gui
	Action = typeof(Action)=='table' and Action or {}
	local data = AddObjectInList(Frame,Action,self.enterAnis)
	if data then
		self:UnSelectedAction(Frame, data)
	end
end
function module:SelectedAction(Frame, Action)
	Frame = typeof(Frame)=='Instance' and Frame or self.gui
	Action = typeof(Action)=='table' and Action or {}
	local data = AddObjectInList(Frame,Action,self.selectAnis)
	if data then
		self:UnSelectedAction(Frame, data)
	end
end
function module:UnSelectedAction(Frame, Action)
	Frame = typeof(Frame)=='Instance' and Frame or self.gui
	Action = typeof(Action)=='table' and Action or {}
	AddObjectInList(Frame,Action,self.unselectAnis)
end
function module:AddEffectSound(TypeSound, Sound)
	if table.find({"number","string"}, typeof(Sound)) then
		local SounId = typeof(Sound) == "number"
			and string.format("rbxassetid://%d", Sound)
			or Sound

		local existing = folderSounds:FindFirstChild(SounId)
		if existing then
			Sound = existing
		else
			local newSound = Instance.new("Sound")
			newSound.SoundId = SounId
			newSound.Name = SounId
			newSound.Parent = folderSounds
			Sound = newSound
		end
	end

	if not (typeof(Sound) == "Instance" and Sound:IsA("Sound")) then return end

	if TypeSound == "Click" then
		self.ClickSound = Sound
	elseif TypeSound == "Hover" then
		self.HoverSound = Sound
	elseif TypeSound == "Select" then
		self.SelectSound = Sound
	end
end

-------------------------------------------------------------------------------------------------

function module:DesactiveAni()
	for _,v in self.AnimProcess do v:Cancel() end
	clear(self.AnimProcess)
end
function module:PlayTween(ListAnimations, NoTween)
	if typeof(ListAnimations) == "table" then
		for _,dataTween in ListAnimations do
			local list
			for index,value in dataTween.DataEnd do
				if NoTween or table.find({"boolean","string","ColorSequence","NumberSequence"}, typeof(value)) then
					dataTween.Object[index] = value
				else
					list = list or {}
					list[index] = value
				end
			end
			if list then
				local tween = crearTween(dataTween.Object,self.TimeAni,list)
				tween:Play()
				table.insert(self.AnimProcess, tween)
			end
		end
	end
end

-------------------------------------------------------------------------------------------------

function module:Down(NoTween)
	if not self.enabled then return end
	self:DesactiveAni()
	self:PlayTween(self.downAnis, NoTween)
end
function module:Enter(NoTween)
	if not self.enabled then return end
	self:DesactiveAni()
	self:PlayTween(self.enterAnis, NoTween)
end

function module:Select(NoTween)
	if not self.enabled then return end
	self:DesactiveAni()
	PlaySound(self.SelectSound)
	self.SelectedActive = true
	self:PlayTween(self.selectAnis, NoTween)
end
function module:UnSelect(UnSelect,NoTween)
	if not UnSelect and self.SelectedActive then return self:Select(NoTween) end
	self.SelectedActive = nil

	self:DesactiveAni()
	self:PlayTween(self.unselectAnis, NoTween)
end

-------------------------------------------------------------------------------------------------

function module:Connect(conexion)
	if self.enabled then return self  end
	self.gui.Interactable = true
	self.enabled = {}

	table.insert(self.enabled, self.gui.MouseEnter:Connect(function()
		PlaySound(self.HoverSound)
		self:Enter()
	end))
	table.insert(self.enabled, self.gui.MouseLeave:Connect(function() self:UnSelect() end))

	table.insert(self.enabled, self.gui.MouseButton1Down:Connect(function() self:Down() end))
	table.insert(self.enabled, self.gui.MouseButton1Up:Connect(function() self:Enter() end))

	if typeof(conexion) == 'function' then
		table.insert(self.enabled, self.gui.MouseButton1Click:Connect(function()
			PlaySound(self.ClickSound)
			conexion()
		end))
	end

	table.insert(self.enabled,self.gui.SelectionGained:Connect(function() PlaySound(self.HoverSound) self:Enter() end))
	table.insert(self.enabled,self.gui.SelectionLost:Connect(function() self:UnSelect() end))

	self:UnSelect()

	return self
end
function module:Disconnect()
	if not self.enabled then return end
	self.gui.Interactable = false
	clear(self.enabled)
	self:UnSelect(true)
	self.enabled = nil
end

function module:removed()
	self:Disconnect()
	table.clear(self)
	self = nil
end

-------------------------------------------------------------------------------------------------

return module
