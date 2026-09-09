--//

local players = game:GetService("Players")

--//

local player = players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local assets = script:WaitForChild("Assets")
local billBoard = assets:WaitForChild("Billboard")

local holderFolder = Instance.new("ScreenGui")
holderFolder.ResetOnSpawn = false
holderFolder.Parent = playerGui
holderFolder.Name = "ActionWheels"

--//

local Page = require(script:WaitForChild("Page"))

--//

local QuickAction = {}
QuickAction.__index = QuickAction

function QuickAction.new(actionName, callback, ...)
	local self = setmetatable({}, QuickAction)
	self.actionName = actionName
	self.callback = callback
	self.args = {...}
	
	return self
end

function QuickAction:perform()
	task.spawn(self.callback, table.unpack(self.args))
end

--//

local ActionWheel = {}
ActionWheel.__index = ActionWheel

function ActionWheel.new()
	local self = setmetatable({}, ActionWheel)
	--//Init
	self.quickAction = nil
	self.container = billBoard:Clone()
	self.page = Page.new()
	self.quickActionChanged = Instance.new("BindableEvent")
	--//Setup
	self.container.Parent = holderFolder
	self.page:setType("main")
	self.page:setContainer(self.container)
	--//
	return self
end

function ActionWheel:show()
	self.page:show()
end

function ActionWheel:hide()
	local activePage = self.page:getActivePage()
	if (activePage) then
		activePage:hide()
	end
end

function ActionWheel:destroy()
	self.container:Destroy()
	self = nil
end

function ActionWheel:getActivePage()
	return self.page:getActivePage()
end

function ActionWheel:addPage(pageName)
	return self.page:addPageButton(pageName).page
end
function ActionWheel:removePage(pageName)
	return self.page:removePageButton(pageName)
end

function ActionWheel:setAdornee(adornee)
	self.container.Adornee = adornee
end

function ActionWheel:setQuickAction(actionName, callback, ...)
	self.quickAction = QuickAction.new(actionName, callback, ...)
	self.quickActionChanged:Fire()
end

return ActionWheel
