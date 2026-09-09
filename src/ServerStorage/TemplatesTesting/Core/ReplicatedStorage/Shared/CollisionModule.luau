local collisionUtils = {}

local function get2DAABB(part)
	local cf = part.CFrame
	local size = part.Size

	local corners = {}
	for x = -0.5, 0.5, 1 do
		for z = -0.5, 0.5, 1 do
			local offset = Vector3.new(x * size.X, 0, z * size.Z)
			local worldPos = (cf * CFrame.new(offset)).Position
			table.insert(corners, Vector2.new(worldPos.X, worldPos.Z))
		end
	end

	local min = corners[1]
	local max = corners[1]

	for _, v in ipairs(corners) do
		min = Vector2.new(math.min(min.X, v.X), math.min(min.Y, v.Y))
		max = Vector2.new(math.max(max.X, v.X), math.max(max.Y, v.Y))
	end

	return min, max
end

function collisionUtils.IsColliding2D(partA, partB)
	local aMin, aMax = get2DAABB(partA)
	local bMin, bMax = get2DAABB(partB)

	return (
		aMin.X <= bMax.X and aMax.X >= bMin.X and
		aMin.Y <= bMax.Y and aMax.Y >= bMin.Y
	)
end

function collisionUtils.DistanceColliding(partA, partB)
	local aMin, aMax = get2DAABB(partA)
	local bMin, bMax = get2DAABB(partB)
	
	local distanceCollidingX
	local distanceCollidingY
	
	if partA.Position.X >= partB.Position.X then		
		distanceCollidingX = bMax.X - aMin.X
	else
		distanceCollidingX = aMax.X - bMin.X
	end
	
	if partA.Position.Y >= partB.Position.Y then
		distanceCollidingY = aMax.Y - bMin.Y
	else
		distanceCollidingY = bMax.Y - aMin.Y
	end
		
	return {distanceCollidingX, distanceCollidingY}
	
	
	
end


return collisionUtils