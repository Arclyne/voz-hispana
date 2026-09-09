# Progreso de la documentación

> Memoria persistente del proyecto de documentación técnica de Voz Hispana.
> **Léelo entero antes de hacer cualquier trabajo de documentación.**
>
> Rama de trabajo: `docs/moonwave-documentation`
> Regla vigente: **solo documentación** — ningún Lua/Luau ejecutable puede cambiar.
> Idioma: **español**, tanto en el sitio como en los comentarios que se añaden al código.

---

## Fase actual

**Fase 3 — Sistemas** (Casas, Datos del jugador, `Data.Main`, Eventos e Invitaciones
documentados; faltan los sistemas de juego). La **Fase 5 — análisis transversal** ya está cerrada: se
adelantó porque el grafo de dependencias solo tiene sentido con varios sistemas leídos, y
ya lo estaban.

---

## Progreso general

**42 %**

Justificación del número (deliberadamente conservadora): el repositorio tiene
**552 archivos `.luau` inspeccionables / ~80 450 líneas** más **320 binarios `.rbxm` no
inspeccionables**. Las fases 0, 1, 2 y 5 están completas, y de la 3 hay cuatro sistemas
documentados a fondo. **45 de 552 archivos leídos** (estado por archivo en
`docs/reference/script-inventory.md`).

Eso es un 8 % por número de archivos, pero una porción mucho mayor del código que sostiene
todo lo demás: el arranque completo, el sistema de mundos/casas entero, las capas de
reserva y presencia, el paquete de persistencia, la capa de datos del jugador, eventos e
invitaciones, y `Data.Main`, el archivo que ata todo lo demás. Los ~507 archivos restantes son sistemas de juego (interactuables, karaoke,
máquinas, herramientas, tiendas, misiones, trabajos) más librerías de terceros
empaquetadas.

El porcentaje **no** está ponderado por número de archivos a propósito: la mayor parte de
lo que queda son hojas de gameplay cuyo valor documental por archivo es mucho menor que el
del arranque. Refleja: 10 páginas de arquitectura + 7 de casas + 4 de sistemas +
3 de referencia + 19 candidatos a bug con evidencia, frente a un plan que aún necesita
~8 sistemas más y la pasada Moonwave por script.

---

## Fases

- [x] Fase 0 — Análisis inicial
- [x] Fase 1 — Infraestructura de documentación
- [x] Fase 2 — Arquitectura
- [ ] Fase 3 — Sistemas *(Casas, Datos del jugador, `Data.Main`, Eventos, Invitaciones hechos)*
- [ ] Fase 4 — Referencia por script y Moonwave
- [x] Fase 5 — Análisis transversal
- [ ] Fase 6 — Validación y planificación de pruebas

---

## Hechos del repositorio (Fase 0 — establecidos por inspección directa)

### Herramientas de build / sincronización

| Hecho | Evidencia |
|---|---|
| Proyecto Rojo, Rojo `7.7.0` fijado con Rokit | `rokit.toml`, `default.project.json` |
| Servicios mapeados: `ReplicatedFirst`, `ReplicatedStorage`, `ServerScriptService`, `ServerStorage`, `StarterGui`, `StarterPack`, `StarterPlayer` | `default.project.json` |
| `StarterPack` está declarado en `default.project.json` pero **`src/StarterPack` no existe en disco** | `default.project.json` vs `find src -maxdepth 1` |
| Hay un `sourcemap.json` versionado (~1,1 MB) en la raíz | listado de la raíz |

### Inventario de archivos

| Extensión | Cantidad |
|---|---|
| `.luau` | 552 |
| `.json` (`.meta.json` / `.model.json` / otros) | 503 |
| `.rbxm` (**binario, no inspeccionable**) | 320 |
| `.gitkeep` | 11 |
| `.txt` | 2 |

Clasificación de los `.luau` (por convención de nombre, que es de donde Rojo deriva la
clase):

| Tipo | Cantidad |
|---|---|
| `ModuleScript` | 445 |
| `Script` (`*.server.luau`) | 96 |
| `LocalScript` (`*.client.luau`) | 11 |

Total de Luau inspeccionable: **~80 450 líneas**.

### Distribución del Luau por zona

| Archivos | Líneas | Zona |
|---|---|---|
| 416 | 56 896 | `TemplatesTesting/Core/ReplicatedStorage` |
| 80 | 12 322 | `TemplatesTesting/Core/ServerScriptService` |
| 33 | 7 062 | `TemplatesTesting/Core/ServerStorage` |
| 8 | 2 757 | `TemplatesTesting/BuildingSystem/ReplicatedStorage` |
| 4 | 858 | `TemplatesTesting/PlayerHouses/ServerScriptService` |
| 3 | 171 | `ServerStorage/Templates` |
| 1 | 68 | `TemplatesTesting/GameWorlds/ServerScriptService` |
| 1 | 10 | `TemplatesTesting/PlayerHouses/ReplicatedStorage` |
| 1 | 26 | `TemplatesTesting/Core/StarterGui` |
| 5 | 366 | arranque en la raíz (`ServerScriptService/*`, `ReplicatedStorage/*`) |

### Remotes / Bindables (declarados como `.model.json` de Rojo)

| ClassName | Cantidad |
|---|---|
| `RemoteEvent` | 174 |
| `RemoteFunction` | 40 |
| `BindableEvent` | 11 |
| `BindableFunction` | 1 |

Lista completa extraída: `docs/reference/remotes.md`.

