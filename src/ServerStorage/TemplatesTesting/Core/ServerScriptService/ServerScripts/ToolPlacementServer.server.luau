local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local ContentProvider = game:GetService("ContentProvider")

local remotes = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Interactable")
local assets = ReplicatedStorage:WaitForChild("Assets")
local modelsFolder = assets:WaitForChild("ToolsModels")
local toolsFolder = assets:WaitForChild("Tools")

local soundManagerModule = ReplicatedStorage:FindFirstChild("SoundManager")
	or ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SoundManager")

local SoundManager = require(soundManagerModule)

local BartenderSystem = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BartenderSystem"))
local store = require(ReplicatedStorage:FindFirstChild("Shared"):FindFirstChild("Stores"))

local InventoryManager = require(
	ServerScriptService
		:WaitForChild("ServerScripts")
		:WaitForChild("inventory")
		:WaitForChild("InventoryManager")
)

local PLACE_TAG = "ToolInteractable"
local MAX_PICKUP_DISTANCE = 30

local workspaceTools = workspace:FindFirstChild("InteractableTools")
if not workspaceTools then
	workspaceTools = Instance.new("Folder")
	workspaceTools.Name = "InteractableTools"
	workspaceTools.Parent = workspace
end

local modelLocks = {}
local openStates = {}

local function copyAttributes(fromInstance: Instance, toInstance: Instance)
	for key, value in fromInstance:GetAttributes() do
		toInstance:SetAttribute(key, value)
	end
end

local function normalizeAssetId(id: any): string?
	if type(id) == "number" then
		return "rbxassetid://" .. tostring(id)
	end

	if type(id) == "string" and id ~= "" then
		if string.find(id, "rbxassetid://") then
			return id
		end

		return "rbxassetid://" .. id
	end

	return nil
end

local function getToolTemplate(toolName: string): Tool?
	local tool = toolsFolder:FindFirstChild(toolName, true)

	if tool and tool:IsA("Tool") then
		return tool
	end

	return nil
end

local function getOpenAnimationId(model: Instance): string?
	return normalizeAssetId(model:GetAttribute("OpenAnimationId") or model:GetAttribute("OpenIDAnim"))
end

local function getOpenHoldAnimationId(model: Instance): string?
	return normalizeAssetId(model:GetAttribute("OpenHoldAnimationId"))
end

local function getOpenSoundId(model: Instance): any?
	local id = model:GetAttribute("OpenSoundId")

	if type(id) == "number" then
		return id
	end

	if type(id) == "string" and id ~= "" then
		return id
	end

	return nil
end

local function hasOpenAnimation(model: Instance): boolean
	return getOpenAnimationId(model) ~= nil
end

local function getModelAnimator(model: Model): Animator?
	local animationController = model:FindFirstChildOfClass("AnimationController")
		or model:FindFirstChild("AnimationController", true)

	if not animationController or not animationController:IsA("AnimationController") then
		return nil
	end

	local animator = animationController:FindFirstChildOfClass("Animator")

	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = animationController
	end

	return animator
end

local function cleanupOpenState(model: Model)
	local state = openStates[model]

	if not state then
		return
	end

	if state.openTrack then
		state.openTrack:Stop(0)
		state.openTrack:Destroy()
	end

	if state.holdTrack then
		state.holdTrack:Stop(0)
		state.holdTrack:Destroy()
	end

	openStates[model] = nil
end

local function prepareOpenState(model: Model)
	local existing = openStates[model]
	if existing then
		return existing
	end

	local openAnimationId = getOpenAnimationId(model)
	if not openAnimationId then
		return nil
	end

	local animator = getModelAnimator(model)
	if not animator then
		return nil
	end

	local animationsToPreload = {}

	local openAnimation = Instance.new("Animation")
	openAnimation.AnimationId = openAnimationId
	table.insert(animationsToPreload, openAnimation)

	local holdAnimationId = getOpenHoldAnimationId(model)
	local holdAnimation = nil

	if holdAnimationId then
		holdAnimation = Instance.new("Animation")
		holdAnimation.AnimationId = holdAnimationId
		table.insert(animationsToPreload, holdAnimation)
	end

	pcall(function()
		ContentProvider:PreloadAsync(animationsToPreload)
	end)

	local openTrack = animator:LoadAnimation(openAnimation)
	openTrack.Looped = false
	openTrack.Priority = Enum.AnimationPriority.Action4

	local holdTrack = nil

	if holdAnimation then
		holdTrack = animator:LoadAnimation(holdAnimation)
		holdTrack.Looped = true
		holdTrack.Priority = Enum.AnimationPriority.Action4
	end

	local state = {
		openAnimation = openAnimation,
		holdAnimation = holdAnimation,
		openTrack = openTrack,
		holdTrack = holdTrack,
	}

	openStates[model] = state

	return state
