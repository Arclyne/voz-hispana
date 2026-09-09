local module = {}
module.__index = module

local begin = Enum.UserInputState.Begin
local none = Enum.UserInputState.None
local ending = Enum.UserInputState.End
local cancel = Enum.UserInputState.Cancel

function module:Start()
	local Store = self.serv.Stores:GetStore(self.serv.Player)
	if self.IsActive or not Store then return end
	self.Store = Store
	self.IsActive = true
	return self:OpenFrame()
end

function module:UpdateCountBuilds(start)
	if not self.IsActive or not self.Store then return end
	
	local count = 0
	
	if self.Store:IsA("Store") then
		count = self.serv.Stores.DecorsPlayer:GetCountBuilds()
	else
		for _,_ in self.Store.DecorChild do count += 1 end
	end
	
	self.Store.CountBuilds = count
	self.CountBuild:SetAmount(count, start)
end

function module:OpenFrame()
	self.serv.SignalGame:Fire("FijarStatGuiTop", true)
	self.gui.Visible = self.IsActive
	local anim = self:SetAnimation(self.IsActive)
	self.actives['TweenActive'] = anim:Connect(function()
		self.serv.ElimineTween(self.AnimationOpenClose)
		self.serv.ElimineOnlyActive(self.actives,"TweenActive")
		
		self.Main:Init()
		
		table.insert(self.actives, self.serv.Stores.ButtonOpenMC.enabledChanged:Connect(function() self:Exit() end))
		
		if self.Store:IsA("Store") then
			table.insert(self.actives, self.Store.OwnerChanged:Connect(function() self:Exit() end))
			
			local decorPlayer = self.serv.Stores.DecorsPlayer
			
			local function change(NameBuild)
				local data = decorPlayer:Find(NameBuild)
				local listActv = {NameBuild.."_removed", NameBuild.."_Changed"}
				if data then
					self.actives[listActv[1]] = data.ChildRemoved:Connect(function() self:UpdateCountBuilds() end)
					self.actives[listActv[2]] = data.ChildChanged:Connect(function() self:UpdateCountBuilds() end)
				else
					self.serv.ElimineGroupActive(self.actives, listActv)
					self:UpdateCountBuilds()
				end
			end

			for _, build in decorPlayer:Get() do change(build.Name) end
			table.insert(self.actives, decorPlayer.ChildAdded:Connect(change))
			table.insert(self.actives, decorPlayer.ChildRemoved:Connect(change))
		else
			table.insert(self.actives, self.Store.DecorChanged:Connect(function() self:UpdateCountBuilds() end))
		end
		
		table.insert(self.actives, self.CountBuild.Changed:Connect(function(state)
			if state == begin then
				self.CountBuild.Label.Visible = true
			elseif state == ending
				or state == cancel
				or state == none then
				self.CountBuild.Label.Visible = self.Store.CountBuilds >= self.serv.Stores.MaxBuildPlace * .7
			end
		end))
		
		self:UpdateCountBuilds(true)
		
		table.insert(self.actives, self.serv.Mouse.Mouse1Click:Connect(function(posi, processed)
			if processed then return end
			
			local cam:Camera = self.serv.Camera

			local ray:Ray = cam:ScreenPointToRay(posi.X,posi.Y)
			local Raycast = workspace:Raycast(ray.Origin,ray.Direction*1000,
				self.Store:IsA("Store") and self.serv.Stores.DecorsPlayer:AddToFilter() or self.Store:AddToFilter())
			if self.MoveAndPlace.Enabled then
				self.MoveAndPlace:BackToClose()
			elseif Raycast then
				local info = self.serv.Stores:GetDecorPlayer(Raycast.Instance)
				if not info then return end
				self.MoveAndPlace:index(info)
			end
			
		end))
		
		self.serv.RS:FindFirstChild("IsInEvent"):SetAttribute("ConstructionMode", true)
		
	end)
	return anim
end

function module:Exit()
	if not self.IsActive then return end
	self.serv.SignalGame:Fire("FijarStatGuiTop", false)
	self.serv.Stores:ExitModeConstruccion()
	self.serv.ElimineActive(self.actives)
	self.IsActive = false
	local anim = self:SetAnimation(false)
	self.actives['TweenActive'] = anim:Connect(function()
		self.serv.ElimineTween(self.AnimationOpenClose)
		self.serv.ElimineOnlyActive(self.actives,"TweenActive")
		self.Main:Destroy()
		self.MoveAndPlace:Destroy()
		self.Colors:Destroy()
		self.gui.Visible = false
		self.serv.RS:FindFirstChild("IsInEvent"):SetAttribute("ConstructionMode", nil)
	end)
	return anim
end

function module:init()
	
	self.ColorFormat = require(script:WaitForChild("ColorFormat"))
	self.DesingData = require(self.serv.RS:WaitForChild("Client"):WaitForChild("DesingData"))
	self.Main = require(script:WaitForChild("Main")).new(self)
	self.MoveAndPlace = require(script:WaitForChild("MoveAndPlaceent")).new(self)
	self.Colors = require(script:WaitForChild("Color")).new(self)

	self.CountBuild = self.serv.ChangeStatService.new(self.gui.MainFrame.ButtonsMenu.CountBuilds)
	self.CountBuild:SetFormat("Builds: %d/"..tostring(self.serv.Stores.MaxBuildPlace))
	self.CountBuild:SetTimeAnimation(.1,.05,3)
	
end

return function(gui, Button)
	local meta = setmetatable({
		Button = Button,
		actives = {},
		gui = gui,
		OriginalPosi = gui.Position,
		up = true,
		serv = require(script.Parent.Parent:WaitForChild('services')),
		IsActive = false,
	}, module)
	
	meta:init()

	return meta
end
