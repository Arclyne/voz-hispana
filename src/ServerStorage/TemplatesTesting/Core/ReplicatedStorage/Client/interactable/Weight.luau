local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local remotes = ReplicatedStorage.Events
local cooldown = 1
local debounce = false

local Weight = {}
Weight.__index = Weight

function Weight.new(tool: Tool)
	local self = setmetatable({}, Weight)
	self.tool = tool
	
	self.equippedConn = tool.Equipped:Connect(function()
		self.clickedConn = UserInputService.InputBegan:Connect(function(input, processed)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and not processed then
				self:click()
			end
		end)
	end)

	self.unequippedConn = tool.Unequipped:Connect(function()
		if self.clickedConn then
			self.clickedConn:Disconnect()
			self.clickedConn = nil
		end
	end)
	
	return self
end

function Weight:click()
	if debounce then
		return
	end
	
	debounce = true
	remotes.Interactable.Weight:FireServer()
	
	task.wait(cooldown)
	debounce = false
end

function Weight:onDestroy()
	if self.clickedConn then
		self.clickedConn:Disconnect()
	end
	self.equippedConn:Disconnect()
	self.unequippedConn:Disconnect()
end

return Weight
