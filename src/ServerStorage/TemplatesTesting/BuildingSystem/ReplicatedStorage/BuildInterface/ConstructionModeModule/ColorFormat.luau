local module = {}
function module.HSVtoHex(h, s, v)
	local c = typeof(h)=="Color3" and h or Color3.fromHSV(h, s, v)
	local r = math.floor(c.R * 255)
	local g = math.floor(c.G * 255)
	local b = math.floor(c.B * 255)
	return string.format("#%02X%02X%02X", r, g, b)
end
function module.HexToColor3(hex)
	local clean = string.upper(string.gsub(hex, "[^A-F0-9]", ""))
	if #clean ~= 6 then return Color3.new(1, 1, 1) end
	local r = tonumber(clean:sub(1, 2), 16)
	local g = tonumber(clean:sub(3, 4), 16)
	local b = tonumber(clean:sub(5, 6), 16)
	local color = Color3.fromRGB(r, g, b)
	return color
end
function module.GetXYFromHSV(H, S)
	local radius = 0.5 * S
	local angle = math.rad(H * 360)
	local xScale = 0.5 - radius * math.cos(angle)
	local yScale = 0.5 - radius * math.sin(angle)
	return xScale, yScale
end
function module.GetColorFromXY_HSV(Position : Vector3)
	local dx = 0.5 - Position.X
	local dy = 0.5 - Position.Y
	local radius = math.sqrt(dx^2 + dy^2)
	local angle = math.atan2(dy, dx)
	if angle < 0 then angle = angle + 2 * math.pi end
	local H = (math.deg(angle) / 360) % 1
	local S = math.clamp(radius / 0.5, 0, 1)
	local V = math.max(.001,1 - Position.Z)
	return Color3.fromHSV(H, S, V)
end
function module.GetBarColor(Color)
	local H,S,_ = Color:ToHSV()
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0,Color3.new(0, 0, 0)),
		ColorSequenceKeypoint.new(1,Color3.fromHSV(H,S,1)),
	})
end
return module