end

local function playOpenAnimationAndHold(model: Model)
	local openSoundId = getOpenSoundId(model)
	if openSoundId then
		SoundManager:Play(nil, openSoundId, {
			Volume = model:GetAttribute("OpenSoundVolume") or 1,
		}, model.PrimaryPart or model)
	end
	
	local state = prepareOpenState(model)
	if not state or not state.openTrack then
		return
	end

	local openTrack = state.openTrack
	local holdTrack = state.holdTrack

	openTrack:Stop(0)
	openTrack.TimePosition = 0
	openTrack:Play(0, 1, 1)

	local startedAt = os.clock()
	while openTrack.Length <= 0 and os.clock() - startedAt < 2 do
		task.wait()
	end

	if holdTrack then
		local blendOffset = model:GetAttribute("OpenHoldBlendOffset") or 1
		local waitTime = 0.5

		if openTrack.Length > 0 then
			waitTime = math.max(openTrack.Length - blendOffset, 0)
		end

		task.wait(waitTime)

		-- Congelamos la animación de abrir en la zona donde ya está abierta.
		-- Importante: NO hacemos openTrack:Stop().
		openTrack:AdjustSpeed(0)

		-- Arrancamos también la animación de caja abierta.
		-- Debe tener la caja abierta desde el primer frame.
		holdTrack:Stop(0)
		holdTrack.TimePosition = 0
		holdTrack:Play(0, 1, 0)
		holdTrack.TimePosition = 0
		holdTrack:AdjustSpeed(0)

		-- Dejamos ambas animaciones vivas:
		-- openTrack congelada + holdTrack congelada/looped.
	else
		-- Fallback si no has puesto OpenHoldAnimationId.
		-- Funciona peor en Roblox publicado; lo ideal es usar OpenHoldAnimationId.
		if openTrack.Length > 0 then
			local holdOffset = model:GetAttribute("OpenHoldOffset") or 1
			local holdTime = math.max(openTrack.Length - holdOffset, 0)

			task.wait(holdTime)

			openTrack.TimePosition = holdTime
			openTrack:AdjustSpeed(0)
		end
	end
end

local function getFoodFolder(container: Instance): Folder?
	local folder = container:FindFirstChild("FoodNumber", true)

	if folder and folder:IsA("Folder") then
		return folder
	end

	return nil
end

local function getSortedFoodPieces(container: Instance): { Instance }
	local folder = getFoodFolder(container)

	if not folder then
		return {}
	end

	local pieces = folder:GetChildren()

	table.sort(pieces, function(a, b)
		local aNumber = tonumber(a.Name)
		local bNumber = tonumber(b.Name)

		if aNumber and bNumber then
			return aNumber < bNumber
		end

		return a.Name < b.Name
	end)

	return pieces
end

local function cacheOriginalTransparency(instance: Instance)
	if instance:IsA("BasePart") and instance:GetAttribute("OriginalTransparency") == nil then
		instance:SetAttribute("OriginalTransparency", instance.Transparency)
	end

	for _, descendant in instance:GetDescendants() do
		if descendant:IsA("BasePart") and descendant:GetAttribute("OriginalTransparency") == nil then
			descendant:SetAttribute("OriginalTransparency", descendant.Transparency)
		end
	end
end

local function setPieceVisible(piece: Instance, visible: boolean)
	cacheOriginalTransparency(piece)

	if piece:IsA("BasePart") then
		piece.Transparency = if visible then piece:GetAttribute("OriginalTransparency") or 0 else 1
		piece.CanCollide = false
		piece.CanTouch = visible
		piece.CanQuery = visible
	end

	for _, descendant in piece:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Transparency = if visible then descendant:GetAttribute("OriginalTransparency") or 0 else 1
			descendant.CanCollide = false
			descendant.CanTouch = visible
			descendant.CanQuery = visible
		end
	end
end

local function getTotalServings(container: Instance): number
	local pieces = getSortedFoodPieces(container)

	if #pieces > 0 then
		return #pieces
	end

	return container:GetAttribute("TotalServings") or 0
end