### Hechos sobre los `.meta.json`

- Hay 170 archivos `.meta.json`.
- **104 de ellos ponen `Disabled: true`.** Esto sostiene todo el arranque:
  `InitScripts.server.luau` reactiva los `BaseScript` desactivados cuando las plantillas
  terminan de importarse.
- `RunContext` está puesto explícitamente en 74 scripts: **47 `Server`, 27 `Client`**.
  Consecuencia (HECHO): muchos archivos llamados `*.server.luau` bajo
  `Core/ReplicatedStorage/Client/` son en realidad `Script` **de contexto cliente**. El
  sufijo del archivo no distingue cliente de servidor en este repositorio — hay que mirar
  el `.meta.json` hermano.
- Etiquetas observadas: `IgnoreAutoEnable` (4), `IgnoreLoader` (2), `Weight` (2),
  `TagEditorTagContainer` (1), `Configuration` (1), `InteractiveTool` (1).

### Puntos de entrada (HECHO)

Solo existen **dos** `Script` de servidor fuera de las plantillas, ambos en
`ServerScriptService` y ambos etiquetados `IgnoreLoader`:

1. `src/ServerScriptService/ImportTemplates.server.luau`
2. `src/ServerScriptService/InitScripts.server.luau`

Más dos módulos compartidos en `ReplicatedStorage`:

3. `src/ReplicatedStorage/PlayerInit.luau` — reparto diferido de `PlayerAdded`
4. `src/ReplicatedStorage/InitAfterTemplates.luau` — barrera bloqueante «plantillas listas»

Y un script de contexto cliente: `src/ReplicatedStorage/Client/visualsManager.server.luau`
(`RunContext: Client`, `Disabled: true`).

### Sistema de plantillas (HECHO)

`ImportTemplates.server.luau` carga tres assets de Roblox por ID con
`InsertService:LoadAsset` y fusiona su contenido dentro de los servicios vivos:

| ID del asset | Plantilla | Carpeta de override local |
|---|---|---|
| `137484964666215` | `Core` (comentario: «siempre el primero») | `ServerStorage/TemplatesTesting/Core` |
| `92258948630058` | `GameWorlds` | `ServerStorage/TemplatesTesting/GameWorlds` |
| `94091855508048` | `BuildingSystem` | `ServerStorage/TemplatesTesting/BuildingSystem` |

`ServerStorage/TemplatesTesting/PlayerHouses` existe en disco pero **no** está en
`TEMPLATES_IDS`. **DESCONOCIDO** — ver *Incógnitas* más abajo.

### Uso de servicios de Roblox (archivos que tocan cada API)

| API | Archivos |
|---|---|
| `MessagingService` | 9 |
| `MemoryStoreService` | 6 |
| `BindToClose` | 8 |
| `TeleportService` | 4 |
| `ReserveServer` | 4 |
| `DataStoreService` | 4 |
| `TeleportAsync` | 3 |
| `ReservedServerAccessCode` | 3 |
| `GetJoinData` | 5 |
| `PrivateServerId` | 1 |

---

## Arquitectura

| Página | Archivo | Estado |
|---|---|---|
| Visión general | `docs/architecture/overview.md` | Documentada |
| Inicialización | `docs/architecture/initialization.md` | Documentada (2 diagramas) |
| Ciclo de vida del servidor | `docs/architecture/server-lifecycle.md` | Documentada (3 diagramas) |
| Ciclo de vida del jugador | `docs/architecture/player-lifecycle.md` | Documentada (4 diagramas) |
| Ciclo de vida del personaje | `docs/architecture/character-lifecycle.md` | Documentada (2 diagramas) |
| Ciclo de vida del cliente | `docs/architecture/client-lifecycle.md` | Documentada (1 diagrama) — **incompleta por construcción**, ver U-001 |
| Red | `docs/architecture/networking.md` | Documentada — alcance acotado, ~200 remotes de gameplay sin revisar |
| Persistencia | `docs/architecture/persistence.md` | Documentada (2 diagramas) |
| Servidores reservados | `docs/architecture/reserved-servers.md` | Documentada (2 diagramas) |
| Dependencias | `docs/architecture/dependencies.md` | Documentada (1 diagrama) — Fase 5 |
| Flujo de datos | — | **No escrita.** Absorbida por Persistencia y Red; solo merece página propia si un sistema posterior enseña un flujo que esas dos no cubran. |

Total de la capa de arquitectura: **18 diagramas Mermaid**.

---

## Sistemas

Lista de sistemas derivada de los límites reales de directorio/namespace del repositorio.

