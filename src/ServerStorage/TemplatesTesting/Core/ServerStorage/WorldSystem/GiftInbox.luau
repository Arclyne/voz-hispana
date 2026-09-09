--!strict
--[[
	Buzón de regalos para quien no está en este servidor cuando llega el recibo.

	Existe porque devolver `NotProcessedYet` con el receptor ausente deja el recibo en
	el limbo: Roblox solo lo reintenta mientras el COMPRADOR esté conectado, y si el
	receptor no vuelve a coincidir con él, los Robux se cobran y no se entrega nada
	nunca. Guardamos el regalo aquí, damos el recibo por bueno, y el receptor lo
	recoge al entrar.

	Va en un DataStore aparte y no en el perfil a propósito: el perfil tiene un único
	escritor por lease, y aquí el servidor del comprador escribe sobre la identidad de
	otro jugador. `UpdateAsync` da la atomicidad necesaria si dos compradores regalan
	a la misma persona a la vez.
]]

local DataStoreService = game:GetService("DataStoreService")

local INBOX = DataStoreService:GetDataStore("GiftInbox_v1")
local MAX_ENTRIES = 50

export type Entry = {
	kind: string,
	id: number?,
	currency: string?,
	amount: number?,
	from: number?,
}

local GiftInbox = {}

--[[
	Guarda un regalo pendiente. Devuelve `false` si no pudo escribirse: quien llama
	debe NO dar el recibo por bueno en ese caso.
]]
function GiftInbox.push(userId: number, entry: Entry): boolean
	local stored = false

	local ok, err = pcall(function()
		INBOX:UpdateAsync(tostring(userId), function(current: any)
			local list = current or {}
			if #list >= MAX_ENTRIES then
				-- Devolver nil cancela la escritura: no reventamos el buzón.
				return nil
			end
			table.insert(list, entry)
			stored = true
			return list
		end)
	end)

	if not ok then
		warn("[GiftInbox] No se pudo guardar el regalo para", userId, err)
		return false
	end

	if not stored then
		warn("[GiftInbox] Buzón lleno para", userId)
	end

	return stored
end

--[[
	Saca y vacía el buzón del jugador. Si la lectura falla devuelve una lista vacía
	sin borrar nada, para no perder regalos por un fallo transitorio del DataStore.
]]
function GiftInbox.drain(userId: number): { Entry }
	local drained: { Entry } = {}

	local ok, err = pcall(function()
		INBOX:UpdateAsync(tostring(userId), function(current: any)
			drained = current or {}
			if #drained == 0 then
				return nil -- nada que vaciar, no gastamos una escritura
			end
			return {}
		end)
	end)

	if not ok then
		warn("[GiftInbox] No se pudo leer el buzón de", userId, err)
		return {}
	end

	return drained
end

return GiftInbox
