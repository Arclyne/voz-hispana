local module = {}

module.normalScale = {.5, 1.5}

function module.GetScale(Scale, ScaleData)
	ScaleData = typeof(ScaleData)=="table" and ScaleData or module.normalScale
	Scale = tonumber(Scale) or (ScaleData[1] + ScaleData[2]) / 2
	return math.clamp(Scale, ScaleData[1], ScaleData[2])
end

function module.IsInArea(NormalPosition: CFrame, Position2: CFrame)
	local dir1 = Vector3.new(Position2.LookVector.X, 0, Position2.LookVector.Z).Unit
	local dir2 = Vector3.new(NormalPosition.LookVector.X, 0, NormalPosition.LookVector.Z).Unit
	local dot = dir1:Dot(dir2)
	local mag = (NormalPosition.Position - Position2.Position).Magnitude
	if mag < 1 and dot > 0.98 then
		return true
	end
end
function module.GetFusion(Position1: CFrame, Position2: CFrame, ListFusion)
	for _, Data in ListFusion do
		if module.IsInArea(Position1:ToWorldSpace(Data.Value), Position2) then
			return Data
		end
	end
end

function module.getFace(position: Vector3, wall: BasePart)
	local cf = wall.CFrame
	local dir = (position - cf.Position)
	local WitheList = wall:GetAttribute("Whitelist") and string.split(wall:GetAttribute("Whitelist"), ",")
	local faces = {
		{normal = cf.LookVector, axis = "Z", Face = "Front"},
		{normal = -cf.LookVector, axis = "Z", Face = "Back"},
		{normal = cf.RightVector, axis = "X", Face = "Right"},
		{normal = -cf.RightVector, axis = "X", Face = "Left"},
		{normal = cf.UpVector, axis = "Y", Face = "Top"},
		{normal = -cf.UpVector, axis = "Y", Face = "Bottom"},
	}
	local best
	local bestDot = -math.huge
	for _,face in ipairs(faces) do
		local dot = dir:Dot(face.normal)
		if dot > bestDot and
			WitheList and table.find(WitheList,face.Face) then
			bestDot = dot
			best = face
		end
	end
	return best
end

function module.solveCollision(ghostPart, Position: CFrame, other: BasePart, bestFace)
	local cf = other.CFrame
	if not bestFace then
		bestFace = module.getFace(Position.Position, other)
		if not bestFace then return Position end
		bestFace = bestFace.normal
	end
	local ghostCF = Position
	local otherHalf =
		math.abs(bestFace:Dot(cf.RightVector)) * other.Size.X * 0.5 +
		math.abs(bestFace:Dot(cf.LookVector)) * other.Size.Z * 0.5
	local ghostHalf =
		math.abs(bestFace:Dot(ghostCF.RightVector)) * ghostPart.Size.X * 0.5 +
		math.abs(bestFace:Dot(ghostCF.LookVector)) * ghostPart.Size.Z * 0.5
	local minDistance = otherHalf + ghostHalf
	local dist = (Position.Position - cf.Position):Dot(bestFace)
	if dist < minDistance then
		local correction = bestFace * (minDistance - dist)
		Position += correction
	end
	return Position
end

function module.resolveCollisions(ghostPart, Position, overlapParams)
	if not overlapParams then return Position end
	local parts = workspace:GetPartBoundsInBox(
		Position,
		ghostPart.Size * .95,
		overlapParams
	)
	for _,Base:BasePart in parts do
		Position = module.solveCollision(ghostPart,Position, Base)
	end
	return Position
end

function module.getVertices(cf, size, baseDir: Vector3)
	local axes = {"X","Y","Z"}
	local main =
		(math.abs(baseDir.X) == 1 and "X") or
		(math.abs(baseDir.Y) == 1 and "Y") or
		"Z"
	table.remove(axes, table.find(axes, main))
	local pos = { X = 1, Y = 2, Z = 3 }
	local results = {}
	local signs = {
		{ 1, -1 },
		{ -1, 1 },
		{ 1, 1 },
		{ -1, -1 }
	}
	for i = 1, 4 do
		local v = {0,0,0}
		v[pos[axes[1]]] = signs[i][1]
		v[pos[axes[2]]] = signs[i][2]
		results[i] = cf:PointToWorldSpace((baseDir + Vector3.new(v[1], v[2], v[3])) * (size/2))
	end
	return results
end

function module.isInside(ghostPart, position, rayParams, dir)
	local vertices = module.getVertices(position, ghostPart.Size, dir)
	dir = position:VectorToWorldSpace(dir)
	for i,v in ipairs(vertices) do
		local result = workspace:Raycast(
			v,
			-dir * ghostPart.Size * 1.1,
			rayParams
		)
		if not result then
			return false
		end
	end
	return true
