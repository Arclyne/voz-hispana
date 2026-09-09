--[[
    Este script sirve para que otros scripts esperen a que se carguen los templates.
    -------------------------------------------------
    Ejemplo de uso en un Script:

	local ServerStorage = game:GetService("ReplicatedStorage")
	require(ServerStorage:WaitForChild("InitAfterTemplates"))  -- Para esperar a que carguen todos los templates
    -------------------------------------------------
    
    Cualquier duda, preguntar a Alvelex
--]]
--[=[
	Barrera bloqueante que espera a que las plantillas estén importadas.

	No es un módulo con API: es una **barrera**. `require` no devuelve una tabla de
	funciones, sino que **no vuelve** hasta que las plantillas están listas, y entonces
	devuelve `true`. Un script que necesite código de plantilla lo pone al principio y se
	olvida del problema.

	```lua
	require(game:GetService("ReplicatedStorage"):WaitForChild("InitAfterTemplates"))
	-- a partir de aquí, las plantillas ya están importadas
	```

	Existe porque `ImportTemplates.server.luau` e `InitScripts.server.luau` son dos
	`Script` hermanos de `ServerScriptService`, y Roblox no garantiza en qué orden
	arrancan. Esta barrera hace que ese orden deje de importar.

	La señal es distinta en cada lado, y las dos se consultan igual:

	| Lado | Fuente de verdad | Respaldo |
	|---|---|---|
	| Servidor | El `BoolValue` `TemplatesReadyFlag` | `Changed`, por si aún no está puesto |
	| Cliente | El `RemoteEvent` `TemplatesReady` | El mismo `BoolValue`, por si el evento ya se disparó antes de conectarse |

	Comprobar el `BoolValue` **antes** de conectarse al evento es lo que evita la carrera
	del cliente que llega tarde: si el aviso ya pasó, la bandera sigue puesta.

	:::caution Bloquea el hilo que hace `require`

	El último paso es `repeat task.wait() until ready`. Un script que lo requiera antes de
	que las plantillas lleguen queda detenido ahí, sin tiempo máximo. Es lo que se busca,
	pero conviene saberlo: no hay ninguna ruta de error ni de rendición.

	:::

	@class InitAfterTemplates
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TemplatesReady = ReplicatedStorage:WaitForChild("TemplatesReady")
local TemplatesReadyFlag = ReplicatedStorage:WaitForChild("TemplatesReadyFlag")

local ready = false

if RunService:IsServer() then
	-- En servidor usamos la BoolValue como fuente de verdad
	if TemplatesReadyFlag.Value then
		ready = true
	else
		TemplatesReadyFlag.Changed:Connect(function()
			if TemplatesReadyFlag.Value then
				ready = true
			end
		end)
	end
else
	-- En cliente escuchamos el RemoteEvent, y también comprobamos el flag (por si ya fue disparado antes)
	if TemplatesReadyFlag.Value then
		ready = true
	else
		TemplatesReady.OnClientEvent:Connect(function()
			ready = true
		end)
	end
end

repeat task.wait() until ready
return true
