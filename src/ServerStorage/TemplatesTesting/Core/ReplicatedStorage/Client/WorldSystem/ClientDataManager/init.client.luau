--[Roblox Services]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Modules
local Channel = require(script.Channel)
-- Remotes
local WorldDataUpdated = ReplicatedStorage:WaitForChild("Events"):WaitForChild("WorldSystem"):WaitForChild("WorldDataUpdated")

WorldDataUpdated.OnClientEvent:Connect(function(dataStoreName, newData)
	Channel:Fire(dataStoreName, newData)
end)