local function syncFoodVisuals(container: Instance)
	if container:GetAttribute("FoodServings") ~= true then
		return
	end

	local pieces = getSortedFoodPieces(container)
	local totalServings = #pieces

	if totalServings <= 0 then
		totalServings = container:GetAttribute("TotalServings") or 0
	end

	local servingsLeft = container:GetAttribute("ServingsLeft")
	if servingsLeft == nil then
		servingsLeft = totalServings
	end

	servingsLeft = math.clamp(servingsLeft, 0, totalServings)

	container:SetAttribute("ServingsLeft", servingsLeft)
	container:SetAttribute("TotalServings", totalServings)
	container:SetAttribute("inventory", false)

	for index, piece in pieces do
		setPieceVisible(piece, index <= servingsLeft)
	end
end

local function setupOpenAttributes(instance: Instance)
	if not hasOpenAnimation(instance) then
		return
	end

	if instance:GetAttribute("Opened") == nil then
		instance:SetAttribute("Opened", false)
	end

	if instance:GetAttribute("Opening") == nil then
		instance:SetAttribute("Opening", false)
	end
end

local function getPortionToolName(model: Model): string
	local portionToolName = model:GetAttribute("PortionToolName")

	if type(portionToolName) == "string" and portionToolName ~= "" then
		return portionToolName
	end

	return model.Name
end

local function createToolFromTemplate(toolName: string, servingsLeft: number?): Tool?
	local originalTool = getToolTemplate(toolName)

	if not originalTool then
		return nil
	end

	local clone = originalTool:Clone()

	if clone:GetAttribute("FoodServings") == true then
		clone:SetAttribute("inventory", false)

		if servingsLeft ~= nil then
			clone:SetAttribute("ServingsLeft", servingsLeft)
		elseif clone:GetAttribute("ServingsLeft") == nil then
			clone:SetAttribute("ServingsLeft", getTotalServings(clone))
		end

		syncFoodVisuals(clone)
	end

	setupOpenAttributes(clone)

	return clone
end

local function createToolFromPlacedModel(model: Model, servingsLeft: number?): Tool?
	local originalTool = getToolTemplate(model.Name)

	if not originalTool then
		return nil
	end

	local clone = originalTool:Clone()

	copyAttributes(model, clone)

	if servingsLeft ~= nil then
		clone:SetAttribute("ServingsLeft", servingsLeft)
	end

	if clone:GetAttribute("FoodServings") == true then
		clone:SetAttribute("inventory", false)
		syncFoodVisuals(clone)
	end

	setupOpenAttributes(clone)

	return clone
end

local function findCarriedFoodTool(player: Player, toolName: string): Tool?
	local character = player.Character

	if not character then
		return nil
	end

	for _, child in character:GetChildren() do
		if child:IsA("Tool") and child.Name == toolName then
			return child
		end
	end

	return nil
end

local function findCarriedFoodToolWithSpace(player: Player, toolName: string): Tool?
	local character = player.Character

	if not character then
		return nil
	end

	for _, child in character:GetChildren() do
		if child:IsA("Tool") and child.Name == toolName then
			local total = getTotalServings(child)
			local servingsLeft = child:GetAttribute("ServingsLeft") or 0

			if total <= 0 or servingsLeft < total then
				return child
			end
		end
	end

	return nil
end

local function addServingToTool(tool: Tool): boolean
	if tool:GetAttribute("FoodServings") ~= true then
		return false
	end

	syncFoodVisuals(tool)

	local total = getTotalServings(tool)
	local servingsLeft = tool:GetAttribute("ServingsLeft") or 0

	if total > 0 and servingsLeft >= total then
		return false
	end

	tool:SetAttribute("ServingsLeft", servingsLeft + 1)
	syncFoodVisuals(tool)

	return true
end

local function removeServingFromTool(tool: Tool): boolean
	if tool:GetAttribute("FoodServings") ~= true then
		return false
	end

	syncFoodVisuals(tool)

	local servingsLeft = tool:GetAttribute("ServingsLeft") or 0

	if servingsLeft <= 0 then
		return false
	end

	tool:SetAttribute("ServingsLeft", servingsLeft - 1)
	syncFoodVisuals(tool)

	return true
end

local function getModelPosition(model: Model): Vector3
	if model.PrimaryPart then
		return model.PrimaryPart.Position
	end

	return model:GetPivot().Position
end

