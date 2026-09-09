local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local IGNORE_TAG = "IgnoreAutoEnable"

local InitScriptsReadyFlag = ReplicatedStorage:FindFirstChild("InitScriptsReadyFlag")
if not InitScriptsReadyFlag then
	InitScriptsReadyFlag = Instance.new("BoolValue")
	InitScriptsReadyFlag.Name = "InitScriptsReadyFlag"
	InitScriptsReadyFlag.Parent = ReplicatedStorage
end

InitScriptsReadyFlag.Value = false

-- 1) Esperar templates
require(ReplicatedStorage:WaitForChild("InitAfterTemplates"))

task.wait(1)

-- 2) Habilitar scripts
local enabledCount, ignoredCount = 0, 0
local ClientScriptsFolder = ReplicatedStorage:FindFirstChild("Client")

for _, obj in ipairs(game:GetDescendants()) do
	if obj:IsDescendantOf(Players) or obj:IsDescendantOf(game.ServerStorage) then
		continue
	end

	if ClientScriptsFolder and obj:IsDescendantOf(ClientScriptsFolder) then
		continue
	end

	if obj:IsA("BaseScript") and obj.Enabled == false then
		if CollectionService:HasTag(obj, IGNORE_TAG) then
			ignoredCount += 1
		else
			local ok, err = pcall(function()
				obj.Enabled = true
			end)

			if ok then
				enabledCount += 1
			else
				warn("No se pudo habilitar:", obj:GetFullName(), err)
			end
		end
	end
end

InitScriptsReadyFlag.Value = true

print(("✅ Scripts de templates activados: %d, ignorados: %d"):format(
	enabledCount,
	ignoredCount
))