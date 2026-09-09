local module = {}
module.__index = module

local Disconnect = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("Disconnects"))
local Debris = game:GetService("Debris")
local IsClient = game:GetService("RunService"):IsClient()
local LocalPlayer = IsClient and game:GetService("Players").LocalPlayer

function module.new()
	local self = setmetatable({
		actives = {},
		Players = not IsClient and {},
	}, module)
	if IsClient then self:add() end
	return self
end

function module:Reset(list)
	if not list then return end
	if list.spawn then
		task.cancel(list.spawn)
		list.spawn = nil
	end
	Disconnect.Group(self.actives, {list.PlayerId.."Seated", list.PlayerId.."Died"})
end

function module:SetCharacter(Player : Player)
	Player = IsClient and LocalPlayer or not IsClient and Player
	if not Player then return end
	local list = IsClient and self.Players or not IsClient and self.Players[Player]
	local Character = Player.Character
	if not list or list.Character == Character then return end
	self:Reset(list)
	local Humanoid : Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid")
	self.actives[list.PlayerId.."Seated"] = Humanoid.Seated:Connect(function(IsActive, Seat)
		list.Seat = IsActive and Seat or nil
	end)
	self.actives[list.PlayerId.."Died"] = Humanoid.Died:Connect(function(IsActive, Seat)
		list.Seat = nil
		list.Died = true
		self:Reset(list)
	end)
	list.Died = nil
	list.Seat = nil
	list.Character = Character
end

function module:add(Player : Player)
	if (not IsClient and Player and not self.Players[Player]) or (IsClient and not self.Players) then
		local list = {
			PlayerId = not IsClient and Player.UserId or LocalPlayer.UserId,
		}
		if IsClient then
			self.Players = list
			Player = LocalPlayer
		else
			self.Players[Player] = list
		end
		self.actives[list.PlayerId.."CharacterAdded"] = Player.CharacterAdded:Connect(function() self:SetCharacter(Player) end)
		self:SetCharacter(Player)
	end
end
function module:remove(Player : Player)
	if IsClient then return end
	local list = self.Players[Player]
	if not list then return end
	Disconnect.Group(self.actives, {list.PlayerId.."CharacterAdded", list.PlayerId.."Seated", list.PlayerId.."Died"})
end

function module:move(Player : Player, Moving : CFrame)
	Moving = (IsClient and Player) or (not IsClient and Moving)
	local TypeOff = typeof(Moving)
	assert(TypeOff == "Vector3" or TypeOff == "CFrame", "Only CFrame o Vector3")
	local list = (not IsClient and self.Players[Player]) or (IsClient and self.Players)
	if not list or list.Died then return end
	
	local SeatWeld = list.Seat and list.Seat:FindFirstChild("SeatWeld")
	local Humanoid : Humanoid = list.Character:FindFirstChild("Humanoid")
	
	if SeatWeld then
		SeatWeld:Destroy()
		Debris:AddItem(SeatWeld,0)
	end
	list.Seat = nil
	
	local Position = TypeOff=="CFrame" and Moving or ((list.Character:GetPivot() - list.Character:GetPivot().Position) + Moving)
	
	if IsClient or not SeatWeld then
		list.Character:PivotTo(Position)
	else
		list.spawn = task.delay(.13, function()
			list.Character:PivotTo(Position)
			list.spawn = nil
		end)
	end
end

return module.new()