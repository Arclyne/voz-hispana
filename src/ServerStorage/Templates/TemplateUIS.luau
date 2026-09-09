local module = {}
module.__index = module

function module:Start()
	if self.IsActive then return end
	self.IsActive = true
	return self:OpenFrame()
end

function module:OpenFrame()
	self.gui.Visible = self.IsActive
	local anim = self:SetAnimation(self.IsActive)
	self.actives['TweenActive'] = anim:Connect(function()
		self.serv.ElimineTween(self.AnimationOpenClose)
		self.serv.ElimineOnlyActive(self.actives,"TweenActive")
	end)
	return anim
end

function module:Exit()
	if not self.IsActive then return end
	self.serv.ElimineActive(self.actives)
	self.IsActive = false
	local anim = self:SetAnimation(false)
	self.actives['TweenActive'] = anim:Connect(function()
		self.serv.ElimineTween(self.AnimationOpenClose)
		self.serv.ElimineOnlyActive(self.actives,"TweenActive")
		self.gui.Visible = false
	end)
	return anim
end

return function(gui, Button)
	local meta = setmetatable({
		Button = Button,
		actives = {},
		gui = gui,
		OriginalPosi = gui.Position,
		serv = require(script.Parent.Parent:WaitForChild('services')),
		IsActive = false,
	}, module)

	return meta
end
