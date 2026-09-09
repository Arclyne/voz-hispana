local module = {}
module.__index = module

local RunS = game:GetService("RunService")
local IsClient = RunS:IsClient()
local InstanceModule = require(script:WaitForChild("Instance"))
local Actions = require(script:WaitForChild("Actions"))

function Desactive(list, ...)
	local all = {...}
	if #all > 0 then
		for _,v in all do
			if list[v] then
				list[v]:Disconnect()
				list[v] = nil
			end
		end
	else
		for _,v in list do
			v:Disconnect()
		end
		table.clear(list)
	end
end

function module.new()
	local self = setmetatable({
		
		IsActive = false,
		actives = {},
		models = {},
		
	}, module)
	
	self:init()
	
	return self
end

function module:GetElapsedTime(t)
	local now = os.clock()
	t = tonumber(t) or now
	return now-t
end

function module:UpdateActionNPCs()
	if self.actives.running then return end
	local UpdateEvent = IsClient and RunS.RenderStepped or RunS.Heartbeat
	self.actives.running = UpdateEvent:Connect(function()
		local IsClear = true
		for _, character in self.models do
			if character.InAction then
				local accionar = Actions[character.InAction.State]
				if not accionar or not accionar(self, character) then
					character.InAction = nil
					character:SetState("idle")
				else
					IsClear = false
				end
			end
		end
		if IsClear then
			Desactive(self.actives, "running")
		end
	end)
end

function module:add(model : Model)
	assert(typeof(model) == "Instance" and model:FindFirstChild("Humanoid"), "No es un Character...")
	if not self.IsActive or self.models[model] then return end
	local Custom = InstanceModule.new(model)
	if not Custom then return end
	self.models[model] = Custom
	table.insert(Custom.IsActive, Custom.StateChanged:Connect(function(state)
		if state == "dead" or state == "deleted" then
			self:remove(model)
		else
			Custom.animator:PlayAnimation(state~="action" and state or "idle")
			self:UpdateActionNPCs()
		end
	end))
	return Custom
end

function module:remove(model)
	local Object = self:get(model)
	if not Object then return end
	if Object.CallBack then pcall(Object.CallBack,"Cancel") end
	if Object.InAction and Object.InAction.action then
		task.defer(Object.InAction.action,"Cancel")
	end
	Object:destroy()
	self.models[model] = nil
end

function module:get(model)
	return typeof(model) == "Instance" and self.models[model]
end

function module:init()
	if self.IsActive then return end
	self.IsActive = true
end

return module.new()