end
function module.getBuildAreaCenter(Position : Vector3, buildArea)
	local total
	local point
	local MaxMagnitude = math.huge
	for _,part in buildArea do
		if part:IsA("BasePart") then
			local Posi = part:GetClosestPointOnSurface(Position)
			local mag = (Position - Posi).Magnitude
			if mag < MaxMagnitude then
				MaxMagnitude = mag
				total = part
				point = Posi
			end
		end
	end
	return total.Position, point, total
end

function module.getWallCFrame(normal)
	local up = Vector3.yAxis
	local zero = Vector3.zero
	local lokat = CFrame.lookAt(zero, zero + normal, up)
	return lokat - lokat.Position
end

function module.GetDirectionByFormat(Format)
	return Vector3.new(
		0,
		Format=="Floors" and -1 or Format=="Ceiling" and 1 or 0,
		Format=="Walls" and 1 or 0
	)
end

function module.GetHalfExtent(cf: CFrame, size: Vector3, normal: Vector3)
	local right = math.abs(cf.RightVector:Dot(normal)) * size.X/2
	local up = math.abs(cf.UpVector:Dot(normal)) * size.Y/2
	local look = math.abs(cf.LookVector:Dot(normal)) * size.Z/2
	return right + up + look
end

function module.GetPosition2(ghostPart, Position:CFrame, rayParams, overlapParams, Format)
	local center,point,Base:BasePart = module.getBuildAreaCenter(Position.Position, rayParams.FilterDescendantsInstances)
	local Normal = module.getFace(point, Base)
	
	if Format == "Walls" then
		Position = module.getWallCFrame(Normal.normal)
	end
	
	local VectorToObjectSpace = Base.CFrame:VectorToObjectSpace(Normal.normal)
	
	local ObjectSpaceNormal = Format == "Walls" and Vector3.new(0,0,-1)
		or VectorToObjectSpace
	
	local angle = CFrame.Angles(Position:ToOrientation())
	
	local RelativeSize = module.GetSize(ghostPart.Size, Position, 2)
	
	local Aumentar = Format == "Walls" and Vector3.new(ghostPart.Size.Z/2,0,ghostPart.Size.Z/2)*VectorToObjectSpace or RelativeSize * Normal.normal
	Position = CFrame.new(point) * angle
	
	local low = Format == "Walls" and Position or module.resolveCollisions(ghostPart, Position, overlapParams)
	
	if not module.isInside(ghostPart, Position, rayParams, ObjectSpaceNormal) then
		low = center
		local high = Position.Position
		for i = 1,10 do
			local mid = (low + high) / 2
			if module.isInside(ghostPart, CFrame.new(mid) * angle, rayParams, ObjectSpaceNormal) then
				low = mid
			else
				high = mid
			end
		end
		
		if Format ~= "Walls" then
			low -= low * Normal.normal:Abs()
			return (CFrame.new(low + (center*Normal.normal:Abs())) * angle) + ((Base.Size/2) * Normal.normal) + Aumentar, true
		end
	end
	
	if Format ~= "Walls" then
		return (typeof(low)=="Vector3" and CFrame.new(low)*angle or low) + Aumentar
	else
		local IsEditable = typeof(low)=="Vector3"
		low = typeof(low)=="Vector3" and CFrame.new(low) or low
		local a = Base.CFrame:ToObjectSpace(low).Position 
		a -= a * VectorToObjectSpace:Abs()
		a = Base.CFrame:ToWorldSpace(CFrame.new(a + ((Base.Size/2) * VectorToObjectSpace) + Aumentar)).Position
		return CFrame.new(a) * angle, IsEditable
	end
end

function module.GetPosition(ghostPart, Position:CFrame, rayParams, overlapParams, Format)
	local center,point,Base:BasePart = module.getBuildAreaCenter(Position.Position, rayParams.FilterDescendantsInstances)
	local Normal = module.getFace(point, Base)
	local angle = Format == "Walls" and module.getWallCFrame(Normal.normal) or Position-Position.Position
	local ghostOffset = module.GetHalfExtent(angle, ghostPart.Size, Normal.normal)
	local wallOffset = module.GetHalfExtent(Base.CFrame, Base.Size, Normal.normal)
	local PointToCenter = (center - point):Dot(Normal.normal) * Normal.normal
	local offset = Normal.normal * (ghostOffset + wallOffset)
	local newPos = module.resolveCollisions(ghostPart, CFrame.new(point + PointToCenter + offset) * angle, overlapParams)
	local dir = Format == "Walls" and Vector3.new(0,0,-1) or Normal.normal
	if not module.isInside(ghostPart, newPos, rayParams, dir) then
		local low = center + offset
		local high = newPos.Position
		for i = 1,10 do
			local mid = (low + high) / 2
			if module.isInside(ghostPart, CFrame.new(mid) * angle, rayParams, dir) then
				low = mid
			else
				high = mid
			end
		end
		return CFrame.new(low) * angle, true
	end
	return newPos
end

return module