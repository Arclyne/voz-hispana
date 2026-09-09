local RS = game:GetService("ReplicatedStorage")
local Evento = RS:FindFirstChild("IsInEvent")

local PPS = game:GetService("ProximityPromptService")

if not Evento then
	Evento = Instance.new("Configuration")
	Evento.Name = "IsInEvent"
	Evento.Parent = RS
end

function change()
	for _,value in Evento:GetAttributes() do
		if value then
			
			PPS.Enabled = false
			
			return
		end
	end
	
	PPS.Enabled = true
end

change()
Evento.AttributeChanged:Connect(change)