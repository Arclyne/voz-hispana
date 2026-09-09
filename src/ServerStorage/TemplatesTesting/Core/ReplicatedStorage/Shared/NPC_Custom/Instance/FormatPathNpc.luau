local module = {}

module.IndexActions = {
	walk = "WalkTo",
	run = "RunTo",
	hold = "HoldTo",
}

function module.FormatPath(data : {})
	if typeof(data)~="table" then return end
	local result = {}
	for _, Action in data do
		if typeof(Action)~="string" then return end
		local resultText = string.split(Action,":")
		local NameFun = module.GetNameAction(module.RemoveSpaces(resultText[1]))
		local Action = module.RemoveSpaces(resultText[2])
		if NameFun and Action then
			table.insert(result, {
				Action = NameFun,
				Process = Action,
			})
		else
			return
		end
	end
	return result
end

function module.GetInfo(character, data, paths)
	if typeof(data) == "string" then
		return module.GetInfo(character, module.FormatPath(data), paths)
	elseif data.Action == "HoldTo" then
		local timeHold = tonumber(data.Process)
		if not timeHold then
			timeHold = character.animator:GetInfoAnimation(data.Process)
			timeHold = timeHold and timeHold.Length>0 and timeHold.Length or 1
		end
		return timeHold
	elseif typeof(data.Process) == "CFrame" then
		return data.Process
	else
		local process:Instance = paths and paths:FindFirstChild(data.Process)
		if not process then return end
		return process:IsA("Attachment") and process.WorldCFrame or process:GetPivot()
	end
end

function module.GetNameAction(NameAction : string)
	if typeof(NameAction)~="string" then return end
	return module.IndexActions[NameAction]
end

function module.RemoveSpaces(texto)
	local result = typeof(texto)=="string" and texto:gsub("^%s*(.-)%s*$", "%1")
	return not not (result and #result>0) and result
end

return module
