--!strict
local Signal = require(script.Parent.Signal)

local ERR_COUNT = 5
local EXPIRE = 120

--[=[
	@class Health

	Circuit-breaker por-store. Cuenta operaciones fallidas dentro de una ventana
	deslizante de `EXPIRE` segundos y marca el store como crítico al alcanzar
	`ERR_COUNT`. El reloj se inyecta para tests deterministas. Emite las señales
	`OnError(msg)` y `OnCriticalToggle(critical)`.
]=]
local Health = {}
Health.__index = Health

Health.ERR_COUNT = ERR_COUNT

type self = {
	OnError: Signal.Signal,
	OnCriticalToggle: Signal.Signal,
	_now: () -> number,
	_issues: { number },
	_critical: boolean,
}

export type Health = typeof(setmetatable({} :: self, Health))

--[=[
	@within Health
]=]
function Health.new(now: () -> number): Health
	return setmetatable({
		OnError = Signal.new(),
		OnCriticalToggle = Signal.new(),
		_now = now,
		_issues = {},
		_critical = false,
	}, Health)
end

-- Poda los fallos fuera de la ventana y actualiza `_critical`; emite `OnCriticalToggle`
-- al cambiar de estado. Sin scheduler propio, esto solo corre cuando algo lo dispara
-- (isCritical o recordFailure) — por eso una ventana ya vencida puede seguir "activa"
-- hasta la próxima llamada.
function Health._refresh(self: Health)
	local now = self._now()
	while self._issues[1] and (now - self._issues[1] > EXPIRE) do
		table.remove(self._issues, 1)
	end
	local crit = #self._issues >= ERR_COUNT
	if crit ~= self._critical then
		self._critical = crit
		self.OnCriticalToggle:Fire(crit)
	end
end

--[=[
	@within Health

	`true` si el store está en estado crítico. No es una lectura pura: refresca la
	ventana antes de responder (ver [Health._refresh]), así que puede podar fallos
	vencidos y disparar `OnCriticalToggle`.
]=]
function Health.isCritical(self: Health): boolean
	self:_refresh()
	return self._critical
end

--[=[
	@within Health

	Registra una operación fallida (no cada reintento) y refresca el estado derivado.
]=]
function Health.recordFailure(self: Health, msg: string)
	table.insert(self._issues, self._now())
	self.OnError:Fire(msg)
	self:_refresh()
end

return Health
