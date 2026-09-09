--[[
ESTE SCRIPT SOLO SE USA DESDE UN SERVIDOR PARA EVITAR EXPLOITS!
Los cooldowns se guardan en la carpeta "cooldowns" del player gracias
al sistema de datastore de Lym que es el que la crea y guarda
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CooldownShared = require(ReplicatedStorage.Shared.Cooldown:WaitForChild("CooldownShared"))

local CooldownManager = {}

local function getFolder(player: Player): Folder
	local folder = player:FindFirstChild("Cooldowns")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Cooldowns"
		folder.Parent = player
	end
	return folder
end

local function getValue(player: Player, key: string): IntValue
	local folder = getFolder(player)
	local v = folder:FindFirstChild(key)
	if not v then
		v = Instance.new("IntValue")
		v.Name = key
		v.Value = 0
		v.Parent = folder
	end
	return v
end

-- Set directo (por si lo necesitas)
function CooldownManager.SetExpire(player: Player, key: string, expireTime: number)
	local v = getValue(player, key)
	v.Value = math.floor(expireTime)
end

-- Empieza/reinicia cooldown: expire = now + duration
function CooldownManager.Start(player: Player, key: string, durationSeconds: number)
	local now = CooldownShared.Now()
	CooldownManager.SetExpire(player, key, now + durationSeconds)
end

-- Extiende: si está activo suma duration; si no, lo inicia
function CooldownManager.Extend(player: Player, key: string, durationSeconds: number)
	local v = getValue(player, key)
	local now = CooldownShared.Now()
	local currentExpire = v.Value

	if currentExpire > now then
		v.Value = currentExpire + math.floor(durationSeconds)
	else
		v.Value = math.floor(now + durationSeconds)
	end
end

function CooldownManager.Clear(player: Player, key: string)
	local v = getValue(player, key)
	v.Value = 0
end

function CooldownManager.GetRemaining(player: Player, key: string): number
	local folder = player:FindFirstChild("Cooldowns")
	local v = folder and folder:FindFirstChild(key)
	if not v then return 0 end
	return CooldownShared.GetRemainingSeconds(v.Value)
end

function CooldownManager.IsOnCooldown(player: Player, key: string): (boolean, number)
	local remaining = CooldownManager.GetRemaining(player, key)
	return remaining > 0, remaining
end

return CooldownManager

