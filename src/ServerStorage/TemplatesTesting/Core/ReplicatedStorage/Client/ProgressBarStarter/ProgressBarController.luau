-- ReplicatedStorage/Client/ProgressBarController.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ProgressBarController = {}
ProgressBarController._started = false

-- targetModel -> {gui: Instance, tween: Tween?}
local activeBars: {[Instance]: {gui: Instance, tween: Tween?}} = {}
local barTemplate = nil

local function destroyBar(targetModel: Instance)
	local info = activeBars[targetModel]
	if not info then return end

	if info.tween then
		pcall(function() info.tween:Cancel() end)
	end
	if info.gui and info.gui.Parent then
		info.gui:Destroy()
	end

	activeBars[targetModel] = nil
end

local function showBar(targetModel: Model, duration: number)
	if not targetModel or not targetModel.Parent then return end

	local adornee = targetModel:FindFirstChild("Head") or targetModel:FindFirstChild("Prompt")
	if not adornee or not adornee:IsA("BasePart") then return end

	-- reiniciar si ya existía
	destroyBar(targetModel)

	if not barTemplate then
		barTemplate = ReplicatedStorage.Assets.Interactable.Billboard:WaitForChild("Bar")
	end
	local gui = barTemplate:Clone()
	gui.Name = "Bar_Global"

	if gui:IsA("BillboardGui") then
		gui.Adornee = adornee
	end
	gui.Parent = adornee

	local barFrame = gui:FindFirstChild("ToolActivatedBar", true)
	local progressBar = barFrame and barFrame:FindFirstChild("Bar", true)
	if not barFrame or not progressBar then
		gui:Destroy()
		return
	end

	progressBar.Size = UDim2.new(0, 0, 1, 0)
	barFrame.Visible = true

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(progressBar, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)})

	activeBars[targetModel] = {gui = gui, tween = tween}

	tween.Completed:Connect(function(state)
		-- si se reinició/quitó, ignorar
		if not activeBars[targetModel] or activeBars[targetModel].gui ~= gui then return end
		if state == Enum.PlaybackState.Completed then
			barFrame.Visible = false
			task.delay(0.25, function()
				destroyBar(targetModel)
			end)
		end
	end)

	tween:Play()
end

function ProgressBarController.Init()
	if ProgressBarController._started then return end
	ProgressBarController._started = true

	local remotes = ReplicatedStorage:WaitForChild("Events")
	local interactable = remotes:WaitForChild("Interactable")

	local CutBarEvent = interactable:WaitForChild("CutBar")
	local CancelEvent = interactable:WaitForChild("CancellCut")

	-- Server -> Clients: (targetModel, activatingPlayer, duration)
	CutBarEvent.OnClientEvent:Connect(function(targetModel: Model, _activatingPlayer: Player, duration: number?)
		showBar(targetModel, duration or 3)
	end)

	-- Server -> Clients: (targetModel)
	CancelEvent.OnClientEvent:Connect(function(targetModel: Model)
		if targetModel then
			destroyBar(targetModel)
		end
	end)
end

return ProgressBarController
