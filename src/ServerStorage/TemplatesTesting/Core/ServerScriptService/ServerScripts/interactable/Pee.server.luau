local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))

local debris = game:GetService("Debris")
local RunS = game:GetService("RunService")
local ActiveRun : RBXScriptConnection
local PlayerCleaners = {}

local MOP_TOOL_NAME = "Mop"
local CLEANING_DURATION = 4.4 -- Asegurarse de que el otro script "Pee" también tiene el mismo tiempo
local cleanSoundDelay = 1.2

local Lerp = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("lerp"))

local assets = ReplicatedStorage.Assets
local remotes = ReplicatedStorage.Events

local function getAliveHumanoid(player: Player): Humanoid?
	local Humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	return not not (Humanoid and Humanoid.Health > 0) and Humanoid
end

local function getCleaningToolName(DataModel)
	local toolName = DataModel.ToolName

	if typeof(toolName) ~= "string" or toolName == "" then
		return MOP_TOOL_NAME
	end

	return toolName
end

local function removeCleaningTool(player: Player)
	local character = player.Character
	if not character then return end

	for _, child in character:GetChildren() do
		if child:IsA("Tool") and child:GetAttribute("CleaningTool") then
			child:Destroy()
		end
	end
end

local function equipCleaningTool(player: Player, toolName: string)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- Desequipamos cualquier tool que tuviera equipada
	humanoid:UnequipTools()

	-- Por si hubiera quedado una tool temporal anterior
	removeCleaningTool(player)

	local toolsFolder = assets:FindFirstChild("Tools")
	if not toolsFolder then
		warn("No se encontró la carpeta Tools")
		return
	end

	local toolAsset = toolsFolder:FindFirstChild(toolName, true)
	if not toolAsset or not toolAsset:IsA("Tool") then
		warn("No se encontró la tool de limpieza:", toolName)
		return
	end

	local tool = toolAsset:Clone()
	tool:SetAttribute("CleaningTool", true)
	tool.Parent = character
end

local function rotateCharacterToFace(player, targetModel)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Obtener la posición objetivo del modelo.
	-- Se asume que el modelo tiene una PrimaryPart asignada.
	local targetPos = targetModel.PrimaryPart and targetModel.PrimaryPart.Position or targetModel:GetPivot().Position

	local currentPos = hrp.Position
	-- Calcular la diferencia en X y Z (horizontal) y establecer Y en 0
	local direction = Vector3.new(targetPos.X - currentPos.X, 0, targetPos.Z - currentPos.Z)

	if direction.Magnitude > 0 then
		-- Crear un nuevo CFrame que apunte hacia la dirección calculada sin afectar la altura.
		local newCFrame = CFrame.new(currentPos, currentPos + direction)
		hrp.CFrame = newCFrame
	end
end

local function remove(Player : Player)
	if not PlayerCleaners[Player] then return end
	local list = PlayerCleaners[Player]
	PlayerCleaners[Player] = nil
	list.Canceled = true
	if list.IsLoaded then
		for _,v in list.actives do v:Disconnect() end

		if list.IsCompleted then
			list.model:SetAttribute("IsComplete", true)
			list.model:Destroy()
			debris:AddItem(list.model,0)
			list.track:Stop()
			list.track:Destroy()
			debris:AddItem(list.track,0)
		else
			for _, mesh in list.mesh do
				mesh.part.Transparency = mesh.transparency
			end
			list.model:SetAttribute("PlayerCleaning", nil)
			list.model:SetAttribute("Cleaning", nil)
		end

		removeCleaningTool(Player)
	else
		list.model:SetAttribute("PlayerCleaning", nil)
		list.model:SetAttribute("Cleaning", nil)
		removeCleaningTool(Player)
	end
end

local function Update()
	ActiveRun = ActiveRun or RunS.Heartbeat:Connect(function()
		local IsClear = true
		for Player:Player, Data in PlayerCleaners do
			if Data.Canceled then continue end
			if Data.IsLoaded then
				local ElapsedTime = tick()-Data.IsLoaded
				local NewSoungCleanDelay = tonumber(Data.cleanSoundDelay) or cleanSoundDelay

				if ElapsedTime >= NewSoungCleanDelay then
					if not Data.cleanSoundDelay then
						Data.cleanSoundDelay = true

						SoundManager:Play(nil, tonumber(Data.DataModel.SoundId) or 87325451774989, {
							Volume = 1,
							Looped = false,
							RollOffMode = Enum.RollOffMode.Linear,
							RollOffMinDistance = 10,
							RollOffMaxDistance = 50,
						}, Data.model)

					end
					ElapsedTime = math.min((ElapsedTime-NewSoungCleanDelay) / ((tonumber(Data.DataModel.ClearDuration) or CLEANING_DURATION) - NewSoungCleanDelay), 1)
					for _, mesh in Data.mesh do
						mesh.part.Transparency = Lerp(mesh.transparency,1,ElapsedTime)
					end
					if ElapsedTime >= 1 then
						Data.IsCompleted = true
						remove(Player)
						continue
					end
				end
			end
			IsClear = false
		end
		if IsClear then
			ActiveRun:Disconnect()
			ActiveRun = nil
		end
	end)
end

local function Add(Player : Player, model : Model)
	if PlayerCleaners[Player] or not model then return end

	local humanoid = getAliveHumanoid(Player)
	if not humanoid then return end

	local DataModel = model:GetAttributes()

	model:SetAttribute("PlayerCleaning", Player.UserId)
	model:SetAttribute("Cleaning", true)

	rotateCharacterToFace(Player, model)

	local list = {IsLoaded = false, actives = {}, model = model, DataModel = DataModel}
	PlayerCleaners[Player] = list

	local animator = humanoid:FindFirstChildOfClass("Animator")

	local PeeModelAssets = assets:FindFirstChild("Interactable"):FindFirstChild("Pee"):FindFirstChild("Animations")
	local success,track = pcall(animator.LoadAnimation, animator, PeeModelAssets:FindFirstChild(DataModel.Animation or "") or PeeModelAssets:FindFirstChild("Pee"))
	if not success then return remove(Player) end

	list.mesh = {}

	for _,v in model:GetDescendants() do
		if v:IsA("BasePart") and v.Transparency < 1 then
			table.insert(list.mesh,{part = v, transparency = v.Transparency})
		end
	end

	track.Looped = true
	list.track = track

	list.IsLoaded = tick()

	table.insert(list.actives, Player.AncestryChanged:Connect(function() remove(Player) end))
	table.insert(list.actives, humanoid.Died:Connect(function() remove(Player) end))
	table.insert(list.actives, model.AncestryChanged:Connect(function(_,parent) if parent then return end remove(Player) end))

	equipCleaningTool(Player, getCleaningToolName(DataModel))

	track:Play()

	Update()
end


remotes.Interactable.Pee.OnServerEvent:Connect(function(player, model: Model)
	if typeof(model)~="Instance" or not model:HasTag("Pee") or model:GetAttribute("Cleaning") then return end
	local whiteList = model:GetAttribute("WhiteList")
	if not whiteList or table.find(string.split(whiteList,","), tostring(player.UserId)) then
		Add(player, model)
	end
end)