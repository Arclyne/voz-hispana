local module = {}

setmetatable(module, {
	__index = function() return module.General end,
})

function module:General()
	if self.Disabled then
		local Part:Part = self.Disabled.PrimaryPart or self.Disabled:FindFirstChild("Primary")
		if Part then
			local list = {"Back","Front","Left","Right","Top"}
			Part:SetAttribute("Whitelist", table.concat(list,","))
		end
	end
end

return module