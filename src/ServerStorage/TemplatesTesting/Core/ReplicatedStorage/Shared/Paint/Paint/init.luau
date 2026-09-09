local Work = game:GetService("Workspace")
local Replicated = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Assets = Replicated:WaitForChild("Assets")
local Interactable = Replicated:WaitForChild('Client'):WaitForChild('interactable')

local PromptModule = require(Interactable:WaitForChild('Paint'))

local Palette = require(script.PaletteColor)
local Save = require(script.Save)

local FormatPinturaData = require(script.Parent.FormatPinturaData)

local Player = Players.LocalPlayer

local UIS = game:GetService('UserInputService')
local guiS = game:GetService('GuiService')

local Shared = Replicated:WaitForChild("Shared")
local PaintShared = Shared:WaitForChild("Paint")
local ServerClient = require(PaintShared:WaitForChild("ServerClient"))

local module = {
	conections = {},
	ServerClient = ServerClient,
}

PromptModule.PaintModule = module

local Tool = script.Tool
local BrushSizeLapiz = 1
local BrushSizeClean = 1

Save.PaintModule = module

module.Init = function(Player, PaintGui, FormatText, DatesText, lastPintura)
	local Format = FormatText
	local Nombre = DatesText

	local ToolsUi = PaintGui:WaitForChild('Tools') 
	local PaintUi = PaintGui:WaitForChild("Paint")

	local ColorPalette = ToolsUi:WaitForChild('ColorPalette')

	ToolsUi.Visible = true
	PaintUi.Visible = false

	local parts = string.split(FormatText, "x")
	local maxLimit = 5
	if parts[1] and parts[2] then
		local w = tonumber(parts[1])
		local h = tonumber(parts[2])
		maxLimit = math.min(w, h)
	end

	module.ManageTool(ToolsUi, maxLimit)
	module.ManageChart(Player, PaintGui, Format, Nombre, lastPintura)
end

module.ManageTool = function(ToolsUi, MaxLimit)
	local ButtonContainer = ToolsUi:WaitForChild('Tools')
	local ScaleFrame = ToolsUi:WaitForChild("Scale")

	local ScaleInput = nil
	local SaveButton = nil

	if ScaleFrame then
		ScaleInput = ScaleFrame:WaitForChild("Scale")
		SaveButton = ScaleFrame:WaitForChild("Save")
		ScaleFrame.Visible = false
	end

	local function SaveSize()
		if not ScaleInput then return end

		local num = tonumber(ScaleInput.Text)
		if num then
			if num > MaxLimit then num = MaxLimit
			elseif num < 1 then num = 1 end

			local finalSize = math.floor(num)

			if Tool.Value == "Lapiz" then
				BrushSizeLapiz = finalSize
				ScaleInput.Text = tostring(BrushSizeLapiz)
			elseif Tool.Value == "Clean" then
				BrushSizeClean = finalSize
				ScaleInput.Text = tostring(BrushSizeClean)
			else
				ScaleInput.Text = tostring(finalSize)
			end
		else
			if Tool.Value == "Lapiz" then
				ScaleInput.Text = tostring(BrushSizeLapiz)
			elseif Tool.Value == "Clean" then
				ScaleInput.Text = tostring(BrushSizeClean)
			end
		end
	end

	for _, T in ipairs(ButtonContainer:GetChildren()) do
		if T:IsA('ImageButton') then
			T.MouseButton1Click:Connect(function()
				if T.Name == "Scale" then
					if ScaleFrame then
						ScaleFrame.Visible = not ScaleFrame.Visible
					end
				else
					Tool.Value = T.Name

					if ScaleFrame then
						if T.Name == "Lapiz" then
							ScaleFrame.Visible = true
							if ScaleInput then ScaleInput.Text = tostring(BrushSizeLapiz) end
						elseif T.Name == "Clean" then
							ScaleFrame.Visible = true
							if ScaleInput then ScaleInput.Text = tostring(BrushSizeClean) end
						else
							ScaleFrame.Visible = false
						end
					end
				end
			end)
		end
	end

	if ScaleFrame and ScaleInput and ScaleInput:IsA("TextBox") then
		ScaleInput.PlaceholderText = "1 - " .. tostring(MaxLimit)

		if Tool.Value == "Lapiz" then
			ScaleInput.Text = tostring(BrushSizeLapiz)
		elseif Tool.Value == "Clean" then
			ScaleInput.Text = tostring(BrushSizeClean)
		else
			ScaleInput.Text = "1"
		end

		if SaveButton and SaveButton:IsA("GuiButton") then
			SaveButton.MouseButton1Click:Connect(SaveSize)
		end

		ScaleInput.FocusLost:Connect(function()
			SaveSize()
		end)
	end
