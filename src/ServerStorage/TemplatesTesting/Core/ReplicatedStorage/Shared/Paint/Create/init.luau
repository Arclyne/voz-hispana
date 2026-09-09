local PaintModule = require(script.Parent.Paint)

local module = {}

module.SelectFormat = function(Format,Value)
	for _, F in pairs(Format:GetChildren()) do
		if  F:IsA("TextButton") then 
			F.MouseButton1Click:Connect(function()
				if Value.Value and Format:FindFirstChild(Value.Value)then 
					Format[Value.Value].UIStroke.Enabled = false 
				end
				Value.Value = F.Name
				Format[Value.Value].UIStroke.Enabled = true
			end) 
		end
	end
end

module.Init = function(Player,PaintGui,CreateFrame)
	
	local Format = CreateFrame:WaitForChild("Format")
	local Dates = CreateFrame:WaitForChild("Dates")
	local Button = CreateFrame:WaitForChild("Crear")
	
	module.SelectFormat(Format,script.Format)
	
	Button.MouseButton1Click:Connect(function()
		local FormatText = script.Format.Value
		local NombreText = Dates.Nombre.Text
		if FormatText == '' then print('Escoge un Formato!') return end
		if NombreText == '' then print('Escoge un nombre!') return end
		
		PaintModule.Init(Player,PaintGui.Parent,FormatText,NombreText)
		FormatText = ''
		NombreText = ''
	end)
	
end

return module
