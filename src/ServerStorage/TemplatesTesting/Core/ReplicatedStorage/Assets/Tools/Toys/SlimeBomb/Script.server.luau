local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local FastCast = require(ReplicatedStorage.Shared:FindFirstChild("FastCastRedux"))
local PartCache = require(ReplicatedStorage.Shared:FindFirstChild("PartCache"))

local Tool = script.Parent
local SlimeProjectile = Tool.Handle.Slime 
local RemoteEvent = Tool.RemoteEvent

local cosmeticBulletsFolder = workspace:FindFirstChild("CosmeticBulletsFolder") or Instance.new("Folder", workspace)
cosmeticBulletsFolder.Name = "CosmeticBulletsFolder"

local cosmeticBullet = SlimeProjectile:Clone()
cosmeticBullet.CanCollide = false
cosmeticBullet.Anchored = true

local CosmeticPartProvider = PartCache.new(cosmeticBullet, 50, cosmeticBulletsFolder)

local SlimeDuration = 3
local PlayersInSlime = {}
local OriginalSpeeds = {}
local SpeedChangeConnections = {} 

local Character = Tool.Parent

local function PlaySound(Sound: Sound, Parent)
	local SoundClone = Sound:Clone()
	SoundClone.Parent = Parent
	SoundClone:Play()

	Debris:AddItem(SoundClone, SoundClone.TimeLength)
end

local function SetCastParams()
	local CastParams = RaycastParams.new()
	CastParams.IgnoreWater = true
	CastParams.FilterType = Enum.RaycastFilterType.Exclude
	CastParams.FilterDescendantsInstances = {Tool.Parent, cosmeticBulletsFolder}

	return CastParams
end

local function SetCastBehavior(Player)
	local CastBehavior = FastCast.newBehavior()

	CastBehavior.RaycastParams = SetCastParams()
	CastBehavior.MaxDistance = 40000
	CastBehavior.HighFidelityBehavior = FastCast.HighFidelityBehavior.Default

	CastBehavior.CosmeticBulletProvider = CosmeticPartProvider
	CastBehavior.CosmeticBulletContainer = cosmeticBulletsFolder
	CastBehavior.Acceleration = Vector3.new(0, -30, 0)
	CastBehavior.AutoIgnoreContainer = false


	return CastBehavior
end

local function SetCastBehavior2(Player)
	local CastBehavior = FastCast.newBehavior()

	CastBehavior.RaycastParams = SetCastParams()
	CastBehavior.MaxDistance = 40000
	CastBehavior.HighFidelityBehavior = FastCast.HighFidelityBehavior.Default

	CastBehavior.CosmeticBulletProvider = CosmeticPartProvider
	CastBehavior.CosmeticBulletContainer = cosmeticBulletsFolder
	CastBehavior.Acceleration = Vector3.new(0, -70, 0)
	CastBehavior.AutoIgnoreContainer = false


	return CastBehavior
end

local function OnLengthChanged(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject, Player)
	if cosmeticBulletObject == nil then
		print("cosmeticBulletObject is nil!")
		return
	end
	
	local Character = Tool.Parent
	
	cosmeticBullet:SetAttribute("onwer" , Character.Name)

	local bulletLength = cosmeticBulletObject.Size.Z / 2
	local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
	cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
end

local function monitorSpeedChanges(player)
	if SpeedChangeConnections[player] then return end

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	SpeedChangeConnections[player] = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if PlayersInSlime[player] and humanoid.WalkSpeed ~= OriginalSpeeds[player] * 0.1 then
			PlayersInSlime[player] = nil
			OriginalSpeeds[player] = nil
			SpeedChangeConnections[player]:Disconnect()
			SpeedChangeConnections[player] = nil
		end
	end)
end

local function OnCastTerminating(cast)
	local cosmeticBullet = cast.RayInfo.CosmeticBulletObject
	if cosmeticBullet ~= nil then
		if SetCastBehavior().CosmeticBulletProvider ~= nil then
			SetCastBehavior().CosmeticBulletProvider:ReturnPart(cosmeticBullet)
		else
			cosmeticBullet:Destroy()
		end
	end
end

