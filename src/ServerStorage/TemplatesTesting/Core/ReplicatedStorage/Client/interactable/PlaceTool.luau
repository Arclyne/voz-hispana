-- Este es el interactuable del bloque invisible que aparece cuando hacemos click a una superficie
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interactable = require(script.Parent.Interactable)

local remotes = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Interactable")

local PlaceTool = {}
PlaceTool.__index = PlaceTool
setmetatable(PlaceTool, Interactable)

function PlaceTool.new(instance: Part)
	local self = Interactable.new()
	setmetatable(self, PlaceTool)

	self.instance = instance
	self.ParentObject = instance.Parent
	instance.Parent = workspace
	self.wheel = self:getDefaultWheel()

	self:setAdornee(instance)
	self:setClickHitbox(instance)

	-- añadimos a la rueda
	self.wheel.page:addAction("Colocar", self.place, self)

	-- Ocultamos el prompt y abrimos la rueda automáticamente
	task.defer(function()
		--task.wait() 
		self.customPrompt:hide()
		self.wheel:show()
	end)

	-- Autodestrucción si el jugador se aleja
	self.proximityPrompt.PromptHidden:Connect(function()
		self:onDestroy()
	end)
	
	
	return self
end

function PlaceTool:place()
	local toolName = self.instance:GetAttribute("ToolName")
	local position = self.instance.Position
	local rotY = self.instance:GetAttribute("SurfaceRotY")

	-- Enviar al servidor la orden de colocar
	remotes.PlaceTool:FireServer(toolName, position, rotY, self.ParentObject)

	self:onDestroy()
end

function PlaceTool:onDestroy()
	if self.instance and self.instance.Parent then
		self.instance:Destroy()
	end
end

return PlaceTool