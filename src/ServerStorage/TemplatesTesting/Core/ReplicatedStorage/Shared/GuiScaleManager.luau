local UserInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

local GuiScaleManager = {}

local registered = {}

local function getOrCreateScale(guiObject: GuiObject): UIScale
	local scale = guiObject:FindFirstChildOfClass("UIScale")

	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = guiObject
	end

	return scale
end

local function isKeyboardAndMouse()
	local preferredInput = UserInputService.PreferredInput

	if preferredInput == Enum.PreferredInput.KeyboardAndMouse then
		return true
	end

	return UserInputService.KeyboardEnabled and UserInputService.MouseEnabled and not UserInputService.TouchEnabled
end

local function resolveScale(config)
	local pcScale = config.pcScale or 0.85
	local mobileScale = config.mobileScale or 1
	local tabletScale = config.tabletScale or mobileScale

	local camera = workspace.CurrentCamera
	local minSide = camera and math.min(camera.ViewportSize.X, camera.ViewportSize.Y) or 1000

	if isKeyboardAndMouse() then
		return pcScale
	end

	if minSide >= 800 then
		return tabletScale
	end

	return mobileScale
end

local function applyOne(entry)
	if not entry.guiObject.Parent then
		return
	end

	local scale = getOrCreateScale(entry.guiObject)
	scale.Scale = resolveScale(entry.config)
end

function GuiScaleManager.Register(guiObject: GuiObject, config)
	if not guiObject or not guiObject:IsA("GuiObject") then
		warn("[GuiScaleManager] Objeto inválido")
		return
	end

	config = config or {}

	local entry = {
		guiObject = guiObject,
		config = config,
	}

	table.insert(registered, entry)

	guiObject.Destroying:Connect(function()
		local index = table.find(registered, entry)
		if index then
			table.remove(registered, index)
		end
	end)

	applyOne(entry)
end

function GuiScaleManager.Refresh()
	for _, entry in ipairs(registered) do
		applyOne(entry)
	end
end

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(GuiScaleManager.Refresh)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	task.defer(GuiScaleManager.Refresh)
end)

task.spawn(function()
	while true do
		task.wait(1)

		local camera = workspace.CurrentCamera
		if camera then
			camera:GetPropertyChangedSignal("ViewportSize"):Connect(GuiScaleManager.Refresh)
			break
		end
	end
end)

return GuiScaleManager