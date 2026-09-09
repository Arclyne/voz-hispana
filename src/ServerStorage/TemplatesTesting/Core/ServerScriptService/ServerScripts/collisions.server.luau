local players = game:GetService('Players')
local physicsService = game:GetService('PhysicsService')

local PlayerInit = require(game.ReplicatedStorage:WaitForChild("PlayerInit"))

local collisionGroupPlayers = 'Players'
local collisionGroupUncollideablePlayers = 'Uncollideable-Players'
local collisionGroupCollideablePlayersOnly = 'Collideable-Players'

physicsService:RegisterCollisionGroup(collisionGroupPlayers)
physicsService:RegisterCollisionGroup(collisionGroupUncollideablePlayers)
physicsService:RegisterCollisionGroup(collisionGroupCollideablePlayersOnly)

physicsService:CollisionGroupSetCollidable(collisionGroupPlayers, collisionGroupUncollideablePlayers, false)
physicsService:CollisionGroupSetCollidable(collisionGroupUncollideablePlayers, collisionGroupUncollideablePlayers, false)
physicsService:CollisionGroupSetCollidable(collisionGroupCollideablePlayersOnly, collisionGroupPlayers, true)
physicsService:CollisionGroupSetCollidable(collisionGroupCollideablePlayersOnly, 'Default', false)

local events: {[Player]: RBXScriptConnection} = {}

local function OnPlayerAdded(player)
	events[player] = player.CharacterAdded:Connect(function(character)

		for _, part: BasePart in ipairs(character:GetDescendants()) do
			if not part:IsA('BasePart') then continue end

			part.CollisionGroup = collisionGroupPlayers
		end
	end)
end

PlayerInit.Connect(OnPlayerAdded)

players.PlayerRemoving:Connect(function(player)
	events[player]:Disconnect()
	events[player] = nil
end)