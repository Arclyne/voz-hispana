
local SettingsInfo = {}
SettingsInfo.__index = SettingsInfo

local defaultSettings = {
	effects = 100,
	music = 100,
	voiceChat = 100,
	shadows = true,
	textures = true,
	animations = true
}

local sharedSettings = {
	_data = table.clone(defaultSettings),
	_bindable = Instance.new("BindableEvent")
}

SettingsInfo.Changed = sharedSettings._bindable.Event


function SettingsInfo:Get(key)
	return sharedSettings._data[key]
end


function SettingsInfo:Set(key, value)
	if sharedSettings._data[key] ~= value then
		sharedSettings._data[key] = value
		sharedSettings._bindable:Fire(key, value)
	end
end

return SettingsInfo