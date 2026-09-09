local module = {}

function module.CalculateTime(position1:Vector3, position2:Vector3, velocity)
	local distance = (position1 - position2).Magnitude
	return distance / velocity
end

function module.factorial(n)
	local r = 1
	for i = math.floor(n), 1, -1 do
		r = r*i
	end
	return r
end

function module.TableSum(tablee, name)
	local sum = 0
	for _,v in tablee do
		sum += name and tonumber(v[name]) or tonumber(v) or 0
	end
	return sum
end

function module.GetTimeRotation(posi , look, Cf : CFrame)
	if look and posi and Cf then
		local _,Y1,_ = CFrame.lookAt(posi.Position, look.Position):ToOrientation()
		local _,Y2,_ = Cf:ToOrientation()
		Y1 %= math.rad(360)
		Y2 %= math.rad(360)
		return math.abs(Y1 - Y2) / math.pi / 4
	end
	return 0
end

return module
