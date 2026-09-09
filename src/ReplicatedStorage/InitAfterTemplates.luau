--[[
    Este script sirve para que otros scripts esperen a que se carguen los templates.
    -------------------------------------------------
    Ejemplo de uso en un Script:

	local ServerStorage = game:GetService("ReplicatedStorage")
	require(ServerStorage:WaitForChild("InitAfterTemplates"))  -- Para esperar a que carguen todos los templates
    -------------------------------------------------
    
    Cualquier duda, preguntar a Alvelex
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TemplatesReady = ReplicatedStorage:WaitForChild("TemplatesReady")
local TemplatesReadyFlag = ReplicatedStorage:WaitForChild("TemplatesReadyFlag")

local ready = false

if RunService:IsServer() then
	-- En servidor usamos la BoolValue como fuente de verdad
	if TemplatesReadyFlag.Value then
		ready = true
	else
		TemplatesReadyFlag.Changed:Connect(function()
			if TemplatesReadyFlag.Value then
				ready = true
			end
		end)
	end
else
	-- En cliente escuchamos el RemoteEvent, y también comprobamos el flag (por si ya fue disparado antes)
	if TemplatesReadyFlag.Value then
		ready = true
	else
		TemplatesReady.OnClientEvent:Connect(function()
			ready = true
		end)
	end
end

repeat task.wait() until ready
return true
