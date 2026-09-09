local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage.Events

local list = {}

remotes.Interactable.Paint.OnServerEvent:Connect(function(player: Player, model : Model, use)
	if typeof(model)=="Instance" and model:IsA("Model") and model:HasTag("Paint") then
		if (use and model:GetAttribute("InInUse")) or (not use and model:GetAttribute("InInUse") ~= player.UserId) or (use and list[player]) then return end
		model:SetAttribute("InInUse", use and player.UserId or nil)
		list[player] = use and model or nil
	end
end)

game:GetService("Players").PlayerRemoving:Connect(function(Player)
	if list[Player] then
		list[Player]:SetAttribute("InInUse", nil)
		list[Player] = nil
	end
end)