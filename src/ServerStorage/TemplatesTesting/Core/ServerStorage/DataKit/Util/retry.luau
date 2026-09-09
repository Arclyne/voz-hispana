--!strict

local DEFAULT_ATTEMPTS = 5
local DEFAULT_BASE_WAIT = 0.25

export type Options = {
	wait: (seconds: number) -> (),
	attempts: number?,
	baseWait: number?,
	label: string?,
}

--[=[
	@function retry
	@within Util

	Reintenta `fn` hasta `opts.attempts` veces con espera lineal (`baseWait * intento`).
	`opts.wait` se inyecta (instantáneo en tests). Devuelve `(true, resultado)` en el
	primer éxito, o `(false, mensaje)` al agotar los intentos. Los `...` se pasan a `fn`.
]=]
local function retry(opts: Options, fn: (...any) -> any, ...: any): (boolean, any)
	local attempts = opts.attempts or DEFAULT_ATTEMPTS
	local baseWait = opts.baseWait or DEFAULT_BASE_WAIT
	local label = opts.label or "retry"
	local args = { ... }

	for attempt = 1, attempts do
		local ok, res = pcall(fn, table.unpack(args))
		if ok then
			return true, res
		end
		warn(`[{label}] failed {attempt}/{attempts} → {res}`)
		if attempt < attempts then
			opts.wait(baseWait * attempt)
		end
	end

	return false, `[{label}] retries exhausted`
end

return retry