end

function module.calcularPosition(Position : Vector2, size : Vector2)
	if Position and size then
		local X = math.round(Position.X / size.X) * size.X
		local Y = math.round(Position.Y / size.Y) * size.Y
		return Vector2.new(X,Y)
	end
end

local posis = {}
local model 

local isInit = false
local Connects

local CELL = 5

local function toColRow(vec: Vector2)
	return math.floor(vec.X / CELL), math.floor(vec.Y / CELL)
end

module.FloodFill = function(startPos, oldColor, newColor, frame, FormatText, modelRef, PlayerRef, NameCuadro)
	local frameWidth = frame.AbsoluteSize.X
	local frameHeight = frame.AbsoluteSize.Y

	local directions = {
		Vector2.new(5, 0),
		Vector2.new(-5, 0),
		Vector2.new(0, 5),
		Vector2.new(0, -5)
	}

	local visited = {}
	local queue = { startPos }

	local connection 

	connection = RunService.RenderStepped:Connect(function()
		local processed = 0
		local maxPerStep = 100

		while processed < maxPerStep and #queue > 0 do
			local current = table.remove(queue, 1)
			local key = tostring(current)

			if not visited[key] then
				visited[key] = true
				if current.X >= 0 and current.X < frameWidth and current.Y >= 0 and current.Y < frameHeight then
					local pixel = posis[key]
					local pixelColor = pixel and pixel.BackgroundColor3 or nil
					local match = (oldColor == nil and pixel == nil) or (pixelColor == oldColor)

					if match then
						if not pixel then
							local newPixel = Instance.new("Frame")
							newPixel.Name = key
							newPixel.BorderSizePixel = 0
							newPixel.Size = UDim2.new(0, 5, 0, 5)
							newPixel.Position = UDim2.new(0, current.X, 0, current.Y)
							newPixel.BackgroundColor3 = newColor
							newPixel.Parent = frame
							posis[key] = newPixel
						else
							pixel.BackgroundColor3 = newColor
						end

						for _, dir in directions do
							local newPos = current + dir
							if newPos.X >= 0 and newPos.X < frameWidth and newPos.Y >= 0 and newPos.Y < frameHeight then
								table.insert(queue, newPos)
							end
						end
					end
				end

				processed += 1
			end
		end
		if #queue == 0 or processed == 0 then
			local Serializacion = Save.SerializePainting(FormatText,modelRef,Player,NameCuadro)
			ServerClient:UpdateCuadros(modelRef,Serializacion,false)
			connection:Disconnect()
		end
	end)
end


local function GetAbsolutePosition(Canva: BasePart, Input: InputObject)
	if Canva and Input then
		local param = RaycastParams.new()
		param.FilterDescendantsInstances = {Canva}
		param.FilterType = Enum.RaycastFilterType.Include
		param.BruteForceAllSlow = true
		
		local camera = workspace.CurrentCamera
		local unitRay = camera:ScreenPointToRay(Input.Position.X, Input.Position.Y)
		local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, param)
		
		if result then
			local relativeCFrame = Canva.CFrame:ToObjectSpace(CFrame.new(result.Position))
			local localPosition = Vector2.new(relativeCFrame.X, relativeCFrame.Y)
			local Size = Vector2.new(Canva.Size.X, Canva.Size.Y)
			return ((localPosition-(Size/2)) / Size):Abs()
		end
	end
end