| Sistema | Ubicación principal | Estado |
|---|---|---|
| Arranque / carga de plantillas | `src/ServerScriptService`, `src/ReplicatedStorage` | **Documentado** (capa de arquitectura) |
| Mundos y Casas (`WorldSystem`) | `Core/ServerStorage/WorldSystem`, `Core/…/WorldManager.server.luau`, `PlayerHouses/*`, `GameWorlds/*` | **Documentado** — 7 páginas, 9 diagramas, 10 candidatos a bug. No `Verificado`: eso exige Studio. |
| Persistencia (`DataKit`) | `Core/ServerStorage/DataKit` | **Documentado** (capa de arquitectura); `Store.transfer` e `Inbox` siguen sin leerse |
| Datos del jugador | `Core/ServerStorage/WorldSystem/PlayerData*`, `Core/…/PlayerDataInit.server.luau`, `Client/EconomySystem/Collections.luau` | **Documentado** — `docs/systems/player-data.md`, 2 diagramas |
| Orquestación de sesión (`Data.Main`) | `Core/ServerScriptService/Data/Main/init.server.luau` | **Documentado** — `docs/systems/session-orchestrator.md`, 1 diagrama |
| Eventos programados | `Core/ServerStorage/WorldSystem/EventService.luau`, `EventBootstrap`, `EventCommands` | **Documentado** — `docs/systems/events.md`, 2 diagramas |
| Invitaciones (referidos) | `Core/ServerStorage/WorldSystem/ReferralService.luau`, `Shared/Referrals` | **Documentado** — `docs/systems/referrals.md`, 1 diagrama |
| Inventario / Herramientas | `Core/…/ServerScripts/inventory`, `ToolsServer`, `ToolPlacementServer`, `Client/inventory` | Pendiente |
| Interactuables | `Core/…/ServerScripts/interactable`, `Client/interactable` | Pendiente |
| Máquinas de arcade | `Core/…/ServerScripts/machines`, `Shared/machines`, `Shared/pong` | Leído en parte (pasada de seguridad → BUG-CANDIDATE-016) |
| Karaoke | `Shared/Karaoke`, `ServerStorage/BusquedaMusicas.luau` | Pendiente |
| Paint | `Shared/Paint`, `interactable/Paint`, `ServerStorage/Paint` | Pendiente |
| Tiendas / Economía | `ShopServerSystem`, `Shared/Stores`, `Shared/ComprasTablero`, `ShopInfo` | Leído en parte (`ProcessPurchase`) |
| Monetización | `Shared/Monetization`, `Events/Monetization`, `WorldSystem/GamePassService` | Pendiente |
| Misiones | `ServerScripts/Quests`, `Shared/Quests`, `Client/QuestClient` | Pendiente |
| Animación | `ServerScripts/AnimationSystem`, `Client/Animator`, `Client/animation` | Pendiente |
| Ragdoll | `ServerScripts/Ragdoll`, `Client/Ragdoll` | Pendiente |
| Trabajos | `Shared/JobSystem`, `Events/Jobs` | Pendiente |
| Nametags / Micrófono | `NametagServer`, `Shared/Nametag`, `MicManagerServer`, `NametagMicClient` | Pendiente |
| Sistema de construcción | `BuildingSystem/ReplicatedStorage/BuildInterface` | Pendiente |
| Cocina / Comida | `ServerScripts/cooking`, `Shared/cooking`, `Client/cooking` | Pendiente |
| Framework de UI (`Icon`, `Kinetic`) | `Shared/Icon`, `Kinetic` | Pendiente (con toda probabilidad, de terceros) |
| Librerías de terceros | `Shared/Promise`, `Shared/Signal`, `Shared/Trove`, `Shared/Sift`, `Shared/FastCastRedux`, `Shared/Observers`, `Shared/PartCache` | Pendiente (marcar como terceros, documentar solo la frontera) |

Ningún sistema ha llegado a `Verificado`. Verificar exige ejecutar los planes de
`docs/testing/verification-plan.md`, y eso necesita Roblox Studio.

### Casas — detalle

**Estado:** Documentado (no Verificado — verificar exige Roblox Studio)

Páginas: `docs/systems/housing/` — `overview.md`, `identity.md`, `persistence.md`,
`entry-flow.md`, `server-lifecycle.md`, `permissions.md`, `error-handling.md`.

Documentación conceptual:

- [x] Visión general, responsabilidades, componentes, arquitectura
- [x] Identidad de la casa, creación, propiedad, compra (casas **y** espacios)
- [x] Ciclo de vida persistente de la casa
- [x] Ciclo de vida del servidor reservado, incluidos «reservado y nunca visitado» y
      «último jugador»
- [x] Red (`JoinServer` / `JoinWorld` y los remotes administrativos)
- [x] Persistencia (`Profiles.World`, `onConflict = "deny"`, la proyección de tarjeta, las
      cuatro ubicaciones de almacenamiento)
- [x] Permisos — los cuatro controles, roles, baneos, invitados, privada/pública
- [x] Concurrencia
- [x] Limpieza y orden de apagado
- [x] Manejo de errores — matriz completa de fallos

Diagramas (9 en las páginas de casas, más 2 en la página de arquitectura de servidores
reservados):

| # | Diagrama | Página |
|---|---|---|
| 1 | Arquitectura de casas | `overview.md` |
| 2 | Secuencia de compra de casa | `identity.md` |
| 3 | Montaje del navegador de casas | `identity.md` |
| 4 | Ciclo de vida persistente de la casa (estados) | `persistence.md` |
| 5 | Ciclo de vida del servidor reservado (estados) | `server-lifecycle.md` |
| 6 | Flujo de apagado | `server-lifecycle.md` |
| 7 | Flujo de entrada del jugador, con el arranque del servidor reservado dentro | `entry-flow.md` |
| 8 | Decisión de `canHostWorld` | `permissions.md` |
| 9 | Decisión de `canPlayerEnter`, con sus disparadores | `permissions.md` |
| 10 | Secuencia de reserva de servidor | `architecture/reserved-servers.md` |
| 11 | Decisión de concurrencia / reserva | `architecture/reserved-servers.md` |

Dos vistas que **no** se dibujaron, a propósito:

- **Entrada de invitados** — es el mismo camino con otro resultado de `canHostWorld`; un
  diagrama aparte duplicaría la secuencia de entrada, que ya está.
