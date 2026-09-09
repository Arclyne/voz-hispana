local ServerClient = require(script.Parent.ServerClient)

local Format = require(script.Parent.FormatPinturaData)

local Template = script:WaitForChild("Template")

local module = {}

local loadFrame = require(script:WaitForChild('LoadFrame'))
local Prompt = require(game:GetService('ReplicatedStorage'):FindFirstChild('Shared'):FindFirstChild('PrompBuy'))
local Player = game:GetService("Players").LocalPlayer

function CreateTemplate(LoadGui,NameBox,Key,CuadrosInhabilitados)
	local NewTemplate = Template:Clone()
	NewTemplate.Parent = LoadGui
	NewTemplate.Name = Key
	NewTemplate.Nombre.Text = NameBox
	
	local Buttons = NewTemplate:FindFirstChild("Buttons")
	Buttons.Load.Visible = not CuadrosInhabilitados[Key]
	
	if not CuadrosInhabilitados[Key] then
		Buttons.Load.MouseButton1Down:Connect(function()
			local ActualModel:Model = loadFrame.PromptModule:GetModelActual()
			if ActualModel then
				loadFrame:Enabled(Key)
			else
				LoadGui.Parent.Parent.Visible = false
			end
		end)
	end
	
	local IsEliminable = ServerClient:IsNotPaintInHouse(Key)
	Buttons.Equip.Visible = IsEliminable
	
	if IsEliminable then
		Buttons.Equip.MouseButton1Click:Connect(function()
			Prompt:Prompt({Pregunta = "Estas seguro que quieres eliminar este cuadro"},function() ServerClient:Remove(Key) end)
		end)
	end
	
end

function CountKeys(LoadGui)
	for _, v in LoadGui:GetChildren() do
		if v:IsA('Frame') then
			v:Destroy()
		end
	end
	
	if LoadGui.Visible then
		local ActualModel = loadFrame.PromptModule:GetModelActual()
		local StorePlayer = loadFrame.Store:GetStore(Player)
		
		if ActualModel and StorePlayer then
			local GlobalDataCache = ServerClient.GlobalDataCache
			local PlayerDataCache = ServerClient.DataPlayer
			
			local IsDataPlayer = #PlayerDataCache > 0
			LoadGui.Parent:FindFirstChild("NoCuadros").Visible = not IsDataPlayer
			
			local CuadrosInhabilitados = ServerClient:CuadrosInhabilitados(StorePlayer, ActualModel.Name) or {}
			
			if IsDataPlayer then
				for _, Keys in pairs(PlayerDataCache) do
					if GlobalDataCache[Keys] then
						local NameBox = Format.format(GlobalDataCache[Keys])[4]
						if LoadGui:FindFirstChild(Keys) then continue end
						CreateTemplate(LoadGui,NameBox,Keys, CuadrosInhabilitados)
					end
				end
			end
			
		else
			
			LoadGui.Parent.Parent.Visible = false
			
		end
		
	else
		
		LoadGui.Parent:FindFirstChild("NoCuadros").Visible = false
		
	end
	
end

module.Init = function(Player,LoadGui:Frame)
	ServerClient.DataAdded:Connect(function()
		CountKeys(LoadGui)
	end)

	ServerClient.CacheAdded:Connect(function()
		CountKeys(LoadGui)
	end)
	
	loadFrame = loadFrame.new(LoadGui.Parent.Parent.Parent:WaitForChild('Load'))
	LoadGui:GetPropertyChangedSignal("Visible"):Connect(function() CountKeys(LoadGui) end)
end

return module
