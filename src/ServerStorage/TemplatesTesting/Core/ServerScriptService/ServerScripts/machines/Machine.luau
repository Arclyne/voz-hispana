local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Shared.Signal)

local remotes = ReplicatedStorage.Events

local function fireAllExcept(remote, excluded, ...)
	for _, player in Players:GetPlayers() do
		if not table.find(excluded, player) then
			remote:FireClient(player, ...)
		end
	end
end

local Machine = {}
Machine.__index = Machine

function Machine.new(model: Model, maxPlayers: number)
	return setmetatable({
		model = model,
		stopped = Signal.new(),
		_players = {},
		_maxPlayers = maxPlayers
	}, Machine)
end

function Machine:bind<T...>(remote: RemoteEvent, callback: (Player, T...) -> ())
	remote.OnServerEvent:Connect(function(player, model, ...)
		if model == self.model and table.find(self._players, player) then
			callback(player, ...)
		end
	end)
end

function Machine:join(player: Player)
	if #self._players >= self._maxPlayers then
		return false
	end

	table.insert(self._players, player)
	return true
end

function Machine:isReady()
	return #self._players == self._maxPlayers
end

function Machine:start(...)
	if not self:isReady() then
		return false
	end
	
	if self.model:GetAttribute("Started") then
		return false
	end

	self.model:SetAttribute("Started", true)
	
	for _, player in self._players do
		remotes.Machines.Start:FireClient(player, self.model, true, ...)
	end

	fireAllExcept(remotes.Machines.Start, self._players, self.model, false, ...)
	return true
end

function Machine:stop()
	self.model:SetAttribute("Started", false)
	remotes.Machines.Stop:FireAllClients(self.model)
	
	for _, player in self._players do
		self.stopped:Fire(player)
	end

	table.clear(self._players)
end

function Machine:getPlayers()
	return self._players
end

function Machine:getPlayer()
	return self._players[1]
end

return Machine
