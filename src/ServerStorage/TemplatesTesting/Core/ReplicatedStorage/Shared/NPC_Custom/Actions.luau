local module = {}

function GetPosition(points, tiempoTranscurrido)
	local acumulado = 0
	for i = 1, #points - 1 do
		local duracion = points[i].duracion
		acumulado += duracion
		if tiempoTranscurrido <= acumulado then
			local inicioIntervalo = acumulado - duracion
			local progreso = (tiempoTranscurrido - inicioIntervalo) / duracion
			local posicionActual = points[i].Position
			local posicionSiguiente = points[i + 1].Position
			local posicionInterpolada = posicionActual:Lerp(posicionSiguiente, math.min(progreso, 1))
			return posicionInterpolada, i
		end
	end
	return (points[#points] and points[#points].Position), (points[#points] and #points)
end

function FloorDetect(Character)
	if not Character.param then
		local a = RaycastParams.new()
		a.FilterType = Enum.RaycastFilterType.Exclude
		a.FilterDescendantsInstances = {Character.model}
		Character.param = a
	end
	local r = workspace:Raycast(Character.model:GetPivot().Position, Vector3.new(0,-100,0), Character.param)
	return r and r.Position.Y
end

function signal(path, state)
	if not path or not path.action then return end
	if state=="Change" or not path.stateSave[state] then
		task.defer(path.action,state)
		path.stateSave[state] = state
	end
end

function GetPorcentaje(ElapsedTime, Object)
	if Object==0 then return 1 end
	return math.min(ElapsedTime / Object, 1)
end

function module:walk(Character)
	if not Character.InAction then return end
	local path = Character.InAction
	if path.Canceled then
		return signal(path,"Cancel")
	end
	local ElapsedTime = self:GetElapsedTime(path.StartTime)
	local posi : Vector3, tramo = GetPosition(path.Path, ElapsedTime)
	if posi and tramo then
		signal(path,"Begin")
		local Next = path.Path[tramo + 1]
		local LookAt = Next and (Next.Position-posi).Unit or (posi-path.Path[tramo - 1].Position).Unit
		LookAt = Vector3.new(LookAt.X, 0, LookAt.Z)
		local floor = FloorDetect(Character)
		if floor then posi = Vector3.new(posi.X, floor, posi.Z) end
		LookAt = CFrame.new(posi, posi + LookAt)
		Character:PivotTo(LookAt)
		if tramo == #path.Path then
			if path.Rotation > 0 then
				path.StartRot = path.StartRot or LookAt
				local t = GetPorcentaje(ElapsedTime - path.duracion, path.Rotation)
				if t >= 1 then
					signal(path,"Complete")
					Character:PivotTo(path.EndCFrame)
				else
					signal(path,"Change")
					Character:PivotTo(path.StartRot:Lerp(path.EndCFrame, t))
					return true
				end
			else
				signal(path,"Complete")
				Character:PivotTo(path.EndCFrame)
			end
		else
			signal(path,"Change")
			return true
		end
	end
end
function module:run(...)
	return module.walk(self,...)
end
function module:action(Character)
	if not Character.InAction then return end
	local path = Character.InAction
	if path.Canceled then return signal(path,"Cancel") end
	signal(path,"Begin")
	local ElapsedTime = GetPorcentaje(self:GetElapsedTime(path.StartTime), path.duracion)
	if ElapsedTime >= 1 then
		signal(path,"Complete")
	else
		signal(path,"Change")
		return true
	end
end

return module