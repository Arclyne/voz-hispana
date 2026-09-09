local module = {}

module.__index = module

export type Prompt = {
	Precio : number,
	NombreItem : string,
}

function module.new()
	return setmetatable({
		actives = {},
		Gui = script:WaitForChild('FrameBuy'),
		Parent = game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui'),
		TimeAnimation = .3,
		Tween = game:GetService('TweenService'),
	}, module)
end

function module:Prompt(...)
	if self.YaHayFuncion then return end
	self.YaHayFuncion = true
	self:CrearAccion(...)
end

function module:CrearAnimacion(timee, Posi)
	local Gui:Frame = self.GuiClone
	local twee = self.Tween:Create(Gui,TweenInfo.new(timee,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{Position = Gui.Position+UDim2.fromScale(0,1 * Posi)})
	return twee
end

function module:InputPlayerChanged()
	if self.YaHayFuncion and self.GuiClone then
		local InputPlayer = self.InputPlayer.InputSelect
		self.GuiClone.Cancel.Gamepad.Visible = InputPlayer == 3
		self.GuiClone.Purchase.Gamepad.Visible = InputPlayer == 3
	else
		self:Exit()
	end
end


function module:IsOutFrame(posi:Vector2)
	local p = (posi - self.GuiClone.AbsolutePosition) / self.GuiClone.AbsoluteSize
	p = p.X > 0 and p.X < 1 and p.Y > 0 and p.Y < 1
	return not p
end

function module:CrearAccion(datos : Prompt, Funcion)
	local cloneScreen = self.Gui:Clone()
	local clone = cloneScreen.frame
	clone.Prugunta.Text = datos.Pregunta or 'Are you sure?'
	clone.Purchase.Text_.Text = tostring(tonumber(datos.Precio) or 'Continue')
	clone.TextLabel.Text = tonumber(datos.Precio) and 'Buy' or 'Warn'
	
	cloneScreen.Parent = self.Parent
	
	self.GuiClone = clone

	clone.Purchase.Gamepad.Position = UDim2.new(.5,(clone.Purchase.Text_.TextBounds.X / 2) + 2,.5,0)
	clone.Cancel.Gamepad.Position = UDim2.new(.5,(clone.Cancel.Text_.TextBounds.X / 2) + 2,.5,0)
	self:InputPlayerChanged()
	
	local animation:Tween = self:CrearAnimacion(self.TimeAnimation, 1)
	self.actives['TweeActive'] = animation.Completed:Connect(function()
		if self.actives['TweeActive'] then
			self.actives['TweeActive']:Disconnect()
			self.actives['TweeActive'] = nil
		end
		table.insert(self.actives, clone.Purchase.MouseButton1Click:Connect(function()
			self:Exit()
			pcall(Funcion)
		end))
		table.insert(self.actives, clone.Cancel.MouseButton1Click:Connect(function()
			self:Exit()
		end))
		table.insert(self.actives,self.InputPlayer.ChangeInput:Connect(function() self:InputPlayerChanged() end))
		table.insert(self.actives,self.UIS.InputBegan:Connect(function(Input:InputObject,Processed)
			if Processed and Input.KeyCode ~= Enum.KeyCode.ButtonA then return end
			if Input.KeyCode == Enum.KeyCode.ButtonA then
				self:Exit()
				pcall(Funcion)
			elseif Input.KeyCode == Enum.KeyCode.ButtonB then
				self:Exit()
			end
		end))
		
		if self.Mouse then
			table.insert(self.actives, self.Mouse.Mouse1Click:Connect(function(Position)
				if self:IsOutFrame(Position) then
					self:Exit()
				end
			end))
		end
	end)
	animation:Play()
end

function module:Exit()
	if not self.YaHayFuncion then return end
	for i,v:RBXScriptConnection in self.actives do v:Disconnect() self.actives[i] = nil end
	local animation:Tween = self:CrearAnimacion(self.TimeAnimation, 1)
	animation:Play()
	game:GetService('Debris'):AddItem(self.GuiClone.Parent, animation.TweenInfo.Time)
	self.GuiClone = nil
	self.YaHayFuncion = nil
end

return module.new()
