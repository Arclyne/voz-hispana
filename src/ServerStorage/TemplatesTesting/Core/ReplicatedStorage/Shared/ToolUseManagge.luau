local module = {}
module.__index = module

local Disconnect = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("Disconnects"))

function module.new(Player : Player)
	local self = setmetatable({

		Player = Player,
		actives = {},
		IsActive = false,
		Character = false,

	}, module)

	self:init()

	return self
end

function module:UnnequipTool()
	local ToolEquiped = self.ToolEquiped
	if not ToolEquiped then return end
	self.ToolEquiped = nil
	if ToolEquiped.Agarre == ToolEquiped.Attachment then
		for _,v in ToolEquiped.instancesCreated do
			v:Destroy()
		end
	else
		ToolEquiped.Attachment:Destroy()
	end
	if self.LeftArm then
		self.LeftArm.Shoulder.Enabled = true
	end
end
function module:EquipTool(Tool : Tool)
	if not self.Character or self.ToolEquiped or not Tool then return end
	local Agarre = Tool:FindFirstChild("LeftHand", true)
	if not Agarre then return end
	local Attachment = Agarre:IsA("Attachment") and Agarre or Agarre:IsA("BasePart") and Instance.new("Attachment", Agarre)
	if not Attachment then return end
	local instancesCreated = {}
	self.ToolEquiped = {
		Tool = Tool,
		Agarre = Agarre,
		Attachment = Attachment,
		instancesCreated = instancesCreated,
	}
	self.LeftArm.Shoulder.Enabled = false
	local Ball = Instance.new("BallSocketConstraint", Attachment)
	table.insert(instancesCreated, Ball)
	task.wait()
	Ball.Attachment0 = self.LeftArm.Hand
	Ball.Attachment1 = Attachment
end

function module:CharacterRemoving()
	if not self.Character then return end
	self.Character = false
	self.LeftArm = false
	Disconnect.Group(self.actives, {"Equip", "Unnequip", "Died", "Destroyed"})
	self:UnnequipTool()
end

function module:CharacterAdded()
	local Character : Model = self.Player.Character
	if not Character or Character == self.Character then return end

	local Humanoid:Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid")

	Disconnect.Group(self.actives, {"Equip", "Unnequip", "Died", "Destroyed"})

	self.actives.Equip = Character.ChildAdded:Connect(function(Child)
		if Child:IsA("Tool") then self:EquipTool(Child) end
	end)

	self.actives.Unnequip = Character.ChildRemoved:Connect(function(Child)
		if self.ToolEquiped and Child == self.ToolEquiped.Tool then self:UnnequipTool() end
	end)

	self.actives.Died = Humanoid.Died:Connect(function() self:CharacterRemoving() end)

	self.actives.Destroyed = Character.AncestryChanged:Connect(function(_, Parent)
		if Parent then return end
		self:CharacterRemoving()
	end)

	self.LeftArm = {
		Shoulder = (Character:FindFirstChild("LeftUpperArm") or Character:WaitForChild("LeftUpperArm")):FindFirstChild("LeftShoulder"),
		Hand = (Character:FindFirstChild("LeftHand") or Character:WaitForChild("LeftHand")):FindFirstChild("LeftGripAttachment"),
	}
	self.Character = Character

end

function module:init()
	if self.IsActive then return end
	self.IsActive = true
	table.insert(self.actives, self.Player.CharacterAdded:Connect(function() self:CharacterAdded() end))
	self:CharacterAdded()
end

function module:Exit()
	if not self.IsActive then return end
	Disconnect.All(self.actives)
	self.IsActive = false
end

return module