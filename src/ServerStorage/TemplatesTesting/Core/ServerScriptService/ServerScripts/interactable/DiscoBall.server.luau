local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage.Events

remotes.Interactable.DiscoBall.OnServerEvent:Connect(function(player, model)
	model:SetAttribute("Active", not model:GetAttribute("Active"))
end)
