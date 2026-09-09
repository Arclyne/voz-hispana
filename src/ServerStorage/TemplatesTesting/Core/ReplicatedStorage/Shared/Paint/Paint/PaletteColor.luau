local ColorPalette = {}
ColorPalette.__index = ColorPalette

function ColorPalette.new(paletteFrame, infoFrame)
	local self = setmetatable({}, ColorPalette)

	self.PaletteFrame = paletteFrame
	self.InfoFrame = infoFrame

	self.ButtonsPerRow = 10
	self.ButtonSize = UDim2.new(0, 30, 0, 30)
	self.Padding = 5

	self.SelectedColor = nil
	self.ColorButtonTemplate = nil

	self:Initialize()

	return self
end

function ColorPalette:Initialize()	
	self.Colors = self:GetAllNamedColors()
	self.ColorButtonTemplate = self:CreateButtonTemplate()
	self:CreateColorButtons()
	self.ColorButtonTemplate.Visible = false
end

function ColorPalette:GetAllNamedColors()
	local namedColors = {}

	local stepsH = 20
	local stepsV = 10 
	local totalCols = stepsH + 1 

	self.ButtonSize = UDim2.new(1 / totalCols, 0, 1 / stepsV, 0)

	local index = 1
	for col = 0, stepsH - 1 do
		local hue = col / stepsH
		for row = 0, stepsV - 1 do
			local value = 1 - (row / (stepsV - 1))
			local color3 = Color3.fromHSV(hue, 1, value)
			local r = math.floor(color3.R * 255)
			local g = math.floor(color3.G * 255)
			local b = math.floor(color3.B * 255)

			table.insert(namedColors, {
				Name = "Color" .. index,
				R = r,
				G = g,
				B = b,
				Color3 = color3,
				Col = col,
				Row = row
			})
			index += 1
		end
	end

	local grayCol = stepsH
	for row = 0, stepsV - 1 do
		local value = 1 - (row / (stepsV - 1))
		local color3 = Color3.fromHSV(0, 0, value)
		local r = math.floor(color3.R * 255)

		table.insert(namedColors, {
			Name = "Gray" .. index,
			R = r,
			G = r,
			B = r,
			Color3 = color3,
			Col = grayCol,
			Row = row
		})
		index += 1
	end

	return namedColors
end

function ColorPalette:CreateButtonTemplate()
	local template = Instance.new("TextButton")
	template.Name = "ColorButtonTemplate"
	template.Size = self.ButtonSize
	template.BackgroundColor3 = Color3.new(1, 1, 1)
	template.Visible = true
	template.Text = ""
	template.BorderSizePixel = 0
	template.BackgroundTransparency = 0

	template.Parent = self.PaletteFrame
	return template
end

function ColorPalette:CreateColorButtons()
	local totalCols = 21 
	local stepsV = 10

	for _, colorData in ipairs(self.Colors) do
		local colorButton = self.ColorButtonTemplate:Clone()
		colorButton.Name = colorData.Name
		colorButton.BackgroundColor3 = colorData.Color3
		colorButton.Size = self.ButtonSize

		colorButton.Position = UDim2.new(
			colorData.Col / totalCols, 0,
			colorData.Row / stepsV, 0
		)

		colorButton.Parent = self.PaletteFrame
		colorButton.MouseButton1Click:Connect(function()
			self:SelectColor(colorData,nil)
		end)
	end
end


function ColorPalette:SelectColor(colorData, color)
	if colorData then
		self.SelectedColor = colorData.Color3
		color = colorData.Color3
	else
		self.SelectedColor = color
	end
	
	local sections = string.split(tostring(color), ",") or nil
	
	local r = (colorData ~= nil) and colorData.R or sections[1]
	local g = (colorData ~= nil) and colorData.G or sections[2]
	local b = (colorData ~= nil) and colorData.B or sections[3]

	local hexColor = self:RGBToHex(r, g, b)

	self.InfoFrame.Color.BackgroundColor3 = color
	self.InfoFrame.R.Text = "R: "..r
	self.InfoFrame.G.Text = "G: "..g
	self.InfoFrame.B.Text = "B: "..b
	self.InfoFrame.HTML.Text = "HTML: "..hexColor
	colorData = nil
end

function ColorPalette:RGBToHex(r, g, b)
	return string.format("#%02X%02X%02X", r, g, b)
end

function ColorPalette:HexToRGB(hex)
	hex = hex:gsub("#","")
	return {
		R = tonumber("0x"..hex:sub(1,2)),
		G = tonumber("0x"..hex:sub(3,4)),
		B = tonumber("0x"..hex:sub(5,6))
	}
end

function ColorPalette:Select()
	return self.SelectedColor or Color3.fromRGB(0,0,0)
end

return ColorPalette