local module = {}

module.PathS = game:GetService('PathfindingService')
module.MaxIntentos = 3

function module.CreatePath(posiA, posiB)
	local intentos = 0
	local s = tick()
	repeat
		local path = module.CreateObstacles(intentos / module.MaxIntentos)
		path:ComputeAsync(posiA,posiB)
		if path.Status == Enum.PathStatus.Success then
			return path:GetWaypoints()
		end
		intentos += 1
	until intentos > module.MaxIntentos
end

function module.Reduce(num, rest)
	local result = num - num * rest
	result = result > 0 and result or nil
	return result
end

function module.CreateObstacles(num)
	num = num or 0
	return module.PathS:CreatePath({
			AgentRadius = module.Reduce(3, num),
			AgentCanJump = false,
			AgentCanClimb = false,
			Costs = {
				Door = 0,
				NonRoad = math.huge,
			}
		})
end

return module.CreatePath
