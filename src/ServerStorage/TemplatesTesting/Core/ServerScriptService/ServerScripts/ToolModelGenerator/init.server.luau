local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage:WaitForChild("Assets")
local toolsFolder = assets:WaitForChild("Tools")

-- Crear la carpeta ToolsModels si no existe
local modelsFolder = assets:FindFirstChild("ToolsModels")
if not modelsFolder then
	modelsFolder = Instance.new("Folder")
	modelsFolder.Name = "ToolsModels"
	modelsFolder.Parent = assets
end

local SCRIPT_CLASSES = {
	Script = true,
	LocalScript = true,
	ModuleScript = true,
}

local function copyAttributes(fromInstance: Instance, toInstance: Instance)
	for key, value in fromInstance:GetAttributes() do
		toInstance:SetAttribute(key, value)
	end
end

local function removeScripts(instance: Instance)
	if SCRIPT_CLASSES[instance.ClassName] then
		instance:Destroy()
		return
	end

	for _, descendant in instance:GetDescendants() do
		if SCRIPT_CLASSES[descendant.ClassName] then
			descendant:Destroy()
		end
	end
end

local function configureWorldVisual(instance: Instance)
	if instance:IsA("BasePart") then
		instance.Anchored = true
		instance.CanCollide = false
		instance.CanTouch = true
		instance.CanQuery = true
	end

	for _, descendant in instance:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = true
			descendant.CanQuery = true
		end
	end
end

local function ensurePromptHolder(model: Model): BasePart
	local existing = model:FindFirstChild("PromptHolder")

	if existing and existing:IsA("BasePart") then
		existing.Transparency = 1
		existing.Anchored = true
		existing.CanCollide = false
		existing.CanTouch = false
		existing.CanQuery = false

		model.PrimaryPart = existing
		return existing
	end

	-- Importante:
	-- Temporalmente quitamos PrimaryPart para calcular el bounding box natural,
	-- parecido al comportamiento anterior del generador.
	model.PrimaryPart = nil

	local cframe, size = model:GetBoundingBox()

	local promptHolder = Instance.new("Part")
	promptHolder.Name = "PromptHolder"
	promptHolder.Size = size or Vector3.new(0.1, 0.1, 0.1)
	promptHolder.Transparency = 1
	promptHolder.Anchored = true
	promptHolder.CanCollide = false
	promptHolder.CanTouch = false
	promptHolder.CanQuery = false
	promptHolder.CFrame = cframe
	promptHolder.Parent = model

	-- Esta es la parte importante:
	-- No usamos Handle como PrimaryPart porque eso cambia el pivot
	-- y puede hacer que al colocar la Tool aparezca girada.
	model.PrimaryPart = promptHolder

	return promptHolder
end

local function syncFoodDefaults(model: Model)
	if model:GetAttribute("FoodServings") ~= true then
		return
	end

	local foodFolder = model:FindFirstChild("FoodNumber", true)

	if not foodFolder or not foodFolder:IsA("Folder") then
		model:SetAttribute("TotalServings", 0)
		model:SetAttribute("ServingsLeft", 0)
		model:SetAttribute("inventory", false)
		return
	end

	local total = #foodFolder:GetChildren()

	model:SetAttribute("TotalServings", total)

	if model:GetAttribute("ServingsLeft") == nil then
		model:SetAttribute("ServingsLeft", total)
	end

	model:SetAttribute("inventory", false)
end

local function createModelFromTool(tool: Tool)
	local oldModel = modelsFolder:FindFirstChild(tool.Name)
	if oldModel then
		oldModel:Destroy()
	end

	local model = Instance.new("Model")
	model.Name = tool.Name

	copyAttributes(tool, model)

	if model:GetAttribute("owner") == nil then
		model:SetAttribute("owner", "")
	end

	-- Conserva la jerarquía:
	-- FoodNumber, folders, modelos, partes, attachments, valores, etc.
	for _, child in tool:GetChildren() do
		if not SCRIPT_CLASSES[child.ClassName] then
			local clone = child:Clone()

			removeScripts(clone)
			configureWorldVisual(clone)

			clone.Parent = model
		end
	end

	ensurePromptHolder(model)
	syncFoodDefaults(model)
	
	script:FindFirstChild("Settings"):Clone().Parent = model
	model.Parent = modelsFolder
end

local function scanForTools(container: Instance)
	if container:IsA("Tool") and container:GetAttribute("Colocable") == true then
		createModelFromTool(container)
		return
	end

	if container:IsA("Folder") then
		for _, child in container:GetChildren() do
			scanForTools(child)
		end
	end
end

scanForTools(toolsFolder)