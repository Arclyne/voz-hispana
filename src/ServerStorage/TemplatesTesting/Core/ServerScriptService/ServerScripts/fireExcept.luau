local Players = game:GetService("Players")

local function fireExcept(remote: RemoteEvent, exception: Player, ...)
	for _, player in Players:GetPlayers() do
		if player ~= exception then
			remote:FireClient(player, ...)
		end
	end
end

return fireExcept
