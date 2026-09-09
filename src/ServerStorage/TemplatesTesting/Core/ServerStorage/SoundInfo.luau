local HttpService = game:GetService("HttpService")

local PROXY_URL = "http://107.174.178.86"
local SECRET_KEY = "VozHispana14759125123471357234"

function getAudioData(assetId)
	-- usamos la ruta de toolbox v2 que enruta a apis.roblox.com
	local url = PROXY_URL .. "/apis/toolbox-service/v2/assets/" .. tostring(assetId)

	local headers = {
		["My-Secret"] = SECRET_KEY
	}

	local success, res = pcall(function()
		return HttpService:GetAsync(url, true, headers)
	end)

	if not success then
		warn("[proxy] error en toolbox v2: " .. tostring(res))
		return nil
	end

	return HttpService:JSONDecode(res)
end

function GetInfoSound(SongId)
	if typeof(SongId) == "number" then
		local data = getAudioData(SongId)
		if data and data.asset then
			data.asset.Creator = string.match(data.creator.creator,"group")
				and data.creator.latestGroupUpdaterUserId or data.creator.userId
			return data.asset
		end
	end
end

return GetInfoSound