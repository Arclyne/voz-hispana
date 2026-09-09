local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local MAX_PLACE_DISTANCE = 15
local currentGhost = nil

local function getEquippedTool()
	local char = player.Character
	if not char then return nil end
	local tool = char:FindFirstChildOfClass("Tool")
	if tool and tool:GetAttribute("Colocable") then
		return tool
	end
	return nil
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end

	local tool = getEquippedTool()
	if not tool then return end

	-- Raycast para detectar la superficie
	local inputPos = input.Position
	local unitRay = camera:ScreenPointToRay(inputPos.X, inputPos.Y)

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {player.Character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, rayParams)

	if result and result.Instance:GetAttribute("Table") == true then
		local distance = (camera.CFrame.Position - result.Position).Magnitude
		if distance > MAX_PLACE_DISTANCE then return end

		-- Eliminar fantasma anterior si existe
		if currentGhost then currentGhost:Destroy() end

		-- Crear el fantasma (Part invisible)
		currentGhost = Instance.new("Part")
		currentGhost.Name = "PlaceGhost_" .. tool.Name
		currentGhost.Size = Vector3.new(2, 0.5, 2)
		currentGhost.Position = result.Position
		currentGhost.Anchored = true
		currentGhost.Transparency = 1
		currentGhost.CanCollide = false

		-- Guardar datos para la colocación final
		currentGhost:SetAttribute("ToolName", tool.Name)
		currentGhost:SetAttribute("SurfaceRotY", result.Instance.Orientation.Y)

		currentGhost.Parent = result.Instance

		-- Asignar el Tag para que el módulo interactuable lo detecte automáticamente
		CollectionService:AddTag(currentGhost, "PlaceTool")
	end
end)