local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage.Events
local serverClient = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Paint"):WaitForChild("ServerClient"))

local list = {}

remotes.Interactable.CuadrosPaint.OnServerEvent:Connect(function(player: Player, model : Model, Key)
	if typeof(model)=="Instance" and model:IsA("Model") and model:HasTag("CuadrosPaint") then
		
	end
end)