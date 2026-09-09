---
sidebar_position: 23
title: Cliente — interfaz y utilidades
---

# Cliente — interfaz y utilidades

Los archivos sueltos de `ReplicatedStorage/Client/` (1 947 líneas) más las carpetas pequeñas:
la barra superior, las notificaciones, los mensajes, las estadísticas, el ragdoll y la
interfaz de la ruleta.

Las carpetas grandes de `Client/` tienen su propia página:
[Interactuables](./interactable-types.md) (5 675), [Máquinas](./machines.md) (2 039),
[Inventario](./inventory.md) (908) y [Invitaciones](./referrals.md) (683).

## La regla de esta capa

**HECHO.** Salvo dos excepciones que se nombran abajo, aquí no hay autoridad. Estos archivos
escuchan remotes, animan y pintan. La pregunta «¿puede un jugador hacer trampa con esto?» se
responde siempre en el servidor.

Lo que sí importa de esta capa, y por eso se documenta, es **el orden de arranque**: casi
todos empiezan con `WaitForChild` sobre `PlayerGui`, `leaderstats` o el `Character`, y esa
espera es lo que los ata a [PlayerInit](../architecture/client-lifecycle.md).

**HECHO.** Ninguno de estos scripts se activa solo. Son `Script` con `RunContext = Client` y
`Disabled = true` dentro de `ReplicatedStorage/Client`, la carpeta que
`InitScripts.server.luau` **excluye a propósito**. Quien los enciende no está en este
repositorio: [BUG-CANDIDATE-007](../testing/verification-plan.md#bug-candidate-007).

## Las dos excepciones

### `InsertService.luau` — corre en el servidor

**HECHO.** Vive en `Client/` y su primera línea dice lo contrario:

```lua
if not game:GetService("RunService"):IsServer() then return function() return false end end
```

En el cliente el módulo **es una función**, no una tabla, así que `InsertService.LoadAsset`
en el cliente no devuelve `nil`: lanza «attempt to index function». Sus dos consumidores
—`BusquedaMusicas` y `Karaoke/CrearCancion/Attributes`— son de servidor, así que hoy no se
da; queda anotado porque su ubicación invita al error.

**Registrado como correcto, y es importante.** Es el envoltorio de `InsertService:LoadAsset`
para las **miniaturas de canciones**, que son ids de asset **que eligen los jugadores**. Y
antes de devolver nada:

```lua
local function elimineScrips(item : Instance)
	for _,v in item:GetDescendants() do
		if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
			v:Destroy()
		end
	end
end
```

**Cargar un asset arbitrario elegido por un jugador y quitarle todos los scripts antes de
parentearlo es exactamente el control que hace falta.** Es de las mejores decisiones de
seguridad del repositorio, y está en un archivo de tres funciones que no la anuncia.

Alrededor hay un caché con deduplicación de peticiones en vuelo, caducidad de cinco minutos
y recogida de basura periódica. Dos cosas de ese caché quedan registradas como
[BUG-CANDIDATE-045](../testing/verification-plan.md#bug-candidate-045).

### `Client/PlayerManager.server.luau` — `RunContext = Client`, nombre de servidor

**HECHO.** Es el que arranca el tutorial de bienvenida. Ver
[Tutoriales](./tutorials.md#una-fachada-que-cambia-según-el-contexto).

## La barra superior

**HECHO.** `topbar.server.luau` (281) construye los iconos con la librería `Icon`. Ocho
teclas declaradas en `GeneralConfiguration.Interface`, y los iconos se crean por fases: los
fijos al arrancar, y los de mundo cuando `isStarted` pone su atributo `Started`.

| Icono | Tecla | Condición |
|---|---|---|
| Tablet | `Q` | siempre |
| Estadísticas | `G` | siempre |
| Herramientas | `F` | siempre |
| Bailes | `R` | siempre |
| Construcción | `P` | según el tipo de place |
| Night club | `O` | según el tipo de place |
| Favorito | **`M`** | cuando el mundo arranca |
| Admin | **`M`** | `placeType == "room"` **y** rol ≥ `moderator` |

**OBSERVACIÓN — dos iconos comparten la tecla `M`.** El de favorito (línea 222) y el de
administración (línea 246) reciben los dos
`Configuration.Interface.AdminPanelAccessKeycode`. Para un moderador en una sala, pulsar `M`
alcanza a los dos. Tiene toda la pinta de copiar y pegar: el icono de favorito debería usar
otra tecla, y `AccessKeycode` (`F2`) y `AudioPanelPlayers` (`C`) están **declaradas y sin
usar** en este archivo.

Se comprueba en diez segundos: entra con un rol de moderador en una sala, pulsa `M`, mira si
se abren las dos cosas. No se corrige aquí.

**HECHO — y esto no es un control.** El icono de administración se crea solo si
`canCreateAdminButton()` devuelve verdadero, y esa función **pregunta al servidor**:

```lua
local ok, result = pcall(function() return getUserRol:InvokeServer() end)
if ok and result ~= nil then
	return result >= rolesInfo.moderator
```

Preguntar al servidor está bien. Pero lo que decide es **el cliente**, y lo que decide es si
se dibuja un botón. Esconder un botón no impide nada: quien quiera puede disparar el remote
sin él.

Eso no es un fallo **aquí**: la seguridad de la moderación está donde tiene que estar, en
`ModeratorManager` y en los cuatro controles que documenta
[Permisos de casa](./housing/permissions.md). El motivo de decirlo es que la misma forma —una
puerta de interfaz que parece una comprobación— sí es un problema en
[BUG-CANDIDATE-042](../testing/verification-plan.md#bug-candidate-042), donde detrás no hay
segunda comprobación. Distinguir los dos casos es justamente el trabajo.

**HECHO.** `OpenAdminPanel` no tiene ningún manejador en los `.luau` del repositorio: el
icono lo dispara y lo recoge la interfaz, que vive en un `.rbxm`.

## El resto, por lo que hacen

| Archivo | Líneas | Qué hace |
|---|---|---|
| `NametagMicClient.server` | 258 | El lado cliente de las etiquetas y el micrófono — ver [Nametags](./nametags.md) |
| `Posicionamientos` | 245 | Escalas, áreas y caras; lo usan Tiendas y Decoración — ver [Tiendas](./stores.md) |
| `BusquedaSettings` | 210 | Ajustes del buscador de canciones — ver [Karaoke](./karaoke.md) |
| `UiManager.server` | 165 | Menú principal, monedas y gemas. Su propio encabezado dice «sería bueno juntarlo todo a futuro» |
| `MainPS.server` | 93 | Monta la interfaz de cuadros — ver [Cuadros](./paint.md) |
| `Attributes` | 89 | Lectura de atributos con valores por defecto |
| `messagesManager.server` | 79 | Mensajes emergentes; escucha `Player/ShowMessage` y su `Bindable` gemelo |
| `stats.server` | 68 | Barras de estadísticas (hambre, higiene…) con avisos configurados aparte |
| `SurfacePlacer.server` | 62 | El fantasma de colocación, con `MAX_PLACE_DISTANCE = 15` **en el cliente** |
| `PlayerManager.server` | 58 | Arranca el tutorial de bienvenida |
| `Event` | 43 | Señal propia del proyecto: `Fire`, `Connect`, `Destroy`. La base de `SignalsGame` |
| `CreatePath` | 38 | Construcción de rutas de instancia |
| `DesingData` | 37 | Datos de diseño de tienda |
| `Math` | 35 | Redondeos y formatos |
| `SettingsInfo` | 33 | Descripciones de los ajustes |
| `Disconnects` | 32 | Gemelo de `Shared/GuideService/Disconnects` |
| `PaintActives` | 2 | Un booleano compartido |

Y las carpetas pequeñas:

| Carpeta | Líneas | Qué hace |
|---|---|---|
| `ReferralClient` | 683 | Interfaz de invitaciones — ver [Invitaciones](./referrals.md) |
| `cooking` | 642 | Interfaz de cocina — ver [Barrido](./survey.md) |
| `QuestClient` | 300 | Interfaz de misiones |
| `notificationsManager` | 256 | Cola y presentación de notificaciones; `statsNotifications` lo alimenta |
| `RouletteUIStarter` | 226 | Interfaz de la ruleta — ver [Máquinas](./machines.md#la-ruleta) |
| `ClickDetectorHandler` | 183 | Puente de `ClickDetector` a la rueda de acciones |
| `EconomySystem` | 176 | `Collections` — ver [Datos del jugador](./player-data.md) |
| `Animator` | 166 | Reproducción de animaciones |
| `Ragdoll` | 134 | Ragdoll de cliente |
| `CodeExamples` | 117 | **Ejemplos**, no código de juego |
| `animation` | 109 | Catálogo de animaciones |
| `ProgressBarStarter` | 100 | Barra de progreso reutilizable |
| `WorldSystem` | 46 | Tres archivos pequeños de mundo |

## `SurfacePlacer`, otra vez la distancia

**HECHO.** `MAX_PLACE_DISTANCE = 15` está en el cliente, y es el cliente quien decide si el
fantasma aparece. La comprobación que cuenta es la del servidor, y eso es exactamente lo que
registran [BUG-CANDIDATE-023](../testing/verification-plan.md#bug-candidate-023) y
[BUG-CANDIDATE-025](../testing/verification-plan.md#bug-candidate-025). No añade nada nuevo;
se menciona para que quien busque «dónde está el límite de distancia» lo encuentre y sepa
que no es ahí.

## Qué queda por leer

| Grupo | Estado |
|---|---|
| `InsertService`, `topbar`, `Event`, `Disconnects`, `PaintActives` | **Leídos** |
| `UiManager`, `messagesManager`, `stats`, `SurfacePlacer`, `MainPS` | **En parte** — su papel, sus fuentes de datos y sus esperas |
| Las 13 carpetas pequeñas | **Superficie** — qué son y a qué sistema pertenecen |
| `CodeExamples/` | **No se leerá** — son ejemplos, no código de juego |

## Implementación relacionada

| Aspecto | Código |
|---|---|
| Carga de assets de jugador | `Client/InsertService.luau` — `elimineScrips`, `LoadAsset`, `SetAsset` |
| Barra superior y teclas | `Client/topbar.server.luau`; `GeneralConfiguration.Interface` |
| Puerta de interfaz del panel de admin | `topbar.server.luau`, `canCreateAdminButton` |
| Señal propia | `Client/Event.luau`; la usa `Shared/SignalsGame.luau` |
| Activación de estos scripts | Fuera de este repositorio — [BUG-CANDIDATE-007](../testing/verification-plan.md#bug-candidate-007) |
