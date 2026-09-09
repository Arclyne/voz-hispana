--!strict
--[[
	Arranca el evento en el servidor reservado.

	Corre en todos los places (vive en Core), pero solo hace algo si el jugador que
	llega trae TeleportData de evento — o sea, solo en la instancia reservada.
]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local worldSystemStorage = ServerStorage:WaitForChild("WorldSystem")
local EventService = require(worldSystemStorage:WaitForChild("EventService"))

local booting = false

local function onPlayerAdded(player: Player)
	if booting or EventService.isHosting() then
		return
	end
	booting = true
	local ok = EventService.tryHost(player)
	booting = false

	if ok then
		warn("[EventBootstrap] Servidor de evento iniciado")
	end
end

for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
