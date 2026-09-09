local TextService = game:GetService('TextService')

function changed(index,options,data,gui)
	if typeof(index)=='string' and typeof(data)=="table" and typeof(gui)=='Instance' and typeof(data.instance)=='Instance' and data.instance.ClassName == gui.ClassName then
		local value = options[index] or data.Options[index]
		if value and value~=data.Options[index] and typeof(data.Options[index])==typeof(value) then
			if index == "Size" then
				gui.Size = UDim2.new(1,0,value.X,value.Y)
				if data.IsA == "ImageLabel" then
					local AbsoluteSizeY = gui.Parent.Parent.AbsoluteSize.Y
					local Scale = options["SizeImage"] or data.Options["SizeImage"]
					local SizeImage = (data.Options["Size"].X * AbsoluteSizeY) + data.Options["Size"].Y
					SizeImage -= SizeImage*data.Options["SizeImage"]
					gui.Input.Size = UDim2.new(gui.Input.Size.X.Scale,0,1,-SizeImage)
				end
			elseif data.IsA == "TextLabel" or data.IsA == "TextBox" then
				if index == "Text" then
					gui.Input.Text = value
					local SizeText = (options["Size"] or data.Options["Size"]).X * gui.Parent.Parent.AbsoluteSize.Y * (options["TextSize"] or data.Options["TextSize"])
					gui.Input.TextSize = SizeText
					local Fonta = options["Font"] or data.Options["Font"]
					local tamano = math.max(TextService:GetTextSize(value,SizeText,Fonta,Vector2.new(gui.Input.AbsoluteSize.X,math.huge)).Y-SizeText,0)
					gui.Input.Size = UDim2.new(gui.Input.Size.X.Scale,0,0,SizeText + tamano)
					options["Size"] = Vector2.new((options["Size"] or data.Options["Size"]).X, tamano)
					changed("Size",options,data,gui)
				elseif index == "Font" then
					gui.Input.Font = value
				end
			elseif index == "Image" and data.IsA == "ImageLabel" then
				gui.Input.Image = value
			end
		end
	end
end

return changed