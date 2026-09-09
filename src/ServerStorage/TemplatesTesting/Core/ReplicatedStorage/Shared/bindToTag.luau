local CollectionService = game:GetService("CollectionService")

type Binding = (Model: Model) -> (() -> ())?

local function bindToTag(tag: string, binding: Binding)
	local cleanups = {}

	for _, instance in CollectionService:GetTagged(tag) do
		cleanups[instance] = binding(instance)
	end

	CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance)
		cleanups[instance] = binding(instance)
	end)
	
	CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance)
		if cleanups[instance] then
			cleanups[instance]()
			cleanups[instance] = nil
		end
	end)
end

return bindToTag
