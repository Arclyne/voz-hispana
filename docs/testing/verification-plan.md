---
sidebar_position: 1
title: Plan de verificación
---

# Plan de verificación

Esta página registra las cosas que **parecen incorrectas o no están probadas** en el
código, junto con la evidencia de cada una y un plan reproducible para resolverlas.

:::danger Nada de esto es un bug confirmado

Cada entrada es una hipótesis con evidencia, no un informe de defecto. Varias resultarán
ser correctas por diseño en cuanto se ejecuten. **No se ha cambiado ningún código** para
atender nada de esta página; eso queda fuera del alcance de este proyecto de documentación
por indicación expresa.

:::

## Cómo leer una entrada

| Campo | Significado |
|---|---|
| **Clasificación** | Ver la taxonomía de abajo. |
| **Estado de verificación** | `Sin verificar` hasta que alguien ejecute el plan. |
| **Gravedad si se confirma** | El impacto *suponiendo* que la teoría se sostenga. No es una afirmación de que se sostenga. |
| **Confianza** | Cuán probable es que la teoría se sostenga, solo con lectura estática. |
| **Comportamiento observado** | Lo que el código hace de forma demostrable. Siempre **HECHO**. |
| **Teoría** | Lo que podría pasar en ejecución. Siempre **TEORÍA**. |
| **Incógnitas** | Lo que la lectura estática no puede resolver. |

### Taxonomía de clasificación

`Observación` · `Posible bug` · `Bug probable` · `Confirmado por análisis estático` ·
`Requiere verificación en ejecución` · `Requiere pruebas de integración` ·
`Requiere pruebas multijugador` · `Requiere pruebas de concurrencia` ·
`Requiere pruebas de ciclo de vida` · `Requiere pruebas de persistencia` ·
`Requiere inyección de fallos` · `Requiere pruebas de seguridad`

### Tipos de prueba

`Funcional` · `Integración` · `Multijugador` · `Concurrencia` · `Ciclo de vida` ·
`Persistencia` · `Recuperación ante fallos` · `Teleport` · `Seguridad` · `Carga`

:::note Roblox Studio no está disponible en este entorno

Nada de esta página se ha ejecutado. Cada plan está escrito para correrlo a mano en Studio
o en un place de pruebas.

:::

## Índice

