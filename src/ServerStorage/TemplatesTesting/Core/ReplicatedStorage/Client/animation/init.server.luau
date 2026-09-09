local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular)
local player = Players.LocalPlayer

if not player.Character or not player.Character.Parent then
	player.CharacterAdded:Wait()
end

local animations = player:WaitForChild("Animations")
local remotes = ReplicatedStorage.Events
local gui = player.PlayerGui:WaitForChild("AnimationsUI")
local frame = gui:FindFirstChild("Container").frame.ListLayout
local content = frame:FindFirstChild("content")
local stop = frame:FindFirstChild("stop")
local template = script:FindFirstChild("Template")

local function initCategoryFrame(parent)
	local layout = parent.content:FindFirstChildOfClass("UIListLayout")
	local padding = layout.Padding

	parent:GetAttributeChangedSignal("Collapsed"):Connect(function()
		local collapsed = parent:GetAttribute("Collapsed")
		layout.Padding = collapsed and padding or UDim.new()

		TweenService:Create(parent.headerButton.ImageArrow, tweenInfo, {
			Rotation = collapsed and 0 or 90
		}):Play()

		for _, child in parent.content:GetChildren() do
			if child:IsA("TextButton") then
				TweenService:Create(child, tweenInfo, {
					Size = UDim2.new(
						template.Size.X,
						collapsed and template.Size.Y or UDim.new()
					),
					TextTransparency = collapsed and 0 or 1
				}):Play()
			end
		end
	end)

	parent.headerButton.Activated:Connect(function()
		local collapsed = parent:GetAttribute("Collapsed")
		parent:SetAttribute("Collapsed", not collapsed)
	end)
	
	parent:SetAttribute("Collapsed", false)
end

local function addAnimation(name: string, category: string)
	local parent = content:FindFirstChild(category)
	if not parent then
		warn(`animation category "{category}" not found`)
		return
	end

	local button = template:Clone()
	button.Name = name
	button.Text = name
	button.Parent = parent:FindFirstChild("content")
	button.Activated:Connect(function()
		remotes.Animate:FireServer(name)
	end)
	
	local collapsed = parent:GetAttribute("Collapsed")
	if not collapsed then
		button.Size = UDim2.new(button.Size.X, UDim.new(0))
		button.TextTransparency = 1
	end
end

local function removeAnimation(name: string)
	for _, categoryFrame in content:GetChildren() do
		if not categoryFrame:IsA("Frame") then
			continue
		end

		for _, button in categoryFrame:GetChildren() do
			if button.Name == name then
				button:Destroy()
			end
		end
	end
end

for _, animation in animations:GetChildren() do
	addAnimation(animation.Name, animation:GetAttribute("Category"))
end

animations.ChildAdded:Connect(function(animation)
	addAnimation(animation.Name, animation:GetAttribute("Category"))
end)

animations.ChildRemoved:Connect(function(animation)
	removeAnimation(animation.Name)
end)

stop.Activated:Connect(function()
	remotes.Animate:FireServer()
end)

for _, categoryFrame in content:GetChildren() do
	if categoryFrame:IsA("Frame") then
		initCategoryFrame(categoryFrame)
	end
end
