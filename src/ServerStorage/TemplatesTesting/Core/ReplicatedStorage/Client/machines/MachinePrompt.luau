local Interactable = require(script.Parent.Parent.interactable.Interactable)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Shared.Signal)

local MachinePrompt = {}
MachinePrompt.__index = MachinePrompt

function MachinePrompt.new(model: Model)
	local self = setmetatable({
		prompt = Interactable.new(),
		triggered = Signal.new(),
	}, MachinePrompt)
	
	self.prompt:setAdornee(model:WaitForChild("Prompt"))
	self.prompt:setClickHitbox(model)
	
	self.wheel = self.prompt:getDefaultWheel()
	self.wheel:setQuickAction("Jugar", self.triggered.Fire, self.triggered)
	self.wheel.page:addAction("Jugar", self.triggered.Fire, self.triggered)

	if model:GetAttribute("Started") then
		self.prompt:disable()
	end

	return self
end

function MachinePrompt:enable()
	self.prompt:enable()
end

function MachinePrompt:disable()
	self.prompt:disable()
end

return MachinePrompt
