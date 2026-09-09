--[Roblox Services]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Instances
local events = ReplicatedStorage:WaitForChild("Events"):WaitForChild("WorldSystem")
-- Remotes
local GetHousesRF = events:WaitForChild("GetHouses")
local GetSlotsRF = events:WaitForChild("GetSlots")

local InventoryController = {}

local Data = {}

function InventoryController.GetData()
	return Data
end

function InventoryController.GetHouses()
	
end


return InventoryController
