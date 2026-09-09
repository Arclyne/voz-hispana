local module = {}
function module.IsA(v)
	return typeof(v) == 'RBXScriptConnection' or typeof(v)=='table' and typeof(v.Disconnect)=='function'
end
function module.Disconnect(RBXScriptConnection)
	if module.IsA(RBXScriptConnection) then
		RBXScriptConnection:Disconnect()
	end
end
function module.All(active : {})
	if typeof(active) == 'table' then
		for _,v : RBXScriptConnection in active do
			module.Disconnect(v)
		end
		table.clear(active)
	end
end
function module.Only(list : {}, Name)
	Name = Name~=nil and Name or "notFound____"
	local disconection = typeof(list)=='table' and list[Name]
	if not disconection then return end
	list[Name] = module.Disconnect(disconection)
end
function module.Group(list : {}, Group : {})
	if typeof(list) == 'table' and typeof(Group) == 'table' then
		for _,Name in Group do
			module.Only(list, Name)
		end
	end
	return {}
end
return module
