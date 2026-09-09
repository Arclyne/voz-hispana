local module = {}
local IsClient = game:GetService('RunService'):IsClient()
module.Player = IsClient and game:GetService('Players').LocalPlayer
local event = script.Parent:WaitForChild('Events')
local UserInputState = Enum.UserInputState
local Rewards = not IsClient and require(script:WaitForChild('Rewards'))
local quitarEspacios = require(script.Parent:WaitForChild('QuitarEspacios'))
function module.GetGuide(Player)
	Player = IsClient and module.Player or Player
	if typeof(Player)=='Instance' and Player:IsA('Player') then
		local guide = Player:FindFirstChild('GuideService') or (IsClient and Player:WaitForChild("GuideService"))
		if not guide and not IsClient then
			guide = Instance.new('BoolValue')
			guide.Name = "GuideService"
			guide.Parent = Player
		end
		return guide
	end
end
function module.GetState(Player,key)
	key = quitarEspacios(IsClient and Player or key)
	Player = IsClient and module.Player or Player
	local Guide:BoolValue = module.GetGuide(Player)
	local state = Guide and Guide:GetAttribute(key or "notFound")
	if state then
		return (state=="pending" and UserInputState.Begin) or (state=="cancel" and UserInputState.Cancel) or (state=="ended" and UserInputState.End) or UserInputState.None
	end
	return UserInputState.None
end

function module.CloseGuide(...)
	if IsClient then
		event:WaitForChild('EndAction'):FireServer(...)
	else
		local parametro = {...}
		local Guide:BoolValue = module.GetGuide(parametro[1])
		local Key:string = quitarEspacios(parametro[2])
		local IsDone = parametro[3] or "pending"
		if Guide and typeof(Key)=='string' then
			if module.GetState(parametro[1], Key) ~= UserInputState.End then
				Guide:SetAttribute(Key,IsDone)
				if IsDone == "ended" then
					Rewards[Key](parametro[1])
				end
			end
		end
	end
end
if not IsClient then
	event:WaitForChild('EndAction').OnServerEvent:Connect(module.CloseGuide)
end
return module
