--//

local assets = script:WaitForChild("Assets")

local page = assets:WaitForChild("Page")
local pageButton = assets:WaitForChild("PageButton")
local actionButton = assets:WaitForChild("ActionButton")
local controlButton = assets:WaitForChild("ControlButton")

local bounds = Vector2.new(350, 350)

--//

local function animateButton(button : TextButton, content)
	button.MouseEnter:Connect(function()
		if (not button.Parent) then return end;
		content:TweenPosition(
			UDim2.fromScale(0, -.06),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Sine,
			.08,
			true
		)
	end)
	button.MouseLeave:Connect(function()
		if (not button.Parent) then return end;
		content:TweenPosition(
			UDim2.fromScale(0, -.1),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Sine,
			.1,
			true
		)
	end)
	button.MouseButton1Down:Connect(function()
		if (not button.Parent) then return end;
		content:TweenPosition(
			UDim2.fromScale(0, 0),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Sine,
			.08,
			true
		)
	end)
	button.MouseButton1Up:Connect(function()
		if (not button.Parent) then return end;
		content:TweenPosition(
			UDim2.fromScale(0, -.1),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Sine,
			.1,
			true
		)
	end)
end

local UI = {}

function UI.makePage()
	return page:Clone()
end

function UI.makeActionButton(text) : TextButton
	local button = actionButton:Clone()
	local label = button:FindFirstChild("Label")

	if not label or not label:IsA("TextLabel") then
		warn("ActionButton no tiene un hijo Label válido")
		return button
	end

	label.Text = text
	animateButton(button, label)

	local c
	c = button:GetPropertyChangedSignal("Parent"):Connect(function()
		if not button.Parent then
			return
		end

		c:Disconnect()

		task.defer(function()
			if not label.Parent then
				return
			end

			local textBounds = label.TextBounds
			local sizeInScale = textBounds.X / bounds.X
			button.Size = UDim2.fromScale(sizeInScale + .1, .1)
		end)
	end)

	return button
end

function UI.makePageButton(text) : TextButton
	local button = pageButton:Clone()
	button.Content.Label.Text = text
	
	animateButton(button, button.Content)
	
	local c;
	c = button:GetPropertyChangedSignal("Parent"):Connect(function()
		c:Disconnect()
		local textBounds = button.Content.Label.TextBounds
		local sizeInScale = textBounds.X / bounds.X
		button.Size = UDim2.fromScale(sizeInScale + .15, .1)
	end)

	return button
end

function UI.makeControlButton(buttonType) : TextButton
	local button = controlButton:Clone()
	button.AutoButtonColor = true
	
	return button
end

return UI
