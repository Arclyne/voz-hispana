local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local Bed = require(script.Bed)
local bindToTag = require(ReplicatedStorage.Shared.bindToTag)

local remotes = ReplicatedStorage.Events

bindToTag("Bed", Bed.new)

remotes.Interactable.Bed.OnServerEvent:Connect(function(player, request: string, model: Model)
	local bed = Bed.fromModel(model)
	if (request == "sleep") then
		bed:sleep(player)
	elseif (request == "wake") then
		bed:wake()
	elseif (request == "make") then
		bed:make()
	end
end)
