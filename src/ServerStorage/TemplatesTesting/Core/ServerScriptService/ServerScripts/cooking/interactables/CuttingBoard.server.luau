local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CookingStation = require(script.Parent.Parent.CookingStation)
local InventoryManager = require(script.Parent.Parent.Parent.inventory.InventoryManager)

local remotes = ReplicatedStorage.Events
local remote = remotes.Interactable.CuttingBoard

local DEFAULT_CHOPS = 5
local CHOP_COOLDOWN = 0.25

local sessions = {}

remote.OnServerEvent:Connect(function(player: Player, model: Model)
	local session = sessions[model]

	-- Active session: treat as a chop click
	if session then
		if session.player ~= player then return end
		if os.clock() - session.lastChop < CHOP_COOLDOWN then return end

		session.chops += 1
		session.lastChop = os.clock()
		model:SetAttribute("ChopProgress", session.chops / session.requiredChops)

		if session.chops >= session.requiredChops then
			session.deathConn:Disconnect()
			session.leaveConn:Disconnect()
			session.cleanup()
			sessions[model] = nil

			InventoryManager.addItem(player, session.target)
			InventoryManager.equipTool(player, session.target)
		end
		return
	end

	-- New session: validate
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local tool = character:FindFirstChildOfClass("Tool")
	if not tool or not tool:GetAttribute("Cuttable") then return end

	local targetValue = tool:FindFirstChild("Target")
	if not targetValue or not targetValue:IsA("ObjectValue") or not targetValue.Value then return end
	local target = targetValue.Value.Name

	local occupant = model:FindFirstChild("Occupant")
	if not occupant or occupant.Value then return end

	local knife = model:FindFirstChild("Knife")
	if not knife then return end

	-- Setup visuals and state
	occupant.Value = player

	local foodClone = CookingStation.cloneFood(tool)
	if foodClone then
		foodClone:PivotTo(model.Board:GetPivot() * CFrame.Angles(math.rad(-90), 0, 0))
		foodClone.Parent = model
	end

	local knifeClone = knife:Clone()
	for _, part in knifeClone:GetChildren() do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end
	knifeClone.Motor6D.Part0 = character:FindFirstChild("RightHand")
	knifeClone.Parent = character
	knife.Parent = nil

	local toolName = tool.Name
	InventoryManager.unequipTool(player)
	InventoryManager.removeItem(player, toolName)

	local requiredChops = model:GetAttribute("Chops") or DEFAULT_CHOPS
	model:SetAttribute("ChopProgress", 0)

	local function cleanup()
		if occupant.Value == player then occupant.Value = nil end
		if foodClone then foodClone:Destroy() end
		if knifeClone.Parent then knifeClone:Destroy() end
		knife.Parent = model
		model:SetAttribute("ChopProgress", nil)
	end

	local deathConn, leaveConn
	local function cancel()
		deathConn:Disconnect()
		leaveConn:Disconnect()
		cleanup()
		sessions[model] = nil
	end

	deathConn = humanoid.Died:Once(cancel)
	leaveConn = Players.PlayerRemoving:Connect(function(p)
		if p == player then cancel() end
	end)

	sessions[model] = {
		player = player,
		target = target,
		chops = 0,
		requiredChops = requiredChops,
		lastChop = os.clock(),
		cleanup = cleanup,
		deathConn = deathConn,
		leaveConn = leaveConn,
	}
end)
