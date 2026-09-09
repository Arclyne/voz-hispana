local module = {}
function module.IsA(v)
	return typeof(v) == 'RBXScriptConnection' or typeof(v)=='table' and typeof(v.Disconnect)=='function'
end
function module.All(active : {})
	if typeof(active) == 'table' then
		for _,v : RBXScriptConnection in active do
			if module.IsA(v) then
				v:Disconnect()
			end
		end
		table.clear(active)
	end
end
function module.Only(list : {}, Name)
	local disconection = typeof(list)=='table' and list[tostring(Name)]
	if disconection and module.IsA(disconection) then
		disconection:Disconnect()
		list[tostring(Name)] = nil
	end
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
