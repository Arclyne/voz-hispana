local module = {}
module.__index = module

module.Added = require(script:WaitForChild('AddedDecor'))

local EventCustom = require(game:GetService("ReplicatedStorage"):WaitForChild("Client"):WaitForChild("Event"))
local debris = game:GetService("Debris")
local IsA = "Decors"

function desactive(active, ...)
	local total = {...}
	if #total > 0 then
		for _, value in total do
			if active[value] then
				active[value]:Disconnect()
				active[value] = nil
			end
		end
	else
		for _,v:RBXScriptConnection in active do
			v:Disconnect()
		end
		table.clear(active)
	end
end

function module.new(NameObject)
	local self = setmetatable({
		Name = NameObject,
		Childs = {},
		Decors = true,
	}, module)
	
	self.ChildAdded = EventCustom.new()
	self.ChildRemoved = EventCustom.new()
	self.ChildChanged = EventCustom.new()
	
	return self
end

function module:IsA(t) return t == IsA end

function module:GetChildren(bool, OnlyNumbers)
	if bool == nil then return OnlyNumbers and #self.Childs or self.Childs end
	local list = not OnlyNumbers and {} or 0
	for _,object in self.Childs do
		if not not object.Disabled == not not bool then
			if OnlyNumbers then
				list += 1
			else
				table.insert(list,object)
			end
		end
	end
	return list
end
function module:GetCountChilds(bool)
	return self:GetChildren(bool, true)
end

function module:GetDataSection()
	if not self.DataSection then
		for _,object in self.Childs do
			self.DataSection = {
				Model = object.Model,
				Info = object.Data,
			}
			return self.DataSection
		end
	else
		return self.DataSection
	end
end

function module:Add(decor : Instance)
	local Object = self.Added.new(decor)
	if Object then
		table.insert(self.Childs, Object)
		table.insert(Object.actives,decor.AncestryChanged:Connect(function(decor2,Parent)
			if decor2 == decor and not Parent then
				self:Remove(decor)
			end
		end))
		table.insert(Object.actives, Object.DisabledChanged:Connect(function()
			self.ChildChanged:Fire(decor)
			desactive(Object.actives, "DisabledInstance")
			if not Object.Disabled then return end
			Object.actives["DisabledInstance"] = Object.Disabled.AncestryChanged:Connect(function(_,parent)
				if parent then return end
				Object:Update(nil, true)
			end)
		end))
		self.ChildAdded:Fire(decor)
	elseif #self.Childs <= 0 then
		self.ListMain:Remove(decor.Name)
	end
end

function module:Remove(decor)
	if typeof(decor) == "Instance" then
		for _,v in self.Childs do
			if v.Boolean == decor then
				desactive(v.actives)
				v.DisabledChanged:Destroy()
				table.remove(self.Childs, table.find(self.Childs, v))
				if #self.Childs <= 0 then
					self.ListMain:Remove(decor.Name)
				else
					self.ChildRemoved:Fire(decor)
				end
				break
			end
		end
	end
end

return module