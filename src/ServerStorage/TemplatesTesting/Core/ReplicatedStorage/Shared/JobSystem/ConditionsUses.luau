local module = {}

local IsClient = game:GetService('RunService'):IsClient()
local PlayerClient = IsClient and game:GetService("Players").LocalPlayer or nil

setmetatable(module,{__index = function() return function() return true end end})

function module:NoSignalClient_SetFinishLocation()
	return IsClient
end

return module
