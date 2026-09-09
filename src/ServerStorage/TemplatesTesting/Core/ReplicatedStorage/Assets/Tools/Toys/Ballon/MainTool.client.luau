local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Tools")
local equipRemote = remotes:WaitForChild("EquipTool")
local ballonRemote = remotes:WaitForChild("Ballon")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Handle = script.Parent:WaitForChild("Handle")
local Ballon = Handle:WaitForChild("BallonMesh")

local attachment = HumanoidRootPart:FindFirstChild("GravityAttachment")
if not attachment then
	attachment = Instance.new("Attachment")
	attachment.Name = "GravityAttachment"
	attachment.Parent = HumanoidRootPart
end

local vectorForce = HumanoidRootPart:FindFirstChild("PlayerGravityForce")
if not vectorForce then
	vectorForce = Instance.new("VectorForce")
	vectorForce.Name = "PlayerGravityForce"
	vectorForce.Attachment0 = attachment
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.ApplyAtCenterOfMass = true
	vectorForce.Parent = HumanoidRootPart
	vectorForce.Force = Vector3.zero
end

local function getCharacterMass()
	local mass = 0
	for _, obj in ipairs(Character:GetDescendants()) do
		if obj:IsA("BasePart") then
			mass += obj:GetMass()
		end
	end
	return mass
end

local function changePlayerGravity(gravityMultiplier)
	local mass = getCharacterMass()

	-- Compensamos parte de la gravedad global con una fuerza hacia arriba
	local upwardForce = workspace.Gravity * mass * (1 - gravityMultiplier)

	vectorForce.Force = Vector3.new(0, upwardForce, 0)
end

local function setupBalloonNoCollision()
	for _, obj in ipairs(Character:GetDescendants()) do
		if obj:IsA("BasePart") and obj ~= Ballon then
			local alreadyExists = Ballon:FindFirstChild("NC_" .. obj.Name)

			if not alreadyExists then
				local noCollision = Instance.new("NoCollisionConstraint")
				noCollision.Name = "NC_" .. obj.Name
				noCollision.Part0 = Ballon
				noCollision.Part1 = obj
				noCollision.Parent = Ballon
			end
		end
	end
end

setupBalloonNoCollision()

script.Parent.Equipped:Connect(function()
	ballonRemote:FireServer(true, script.Parent)
	equipRemote:FireServer(Handle)
	changePlayerGravity(0.3)
end)

script.Parent.Unequipped:Connect(function()
	ballonRemote:FireServer(false, script.Parent)
	changePlayerGravity(1)
end)