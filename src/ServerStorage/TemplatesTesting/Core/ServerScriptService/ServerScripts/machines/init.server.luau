local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local shared = ReplicatedStorage:WaitForChild("Shared")
local bindToTag = require(shared:WaitForChild("bindToTag"))
local PlayerInit = require(ReplicatedStorage:WaitForChild("PlayerInit"))
local MachineFactory = require(script.MachineFactory)

local machineByModel = {}
local machineByPlayer = {}

local remotes = ReplicatedStorage:WaitForChild("Events")

local CooldownManager = require(ReplicatedStorage.Shared.Cooldown:WaitForChild("CooldownManager"))

local rouletteRemotes = remotes:WaitForChild("Roulette")
local requestSpinRF = rouletteRemotes:WaitForChild("RequestSpin")

local FREE_SPIN_KEY = "RouletteFreeSpin"
local FREE_SPIN_COOLDOWN = 24 * 60 * 60 -- 1 día

remotes.Machines.Request.OnServerInvoke = function(player, model)
	-- Roulette ya no usa el sistema viejo de coins
	if model and model.Name == "Roulette" then
		return false
	end

	if machineByPlayer[player] then
		return false
	end

	local character = player.Character
	if not character then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return false
	end

	local price = model:GetAttribute("Price") or 0
	local coins = tonumber(player.leaderstats.Coins.Value)
	if coins < price then
		return false
	end

	local machine = machineByModel[model]
	if not machine or not machine:join(player) then
		return false
	end

	machineByPlayer[player] = machine

	-- TODO: integrate with the actual currency service
	player.leaderstats.Coins.Value = tostring(coins - price)

	return true
end

remotes.Machines.Start.OnServerEvent:Connect(function(player)
	local machine = machineByPlayer[player]
	if machine then
		machine:start(player)
	end
end)

PlayerInit.Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Once(function()
			local machine = machineByPlayer[player]
			if machine then
				machine:stop()
			end
		end)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local machine = machineByPlayer[player]
	if machine then
		machine:stop()
	end
end)

bindToTag("Machine", function(model: Model)
	local machine = MachineFactory.create(model.Name, model)
	machine:onStop(function(player)
		machineByPlayer[player] = nil
	end)

	machineByModel[model] = machine
end)

-- ✅ helper: saber si una máquina ya está ocupada por alguien
local function isMachineBusy(machineObj): boolean
	for _, m in pairs(machineByPlayer) do
		if m == machineObj then
			return true
		end
	end
	return false
end

requestSpinRF.OnServerInvoke = function(player: Player, model: Model, mode: string)
	-- Validaciones base
	if typeof(model) ~= "Instance" or not model:IsA("Model") then
		return false, "BAD_MODEL"
	end

	if model.Name ~= "Roulette" then
		return false, "NOT_ROULETTE"
	end

	-- No permitir si ya está en otra máquina
	if machineByPlayer[player] then
		return false, "IN_MACHINE"
	end

	local character = player.Character
	if not character then return false, "NO_CHAR" end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return false, "DEAD"
	end

	local machine = machineByModel[model]
	if not machine then
		return false, "NO_MACHINE"
	end

	-- ✅ BUSY CHECK antes de tocar spins/cooldown (para que no pierdan nada)
	if isMachineBusy(machine) then
		return false, "BUSY"
	end

	-- ✅ Validación de recursos (sin cobrar aún)
	local spinsVal
	if mode == "Paid" then
		spinsVal = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Spins")
		if not spinsVal then return false, "NO_SPINS_STAT" end

		local spins = tonumber(spinsVal.Value) or 0
		if spins < 1 then
			return false, "NO_SPINS"
		end

	elseif mode == "Free" then
		local onCd, remaining = CooldownManager.IsOnCooldown(player, FREE_SPIN_KEY)
		if onCd then
			return false, "FREE_COOLDOWN", remaining
		end

	else
		return false, "BAD_MODE"
	end

	-- ✅ JOIN (aquí puede fallar por race). Si falla, NO cobramos nada.
	if not machine:join(player) then
		return false, "BUSY"
	end

	-- Marcamos inmediatamente al jugador dentro para bloquear doble click
	machineByPlayer[player] = machine

	-- ✅ Ahora sí cobramos / aplicamos cooldown (ya sabemos que entró)
	if mode == "Paid" then
		local spins = tonumber(spinsVal.Value) or 0
		if spins < 1 then
			-- ultra edge case: si cambió justo aquí, liberamos
			machine:stop()
			machineByPlayer[player] = nil
			return false, "NO_SPINS"
		end
		spinsVal.Value = tostring(spins - 1)

	elseif mode == "Free" then
		CooldownManager.Start(player, FREE_SPIN_KEY, FREE_SPIN_COOLDOWN)
	end

	-- Start
	machine:start(player)

	return true
end