local function canUsePlacedModel(player: Player, model: Instance): boolean
	if typeof(model) ~= "Instance" or not model:IsA("Model") then
		return false
	end

	if model.Parent ~= workspaceTools then
		return false
	end

	if not CollectionService:HasTag(model, PLACE_TAG) then
		return false
	end

	local owner = model:GetAttribute("owner")
	if owner and type(owner) == "string" and owner ~= "" and owner ~= player.Name then
		return false
	end

	local character = player.Character
	if not character or not character.PrimaryPart then
		return false
	end

	local distance = (character.PrimaryPart.Position - getModelPosition(model)).Magnitude
	if distance > MAX_PICKUP_DISTANCE then
		return false
	end

	return true
end

local function canUseFoodServings(model: Model): boolean
	if model:GetAttribute("FoodServings") ~= true then
		return false
	end

	if hasOpenAnimation(model) and model:GetAttribute("Opened") ~= true then
		return false
	end

	return true
end

-- COLOCAR
remotes.PlaceTool.OnServerEvent:Connect(function(player : Player, toolName: string, position: Vector3, rotY: number, basePart : BasePart)
	if typeof(toolName) ~= "string" then return end
	if typeof(position) ~= "Vector3" then return end
	if typeof(rotY) ~= "number" then return end
	if typeof(basePart) ~= "Instance" or not basePart:IsA("BasePart") then return end

	local character = player.Character
	if not character then return end

	local tool = character:FindFirstChild(toolName)

	if not tool or not tool:IsA("Tool") or tool:GetAttribute("Colocable") ~= true then
		return
	end

	local modelTemplate = modelsFolder:FindFirstChild(toolName)
	if not modelTemplate or not modelTemplate:IsA("Model") then
		return
	end
	
	local _, size = modelTemplate:GetBoundingBox()
	local finalPosition = position + Vector3.new(0, size.Y / 2, 0)
	local finalCFrame = CFrame.new(finalPosition) * CFrame.Angles(0, math.rad(rotY + 180), 0)

	local newModel
	
	local StorePlayer = store:GetStore(player)
	local NoAplication = true
	
	if StorePlayer and basePart:IsDescendantOf(StorePlayer:IsA("House") and StorePlayer.ParentObjects or StorePlayer.Decors) then
		local _, DataSettings = store.AddedDecor.Added.verificarExistencia(toolName)
		if not DataSettings then return end
		local item = store.AddItem(DataSettings.Data.Name, DataSettings.Data.Value, DataSettings.Data)
		item.Parent = player:FindFirstChild("InventoryBuild")
		if not item.Parent then return end
		
		local data = store:SetDecorPlayer(player,item)
		if not data then return end
		local Colors = {}
		for _,v in tool:GetChildren() do
			if v:IsA("BasePart") and string.match(v.Name:lower(), "color") then
				table.insert(Colors, {Name = v.Name, Color = v.Color})
			end
		end
		newModel = store:UpdateDecor(player,data.Boolean, {
			Position = finalCFrame,
			Colors = Colors,
			owner = tool:GetAttribute("owner"),
			inventory = tool:GetAttribute("inventory"),
		})
	else
		newModel = modelTemplate:Clone()
		NoAplication = false
	end
	if not newModel then return end

	copyAttributes(tool, newModel)
	setupOpenAttributes(newModel)

	if newModel:GetAttribute("owner") == nil then
		newModel:SetAttribute("owner", "")
	end

	if newModel:GetAttribute("FoodServings") == true then
		newModel:SetAttribute("inventory", false)

		local totalServings = getTotalServings(newModel)
		local servingsLeft = newModel:GetAttribute("ServingsLeft")

		if servingsLeft == nil then
			servingsLeft = totalServings
		end

		newModel:SetAttribute("ServingsLeft", servingsLeft)
		newModel:SetAttribute("TotalServings", totalServings)

		syncFoodVisuals(newModel)
	end

	local useInventory = tool:GetAttribute("inventory")

	if tool:GetAttribute("FoodServings") == true then
		useInventory = false
	end
	
	if tool:GetAttribute("IsBebidaBartender") then
		tool:SetAttribute("IsPlace", true)
		local otherPlayer = game:GetService("Players"):FindFirstChild(newModel:GetAttribute("owner"))
		if otherPlayer then
			BartenderSystem.Drops[otherPlayer] = BartenderSystem.Drops[otherPlayer] or {}
			table.insert(BartenderSystem.Drops[otherPlayer], newModel)
		end
	end
	
	if useInventory == false then
		tool:Destroy()
	else
		InventoryManager.removeItem(player, toolName)
	end

	if not NoAplication then
		newModel:PivotTo(finalCFrame)
		newModel.Parent = workspaceTools
		CollectionService:AddTag(newModel, PLACE_TAG)
	end

	if hasOpenAnimation(newModel) then
		task.defer(function()
			prepareOpenState(newModel)

			if newModel:GetAttribute("Opened") == true then
				playOpenAnimationAndHold(newModel)
			end
		end)
	end
end)

