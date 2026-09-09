return function(Text)
	if typeof(Text)=='string' then
		return string.gsub(Text, " ", "_")
	end
end