module.ActiveFormat = function(FormatText, modelRef, PaintGui, Player,NameCuadro, lastpintura)	
	local ToolsUi = PaintGui:WaitForChild('Tools')	
	local ColorPalette = ToolsUi:WaitForChild('ColorPalette')

	local Formats = Assets:WaitForChild("Paint")
	local FormatNew = Formats:WaitForChild(tostring(FormatText)):Clone()

	FormatNew.Parent = modelRef
	FormatNew.CFrame = modelRef.model.CFrame
	FormatNew.Name = 'Canva'

	Connects = Palette.new(ColorPalette.Palette,ColorPalette.Info)

	local frame:Frame = FormatNew:WaitForChild("Canva"):WaitForChild("SurfaceGui"):WaitForChild("Canva")

	local parts = string.split(FormatText, "x")
	local columns = tonumber(parts[1])
	local rows = tonumber(parts[2])

	FormatText = tostring(FormatText)

	if not columns or not rows then
		return
	end

	frame:ClearAllChildren()

	local buttonWidth = 1 / columns
	local buttonHeight = 1 / rows

	local buttonIndex = 1
	local color = Color3.fromRGB(0,0,0)
	local isFilling

	local down

	local function Changed(Position)
		if Position then
			local centroOriginal = Vector2.new(Position.X, Position.Y)
			local centroGrid = module.calcularPosition(centroOriginal, Vector2.new(5,5))

			local range = 0 
			if Tool.Value == 'Lapiz' then
				range = BrushSizeLapiz - 1 
			elseif Tool.Value == 'Clean' then
				range = BrushSizeClean - 1
			end

			local radiusLimitSq
			if range <= 1 then
				radiusLimitSq = range * range
			else
				local smoothRadius = range + 0.5
				radiusLimitSq = smoothRadius * smoothRadius
			end

			for x = -range, range do
				for y = -range, range do
					if (x * x) + (y * y) <= radiusLimitSq then

						local offsetX = x * 5
						local offsetY = y * 5

						local nuevaPos = Vector2.new(centroGrid.X + offsetX, centroGrid.Y + offsetY)
						local key = tostring(nuevaPos)

						if Tool.Value == 'Pencil' or Tool.Value == 'Lapiz' then
							if not posis[key] then
								local button = Instance.new("Frame")
								button.Name = tostring(buttonIndex)
								button.BorderSizePixel = 0
								button.Size = UDim2.new(0, 5, 0, 5)
								button.Position = UDim2.new(0, nuevaPos.X, 0, nuevaPos.Y)
								button.Parent = frame
								button.BackgroundColor3 = color
								posis[key] = button
							else
								posis[key].BackgroundColor3 = color
							end

						elseif Tool.Value == 'Clean' then
							if posis[key] then
								posis[key]:Destroy()
								posis[key] = nil
							end
						end
					end
				end
			end
		end
	end

	table.insert(module.conections, UIS.InputBegan:Connect(function(Input, processed)
		if processed or down then return end
		if table.find({Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch},Input.UserInputType)
			and Input.UserInputState==Enum.UserInputState.Begin then
			local posi = GetAbsolutePosition(FormatNew:FindFirstChild("Canva"), Input)
			posi = posi and (posi * frame.AbsoluteSize):Floor()
			
			if posi then

				down = Input.UserInputType==Enum.UserInputType.MouseButton1 or Input
				color = Connects:Select()

				if Tool.Value == 'Copy' then
					local calcular = module.calcularPosition(posi, Vector2.new(5,5))
					local key = tostring(calcular)
					if posis[key] then
						local pickedColor = posis[key].BackgroundColor3
						Connects:SelectColor(nil,pickedColor)
					end
				elseif Tool.Value == 'Bote' and not isFilling then
					isFilling = true
					local calcular = module.calcularPosition(posi, Vector2.new(5, 5))
					local key = tostring(calcular)
					local oldColor = posis[key] and posis[key].BackgroundColor3 or nil

					if oldColor ~= color then
						task.spawn(function()
							module.FloodFill(calcular, oldColor, color, frame, FormatText, modelRef, Player, NameCuadro)
							isFilling = false
						end)
					else
						isFilling = false
					end
				else
					Changed(posi)
				end
			end
		end
	end))
	table.insert(module.conections,
		UIS.InputEnded:Connect(function(Input)
			if (down==true and table.find({Enum.UserInputType.MouseButton1},Input.UserInputType)) or Input==down then
				down = false
				if Tool.Value ~= 'Bote' then
					local Serializacion = Save.SerializePainting(FormatText,modelRef,Player,NameCuadro)
					ServerClient:UpdateCuadros(modelRef,Serializacion,false)
				end
			end
		end)
	)
	table.insert(module.conections,
		UIS.InputChanged:Connect(function(Input)
			if Tool.Value == 'Bote' then return end
			if (down==true and table.find({Enum.UserInputType.MouseMovement},Input.UserInputType)) or Input==down then
				
				local posi = GetAbsolutePosition(FormatNew:FindFirstChild("Canva"), Input)
				posi = posi and (posi * frame.AbsoluteSize):Floor()
				if posi then
					Changed(posi)
				end

			end
		end)
	)

	if lastpintura then
		posis = module.LoadOtherFrames(modelRef, FormatPinturaData.InvertFormat(lastpintura)) or {}
	end
