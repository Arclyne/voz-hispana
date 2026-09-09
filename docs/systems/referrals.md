---
sidebar_position: 4
title: Invitaciones
---

# Invitaciones

Sistema de «invita a un amigo»: un jugador comparte un enlace o un código, quien entra por
él queda atribuido, y cuando cumple unos minutos de juego el invitador suma un amigo y
puede reclamar recompensas.

`ReferralService.luau` tiene **1 243 líneas**, el módulo propio más grande del repositorio,
y está muy comentado en el propio código. Esta página resume su forma y destaca lo que
importa para el resto del sistema.

## Componentes

| Componente | Ruta | Papel |
|---|---|---|
| `ReferralService` | `Core/ServerStorage/WorldSystem/ReferralService.luau` | Toda la lógica |
| `ReferralConfig` | `Core/ReplicatedStorage/Shared/Referrals/ReferralConfig.luau` | Todo lo ajustable: minutos, ventana, recompensas, límites |
| `ReferralShared` | `Core/ReplicatedStorage/Shared/Referrals/ReferralShared.luau` | Cálculos que comparten cliente y servidor |
| `ReferralMain` | `Core/…/ServerScripts/Referrals/ReferralMain.server.luau` | Enganche al ciclo de vida y remotes |
| `ReferralCommands` | `Core/…/ServerScripts/Referrals/ReferralCommands.server.luau` | Comandos de administración |
| `ReferralClient` | `Core/…/Client/ReferralClient/ReferralClient.server.luau` | La tablet |
| `Profiles.ReferralCode` | `Core/ServerStorage/WorldSystem/Profiles.luau` | Registro de códigos manuales |

**HECHO.** El módulo declara en su cabecera que no hay números sueltos: todo lo ajustable
está en `ReferralConfig`.

## El recorrido de una invitación

**HECHO.** La cabecera del archivo lo enumera, y el código lo cumple:

```mermaid
sequenceDiagram
    autonumber
    participant I as Invitado
    participant RS as ReferralService
    participant PI as Perfil del invitado
    participant PV as Perfil del invitador

    I->>RS: entra con ?ref= o con un código
    RS->>RS: OnPlayerReady — ¿perfil nuevo de verdad?
    RS->>RS: hasVoiceChat(userId)
    RS->>PI: SetInviter — inviterId, startedAt, consumed = true
    RS->>PI: store:save("referral:attributed")
    RS->>PV: send { kind = "referralPending" }

    loop mientras juega
        RS->>RS: Tick(player, delta) — suma segundos
        RS->>PI: flush en checkpoints
    end

    RS->>RS: alcanza los minutos requeridos
    RS->>PI: marca done
    RS->>PV: send { kind = "referralCompleted" }
    Note over PV: el handler onMessage de Profiles<br/>suma amigo y créditos, de forma idempotente
```

**HECHO — el mensaje llega esté el invitador conectado o no.** `send` escribe en la cola
durable del perfil destino; ver [Persistencia](../architecture/persistence.md). El
invitador no tiene que estar en el juego, ni siquiera en el mismo servidor.

## Cómo se defiende de abusos

`SetInviter` es la función mejor defendida del código revisado. **HECHO**, cada
comprobación en orden:

| Comprobación | Motivo |
|---|---|
| `ReferralConfig.Enabled` | Interruptor global |
| `inviterId <= 0` | Entrada basura |
| `inviterId == player.UserId` | **No puedes invitarte a ti mismo** |
| `referral.consumed` | Una invitación por cuenta, para siempre |
| `referral.inviterId > 0` | Ya tiene invitación en curso |
| `attributing[player]` | Guarda de reentrada |
| `hasVoiceChat(player.UserId)` | Al que echan por no tener micro no cuenta |
| `player.Parent ~= Players` | Se fue mientras comprobábamos la voz |
| Re-lectura de `inviterId` | **Alguien pudo atribuirlo mientras esperábamos a Roblox** |

