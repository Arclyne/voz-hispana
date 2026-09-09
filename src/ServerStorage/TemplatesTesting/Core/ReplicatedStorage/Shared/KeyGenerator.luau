local UniqueIDGenerator = {}
UniqueIDGenerator.__index = UniqueIDGenerator

function UniqueIDGenerator.new()
	return setmetatable({
		generatedIDs = {},
		MaxKeys = 6,
	}, UniqueIDGenerator)
end

function UniqueIDGenerator:GenerateID()
	local newID
	repeat
		newID = ""
		for _ = 1, self.MaxKeys do
			newID = newID .. tostring(math.random(0, 9))
		end
	until not self.generatedIDs[newID]
	self.generatedIDs[newID] = true
	return newID
end

function UniqueIDGenerator:ElimineInList(Key, List : {})
	(List or {})[Key] = nil
	self.generatedIDs[Key] = nil
end

return UniqueIDGenerator.new()
