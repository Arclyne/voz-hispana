local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryManager = require(script.Parent.Parent.inventory.InventoryManager)

local remotes = ReplicatedStorage.Events

remotes.Interactable.MusicPlayer.OnServerEvent:Connect(function(player, model, id)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local emitter = model.Emitter.Sound
	emitter.SoundId = id
	emitter:Play()
	print("aaa", id)
end)
