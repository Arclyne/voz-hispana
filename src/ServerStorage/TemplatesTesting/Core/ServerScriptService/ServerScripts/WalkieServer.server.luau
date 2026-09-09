local RemoteEvent = game.ReplicatedStorage.Events.Tools.Walkie
local Players = game:GetService("Players")
local PlayerInit = require(game.ReplicatedStorage:WaitForChild("PlayerInit"))

local channels = {} 
local playerData = {}

local function cleanWires(player)
	if playerData[player] and playerData[player].wires then
		for _, wire in ipairs(playerData[player].wires) do
			wire:Destroy()
		end
		playerData[player].wires = {}
	end
end

local function setupAudioDevices(player)
	local input = Instance.new("AudioDeviceInput")
	input.Name = "AudioDeviceInput"
	input.Player = player
	input.Parent = player

	local fader = Instance.new("AudioFader")
	fader.Parent = player
	
	local wire
	
	player.CharacterAdded:Connect(function(character)
		
		if wire then wire:Destroy() end
		
		wire = Instance.new("Wire")
		wire.SourceInstance = input
		wire.TargetInstance = fader
		wire.Parent = fader
		
		local emitter = Instance.new("AudioEmitter")
		emitter:SetDistanceAttenuation({[10] = 1, [100] = 0})
		emitter.Name = "VoiceEmitter"
		emitter.Parent = character

		local wireEmiter = Instance.new("Wire")
		wireEmiter.SourceInstance = fader
		wireEmiter.TargetInstance = emitter
		wireEmiter.Parent = emitter
		
	end)
end

local function connectTransmitterToReceivers(transmitter, receivers)
	local transmitterTool = transmitter.Character and transmitter.Character:FindFirstChildOfClass("Tool")
	if not transmitterTool then return end

	local transmitterEmitter = transmitterTool:FindFirstChild("Transmitter") or Instance.new("AudioEmitter")
	transmitterEmitter.Name = "Transmitter"
	transmitterEmitter.Parent = transmitterTool

	for receiverPlayer, _ in pairs(receivers) do
		if receiverPlayer ~= transmitter then
			local receiverTool = receiverPlayer.Character and receiverPlayer.Character:FindFirstChildOfClass("Tool")
			if receiverTool then
				local receiver = receiverTool:FindFirstChild("Receiver") or Instance.new("AudioListener")
				receiver.Name = "Receiver"
				receiver.Parent = receiverTool

				local wire = Instance.new("Wire")
				wire.SourceInstance = transmitterEmitter
				wire.TargetInstance = receiver
				wire.Parent = transmitterTool

				if not playerData[transmitter].wires then
					playerData[transmitter].wires = {}
				end
				table.insert(playerData[transmitter].wires, wire)
			end
		end
	end
end

local function joinChannel(player, channel, tool)
	cleanWires(player)

	if not channels[channel] then
		channels[channel] = {transmitter = player, receivers = {}}
	end

	playerData[player] = {wires = {}, currentChannel = channel}

	local receiver = tool:FindFirstChild("Receiver") or Instance.new("AudioListener")
	receiver.Name = "Receiver"
	receiver.Parent = tool

	if channels[channel].transmitter == player then
		connectTransmitterToReceivers(player, channels[channel].receivers)
	else
		channels[channel].receivers[player] = true
		connectTransmitterToReceivers(channels[channel].transmitter, {[player] = true})
	end
end

local function leaveChannel(player)
	if playerData[player] and playerData[player].currentChannel then
		local channel = playerData[player].currentChannel
		if channels[channel] then
			if channels[channel].transmitter == player then
				local nextTransmitter = next(channels[channel].receivers)
				if nextTransmitter then
					channels[channel].transmitter = nextTransmitter
					channels[channel].receivers[nextTransmitter] = nil
					connectTransmitterToReceivers(nextTransmitter, channels[channel].receivers)
				else
					channels[channel] = nil
				end
			else
				channels[channel].receivers[player] = nil
			end
		end
		cleanWires(player)
	end
end

local function OnPlayerAdded(player)
	setupAudioDevices(player)
	playerData[player] = {wires = {}}

	player.CharacterAdded:Connect(function(character)
		if playerData[player].currentChannel then
			local tool = character:FindFirstChildOfClass("Tool")
			if tool then
				joinChannel(player, playerData[player].currentChannel, tool)
			end
		end
	end)
end

PlayerInit.Connect(OnPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	leaveChannel(player)
	playerData[player] = nil
end)

RemoteEvent.OnServerEvent:Connect(function(player, channel, tool)
	if #channel == 3 then
		leaveChannel(player)
		joinChannel(player, channel, tool)
	end
end)