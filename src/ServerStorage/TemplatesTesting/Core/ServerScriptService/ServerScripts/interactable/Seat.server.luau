local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage.Events

remotes.Interactable.Sit.OnServerEvent:Connect(function(player: Player, seat: Seat)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	
	local distance = player:DistanceFromCharacter(seat.Position)
	if distance > 15 then
		return
	end
	
	if seat.Occupant then
		return
	end

	if humanoid.Sit and humanoid.SeatPart then
		humanoid.SeatPart:Sit(nil)
		task.wait(0.1)
	end

	seat:Sit(humanoid)
end)
