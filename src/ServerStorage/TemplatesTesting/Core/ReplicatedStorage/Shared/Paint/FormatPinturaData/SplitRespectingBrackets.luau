local function SplitRespectingBrackets(str)
	local result = {}
	local current = ""
	local depth = 0
	for i = 1, #str do
		local c = str:sub(i,i)
		if c == '{' or c == '[' or c == '(' then
			depth += 1
			current ..= c
		elseif c == '}' or c == ']' or c == ')' then
			depth -= 1
			current ..= c
		elseif c == ',' and depth == 0 then
			table.insert(result, current)
			current = ""
		else
			current ..= c
		end
	end
	if current ~= "" then
		table.insert(result, current)
	end
	for i, v in ipairs(result) do
		local asd = v:match("^%s*(.-)%s*$")
		if #asd > 0 then
			result[i] = asd
		end
	end
	return result
end
return SplitRespectingBrackets