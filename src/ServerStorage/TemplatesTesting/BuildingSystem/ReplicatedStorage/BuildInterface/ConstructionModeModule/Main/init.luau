local module = {}
module.__index = module

function module.new(metatable)
	local self = setmetatable({}, module)
	
	self.self = metatable
	
	self.Tween = {Tween = {}, Action = false}
	self.gui = metatable.gui.MainFrame
	
	self.Sections = {
		{
			module = require(script:WaitForChild("FurnitureFrame")).new(self),
			Button = self.gui.Main.MainButtons.Furniture,
		},
		{
			module = require(script:WaitForChild("DesingFrame")).new(self),
			Button = self.gui.Main.MainButtons.HouseDesing,
		},
		{
			module = require(script:WaitForChild("Inventory")).new(self),
			Button = self.gui.Main.MainButtons.Inventory,
		},
	}
	
	self.SectionSelect = 1

	self:InizializarMain()
	
	return self
end

function module:Expand(active)
	local function added()
		self.self.serv.ElimineOnlyActive(self.Tween, "Action")
		self.self.serv.ElimineTween(self.Tween.Tween)
		if active ~= nil then
			local anim:Tween = self.self.serv.CreateTween(self.gui,{Position = UDim2.fromScale(.5,active and .5 or .8)},.15)
			table.insert(self.Tween.Tween, anim)
			self.Tween.Action = anim.Completed:Connect(function(playback)
				if playback == Enum.PlaybackState.Completed then
					self.self.serv.ElimineTween(self.Tween.Tween)
					self.self.serv.ElimineOnlyActive(self.Tween, "Action")
					self.ExpandButton.SelectedActive = active
					self.ExpandButton:UnSelect()
					for index,section in self.Sections do
						if self.expand then
							table.insert(self.self.actives, section.Button:Connect(function()
								if self.SectionSelect ~= index then
									self.SectionSelect = index
									for index2,section in self.Sections do
										if index2 == self.SectionSelect then
											section.module:Open()
										else
											section.module:Close()
										end
									end
								end
							end))
							if index == self.SectionSelect then
								section.module:Open()
							end
						else
							for index,section in self.Sections do
								local selected = self.Sections[index]
								if selected then
									selected.module:Close()
								end
							end
						end
					end
				end
			end)
			anim:Play()
		else
			self.gui.Position = UDim2.fromScale(.5,.8)
			for index,section in self.Sections do
				local selected = self.Sections[index]
				if selected then
					selected.module:Close()
				end
			end
		end
	end
	if active and not self.expand and not self.self.MoveAndPlace.Enabled then
		self.expand = {}
		self.ExpandButton.SelectedActive = true
		added()
	elseif not active and self.expand then
		self.expand = self.self.serv.ElimineActive(self.expand)
		added()
	end
end

function module:Init()
	if self.self.IsActive then
		table.insert(self.self.actives, self.ExpandButton:Connect(function() self:Expand(not self.expand) end))
		self.ExpandButton.gui.Visible = not self.self.MoveAndPlace.Enabled
		
		table.insert(self.self.actives, self.self.MoveAndPlace.StateChanged:Connect(function()
			local enabled = not self.self.MoveAndPlace.Enabled
			self.ExpandButton.gui.Visible = enabled
			if not enabled then
				if self.expand then
					self.LastStateExpand = true
					self:Expand(false)
				end
			elseif self.LastStateExpand then
				self:Expand(true)
				self.LastStateExpand = nil
			end
		end))
		
		table.insert(self.self.actives, self.CloseButton:Connect(function() self.self:Exit() end))
	end
end
function module:Destroy()
	self.LastStateExpand = nil
	self:Expand()
end

function module:InizializarMain()
	self.ExpandButton = self.self.serv.ButtonAnimator.new(self.gui.Expand)
	self.ExpandButton:EnterAction(nil, {
		BackgroundColor3 = Color3.fromRGB(49, 98, 147),
	})
	self.ExpandButton:EnterAction(self.gui.Expand.TextLabel, {
		Size = UDim2.fromScale(1,1.5),
	})
	self.ExpandButton:DownAction(self.gui.Expand.TextLabel, {
		Size = UDim2.fromScale(1,1.2),
	})
	self.ExpandButton:SelectedAction(nil, {
		BackgroundColor3 = Color3.fromRGB(85, 170, 255),
	})
	self.ExpandButton:SelectedAction(self.gui.Expand.TextLabel, {
		Rotation = 180,
		Position = UDim2.fromScale(0,0),
		Size = UDim2.fromScale(1,1.357),
	})
	self.ExpandButton:ChangeTimeAnimation(.1)
	
	self.ExpandButton:AddEffectSound("Click", 139037694620957)
	
	self.CloseButton = self.self.serv.ButtonAnimator.new(self.gui.ButtonsMenu.Close)
	self.CloseButton:EnterAction(nil, {
		Size = UDim2.fromScale(.16,1.1),
		BackgroundColor3 = Color3.fromRGB(49, 49, 49),
	})
	self.CloseButton:DownAction(nil, {
		Size = UDim2.fromScale(.12,.8),
	})
	self.CloseButton:AddEffectSound("Click", 139037694620957)

	self.OcultButt = self.self.serv.ButtonAnimator.new(self.gui.ButtonsMenu.Ocult)
	self.OcultButt:EnterAction(nil, {
		Size = UDim2.fromScale(.1,1.1),
		BackgroundColor3 = Color3.fromRGB(149, 149, 149),
	})
	self.OcultButt:DownAction(nil, {
		Size = UDim2.fromScale(.08,.8),
	})
	self.OcultButt:AddEffectSound("Click", 139037694620957)
	
	for _,section in self.Sections do
		local ButtonAnim = self.self.serv.ButtonAnimator.new(section.Button)
		
		ButtonAnim:UnSelectedAction(nil, {
			BackgroundColor3 = Color3.fromRGB(195, 196, 213),
		})
		ButtonAnim:UnSelectedAction(section.Button.UIGradient, {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0,Color3.fromRGB(189, 189, 206)),
				ColorSequenceKeypoint.new(1,Color3.fromRGB(255, 255, 255))}),
		})
		
		ButtonAnim:EnterAction(nil, {
			Size = UDim2.fromScale(.9, .27),
		})
		ButtonAnim:DownAction(nil, {
			Size = UDim2.fromScale(.8, .23),
		})
		
		ButtonAnim:SelectedAction(nil, {
			BackgroundColor3 = Color3.fromRGB(85, 170, 255),
			Size = UDim2.fromScale(.854, .25),
		})
		ButtonAnim:SelectedAction(section.Button.UIGradient, {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0,Color3.fromRGB(85, 170, 255)),
				ColorSequenceKeypoint.new(1,Color3.fromRGB(255, 255, 255))}),
		})
		ButtonAnim:AddEffectSound("Click", 139037694620957)
		
		section.Button = ButtonAnim
		section.module.Button = ButtonAnim
	end
end

return module