- **Registro / lease** — los dos registros ya están cubiertos por una tabla comparativa
  más la secuencia de reserva; una tercera vista solo los repetiría.

Scripts:

- `WorldManager.server.luau` — Analizado
- `ServerPresence.luau` — **Documentado** (Moonwave)
- `Profiles.luau` — Analizado
- `PlayerSchema.luau` — Analizado
- `PlayerWorld_Init.lua.server.luau` — Analizado
- `WorldService.luau` — Analizado
- `WorldDataReplicator.server.luau` — Analizado
- `ModeratorManager.server.luau` — Analizado
- `PublicServerInit.lua.server.luau` — Analizado
- `ServerDirectory.server.luau` — Analizado
- `WorldsBrowser.server.luau` — Analizado
- `PlayerDataReplicator.server.luau` — Analizado
- `ShopServerSystem.server.luau` — Analizado en parte (solo `ProcessPurchase`)
- `HousesInfo.luau`, `RolesInfo.luau`, `GeneralConfiguration.luau` — Analizados
- `GamePassService/*` — Pendiente

Incógnitas todavía abiertas: **U-002** (cómo se importa `PlayerHouses`), **U-007** (nada
impone `slots` como límite de casas abiertas) y la sección `content` del perfil `World`,
que está declarada y ningún script leído hasta ahora escribe — el candidato a escritor es
`BuildingSystem`.

Posibles bugs: BUG-CANDIDATE-004, 005, 006, 008, 009, 010, 011, 012, 013, 014.

---

## Scripts

**El estado por archivo vive en `docs/reference/script-inventory.md`**, que genera
`.github/scripts/generate-script-inventory.py` y lista los 552 archivos con su ruta en
ejecución dentro del DataModel, su `RunContext`, si está desactivado, sus líneas y su
estado.

Resumen a día de hoy:

| Estado | Cantidad |
|---|---|
| **Documentado** (leído entero + anotado con Moonwave por este proyecto) | 2 |
| Analizado (leído entero, descrito en el sitio) | 35 |
| Analizado (en parte) | 8 |
| Pendiente | 507 |

Las lecturas parciales y por qué:

| Archivo | Qué se leyó | Qué no |
|---|---|---|
| `DataKit/Store.luau` (1 237 líneas) | Resolución de propiedad, staging, guardado/cierre, heartbeat | `transfer`, la tubería de mensajes, las proyecciones |
| `DataKit/BaseStore.luau` (330) | El formato del sobre durable (`__dkFence` / `__dkData` / `__dkMsgs`) | Commit, fencing, mecánica del inbox |
| `ShopServerSystem.server.luau` | `ProcessPurchase` | Rotación de la tienda, sincronización con `MessagingService`, uso de `MemoryStore` |
| `RoleService/init.luau` | La comprobación de grupo y su caché de 50 s | El resto del módulo |
| `machines/Machine.luau` | `Machine:bind` y la ruta de recompensa | El resto del ciclo de vida de las máquinas |
| `machines/PopTheLock.luau` | El remote de recompensa | La lógica del minijuego |
| `EventCommands.server.luau` | La puerta de administrador | El resto de comandos |
| `AddValues.luau` | `Create`, y cómo restaura atributos | Nada más: el archivo son 59 líneas |

**Ya anotados con Moonwave en el propio código antes de este proyecto** — salen gratis en
la referencia de API, y son de terceros o empaquetados: `DataKit`, `Store`, `Profile`,
`Lease`, `Mutex`, `Health`, `BaseStore`, `Signal`, `Inbox`, `Adapters`, `Promise`, `Sift`,
`Trove`, `Observers`, `Kinetic`, `Icon`.

---

## Assets binarios

**320 archivos `.rbxm` — binarios / no inspeccionables.** La enumeración completa,
agrupada por directorio y con rutas en ejecución, está en
`docs/reference/binary-assets.md` (lo genera `.github/scripts/generate-reference.py`).

Los cinco que de verdad bloquean documentación:

| Ruta | Qué bloquea |
|---|---|
| `src/StarterPlayer/StarterPlayerScripts.rbxm` | El cargador del cliente y el emisor de `LoadCharacterRequest` → BUG-CANDIDATE-007 |
| `src/StarterPlayer/StarterCharacterScripts.rbxm` | El ciclo de vida del personaje al completo |
| `src/ReplicatedFirst/LoadingScreenUI.rbxm` | Lo primero que ve un cliente |
| `src/StarterGui/ScreenGui.rbxm`, `BuildMenu.rbxm` | La UI raíz |
| `…/PlayerHouses/StarterGui/PermsGui.rbxm` | La mitad cliente de los permisos de casa |

---

## Incógnitas

