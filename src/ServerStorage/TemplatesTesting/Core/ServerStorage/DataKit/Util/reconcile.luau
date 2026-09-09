--!strict
local deepCopy = require(script.Parent.deepCopy)

--[=[
	@function reconcile
	@within Util

	Rellena `target` con las claves string que falten de `template` (recursivo, sin
	pisar valores existentes). Devuelve `true` si hubo algún cambio.
]=]
local function reconcile(target: any, template: any): boolean
	local changed = false
	for k, v in pairs(template) do
		if type(k) ~= "string" then
			continue
		end
		if target[k] == nil then
			target[k] = deepCopy(v)
			changed = true
		elseif type(target[k]) == "table" and type(v) == "table" and reconcile(target[k], v) then
			changed = true
		end
	end
	return changed
end

return reconcile
