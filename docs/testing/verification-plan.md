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
| [008](#bug-candidate-008) | Una compra concede el artículo antes de cobrarlo, y por una ruta de persistencia distinta | Casas / Economía | Bug probable / Requiere pruebas de persistencia | Media | **Alta** |
| [009](#bug-candidate-009) | Un fallo al resolver el nombre en el primer arranque bautiza la casa para siempre | Casas | Posible bug / Requiere inyección de fallos | Baja | Alta |
| [010](#bug-candidate-010) | `WorldDataReplicator` se pierde un servidor que ya está `ready` | Casas | Bug probable / Requiere pruebas de ciclo de vida | Media | Media |
| [011](#bug-candidate-011) | El rol `moderator` no puede moderar | Casas | Bug probable / Confirmado por análisis estático | Media | Alta |
| [012](#bug-candidate-012) | Roles, ajustes y baneos de una casa los puede leer cualquier ocupante | Casas | Observación / Requiere pruebas de seguridad | Baja | Alta |
| [013](#bug-candidate-013) | Un servidor de casa sin `TeleportData` deja tirado a su jugador en silencio | Casas | Posible bug / Requiere verificación en ejecución | Media | Media |
| [014](#bug-candidate-014) | Un secreto compartido y un host proxy están escritos a fuego en un archivo versionado | Casas / Seguridad | Confirmado por análisis estático | Alta | Alta |
| [015](#bug-candidate-015) | Un solo booleano separa la economía de escrituras arbitrarias del cliente | Economía / Seguridad | Observación / Requiere pruebas de seguridad | Crítica | Alta |
| [016](#bug-candidate-016) | Las máquinas aceptan del cliente el valor de la recompensa sin validarlo | Máquinas / Seguridad | Observación / Requiere pruebas de seguridad | Alta | Alta |
| [017](#bug-candidate-017) | Revocar un rol de administrador tarda hasta 50 segundos en surtir efecto | Administración / Seguridad | Observación / Requiere verificación en ejecución | Baja | Alta |
| [018](#bug-candidate-018) | Salir durante la carga deja el registro sucio y rompe la reconexión al mismo servidor | Datos del jugador / Sesión | Bug probable / Requiere pruebas de ciclo de vida | Media | Alta |
| [019](#bug-candidate-019) | Donar a un jugador que aún no ha cargado destruye la moneda | Economía / Sesión | Bug probable / Requiere pruebas de ciclo de vida | Media | Alta |
| [020](#bug-candidate-020) | El color de una superficie llega del cliente sin límite de tamaño y se guarda tal cual | Tiendas / Casas / Seguridad | Observación / Requiere pruebas de seguridad | Alta | Media |
| [021](#bug-candidate-021) | El dueño de una casa puede vender el mueble de un invitado y quedarse el reembolso | Tiendas / Economía | Posible bug / Requiere pruebas multijugador | Media | Media |

### Entradas de seguridad

Las que tratan superficie de ataque en vez de corrección funcional. Se escriben en el mismo
formato que el resto: teoría con justificación, no acusaciones.

| ID | Vector | Estado hoy |
|---|---|---|
| [012](#bug-candidate-012) | Lectura de roles y baneos de una casa sin comprobación de permisos, por dos sistemas distintos | **Explotable hoy**, impacto bajo |
| [014](#bug-candidate-014) | Secreto compartido versionado, proxy en HTTP plano, remote sin límite de frecuencia | **Expuesto hoy**, impacto por determinar |
| [015](#bug-candidate-015) | Escritura arbitraria de moneda desde el cliente | **Latente** — desactivado por un booleano |
| [016](#bug-candidate-016) | Valor de recompensa suministrado por el cliente | **Latente** — el manejador de premio es un stub |
| [017](#bug-candidate-017) | Ventana de revocación de privilegios de administrador | **Presente hoy**, impacto bajo |
| [020](#bug-candidate-020) | Dato de tamaño arbitrario, controlado por el cliente, persistido en el perfil de una casa ajena | **Presente hoy**, impacto por determinar |

#### Lo que se revisó y salió limpio

Registrado con el mismo cuidado, porque una lista de hallazgos sin lo revisado y correcto es
engañosa:

| Superficie | Resultado |
|---|---|
| Comandos de administración (`EventCommands`, `ReferralCommands`) | **Correcto.** Ambos comprueban `Admins:IsRole(player, "Admins")` contra un grupo de Roblox, y rechazan en silencio para no revelar la existencia del comando. |
| `RoleService` ante fallo de `GroupService` | **Falla cerrado.** Un `pcall` fallido produce una tabla de roles vacía, no un pase libre. |
| Precios de la tienda | **Correcto.** El precio se lee de `HousesInfo`/`DancesInfo` en el servidor; el cliente solo envía un id de artículo, que además debe estar en la rotación vigente. |
| `accessCode` de servidores reservados | **Correcto.** Nunca viaja al cliente: `ServerDirectory.toPublicEntry` construye la respuesta campo a campo y lo omite. |
| Destinos de teleport | **Correcto.** El cliente envía una clave, nunca un `PlaceId`; se resuelve contra `HousesInfo` o `PlaceKeyToPlaceId`. |
| `Machine:bind` | **Correcto.** Exige que el modelo coincida y que el jugador esté en la lista de participantes de esa máquina. |
| `SetWorldName` | **Correcto en el saneado**, con la salvedad de que el filtrado de texto falla abierto (ver [Permisos](../systems/housing/permissions.md)). |
| Apertura de casa ajena | **Correcto.** `hasRoom` se comprueba en el destino contra el perfil del dueño; una clave falsificada no crea ni abre una casa. |
| Precios de mobiliario y materiales | **Correcto.** `BuyStore`, `BuyDecors` y `ComprarMaterial` resuelven el precio en el servidor desde `StoreTemplates`, `verificarExistencia` y `DesingData`. El cliente solo manda un nombre. |
| Precio vacío como compra gratis | **Correcto, y deliberado.** `Collections.requirements` devuelve la bandera `vacio`, que solo se activa dentro del bucle: una tabla de precio vacía devuelve `false` y el cobro no se da por bueno. |
| Inyección de tablas arbitrarias en el perfil de una casa | **Correcto.** `BreakDown.Set` devuelve `nil` para cualquier tipo que no sea booleano, cadena, número o uno de los seis con descomposición declarada. |
| Amueblar la casa de otro como vía de transferencia de moneda | **Correcto.** Pasa por `donacion.GetState` y `donacion.Quitar`: consume el mismo tope diario de 1 000 que una donación directa. |
| Importe de las compras en Robux | **Correcto.** `Compras.Comprar` usa `self.ProductActive`, estado de servidor, y lee el precio de `GetProduct`. |

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

#### Ya existe un patrón mejor en este mismo repositorio

`EventService` tiene exactamente la misma necesidad —poder probar en Studio, donde el
teleport es una operación vacía— y la resuelve **sin fabricar nada**. Su comentario lo dice:

```lua
-- Puente de Studio: como ahí el teleport es no-op, `reserve()` deja la reserva anotada
-- con TTL largo y la place reservada la levanta al darle Play. Es el equivalente a lo que
-- hacen las casas en PlayerWorld_Init, pero sin inventar datos: usa la reserva de verdad.
```

Reserva de verdad con `ReserveServer`, y anota en un mapa aparte (`EventStudioPending`) que
hay una reserva esperando a que alguien le dé Play. El código que llega al registro
compartido es siempre un código real.

Esto no es una propuesta de arreglo —este proyecto no cambia código— pero sí acota mucho la
discusión: la solución ya está escrita, probada y comentada a unos pocos archivos de
distancia. Ver [Eventos](../systems/events.md).

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

**Sistema:** Casas / Economía · **Clasificación:** Bug probable / Requiere pruebas de persistencia
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Alta

:::note Actualizado tras leer `Collections` y `PlayerDataReplicator`

La primera versión de esta entrada dependía de que `collections.SetAmount` fallara, y por
eso su confianza era Media. Leer la capa de datos del jugador ha resuelto esa incógnita —y
la ha empeorado: la concesión y el cobro **no comparten ruta de persistencia**, así que no
hace falta ningún error para abrir la ventana. Basta con el reloj.

:::

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

#### El hecho que lo cambia todo — HECHO

La concesión y el cobro llegan al perfil por **rutas distintas y con tiempos distintos**:

| | Concesión (`rooms`) | Cobro (moneda) |
|---|---|---|
| Qué se escribe | `store:update` sobre el perfil | `value.Value` de un `ValueBase` bajo el `Player` |
| Cuándo entra en el perfil | **De inmediato** | Solo cuando `PlayerDataReplicator.flush` serializa las `Instance` — **cada 60 s** (`FLUSH_INTERVAL`) o al salir |
| Cuándo llega al DataStore | En el siguiente autoguardado del `Store` (300 s por defecto) o al cerrar | Igual, pero solo si ya pasó por un `flush` |

`rooms` **no** está en la tabla `SPEC` de `PlayerDataReplicator`, así que no se materializa
como `Instance`: se escribe directo al perfil. `stats` sí está en `SPEC`, mapeado a
`leaderstats`, y es donde vive la moneda. Ver [Datos del jugador](../systems/player-data.md).

#### Por qué es un problema

Las dos escrituras no son atómicas, no están ordenadas defensivamente, y —esto es lo
nuevo— **ni siquiera viajan juntas**. Existe una ventana de hasta 60 segundos en la que el
perfil contiene la casa concedida y todavía no el descuento.

#### Teoría — TEORÍA

Si el autoguardado del `Store` cae dentro de esa ventana y el servidor muere antes del
siguiente `flush`, el DataStore queda con la room añadida y la moneda intacta. No hace
falta que nada falle: basta con que los dos relojes —autoguardado a 300 s, volcado a 60 s—
se crucen en el orden desfavorable.

El mismo razonamiento aplica a `buySlot`, donde `slots` tampoco está en `SPEC`.

#### Evidencia

- El orden es directo e inequívoco — **HECHO**.
- La comprobación de fondos lee `value.Value` *antes* del update y el descuento recalcula
  desde `tonumber(value.Value)` *después*, así que las dos lecturas están separadas por una
  llamada que cede el hilo — **HECHO**.
- `buySlot` lleva un comentario explícito que muestra que el autor razonó sobre invocaciones
  concurrentes (*«dos invokes simultáneos leerían el mismo `slots` y cobrarían dos veces»*)
  y añadió una guarda por jugador, pero no reordenó la concesión y el cobro — **HECHO**.
- `rooms` y `slots` no aparecen en la tabla `SPEC`; `stats` sí, como carpeta `leaderstats` —
  **HECHO**. Esta es la evidencia que sube la confianza a Alta: la separación de rutas es
  estructural, no accidental.
- `FLUSH_INTERVAL = 60` y el autoguardado por defecto de `Store` de 300 s son constantes
  explícitas — **HECHO**.

#### El patrón correcto ya existe en este repositorio, escrito y razonado

`ReferralService.ClaimReward` resuelve exactamente el mismo problema —mover valor sin
poder perderlo ni duplicarlo— y lo hace al revés que la tienda. Su comentario lo justifica:

```lua
--[[
	El orden importa: primero se marca como reclamado y se guarda, y solo despues
	se da el dinero. Al reves, un fallo de guardado dejaria al jugador cobrando el
	mismo hito una y otra vez.
]]
```

Y el código lo cumple, incluida la parte que la tienda no hace: **comprobar que el guardado
funcionó** antes de mover el valor.

```lua
if not store:save("referral:claim") then
    return false, "No se pudo guardar. Intentalo otra vez."
end

giveReward(player, reward.Currency, reward.Amount)
```

`SetInviter` hace lo mismo por el mismo motivo (`store:save("referral:attributed")`, con el
comentario *«Se persiste ya: si el servidor se cae en el proximo minuto, la invitacion no se
pierde»*).

**Esto es lo que sube la clasificación a Bug probable.** No son dos criterios defendibles
conviviendo: es el mismo problema resuelto bien en un sitio y mal en otro, con el
razonamiento correcto escrito a unos archivos de distancia. Ver
[Invitaciones](../systems/referrals.md).

#### Incógnitas

- Con qué frecuencia el autoguardado del `Store` cae realmente dentro de la ventana. Depende
  de la deriva entre dos temporizadores independientes y de cuándo se compre.
- Si el equipo prefiere «conceder primero y no perder nunca una compra» como política
  consciente. Sería defendible, pero entonces conviene decirlo, porque el coste es
  regalar artículos de vez en cuando.
- ~~Si `collections.SetAmount` puede fallar~~ — ya no hace falta: la ventana existe sin
  ningún fallo.

#### Escenario de ejemplo

1. Un jugador con exactamente 4 000 Coins compra `playaRoom` por 4 000.
2. `store:update` inserta la room en el perfil, de inmediato.
3. `SetAmount` descuenta la moneda **solo en el `ValueBase`**; el perfil sigue sin saberlo.
4. Segundos después, el autoguardado del `Store` escribe el perfil al DataStore: con la
   casa, y con la moneda antigua.
5. El servidor se cae antes del siguiente `flush` de 60 s.
6. El jugador vuelve a entrar con la casa y con sus 4 000 Coins.

#### Esperado frente a posible real

| Esperado | Posible real |
|---|---|
| O ocurren la concesión y el cobro, o no ocurre ninguno | El artículo se concede y no se paga |

#### Plan de verificación — *Persistencia*, *Recuperación ante fallos*, *Funcional*

El paso de lectura previa ya está hecho, y confirmó la separación de rutas. Lo que queda es
medir la ventana:

1. En un place de pruebas, baja `FLUSH_INTERVAL` a un valor alto (por ejemplo 600 s) para
   ensanchar la ventana a propósito y hacerla observable.
2. Compra una casa.
3. Fuerza un guardado del `Store` sin esperar (o baja su `autosaveInterval`), y luego cierra
   el servidor de golpe, sin apagado ordenado.
4. Vuelve a entrar. Comprueba si tienes la casa **y** el dinero.
5. Repite con `buySlot`.
6. Repite con los valores por defecto (60 s / 300 s) varias veces para estimar con qué
   frecuencia ocurre en condiciones reales.

**Pasa:** tras el paso 4 el jugador tiene la casa y **no** el dinero, o no tiene ninguna de
las dos cosas.
**Falla:** tiene ambas.

**Instrumentación sugerida:** registrar un único apunte de compra —jugador, artículo,
precio, saldo antes, saldo después— escrito **dentro del mismo `store:update` que concede
el artículo**, para que el apunte y la concesión compartan destino y se puedan cuadrar
después. Un apunte escrito por fuera tendría el mismo problema que el cobro.

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

:::note Un quinto camino, hallado al leer `Shared/Stores`

La tabla de roles sale también por un remote que no está en la lista de arriba y que
pertenece a otro sistema. `HouseAdded:init` conecta `GetInfoHouse` en las dos direcciones:

```lua
local GetInfoHouse = Events:WaitForChild("GetInfoHouse")
GetInfoHouse = Client and GetInfoHouse.OnClientEvent or GetInfoHouse.OnServerEvent
GetInfoHouse:Connect(function(...) self:GetData(...) end)
```

Cualquier cliente puede dispararlo, y el servidor responde con la tabla completa:

```lua
local DataClient = {
	Permisos = self.DataBaseHouse:GetStoreData("WorldRolesStore") or {},
	Owner = tonumber(self.DataBaseHouse.OwnerId),
	Desing = self:GetColorAndTexture(not ClientData),
}
Events:FindFirstChild("GetInfoHouse"):FireClient(ClientData, DataClient)
```

Además, cada cambio de roles se difunde con `FireAllClients`, sin filtrar por destinatario.

Esto **eleva la confianza** de esta entrada —hay dos sistemas independientes que exponen lo
mismo, así que no es un descuido aislado— y **amplía el trabajo de una eventual corrección**:
cerrar los cuatro remotes de `WorldDataReplicator` no bastaría.

No cambia la gravedad. Sigue siendo una fuga de metadatos de una casa hacia quien ya está
dentro de ella.

:::

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

---

## BUG-CANDIDATE-015

### Un solo booleano separa la economía de escrituras arbitrarias del cliente

**Sistema:** Economía / Seguridad · **Clasificación:** Observación / Requiere pruebas de seguridad
**Estado:** Sin verificar · **Gravedad si se confirma:** Crítica · **Confianza:** Alta

**Código relacionado:** `Core/ReplicatedStorage/Client/EconomySystem/Collections.luau`,
final del archivo; `Core/ReplicatedStorage/Events/Collections/*`
**Documentación relacionada:** [Red](../architecture/networking.md)

:::note Hoy no es explotable

El código que lo abriría está **desactivado por una constante**. Esta entrada no dice que
el juego sea vulnerable ahora. Dice que la distancia entre el estado actual y una
vulnerabilidad crítica es un `false` que alguien podría cambiar sin darse cuenta de lo que
habilita.

:::

#### Comportamiento observado — HECHO

`Collections.luau` termina con un enlazado automático de remotes a sus propias funciones:

```lua
if not IsClient and not Start and ConexionEntreServerYCliente then
    Start = not Start

    for _,remote in Events:GetChildren() do
        if not module[remote.Name] then continue end
        if remote:IsA('RemoteEvent') then
            remote.OnServerEvent:Connect(module[remote.Name])
        elseif remote:IsA('RemoteFunction') then
            remote.OnServerInvoke = module[remote.Name]
        end
    end
end
```

y arriba del archivo, en la línea 9:

```lua
local ConexionEntreServerYCliente = false
```

Los remotes existen y coinciden por nombre con funciones del módulo:

| Remote | Clase | Función del módulo con ese nombre |
|---|---|---|
| `Events/Collections/SetAmount` | `RemoteEvent` | `module.SetAmount(_, value, Amount, earned2)` |
| `Events/Collections/Give` | `RemoteEvent` | `module.Give(Player, List, Level)` |
| `Events/Collections/charge` | `RemoteFunction` | `module.charge(Player, List, Level)` |
| `Events/Collections/Get` | `RemoteEvent` | *(no hay `module.Get`; el bucle lo salta)* |

#### Por qué puede ser un problema

Si esa constante pasara a `true`, el bucle enlazaría los remotes directamente a funciones
que **no fueron escritas para recibir entrada del cliente**. En particular:

- **`SetAmount`.** Su primer parámetro se llama `_` y se ignora. En un `OnServerEvent`, el
  primer argumento es el jugador que dispara, así que el jugador cae en `_`, y `value` y
  `Amount` vienen **del cliente**. El cuerpo hace:

  ```lua
  value.Value = math.clamp(Amount, 0, math.huge)
  ```

  Es decir: escritura arbitraria sobre cualquier `ValueBase` que el cliente pueda
  referenciar, con cualquier valor. No hay comprobación de propiedad, ni de tipo, ni de
  rango superior.

- **`Give`.** Su firma sí empieza por `Player`, así que el jugador llegaría correctamente,
  pero `List` y `Level` vendrían del cliente. `Give` recorre `List` sumando a cada stat
  nombrado el valor que el propio cliente indica. Es moneda ilimitada.

#### Teoría — TEORÍA

Un cliente podría concederse cualquier cantidad de Coins, Gems o cualquier otro stat
replicado, y con `SetAmount` escribir sobre `ValueBase` que ni siquiera le pertenecen. Como
`PlayerDataReplicator` replica los stats desde y hacia el perfil persistido, el efecto sería
además duradero, no cosmético.

#### Evidencia

- La constante está a `false` y es el único guardián — **HECHO**. Sin ella, el enlazado
  ocurre sin más condiciones.
- La coincidencia por nombre entre remotes y funciones no es casual: los cuatro remotes
  existen y tres tienen función homónima — **HECHO**. El mecanismo estaba pensado para
  usarse.
- `module.SetAmount` tiene `_` como primer parámetro — **HECHO**. Eso demuestra que se
  diseñó para llamarse desde el servidor (`SetAmount(Player, value, amount)`), no como
  manejador de remote, donde ese hueco lo ocupa el jugador.
- El nombre de la constante, *«ConexionEntreServerYCliente»*, indica que el autor sabía
  exactamente qué habilitaba y decidió dejarlo apagado — **INFERENCIA**.

#### Incógnitas

- Por qué se dejó el código en lugar de borrarlo. Puede ser trabajo a medias, o un
  interruptor de depuración.
- Si alguna versión publicada de la plantilla `Core` tiene esa constante a `true`. **Este
  repositorio solo contiene el override local**; el asset publicado es el que manda en
  producción, y no se puede leer desde aquí. Esta incógnita es la razón de que la entrada
  se registre en vez de descartarse.

#### Escenario de ejemplo

1. Alguien pone `ConexionEntreServerYCliente = true` para probar algo, o la versión
   publicada ya lo tiene.
2. Un cliente ejecuta
   `ReplicatedStorage.Events.Collections.Give:FireServer({ Coins = 999999999 }, true)`.
3. El servidor suma esa cantidad al stat `Coins` del jugador.
4. `PlayerDataReplicator` la persiste.

#### Esperado frente a posible real

| Esperado | Posible real |
|---|---|
| La moneda solo la modifica el servidor, tras validar | Cualquier cliente fija cualquier stat al valor que quiera |

#### Plan de verificación — *Seguridad*, *Integración*

1. **Primero, lo que decide todo:** comprueba el valor de `ConexionEntreServerYCliente` en
   el asset `Core` **publicado** (`137484964666215`), no en este repositorio. Si allí es
   `false`, el riesgo es solo latente y esta entrada baja a nota de mantenimiento.
2. En un place de pruebas aislado, pon la constante a `true`.
3. Desde el cliente, dispara `Collections/Give` con una tabla de stats y cantidades
   inventadas. Anota si el stat cambia.
4. Dispara `Collections/SetAmount` con una referencia a un `ValueBase` que no pertenezca al
   jugador. Anota si se escribe.
5. Vuelve a entrar para comprobar si el cambio persistió.

**Pasa:** con la constante a `true` los remotes siguen rechazando la entrada del cliente
(no es el caso según la lectura del código), o la constante está a `false` en el asset
publicado y se documenta como interruptor peligroso.
**Falla:** el paso 3 o el 4 modifican valores.

**Instrumentación sugerida:** ninguna en producción. Lo que corresponde es una comprobación
en el proceso de publicación que falle si esa constante llega a `true`.

---

## BUG-CANDIDATE-016

### Las máquinas aceptan del cliente el valor de la recompensa sin validarlo

**Sistema:** Máquinas / Seguridad · **Clasificación:** Observación / Requiere pruebas de seguridad
**Estado:** Sin verificar · **Gravedad si se confirma:** Alta · **Confianza:** Alta

**Código relacionado:** `Core/…/ServerScripts/machines/PopTheLock.luau`;
`Core/…/ServerScripts/machines/Machine.luau`, `Machine:bind`
**Documentación relacionada:** [Red](../architecture/networking.md)

:::note Hoy no concede nada

El manejador de premio es un stub que solo escribe en el log. Esta entrada documenta la
**forma** del flujo, porque el valor del cliente ya llega hasta el borde de la ruta de
recompensa y solo falta que alguien implemente el premio.

:::

#### Comportamiento observado — HECHO

```lua
self._machine:bind(remotes.Machines.PopTheLockFinish, function(player, tickets)
    fireExcept(remotes.Machines.PopTheLockFinish, player, model, tickets)
    if tickets > 0 then
        self:_handle(player, tickets)
    end
    self:stop()
end)
```

`tickets` viene íntegramente del cliente. Y el manejador de premio, hoy:

```lua
function PopTheLock:_handle(player: Player, tickets: number)
    warn(`[pop the lock] player({player}) tickets({tickets})`)
end
```

#### Por qué puede ser un problema

Dos cosas distintas:

1. **La cantidad de premio la decide el cliente.** El servidor no simula la partida, no
   acota `tickets`, y no comprueba que el resultado sea alcanzable. El día que `_handle`
   conceda algo, concederá lo que el cliente diga.
2. **`tickets > 0` no comprueba el tipo.** Si un cliente envía una cadena o `nil`, la
   comparación lanza un error de Luau («attempt to compare»), que aborta el manejador. Todos
   los demás remotes revisados en `WorldManager` sí comprueban tipo antes de usar el valor.

#### Lo que sí está bien

**HECHO.** `Machine:bind` no es ingenuo:

```lua
remote.OnServerEvent:Connect(function(player, model, ...)
    if model == self.model and table.find(self._players, player) then
        callback(player, ...)
    end
end)
```

Exige que el modelo coincida con esa máquina y que el jugador esté en su lista de
participantes. Así que un jugador cualquiera no puede disparar el premio de una máquina en
la que no está jugando. Eso acota el problema a los participantes legítimos, no lo elimina.

#### Teoría — TEORÍA

Cuando se implemente el premio, un participante podrá enviar el número de tickets que
quiera. El patrón —el cliente reporta su propia puntuación— es el mismo en el resto de
máquinas, así que el arreglo probablemente no sea puntual sino de diseño: la puntuación
debería derivarse en el servidor, o al menos acotarse por lo que la partida permite.

#### Evidencia

- `tickets` va del remote a `_handle` sin ninguna transformación — **HECHO**.
- `_handle` es un stub — **HECHO**, y por eso la clasificación es Observación y no bug.
- Ninguna máquina otorga moneda hoy: un `grep` de `Collections`/`SetAmount` sobre
  `ServerScripts/machines` no devuelve nada — **HECHO**. La única que cobra es
  `LootBoxService`, y lo hace con `Collections.charge` del lado servidor.

#### Incógnitas

- Si el diseño previsto es que el servidor simule la partida o que confíe en el cliente y
  acote el resultado.
- Si las demás máquinas (`Stacker`, `Basketball`) siguen el mismo patrón en sus finales.
  No se han leído en detalle.

#### Escenario de ejemplo

1. Alguien implementa `_handle` para que conceda tickets.
2. Un jugador entra legítimamente en la máquina.
3. Dispara `PopTheLockFinish` con `tickets = 1e9` sin haber jugado.
4. Recibe la recompensa completa.

#### Esperado frente a posible real

| Esperado | Posible real |
|---|---|
| El servidor decide la recompensa | El cliente la decide |

#### Plan de verificación — *Seguridad*, *Funcional*

1. Lee `Stacker.luau`, `Basketball/init.luau` y `Roulette.luau` y comprueba si sus rutas de
   final tienen la misma forma. `Roulette` ya valida el modelo en `requestSpinRF`, así que
   puede ser el patrón a seguir.
2. En un place de pruebas, implementa `_handle` con una concesión de prueba.
3. Únete a la máquina y dispara `PopTheLockFinish` con un valor absurdo, sin jugar.
4. Anota si se concede.
5. Repite enviando una cadena en vez de un número y comprueba si el manejador lanza error.

**Pasa:** el servidor recalcula o acota la recompensa; un valor no numérico se rechaza
limpiamente.
**Falla:** se concede lo que el cliente dijo, o un valor no numérico produce un error de
Luau.

**Instrumentación sugerida:** registrar `tickets` junto con la duración de la partida en el
servidor; una recompensa alta con una partida de cero segundos es la señal buscada.

---

## BUG-CANDIDATE-017

### Revocar un rol de administrador tarda hasta 50 segundos en surtir efecto

**Sistema:** Administración / Seguridad · **Clasificación:** Observación / Requiere verificación en ejecución
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja · **Confianza:** Alta

**Código relacionado:** `Core/ServerStorage/RoleService/init.luau` — `PlayerAdded`,
`IsRole`, `TimeHold`
**Documentación relacionada:** —

#### Comportamiento observado — HECHO

`IsRole` no consulta a Roblox: lee una caché.

```lua
function module:IsRole(Player:Player, NameRole)
    assert(typeof(NameRole) == "string", "Only string")
    return self:GetInfoPlayer(Player).Roles[NameRole] or false
end
```

y `GetInfoPlayer` → `PlayerAdded` solo refresca si la entrada es más vieja que `TimeHold`:

```lua
if not LastData or GetElapsedTime(LastData.UpdateTime) >= self.TimeHold then
    local Sucess, DataGroup = pcall(GroupService.GetRolesInGroupAsync, GroupService, Player.UserId, self.GroupId)
```

`TimeHold = 50` segundos, y un bucle aparte llama a `Updating()` cada 10 segundos.

#### Por qué puede ser un problema

Quitar a alguien del rango de administrador en el grupo de Roblox no le retira los permisos
de inmediato: sigue pasando `IsRole` hasta que su entrada de caché caduque.

#### Teoría — TEORÍA

Existe una ventana de hasta 50 segundos en la que un administrador recién degradado
—posiblemente por abuso, que es justo cuando importa— conserva acceso a `EventCommands` y
`ReferralCommands`.

#### Lo que sí está bien

**HECHO.** El servicio **falla cerrado**. Si `GetRolesInGroupAsync` da error, `Sucess` es
`false` y `GetRoles(nil)` devuelve `{}`, así que el jugador queda sin roles en vez de con
todos. Es la dirección segura.

**OBSERVACIÓN.** El reverso de eso es que un fallo transitorio de `GroupService` también se
cachea 50 segundos, así que un administrador legítimo puede quedarse sin permisos durante
ese rato. Es una molestia de disponibilidad, no un agujero.

#### Evidencia

- `TimeHold = 50` y la condición de refresco son explícitos — **HECHO**.
- `IsRole` no tiene ninguna vía para forzar un refresco — **HECHO**.

#### Incógnitas

- Si 50 segundos es una elección deliberada de compromiso entre cuota de `GroupService` y
  frescura. Muy probablemente sí, dado que hay un bucle de actualización periódica.
- Si el modelo de amenaza del equipo contempla la revocación urgente.

#### Escenario de ejemplo

1. Se retira a un administrador del rango en el grupo de Roblox.
2. Dentro de los 50 segundos siguientes ejecuta un comando de evento.
3. `IsRole` lee la caché y lo permite.

#### Plan de verificación — *Seguridad*, *Ejecución*

1. Con dos cuentas, una administradora, entra en un servidor.
2. Ejecuta un comando de administración y confirma que funciona.
3. Retira el rango en el grupo de Roblox.
4. Vuelve a ejecutar el comando de inmediato, y luego cada 10 segundos.
5. Anota cuándo empieza a rechazarse.

**Pasa:** el rechazo llega dentro de la ventana que el equipo considere aceptable.
**Falla:** el acceso persiste bastante más de 50 segundos, lo que indicaría que la caché no
caduca como se espera.

**Instrumentación sugerida:** registrar la antigüedad de la entrada de caché junto a cada
comando administrativo aceptado, para conocer la frescura real en producción.


## BUG-CANDIDATE-018

### Salir durante la carga deja el registro sucio y rompe la reconexión al mismo servidor

**Sistema:** Datos del jugador / Sesión · **Clasificación:** Bug probable / Requiere pruebas de ciclo de vida
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Alta

**Código relacionado:** `Core/ServerScriptService/Data/Main/init.server.luau`, `PlayerAdded`
(líneas 104–155) y `PlayerRemoving` (líneas 187–196)
**Documentación relacionada:** [Data.Main](../systems/session-orchestrator.md#los-tres-estados-de-datacomplete)

#### Comportamiento observado — HECHO

`PlayerAdded` marca al jugador como «cargando» en su primera línea, y el resto de la
función es una secuencia larga con varios puntos de espera:

```lua
function PlayerAdded(Player)
	if PlayerDataReplicator.DataComplete[Player.UserId] then return end
	PlayerDataReplicator.DataComplete[Player.UserId] = 'no complete'
	...
	local list, errorMessage = PlayerDataReplicator.hydrate(Player)   -- espera al DataStore
	...
	PlayerDataReplicator.DataComplete[Player.UserId] = list
	PlayerDataReplicator.markReady(Player)
	...
end
```

`PlayerRemoving`, el manejador que limpia ese registro, **se rinde ante el valor
transitorio**:

```lua
function PlayerRemoving(Player)
	RequerestLoadedPlayer[Player] = nil
	local DataComplete = PlayerDataReplicator.DataComplete[Player.UserId]

	if not DataComplete or table.find({"no complete", "Guardando"}, DataComplete) then return end

	PlayerDataReplicator.finalize(Player)
	PlayerDataReplicator.DataComplete[Player.UserId] = nil
end
```

Sale con `return` y **no borra la entrada**. `DataComplete` solo lo escribe este archivo:
un `grep` sobre todo `src/` confirma que ningún otro script lo asigna. Nada más lo va a
limpiar.

#### Por qué esto puede ser un problema — HECHO

La primera línea de `PlayerAdded` es una guarda de reentrada contra **el mismo `UserId`**,
no contra la misma `Instance` de `Player`:

```lua
if PlayerDataReplicator.DataComplete[Player.UserId] then return end
```

Si la entrada quedó sucia, una reconexión **a esa misma instancia de servidor** entra por
esa guarda y sale inmediatamente: no hay `hydrate`, no hay `leaderstats`, no hay
`markReady`, y `StartClientPlayer` no se dispara nunca.

#### Teoría — TEORÍA

Hay dos ventanas, y la segunda es la que más daño hace.

**Ventana A — salir durante `hydrate`.** El propio `hydrate` la contempla:

```lua
if not player:IsDescendantOf(game) then
	return nil, "El jugador salio durante la carga"
end
```

Devuelve `nil`, y la rama de error de `PlayerAdded` **sí** limpia la entrada. Esta ventana
se cierra sola. Está anotada porque demuestra que quien escribió el código conocía el
problema en ese punto concreto.

**Ventana B — salir después de `hydrate` y antes de la línea 147.** Aquí no hay
comprobación. La secuencia sería:

1. El jugador entra; `DataComplete[userId] = "no complete"`.
2. `hydrate` termina bien.
3. El jugador se va. `Players.PlayerRemoving` dispara los dos manejadores; el de
   `Data.Main` ve `"no complete"` y **se rinde**.
4. La corrutina de `PlayerAdded` continúa y escribe `DataComplete[userId] = list`.
5. La entrada queda como **tabla, para un jugador que ya no está**.

A partir de ahí, en ese servidor:

| Consecuencia | Mecanismo |
|---|---|
| Una reconexión no inicializa nada | La guarda de la línea 105 |
| El apagado tarda 30 s de más | `CountDatasCompletes()` cuenta las tablas, y espera hasta agotar el tope |
| `RevisarCanciones` y `ComprasTablero` creen que el jugador está presente | Leen `DataComplete[UserId]` por inyección |

**No hay pérdida de datos.** `PlayerDataInit` conecta su propio manejador de
`Players.PlayerRemoving` que llama a `PlayerDataService.close`, y ese camino sí cierra el
perfil y suelta el lease pase lo que pase. Lo que se corrompe es el estado en memoria de
la sesión, no lo guardado.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `DataComplete` solo se asigna en `Data/Main/init.server.luau`; ningún otro archivo escribe en él |
| 2 | `PlayerRemoving` sale antes de limpiar en dos de los cuatro estados posibles |
| 3 | La guarda de reentrada es por `UserId`, que sobrevive a la reconexión, no por `Player` |
| 4 | `markReady` sí está protegido (`if tracked[player] ~= nil then`), lo que impide que el estado de guardado se corrompa por esta misma vía — la protección existe en `PlayerDataReplicator` pero no en `DataComplete` |
| 5 | `hydrate` comprueba explícitamente `IsDescendantOf(game)`, prueba de que la ventana de salida durante la carga se consideró en ese punto |

#### Incógnitas

- Con qué frecuencia Roblox devuelve a un jugador que reconecta a **la misma** instancia de
  servidor. Sin eso, el impacto se queda en el retraso de apagado y el estado fantasma.
- Cuánto dura realmente la ventana B: depende de lo que tarden `PaintServer:Load`,
  `Commands:PlayerAdded` y `AgarreTool.new`, ninguno medido.

#### Escenario de ejemplo

Un jugador con conexión inestable entra, su perfil carga, y pierde la conexión mientras el
servidor todavía está montando sus cuadros. Vuelve treinta segundos después y Roblox lo
manda al mismo servidor. Aparece en el mundo sin `leaderstats`, sin inventario y sin
interfaz: el cliente sigue esperando un `StartClientPlayer` que ya no va a llegar.

**Comportamiento esperado:** la reconexión inicializa al jugador con normalidad.
**Comportamiento posible:** el jugador queda en un estado inerte hasta que le toque otro
servidor.

#### Plan de verificación — *Ciclo de vida*

1. En un place de pruebas, añade un `task.wait(10)` **temporal** justo después de la
   llamada a `hydrate` en `PlayerAdded`, para ensanchar la ventana B a un tamaño manejable.
   *(Es un cambio de instrumentación para la prueba, no una corrección.)*
2. Entra con una cuenta y cierra el cliente a los ~5 segundos.
3. Vuelca `PlayerDataReplicator.DataComplete` desde la consola del servidor.
4. Vuelve a entrar, forzando el mismo servidor con `TeleportService:TeleportToPlaceInstance`
   o uniéndote desde la lista de amigos.
5. Observa si aparecen `leaderstats` y si el cliente recibe `StartClientPlayer`.

**Pasa:** tras el paso 3 `DataComplete` no contiene ninguna entrada para ese `UserId`, y la
reconexión inicializa con normalidad.
**Falla:** queda una entrada, y la reconexión al mismo servidor no monta nada.

**Instrumentación sugerida:** un `warn` en `PlayerAdded` cuando la guarda de la línea 105
rechaza a un jugador. En producción, ese contador diría de inmediato si esto ocurre de
verdad y con qué frecuencia.

---

## BUG-CANDIDATE-019

### Donar a un jugador que aún no ha cargado destruye la moneda

**Sistema:** Economía / Sesión · **Clasificación:** Bug probable / Requiere pruebas de ciclo de vida
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Alta

**Código relacionado:** `Core/ServerScriptService/Data/Main/init.server.luau`,
`donacion.Donar`; `Core/ReplicatedStorage/Client/EconomySystem/Collections.luau`,
`Give` y `GetValue`
**Documentación relacionada:** [Data.Main → Donaciones](../systems/session-orchestrator.md#donaciones-entre-jugadores)

#### Comportamiento observado — HECHO

`donacion.Donar` cobra primero y concede después, que es el orden correcto:

```lua
if SumaTotal <= MaxAmountSend and Cobros.charge(Player, {Coins = Cantidad}, true) then
	Cobros.Give(Receptor, {Coins = Cantidad}, true)
	Cash:SetAttribute("AmountSending", tostring(SumaTotal))
```

La validación del receptor es esta, y solo esta:

```lua
typeof(Receptor)=="Instance" and Receptor:IsA("Player") and Receptor:IsDescendantOf(game)
```

`Cobros.Give` localiza la `Instance` de moneda del receptor con `GetValue`, y **si no la
encuentra no hace nada**:

```lua
local stat = module.GetValue(Player, NameStats)
if stat then
	... module.SetAmount(...)
end
-- sin rama else, sin valor de retorno, sin aviso
```

`GetValue` busca dentro de las carpetas de `Index` —`leaderstats` entre ellas— que **solo
existen después de `hydrate`**. Un jugador que acaba de entrar aparece en `Players` y pasa
las tres comprobaciones de `Donar` mucho antes de tener esas carpetas.

#### Por qué esto puede ser un problema — HECHO

El cobro y la concesión no comparten condición de éxito:

| | Cobro (`charge`) | Concesión (`Give`) |
|---|---|---|
| Sobre quién | El emisor, ya cargado por definición (si no, `Donar` habría fallado antes al indexar `leaderstats`) | El receptor, que puede estar a medio cargar |
| Si la `Instance` no existe | `requirements` falla → devuelve `nil` → no se cobra | No hace nada, en silencio |
| Valor de retorno | `true` o `nil` | ninguno |

El resultado se comprueba en un lado y no en el otro. `Donar` nunca mira lo que devolvió
`Give`, porque `Give` no devuelve nada.

#### Teoría — TEORÍA

Donar a un jugador que todavía está cargando **destruye la moneda**: sale de la cuenta del
emisor, no entra en la del receptor, y además consume presupuesto del tope diario. Ambas
partes ven la notificación de éxito, porque las notificaciones se envían
incondicionalmente después:

```lua
Cobros.Give(Receptor, {Coins = Cantidad}, true)
Cash:SetAttribute("AmountSending", tostring(SumaTotal))
SentNotification(Player, "Server", `Has donado ${Cantidad} al jugador {Receptor.DisplayName}`, ...)
SentNotification(Receptor, "Server", `El jugador {Player.DisplayName} te ha donado ${Cantidad}`, ...)
return
```

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `Give` no tiene rama `else` cuando `stat` es `nil`, ni valor de retorno |
| 2 | `Donar` no comprueba el resultado de `Give` — no podría, aunque quisiera |
| 3 | `GetValue` depende de carpetas que crea `hydrate`, no de la presencia del jugador |
| 4 | Las notificaciones de éxito se emiten sin condicionar al resultado |
| 5 | El mismo patrón de escritura silenciosa aparece en `SetAmount`, que ignora la llamada si `value` o `Amount` son falsos |

#### Incógnitas

- Cómo elige el cliente al receptor. Si la interfaz solo lista jugadores con datos cargados,
  la ventana se estrecha mucho, pero un cliente modificado puede enviar cualquier `Player`
  igualmente: la validación del servidor es la única que cuenta.
- Si `Index` incluye alguna carpeta que exista antes de `hydrate`. No se ha leído completa.

#### Escenario de ejemplo

Dos amigos entran a la vez. Uno carga primero, abre el panel de donaciones, ve al otro en
la lista y le manda 500 Coins. El receptor todavía está montando su árbol de datos. El
emisor ve «Has donado 500», el receptor ve «te ha donado 500», y los 500 no existen en
ninguna parte.

**Comportamiento esperado:** o la donación llega, o se rechaza y no se cobra.
**Comportamiento posible:** se cobra, no llega, y ambos reciben confirmación de éxito.

#### Plan de verificación — *Ciclo de vida*, *Funcional*

1. En un place de pruebas, retrasa `hydrate` para una cuenta concreta (un `task.wait`
   temporal condicionado por `UserId`).
2. Con una segunda cuenta ya cargada, dispara `DonarCoins` hacia la primera durante ese
   retraso, desde la consola del cliente.
3. Anota los `Coins` del emisor antes y después.
4. Espera a que la primera cuenta termine de cargar y anota sus `Coins`.
5. Comprueba el atributo `AmountSending` del emisor.

**Pasa:** el emisor conserva sus Coins, o el receptor los recibe.
**Falla:** el emisor pierde los Coins, el receptor no los gana y `AmountSending` sube.

**Instrumentación sugerida:** hacer que `Collections.Give` devuelva cuántas estadísticas
aplicó realmente. Es un cambio de una línea que convertiría este fallo silencioso, y todos
los de su forma, en algo detectable — pero es un **cambio de código**, así que queda
registrado aquí y no aplicado.


## BUG-CANDIDATE-020

### El color de una superficie llega del cliente sin límite de tamaño y se guarda tal cual

**Sistema:** Tiendas / Casas / Seguridad · **Clasificación:** Observación / Requiere pruebas de seguridad
**Estado:** Sin verificar · **Gravedad si se confirma:** Alta · **Confianza:** Media

**Código relacionado:** `Core/…/Shared/Stores/init.luau`, `fn:ChangeDesing`;
`Core/…/Shared/Stores/HouseAdded.luau`, `module:ChangeDesing`;
`Core/…/Shared/BreakDown.luau`, `Set`
**Documentación relacionada:** [Tiendas y decoración](../systems/stores.md#quién-escribe-content-la-incógnita-cerrada)

#### Comportamiento observado — HECHO

El manejador del servidor filtra las claves con cuidado, pero solo una de ellas por valor:

```lua
for index, value in Valores do
	if index ~= "Material" then
		NewValores[index] = value            -- copiado tal cual
	else
		local material = DataDesing.FindMaterial(value)
		if material then ... end             -- validado contra el catálogo
	end
end
store:ChangeDesing(Data, NewValores)
```

`Material` se resuelve contra el catálogo y además exige haberlo comprado o tener el
gamepass. **`Color` no se valida en absoluto**: se copia y llega hasta la escritura:

```lua
Data.Desing[ListRuta[1]][ListRuta[2]][index] = breackdownValues.Set(value)
```

Y `BreakDown.Set` deja pasar las cadenas sin tocarlas:

```lua
module.DataNormal = { ['boolean'] = true, ['string'] = true, ['number'] = true }

function module.Set(Option)
	if module.DataNormal[typeof(Option)] then return Option end
	...
```

#### Por qué esto puede ser un problema — HECHO

Lo que se escribe es la sección `content` del perfil `World` de esa casa, a través de
`WorldService.UpdateStore("WorldContentStore", …)`. Es decir: **datos que el cliente
controla en tamaño y contenido acaban en el DataStore de una casa que puede no ser suya.**

El permiso necesario es bajo. `fn:GetStore` concede a cualquiera con un rol distinto de
`46`, no solo al dueño. Un invitado con permiso de construcción cumple.

Las validaciones que sí existen acotan la **forma** pero no el **tamaño**:

| Validación | Qué acota | Qué no |
|---|---|---|
| `ListRuta` de dos partes, ambas resueltas contra `Estructura` | Dónde se escribe | Cuánto |
| `if not Changes[index] then continue end` | Qué claves (`Color`, `Material`) | El valor de `Color` |
| `BreakDown.Set` | Que no sean tablas arbitrarias | Que las cadenas sean cortas |

#### Teoría — TEORÍA

Un cliente modificado puede disparar `ChangeDesing` con
`{ Color = string.rep("A", 200000) }` y hacer crecer el perfil `World` de la casa hasta
acercarse o superar el límite de 4 MB por clave de DataStore. A partir de ahí los guardados
de esa casa fallarían, y con suficientes fallos seguidos el cortacircuitos `Health` de
DataKit abriría el circuito para ese store.

El daño no lo sufre quien ataca: lo sufre **la casa**, y por tanto su dueño.

Hay una segunda vía, más lenta y con el mismo efecto: cada `(carpeta, modelo)` es una
ranura distinta, así que aunque hubiera un tope por valor, el número de ranuras multiplica
lo acumulable.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `NewValores[index] = value` sin ninguna comprobación para toda clave que no sea `Material` |
| 2 | `BreakDown.Set` devuelve las cadenas sin modificar ni medir |
| 3 | La escritura va a `WorldContentStore`, que `WorldService` mapea a la sección `content` del perfil `World` |
| 4 | El permiso lo concede `GetStore`, que acepta cualquier rol distinto de `46` |
| 5 | No hay límite de frecuencia en el remote `ChangeDesing` |
| 6 | El lado que renderiza **sí** es robusto: `ColorTexture.Color` sustituye cualquier valor que no sea `Color3` por blanco. El problema es de almacenamiento, no de renderizado |

#### Incógnitas

- Qué hace DataKit ante una escritura que supera el límite del DataStore: si rechaza
  limpiamente y deja el perfil anterior intacto, la gravedad baja mucho.
- Si `UpdateStore` valida el tamaño de la sección antes de escribir. `WorldService.UpdateStore`
  no se ha releído con esta pregunta en mente.
- Cuántas ranuras `(carpeta, modelo)` tiene una casa real. Determina el techo acumulable.

#### Escenario de ejemplo

Un jugador con rol de constructor en la casa de un amigo abre la consola y manda un color
de 200 000 caracteres para un suelo. Repite con cada superficie. La casa deja de guardar;
la siguiente sesión pierde el mobiliario colocado desde ese momento.

**Comportamiento esperado:** un color que no es un color se rechaza.
**Comportamiento posible:** se guarda, y el perfil de la casa se degrada.

#### Plan de verificación — *Seguridad*, *Persistencia*

1. En un place de pruebas, entra en una casa con una cuenta que tenga un rol distinto de
   `46` pero no sea la dueña.
2. Desde la consola del cliente, dispara `ChangeDesing` con
   `("Floors.Color1", { Color = string.rep("A", 1000) })`.
3. Lee la sección `content` del perfil de esa casa y comprueba si la cadena está ahí.
4. Si está, repite subiendo el tamaño y anota en qué punto empieza a fallar el guardado.
5. Comprueba si el fallo se reporta o pasa en silencio.

**Pasa:** el valor se rechaza por no ser un `Color3`, o `UpdateStore` corta por tamaño.
**Falla:** la cadena aparece íntegra en el perfil.

**Instrumentación sugerida:** registrar el tamaño serializado de cada sección al guardar.
Es información útil mucho más allá de esta entrada.

---

## BUG-CANDIDATE-021

### El dueño de una casa puede vender el mueble de un invitado y quedarse el reembolso

**Sistema:** Tiendas / Economía · **Clasificación:** Posible bug / Requiere pruebas multijugador
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Media

:::note Esto puede ser el diseño querido

«Es mi casa, puedo quitar lo que haya» es una regla perfectamente razonable. Lo que esta
entrada cuestiona no es que el dueño pueda **quitar** el mueble, sino **a quién se le paga**
cuando lo hace. Se registra como pregunta de diseño con evidencia, no como acusación.

:::

**Código relacionado:** `Core/…/Shared/Stores/init.luau`, `fn:SellDecors` y `fn:GetDecorPlayer`
**Documentación relacionada:** [Tiendas y decoración](../systems/stores.md#el-modelo-de-permisos)

#### Comportamiento observado — HECHO

`GetDecorPlayer`, en el servidor, busca primero en el índice del jugador que pregunta y
**luego en todo el mobiliario de la casa**, sin filtrar por dueño:

```lua
local list = Client and self.DecorsPlayer:Get() or Player and self.DecorsPlayer[Player.UserId]
if list then ... end

if self.Added and self.Added:IsA("House") then
	for i, v in self.Added.DecorChild do
		...
		for _, data in v do
			if IsValue and data.Boolean == decor then return data end
```

`SellDecors` acepta tres caminos, y el tercero solo mira quién es el dueño de la casa:

```lua
if Decor2.Boolean:IsDescendantOf(Player)
	or (self.Added:IsA("House") and Decor2.Owner == Player.UserId and (...)
	or (self.Added.DataBaseHouse and tonumber(self.Added.DataBaseHouse.OwnerId) == Player.UserId)) then

	local PriceDevolver = not Decor2.Boolean.Value and Decor2.Data.Price
	                       or self.Cobros.Lerp(Decor2.Data.Price, .7)
	debris:AddItem(Decor2.Boolean, 0)
	self.Cobros.Give(Player, PriceDevolver, true)
```

`Player` es siempre quien disparó el remote. El reembolso va a esa cuenta, sea o no quien
compró el mueble.

#### Por qué esto puede ser un problema — HECHO

El sistema **sí sabe** quién colocó cada mueble: `Object.OwnerPlace` viaja en el perfil y
`fn:SetStore` lo restaura al arrancar el servidor. `ExitModeConstruccion` lo usa para fijar
solo lo de cada jugador:

```lua
if data.Boolean:GetAttribute("OwnerPlace") == Player.UserId then
	data.Boolean.Value = true
end
```

La información de propiedad existe y se usa en otro sitio. En el reembolso no se consulta.

#### Teoría — TEORÍA

Un jugador invita a otro a su casa, el invitado compra y coloca mobiliario —pagándolo de su
bolsillo y consumiendo su tope diario de donación, que es justo lo que el código hace para
tratar eso como un regalo—, y después el dueño lo vende y cobra el 70 % del precio.

Lo que convierte esto en una vía de extracción, y no solo en una asimetría, es
precisamente ese tope: el juego reconoce que amueblar una casa ajena **es** transferir
valor, y le aplica el límite diario de 1 000. La venta por parte del dueño no tiene tope
equivalente.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `GetDecorPlayer` cae a `DecorChild` —todo el mobiliario de la casa— sin filtrar por dueño |
| 2 | El tercer disyuntor de `SellDecors` solo comprueba `OwnerId == Player.UserId` |
| 3 | `Cobros.Give(Player, …)` paga a quien llamó, no a `Decor2.Owner` |
| 4 | `Decor2.Owner` y el atributo `OwnerPlace` existen y se usan en `ExitModeConstruccion` y en la restauración |
| 5 | `BuyDecors` tiene la misma forma para «recoger»: el dueño se lleva el mueble a **su** inventario (`addInventory(Inventory, true)`) |
| 6 | Colocar en casa ajena consume el tope diario de donación; retirarlo no devuelve nada a ese tope |

#### Incógnitas

- Si la interfaz de la casa ofrece «vender» sobre muebles ajenos, o solo «devolver al
  inventario». Si solo ofrece lo segundo, hace falta un cliente modificado, lo que reduce
  la exposición pero no cierra el caso.
- Si `Decor2.Data.Price` de un mueble ajeno es el precio real pagado o el de catálogo.
- Si el equipo considera que retirar mobiliario ajeno debe reembolsar a alguien.

#### Escenario de ejemplo

Dos jugadores. A invita a B con rol de constructor. B compra mobiliario por 900 Coins y lo
coloca. A lo vende todo y recibe 630 Coins. B pierde 900 y ha gastado además su tope diario.
Repetible cada día, con cada invitado.

**Comportamiento esperado:** o el reembolso va a quien compró, o retirar mobiliario ajeno no
reembolsa a nadie.
**Comportamiento posible:** el reembolso va a quien pulsa el botón.

#### Plan de verificación — *Multijugador*, *Funcional*

1. Dos cuentas. A dueña de una casa, B con un rol distinto de `46`.
2. B compra un mueble y lo coloca dentro de la casa. Anota los Coins de ambos.
3. A dispara `SellDecor` sobre ese mueble.
4. Anota los Coins de ambos otra vez y comprueba si el mueble desapareció.
5. Repite con `BuyDecor` en modo «recoger» y mira en qué inventario acaba.

**Pasa:** B recibe el reembolso, o no lo recibe nadie.
**Falla:** A recibe el reembolso de un mueble que pagó B.

**Instrumentación sugerida:** registrar `Decor2.Owner` junto a quien llama en cada venta.
Un solo `warn` bastaría para saber si esto ocurre en producción.


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
| `EventService`, `ReferralService` | Sí | |
| `PlayerDataService`, `WorldSystem/PlayerDataReplicator.luau` | Sí | |
| `Data/Main/init.server.luau` | Sí | El orquestador de sesión; ver [Data.Main](../systems/session-orchestrator.md) |
| `AddValues`, `BreakDown` | En parte | Solo el camino de materialización de atributos, para cerrar la duda del tope de donación |
| `Collections` (moneda) | Sí | Leído entero: la pasada de seguridad (BUG-CANDIDATE-015), la ruta de persistencia (BUG-CANDIDATE-008) y la escritura silenciosa de `Give` (BUG-CANDIDATE-019) |
| `RoleService`, `EventCommands`, `ReferralCommands` | **En parte** | Solo la ruta de autorización, para la pasada de seguridad |
| `machines/Machine`, `machines/PopTheLock` | **En parte** | Solo las rutas de enlace y de premio |
| `GlobalDataStore`, `GiftInbox` | **No** | Ambos usan DataStoreService fuera de DataKit |
| `Shared/Stores`: `init`, `HouseAdded`, `ColorTexture` | Sí | Los trece manejadores de remotes y el ciclo de `content` |
| `Shared/Stores`: `Compras` | En parte | Solo `Comprar` y la forma general |
| `Shared/Stores`: `Added`, `DecorFuncs/`, `DecorsPlayer` | **No** | En cola |
| Sistemas de juego (~470 archivos) | **No** | En cola |
| 320 binarios `.rbxm` | **No inspeccionables** | |

Que un área no tenga entrada en esta página significa que **no se ha examinado**, no que
esté limpia.

### Alcance de la revisión de seguridad

La pasada de seguridad no fue una auditoría. Se buscaron patrones concretos sobre la
superficie ya leída:

- remotes que conceden valor (moneda, artículos, recompensas);
- remotes que aceptan cantidades, precios o identificadores del cliente;
- comandos de administración y cómo se autorizan;
- secretos y credenciales en el código;
- límites de frecuencia en remotes que provocan trabajo caro;
- comprobaciones de propiedad antes de actuar sobre datos de otro jugador.

**No** se han revisado: los ~200 remotes de `Interactable`, `Karaoke`, `Stores`, `Tools` y
`Paint`; la ruta de `Monetization` y compras con Robux; ni el sistema de construcción. Son
exactamente el tipo de superficie donde suelen aparecer más hallazgos, así que esta sección
debe leerse como un primer barrido, no como una garantía.
