local module = {}

local jobSystem = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("JobSystem"))

function module:Premium(Player:Player)
	self.ActivePlayer[Player.UserId] = self.ActivePlayer[Player.UserId] or {}
	if self.ActivePlayer[Player.UserId].Premium then return end
	if self.Stores.StoresList then
		for _,store in self.Stores.StoresList do
			if store.Owner == Player then
				store:RemoveWithGamepass()
			end
		end
	end
	self.ActivePlayer[Player.UserId].Premium = true
end

return module
