local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage.Events

local NightClub

remotes.Interactable.FocusNpcDialog.OnServerEvent:Connect(function(player: Player, model : Model, IsFocus)
	if typeof(model) ~= "Instance" or not model:IsA("Model") or not model:HasTag("NpcDialog") then return end
	
	if model:GetAttribute("DialogId") == "NightClubDialog" and NightClub ~= false then
		
		if not NightClub then
			local Module = ReplicatedStorage:WaitForChild("Shared"):FindFirstChild("NightClub")
			NightClub = Module and require(Module).new()
			if not NightClub then return end
		end
		
		if not NightClub.IsActive or not NightClub.Managger or NightClub.Managger.model ~= model then return end
		
		if IsFocus then
			NightClub:FocusManagger(player)
		else
			NightClub:UnfocusManagger(player)
		end
		
	end
	
end)
