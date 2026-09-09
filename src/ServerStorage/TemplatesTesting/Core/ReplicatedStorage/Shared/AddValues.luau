local get = require(script.Parent:WaitForChild('BreakDown')).Get

function Verify(list)
	if typeof(list) ~= "table" then return false end

	local hasName = typeof(list.Name) == "string" and #list.Name > 0
	local hasValue = list.Value ~= nil

	return hasName and hasValue
end

function Create(Name, Value, Attributes)
	if not Name then return end

	local bool : ValueBase

	if typeof(Value) == 'number' then
		bool = Value-math.floor(Value) > 0 and Instance.new('NumberValue') or Instance.new('IntValue')
	elseif typeof(Value) == 'string' then
		bool = Instance.new('StringValue')
	elseif typeof(Value) == 'Instance' then
		bool = Instance.new('ObjectValue')
	elseif typeof(Value) == 'boolean' or typeof(Value) == 'nil' then
		bool = Instance.new('BoolValue')
	else
		warn("Tipo de valor no compatible:", typeof(Value), "en", Name)
		return nil
	end

	bool.Name = Name
	bool.Value = Value

	for index, valor in typeof(Attributes) == 'table' and Attributes or {} do
		if index == 'Name' or index == 'Value' then continue end

		if index == 'Childs' and typeof(valor) == 'table' then
			for _, child in valor do
				if typeof(child) == 'table' and Verify(child) then
					local childInstance = Create(child.Name, child.Value, child)
					if childInstance then
						childInstance.Parent = bool
					end
				end
			end
		else
			-- CORRECCIÓN IMPORTANTE:
			local finalValue = get(valor)

			-- Roblox prohíbe poner Tablas como atributos. Verificamos antes de ponerlo.
			if finalValue ~= nil and typeof(finalValue) ~= "table" then
				bool:SetAttribute(index, finalValue)
			end
		end
	end

	return bool
end

return Create