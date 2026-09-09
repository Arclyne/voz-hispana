local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = require(script.Parent.Parent.stats.Stats)
local bindToTag = require(ReplicatedStorage.Shared.bindToTag)
local SoundManager = require(ReplicatedStorage.Shared:WaitForChild("SoundManager"))

local SEAT_DURATION = 8

local remotes = ReplicatedStorage.Events

local function getAliveHumanoid(player: Player): Humanoid?
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end

	return humanoid
end

local function setHingeAngle(model: Model, angle: number, playSound: boolean?)
	local hinge = model:FindFirstChildOfClass("HingeConstraint")
	if not hinge then return end

	hinge.TargetAngle = angle
	
	if playSound then
		task.delay(0.4, function()
			SoundManager:Play(nil, 126891613553309, {
				Volume = 0.5,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				RollOffMinDistance = 6,
				RollOffMaxDistance = 30,
				EmitterSize = 6,
			}, model.PrimaryPart)
		end)
	end
end

bindToTag("Toilet", function(model: Model)
	local seat = model:FindFirstChildOfClass("Seat")
	seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if not seat.Occupant then
			setHingeAngle(model, -95.5, true)
		end
	end)
	
	setHingeAngle(model, -95.5, false) -- false: sin sonido
end)

remotes.Interactable.Toilet.OnServerEvent:Connect(function(player, model: Model)
	local humanoid = getAliveHumanoid(player)
	if not humanoid then
		return
	end

	local seat = model:FindFirstChildOfClass("Seat")
	if seat.Occupant then
		return
	end
	
	local stats = Stats.fromPlayer(player)
	if not stats then
		return
	end

	setHingeAngle(model, 0)
	-- wait for the hinge
	task.wait(0.5)
	
	-- a previous that requested the toiled before can be the occupant
	-- while we wait for the hinge
	if seat.Occupant then
		return
	end

	local playerCFrame = player.Character:GetPivot()
	seat:Sit(humanoid)

	local conn
	local thread = task.delay(SEAT_DURATION, function()
		conn:Disconnect()
		seat:Sit(nil)
		stats:set("bladder", 100)
		SoundManager:Play(nil, 76914264254203, { Volume = 1 }, model)
		task.wait(0.1)
		player.Character:PivotTo(playerCFrame)
	end)
	
	conn = seat:GetPropertyChangedSignal("Occupant"):Once(function()
		if coroutine.status(thread) == "suspended" then
			task.cancel(thread)
		end
	end)
end)
