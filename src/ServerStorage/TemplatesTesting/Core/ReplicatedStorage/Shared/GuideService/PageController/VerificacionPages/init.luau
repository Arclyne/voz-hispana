local module = {}

local Changed = require(script:WaitForChild("Changed"))

module.Data = {
	Text = {
		IsA = "TextLabel",
		instance = script:WaitForChild('TextLabel'),
		Options = {
			Text = "Hi!",
			Size = Vector2.new(.3,0),
			Font = Enum.Font.SourceSans,
			TextSize = 1,
		},
	},
	Copy = {
		IsA = "TextBox",
		instance = script:WaitForChild('Copy'),
		Options = {
			Text = "Hi!",
			Size = Vector2.new(.5,0),
			Font = Enum.Font.SourceSans,
			TextSize = .6,
		},
	},
	Image = {
		IsA = "ImageLabel",
		instance = script:WaitForChild('Image'),
		Options = {
			Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
			Size = Vector2.new(2,0),
			SizeImage = .8,
		},
	},
}

function module.verifiSection(Data)
	if typeof(Data)=="table" then
		local result = {}
		for _,dataContext in Data do
			if typeof(dataContext) == 'table' and module.Data[dataContext.type or "not found"] then
				table.insert(result, dataContext)
			end
		end
		return #result > 0 and result or nil
	end
end

function module.Create(data,parent)
	local dataSelect = module.Data[typeof(data)=='table' and data.type or "not found"]
	
	if dataSelect and parent then
		local clone = dataSelect.instance:Clone()
		clone.Parent = parent.Loading
		data.Options = data.Options or dataSelect.Options
		for index2,value in dataSelect.Options do
			Changed(index2,data.Options,dataSelect,clone)
		end
		clone.Parent = parent
		clone.GroupTransparency = 0
	end
	
end

return module