| ID | Título | Sistema | Clasificación | Gravedad si se confirma | Confianza |
|---|---|---|---|---|---|
| [001](#bug-candidate-001) | El control de chat de voz falla abierto cuando la comprobación de Roblox da error | Arranque | Observación / Requiere inyección de fallos | Baja | Alta |
| [002](#bug-candidate-002) | Una entrada de presencia puede sobrevivir a su servidor hasta el TTL | World System | Posible bug / Requiere pruebas de ciclo de vida | Media | Media |
| [003](#bug-candidate-003) | Un respawn fallido deja al jugador sin personaje y nada reintenta | Character | Posible bug / Requiere inyección de fallos | Media | Media |
| [004](#bug-candidate-004) | La convergencia tras un anfitrión denegado puede dejar tirados a los jugadores | Casas | Posible bug / Requiere pruebas multijugador | Alta | Baja |
| [005](#bug-candidate-005) | Teleport con un código de acceso cuya instancia ya se apagó | Casas | Requiere pruebas de teleport | Media | Baja |
| [006](#bug-candidate-006) | Una sesión de Studio puede publicar un código de acceso falso en el registro real | Casas | Bug probable / Requiere pruebas de integración | Alta | Media |
| [007](#bug-candidate-007) | El cargador de scripts del cliente no está en este repositorio | Cliente | Observación / Requiere verificación en ejecución | — | Alta |
| [008](#bug-candidate-008) | Una compra concede el artículo antes de cobrarlo | Casas / Economía | Posible bug / Requiere inyección de fallos | Media | Media |
| [009](#bug-candidate-009) | Un fallo al resolver el nombre en el primer arranque bautiza la casa para siempre | Casas | Posible bug / Requiere inyección de fallos | Baja | Alta |
| [010](#bug-candidate-010) | `WorldDataReplicator` se pierde un servidor que ya está `ready` | Casas | Bug probable / Requiere pruebas de ciclo de vida | Media | Media |
| [011](#bug-candidate-011) | El rol `moderator` no puede moderar | Casas | Bug probable / Confirmado por análisis estático | Media | Alta |
| [012](#bug-candidate-012) | Roles, ajustes y baneos de una casa los puede leer cualquier ocupante | Casas | Observación / Requiere pruebas de seguridad | Baja | Alta |
| [013](#bug-candidate-013) | Un servidor de casa sin `TeleportData` deja tirado a su jugador en silencio | Casas | Posible bug / Requiere verificación en ejecución | Media | Media |
| [014](#bug-candidate-014) | Un secreto compartido y un host proxy están escritos a fuego en un archivo versionado | Casas / Seguridad | Confirmado por análisis estático | Alta | Alta |

---

## BUG-CANDIDATE-001

### El control de chat de voz falla abierto cuando la comprobación de Roblox da error

**Sistema:** Arranque · **Clasificación:** Observación / Requiere inyección de fallos
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja · **Confianza:** Alta

**Código relacionado:** `src/ServerScriptService/ImportTemplates.server.luau`, `onPlayerAdded`
**Documentación relacionada:** [Ciclo de vida del jugador](../architecture/player-lifecycle.md)

#### Comportamiento observado — HECHO

```lua
local success, isVoiceEnabled = pcall(function()
    return VoiceChatService:IsVoiceEnabledForUserIdAsync(player.UserId)
end)

if success then
    if not isVoiceEnabled then
        player:Kick("Este juego es exclusivo para usuarios con Chat de Voz. …")
    end
else
    -- Si Roblox falla la red al verificar, quizas conviene que le hagamos kick tambien
    warn("No se pudo verificar el estado del chat de voz de " .. player.Name)
end
```

Tres ramas: voz desactivada → expulsión; voz activada → se permite; **la comprobación dio
error → se permite**.

#### Por qué puede ser un problema

Voz Hispana es exclusivo de chat de voz por diseño, y este es el único sitio donde se
aplica ese requisito. La tercera rama admite a un jugador cuya elegibilidad nunca se llegó
a establecer.

#### Teoría — TEORÍA

Durante una incidencia del servicio de voz de Roblox,
`IsVoiceEnabledForUserIdAsync` fallaría para muchos jugadores a la vez y la puerta los
admitiría a todos mientras durase.

#### Evidencia

El comentario del código en la rama de fallo —*«quizas conviene que le hagamos kick
tambien»*— muestra que el autor consideró expulsar aquí y lo dejó abierto. Es una
**decisión abierta registrada**, no un descuido, y por eso se clasifica como Observación.

#### Incógnitas

- La tasa real de fallo de `IsVoiceEnabledForUserIdAsync`.
- Qué comportamiento quiere el equipo. Fallar cerrado durante una caída de Roblox dejaría
  el juego injugable; fallar abierto admite jugadores no elegibles. Ambas posturas son
  defendibles.

#### Escenario de ejemplo

1. Los servicios de voz de Roblox se degradan.
2. Entran jugadores. Todos los `pcall` devuelven `false`.
3. Se admite a todos, incluidos los que tienen el chat de voz desactivado.

#### Esperado frente a posible real

| Esperado | Posible real |
|---|---|
| Solo hay jugadores con voz activada | Durante la incidencia hay jugadores sin chat de voz |

#### Plan de verificación — *Recuperación ante fallos*, *Funcional*

1. En un place de pruebas, apunta temporalmente la comprobación a un stub que lance error.
   **No modifiques el script publicado**: cópialo a un place de borrador.
2. Entra con dos cuentas, una con voz activada y otra sin ella.
3. Observa que se admite a ambas y que el `warn` aparece en el log del servidor.
4. Repite con el servicio real para confirmar que la ruta de expulsión sigue funcionando.

**Pasa:** el equipo confirma que fallar abierto es la política deseada, y queda
documentado.
**Falla:** fallar abierto no es lo deseado — en cuyo caso esto pasa a ser una decisión de
producto, no un defecto que arreglar en silencio.

**Instrumentación sugerida:** contar los fallos de `pcall` por hora con una etiqueta de log
propia, para conocer la frecuencia real antes de que nadie cambie la política.

---

## BUG-CANDIDATE-002

### Una entrada de presencia puede sobrevivir a su servidor hasta el TTL

**Sistema:** World System · **Clasificación:** Posible bug / Requiere pruebas de ciclo de vida
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Media

**Código relacionado:** `Core/ServerStorage/WorldSystem/ServerPresence.luau` — `Cleanup`,
`safeRemove`, `isThrottled`
**Funciones relacionadas:** [`ServerPresence:Cleanup`](/api/ServerPresence),
[`ServerPresence.SafeGet`](/api/ServerPresence)
**Documentación relacionada:** [Ciclo de vida del servidor](../architecture/server-lifecycle.md)

#### Comportamiento observado — HECHO

- La entrada del registro se escribe con `ACTIVE_TTL = 120` segundos y se refresca cada 30.
- `Cleanup` la elimina, y solo se llega desde `game:BindToClose` (o, en las casas, desde la
  ruta `onDenied`).
- `safeRemove` reintenta hasta `MAX_RETRIES = 6` veces con backoff exponencial, pero
  **abandona la eliminación por completo** cuando MemoryStore reporta throttling:

```lua
elseif isThrottled(err) then
    throttled = true
    warn("[ServerPresence] RemoveAsync throttled; abandono los reintentos.")
```

#### Por qué puede ser un problema

Entre la muerte de un servidor y la expiración de su entrada, el directorio anuncia un
servidor que ya no existe. A un jugador que lo elija en un navegador se le teletransporta a
un `JobId` muerto.

#### Teoría — TEORÍA

Tres caminos hacia una entrada obsoleta: que `BindToClose` agote su ventana; un crash en el
que no corre nada; o throttling de MemoryStore durante el apagado, donde el abandono es por
diseño. En los tres, la entrada sobrevive hasta su TTL, ≤120 s.

#### Evidencia

El TTL es lo que acota el daño, y el diseño se apoya en él — ver el comentario de `Lease`
sobre que *«El TTL da la liveness»*. `ServerPresence` además desconecta sus conexiones de
jugador antes de eliminar la clave precisamente para que un `PlayerRemoving` tardío no
pueda resucitarla, lo que demuestra que la obsolescencia se tuvo en cuenta.

#### Incógnitas

- Qué hace Roblox con un teleport a un `ServerInstanceId` que ya no existe: ¿un error
  limpio que el llamante pueda presentar, o un fallo feo de cara al usuario?
- Si algún consumidor le muestra ese fallo al jugador.

#### Escenario de ejemplo

1. Dos jugadores están en un servidor público; se apaga de forma abrupta.
2. Antes de 120 s, un tercer jugador abre el navegador de servidores y lo selecciona.
3. `JoinServer` encuentra la entrada, lee `jobId` y llama a `TeleportAsync`.

#### Plan de verificación — *Ciclo de vida*, *Teleport*, *Recuperación ante fallos*

1. Arranca un servidor público; confirma su clave en `UserServerRegistry_Test`.
2. Fuérzalo a cerrar sin apagado ordenado.
3. Sondea el mapa cada 10 s y anota cuándo desaparece la entrada. Se espera ≤120 s.
4. Dentro de esa ventana, haz que otro jugador seleccione ese servidor.
5. Anota qué devuelve `safeTeleport` y qué ve el jugador.
6. Repite con un apagado normal y confirma que la entrada desaparece de inmediato.

**Pasa:** la entrada se limpia dentro del TTL, y un teleport dentro de la ventana falla con
un mensaje que el jugador entiende.
**Falla:** la entrada sobrevive al TTL, o el teleport se cuelga o deja al jugador en un
estado roto.

**Instrumentación sugerida:** registrar `serverKey`, `os.time()` y el desenlace al principio
y al final de `Cleanup`, y registrar cada fallo de `safeTeleport` con su motivo.

---

## BUG-CANDIDATE-003

### Un respawn fallido deja al jugador sin personaje y nada reintenta

**Sistema:** Character · **Clasificación:** Posible bug / Requiere inyección de fallos
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Media

**Código relacionado:** `Core/…/ServerScripts/playerManager.server.luau` — `respawnPlayer`,
`onCharacterAdded`
**Documentación relacionada:** [Ciclo de vida del Character](../architecture/character-lifecycle.md)

#### Comportamiento observado — HECHO

```lua
task.delay(RESPAWN_DELAY, function()
    if player.Parent ~= Players then respawning[player] = nil; return end
    local ok, err = pcall(function() player:LoadCharacterAsync() end)
    if not ok then warn("[playerManager] Error respawneando a", player.Name, err) end
    respawning[player] = nil
end)
```

`Humanoid.Died` se conecta con `:Once`, así que no volverá a dispararse para el personaje
muerto. `playersLoaded[player]` sigue en `true`, y la ruta de petición rechaza un
`LoadCharacterRequest` del cliente mientras lo esté.

#### Por qué puede ser un problema

Si `LoadCharacterAsync` lanza error, el fallo se avisa y se limpia el flag, pero nada
reintenta. El manejador de muerte no puede volver a dispararse, y la ruta de petición del
cliente está cerrada por `playersLoaded`.

#### Teoría — TEORÍA

Un jugador cuya llamada de respawn falle se queda tirado sin personaje hasta que vuelva a
entrar.

#### Evidencia

`respawnPlayer` no tiene bucle de reintento.
`canProcessLoadCharacterRequest` rechaza cuando `playersLoaded[player]` está puesto, y
`respawnPlayer` nunca lo limpia — solo lo limpia la ruta de *entrada*, y solo cuando falla
*su propio* `LoadCharacterAsync`.

#### Incógnitas

- Con qué frecuencia lanza error `LoadCharacterAsync` para un jugador que sigue en el
  servidor.
- Si otro sistema (posiblemente en un asset binario) también genera personajes y taparía
  esto.

#### Escenario de ejemplo

1. El jugador muere. `Humanoid.Died` se dispara una vez.
2. `respawnPlayer` espera 3 s y llama a `LoadCharacterAsync`, que lanza error.
3. Se registra el aviso; se limpia `respawning`; `playersLoaded` sigue en `true`.
4. El cliente pide un personaje; `canProcessLoadCharacterRequest` lo rechaza como
   «Character ya solicitado/cargado».

#### Esperado frente a posible real

| Esperado | Posible real |
|---|---|
| El jugador reaparece, quizá tras un reintento | El jugador se queda sin personaje hasta volver a entrar |

#### Plan de verificación — *Recuperación ante fallos*, *Ciclo de vida*

1. En una copia de borrador del place, envuelve `LoadCharacterAsync` para que lance error
   solo en el primer respawn.
2. Entra, muere y observa.
3. Confirma si acaba apareciendo un personaje, y por qué vía.
4. Desde el cliente, dispara `LoadCharacterRequest` y confirma que se rechaza.

**Pasa:** el jugador se recupera, por reintento o por otro sistema.
**Falla:** no aparece ningún personaje y la petición del cliente se rechaza.

**Instrumentación sugerida:** registrar cada fallo de `LoadCharacterAsync` con el jugador y
la vía (entrada frente a respawn), y registrar los `LoadCharacterRequest` rechazados con su
motivo — hoy dos de los cuatro motivos de rechazo son silenciosos por diseño.

---

## BUG-CANDIDATE-004

### La convergencia tras un anfitrión denegado puede dejar tirados a los jugadores

**Sistema:** Casas · **Clasificación:** Posible bug / Requiere pruebas multijugador
**Estado:** Sin verificar · **Gravedad si se confirma:** Alta · **Confianza:** Baja

**Código relacionado:** `PlayerHouses/ServerScriptService/PlayerWorld_Init.lua.server.luau` —
`convergeToOwner`; `DataKit/Store.luau` — `_resolveOwnership`
**Documentación relacionada:** [Arquitectura → Servidores reservados](../architecture/reserved-servers.md)

:::note La confianza es Baja a propósito

El mecanismo que esta entrada cuestiona es la *mitigación*, no un hueco. La carrera de
doble reserva está genuinamente protegida — ver
[Servidores reservados](../architecture/reserved-servers.md). Esta entrada solo pregunta si
la ruta de último recurso se comporta bien bajo carga.

:::

#### Comportamiento observado — HECHO

Cuando arranca una segunda instancia de casa para un mundo que ya está hosteado, su `Store`
tiene `onConflict = "deny"`, así que `_resolveOwnership` dispara `onDenied(owner, ownerMeta)`.
`PlayerWorld_Init` entonces:

1. limpia su presencia;
2. llama a `convergeToOwner`, que teletransporta a todos los presentes al
   `ownerMeta.accessCode`, reintentando `CONVERGE_ATTEMPTS = 3` veces con
   `CONVERGE_RETRY = 0,5` s;
3. **expulsa** a todos si los tres intentos fallan:

```lua
for _, plr in players do
    plr:Kick("[Error] This world is already hosted. Please try joining again.")
end
```

También conecta `Players.PlayerAdded` para reenviar también a los que lleguen después.

#### Por qué puede ser un problema

Tres intentos en 1,5 s es un presupuesto corto para un teleport, y el plan B es una
expulsión.

#### Teoría — TEORÍA

Bajo throttling de teleports, o si `ownerMeta` está desfasado cuando corre la convergencia,
los intentos se agotan y se expulsa a jugadores que tenían derecho a entrar.

#### Evidencia

`convergeToOwner` devuelve `false` sin intentar nada cuando `ownerMeta` está mal formado o
cuando `ownerMeta.accessCode == selfAccessCode`; en ese caso corre `onFailedServer` y
`ServerPresence.KickAll` echa a todos. Hay por tanto dos rutas distintas hacia una
expulsión, no una.

#### Incógnitas

- La tasa real de éxito de `TeleportAsync` entre dos servidores reservados bajo carga.
- Con qué frecuencia ocurre de verdad la carrera residual: requiere que dos lobbies se
  entrelacen dentro de una ventana de milisegundos.

#### Escenario de ejemplo

1. El lobby A hace staging de la casa `123_playaRoom` y reserva la instancia X.
2. La instancia X arranca y reclama el lease.
3. La comprobación de «hosted» del lobby B corrió *justo* antes del claim de X, así que B
   también hace staging, reserva la instancia Y y manda allí a su jugador.
4. Y arranca, es denegada, e intenta converger su jugador hacia X.
5. Los tres teleports fallan.
6. Se expulsa al jugador.

#### Plan de verificación — *Multijugador*, *Concurrencia*, *Teleport*

1. Dos cuentas en dos servidores de lobby distintos, mismo `HouseId`, aún sin hostear.
2. Dispara `JoinServer` en ambas lo más simultáneamente posible; repite 20 veces, variando
   el desfase de 0 a 500 ms.
3. Por cada ejecución anota: cuántas instancias reservadas se crearon, si alguna instancia
   registró `[PlayerWorld] World already hosted`, y dónde acabó cada jugador.
4. Repite 5 ejecuciones más con la red limitada para forzar fallos de teleport.

**Pasa:** ambos jugadores acaban siempre en la misma instancia; ninguna expulsión en las
ejecuciones sin limitación.
**Falla:** persisten dos instancias vivas de la misma casa, o se expulsa a un jugador en
una ejecución sin limitación.

**Instrumentación sugerida:** registrar `serverKey`, `game.JobId`, `accessCode` y
`os.clock()` en cada etapa de `hostWorld` y en cada `onDenied`, para poder correlacionar
ejecuciones entre servidores.

---

## BUG-CANDIDATE-005

### Teleport con un código de acceso cuya instancia ya se apagó

**Sistema:** Casas · **Clasificación:** Requiere pruebas de teleport
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Baja

**Código relacionado:** `WorldManager.server.luau` — `teleportToHost`; `DataKit/Lease.luau`
**Documentación relacionada:** [Arquitectura → Servidores reservados](../architecture/reserved-servers.md)

#### Comportamiento observado — HECHO

La alcanzabilidad de una casa es la entrada de `DataKitLeases` para `World/{key}`, con TTL
de 120 segundos y refresco cada 30. `store:close()` lo libera en un apagado ordenado; una
muerte abrupta lo deja expirar.

Dentro de esa ventana `claimStaged` devuelve `kind = "hosted"` y `WorldManager`
teletransporta al jugador con el `accessCode` de la instancia muerta.

#### Por qué puede ser un problema

Se envía al jugador a una instancia reservada que ya no existe.

#### Teoría — TEORÍA

El comportamiento documentado por Roblox es que teletransportar con un
`ReservedServerAccessCode` cuya instancia se ha apagado **arranca una instancia nueva** con
ese mismo código. Si es así, esto es inocuo: la nueva instancia arranca, encuentra el lease
expirado o expirando, y toma el relevo.

Esta documentación no afirma ese comportamiento, porque no lo establece el código de este
repositorio. Ese es justamente el sentido de la entrada.

#### Incógnitas

- Si el código de acceso de una instancia reservada apagada es realmente reutilizable.
- Qué hace la nueva instancia si arranca mientras el lease *antiguo* aún no ha expirado:
  sería denegada e intentaría converger hacia un dueño muerto, lo que enlaza de vuelta con
  [BUG-CANDIDATE-004](#bug-candidate-004).

#### Escenario de ejemplo

1. Un servidor de casa corre y luego crashea sin que `BindToClose` llegue a completarse.
2. Antes de 120 s el dueño intenta volver a entrar.
3. `claimStaged` reporta `hosted` con el `accessCode` muerto.
4. Se llama a `TeleportAsync` con él.

#### Plan de verificación — *Teleport*, *Ciclo de vida*, *Recuperación ante fallos*

1. Abre una casa; anota su `accessCode` desde `DataKitLeases`.
2. Fuerza el cierre de la instancia sin apagado ordenado.
3. **De inmediato** (bien dentro de los 120 s), haz que el dueño vuelva a entrar.
4. Anota si arranca una instancia nueva, si conserva el mismo `accessCode`, y si adquiere
   el lease o es denegada.
5. Repite empezando a los 130 s, cuando el lease ya ha expirado con seguridad, como
   control.

**Pasa:** el paso 3 deja al jugador en una casa funcional en ambos tiempos.
**Falla:** el paso 3 da error, se cuelga, o produce una instancia que se deniega a sí misma
de inmediato.

**Instrumentación sugerida:** registrar `accessCode` y `game.JobId` en cada arranque de
casa, y registrar el desenlace de `claimStaged` (`hosted` / `staged` / ganado / fallo de
MemoryStore) en cada `hostWorld`.

---

## BUG-CANDIDATE-006

### Una sesión de Studio puede publicar un código de acceso falso en el registro real

**Sistema:** Casas · **Clasificación:** Bug probable / Requiere pruebas de integración
**Estado:** Sin verificar · **Gravedad si se confirma:** Alta · **Confianza:** Media

**Código relacionado:** `WorldManager.server.luau` — `reserveAccessCode`, `safeTeleport`,
`hostWorld`
**Documentación relacionada:** [Arquitectura → Servidores reservados](../architecture/reserved-servers.md)

#### Comportamiento observado — HECHO

`reserveAccessCode` devuelve un **GUID fabricado** en Studio en vez de reservar:

```lua
local function reserveAccessCode(placeId: number): string?
    if RunService:IsStudio() then
        return HttpService:GenerateGUID(false)
    end
    …
```

`safeTeleport` también se convierte en una operación vacía en Studio:

```lua
if not RunService:IsStudio() then
    … TeleportAsync …
else
    warn("[WorldManager] Teleport ignored in studio")
end
return true, nil
```

Pero la ruta de código **entre** esas dos no es consciente de Studio. `hostWorld` sigue
llamando a `Profiles.World.claimStaged`, y si tiene éxito sigue ejecutando
`claim:setMeta(meta)` y `claim:tryClaim()` — escrituras que van a **MemoryStore**, que es
de ámbito universo y está compartido con los servidores reales.

#### Por qué puede ser un problema

MemoryStore y DataStore no están aislados por entorno. Una sesión de Studio con acceso a
API activado escribe en el mismo mapa `DataKitLeases` que lee producción.

#### Teoría — TEORÍA

Un desarrollador probando en Studio hace staging de una clave de casa y publica una entrada
`staged/World/{key}` cuyo `accessCode` es un GUID aleatorio que no reserva nada. Durante el
TTL de staging (30 s), a un jugador real que pida esa misma casa se le dice que el mundo
está `staged`, sondea `peekStaged`, recibe el código falso, y se le teletransporta con un
`ReservedServerAccessCode` que `TeleportService` nunca emitió.

#### Evidencia

- `reserveAccessCode` fabrica el código — **HECHO**.
- `claimStaged` escribe en el MemoryStore real sin ninguna guarda de Studio — **HECHO**, y
  la presencia de guardas `RunService:IsStudio()` a ambos lados demuestra que el autor era
  consciente del entorno precisamente aquí y no protegió este paso.
- La clave de staging solo lleva el espacio de nombres del perfil y el id
  (`staged/World/{userId}_{room}`), no el entorno — **HECHO**.
- `ACTIVE_MAP_NAME = "UserServerRegistry_Test"` — el sufijo `_Test` sugiere que el mapa de
  *presencia* está al menos separado por convención. El nombre del mapa de leases,
  `DataKitLeases`, no lleva tal sufijo.

#### Incógnitas

- Si «Enable Studio Access to API Services» está realmente activado para este universo. Si
  está desactivado, las llamadas a MemoryStore fallan en Studio y el escenario entero se
  cae — por eso la confianza es Media y no Alta.
- Si alguna vez se prueba en Studio contra el universo de producción en vez de contra uno
  separado.

#### Escenario de ejemplo

1. Un desarrollador abre el place de casa en Studio con acceso a API activado.
2. Un jugador entra en la sesión local; `PlayerWorld_Init` usa la clave de reserva de
   Studio `"{UserId}_defaultRoom"`.
3. En otra sesión de Studio sobre el place de lobby, se invoca `JoinServer` para esa clave.
4. `claimStaged` gana, `reserveAccessCode` devuelve un GUID, y se publica.
5. Antes de 30 s, un jugador real pide la misma casa y recibe el código fabricado.

#### Esperado frente a posible real

| Esperado | Posible real |
|---|---|
| Probar en Studio no puede afectar a jugadores reales | A un jugador real se le teletransporta con un código de acceso que no reserva nada |

#### Plan de verificación — *Integración*, *Seguridad*, *Teleport*

1. Confirma si el acceso a API está activado para el universo, y si las pruebas en Studio
   apuntan al universo de producción. **Si ambas respuestas son no, cierra esta entrada
   como no aplicable y déjalo registrado.**
2. Si sí: en Studio, invoca `JoinServer` para una clave de casa que poseas. Lee
   `staged/World/{key}` de `DataKitLeases` con un script aparte.
3. Comprueba si existe una entrada y si su `accessCode` es un GUID en vez de un código
   reservado real.
4. En un servidor real, antes de 30 s, pide la misma casa y anota el desenlace.

**Pasa:** desde Studio no se escribe ninguna entrada de staging, o la petición real no se ve
afectada.
**Falla:** un código fabricado llega a un jugador real.

**Instrumentación sugerida:** registrar `RunService:IsStudio()`, `game.JobId` y la
procedencia del código (reservado frente a generado) en cada `reserveAccessCode`, para que
las entradas de origen Studio sean identificables en el registro.

---

## BUG-CANDIDATE-007

### El cargador de scripts del cliente no está en este repositorio

**Sistema:** Cliente · **Clasificación:** Observación / Requiere verificación en ejecución
**Estado:** Sin verificar · **Gravedad si se confirma:** — · **Confianza:** Alta

**Código relacionado:** `src/ServerScriptService/InitScripts.server.luau`;
`Core/ReplicatedStorage/Events/GameLoad/InitScriptsRequest.model.json`
**Documentación relacionada:** [Ciclo de vida del cliente](../architecture/client-lifecycle.md)

Esto no es un defecto sospechado. Es un **hueco de documentación** registrado en el mismo
formato porque necesita el mismo tipo de respuesta en ejecución.

#### Comportamiento observado — HECHO

- Los 27 scripts con `RunContext = "Client"` de `Core/ReplicatedStorage/Client` se
  distribuyen con `Disabled: true`.
- `InitScripts.server.luau` excluye explícitamente los descendientes de
  `ReplicatedStorage.Client`.
- Ningún archivo `.luau` de este repositorio asigna `Enabled = true` a un `Script` o
  `LocalScript`.
- Existe un `RemoteEvent` llamado `InitScriptsRequest` en `Events/GameLoad`, y **ningún**
  archivo `.luau` de aquí lo referencia.
- Tres de los cuatro scripts etiquetados `IgnoreAutoEnable` están en
  `ReplicatedStorage/Client` — una carpeta que el barrido del servidor ya omite en bloque,
  así que la etiqueta es redundante para el cargador del servidor y solo tiene sentido para
  uno *de cliente*.
- La etiqueta `IgnoreLoader`, en ambos scripts de arranque, tampoco tiene consumidor aquí.

#### Teoría — TEORÍA

Existe un cargador del lado cliente fuera de este repositorio —lo más plausible, dentro de
`src/StarterPlayer/StarterPlayerScripts.rbxm`— que espera a `InitAfterTemplates`, activa
los scripts de cliente, respeta `IgnoreAutoEnable`, y probablemente usa `InitScriptsRequest`
para coordinarse con el servidor.

#### Por qué importa

Hasta que se confirme, [Ciclo de vida del cliente](../architecture/client-lifecycle.md)
está incompleto por construcción, y cualquier afirmación sobre el orden de arranque del
cliente carece de fundamento.

#### Plan de verificación — *Funcional* — unos dos minutos

1. Abre el place en Roblox Studio.
2. Inspecciona `StarterPlayer.StarterPlayerScripts` y
   `StarterPlayer.StarterCharacterScripts` en el Explorador.
3. Busca en todo el DataModel `Enabled = true`, `InitScriptsRequest` e
   `IgnoreAutoEnable`.
4. Anota cada script encontrado, con su ruta completa y su código.

**Pasa:** se encuentra el cargador y se puede documentar.
**Falla:** no existe tal cargador — lo cual sería un hallazgo bastante más grave, porque
entonces los scripts de cliente no correrían nunca, y necesitaría su propia entrada.

---

## BUG-CANDIDATE-008

### Una compra concede el artículo antes de cobrarlo

**Sistema:** Casas / Economía · **Clasificación:** Posible bug / Requiere inyección de fallos
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Media

**Código relacionado:** `Core/…/ServerScripts/ShopServerSystem.server.luau`, `ProcessPurchase`;
`Core/…/ServerScripts/PlayerDataReplicator.server.luau`, `buySlot`
**Documentación relacionada:** [Casas → Identidad y propiedad](../systems/housing/identity.md)

#### Comportamiento observado — HECHO

Las dos rutas de compra mutan el perfil del jugador **antes** de descontar la moneda.

En `ProcessPurchase`:

```lua
store:update(function(current)
    if not table.find(current.rooms, itemIdToBuy) then
        table.insert(current.rooms, itemIdToBuy)
    end
    return current
end)
UpdateHouses:FireClient(player, store:get().rooms)
if not RunService:IsStudio() then
    collections.SetAmount(player, value, tonumber(value.Value) - finalPrice)
end
```

`buySlot` tiene la misma forma: `store:update(...)` y luego `collections.SetAmount(...)`.

#### Por qué puede ser un problema

Las dos escrituras no son atómicas ni están ordenadas defensivamente. Cualquier cosa que
impida completar la segunda deja al jugador con un artículo por el que no se le cobró.

#### Teoría — TEORÍA

Si `collections.SetAmount` lanza error, cede el hilo más allá de un apagado del servidor, o
escribe en un store que falla, la room se queda en `rooms` —que `DataKit` persistirá en su
siguiente autoguardado— mientras la moneda queda intacta.

#### Evidencia

- El orden es directo e inequívoco — **HECHO**.
- La comprobación de fondos lee `value.Value` *antes* del update y el descuento recalcula
  desde `tonumber(value.Value)` *después*, así que las dos lecturas están separadas por una
  llamada que cede el hilo — **HECHO**.
- `buySlot` lleva un comentario explícito que muestra que el autor razonó sobre invocaciones
  concurrentes (*«dos invokes simultáneos leerían el mismo `slots` y cobrarían dos veces»*)
  y añadió una guarda por jugador, pero no reordenó la concesión y el cobro — **HECHO**. Por
  eso la confianza es Media y no Alta: el ángulo de concurrencia sí se consideró, así que el
  orden podría ser una decisión deliberada de «conceder primero, nunca perder una compra».

#### Incógnitas

- Si `collections.SetAmount` puede fallar. `Collections` no se ha leído.
- Si la moneda vive en el mismo store de `DataKit` que `rooms`. Si es así, ambas escrituras
  caen en un mismo guardado y la ventana es mucho menor de lo que parece.

#### Escenario de ejemplo

1. Un jugador con exactamente 4 000 Coins compra `playaRoom` por 4 000.
2. `store:update` inserta la room; se le dice al cliente que ya la posee.
3. `SetAmount` falla.
4. El jugador posee la casa y sigue teniendo 4 000 Coins.

#### Esperado frente a posible real

| Esperado | Posible real |
|---|---|
| O ocurren la concesión y el cobro, o no ocurre ninguno | El artículo se concede y no se paga |

#### Plan de verificación — *Recuperación ante fallos*, *Persistencia*, *Funcional*

1. Lee primero `Client/EconomySystem/Collections.luau` y establece dónde se guarda la
   moneda. **Si está en el mismo store de `DataKit` que `rooms`, reevalúa: la ventana puede
   ser despreciable.**
2. En un place de borrador, sustituye `collections.SetAmount` por un stub que lance error.
3. Compra una casa. Confirma si la room aparece en `rooms` y si la moneda cambió.
4. Vuelve a entrar para confirmar qué persistió.
5. Repite con `buySlot`.

**Pasa:** la concesión no persiste sin el cobro.
**Falla:** el jugador se queda el artículo y la moneda.

**Instrumentación sugerida:** registrar un único apunte de compra —jugador, artículo,
precio, saldo antes, saldo después— escrito después de ambas operaciones, para poder
detectar descuadres de forma agregada.

---

## BUG-CANDIDATE-009

### Un fallo al resolver el nombre en el primer arranque bautiza la casa para siempre

**Sistema:** Casas · **Clasificación:** Posible bug / Requiere inyección de fallos
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja · **Confianza:** Alta

**Código relacionado:** `PlayerHouses/ServerScriptService/PlayerWorld_Init.lua.server.luau`,
`getRoomDisplayName`; `PlayerHouses/ServerScriptService/WorldService.luau`, `start`
**Documentación relacionada:** [Casas → Persistencia](../systems/housing/persistence.md)

#### Comportamiento observado — HECHO

```lua
local function getRoomDisplayName(ownerId: number, roomName: string): string
    local success, playerName = pcall(function()
        return Players:GetNameFromUserIdAsync(ownerId)
    end)
    if success then
        return ("%s's %s"):format(playerName, HousesInfo[roomName].name)
    else
        return "default Name"
    end
end
```

y el valor se escribe una sola vez, protegido por el centinela:

```lua
store:update(function(data)
    if data.settings.OwnerId == 0 then
        data.settings.OwnerId = config.ownerId
        data.settings.Name = config.displayName
    end
    return data
end)
```

#### Por qué puede ser un problema

La inicialización es de un solo disparo por diseño. Un fallo transitorio de Roblox durante
el primerísimo arranque de una casa queda por tanto escrito en estado permanente, y ningún
arranque posterior lo corrige.

#### Teoría — TEORÍA

Una casa abierta por primera vez durante un hipo de la API de Roblox se llama
`"default Name"` durante el resto de su existencia, en el navegador y en el directorio,
hasta que su dueño la renombre a mano.

#### Evidencia

La guarda `OwnerId == 0` es todo el mecanismo — **HECHO**. Como `OwnerId` se escribe en la
misma sentencia que `Name`, un arranque con éxito pero con la resolución de nombre fallida
cierra la puerta a ambos. La confianza es Alta porque no hace falta ninguna coincidencia de
tiempos: basta una llamada fallida en un momento.

#### Incógnitas

- La tasa real de fallo de `GetNameFromUserIdAsync`.
- Si el dueño afectado se daría cuenta y la renombraría.

#### Escenario de ejemplo

1. Un jugador compra `VistaLujosaRoom` y la abre por primera vez.
2. `GetNameFromUserIdAsync` falla.
3. `settings.Name` queda en `"default Name"` y `OwnerId` con el id correcto.
4. Todos los arranques posteriores encuentran `OwnerId ~= 0` y se saltan la inicialización.

#### Esperado frente a posible real

| Esperado | Posible real |
|---|---|
| La casa se llama `"<Dueño>'s Casa Vista Lujosa"` | Se llama `"default Name"` para siempre |

#### Plan de verificación — *Recuperación ante fallos*, *Persistencia*

1. En un place de borrador, sustituye `Players:GetNameFromUserIdAsync` por un stub que lance
   error.
2. Abre una casa que no se haya abierto nunca.
3. Confirma que `settings.Name == "default Name"` y que `OwnerId` es correcto.
4. Quita el stub, apaga y vuelve a abrir.
5. Confirma que el nombre **no** se corrige.
6. Confirma que `SetWorldName` sigue funcionando.

**Pasa:** el nombre se corrige en un arranque posterior, o el fallo tampoco escribe
`OwnerId`.
**Falla:** la casa conserva `"default Name"` después del paso 5.

**Instrumentación sugerida:** registrar cada inicialización de primer arranque con el id del
dueño, el nombre resuelto, y si la resolución tuvo éxito.

---

## BUG-CANDIDATE-010

### `WorldDataReplicator` se pierde un servidor que ya está `ready`

**Sistema:** Casas · **Clasificación:** Bug probable / Requiere pruebas de ciclo de vida
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Media

**Código relacionado:** `PlayerHouses/ServerScriptService/WorldDataReplicator.server.luau`
(final del archivo); compárese con
`PlayerHouses/ServerScriptService/ModeratorManager.server.luau`
**Documentación relacionada:** [Casas → Ciclo de vida del servidor](../systems/housing/server-lifecycle.md)

#### Comportamiento observado — HECHO

`WorldDataReplicator` cablea toda su replicación dentro de un listener de cambio, y nunca
comprueba el valor actual:

```lua
ServerInfo:GetAttributeChangedSignal("status"):Connect(function()
    if ServerInfo:GetAttribute("status") ~= "ready" then return end
    if replicationWired then return end
    replicationWired = true
    for _, storeName in ReplicatedDataStores do pushStore(storeName) end
    WorldService.OnStoreUpdated:Connect(function(storeName) … end)
end)
```

`ModeratorManager`, en la misma carpeta, maneja ambos casos:

```lua
if ServerInfo:GetAttribute("status") == "ready" then
    onReady()
else
    local conn
    conn = ServerInfo:GetAttributeChangedSignal("status"):Connect(function() … end)
end
```

#### Por qué puede ser un problema

Si el atributo ya vale `"ready"` cuando `WorldDataReplicator` arranca, la señal no vuelve a
dispararse para esa transición, `replicationWired` se queda en `false`, y **dos** cosas no
ocurren nunca: el envío inicial de ajustes/roles/baneos a los clientes privilegiados, y la
suscripción a `WorldService.OnStoreUpdated` que los mantiene al día.

#### Teoría — TEORÍA

El dueño abre la interfaz de administración de la casa y no ve nada —ni roles, ni baneos, ni
ajustes— y los cambios que hagan otros nunca aparecen. Los *remotes* administrativos siguen
funcionando, porque son `RemoteFunction` enlazados en el ámbito del archivo, fuera del
listener. Así que el síntoma es «el panel está vacío» y no «la administración está rota».

#### Evidencia

- La asimetría entre dos archivos de la misma carpeta resolviendo el mismo problema —
  **HECHO**, y evidencia fuerte de que la omisión no es intencionada.
- Los remotes se enlazan fuera del listener mientras la replicación está dentro — **HECHO** —
  que es lo que hace el síntoma parcial en vez de total.
- Alcanzabilidad: `WorldDataReplicator` se distribuye con `Disabled: true` y lo activa
  `InitScripts`, que hace `task.wait(1)` más un recorrido completo de
  `game:GetDescendants()`. Un servidor de casa reservado arranca *porque* un jugador se está
  teletransportando a él, y `PlayerWorld_Init` arranca la capa de presencia en cuanto ese
  jugador llega. Las dos secuencias se solapan. **INFERENCIA**, y la razón de que la
  confianza sea Media y no Alta: el orden es plausible pero no está probado.

#### Incógnitas

- Si el barrido de activación termina de forma fiable antes de que el primer jugador
  dispare `PlayerWorld_Init`, en un servidor reservado real.
- Si el orden de `GetDescendants()` hace que uno de los dos scripts vaya sistemáticamente
  antes.

#### Escenario de ejemplo

1. Un servidor de casa reservado arranca con un jugador ya teletransportándose.
2. `InitScripts` empieza su espera de 1 segundo.
3. Llega el jugador; `PlayerWorld_Init` —ya activado— inicializa, y la presencia se reporta
   lista. `ServerInfo.status` pasa a `"ready"`.
4. `InitScripts` termina y activa `WorldDataReplicator`.
5. Su listener espera una transición que ya ocurrió.

#### Esperado frente a posible real

| Esperado | Posible real |
|---|---|
| El panel de administración del dueño se rellena y se mantiene al día | Está vacío y nunca se actualiza |

#### Plan de verificación — *Ciclo de vida*, *Integración*

1. Añade una línea de log al principio de `WorldDataReplicator`, y dentro de su listener,
   registrando `ServerInfo:GetAttribute("status")` y `os.clock()`.
2. Añade lo mismo al principio de `ModeratorManager` y en `onHouseStarted`.
3. Abre una casa 20 veces y anota el orden en cada una.
4. En las ejecuciones donde el estado ya fuera `"ready"`, confirma si la interfaz de
   administración se rellena.
5. Fuerza el caso retrasando la activación de `PlayerWorld_Init` respecto a la de
   `WorldDataReplicator`.

**Pasa:** la replicación se cablea en todas las ejecuciones.
**Falla:** cualquier ejecución en la que el estado ya fuera `"ready"` y la replicación no se
cableara nunca.

**Instrumentación sugerida:** registrar `replicationWired` y el estado observado al arrancar
`WorldDataReplicator` — una sola línea basta para resolver esto en producción.

---

## BUG-CANDIDATE-011

### El rol `moderator` no puede moderar

**Sistema:** Casas · **Clasificación:** Bug probable / Confirmado por análisis estático
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Alta

**Código relacionado:** `PlayerHouses/ServerScriptService/WorldDataReplicator.server.luau`,
`canModerate`, `pushStore`
**Documentación relacionada:** [Casas → Permisos](../systems/housing/permissions.md)

#### Comportamiento observado — HECHO

```lua
local function canModerate(data: any, player: Player): boolean
    if data.settings.OwnerId == player.UserId then
        return true
    end
    return roleFor(data, player.UserId) > RolesInfo["moderator"]
end
```

`RolesInfo.moderator == 48`, así que un jugador cuyo rol sea exactamente `moderator` evalúa
`48 > 48` → `false`.

En el **mismo archivo**, la replicación usa `>=`:

```lua
if role >= RolesInfo["moderator"] or data.settings.OwnerId == plr.UserId then
```

Y la comprobación de entrada de `ModeratorManager` también usa `>=`:

```lua
local function hasAtLeastGuestRole(rolesMap, userId): boolean
    local val = rolesMap and rolesMap[tostring(userId)] or 0
    return val >= getGuestThreshold()
end
```

#### Por qué puede ser un problema

Dos comparaciones contra la misma escala, en el mismo archivo, no coinciden. Un `moderator`
**recibe** los contenidos de roles, ajustes y baneos —así que la interfaz de administración
se le rellena— pero todos los remotes administrativos lo rechazan.

#### Teoría — TEORÍA

A un jugador con `moderator` se le muestra un panel que parece funcional y en el que toda
acción falla en silencio. `SetBan`, `SetUserRole` y `SetWorldName` devuelven `nil` al
rechazar, y `togglePrivacity` solo avisa en el servidor, así que el cliente no recibe ningún
error que mostrar.

#### Evidencia

- La división `>` / `>=` dentro de un mismo archivo — **HECHO**. Es el núcleo del hallazgo.
- `canModerate` lleva el *nombre* del rol que excluye — **HECHO**.
- `designer` (47) y `guest` (46) también quedan excluidos, lo que presumiblemente sí es
  intencionado; la escala solo tiene sentido si algún peldaño es el umbral administrativo, y
  `moderator` es al que apunta el nombre.

Se clasifica como **Confirmado por análisis estático** para la *inconsistencia*, que es
segura, y como **Bug probable** para la *intención*, que no lo es: el arreglo podría ser
tanto renombrar la función como mover el umbral. Eso es una decisión de producto.

#### Un segundo hallazgo relacionado

`SetUserRole` comprueba que el llamante pueda moderar y que el objetivo no sea el dueño.
**No** comprueba que el llamante supere al rol que se está concediendo:

```lua
if targetUserId == data.settings.OwnerId then return false, "CannotEditOwner" end
if roleName ~= "none" and RolesInfo[roleName] == nil then return false, "InvalidRole" end
```

Así que un `admin` (49) puede conceder `coOwner` (50), a otro jugador o a sí mismo. Si es
intencionado es una cuestión de producto; se registra aquí porque pertenece a la misma
revisión del modelo de roles.

#### Incógnitas

- Cuál de los dos comportamientos quiere el equipo para `moderator`.
- Si la escalada de `admin` a `coOwner` es deliberada.

#### Escenario de ejemplo

1. El dueño concede `moderator` a un amigo.
2. El amigo abre el panel y ve las listas de roles y baneos — `pushStore` se las envió.
3. Intenta banear a alguien. `SetBan` devuelve `nil`. No pasa nada, sin error.

#### Esperado frente a posible real

| Esperado | Posible real |
|---|---|
| Un `moderator` puede banear y gestionar roles | Ve la interfaz y toda acción falla en silencio |

#### Plan de verificación — *Funcional*, *Seguridad*

1. En una casa de pruebas, concede `moderator` a una segunda cuenta.
2. Confirma que el panel de administración se le rellena.
3. Intenta `SetBan`, `SetUserRole`, `SetWorldName`, `togglePrivacity`. Anota cada resultado.
4. Repite con `admin` (49) como control — deberían funcionar todos.
5. Como `admin`, concede `coOwner` a una tercera cuenta, y a ti mismo. Anota si se permite.

**Pasa:** el paso 3 funciona, o el panel se le oculta correctamente a un moderador.
**Falla:** se muestra el panel y toda acción se rechaza.

**Instrumentación sugerida:** registrar cada llamada administrativa rechazada con el rol del
llamante y el umbral — eso haría aflorar el descuadre de inmediato en producción.

---

## BUG-CANDIDATE-012

### Roles, ajustes y baneos de una casa los puede leer cualquier ocupante

**Sistema:** Casas · **Clasificación:** Observación / Requiere pruebas de seguridad
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja · **Confianza:** Alta

**Código relacionado:** `PlayerHouses/ServerScriptService/WorldDataReplicator.server.luau` —
`GetRolesRf`, `GetWorldSettingRF`, `GetBansRF`, `GetUserRolRF`
**Documentación relacionada:** [Casas → Permisos](../systems/housing/permissions.md)

#### Comportamiento observado — HECHO

Los cuatro remotes de lectura no tienen comprobación de permisos:

```lua
GetRolesRf.OnServerInvoke = function(_player: Player)
    local data = WorldService.get()
    return data and data.roles or nil
end
```

Nótese el `_player`: el llamante se ignora explícitamente. `GetWorldSettingRF` y `GetBansRF`
tienen la misma forma. `GetUserRolRF` acepta un `userId` arbitrario y devuelve el rol de ese
usuario.

Mientras tanto, la ruta de **envío** sí está restringida:

```lua
if role >= RolesInfo["moderator"] or data.settings.OwnerId == plr.UserId then
    WorldDataUpdated:FireClient(plr, storeName, payload)
end
```

#### Por qué puede ser un problema

Los mismos tres contenidos están restringidos al enviarse y sin restringir al consultarse.
Lo que sea que protegiera la restricción de envío se puede obtener invocando directamente el
`RemoteFunction` correspondiente.

#### Teoría — TEORÍA

Cualquier jugador dentro de una casa puede leer su lista completa de baneos y su tabla de
roles — un conjunto de ids de usuario y sus niveles de privilegio. No es sensible como lo
serían unas credenciales, pero es información que el código demostrablemente pretendía
restringir.

#### Evidencia

- La asimetría entre el listón de rol de `pushStore` y la ausencia de listón en los remotes
  de lectura — **HECHO**. Por eso se registra: la intención de restringir es visible.
- `_player` lleva guion bajo inicial, la convención de Luau para un parámetro
  deliberadamente sin usar — **HECHO**. Así que la omisión es al menos explícita.

#### Incógnitas

- Si restringir las lecturas se pretendió alguna vez, o si el listón de `pushStore` existe
  solo para no enviar contenidos que nadie va a usar.

#### Escenario de ejemplo

1. Un jugador entra en una casa pública en la que no tiene ningún rol.
2. Desde la consola del cliente, invoca `GetBans` y `GetRoles`.
3. Recibe la lista de baneos y la tabla de roles completas.

#### Plan de verificación — *Seguridad*, *Funcional*

1. Entra en una casa como jugador sin rol.
2. Invoca los cuatro remotes de lectura desde el cliente.
3. Anota qué devuelve cada uno.
4. Confirma que a ese jugador **no** se le dispara `WorldDataUpdated`, estableciendo la
   asimetría.

**Pasa:** las lecturas se rechazan, o el equipo confirma que los datos son públicos a
propósito.
**Falla:** un ocupante sin rol obtiene datos que la ruta de envío le niega.

**Instrumentación sugerida:** registrar el rol del llamante en los cuatro remotes de lectura
durante un tiempo, para ver si en la práctica hay llamantes sin rol.

---

## BUG-CANDIDATE-013

### Un servidor de casa sin `TeleportData` deja tirado a su jugador en silencio

**Sistema:** Casas · **Clasificación:** Posible bug / Requiere verificación en ejecución
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Media

**Código relacionado:** `PlayerHouses/ServerScriptService/PlayerWorld_Init.lua.server.luau` —
`extractPayload`, `onPlayerAdded`
**Documentación relacionada:** [Casas → Manejo de errores](../systems/housing/error-handling.md)

#### Comportamiento observado — HECHO

```lua
local function onPlayerAdded(player: Player)
    if booting or presence then
        return
    end
    local key, accessCode = extractPayload(player)
    if key then
        booting = true
        init(key, player, accessCode)
        booting = false
    end
end

Players.PlayerAdded:Once(onPlayerAdded)
```

`extractPayload` devuelve `(nil, nil)` cuando falta `GetJoinData().TeleportData` o su `key`
no es una cadena. No hay `else`.

Cualquier otro fallo dentro de `init` llama a `onFailedServer`, que avisa y expulsa con una
explicación. Solo esta ruta no produce aviso, ni expulsión, ni estado.

#### Por qué puede ser un problema

Se acumulan dos efectos. El jugador se queda en un servidor sin datos de mundo, sin
presencia y sin `isStarted`. Y como la conexión es `:Once`, ya está **consumida**: un
jugador posterior, correctamente teletransportado, tampoco podrá inicializar el servidor.

#### Teoría — TEORÍA

Un único jugador que llegue sin `TeleportData` válido envenena permanentemente esa instancia
reservada para todos los que vengan detrás, sin ninguna línea de log que lo explique.

#### Evidencia

- `:Once` en vez de `:Connect` — **HECHO**. Las guardas `booting`/`presence` ya impedirían
  la doble inicialización, así que `:Once` no aporta nada salvo este consumo.
- Todas las rutas de fallo hermanas desembocan en `onFailedServer` — **HECHO**. Esta no, lo
  que la convierte en la excepción.
- El bucle sobre `Players:GetPlayers()` previo al `:Once` usa `task.spawn`, así que un
  jugador ya presente se atiende en paralelo — **HECHO**, y eso implica que el orden entre
  ambos puntos de entrada no es determinista.

#### Incógnitas

- Si un jugador puede llegar siquiera a un place de `PlayerHouses` sin `TeleportData`
  válido. `WorldManager` siempre lo pone, así que las rutas candidatas son una entrada
  directa al place, una reentrada iniciada por Roblox tras una desconexión, o un teleport
  desde código fuera de este repositorio. **Esta es la pregunta que decide si la entrada
  importa**, y por eso la confianza es Media.
- Qué devuelve `GetJoinData()` en una reentrada iniciada por Roblox a un servidor reservado.

#### Escenario de ejemplo

1. Un jugador se teletransporta a una casa y se desconecta a mitad del teleport.
2. Roblox lo reintroduce en la instancia reservada sin el `TeleportData` original.
3. `extractPayload` devuelve nil; no pasa nada; el `:Once` queda consumido.
4. El dueño llega correctamente instantes después, y el servidor sigue sin inicializarse.

#### Esperado frente a posible real

| Esperado | Posible real |
|---|---|
| Una llegada inválida se rechaza con un mensaje, y el servidor aún se inicializa con la siguiente válida | El servidor queda inerte y sigue inerte |

#### Plan de verificación — *Ejecución*, *Teleport*, *Recuperación ante fallos*

1. Establece primero si el caso es alcanzable: teletranspórtate a un place de casa **sin**
   `TeleportData` (una entrada directa al place reservado, o un teleport sin datos). **Si
   Roblox rechaza la entrada de plano, cierra esta entrada y déjalo registrado.**
2. Si es alcanzable, añade una línea de log a la rama nil de `extractPayload` y confirma que
   se alcanza.
3. Haz que un segundo jugador, correctamente teletransportado, entre en la misma instancia.
4. Anota si el servidor llega a inicializarse alguna vez.
5. Repite desconectando a un jugador a mitad del teleport y dejando que Roblox lo
   reintroduzca.

**Pasa:** el caso es inalcanzable, o un jugador válido posterior sí inicializa el servidor.
**Falla:** la instancia sigue inerte tras una llegada válida.

**Instrumentación sugerida:** un aviso en la rama nil que nombre al jugador y vuelque
`GetJoinData()`, lo que haría visible el caso en producción incluso antes de reproducirlo.

---

## BUG-CANDIDATE-014

### Un secreto compartido y un host proxy están escritos a fuego en un archivo versionado

**Sistema:** Casas / Seguridad · **Clasificación:** Confirmado por análisis estático
**Estado:** Sin verificar (la *exposición* es segura; el *impacto* no)
**Gravedad si se confirma:** Alta · **Confianza:** Alta

**Código relacionado:** `Core/…/ServerScripts/WorldsBrowser.server.luau`, principio del
archivo — las constantes `MY_PROXY_URL` y `MY_SECRET_KEY`, usadas por `searchPlayer`
**Documentación relacionada:** [Casas → Identidad y propiedad](../systems/housing/identity.md)

:::note El secreto no se reproduce aquí

Esta página nombra el archivo y las constantes. No repite el valor, y ningún otro documento
debería hacerlo. El valor está en el repositorio y en su historial de git, que es
precisamente el motivo de esta entrada.

:::

#### Comportamiento observado — HECHO

`WorldsBrowser.server.luau` declara, como literales de cadena al principio de un archivo
versionado:

- una URL `http://` con IP desnuda hacia un proxy autoalojado, descrito en un comentario
  como *«Nuestro servidor VPS privado (Puerto 80)»*;
- un secreto compartido, enviado como cabecera `My-Secret` de la petición.

`searchPlayer` llama entonces a `HttpService:GetAsync(url, true, headers)` contra ese host
para resolver una búsqueda por nombre de jugador.

#### Por qué es un problema

Tres cuestiones distintas, en orden decreciente de certeza:

1. **El secreto está versionado.** Cualquiera con acceso de lectura al repositorio —ahora, o
   en cualquier punto de su historial— lo tiene. Rotar el archivo no rota el historial.
2. **El transporte es HTTP plano contra una IP desnuda.** La cabecera viaja sin cifrar y el
   host no está autenticado, así que es interceptable y suplantable en tránsito.
3. **El remote que llega hasta ahí no tiene límite de frecuencia.**
   `SearchPlayerRF.OnServerInvoke` llama a `searchPlayer` con la palabra clave del cliente
   directamente, sin límite de frecuencia, sin tope de longitud y sin cooldown — a
   diferencia de `LoadCharacterRequest`, que tiene un cooldown de 2 segundos. Cada
   invocación es una petición HTTP saliente al proxy.

La palabra clave sí se codifica con `HttpService:UrlEncode`, así que la inyección en
parámetros de consulta está atendida.

#### Teoría — TEORÍA

Un atacante con el secreto puede consultar el proxy directamente, saltándose el juego. Si el
proxy expone algo más allá de la búsqueda de usuarios, el radio de impacto es mayor que este
único endpoint. Por separado, un cliente que ejecute `SearchPlayer` en bucle puede dirigir
tráfico al VPS al ritmo que el servidor sea capaz de procesar, lo que es un vector de
denegación de servicio contra infraestructura de la que el juego depende.

#### Evidencia

- Los literales están en el archivo — **HECHO**.
- `SearchPlayerRF.OnServerInvoke` no tiene guarda de ningún tipo — **HECHO**:

  ```lua
  SearchPlayerRF.OnServerInvoke = function(player: Player, keyword: string)
      print("🔍 Buscando jugador:", keyword)
      return searchPlayer(keyword)
  end
  ```

  Nótese además que `keyword` no se comprueba de tipo, a diferencia de todos los remotes de
  `WorldManager`. Un valor que no sea cadena llega hasta `HttpService:UrlEncode`.

#### Incógnitas

- Qué más expone el proxy, y qué autoriza el secreto. No se puede saber desde este
  repositorio.
- Si el repositorio es privado, y quién ha tenido acceso a él.
- Si el proxy aplica su propio límite de frecuencia.

#### Plan de verificación — *Seguridad*

**No ejecutes esto contra infraestructura de producción sin autorización explícita del
propietario.** Estos pasos son para quienes son dueños del VPS.

1. Confirma que el secreto está presente en el `main` actual y en el historial de git.
2. Determina la superficie completa que expone el proxy y qué concede el secreto.
3. Revisa los logs de acceso del proxy en busca de peticiones que no procedan de servidores
   de Roblox.
4. Mide qué puede hacer un solo cliente: invoca `SearchPlayer` en bucle y observa el ritmo
   de peticiones salientes.

**Pasa:** el secreto no concede nada de valor, y el proxy limita la frecuencia por su
cuenta.
**Falla:** el secreto autoriza algo que merezca protección, o un solo cliente puede saturar
el proxy.

#### Remediación recomendada

Fuera del alcance de este proyecto de documentación —**no se ha cambiado ningún código**—,
pero se registra para que no se pierda:

- Rotar el secreto; dar por comprometido el versionado.
- Sacarlo del código a un almacén de secretos del lado servidor, y purgarlo del historial de
  git.
- Servir el proxy por HTTPS, con nombre de host y certificado válido.
- Limitar la frecuencia y comprobar el tipo en `SearchPlayer`, siguiendo el patrón que ya usa
  `canProcessLoadCharacterRequest`.

---

## Cobertura

Qué se ha examinado y qué no, para que esta página no se confunda con una auditoría
completa.

| Área | Leída de punta a punta | Notas |
|---|---|---|
| Arranque (4 archivos) | Sí | |
| `WorldManager`, `ServerPresence`, `Profiles` | Sí | |
| `PlayerWorld_Init`, `WorldService`, `WorldDataReplicator`, `ModeratorManager` | Sí | Toda la plantilla `PlayerHouses` |
| `ServerDirectory`, `WorldsBrowser` | Sí | |
| `PlayerDataReplicator` (script de servidor), `PlayerSchema`, `HousesInfo`, `RolesInfo`, `GeneralConfiguration` | Sí | |
| `DataKit`: `init`, `Profile`, `Lease`, `Mutex`, `Health` | Sí | Ya documentados con Moonwave en el propio código |
| `DataKit`: `Store`, `BaseStore` | En parte | Propiedad, staging y save/close leídos; `transfer` e `Inbox` no |
| `ShopServerSystem` | En parte | Solo `ProcessPurchase`; la rotación de tienda y la sincronización por `MessagingService` no |
| `playerManager`, `Client/PlayerManager` | Sí | |
| `EventService`, `ReferralService` | **No** | En cola |
| `PlayerDataService`, `WorldSystem/PlayerDataReplicator.luau` | **No** | En cola |
| `Collections` (moneda) | **No** | Necesario para cerrar BUG-CANDIDATE-008 |
| `GlobalDataStore`, `GiftInbox` | **No** | Ambos usan DataStoreService fuera de DataKit |
| Sistemas de juego (~480 archivos) | **No** | En cola |
| 320 binarios `.rbxm` | **No inspeccionables** | |

Que un área no tenga entrada en esta página significa que **no se ha examinado**, no que
esté limpia.
