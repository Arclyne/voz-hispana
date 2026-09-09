print("VisualManager")

--[[
    Visuals Manager
    ---------------
    Este script se encarga de gestionar una lista de objetos que tienen comportamientos visuales,
    actualmente aplicando una rotación a cada objeto según la velocidad definida.
    En el futuro se podrá extender para incluir otros efectos, como movimientos o animaciones de texturas.
    Cualquier duda preguntar a Alvelex
--]]

local RunService = game:GetService("RunService")
local hologramsFolder = workspace.Lobby.RotatingHolograms


-- Definición de la lista de objetos visuales con su respectiva velocidad de rotación
local visualObjects = {
	{ object = workspace.Lobby.Trees.Arbol:WaitForChild("Hojas"), rotationSpeed = 10 },
	{ object = workspace.Lobby.Trees.Arbol:WaitForChild("Hojas2"), rotationSpeed = -10 },
}

for _, tringle in ipairs(hologramsFolder:GetChildren()) do
	-- Asegurarse de que sea un modelo/folder
	if tringle:IsA("Model") or tringle:IsA("Folder") then
		local ico1 = tringle:FindFirstChild("Icosphere1")
		if ico1 then
			table.insert(visualObjects, {
				object = ico1,
				rotationSpeed = 10
			})
		end
		local ico2 = tringle:FindFirstChild("Icosphere2")
		if ico2 then
			table.insert(visualObjects, {
				object = ico2,
				rotationSpeed = -10
			})
		end
	end
end

-- Conexión al evento RenderStepped para actualizar la rotación cada frame
RunService.RenderStepped:Connect(function(deltaTime)
	for _, visual in ipairs(visualObjects) do
		local currentCFrame = visual.object.CFrame
		local angle = math.rad(visual.rotationSpeed) * deltaTime
		visual.object.CFrame = currentCFrame * CFrame.Angles(0, angle, 0)
	end
end)
