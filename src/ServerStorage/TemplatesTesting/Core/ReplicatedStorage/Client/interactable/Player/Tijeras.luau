local Tijeras = {}
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local remotes = ReplicatedStorage:WaitForChild("Events")
local StartCut = remotes.Interactable:WaitForChild("StartCut")
local EndCut = remotes.Interactable:WaitForChild("EndCut")
local CancelCut = remotes.Interactable:WaitForChild("CancellCut")
local CutBarEvent = remotes.Interactable:WaitForChild("CutBar")

local CooldownShared = require(ReplicatedStorage.Shared.Cooldown:WaitForChild("CooldownShared"))

local MaxDistance = 15
local DefaultDuration = 3
local COOLDOWN_KEY = "Tijeras"

local TijerasState = {
	isActionActive = false,
	checkConnection = nil,
	activePlayer = nil,
	targetModel = nil :: Model?,
	cancelSent = false,
}

local function cleanUp()
	if TijerasState.checkConnection then
		TijerasState.checkConnection:Disconnect()
		TijerasState.checkConnection = nil
	end
	TijerasState.isActionActive = false
	TijerasState.activePlayer = nil
	TijerasState.targetModel = nil
	TijerasState.cancelSent = false
end

local function getRemainingCooldownSeconds(): number
	local cooldowns = Player:WaitForChild("Cooldowns")
	local v = cooldowns:FindFirstChild(COOLDOWN_KEY)
	local expire = v and v.Value or 0
	return CooldownShared.GetRemainingSeconds(expire)
end

local function toCharacterModel(x): Model?
	if typeof(x) ~= "Instance" then return nil end
	if x:IsA("Model") then return x end
	if x:IsA("Humanoid") then return x.Parent end
	if x:IsA("Player") then return x.Character end
	return nil
end

local function getNearestOtherCharacter(): Model?
	local myChar = Player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end

	local best: Model? = nil
	local bestDist = MaxDistance

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= Player and plr.Character then
			local root = plr.Character:FindFirstChild("HumanoidRootPart")
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if root and hum and hum.Health > 0 then
				local d = (myRoot.Position - root.Position).Magnitude
				if d <= bestDist then
					bestDist = d
					best = plr.Character
				end
			end
		end
	end

	return best
end

local function sendCancel()
	if TijerasState.cancelSent then return end
	TijerasState.cancelSent = true
	if TijerasState.targetModel then
		CancelCut:FireServer(TijerasState.targetModel)
	end
end

function Tijeras.new(playerInstance, tool)
	if playerInstance.wheel and playerInstance.wheel.page then
		playerInstance.wheel.page:addAction("Cortar", function()
			if not TijerasState.isActionActive then
				Tijeras:StartCutAction(playerInstance.model)
			end
		end)
	end

	tool.Unequipped:Connect(function()
		-- si estabas cortando, cancelas en server
		if TijerasState.isActionActive and TijerasState.activePlayer == Player then
			sendCancel()
		end
		playerInstance:RemoveToCatalog("Cortar")
		cleanUp()
	end)
end

function Tijeras:StartCutAction(targetRef)
	-- UX: si estás en cooldown no mandas request
	if getRemainingCooldownSeconds() > 0 then
		return
	end

	local targetModel = toCharacterModel(targetRef)
	if not targetModel or targetModel == Player.Character then
		targetModel = getNearestOtherCharacter()
	end
	if not targetModel then return end

	StartCut:FireServer(targetModel)
end

-- Cuando el server acepta StartCut, avisa a todos. Solo el cutter controla la lógica.
CutBarEvent.OnClientEvent:Connect(function(targetModel: Model, activatingPlayer: Player, duration: number?)
	if not targetModel or not activatingPlayer then return end

	-- Solo el que corta controla End/Cancel (los demás solo ven la barra por el ProgressBarController)
	if activatingPlayer ~= Player then return end

	-- ya había una acción, la limpiamos
	cleanUp()

	TijerasState.isActionActive = true
	TijerasState.activePlayer = activatingPlayer
	TijerasState.targetModel = targetModel
	TijerasState.cancelSent = false

	duration = duration or DefaultDuration

	-- chequeo de distancia continuo
	TijerasState.checkConnection = RunService.Heartbeat:Connect(function()
		if not TijerasState.isActionActive or not TijerasState.targetModel then return end

		local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		local trgRoot = TijerasState.targetModel:FindFirstChild("HumanoidRootPart")
		if not myRoot or not trgRoot then
			sendCancel()
			cleanUp()
			return
		end

		local dist = (myRoot.Position - trgRoot.Position).Magnitude
		if dist > MaxDistance then
			sendCancel()
			cleanUp()
		end
	end)

	-- terminar después de duration
	task.delay(duration, function()
		if not TijerasState.isActionActive then return end
		if TijerasState.activePlayer ~= Player then return end
		if not TijerasState.targetModel then return end

		-- si ya cancelamos, no hacemos EndCut
		if TijerasState.cancelSent then
			cleanUp()
			return
		end

		EndCut:FireServer(TijerasState.targetModel)
		cleanUp()
	end)
end)

-- Si el server cancela, limpiamos (solo si era nuestra acción)
CancelCut.OnClientEvent:Connect(function(targetModel: Model)
	if TijerasState.targetModel and targetModel == TijerasState.targetModel then
		cleanUp()
	end
end)

return Tijeras
