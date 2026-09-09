local module = {}

module.__index = module

local EventCustom = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("Event"))
local Client = game:GetService("RunService"):IsClient()
local debris = game:GetService("Debris")

function module.new()
	local self = setmetatable({}, module)
	self.Childs = {}
	self.ChildAdded = EventCustom.new()
	self.ChildRemoved = EventCustom.new()
	self.Count = 0
	return self
end

function module:AddToFilter()
	local list = {}
	
	for _,section in self.Childs do
		for _,object in section.Childs do
			if object.Disabled then
				table.insert(list, object.Disabled)
			end
		end
	end
	
	local param = RaycastParams.new()
	param.FilterType = Enum.RaycastFilterType.Include
	param.FilterDescendantsInstances = list
	param.IgnoreWater = true
	
	return param
end
function module:UpdateCount()
	local total = 0
	for _,_ in self.Childs do
		total += 1
	end
	self.Count = math.floor(total)
end
function module:Get()
	return self.Childs
end
function module:Find(nameObject)
	return typeof(nameObject) == "string" and self.Childs[nameObject]
end
function module:GetDescendants()
	local list = {}
	for _,section in self.Childs do
		for _,object in section:GetChildren(true) do
			table.insert(list, object)
		end
	end
	return list
end

function module:GetCountBuilds()
	local count = 0
	for _,section in self.Childs do
		count += section:GetCountChilds(true)
	end
	return count
end

function module:Add(NameObject, Option)
	if typeof(NameObject) == "string" and typeof(Option) == 'table' then
		local search = self:Find(NameObject)
		if search then
			return search
		else
			self.Childs[NameObject] = Option
			self:UpdateCount()
			self.ChildAdded:Fire(NameObject)
			return Option
		end
	end
end
function module:Remove(NameObject)
	local Object = self:Find(NameObject)
	if Object and Object:GetCountChilds() <= 0 then
		Object.ChildAdded:Destroy()
		Object.ChildRemoved:Destroy()
		Object.ChildChanged:Destroy()
		self.Childs[NameObject] = nil
		self:UpdateCount()
		self.ChildRemoved:Fire(NameObject)
	end
end

return not Client and {} or module.new()
