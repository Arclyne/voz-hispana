--//

local UI = require(script:WaitForChild("UI"))

--//

local Action = {}
Action.__index = Action

function Action.new(parentPage, actionName, callback, ...)
	local self = setmetatable({}, Action)
	
	--//Init
	self.args = {...}
	self.actionName = actionName
	self.callback = callback
	self.parentPage = parentPage
	self.button = UI.makeActionButton(actionName)
	--//Setup
	self.button.Parent = parentPage.content
	--//Events
	self.button.MouseButton1Click:Connect(function()
		task.spawn(callback, table.unpack(self.args)) 
		parentPage:hide()
		parentPage.mainPage:hide()
	end)
	
	return self
end

function Action:destroy()
	self.button:Destroy()
	self = nil
end

--//

local PageButton = {}
PageButton.__index = PageButton

function PageButton.new(parentPage, page, pageName)
	local self = setmetatable({}, PageButton)
	
	--//Init
	self.page = page
	self.pageName = pageName
	self.parentPage = parentPage	
	self.button = UI.makePageButton(pageName)
	--//Setup
	self.button.Parent = parentPage.content
	--//Events
	self.button.MouseButton1Click:Connect(function()
		self.parentPage:hide()
		self.page:show()
	end)
	
	return self
end

function PageButton:destroy()
	self.button:Destroy()
	self = nil
end

--//

local Page = {}
Page.__index = Page

function Page.new()
	local self = setmetatable({}, Page)
	
	--//Init
	self.enabled = false
	self.actions = {}
	self.pageButtons = {}
	self.control = UI.makeControlButton()
	self.content = UI.makePage()
	self.container = nil
	self.returnPage = nil
	self.mainPage = nil
	self.shown = Instance.new("BindableEvent")
	self.hidden = Instance.new("BindableEvent")
	--//Setup
	self.control.Parent = self.content
	self.content.Visible = false
	
	return self
end

function Page:setType(pageType)
	if (pageType == "main") then
		self.mainPage = self
		self.childPages = {}
		self.control.Content.Icon.Image = "rbxassetid://18774924973"
		self.control.MouseButton1Click:Connect(function()
			self:hide()
		end)
	elseif (pageType == "subPage") then
		self.control.Content.Icon.Image = "rbxassetid://18774947861"
		self.control.MouseButton1Click:Connect(function()
			if (not self.returnPage) then return end;

			self:hide()
			self.returnPage:show()
		end)
	end
end

function Page:getActivePage()
	if (not self.childPages) then return end;
	if (self.enabled) then return self end;
	
	for _, page in pairs(self.childPages) do
		if (not page.enabled) then continue end
		return page
	end
end

function Page:setReturnPage(returnPage)
	self.returnPage = returnPage
end

function Page:setContainer(container)
	self.container = container
	self.content.Parent = container
end

function Page:placeButtons()
	local x = 0
	for _, action in pairs(self.actions) do
		x += 1
	end
	for _, pageButton in pairs(self.pageButtons) do
		x += 1
	end	
	
	local r = .25
	local i = 0
	local step = (2 * math.pi) / x
	for _, action in pairs(self.actions) do
		local angle = step * i
		local direction = Vector2.new(math.sin(angle), math.cos(angle))
		local x, y = direction.X * r, direction.Y * r

		action.button.Position = UDim2.fromScale(x + .5, -y + .5)
		action.button.AnchorPoint = -direction + Vector2.new(.5, .5)
		i += 1
		
	end
	for _, pageButton in pairs(self.pageButtons) do
		local angle = step * i
		local direction = Vector2.new(math.sin(angle), math.cos(angle))
		local x, y = direction.X * r, direction.Y * r

		pageButton.button.Position = UDim2.fromScale(x + .5, -y + .5)
		pageButton.button.AnchorPoint = -direction + Vector2.new(.5, .5)
		i += 1
	end
end

function Page:show()
	self.enabled = true
	
	self.content.Size = UDim2.fromScale(0, 0)
	self.content.Visible = true

	for _, action in pairs(self.actions) do
		local content = action.button:FindFirstChild("Content") 
			or action.button:FindFirstChild("Label")
		content.Visible = true
	end

	self.content:TweenSize(
		UDim2.fromScale(1, 1),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Sine,
		.1,
		true
	)

	task.wait(.1)
	self.shown:Fire()
end

function Page:hide()
	self.enabled = false
	
	for _, action in pairs(self.actions) do
		local content = action.button:FindFirstChild("Content") 
			or action.button:FindFirstChild("Label")
		content.Visible = false
	end

	self.content:TweenSize(
		UDim2.fromScale(0, 0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Sine,
		.1,
		true
	)

	task.wait(.1)
	self.content.Visible = false
	self.hidden:Fire()
end

--

function Page:addAction(actionName, callback, ...)
	local action = Action.new(self, actionName, callback, ...)
	self.actions[actionName] = action
	
	self:placeButtons()
	
	return action
end

function Page:getAction(actionName)
	return self.actions[actionName]
end

function Page:removeAction(actionName)
	local action = self.actions[actionName]
	
	if (action) then
		action:destroy()
		self.actions[actionName] = nil
		self:placeButtons()
	end
end

function Page:clearActions()
	for _, action in pairs(self.actions) do
		action:destroy()
	end
	table.clear(self.actions)
end

--

function Page:addPageButton(pageName)
	local newPage = Page.new()
	newPage:setReturnPage(self)
	newPage:setContainer(self.container)
	newPage:setType("subPage")
	newPage.mainPage = self.mainPage
	
	local button = PageButton.new(self, newPage, pageName)
	self.pageButtons[pageName] = button
	table.insert(self.mainPage.childPages, newPage)
	
	self:placeButtons()
	return button
end

function Page:getPageButton(pageName)
	return self.pageButtons[pageName]
end

function Page:removePageButton(pageName)
	local pageButton = self.pageButtons[pageName]

	if (pageButton) then
		pageButton:destroy()
		self.pageButtons[pageName] = nil
		self:placeButtons()
	end
end

--

return Page
