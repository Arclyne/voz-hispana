local Tool = script.Parent
local TweenService = game:GetService("TweenService")
local Player = game:GetService("Players").LocalPlayer

if not Player.Character or not Player.Character.Parent then
	Player.CharacterAdded:Wait()
end

local ScreenGUI = Player.PlayerGui:WaitForChild("Walkie")
local WalkieFrame = ScreenGUI.ToolEquipada
local WalkieText = WalkieFrame.ImageLabel.Channel
local RemoteEvent = game.ReplicatedStorage.Events.Tools.Walkie

local CurrentChannel = ""

local tweenInfoIn = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local tweenInfoOut = TweenInfo.new(
	0.4,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.In,
	0,
	false,
	0
)

local hiddenPosition = UDim2.new(1.2, 0, 0.53, 0)
local visiblePosition = UDim2.new(0.908, 0, 0.53, 0)

WalkieFrame.Position = hiddenPosition
WalkieFrame.Visible = false

local function updateChannelText()
	local displayText = CurrentChannel
	local missingDigits = 3 - #displayText
	if missingDigits > 0 then
		displayText = displayText .. string.rep("-", missingDigits)
	end
	WalkieText.Text = displayText
end

Tool.Equipped:Connect(function()
	WalkieFrame.Visible = true
	local tweenIn = TweenService:Create(
		WalkieFrame,
		tweenInfoIn,
		{Position = visiblePosition}
	)
	tweenIn:Play()
end)

Tool.Unequipped:Connect(function()
	local tweenOut = TweenService:Create(
		WalkieFrame,
		tweenInfoOut,
		{Position = hiddenPosition}
	)
	tweenOut.Completed:Connect(function()
		WalkieFrame.Visible = false
	end)
	tweenOut:Play()
end)

for _, button in ipairs(WalkieFrame.ImageLabel.Buttons:GetChildren()) do
	if button:IsA("TextButton") then
		button.Activated:Connect(function()
			if tonumber(button.Name) ~= nil then
				if #CurrentChannel < 3 then
					CurrentChannel = CurrentChannel .. button.Name
				else
					CurrentChannel = CurrentChannel:sub(2) .. button.Name
				end
				updateChannelText()
			elseif button.Name == "Delete" then
				CurrentChannel = CurrentChannel:sub(1, -2)
				updateChannelText()
			elseif button.Name == "Ok" then
				if #CurrentChannel == 3 then
					RemoteEvent:FireServer(CurrentChannel, Tool)
				end
			end
		end)
	end
end

updateChannelText()