**INFERENCIA — las dos últimas son las que distinguen este código.** La comprobación de
chat de voz cede el hilo, y el autor lo sabe: la guarda `attributing` existe para eso, y su
comentario lo dice —*«un link y un codigo metidos a la vez podrian colar dos invitadores
para el mismo jugador»*—, pero además **vuelve a leer el perfil después del yield** en vez
de fiarse de la lectura anterior. Es exactamente el error que la mayoría del código de
Roblox comete y este no.

**HECHO.** El requisito de chat de voz enlaza con la puerta de entrada del juego: la
cabecera dice *«al que echan por no tener micro no llega a contar»*. Ver
[BUG-CANDIDATE-001](../testing/verification-plan.md#bug-candidate-001).

## Persistencia: el patrón correcto, escrito y razonado

**HECHO.** `ClaimReward` tiene este comentario, y el código lo cumple:

```lua
--[[
	El orden importa: primero se marca como reclamado y se guarda, y solo despues
	se da el dinero. Al reves, un fallo de guardado dejaria al jugador cobrando el
	mismo hito una y otra vez.
]]
```

La secuencia real es:

1. `store:update` marca la recompensa como reclamada;
2. `store:save("referral:claim")` — **y se comprueba el resultado**:
   ```lua
   if not store:save("referral:claim") then
       return false, "No se pudo guardar. Intentalo otra vez."
   end
   ```
3. solo entonces `giveReward`.

**HECHO.** `SetInviter` hace lo mismo por el mismo motivo:

```lua
-- Se persiste ya: si el servidor se cae en el proximo minuto, la invitacion
-- no se pierde.
store:save("referral:attributed")
```

**INFERENCIA — y esto importa más allá de este sistema.** El repositorio **contiene** el
patrón correcto para mover valor: persistir el apunte contable primero, verificar que se
guardó, y solo después mover el valor. Está escrito a propósito y con el razonamiento
documentado.

La ruta de compra de la tienda hace lo contrario —concede primero, cobra después, sin
comprobar el guardado— y por rutas de persistencia distintas. Que ambos patrones convivan
en el mismo repositorio es lo que convierte
[BUG-CANDIDATE-008](../testing/verification-plan.md#bug-candidate-008) en una
inconsistencia y no en una diferencia de criterio.

## Idempotencia de los mensajes

**HECHO.** Los mensajes que recibe el invitador los consume el handler `onMessage` de
`Profiles.WorldsPlayer`, y ese handler **tiene que ser idempotente** porque `Store` puede
reejecutarlo si falla un guardado. `Profiles.luau` lo respeta marcando en vez de borrando:

```lua
-- La red de seguridad contra el doble conteo: si esta entrada ya se cobro, no
-- se vuelve a sumar pase lo que pase.
if typeof(entry) == "table" and entry.paid then
    return data
end
```

Ver [Persistencia](../architecture/persistence.md) para el contrato completo.

## Cachés y coste

**HECHO.** El sistema evita deliberadamente MemoryStore, y dice por qué:

```lua
-- Este sistema no usa MemoryStore directamente: la cuota del universo ya nos dio
-- un susto en agosto. El unico roce es el timbre de DataKit al hacer `send`, que
-- es best-effort y si falla el mensaje llega igual por DataStore.
```

**HECHO.** Dos cachés acotan el coste:

| Caché | Valor | Motivo declarado en el código |
|---|---|---|
| `PROGRESS_CACHE_SECONDS` | 60 s | *«Sin esto, tener la tablet abierta seria una lectura de DataStore por segundo»* |
| Sesión en memoria | checkpoints | *«Escribir el perfil una vez por segundo seria absurdo»* |

**INFERENCIA.** La elección de 60 s no es arbitraria: el propio comentario razona que el
invitado solo persiste su avance cada `ProgressCheckpointSeconds`, así que leer más a
menudo no daría un dato más exacto. Es una caché dimensionada contra la frecuencia real de
escritura, no un número redondo.

## Administración

**HECHO.** `ReferralCommands` está restringido a administradores con
`Admins:IsRole(player, "Admins")`, igual que `EventCommands`. Las operaciones
administrativas que expone `ReferralService`:

| Función | Qué hace |
|---|---|
| `SetPartnerRate(userId, rate)` | Fija la tarifa de créditos por amigo de un creador |
| `MarkPaid(userId, amount)` | Apunta un pago ya realizado |
| `AssignCode(userId, rawCode, ownerName)` | Registra un código manual de invitación |
| `GetSummary(userId)` | Resumen de un usuario |
| `DebugForceInvite`, `DebugSession` | Depuración |

**HECHO.** Los tres primeros funcionan sobre jugadores **desconectados**, usando `send`
sobre su perfil (`referralPartner`, `referralPaid`, `referralCode`). Ver los handlers en
`Profiles.luau`.

**HECHO.** `Profiles.ReferralCode` usa `onConflict = "deny"`, y el código explica el
motivo:

```lua
`onConflict = "deny"` porque dos servidores asignando el mismo codigo a la vez
debe fallar, no robarse el candado.
```

## La configuración, que es el único archivo que hay que tocar

**HECHO.** `Shared/Referrals/ReferralConfig.luau` concentra todo lo ajustable, y **se
documenta a sí mismo mejor que la mayoría de este sitio**: cada constante lleva escrito no
solo qué hace, sino por qué vale lo que vale. Aquí solo se resume; para decidir un cambio,
léelo.

| Ajuste | Valor | Lo que dice su propio comentario |
|---|---|---|
| `RequiredSeconds` | 15 min | Lo que tiene que jugar el invitado |
| `AccumulateAcrossSessions` | `true` | «Acumular convierte muchas más invitaciones; de una sentada es más difícil de falsear. Con el chat de voz obligatorio y la cuenta mínima, acumular sale bien parado» |
| `PendingWindowSeconds` | 48 h | Cuánto vive la invitación antes de caducar sin premio |
| `ReconnectGraceSeconds` | 90 s | Para que un teleport a una casa o al karaoke no cuente como irse |
| `ProgressCheckpointSeconds` | 180 s | «Más bajo = barra más fina y más escrituras» |
| `MinAccountAgeDays` | **0** | Desactivado a propósito, y razonado abajo |
| `MaxPendingPerInviter` | 50 | Acota las lecturas de DataStore de la tablet, no el total de amigos |

**El caso de `MinAccountAgeDays = 0` merece leerse**, porque es una decisión deliberada que
parece un descuido:

> Se comprueba AL COMPLETAR, no al entrar. Ojo: con la ventana de 48 h, cualquier valor
> mayor que 2 deja fuera para siempre a quien se cree la cuenta para el vídeo de un
> youtuber. El chat de voz ya exige cuenta verificada, que es el filtro real.

Es exactamente el tipo de razonamiento que esta documentación busca registrar: el filtro no
se quitó por dejadez, se quitó porque duplicaba otro que funciona mejor y rompía el caso de
uso principal.

### La escalera de recompensas

**HECHO.** Catorce hitos, de 1 a 14 amigos, y después una recompensa por defecto de 400
Coins por cada amigo adicional.

**OBSERVACIÓN.** La curva **no es monótona**: el sexto amigo paga 400 y el quinto pagaba
500; el undécimo paga 700 y el décimo pagaba 1 200. No es un error — el comentario declara
«saltos gordos en el 5, el 10 y el 14 para que haya metas visibles», así que los hitos
sobresalen y los intermedios vuelven a la curva base. Se anota porque a primera vista parece
una errata.

**HECHO.** Y hay un aviso escrito que conviene respetar:

> `Id` es permanente y es por lo que se guarda lo reclamado. **NUNCA reutilices un Id
> borrado**, o alguien podría reclamar dos veces.

## Los tres remotes, y por qué el de compartir vive en el servidor

| Remote | Tipo | Qué hace |
|---|---|---|
| `GetReferralState` | `RemoteFunction` | Devuelve el estado del propio jugador |
| `ShareReferralLink` | `RemoteEvent` | Abre la hoja de compartir de Roblox |
| `ClaimReferralReward` | `RemoteEvent` | Reclama un hito, delegando en `ReferralService.ClaimReward` |

**HECHO.** `PromptLinkSharingAsync` **solo se puede llamar desde el servidor**, de ahí que
compartir sea un remote y no una acción de cliente. Y está bien protegido:

| Control | Cómo |
|---|---|
| No se solapan dos compartires | El mapa `sharing[player]`, limpiado también en `PlayerRemoving` |
| Studio no enseña un error falso | Roblox devuelve 403 a los share links fuera de un servidor publicado, así que se detecta y se avisa con `"studio"` |
| Un valor de caducidad que Roblox rechace no deja sin link | Se reintenta una vez sin `ExpirationSeconds`, con el valor por defecto de Roblox |
| No se responde a quien ya se fue | `if player.Parent == Players` antes de `FireClient` |

## Tres decisiones del bucle que merecen leerse

`ReferralMain.server.luau` explica sus tres decisiones no obvias, y las tres son correctas:

**1. Se suma lo que `task.wait` durmió de verdad, no el nominal.**

```lua
local elapsed = task.wait(TICK_SECONDS)
ReferralService.Tick(player, elapsed)
```

> `task.wait` devuelve lo que durmió de verdad, que con el servidor cargado es más que
> `TICK_SECONDS`; sumar el nominal haría los 15 minutos más largos.

**2. No se recorre `Players:GetPlayers()` al arrancar.**

> `PlayerInit` ya reejecuta el callback para los jugadores que estaban dentro cuando se
> registra, así que **NO** hay que recorrer `Players:GetPlayers()` aparte: serían dos bucles
> sumando segundos al mismo jugador.

Es una consecuencia directa de lo que documenta [`PlayerInit`](/api/PlayerInit), y de las
pocas veces en el repositorio en que un consumidor demuestra haber leído ese contrato.

**3. El volcado va por `onBeforeClose`, no por `PlayerRemoving`.**

Y esta es la importante:

> `PlayerDataInit` también escucha `PlayerRemoving` para cerrar el perfil, y **el orden
> entre dos conexiones al mismo evento no está garantizado**. Si el perfil se cerrara
> primero, los segundos de la sesión se perderían y un teleport a una casa reiniciaría la
> cuenta. `onBeforeClose` corre siempre antes del cierre.

:::tip Aquí está la solución a un problema registrado en otro sistema

Ese es **exactamente** el riesgo que
[BUG-CANDIDATE-018](../testing/verification-plan.md#bug-candidate-018) describe en
[`Data.Main`](./session-orchestrator.md): dos manejadores de `Players.PlayerRemoving`, sin
orden garantizado, y una limpieza que se pierde según cuál gane.

Este sistema se topó con el mismo problema, lo entendió y lo resolvió usando
`PlayerDataService.onBeforeClose`, que sí tiene orden garantizado respecto al cierre del
perfil. **El patrón de arreglo ya está en el repositorio**, escrito y razonado, a dos
directorios de distancia del sitio donde falta.

:::

## Puntos de verificación

Ninguna entrada nueva. Este sistema es el mejor defendido de los revisados, y sus
contribuciones al plan de verificación son como **contraste**, no como hallazgo:

| Aporta a | Cómo |
|---|---|
| [BUG-CANDIDATE-008](../testing/verification-plan.md#bug-candidate-008) | Demuestra que el patrón correcto de orden de persistencia ya existe y está razonado en el repositorio |
| [BUG-CANDIDATE-001](../testing/verification-plan.md#bug-candidate-001) | Depende del control de chat de voz para no contar invitaciones que luego se expulsan |

## Implementación relacionada

| Aspecto | Código |
|---|---|
| Atribución | `ReferralService.luau`, `SetInviter`, `AttributeFromJoin`, `ReadInviteJoinData` |
| Progreso | `ReferralService.luau`, `Tick`, `flushSession`, `completeReferral` |
| Lectura para la tablet | `ReferralService.luau`, `GetState`, `readInviteeProgress`, `prunePending` |
| Recompensas | `ReferralService.luau`, `ClaimReward`, `giveReward` |
| Compartir | `ReferralService.luau`, `GetShareOptions` |
| Administración | `ReferralService.luau`, `SetPartnerRate`, `MarkPaid`, `AssignCode` |
| Consumo de mensajes | `Profiles.luau`, `applyReferralPending`, `applyReferralCompleted` |
