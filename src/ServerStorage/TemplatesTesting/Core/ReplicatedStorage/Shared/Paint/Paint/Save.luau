local Replicated = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Shared = Replicated:WaitForChild("Shared")
local PaintFolder = Shared:WaitForChild("Paint")

local Asset = Replicated:WaitForChild("Assets")
local Formats = Asset:WaitForChild("Paint")

local Prompt = require(Shared:WaitForChild("PrompBuy"))
local ServerClient = require(PaintFolder:WaitForChild("ServerClient"))

local module = {}

module.Connections = {}

local CELL_SIZE = 5

function color3ToHex(c: Color3)
	return string.format("%02X%02X%02X",
		math.floor(c.R * 255),
		math.floor(c.G * 255),
		math.floor(c.B * 255)
	)
end

function getWorldPosFromModel(model: Instance)
	if model and model:IsA("Model") then
		if model.PrimaryPart then
			return model.PrimaryPart.Position
		end
		local m = model:FindFirstChild("model")
		if m and m:IsA("BasePart") then
			return m.Position
		end
	end
	return nil
end

function SerializePainting(FormatText, model, Player, cuadroName)
	local function color3ToHex(c: Color3)
		return string.format("%02X%02X%02X",
			math.floor(c.R * 255),
			math.floor(c.G * 255),
			math.floor(c.B * 255)
		)
	end

	local frame = model:WaitForChild("Canva"):WaitForChild("Canva"):WaitForChild("SurfaceGui"):WaitForChild("Canva")
	
	local pixelsByColor = {}
	for _, pixel in ipairs(frame:GetChildren()) do
		if pixel:IsA("Frame") then
			local c = pixel.BackgroundColor3
			local colorHex = color3ToHex(c)
			pixelsByColor[colorHex] = pixelsByColor[colorHex] or {}

			local col = pixel.Position.X.Offset / CELL_SIZE
			local row = pixel.Position.Y.Offset / CELL_SIZE
			table.insert(pixelsByColor[colorHex], col .. "," .. row)
		end
	end

	local colorParts = {}
	for colorHex, coords in pairs(pixelsByColor) do
		table.insert(colorParts, colorHex .. ":" .. table.concat(coords, ";"))
	end
	
	return string.format("%s|%d|%d|%s|%s|",FormatText,Player.UserId,Player.UserId,cuadroName,"()") .. table.concat(colorParts, "|")
end

local function hexToColor3(hex)
	hex = tostring(hex):gsub("#","")
	if #hex ~= 6 then return Color3.new(1,1,1) end
	local r = tonumber(hex:sub(1,2), 16) / 255
	local g = tonumber(hex:sub(3,4), 16) / 255
	local b = tonumber(hex:sub(5,6), 16) / 255
	return Color3.new(r, g, b)
end

local function DeserializePainting(serialized, targetFrame, CELL_SIZE)
	if not serialized or type(serialized) ~= "string" then return false end
	if not targetFrame or not targetFrame:IsA("Frame") then return false end
	if serialized == targetFrame:GetAttribute("serialized") then return end
	CELL_SIZE = CELL_SIZE or 5
	local list = {}

	targetFrame:ClearAllChildren()
	
	for _,colorPart in ServerClient.Format.GetPintura(serialized) do
		local colorHex, coordsStr = colorPart:match("^([^:]+):(.*)$")
		if colorHex and coordsStr and coordsStr ~= "" then
			local color = hexToColor3(colorHex)
			for coord in coordsStr:gmatch("([^;]+)") do
				local colStr, rowStr = coord:match("^%s*([^,]+)%s*,%s*([^,]+)%s*$")
				local col = tonumber(colStr)
				local row = tonumber(rowStr)
				if col and row then
					local pixel = Instance.new("Frame")
					pixel.Name = "Pixel_" .. tostring(col) .. "_" .. tostring(row)
					pixel.Size = UDim2.new(0, CELL_SIZE, 0, CELL_SIZE)
					pixel.Position = UDim2.new(0, col * CELL_SIZE, 0, row * CELL_SIZE)
					pixel.BackgroundColor3 = color
					pixel.BorderSizePixel = 0
					pixel.Parent = targetFrame
					list[tostring(Vector2.new(col*CELL_SIZE, row*CELL_SIZE))] = pixel
				end
			end
		end
	end

	targetFrame:SetAttribute("serialized", serialized)
	return list
end

module.SerializePainting = SerializePainting
module.Deserialize = DeserializePainting

module.Init = function(FormatText, model, PaintGui, Player, NameBox)
	local ToolsUi = PaintGui:WaitForChild("Tools")
	local Dates = ToolsUi:WaitForChild("Dates")
	local SaveButton = Dates:WaitForChild("Save")
	local CancelButton = Dates:WaitForChild("Cancel")

	module.Connections.Save = SaveButton.MouseButton1Click:Connect(function()
		Prompt:Prompt({Pregunta = 'Estas seguro de guardar el cuadro?'}, function()
			if #ServerClient.DataPlayer >= ServerClient.maxSlots then
				warn(string.format("No puedes guardar más de %d cuadros", ServerClient.maxSlots))
				return
			end
			local cuadroName = NameBox ~= "" and NameBox or ("Cuadro" .. tostring(#ServerClient.DataPlayer+1))
			model:SetAttribute("CuadroName", cuadroName)
			local encoded = module.SerializePainting(FormatText, model, Player, cuadroName)
			ServerClient:Save(encoded)
			for _,v in module.Connections do v:Disconnect() end
			module.Connections = {}
			module.PaintModule.Reload(PaintGui,model)
		end)
	end)

	module.Connections.Cancel = CancelButton.MouseButton1Click:Connect(function()
		Prompt:Prompt({Pregunta = 'Estas seguro de borrar el cuadro?'}, function()
			for _,v in module.Connections do v:Disconnect() end
			module.Connections = {}
			module.PaintModule.Reload(PaintGui,model)
		end)
	end)

	module.Connections.Exit = Dates:WaitForChild("Exit").MouseButton1Click:Connect(function()
		Prompt:Prompt({Pregunta = 'Estas seguro de que quieres salir?'}, function()
			for _,v in module.Connections do v:Disconnect() end
			module.Connections = {}
			local cuadroName = NameBox ~= "" and NameBox or ("Cuadro" .. tostring(#ServerClient.DataPlayer+1))
			local encoded = module.SerializePainting(FormatText, model, Player, cuadroName)
			ServerClient:UpdateCuadros(model,encoded,true)
			module.PaintModule.Reload(PaintGui,model,true)
		end)
	end)
end

return module
