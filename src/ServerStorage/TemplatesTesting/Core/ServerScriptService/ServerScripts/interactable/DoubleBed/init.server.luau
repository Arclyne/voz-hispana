local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local DoubleBed = require(script.DoubleBed)
local bindToTag = require(ReplicatedStorage.Shared.bindToTag)

local remotes = ReplicatedStorage.Events

bindToTag("DoubleBed", DoubleBed.new)

remotes.Interactable.DoubleBed.OnServerEvent:Connect(function(player, model, request, side)
	local bed = DoubleBed.fromModel(model)
	if not bed then
		return
	end

	if (request == "sleep") then
		bed:sleep(player, side)
	elseif (request == "wake") then
		bed:wake(side)
	elseif (request == "make") then
		bed:make()
	end
end)
