local module = {}
module.__index = module

local UIS = game:GetService('UserInputService')
local RunS = game:GetService('RunService')
local EventCustom = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("Event"))

function IsDownInput(InputObject : InputObject)
	local UserInputType = InputObject.UserInputType
	return UserInputType==Enum.UserInputType.MouseButton1 or
		(UserInputType==Enum.UserInputType.Touch and InputObject.UserInputState==Enum.UserInputState.Begin)
end

function clear(active, ...)
	if typeof(active) == 'table' then
		local params = {...}
		if #params > 0 then
			for _,v in params do
				if active[v] then
					active[v]:Disconnect()
					active[v] = nil
				end
			end
		else
			for _,v : RBXScriptConnection in active do
				if typeof(v) == 'RBXScriptConnection' then
					v:Disconnect()
				end
			end
			table.clear(active)
		end
	end
end

function searchBase(BaseGui : GuiBase)
	if not BaseGui then return end
	if BaseGui:IsA("ScreenGui") or BaseGui:IsA("BillboardGui") or BaseGui:IsA("SurfaceGui") then
		return not BaseGui:IsA("ScreenGui") and BaseGui
	else
		return searchBase(BaseGui.Parent)
	end
end

function module.new(BaseGui : GuiBase)
	
	if typeof(BaseGui) == 'Instance' and BaseGui:IsA('GuiBase') then
		
		local self = setmetatable({

			Button = BaseGui,
			resultado = 100,--//100%
			listPorcentajes = {},
			listArrows = {},
			listBars = {},
			actual = 0,
			ScreenGui = searchBase(BaseGui),
			Changed = EventCustom.new(),
			
		}, module)
		
		return self
		
	end
	
end

function module:changeResultado(number)
	number = tonumber(number) or 0
	self.resultado = number > 0 and math.clamp(math.floor(number), 10, 100) or math.max(0, number)
end

function module:changed(x, state)
	
	x = tonumber(x) or 0
	x = math.clamp(self.resultado > 0 and (math.round(x * self.resultado) / self.resultado) or x,0,1)
	
	for _,v : Frame in self.listArrows do
		if v:GetAttribute("WithAnchorPoint") then
			v.AnchorPoint = Vector2.new(x,v.AnchorPoint.Y)
		end
		v.Position = UDim2.new(x,0,v.Position.Y.Scale,v.Position.Y.Offset)
	end
	
	local porcentaje = x * 100
	
	for _,v : TextLabel in self.listPorcentajes do
		v.Text = string.format('%d%%',porcentaje)
	end
	
	for _,v : Frame in self.listBars do
		
		local X = 1 - math.abs(math.sign(v.AnchorPoint.X))
		local Y = 1 - math.abs(math.sign(v.AnchorPoint.Y))
		
		v.Size = UDim2.fromScale(X==1 and x or v.Size.X.Scale, Y==1 and x or v.Size.Y.Scale)
	end
	
	if x ~= self.actual or state == Enum.UserInputState.End then
		self.actual = x
		if not state then return end
		self.Changed:Fire(x, state)
	end
	
end

function module:AddedPorcentaje(gui : TextLabel)
	
	if typeof(gui) == 'Instance' and (gui:IsA('TextLabel') or gui:IsA('TextBox')) then
		table.insert(self.listPorcentajes, gui)
		self:changed(self.actual)
		if gui:IsA('TextBox') and self.active then
			table.insert(self.active, gui:GetPropertyChangedSignal('Text'):Connect(function()
				if not gui:IsFocused() then return end
				gui.Text = tostring(math.round(tonumber(gui.Text) or 0))
				if gui.Text == "0" then
					gui.CursorPosition = 2
				end
			end))
			table.insert(self.active, gui.FocusLost:Connect(function()
				self:changed(math.clamp(math.round(tonumber(gui.Text) or 0),0,100) / 100, Enum.UserInputState.End)
			end))
		end
	end
	
end

function module:AddedArrow(gui : Frame, AndhorPoint)
	
	if typeof(gui) == 'Instance' and gui:IsA('GuiBase') and gui:IsDescendantOf(self.Button) then
		gui:SetAttribute("WithAnchorPoint", AndhorPoint)
		table.insert(self.listArrows, gui)
		self:changed(self.actual)
	end
	
end

function module:AddedBar(gui : Frame)

	if typeof(gui) == 'Instance' and gui:IsA('GuiBase') and gui:IsDescendantOf(self.Button) then
		table.insert(self.listBars, gui)
		self:changed(self.actual)
	end

end

function module:GetX(X, start)
	local AbsolutePosition = self.Button.AbsolutePosition.X
	
	if not start and self.ScreenGui and self.ScreenGui.Adornee then
		local Position : Vector3 = self.ScreenGui.Adornee:GetPivot().Position
		local camera = workspace.CurrentCamera
		local Screen, _ = camera:WorldToScreenPoint(Position)
		AbsolutePosition += math.clamp(Screen.X, 0, camera.ViewportSize.X) - (self.ScreenGui.AbsoluteSize.X/2)
	end
	
	return (X - AbsolutePosition) / self.Button.AbsoluteSize.X
end

function module:up()
	clear(self.active, "up", "changed")
	if self.Button:IsA("ScrollingFrame") then
		--Instance.new("")
	end
end

function module:down(input : InputObject, processed)
	if not self.active or processed or self.active['up'] or not IsDownInput(input) then return end

	self:changed(self:GetX(input.Position.X, true),Enum.UserInputState.Begin)
	local IsTouch = input.UserInputType == Enum.UserInputType.Touch
	local InputEnded = IsTouch and UIS.TouchEnded or UIS.InputEnded
	self.active['up'] = UIS.InputEnded:Connect(function(input2 : InputObject)
		if input2 == input or input2.UserInputType == input.UserInputType then
			self:changed(self.actual, Enum.UserInputState.End)
			self:up()
		end
	end)
	
	local InputChanged = IsTouch and UIS.TouchMoved or UIS.InputChanged
	self.active['changed'] = InputChanged:Connect(function(input2 : InputObject)
		if input2 == input or input2.UserInputType == Enum.UserInputType.MouseMovement then
			self:changed(self:GetX(input2.Position.X), Enum.UserInputState.Change)
			--self:up()
		end
	end)
	
end

function module:IsButtonDown()
	return self.active and self.active["up"]
end

function module:enabled()
	if self.active then return end
	self.active = {}
	for _,gui : TextLabel in self.listPorcentajes do
		if gui:IsA('TextBox') then
			table.insert(self.active, gui:GetPropertyChangedSignal('Text'):Connect(function()
				if not gui:IsFocused() then return end
				gui.Text = tostring(math.round(tonumber(gui.Text) or 0))
				if gui.Text == "0" then
					gui.CursorPosition = 2
				end
			end))
			table.insert(self.active, gui.FocusLost:Connect(function()
				self:changed(math.clamp(math.round(tonumber(gui.Text) or 0),0,100) / 100, Enum.UserInputState.End)
			end))
		end
	end
	table.insert(self.active, self.Button.InputBegan:Connect(function(...) self:down(...) end))
	for _,v in self.listArrows do
		table.insert(self.active, v.InputBegan:Connect(function(...) self:down(...) end))
	end
end

function module:disabled()
	if not self.active then return end
	self:up()
	self.active = clear(self.active)
end

return module