| # | Incógnita | Por qué no se puede resolver estáticamente |
|---|---|---|
| U-001 | Contenido de `StarterPlayerScripts.rbxm` / `StarterCharacterScripts.rbxm` | Binario. El punto de entrada real del cliente puede estar ahí y no se puede leer. La documentación del ciclo de vida del cliente será explícitamente incompleta hasta inspeccionarlos en Studio. |
| U-002 | Qué asset de plantilla trae `PlayerHouses` | `PlayerHouses` existe bajo `TemplatesTesting` (la carpeta de overrides) pero no aparece en `TEMPLATES_IDS` de `ImportTemplates.server.luau`. Es plausible que los `PlaceId` de casas (`126499097860226`, `80492586639096`) ejecuten *otro* proyecto/place de Rojo cuyo propio `ImportTemplates` sí lo incluya — **no verificable desde este repositorio**. |
| U-003 | Si el contenido publicado de los tres assets coincide con `TemplatesTesting/` en disco | Las copias en disco solo se usan como *override*; el contenido autoritativo es el asset publicado en Roblox. |
| U-004 | `src/StarterPack` está declarado en `default.project.json` pero no existe en disco | No se puede saber si Rojo lo tolera o si falta un archivo en el commit. |
| U-005 | Orden real de ejecución entre `ImportTemplates` e `InitScripts` | Ambos son `Script` de primer nivel en `ServerScriptService`; Roblox no garantiza orden entre hermanos. **Resuelta en parte:** la barrera hace irrelevante el orden para la dependencia «plantillas listas». Queda abierto el orden *entre* scripts de plantilla según los recorre la pasada de activación. |
| U-006 | Qué script activa los 27 scripts de contexto cliente | Ningún `.luau` de aquí asigna `Enabled = true`. Promovida a entrada formal: **BUG-CANDIDATE-007**, con un plan de dos minutos en Studio. |
| U-007 | Si algo impone `slots` como límite de casas abiertas a la vez | `slots` se lee, se vende y se replica, pero ningún código revisado lo contrasta contra las casas abiertas. Si la validación existe, estaría en una UI de cliente (posiblemente en un `.rbxm`) o en ninguna parte. |
| U-008 | Si `GlobalDataStore` y `GiftInbox` duplican las garantías de `DataKit` | Ambos llaman a `DataStoreService` directamente, fuera de `DataKit`. Ninguno se ha leído. |
| U-009 | Quién escribe la sección `content` del perfil `World` | Está declarada en el esquema y ningún script leído la escribe. El candidato es `BuildingSystem`, que aún no se ha leído. |

**Cerrada durante esta fase:** «cómo se compra una casa y dónde se anota en el perfil del
jugador» — la escribe `ShopServerSystem.ProcessPurchase` en `data.rooms`, y `buySlot` de
`PlayerDataReplicator` escribe `slots`. Eso es lo que sostiene BUG-CANDIDATE-008.

---

## Problemas encontrados

Diecinueve entradas, todas redactadas al completo en
`docs/testing/verification-plan.md`. **Ninguna se afirma como bug confirmado.** Dos están
clasificadas como *Confirmado por análisis estático*, y aun esas solo afirman lo que el
código demostrablemente hace: la 011 confirma una inconsistencia, no qué lado de ella está
mal; la 014 confirma una exposición, no su impacto.

**BUG-CANDIDATE-014 es la primera sobre la que actuar.** Es una credencial versionada y,
a diferencia del resto, su remediación no espera al resultado de ninguna prueba. Queda
fuera del alcance de este proyecto, que no cambia código, pero no debería quedarse en una
lista de pendientes.

| ID | Título | Sistema | Clasificación | Gravedad si se confirma | Confianza |
|---|---|---|---|---|---|
| BUG-CANDIDATE-001 | El control de chat de voz falla abierto cuando la comprobación de Roblox da error | Arranque | Observación / Requiere inyección de fallos | Baja | Alta |
| BUG-CANDIDATE-002 | Una entrada de presencia puede sobrevivir a su servidor hasta el TTL | World System | Posible bug / Requiere pruebas de ciclo de vida | Media | Media |
| BUG-CANDIDATE-003 | Un respawn fallido deja al jugador sin personaje y nada reintenta | Character | Posible bug / Requiere inyección de fallos | Media | Media |
| BUG-CANDIDATE-004 | La convergencia tras un anfitrión denegado puede dejar tirados a los jugadores | Casas | Posible bug / Requiere pruebas multijugador | Alta | Baja |
| BUG-CANDIDATE-005 | Teleport con un código de acceso cuya instancia ya se apagó | Casas | Requiere pruebas de teleport | Media | Baja |
| BUG-CANDIDATE-006 | Una sesión de Studio puede publicar un código de acceso falso en el registro real | Casas | Bug probable / Requiere pruebas de integración | Alta | Media |
| BUG-CANDIDATE-007 | El cargador de scripts del cliente no está en este repositorio | Cliente | Observación / Requiere verificación en ejecución | — | Alta |
| BUG-CANDIDATE-008 | Una compra concede el artículo antes de cobrarlo | Casas / Economía | Bug probable / Requiere pruebas de persistencia | Media | Alta |
| BUG-CANDIDATE-009 | Un fallo al resolver el nombre en el primer arranque bautiza la casa para siempre | Casas | Posible bug / Requiere inyección de fallos | Baja | Alta |
| BUG-CANDIDATE-010 | `WorldDataReplicator` se pierde un servidor que ya está `ready` | Casas | Bug probable / Requiere pruebas de ciclo de vida | Media | Media |
| BUG-CANDIDATE-011 | El rol `moderator` no puede moderar | Casas | Bug probable / Confirmado por análisis estático | Media | Alta |
| BUG-CANDIDATE-012 | Roles, ajustes y baneos de una casa los puede leer cualquier ocupante | Casas | Observación / Requiere pruebas de seguridad | Baja | Alta |
| BUG-CANDIDATE-013 | Un servidor de casa sin `TeleportData` deja tirado a su jugador en silencio | Casas | Posible bug / Requiere verificación en ejecución | Media | Media |
| BUG-CANDIDATE-014 | Un secreto compartido y un host proxy escritos a fuego en un archivo versionado | Casas / Seguridad | Confirmado por análisis estático | Alta | Alta |
| BUG-CANDIDATE-015 | Un solo booleano separa la economía de escrituras arbitrarias del cliente | Economía / Seguridad | Observación / Requiere pruebas de seguridad | Crítica | Alta |
| BUG-CANDIDATE-016 | Las máquinas aceptan del cliente el valor de la recompensa sin validarlo | Máquinas / Seguridad | Observación / Requiere pruebas de seguridad | Alta | Alta |
| BUG-CANDIDATE-017 | Revocar un rol de administrador tarda hasta 50 segundos en surtir efecto | Administración / Seguridad | Observación / Requiere verificación en ejecución | Baja | Alta |
| BUG-CANDIDATE-018 | Salir durante la carga deja el registro sucio y rompe la reconexión al mismo servidor | Datos del jugador / Sesión | Bug probable / Requiere pruebas de ciclo de vida | Media | Alta |
| BUG-CANDIDATE-019 | Donar a un jugador que aún no ha cargado destruye la moneda | Economía / Sesión | Bug probable / Requiere pruebas de ciclo de vida | Media | Alta |

