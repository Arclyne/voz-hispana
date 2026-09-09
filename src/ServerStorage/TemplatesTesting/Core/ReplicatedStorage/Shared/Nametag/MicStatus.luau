--!strict

local MicStatus = {}

local statusMap: {[string]: string} = {}

local changedEvent = Instance.new("BindableEvent")

local VALID_STATUS = {
	["6OpenMic"] = true,
	["6CloseMic"] = true,
	["6NoMic"] = true,
}

local function getKey(playerOrUserId: any): string?
	if typeof(playerOrUserId) == "Instance" and playerOrUserId:IsA("Player") then
		return tostring(playerOrUserId.UserId)
	end

	if typeof(playerOrUserId) == "number" or typeof(playerOrUserId) == "string" then
		return tostring(playerOrUserId)
	end

	return nil
end

function MicStatus.Set(playerOrUserId: any, status: string?)
	local key = getKey(playerOrUserId)
	if not key then
		return
	end

	if status ~= nil and not VALID_STATUS[status] then
		warn("[MicStatus] Estado inválido:", status)
		return
	end

	if statusMap[key] == status then
		return
	end

	statusMap[key] = status

	changedEvent:Fire(tonumber(key), status)
end

function MicStatus.Get(playerOrUserId: any): string?
	local key = getKey(playerOrUserId)
	if not key then
		return nil
	end

	return statusMap[key]
end

function MicStatus.GetAll(): {[string]: string}
	local result = {}

	for userId, status in statusMap do
		result[userId] = status
	end

	return result
end

function MicStatus.Resolve(canChat: boolean, active: boolean?): string?
	if not canChat then
		return "6NoMic"
	end

	if active == nil then
		return nil
	end

	return active and "6OpenMic" or "6CloseMic"
end

MicStatus.Changed = changedEvent.Event

return MicStatus