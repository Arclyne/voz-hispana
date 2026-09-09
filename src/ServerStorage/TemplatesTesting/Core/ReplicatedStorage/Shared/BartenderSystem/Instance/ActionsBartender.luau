local module = {}

module.IdleAction = {
	{
		"walk : Walkpoint3",
		"hold : 0.5",
		"hold : combing",
		"hold : 0.5",
	},
	
	{
		"walk : Walkpoint2",
		"hold : 0.5",
		"hold : swinging",
		"hold : 0.5",
	},
	
	{
		"walk : Walkpoint1",
		"hold : 0.5",
		"hold : clock",
		"hold : 0.5",
	},
	
	{
		"walk : Walkpoint1",
		"hold : 1",
	},
	
	{
		"walk : Walkpoint2",
		"hold : 1",
	},
	
	{
		"walk : Walkpoint3",
		"hold : 1",
	},
}

module.IdAnimations = {
	idle = 95957848999704,
	giveBebida = 71469378779952,
	
	bebidaTop = 82973915250293,
	bebidaMid = 100326262520391,
	bebidaLow = 76469547799909,
	
	combing = 91221694833975,
	swinging = 93352545733558,
	clock = 102582233261841,
}

module.FolderAnimations = Instance.new("Folder", script)
for index, value in module.IdAnimations do
	local anim = Instance.new("Animation", module.FolderAnimations)
	anim.Name = index
	anim.AnimationId = string.format("rbxassetid://%d", value)
end

return module
