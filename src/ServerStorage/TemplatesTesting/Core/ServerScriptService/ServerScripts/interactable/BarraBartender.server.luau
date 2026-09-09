local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage.Events
local Shared = ReplicatedStorage:WaitForChild("Shared")

local BarraModule = require(Shared:WaitForChild("BartenderSystem"))
local Commands = require(Shared:WaitForChild("Commands"))

function OnServerEvent(Player : Player, model : Model, Action : string, NamePedido)
	if not model or not Action then return end
	
	if Action == "pedir" then
		if typeof(NamePedido)~="string" then return end
		local Object = BarraModule:Get(model)
		if not Object then return end
		Object:Pedir(Player, NamePedido)
	elseif Action == "cancelar" then--close
		BarraModule:actionBarras("close",Player)
	elseif Action == "OpenGui" then
		Commands:Fire(Player, 9, model)
	end
	
end

remotes.Interactable:WaitForChild("BarraBartender").OnServerEvent:Connect(OnServerEvent)
