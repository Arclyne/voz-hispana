local module = {}
module.__index = module

local Disconnect = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("Disconnects"))
local ani = {}

for _,Animation in script:GetDescendants() do
	if Animation:IsA('Animation') then
		ani[Animation.Name] = Animation
	end
end

function module.new(Character:Model)
	local self = setmetatable({
		Owner = game:GetService('Players'):FindFirstChild(Character.Name),
		Character = Character,
		Humanoid = Character:WaitForChild('Humanoid'),
		actives = {},
	},module)
	
	self.Animator = self.Humanoid:WaitForChild('Animator')
	self.ListAnimations = self:LoadAnimation()
	
	table.insert(self.actives, self.Humanoid:GetPropertyChangedSignal('Health'):Connect(function()
		if self.Humanoid.Health <= 0 then
			self:PlayAnimation()
		end
	end))
	table.insert(self.actives, self.Character.AncestryChanged:Connect(function(_,parent)
		if parent then return end
		self:PlayAnimation()
		table.clear(self)
		self.IsDestroyed = true
	end))
	
	table.insert(self.actives, script.DescendantAdded:Connect(function(animation)
		if not animation:IsA('Animation') then return end
		self:AddAnimation(animation)
	end))
	table.insert(self.actives, script.DescendantRemoving:Connect(function(animation)
		if not animation:IsA('Animation') then return end
		self:RemoveAnimation(animation.Name)
	end))
	
	return self
end

function module:RemoveAnimation(folder)
	if self.IsDestroyed then return end
	if typeof(folder)=="Instance" then
		if folder:IsA("Folder") then
			for _,anim in folder:GetChildren() do
				if anim:IsA("Animation") then
					self:RemoveAnimation(anim)
				end
			end
		elseif folder:IsA("Animation") then
			self:RemoveAnimation(folder.Name)
		end
	elseif typeof(folder) == "string" then
		if self.ListAnimations[folder] then
			Disconnect.Only(self.actives,folder.."Anim")
			self.ListAnimations[folder]:Stop()
			self.ListAnimations[folder] = nil
		end
	end
end

function module:AddAnimation(folder,Playing)
	if self.IsDestroyed then return end
	if typeof(folder)=="Instance" then
		if folder:IsA("Folder") then
			for _,anim in folder:GetChildren() do
				if anim:IsA("Animation") then
					self:AddAnimation(anim)
				end
			end
		elseif folder:IsA("Animation") then
			self:RemoveAnimation(folder.Name)
			self.ListAnimations[folder.Name] = self.Animator:LoadAnimation(folder)
			if Playing then self:PlayAnimation(folder.Name) end
			if not folder:IsDescendantOf(script) then
				self.actives[folder.Name.."Anim"] = folder.AncestryChanged:Connect(function(_,parent)
					if parent then return end
					self:RemoveAnimation(folder.Name)
				end)
			end
		end
	end
end

function module:ClearAllAnimation()
	if self.IsDestroyed then return end
	for _,v in self.Animator:GetPlayingAnimationTracks() do
		v:Stop()
	end
end

function module:LoadAnimation()
	if self.IsDestroyed then return end
	local list = {}
	for NameAnimation,Animation:Animation in ani do
		local loaded = self.Animator:LoadAnimation(Animation)
		list[NameAnimation] = loaded
	end
	return list
end

function module:GetInfoAnimation(NameANimation)
	if self.IsDestroyed then return end
	return self.ListAnimations[NameANimation]
end

function module:GetLastAnimation()
	if self.IsDestroyed then return end
	return self.LastAnimation
end

function module:PlayAnimation(NameANimation, fade)
	if self.IsDestroyed then return end
	local activado = false
	for NameAnimation,Animation:Animation in self.ListAnimations do
		if NameAnimation == NameANimation then
			if not Animation.IsPlaying then
				Animation:Play(fade)
				activado = Animation
			end
		elseif Animation.IsPlaying then
			self.LastAnimation = {
				TimePosition = Animation.TimePosition,
				Length = Animation.Length,
				Speed = Animation.Speed,
				Name = NameAnimation,
				Info = Animation,
			}
			Animation:Stop()
		end
	end
	return activado
end

function module:AdjustSpeed(NameANimation,Speed)
	if self.IsDestroyed then return end
	local Animation = self.ListAnimations[NameANimation]
	if Animation then
		Animation:AdjustSpeed(tonumber(Speed) or 1)
	end
end

function module:AdjustWeight(NameANimation,Weight, fade)
	if self.IsDestroyed then return end
	local Animation = self.ListAnimations[NameANimation]
	if Animation then
		Animation:AdjustWeight(tonumber(Weight) or 1, tonumber(fade))
	end
end

function module:StopedAnimate()
	if self.IsDestroyed then return end
	self.Character:WaitForChild('Animate').Enabled = false
	for _,v in self.Animator:GetPlayingAnimationTracks() do
		v:Stop()
	end
end

return module