-- RECOGER OBJETO COLOCADO
remotes.PickupTool.OnServerEvent:Connect(function(player, model)
	if not canUsePlacedModel(player, model) then
		return
	end

	if modelLocks[model] then
		return
	end

	modelLocks[model] = true

	local character = player.Character
	if not character then
		modelLocks[model] = nil
		return
	end
	
	local humanoid : Humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		modelLocks[model] = nil
		return
	end
	

	local toolName = model.Name
	local useInventory = model:GetAttribute("inventory")
	local isFoodServings = model:GetAttribute("FoodServings") == true

	if isFoodServings then
		syncFoodVisuals(model)
	end

	local toolToGive: Tool? = nil

	if useInventory == false or isFoodServings then
		toolToGive = createToolFromPlacedModel(model)
	end
	
	if model:GetAttribute("IsBebidaBartender") then
		BartenderSystem:PutDrop(player, model)
	end

	cleanupOpenState(model)
	model:Destroy()

	if toolToGive then
		humanoid:EquipTool(toolToGive)
	elseif useInventory ~= false then
		InventoryManager.addItem(player, toolName)
	end

	modelLocks[model] = nil
end)

-- ABRIR ENVASE DE COMIDA
remotes.OpenFoodContainer.OnServerEvent:Connect(function(player, model)
	if not canUsePlacedModel(player, model) then
		return
	end

	if model:GetAttribute("FoodServings") ~= true then
		return
	end

	if not hasOpenAnimation(model) then
		return
	end

	setupOpenAttributes(model)

	if model:GetAttribute("Opened") == true then
		return
	end

	if model:GetAttribute("Opening") == true then
		return
	end

	if modelLocks[model] then
		return
	end

	modelLocks[model] = true
	model:SetAttribute("Opening", true)

	prepareOpenState(model)
	playOpenAnimationAndHold(model)

	model:SetAttribute("Opened", true)
	model:SetAttribute("Opening", false)

	modelLocks[model] = nil
end)

-- COGER UNA PORCIÓN
remotes.TakeFoodServing.OnServerEvent:Connect(function(player, model)
	if not canUsePlacedModel(player, model) then
		return
	end

	if not canUseFoodServings(model) then
		return
	end

	if modelLocks[model] then
		return
	end

	modelLocks[model] = true

	local character = player.Character
	if not character then
		modelLocks[model] = nil
		return
	end

	syncFoodVisuals(model)

	local modelServingsLeft = model:GetAttribute("ServingsLeft") or 0

	if modelServingsLeft <= 0 then
		modelLocks[model] = nil
		return
	end

	local portionToolName = getPortionToolName(model)
	local targetTool = findCarriedFoodToolWithSpace(player, portionToolName)

	if targetTool then
		if not addServingToTool(targetTool) then
			modelLocks[model] = nil
			return
		end
	else
		targetTool = createToolFromTemplate(portionToolName, 1)

		if not targetTool then
			modelLocks[model] = nil
			return
		end

		targetTool.Parent = character
	end

	model:SetAttribute("ServingsLeft", modelServingsLeft - 1)
	syncFoodVisuals(model)

	modelLocks[model] = nil
end)

-- DEJAR UNA PORCIÓN
remotes.ReturnFoodServing.OnServerEvent:Connect(function(player, model)
	if not canUsePlacedModel(player, model) then
		return
	end

	if not canUseFoodServings(model) then
		return
	end

	if modelLocks[model] then
		return
	end

	modelLocks[model] = true

	local character = player.Character
	if not character then
		modelLocks[model] = nil
		return
	end

	syncFoodVisuals(model)

	local modelServingsLeft = model:GetAttribute("ServingsLeft") or 0
	local modelTotalServings = model:GetAttribute("TotalServings") or getTotalServings(model)

	if modelServingsLeft >= modelTotalServings then
		modelLocks[model] = nil
		return
	end

	local portionToolName = getPortionToolName(model)
	local carriedTool = findCarriedFoodTool(player, portionToolName)

	if not carriedTool then
		modelLocks[model] = nil
		return
	end

	if not removeServingFromTool(carriedTool) then
		modelLocks[model] = nil
		return
	end

	model:SetAttribute("ServingsLeft", modelServingsLeft + 1)
	syncFoodVisuals(model)

	modelLocks[model] = nil
end)