### La pasada de seguridad

Las entradas 014 a 017 salen de una revisión específica de vulnerabilidades, hecha con el
mismo formato que el resto: teoría y justificación, nunca afirmación. Esa revisión también
dejó por escrito **lo que se miró y estaba bien**, en
`docs/testing/verification-plan.md`: los comandos de administrador sí están cerrados por
grupo, los precios de tienda se resuelven en el servidor, el `accessCode` no llega nunca
al cliente, los destinos de teleport se resuelven en el servidor, `Machine:bind`
comprueba la distancia y la propiedad, y `hasRoom` se vuelve a comprobar en el destino.
Registrar los controles que sí existen importa tanto como registrar los que faltan: evita
que una pasada futura los vuelva a auditar desde cero.

### Pistas investigadas y cerradas

Anotadas para que una ejecución futura no las reabra:

| Pista | Resultado |
|---|---|
| T-a — «la reserva de casas puede no tener guarda entre servidores» | **Cerrada — no es defecto.** `Profiles.World.claimStaged` reclama una clave `staged/World/{key}` de MemoryStore con `Lease.tryClaim`, un único `UpdateAsync` atómico de comparar-y-fijar. La ventana no atómica residual está documentada explícitamente en `Store.luau` y la absorben `onConflict = "deny"` más `convergeToOwner`. Solo queda abierto el comportamiento de *la mitigación* bajo carga → BUG-CANDIDATE-004. |
| T-b — «el registro de MemoryStore puede quedarse obsoleto» | **Mantenida, acotada** → BUG-CANDIDATE-002. Acotada por diseño al TTL de 120 s. |
| T-c — «código de acceso falso desde Studio» | **Mantenida, afinada** → BUG-CANDIDATE-006. Las llamadas de reserva y teleport *sí* están protegidas contra Studio; la escritura a MemoryStore que va entre medias, no. |
| T-d — «`ImportTemplates` destruye `TemplatesTesting`; algo podría seguir necesitándolo» | **Cerrada — no es defecto.** Un `grep` enseña que `TemplatesTesting` solo se referencia dentro del propio `ImportTemplates.server.luau`. |
| T-e — «intención frente a comportamiento en el control de chat de voz» | **Mantenida** → BUG-CANDIDATE-001, clasificada como Observación porque el propio código comenta la decisión. |
| T-f — «los comandos de administrador podrían no comprobar permisos» | **Cerrada — no es defecto.** `EventCommands` pasa por `RoleService`, que consulta el rango en el grupo. Lo único que queda es la caché de 50 s → BUG-CANDIDATE-017. |
| T-h — «el tope diario de donación vive en un atributo de `Instance`, así que reconectar debería reiniciarlo» | **Cerrada — no es defecto.** `SPEC` mapea `stats` a `leaderstats`, y el serializador guarda los atributos junto al valor (`for index, attribute in value:GetAttributes()`); `AddValues.Create` los restaura al materializar. El tope sobrevive a la reconexión. |
| T-g — «los precios de tienda podrían venir del cliente» | **Cerrada — no es defecto.** `ProcessPurchase` resuelve el precio desde `currentShopData` en el servidor; el cliente solo manda un identificador. |

### Observaciones registradas, que no son defectos

| Observación | Dónde |
|---|---|
| `folderTest:Destroy()` seguido de `Debris:AddItem(folderTest)` es redundante | `ImportTemplates.server.luau` |
| La etiqueta `IgnoreLoader` no tiene ningún consumidor en este repositorio | Ambos scripts de arranque |
| 3 de los 4 scripts etiquetados `IgnoreAutoEnable` están bajo `ReplicatedStorage/Client`, que la pasada del servidor ya se salta entera — evidencia a favor de la teoría del cargador de cliente | apoya BUG-CANDIDATE-007 |
| `GetSlots` está declarado en las carpetas de eventos de `Core` y de `PlayerHouses`, misma clase, un solo binder, un solo consumidor | `docs/architecture/networking.md` |
| `default.project.json` mapea `StarterPack`, que no existe en disco | raíz |
| El bloque de auto-enlazado de remotes de `Collections` está inactivo tras `ConexionEntreServerYCliente = false` | `docs/systems/player-data.md`, sostiene BUG-CANDIDATE-015 |

---

## Verificación y plan de pruebas

`docs/testing/verification-plan.md` — **creado**, 19 entradas, cada una con condiciones de
paso/fallo e instrumentación sugerida. Todas están `Sin verificar`.

