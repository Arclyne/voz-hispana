local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage.Events

remotes.Interactable.SmokeMachine.OnServerEvent:Connect(function(player, model)
	model:SetAttribute("Enabled", not model:GetAttribute("Enabled"))
end)
