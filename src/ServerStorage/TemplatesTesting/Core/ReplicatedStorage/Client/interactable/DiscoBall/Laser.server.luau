local RunService = game:GetService("RunService")

local LASER_LENGTH = 256

local actor = script.Parent
local model = actor.Parent
local lights = model:WaitForChild("Lights")
local root = model.PrimaryPart

local params = RaycastParams.new()
params.FilterDescendantsInstances = {model}
params.FilterType = Enum.RaycastFilterType.Exclude

local lightData = {}

for _, light in lights:GetChildren() do
	if not light:IsA("BasePart") then
		continue
	end

	local target = light:FindFirstChild("Attachment1")
	if not target then
		continue
	end

	table.insert(lightData, {
		light = light,
		target = target,
	})
end

local positions = table.create(#lightData)
local conn

local function update()
	local rootPosition = root.Position

	for index, data in lightData do
		local origin = data.light.Position
		local offset = origin - rootPosition

		if offset.Magnitude > 0 then
			local direction = offset.Unit * LASER_LENGTH
			local result = workspace:Raycast(origin, direction, params)

			positions[index] = result and result.Position or origin + direction
		else
			positions[index] = origin
		end
	end

	task.synchronize()

	for index, data in lightData do
		data.target.WorldPosition = positions[index]
	end
end

local function enable()
	if conn then
		return
	end

	conn = RunService.Heartbeat:ConnectParallel(update)
end

local function disable()
	if conn then
		conn:Disconnect()
		conn = nil
	end
end

model:GetAttributeChangedSignal("Active"):Connect(function()
	if model:GetAttribute("Active") then
		enable()
	else
		disable()
	end
end)

if model:GetAttribute("Active") then
	enable()
else
	disable()
end