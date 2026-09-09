local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer

local questEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Quests")
local GetQuestPickables = questEvents:WaitForChild("GetQuestPickables")
local QuestPickablesUpdated = questEvents:WaitForChild("QuestPickablesUpdated")

local pickableTemplates = ReplicatedStorage
	:WaitForChild("Assets")
	:WaitForChild("Quests")
	:WaitForChild("PickableObjects")

local localFolder = workspace:FindFirstChild("LocalQuestPickables")

if not localFolder then
	localFolder = Instance.new("Folder")
	localFolder.Name = "LocalQuestPickables"
	localFolder.Parent = workspace
end

local spawned = {}

local function placeObject(clone: Instance, position: Vector3)
	if clone:IsA("Model") then
		clone:PivotTo(CFrame.new(position))
	elseif clone:IsA("BasePart") then
		clone.CFrame = CFrame.new(position)
	end
end

local function applyPickables(list)
	local keep = {}

	for _, info in ipairs(list or {}) do
		keep[info.Id] = true

		if spawned[info.Id] then
			continue
		end

		local template = pickableTemplates:FindFirstChild(info.ObjectName)

		if not template then
			warn("[QuestPickableClient] No existe el objeto:", info.ObjectName)
			continue
		end

		local clone = template:Clone()
		clone.Name = info.ObjectName
		clone:SetAttribute("CollectibleId", info.Id)
		clone:SetAttribute("ObjectName", info.ObjectName)

		placeObject(clone, info.Position)

		clone.Parent = localFolder

		CollectionService:AddTag(clone, "QuestPickable")

		spawned[info.Id] = clone
	end

	for id, object in pairs(spawned) do
		if not keep[id] then
			if object and object.Parent then
				object:Destroy()
			end

			spawned[id] = nil
		end
	end
end

local function refresh()
	local success, list = pcall(function()
		return GetQuestPickables:InvokeServer()
	end)

	if success then
		applyPickables(list)
	else
		warn("[QuestPickableClient] Error pidiendo pickables:", list)
	end
end

QuestPickablesUpdated.OnClientEvent:Connect(function(list)
	applyPickables(list)
end)

player.CharacterAdded:Connect(function()
	task.wait(1)
	refresh()
end)

task.defer(refresh)