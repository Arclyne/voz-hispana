--!strict
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local worldSystem = ServerStorage:WaitForChild("WorldSystem")
local PlayerDataService = require(worldSystem:WaitForChild("PlayerDataService"))
local PlayerInit = require(ReplicatedStorage:WaitForChild("PlayerInit"))

local wired: { [Player]: boolean } = {}

local function onPlayerAdded(player: Player)
	local store = PlayerDataService.load(player)
	if wired[player] then
		return
	end
	wired[player] = true

	store:onReady():Connect(function()
		print(("[PlayerData] Perfil listo para %d"):format(player.UserId))
	end)

	store:onError():Connect(function(source, err)
		warn(("[PlayerData] %s (%s): %s"):format(player.Name, tostring(source), tostring(err)))
	end)
end

local function onPlayerRemoving(player: Player)
	wired[player] = nil
	PlayerDataService.close(player)
end

PlayerInit.Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

game:BindToClose(function()
	PlayerDataService.closeAll()
end)