local module = {}
module.__index = module

local debris = game:GetService('Debris')
local verificacionPages = require(script.Parent:WaitForChild('VerificacionPages'))

local Player = game:GetService('Players').LocalPlayer

function module:CreateGui()
	if not self or self.gui then return end
	local clone = script:FindFirstChild('InterfaceGuide'):Clone()
	clone.back.Top.TagKey.Text = self.uniqueKey
	
	table.insert(self.actives, clone.back.Top.Cancel.MouseButton1Click:Connect(function() self:End(self.PageSelect < #self.PagesOrder) end))
	table.insert(self.actives, clone.back.Bottom.Next.MouseButton1Click:Connect(function() self:AdvancePage() end))
	table.insert(self.actives, clone.back.Bottom.Back.MouseButton1Click:Connect(function() self:PreviousPage() end))
	
	clone.Parent = Player:WaitForChild('PlayerGui')
	self.gui = clone
end

function module:Exit()
	if not self then return end
	if self.gui then
		debris:AddItem(self.gui,0)
		self.gui = nil
	end
end

function module:Start()
	if not self or not self.actives then return end
	module.CreateGui(self)
	module.SetPage(self)
end

function module:Clear()
	if self and self.gui then
		for _,gui in self.gui.back:GetChildren() do
			if gui:IsA('GuiBase') and not table.find({"Top","Bottom"}, gui.Name) then
				debris:AddItem(gui,0)
			end
		end
	end
end

function module:SetPage()
	if not self or not self.gui then return end
	self.gui.back.Bottom.Back.Text = self.PageSelect <= 1 and "Cancel" or "Back"
	self.gui.back.Bottom.Next.Text = self.PageSelect >= #self.PagesOrder and "Finish" or "Next"
	module.Clear(self)
	local pageSelected = self.PagesOrder[self.PageSelect]
	if pageSelected then
		for _,data in pageSelected do
			verificacionPages.Create(data,self.gui.back)
		end
	else
		self:End(self.PageSelect <= #self.PagesOrder)
	end
end

return module