local module = {}
module.__index = module

local Event = Instance.new('BindableEvent',script)
local Player = game:GetService('Players').LocalPlayer

function module.new()
	local self = setmetatable({
		IsActive = false,
		actives = {},
		UIS = game:GetService('UserInputService'),
		ChangeInput = Event.Event,
		
		ListInputs = {
			[Enum.UserInputType.Touch.Name] = 1,
			
			[Enum.UserInputType.MouseMovement.Name] = 2,
			[Enum.UserInputType.MouseButton1.Name] = 2,
			[Enum.UserInputType.MouseButton2.Name] = 2,
			[Enum.UserInputType.MouseButton3.Name] = 2,
			[Enum.UserInputType.Keyboard.Name] = 2,
			[Enum.UserInputType.MouseWheel.Name] = 2,
			[Enum.UserInputType.TextInput.Name] = 2,
			
			[Enum.UserInputType.Gamepad1.Name] = 3,
			[Enum.UserInputType.Gamepad2.Name] = 3,
			[Enum.UserInputType.Gamepad3.Name] = 3,
			[Enum.UserInputType.Gamepad4.Name] = 3,
			[Enum.UserInputType.Gamepad5.Name] = 3,
			[Enum.UserInputType.Gamepad6.Name] = 3,
			[Enum.UserInputType.Gamepad7.Name] = 3,
			[Enum.UserInputType.Gamepad8.Name] = 3,
		},
		
		Message = {
			'Phone','Keyboard','Console'
		},
		
	},module)
	
	self:Start()
	
	return self
end

function module:Connect(Funct)
	if typeof(Funct) == 'function' then
		local active = self.ChangeInput:Connect(Funct)
		table.insert(self.actives,active)
		return active
	end
end

function module:GetStartInput()
	return self.UIS.TouchEnabled and Enum.UserInputType.Touch or self.UIS.GamepadEnabled and Enum.UserInputType.Gamepad1 or self.UIS.KeyboardEnabled and Enum.UserInputType.MouseButton1
end

function module:Change(Input:Enum.UserInputType)
	if Input then
		local LastInput = self.InputSelect
		local idk = self:GetStartInput()
		self.InputSelect = self.ListInputs[Input and Input.Name] or self.ListInputs[idk and idk.Name] or nil
		if LastInput ~= self.InputSelect then
			--warn(string.format('InputPlayer: %s', self.Message[self.InputSelect] or 'No found'))
			--self.UIS.MouseIconEnabled = self.InputSelect ~= 3
			Event:Fire()
		end
	end
end

function module:Start()
	if self.IsActive then return end
	self:Change(self:GetStartInput())
	table.insert(self.actives,self.UIS.LastInputTypeChanged:Connect(function(...) self:Change(...) end))
end

function module:Exit()
	if not self.IsActive then return end
	self.Gui.Parent = script
	for _,v:RBXScriptConnection in self.actives do v:Disconnect() end
	--self.UIS.MouseIconEnabled = true
	self.actives = {}
end

return module.new()
