local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

type CallbackData = {
	callback: () -> (),
	interval: number,
	lastRun: number,
}

local Timer = {}
Timer.__index = Timer

function Timer.new()
	local self = setmetatable({}, Timer)
	self.callbacks = {} :: { CallbackData }
	self.running = false
	return self
end

function Timer:registerCallback(callback: () -> (), interval: number)
	local id = HttpService:GenerateGUID(false)
	self.callbacks[id] = {
		callback = callback,
		interval = interval,
		lastRun = 0
	}
	
	return function()
		self.callbacks[id] = nil
	end
end

function Timer:start()
	if self._connection then
		return
	end

	self._connection = RunService.Heartbeat:Connect(function()
		local currentTime = os.clock()
		for _, data in self.callbacks do
			if currentTime - data.lastRun >= data.interval then
				data.callback()
				data.lastRun = currentTime
			end
		end
	end)
end

function Timer:stop()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
end

return Timer
