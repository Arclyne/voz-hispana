local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local rouletteUtil = require(ReplicatedStorage.Shared.machines.rouletteUtil)
local roulettePrizes = require(ReplicatedStorage.Shared.machines.roulettePrizes)
local Machine = require(script.Parent.Machine)
local Trove = require(ReplicatedStorage.Shared.Trove)

-- para los BAILES
local AnimationSystem = ServerScriptService.ServerScripts:WaitForChild("AnimationSystem")
local AnimationManager = require(AnimationSystem:WaitForChild("AnimationManager"))
local AnimationData = require(game.ReplicatedStorage:WaitForChild("DancesInfo"))


-- (Opcional) notificación si existe en tu juego
local showNotificationEvent = ReplicatedStorage:WaitForChild("Events")
	:WaitForChild("Player")
	:FindFirstChild("ShowNotification")

local function notify(player: Player, title: string, msg: string)
	if showNotificationEvent and showNotificationEvent:IsA("RemoteEvent") then
		-- ajusta args si tu UI espera otro formato
		showNotificationEvent:FireClient(player, title, msg, 6, 86164423709638, "rotate", 133962474176377)
	end
end

local function modulo(a, b)
	if a < b then
		return a
	else
		return a % b + 1
	end
end

local Roulette = {}
Roulette.__index = Roulette

function Roulette.new(model: Model)
	return setmetatable({
		model = model,
		_machine = Machine.new(model, 1),
		_trove = Trove.new(),
		_parts = #model:FindFirstChild("Parts"):GetChildren(),
	}, Roulette)
end

function Roulette:join(player: Player)
	return self._machine:join(player)
end

function Roulette:start()
	local turns = self:_getRandomTurns()
	local result = modulo(turns, self._parts)
	local player = self._machine:getPlayer()

	if not self._machine:start(turns) then
		return
	end

	self._trove:Add(task.spawn(function()
		self:_wait(turns)
		self:_handle(player, result)
		self:stop()
	end))
end

function Roulette:stop()
	self._trove:Clean()
	self._machine:stop()
end

function Roulette:onStop(callback: (Player) -> ())
	self._machine.stopped:Connect(callback)
end

-- soporta leaderstats como StringValue/IntValue/NumberValue
local function addStat(player: Player, statName: string, delta: number): boolean
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return false end

	local stat = leaderstats:FindFirstChild(statName)
	if not stat or not stat:IsA("ValueBase") then return false end

	local current = tonumber(stat.Value) or 0
	local newValue = current + delta

	if stat:IsA("StringValue") then
		stat.Value = tostring(newValue)
	elseif stat:IsA("IntValue") then
		stat.Value = math.floor(newValue)
	elseif stat:IsA("NumberValue") then
		stat.Value = newValue
	else
		return false
	end

	return true
end

local function getUnownedDanceNames(player: Player): {string}
	local list = {}
	for animName, info in pairs(AnimationData) do
		if info.category == "dances" then
			if not AnimationManager.HasAnimation(player, animName) then
				table.insert(list, animName)
			end
		end
	end
	return list
end

local function giveRandomDance(player: Player): (boolean, string?)
	local available = getUnownedDanceNames(player)
	if #available <= 0 then
		return false, nil
	end

	local picked = available[math.random(1, #available)]
	AnimationManager.AddAnimation(player, picked)
	return true, picked
end

local function applyPrizeReward(player: Player, prize)
	if not prize then return end
	local reward = prize.reward
	if typeof(reward) ~= "table" then return end

	-- Recompensas numéricas directas en leaderstats
	for statName, amount in pairs(reward) do
		if typeof(amount) == "number" then
			addStat(player, statName, amount)
		end
	end

	-- Specials
	if reward._Special == "Dance" then
		local ok, danceName = giveRandomDance(player)
		if ok and danceName then
			notify(player, "Ruleta", "🕺 Has ganado un baile: " .. danceName)
		else
			-- fallback si ya tiene TODOS los bailes: para que no sea premio “vacío”
			addStat(player, "Spins", 2)
			notify(player, "Ruleta", "✅ Ya tienes todos los bailes. Te damos +2 Spins.")
		end
	end

	-- Furniture: aún no implementado
	if reward._Special == "Furniture" then
		-- TODO: cuando exista el sistema de construcción, aquí se entrega
	end
end

function Roulette:_handle(player: Player, result: number)
	if not player or not player.Parent then return end

	local prize = roulettePrizes[result]
	if not prize then
		warn("[roulette] prize missing for result:", result)
		return
	end

	applyPrizeReward(player, prize)
	warn(("[roulette] %s won %s (slot %d)"):format(player.Name, tostring(prize.type), result))
end

function Roulette:_getRandomTurns()
	return self._parts * math.random(2, 4) + math.random(0, self._parts)
end

function Roulette:_wait(turns: number)
	for turn = 0, turns - 1 do
		task.wait(rouletteUtil.getWaitTime(turn, turns))
	end
	task.wait(1)
end

return Roulette