local function OnSecondaryHit(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
	local HitPosition = raycastResult.Position
	local normal = raycastResult.Normal

	if not raycastResult.Instance:HasTag("superficie") then 
		OnCastTerminating(cast) 
		return 
	end

	if cosmeticBulletObject then
		CosmeticPartProvider:ReturnPart(cosmeticBulletObject)
	end
	
	local Character = Tool.Parent

	local SlimeMesh = game.ReplicatedStorage.Assets.Models.SlimeMesh:Clone()
	
	SlimeMesh.Parent = workspace.CosmeticBulletsFolder

	local upVector = Vector3.new(0, 1, 0)
	local rightVector

	if math.abs(normal.Y) < 0.1 then 
		rightVector = normal:Cross(upVector)
	else  
		rightVector = Vector3.new(0, 0, 1):Cross(normal)
	end

	local backVector = rightVector:Cross(normal)
	local rotationCFrame = CFrame.fromMatrix(HitPosition, rightVector, normal, backVector)

	SlimeMesh.CFrame = rotationCFrame

	local Random = math.random(1, 4)
	local Sound = Tool.Colissions[tostring(Random)]

	PlaySound(Sound, SlimeMesh)

	SlimeMesh.AncestryChanged:Connect(function(_, parent)
		if not parent then
			for player, _ in pairs(PlayersInSlime) do
				local character = player.Character
				if character then
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					if humanoid and OriginalSpeeds[player] then
						humanoid.WalkSpeed = OriginalSpeeds[player]
					end
				end
				if SpeedChangeConnections[player] then
					SpeedChangeConnections[player]:Disconnect()
					SpeedChangeConnections[player] = nil
				end
			end

			PlayersInSlime = {}
			OriginalSpeeds = {}
		end
	end)

	SlimeMesh.Hitbox.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent) or 
			Players:GetPlayerFromCharacter(hit.Parent.Parent)
		if not player then return end

		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end

		if PlayersInSlime[player] then return end

		OriginalSpeeds[player] = humanoid.WalkSpeed
		humanoid.WalkSpeed = OriginalSpeeds[player] * 0.1

		PlayersInSlime[player] = true
		monitorSpeedChanges(player)
	end)

	SlimeMesh.Hitbox.TouchEnded:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent) or 
			Players:GetPlayerFromCharacter(hit.Parent.Parent)
		if not player then return end

		local character = player.Character
		if not character then return end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end

		if PlayersInSlime[player] and OriginalSpeeds[player] then
			humanoid.WalkSpeed = OriginalSpeeds[player]
		end

		PlayersInSlime[player] = nil
		OriginalSpeeds[player] = nil

		if SpeedChangeConnections[player] then
			SpeedChangeConnections[player]:Disconnect()
			SpeedChangeConnections[player] = nil
		end
	end)

	task.delay(SlimeDuration, function()
		if SlimeMesh and SlimeMesh.Parent then
			SlimeMesh:Destroy()
		end
	end)
end

local function Explote(hitPosition, normal: Vector3)
	local Ammount = 20
	local Angle = math.rad(45) 

	for i = 1, Ammount - 1 do
		local randomDir = Vector3.new(
			math.random() - 0.5,
			math.random() - 0.5,
			math.random() - 0.5
		).Unit

		local tangent = (randomDir - normal * randomDir:Dot(normal)).Unit
		local angle = math.random() * Angle
		local direction = (normal * math.cos(angle) + tangent * math.sin(angle)).Unit

		direction = (direction + Vector3.new(
			(math.random() - 0.5) * 0.3,
			(math.random() - 0.5) * 0.3,
			(math.random() - 0.5) * 0.3
			)).Unit

		
		local caster = FastCast.new()
		caster.LengthChanged:Connect(OnLengthChanged)
		caster.RayHit:Connect(OnSecondaryHit)
		caster:Fire(hitPosition, direction, 40, SetCastBehavior2())
		
		
	end

	local oppositeCaster = FastCast.new()
	oppositeCaster.LengthChanged:Connect(OnLengthChanged)
	oppositeCaster.RayHit:Connect(OnSecondaryHit)

	oppositeCaster:Fire(hitPosition, normal, 5, SetCastBehavior2())
end

local function OnRayHit(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
	local hitPart: Part = raycastResult.Instance
	local HitPosition = raycastResult.Position
	local normal = raycastResult.Normal

	local offsetDistance = 0.4
	local newPosition = HitPosition + (normal * offsetDistance)

	local SlimeProjectile2 = ReplicatedStorage.Assets.Models.SlimeBombMesh2:Clone()
	SlimeProjectile2.Parent = workspace.CosmeticBulletsFolder
	SlimeProjectile2.Anchored = true 

	local upVector = Vector3.new(0, 1, 0)
	local rightVector

	if math.abs(normal.Y) > 0.8 then
		rightVector = Vector3.new(1, 0, 0)
	else
		rightVector = normal:Cross(upVector).Unit
	end

	local backVector = rightVector:Cross(normal)
	local rotationCFrame = CFrame.fromMatrix(newPosition, rightVector, normal, backVector)
	SlimeProjectile2.CFrame = rotationCFrame

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = hitPart
	weldConstraint.Part1 = SlimeProjectile2
	weldConstraint.Parent = SlimeProjectile2

	PlaySound(Tool.CountDown, SlimeProjectile2)
	SlimeProjectile2.Attachment.Hit.Enabled = true

	local explosionTimer = 2
	task.wait(explosionTimer)

	SlimeProjectile2.Attachment.Hit.Enabled = false
	PlaySound(Tool.Explosion, SlimeProjectile2)
	SlimeProjectile2.Transparency = 1

	task.delay(Tool.Explosion.TimeLength, function()
		if SlimeProjectile2 and SlimeProjectile2.Parent then
			if weldConstraint and weldConstraint.Parent then
				weldConstraint:Destroy()
			end
			SlimeProjectile2:Destroy()
		end
	end)

	Explote(HitPosition, normal)
end

task.spawn(function()
	while task.wait(.5) do
		for Player, _ in pairs(PlayersInSlime) do
			local character = Player.Character
			if not character then continue end
			PlaySound(Tool.Charco, character.HumanoidRootPart)
		end
	end
end)

RemoteEvent.OnServerEvent:Connect(function(Player, MousePosition: Vector3)

	local Caster = FastCast.new()

	local FirePoint = Player.Character.Head.Position
	local direction = (MousePosition - FirePoint).Unit

	Caster.LengthChanged:Connect(function(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
		OnLengthChanged(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
	end)

	Caster.RayHit:Connect(function(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
		OnRayHit(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
	end)

	Caster.CastTerminating:Connect(function(cast)
		OnCastTerminating(cast)
	end)

	Caster:Fire(FirePoint, direction, 60, SetCastBehavior())
end)