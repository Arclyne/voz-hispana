local module = {}

local Events = game:GetService('ReplicatedStorage'):WaitForChild('Events'):WaitForChild('Collections')
local IsClient = game:GetService('RunService'):IsClient()
local plr = IsClient and game:GetService('Players').LocalPlayer

local Start

local ConexionEntreServerYCliente = false

local Index = {
	'leaderstats'
}

export type Collections = {
	Crimson :{number} & number,
}

function module.Fire(object:RemoteFunction,...)
	if not object or not IsClient then return end
	if object:IsA('RemoteEvent') then
		object:FireServer(...)
		return true
	elseif object:IsA('RemoteFunction') then
		return object:InvokeServer(...)
	end
end
function module.GetPlayer(Player)
	Player = Player or plr
	Player = typeof(Player) == 'Instance' and Player:IsA('Player') and Player:IsDescendantOf(game) and Player
	return Player
end

function module.GetValue(Player,NameStat)
	Player = module.GetPlayer(Player)
	if not Player then return end
	for _,nameScopeData in Index do
		local data = Player:FindFirstChild(nameScopeData)
		data = data and data:FindFirstChild(NameStat)
		if data then
			return data
		end
	end
end

function module.requirements(Player:Player,List:Collections,Level : boolean & number)
	Player = module.GetPlayer(Player)

	if Level == nil then Level = true end
	if not List then print('list: ',List) return end
	
	local vacio = false
	
	for NameStats, Valor in List do
		
		local Bool : IntValue = module.GetValue(Player,NameStats)
		if not Bool then return end
		vacio = true
		
		if typeof(Level) == 'number' and typeof(Valor) == 'table' then
			local valor2 = tonumber(Valor[Level + 1])
			if (valor2 and tonumber(Bool.Value) < valor2) or not valor2 then
				return
			end
		elseif typeof(Level) == 'boolean' and typeof(Valor) == 'number' then
			if tonumber(Bool.Value) < Valor then
				return
			end
		else
			return
		end
		
	end
	
	return vacio
end

function module.SetAmount(_,value:ValueBase, Amount, earned2)
	if IsClient then
		module.Fire(Events:WaitForChild('SetAmount'), value, Amount)
	elseif value and Amount  then
		
		value.Value = math.clamp(Amount, 0, math.huge)
		
		if typeof(earned2) == 'number' and earned2 > 0 then
			local earned = tonumber(value:GetAttribute('earned') or 0)
			earned = tostring(earned + earned2)
			value:SetAttribute('earned', earned)
		end
	end
end

function module.charge(Player:Player, List:Collections, Level : boolean & number)
	if IsClient then
		return module.Fire(Events:WaitForChild('charge'), List, Level)
	else
		if Level == nil then Level = true end
		
		if module.requirements(Player, List, Level) then
			Player = module.GetPlayer(Player)
			
			for NameStats, Valor in List do
				
				local stat : IntValue = module.GetValue(Player,NameStats)
				
				if stat then
					if typeof(Level) == 'number' and typeof(Valor) == 'table' then
						local valor2 = tonumber(Valor[Level + 1]) or 0
						module.SetAmount(Player, stat, tonumber(stat.Value) - valor2)
					elseif typeof(Level) == 'boolean' and typeof(Valor) == 'number' then
						module.SetAmount(Player, stat, tonumber(stat.Value) - Valor)
					end
				end
				
			end
			
			return true
		end
	end
end

function module.Give(Player:Player, List:Collections, Level : boolean & number)
	if IsClient then
		return module.Fire(Events:WaitForChild('Give'), List, Level)
	else
		Player = module.GetPlayer(Player)
		if Level == nil then Level = true end
		
		if not List then print('list: ',List) return end
		
		for NameStats, Valor in List do
			
			local stat : IntValue = module.GetValue(Player,NameStats)
			
			if stat then
				if typeof(Level) == 'number' and typeof(Valor) == 'table' then
					local valor2 = tonumber(Valor[Level]) or 0
					module.SetAmount(Player, stat, tonumber(stat.Value) + valor2, 1)
				elseif typeof(Level) == 'boolean' and typeof(Valor) == 'number' then
					module.SetAmount(Player, stat, tonumber(stat.Value) + Valor, 1)
				end
			end
			
		end
	end
end

function module.Lerp(List:Collections, i)
	if typeof(List) == "table" then
		i = typeof(i) == "number" and i>0 and i or 1
		local newData = {}
		for index, value in List do
			if typeof(value) == "number" then
				newData[index] = math.round(value * i)
			end
		end
		return newData
	end
	return {}
end

if not IsClient and not Start and ConexionEntreServerYCliente then
	Start = not Start
	
	for _,remote in Events:GetChildren() do
		if not module[remote.Name] then continue end
		if remote:IsA('RemoteEvent') then
			remote.OnServerEvent:Connect(module[remote.Name])
		elseif remote:IsA('RemoteFunction') then
			remote.OnServerInvoke = module[remote.Name]
		end
	end
	
end

return module
