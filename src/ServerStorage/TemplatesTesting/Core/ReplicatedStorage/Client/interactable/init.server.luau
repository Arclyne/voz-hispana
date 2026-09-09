local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Shared")
local bindToTag = require(shared:WaitForChild("bindToTag"))

for _, child in script:GetChildren() do
	if not child:IsA("ModuleScript") then
		continue
	end

	local module = require(child)
	
	bindToTag(child.Name, function(instance)
		local object = module.new(instance)
		return typeof(object.onDestroy) == "function" and function()
			object:onDestroy()
		end
	end)
	
end
