--[[
    TextScaler
    ---------------
    Ejemplo de uso:
	local TextScaler = require(ReplicatedStorage.Shared:WaitForChild("textScaler"))
    textLabel.TextSize = TextScaler.getScaledFontSize(textLabel.Text, messageLabel.TextSize)
--]]
local TextScaler = {}

-- Función que ajusta el tamaño de fuente en función de la cantidad de caracteres.
function TextScaler.getScaledFontSize(text, baseFontSize)
	
	if typeof(text) ~= "string" then
		warn("⚠️ TextScaler.getScaledFontSize recibió un valor no-string:", text)
		text = tostring(text)
	end
	
	local charCount = #text
	local newSize = baseFontSize

	if charCount > 100 then
		newSize = baseFontSize * 0.5
	elseif charCount > 50 then
		newSize = baseFontSize * 0.8
	elseif charCount > 25 then
		newSize = baseFontSize * 0.9
	elseif charCount > 10 then
		newSize = baseFontSize * 0.95
	end

	return newSize
end

return TextScaler
