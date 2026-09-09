local module = {}

setmetatable(module, {__index = function() return print end})

return module
