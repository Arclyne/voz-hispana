local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryManager = require(script.Parent.Parent.inventory.InventoryManager)

local remotes = ReplicatedStorage.Events
local progressBarRemote = remotes.Interactable.CutBar
local cancelBarRemote = remotes.Interactable.CancellCut

local assets = ReplicatedStorage.Assets

local activeExpirations: { [Model]: thread } = {}

local CookingStation = {}
CookingStation.__index = CookingStation

function CookingStation.cloneFood(tool: Tool): Model?
	local content = tool:FindFirstChildOfClass("Model")
	if not content then
		return nil
	end

	local clone = content:Clone()
	for _, desc in clone:GetDescendants() do
		if desc:IsA("BasePart") then
			desc.Anchored = true
			if not clone.PrimaryPart then
				clone.PrimaryPart = desc
			end
		end
	end
	return clone
end

function CookingStation.spawnResultVisual(stationModel: Model, targetName: string, resultCFrame: CFrame?)
	local toolAsset = assets.Tools:FindFirstChild(targetName, true)
	if not toolAsset then
		return
	end

	local foodModel = toolAsset:FindFirstChildOfClass("Model")
	local visual = if foodModel then foodModel:Clone() else toolAsset:Clone()
	for _, desc in visual:GetDescendants() do
		if desc:IsA("BasePart") then
			desc.Anchored = true
			if not visual.PrimaryPart then
				visual.PrimaryPart = desc
			end
		end
	end

	local size = stationModel:GetExtentsSize()
	local spawnCF = resultCFrame or stationModel:GetPivot() * CFrame.new(0, size.Y / 2 + 0.5, 0)
	visual:PivotTo(spawnCF)

	local existing = stationModel:FindFirstChild("Pickable_Result")
	if existing then
		existing:Destroy()
	end

	visual.Name = "Pickable_Result"
	visual.Parent = stationModel
end

function CookingStation.new(remoteName: string)
	local self = setmetatable({}, CookingStation)
	self.remoteName = remoteName
	self.defaultDuration = 5
	self.skipResultVisual = false
	self.expirationTime = nil :: number?
	self.expiredItem = nil :: string?
	return self
end

function CookingStation:matchAttribute(tool: Tool): string?
	return nil
end

function CookingStation:validate(model: Model): boolean
	return true
end

function CookingStation:onStart(ctx): (() -> CFrame?)?
	return nil
end

function CookingStation:onCancel(ctx) end

function CookingStation:onPickup(model: Model) end

function CookingStation:onExpire(model: Model): boolean
	return false
end

function CookingStation:removeTool(player: Player, toolName: string)
	InventoryManager.unequipTool(player)
	InventoryManager.removeItem(player, toolName)
end

function CookingStation:bind()
	local remote = remotes.Interactable[self.remoteName]

	remote.OnServerEvent:Connect(function(player: Player, model: Model)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end

		-- Handle pickup of ready result
		local resultReady = model:GetAttribute("ResultReady")
		if resultReady then
			model:SetAttribute("ResultReady", nil)
			model:SetAttribute("ExpirationDuration", nil)

			if activeExpirations[model] then
				task.cancel(activeExpirations[model])
				activeExpirations[model] = nil
			end

			local resultVisual = model:FindFirstChild("Pickable_Result")
			if resultVisual then
				resultVisual:Destroy()
			end

			local processing = model:FindFirstChild("ProcessingVisual")
			if processing then
				processing:Destroy()
			end

			self:onPickup(model)

			InventoryManager.addItem(player, resultReady)
			InventoryManager.equipTool(player, resultReady)
			return
		end

		local tool = character:FindFirstChildOfClass("Tool")
		if not tool then
			return
		end

		local matchedAttribute = self:matchAttribute(tool)
		if not matchedAttribute then
			return
		end

		local targetValue = tool:FindFirstChild("Target")
		if not targetValue or not targetValue:IsA("ObjectValue") or not targetValue.Value then
			return
		end

		local target = targetValue.Value.Name

		if not self:validate(model) then
			return
		end

		local duration = model:GetAttribute("Duration") or self.defaultDuration

		local toolRemoved = false
		local ctx = {
			player = player,
			character = character,
			humanoid = humanoid,
			model = model,
			tool = tool,
			toolName = tool.Name,
			target = target,
			duration = duration,
			matchedAttribute = matchedAttribute,

			removeTool = function()
				if toolRemoved then
					return
				end

				toolRemoved = true
				self:removeTool(player, tool.Name)
			end,
		}

		local cleanup = self:onStart(ctx)

		ctx.removeTool()

		progressBarRemote:FireAllClients(model, player, duration)

		local cancelled = false

		local function onCancel()
			cancelled = true
			self:onCancel(ctx)
			cancelBarRemote:FireAllClients(model)
		end

		local deathConn = humanoid.Died:Once(onCancel)

		local leaveConn = Players.PlayerRemoving:Connect(function(p)
			if p == player then
				onCancel()
			end
		end)

		task.wait(duration)

		deathConn:Disconnect()
		leaveConn:Disconnect()

		local resultCFrame

		if cleanup then
			resultCFrame = cleanup()
		end

		if cancelled then
			return
		end

		if not self.skipResultVisual then
			CookingStation.spawnResultVisual(model, target, resultCFrame)
		end

		model:SetAttribute("ResultReady", target)

		if self.expirationTime and self.expiredItem then
			if activeExpirations[model] then
				task.cancel(activeExpirations[model])
			end

			model:SetAttribute("ExpirationDuration", self.expirationTime)

			activeExpirations[model] = task.delay(self.expirationTime, function()
				activeExpirations[model] = nil

				if not model:GetAttribute("ResultReady") then
					return
				end

				local handled = self:onExpire(model)

				if not handled then
					local oldVisual = model:FindFirstChild("Pickable_Result")

					if oldVisual then
						oldVisual:Destroy()
					end

					local processing = model:FindFirstChild("ProcessingVisual")
					local processingCFrame

					if processing then
						processingCFrame = processing:GetPivot()
						processing:Destroy()
					end

					CookingStation.spawnResultVisual(
						model,
						self.expiredItem,
						processingCFrame or resultCFrame
					)
				end

				model:SetAttribute("ExpirationDuration", nil)
				model:SetAttribute("ResultReady", self.expiredItem)
			end)
		end
	end)
end

return CookingStation