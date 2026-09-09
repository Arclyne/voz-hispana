local function lerp(a, b, t)
	return a + (b - a) * math.clamp(t, 0, 1)
end

return lerp