Roblox Studio **no está disponible en este entorno**, así que no se ha ejecutado ningún
plan. Cada uno está escrito para ejecutarse a mano.

**Orden de ejecución recomendado** (lo más barato e informativo primero). El orden completo
y razonado está en la propia página; el resumen es:

1. BUG-CANDIDATE-014 — no necesita prueba: comprobar si el repositorio es privado y si el
   secreto se ha rotado. **Hazlo primero, pase lo que pase con el resto.**
2. BUG-CANDIDATE-015 — leer un booleano y confirmar que sigue en `false`. Dos minutos, y
   es el de gravedad más alta.
3. BUG-CANDIDATE-007 — ~2 minutos en Studio, y desbloquea todo el capítulo del cliente.
4. BUG-CANDIDATE-016 — un remote invocado desde la consola del cliente.
5. BUG-CANDIDATE-006 — empieza por una pregunta de configuración («¿está activado el
   acceso a API desde Studio en este universo?») que puede cerrarla de golpe.
6. BUG-CANDIDATE-011, 012, 017 — dos cuentas, pocos minutos, sin inyección de fallos.
7. BUG-CANDIDATE-002, 003, 009 — un jugador y un fallo inyectado.
8. BUG-CANDIDATE-019 — dos cuentas y un `task.wait` de instrumentación.
9. BUG-CANDIDATE-008, 010, 013, 018 — instrumentación y repetición.
10. BUG-CANDIDATE-005, 004 — las más caras: crash forzado, timing ajustado, dos cuentas en
   dos servidores y más de 20 ejecuciones.
11. BUG-CANDIDATE-001 — más una decisión de producto que una prueba.

---

## Último trabajo completado

- **Fase:** 3 — Sistemas (Casas, Datos del jugador, Eventos, Invitaciones) y **Fase 5**
  cerrada con el grafo de dependencias.
- **Idioma:** todo el sitio, los comentarios Moonwave y los generadores están en español.
- **Páginas del sitio:** `docs/intro.md`, 10 de arquitectura, 7 de casas, 4 de sistemas,
  1 de verificación, 3 de referencia generada.
- **Archivos anotados (solo comentarios, demostrado por la guarda de CI):**
  - `src/ReplicatedStorage/PlayerInit.luau`
  - `…/Core/ServerStorage/WorldSystem/ServerPresence.luau`
- **Diagramas:** 33 diagramas Mermaid (flowchart, sequence, state)
- **Candidatos a bug:** 19 redactados al completo, incluida una pasada de seguridad
- **Scripts leídos:** 45 de 552
- **Estado en GitHub:** la PR #1 se fusionó en `main`; la rama se reinició desde el `main`
  fusionado y el trabajo posterior va encima. El workflow de documentación pasa en verde y
  GitHub Pages está configurado con `Source: GitHub Actions`.

### Respuestas a las preguntas centrales del encargo

Anotadas aquí para que una ejecución futura no las vuelva a deducir:

| Pregunta | Respuesta | Dónde |
|---|---|---|
| ¿Qué arranca primero en un servidor? | Dos `Script` hermanos **sin orden garantizado**; un `BoolValue` de barrera hace que el orden dé igual | `docs/architecture/initialization.md` |
| ¿Cómo se inicializa un jugador? | No hay arranque central: los sistemas se registran en `PlayerInit` y empiezan a la vez y sin orden | `docs/architecture/player-lifecycle.md` |
| ¿Cómo se inicializa el cliente? | **No se puede responder desde este repositorio.** Aquí no hay nada que active los 27 scripts de cliente | `docs/architecture/client-lifecycle.md`, BUG-CANDIDATE-007 |
| ¿Pueden dos jugadores reservar la misma casa a la vez? | **No, está guardado**, por un comparar-y-fijar atómico de MemoryStore, más denegar-y-converger para la ventana residual | `docs/architecture/reserved-servers.md` |
| ¿Cómo se detecta una referencia a un servidor muerto? | No se detecta: se **previene**. Nada durable apunta a un servidor; la alcanzabilidad *es* un lease y la vida *es* su TTL | `docs/systems/housing/server-lifecycle.md` |
| ¿Qué pasa cuando se va el último jugador? | Nada específico de casas. No existe manejador, y no hace falta | `docs/systems/housing/server-lifecycle.md` |
| ¿Cómo se reabre una casa? | No hay camino de reapertura. Una casa cerrada es una casa sin lease | `docs/systems/housing/server-lifecycle.md` |
| ¿Cómo se comunican cliente y servidor? | 174 `RemoteEvent` y 40 `RemoteFunction` declarados como `.model.json`, sin capa de red compartida: cada sistema los ata a mano | `docs/architecture/networking.md` |
| ¿Qué depende de qué? | Grafo real de `require`: `PlayerInit` (20 consumidores) y `PlayerDataService` (10) son los cimientos; no hay ciclos entre los sistemas revisados | `docs/architecture/dependencies.md` |

### Notas de herramientas para la próxima ejecución

