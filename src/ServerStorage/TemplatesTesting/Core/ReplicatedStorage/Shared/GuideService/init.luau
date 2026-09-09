local module = {}
module.__index = module
local Server = require(script:WaitForChild('Server'))
local Disconnects = require(script:WaitForChild('Disconnects'))
function module.new()
	local self = setmetatable({
		_active = {},
		AddedRegister = require(script:WaitForChild('PageController')),
		EndEvent = {},
	}, module)
	return self
end
function module:Verify(uniqueKey)
	if typeof(uniqueKey) ~= "string" then
		warn("El valor no es un string, intenta de nuevo.")
		return true
	end
	return
end
function module:GetEnded(uniqueKey)
	return not self:Verify(uniqueKey) and self._active[uniqueKey] and self._active[uniqueKey].Ended
end
function module:Bind(uniqueKey, force)
	if self:Verify(uniqueKey) then return end
	if self._active[uniqueKey] then
		if not force then
			warn(`[GuideService] La acción "{uniqueKey}" ya existe. Usa UnbindTutorial o pasa "force = true".`)
			return
		end
		self:Unbind(uniqueKey)
	end
	self._active[uniqueKey] = self.AddedRegister.new(uniqueKey)
	self._active[uniqueKey]:init()
end
function module:Unbind(uniqueKey)
	if self:Verify(uniqueKey) then return end
	if self._active[uniqueKey] then
		self._active[uniqueKey]:destroy()
		self._active[uniqueKey] = nil
	else
		warn(`[GuideService] La acción "{uniqueKey}" no existe`)
	end
end
function module:AddPage(uniqueKey,...)
	if self:Verify(uniqueKey) then return end
	if self._active[uniqueKey] then
		self._active[uniqueKey]:AddPage(...)
	else
		warn(`[GuideService] La acción "{uniqueKey}" no existe`)
	end
end
function module:RemovePage(...)
	self:AddPage(...)
end
function module:Start(uniqueKey, force)
	if self:Verify(uniqueKey) then return end
	if self._active[uniqueKey] then
		if not self.IsActive then
			if force or Server.GetState(uniqueKey) ~= Enum.UserInputState.End then
				self.IsActive = self._active[uniqueKey]
				self.IsActive:Start()
				table.insert(self.EndEvent, self.IsActive.Ended:Connect(function(IsDone)
					Server.CloseGuide(uniqueKey, IsDone and "ended" or "cancel")
					self:End(uniqueKey)
				end))
				return true
			else
				warn(`[GuideService] La acción "{uniqueKey}" ya fue hecha, Usa "force = true" para activalo de nuevo pero ya no obtendra recompensas.`)
			end
		else
			warn(`[GuideService] ya existe una accion "{self.IsActive.uniqueKey}" en proceso.`)
		end
	else
		warn(`[GuideService] La acción "{uniqueKey}" no existe`)
	end
end
function module:End(uniqueKey)
	if self:Verify(uniqueKey) then return end
	if self._active[uniqueKey] then
		self._active[uniqueKey]:End(true)
		if self._active[uniqueKey] == self.IsActive then
			self.IsActive = nil
			Disconnects.All(self.EndEvent)
		end
	else
		warn(`[GuideService] La acción "{uniqueKey}" no existe`)
	end
end
return game:GetService('RunService'):IsServer() and Server or module.new()