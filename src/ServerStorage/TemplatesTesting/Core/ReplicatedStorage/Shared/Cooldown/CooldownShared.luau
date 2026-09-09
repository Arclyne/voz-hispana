--[[
ESTE SCRIPT SE PUEDE USAR TANTO DESDE CLIENTE COMO 
SERVER PARA SABER EL TIEMPO RESTANTE DE UN COOLDOWN 
--]]
local CooldownShared = {}

function CooldownShared.Now(): number
	-- Tiempo global sincronizado al servidor
	return workspace:GetServerTimeNow()
end

function CooldownShared.GetRemainingSeconds(expireTime: number, now: number?): number
	now = now or CooldownShared.Now()
	local remaining = expireTime - now
	if remaining < 0 then remaining = 0 end
	return math.floor(remaining + 0.0001)
end

function CooldownShared.SplitTime(totalSeconds: number)
	totalSeconds = math.max(0, math.floor(totalSeconds))

	local days = math.floor(totalSeconds / 86400)
	totalSeconds %= 86400

	local hours = math.floor(totalSeconds / 3600)
	totalSeconds %= 3600

	local minutes = math.floor(totalSeconds / 60)
	local seconds = totalSeconds % 60

	return days, hours, minutes, seconds
end

-- Formato estable (si quieres SIEMPRE d/h/m/s)
function CooldownShared.FormatDHMS(totalSeconds: number)
	local d, h, m, s = CooldownShared.SplitTime(totalSeconds)
	return string.format("%dd %02dh %02dm %02ds", d, h, m, s)
end

-- Formato “compacto” (opcional)
function CooldownShared.FormatRemaining(totalSeconds: number)
	local d, h, m, s = CooldownShared.SplitTime(totalSeconds)

	if d > 0 then
		return string.format("%dd %02dh %02dm %02ds", d, h, m, s)
	elseif h > 0 then
		return string.format("%02dh %02dm %02ds", h, m, s)
	elseif m > 0 then
		return string.format("%02dm %02ds", m, s)
	else
		return string.format("%02ds", s)
	end
end

return CooldownShared