- **La capa de API de Moonwave está acotada, y eso sostiene el build.** El workflow pasa
  `--code src/ReplicatedStorage src/ServerStorage/TemplatesTesting/Core/ServerStorage`
  (`DOC_CODE_PATHS` en `.github/workflows/docs.yml`), **no** todo `src/`. El primer build
  real de CI demostró por qué: el extractor de Moonwave trata cada comentario `---` y cada
  bloque `--[=[ ]=]` como comentario de documentación, y aborta con el primer lote de
  diagnósticos. Encontró **16 errores**, todos en `Core/ReplicatedStorage`, en archivos que
  este proyecto no ha tocado:

  | Causa | Archivos |
  |---|---|
  | `---` usado como separador visual con texto en la línea | `Icon/Types`, `Icon/init`, `PartCache/init`, `FastCastRedux/init`, `FastCastRedux/ActiveCast`, `Karaoke/RevisarCanciones/init`, `Karaoke/CrearCancion/init`, `Paint/ServerClient/init`, `DancesInfo`, `Client/BusquedaSettings` |
  | Bloque `--[=[ ]=]` cuya clase padre no tiene entrada `@class` | `CardSlots`, `Carousel`, `ButtonMotion`, `AreaSystem` |
  | `@class Signal` duplicada | `Shared/Signal.luau` frente a `DataKit/Signal.luau` |

  Una línea `-----` a secas, sin texto, **no** da error — `WorldSystem/EventService` y
  `ReferralService` las usan y salieron limpios. El problema es solo `---` seguido de
  texto.

  **Antes de ampliar `DOC_CODE_PATHS`**, arregla los comentarios de los archivos que
  entran, o el build falla para todo el mundo. `check-docs-links.py` valida los enlaces
  `/api/<Clase>` contra exactamente esas rutas, así que las dos cosas van juntas.

- **Moonwave no se puede construir localmente en este entorno.** La CLI se instala desde
  npm, pero `moonwave build` descarga su binario extractor de
  `latest-github-release.eryn.io` / `github.com`, ambos fuera de la lista permitida de red
  (HTTP 403). El build se valida en los runners de GitHub Actions. **Ejecuta estos dos
  antes de cada commit** — son el sustituto local, y los dos están cableados en CI:
  - `python3 .github/scripts/check-docs-links.py docs $DOC_CODE_PATHS`
  - `python3 .github/scripts/check-luau-code-unchanged.py origin/main`
- **Regenera las páginas de referencia** después de leer archivos nuevos, y actualiza los
  conjuntos `ANALYSED` / `PARTIAL` / `DOCUMENTED` de la cabecera de
  `generate-script-inventory.py`:
  - `python3 .github/scripts/generate-reference.py`
  - `python3 .github/scripts/generate-script-inventory.py`
- **Mermaid** no está en la plantilla de Docusaurus de Moonwave 1.4.2. El workflow
  construye dos veces: una pasada de calentamiento puebla el proyecto cacheado de
  Moonwave, el tema se instala dentro con `--no-save --no-package-lock` para que la caché
  sobreviva, y entonces corre el build real. Si la instalación falla, avisa en vez de
  romper el build.
- **El push ya funciona.** La app de GitHub de Claude está instalada en el repositorio; el
  403 que bloqueaba todo durante la primera ejecución está resuelto.

---

## Trabajo recomendado a continuación

**No empieces todavía la pasada por script de la Fase 4.** El encargo es explícito: cinco
sistemas entendidos a fondo valen más que cincuenta descritos por encima, y quedan sistemas
que merecen ese trato.

### 1. `Shared/Stores/init.luau` — la pieza pendiente más importante

Ata **13 manejadores de remotes**, la mayor concentración de un solo archivo del
repositorio, y `Data.Main` le inyecta `DataKit`, `Profiles`, `PlayerDataService`,
`GlobalDataStore`, `Monetizacion` y `PaintServer`. Es el cruce entre economía,
monetización y persistencia, y hoy solo se conoce por sus efectos.

Junto a él, `Shared/Monetization` y `WorldSystem/GamePassService`: la ruta de compras con
Robux es la superficie de seguridad grande que la primera pasada dejó sin revisar.

### 2. `GlobalDataStore` y `GiftInbox`

Llaman a `DataStoreService` fuera de `DataKit`. Cierra U-008 y termina la pregunta abierta
de `docs/architecture/persistence.md`.

### 3. Los sistemas de juego

Inventario/Herramientas, Interactuables (44 remotes; `Interactable` es el módulo con más
consumidores del repositorio, 37), Máquinas, Karaoke (25 remotes), Paint, Tiendas,
Misiones, Trabajos, Animación, Construcción. Unos 480 archivos. De uno en uno, y un commit
por sistema.

### 4. Fase 4 y Fase 6

Pasada Moonwave por script, `classOrder` en `moonwave.toml` una vez exista el conjunto
completo de `@class`, y la validación final.

### Diferido a propósito, con motivos

| Diferido | Por qué |
|---|---|
| `docs/architecture/data-flow.md` | Persistencia y Red ya cubren los flujos encontrados. Añadirla solo si un sistema posterior enseña uno que no cubran. |
| `classOrder` en `moonwave.toml` | Fase 4, cuando exista el conjunto completo de anotaciones `@class`. Nombrar una clase que no existe rompería el build. |
| Pasada Moonwave por script | Fase 4. Van dos módulos anotados por este proyecto; ~16 más ya venían anotados por sus autores. |

### Antes de terminar cualquier ejecución futura

1. Ejecuta los dos scripts de comprobación.
2. Regenera las dos páginas de referencia y actualiza los conjuntos de estado.
3. Actualiza *Fase actual*, *Último trabajo completado*, *Trabajo recomendado a
   continuación*, *Incógnitas* y cualquier candidato nuevo **tanto en este archivo como en**
   `docs/testing/verification-plan.md`.
4. Haz commit y push a `docs/moonwave-documentation`.