end

function CreateMarco(Canva,NameCuadro,FormatSize)
	if typeof(Canva)=="Instance" and Canva:IsA("BasePart") and typeof(FormatSize)=="string" and typeof(NameCuadro)=="string" then
		local marco = Assets:FindFirstChild("Frames"):FindFirstChild(NameCuadro)
		marco = marco and marco:FindFirstChild(FormatSize)
		if marco then
			marco = marco:Clone()
			marco.Parent = Canva
			marco:FindFirstChild("Soldadura").Part0 = Canva
		end
	end
end

module.LoadOtherFrames = function(ModeloCuadro : Model, Serializacion : string?)
	if not ModeloCuadro then return end

	local ownCharacter = Player.Character

	local Separate = FormatPinturaData.SeguridadFormato(Serializacion)
	local canva = ModeloCuadro:FindFirstChild('Canva')

	if ModeloCuadro:IsDescendantOf(workspace) and Separate and ownCharacter then
		local FormatSer = Separate[1]

		local distance = (ModeloCuadro:GetPivot().Position - ownCharacter:GetPivot().Position).Magnitude
		local maxDistance = 50
		
		ModeloCuadro.model.Transparency = (distance <= maxDistance or ModeloCuadro:HasTag("Paint")) and 1 or 0
		
		if distance <= maxDistance then
			if canva then
				local Frame = ModeloCuadro.Canva.Canva.SurfaceGui.Canva
				canva.CFrame = ModeloCuadro.model.CFrame
				return Save.Deserialize(Serializacion,Frame)
			else
				local CreateCanva = Assets.Paint:FindFirstChild(FormatSer):Clone()
				CreateCanva.Parent = ModeloCuadro
				CreateCanva.CFrame = ModeloCuadro.model.CFrame
				CreateCanva.Name = 'Canva'
				CreateMarco(CreateCanva, ModeloCuadro:GetAttribute("Marco"), FormatSer)
				local Frame = CreateCanva.Canva.SurfaceGui.Canva
				return Save.Deserialize(Serializacion,Frame)
			end
		end

	end

	if canva then
		game.Debris:AddItem(canva,0)
		if ModeloCuadro:FindFirstChild("model") then
			ModeloCuadro.model.Transparency = ModeloCuadro:HasTag("Paint") and 1 or 0
		end
	end
end

module.Reload = function(PaintGui,modelRef,exit)
	if not modelRef then return end
	posis = {}
	game.Debris:AddItem(modelRef:FindFirstChild('Canva'),0)
	if not exit then
		ServerClient:UpdateCuadros(modelRef,nil,true)
	end
	for _, conn in ipairs(module.conections) do
		if conn and conn.Connected then
			conn:Disconnect()
		end
	end
	table.clear(module.conections)
	PaintGui.Paint.Visible = true
	PaintGui.Tools.Visible = false
	PaintGui.Paint.Visible = not exit
	Save.Init:Disconnect()
	module.ActiveFormat:Disconnect()
	module.ManageChart:Disconnect()
	module.Init:Disconnect()
	Connects:Disconnect()
	for _, Colors in ipairs(PaintGui.Tools.ColorPalette.Palette:GetChildren()) do
		game.Debris:AddItem(Colors,0)
	end
end

module.ManageChart = function(Player,PaintGui,FormatText,NameCuadro, lastPintura)
	local modelActual = PromptModule:GetModelActual()
	module.ActiveFormat(FormatText, modelActual, PaintGui, Player,NameCuadro,lastPintura)
	Save.Init(FormatText, modelActual, PaintGui, Player, NameCuadro)
end

ServerClient.ModulePaint = module

return module