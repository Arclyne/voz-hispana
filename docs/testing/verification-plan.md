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
| [014](#bug-candidate-014) | Un secreto compartido y un host proxy están escritos a fuego en cuatro archivos, uno de ellos replicado al cliente | Infraestructura / Seguridad | Confirmado por análisis estático | **Crítica** | Alta |
| [015](#bug-candidate-015) | Un solo booleano separa la economía de escrituras arbitrarias del cliente | Economía / Seguridad | Observación / Requiere pruebas de seguridad | Crítica | Alta |
| [016](#bug-candidate-016) | Las máquinas aceptan del cliente el valor de la recompensa sin validarlo | Máquinas / Seguridad | Observación / Requiere pruebas de seguridad | Alta | Alta |
| [017](#bug-candidate-017) | Revocar un rol de administrador tarda hasta 50 segundos en surtir efecto | Administración / Seguridad | Observación / Requiere verificación en ejecución | Baja | Alta |
| [018](#bug-candidate-018) | Salir durante la carga deja el registro sucio y rompe la reconexión al mismo servidor | Datos del jugador / Sesión | Bug probable / Requiere pruebas de ciclo de vida | Media | Alta |
| [019](#bug-candidate-019) | Donar a un jugador que aún no ha cargado destruye la moneda | Economía / Sesión | Bug probable / Requiere pruebas de ciclo de vida | Media | Alta |
| [020](#bug-candidate-020) | El color de una superficie llega del cliente sin límite de tamaño y se guarda tal cual | Tiendas / Casas / Seguridad | Observación / Requiere pruebas de seguridad | Alta | Media |
| [021](#bug-candidate-021) | El dueño de una casa puede vender el mueble de un invitado y quedarse el reembolso | Tiendas / Economía | Posible bug / Requiere pruebas multijugador | Media | Media |
| [022](#bug-candidate-022) | Un jugador puede añadir a su escaparate cualquier artículo del catálogo, sea suyo o no | Monetización / Seguridad | Bug probable / Requiere pruebas de seguridad | Media | Alta |
| [023](#bug-candidate-023) | La posición de lo que se coloca la decide el cliente y el servidor no la comprueba | Tiendas / Casas / Herramientas | Observación / Requiere pruebas de seguridad | Baja | Alta |
| [024](#bug-candidate-024) | `MusicPlayer` reproduce el audio que le diga el cliente, en el modelo que le diga el cliente | Interactuables / Seguridad | Bug probable / Requiere pruebas de seguridad | Media | Alta |
| [025](#bug-candidate-025) | La distancia de interacción la comprueba solo el cliente | Interactuables | Observación / Requiere pruebas de seguridad | Baja | Alta |
| [026](#bug-candidate-026) | El globo está implementado entero y ningún jugador lo recibe nunca | Inventario | Bug probable / Confirmado por análisis estático | Baja | **Muy alta** |
| [027](#bug-candidate-027) | `ToolsServer` reparenta y manipula las `Instance` que le diga el cliente | Herramientas / Seguridad | Bug probable / Requiere pruebas de seguridad | Alta | Alta |
| [028](#bug-candidate-028) | Tres cargadores de moderación comprueban que haya un administrador conectado, no que quien llama lo sea | Karaoke / Seguridad | Posible bug / Requiere pruebas de seguridad | Baja | Alta |
| [029](#bug-candidate-029) | Borrar un cuadro reintenta por recursión, sin límite y sin cortacircuitos | Cuadros | Posible bug / Requiere inyección de fallos | Media | Alta |
| [030](#bug-candidate-030) | El límite de ritmo al editar un cuadro solo existe en el cliente, y el servidor difunde a todos | Cuadros / Seguridad | Posible bug / Requiere pruebas de seguridad | Media | Alta |
| [031](#bug-candidate-031) | Se puede hacer bailar al personaje de otro jugador | Animación | Posible bug / Requiere pruebas multijugador | Baja | Alta |
| [032](#bug-candidate-032) | Una condición de trabajo mal escrita permite la acción en silencio | Trabajos | Observación / Requiere verificación en ejecución | Baja | Alta |
| [033](#bug-candidate-033) | Las cuatro operaciones de `GlobalDataStore` comparten una señal y no coinciden en qué lleva | Persistencia | Posible bug / Requiere pruebas de concurrencia | Media | Alta |
| [034](#bug-candidate-034) | Un `RemoteFunction` en la carpeta de televisores nunca quedaría atado | Karaoke | Confirmado por análisis estático — **latente** | Baja hoy | **Muy alta** |
| [035](#bug-candidate-035) | El limitador de ritmo de la búsqueda de canciones está invertido | Karaoke / Persistencia | Bug probable / Confirmado por análisis estático | Media | **Muy alta** |
| [036](#bug-candidate-036) | La lista de favoritos crece sin tope, con cadenas que elige el cliente | Casas / Persistencia | Observación / Requiere pruebas de seguridad | Baja | Alta |
| [037](#bug-candidate-037) | La caja de botín es estrictamente mejor que la tienda de bailes | Economía | Observación / Pregunta de diseño | Media | Alta |
| [038](#bug-candidate-038) | El filtro de errores del micrófono está invertido: solo se avisa del fallo esperado | Chat de voz | Bug probable / Confirmado por análisis estático | Media | **Muy alta** |
| [039](#bug-candidate-039) | El servidor marca un tutorial como terminado porque el cliente se lo dice | Tutoriales / Seguridad | Confirmado por análisis estático — **latente** | Baja hoy | **Muy alta** |
| [042](#bug-candidate-042) | `typee` de comando suministrado por el cliente, sin la comprobación de rol que sí hace el camino del chat | **Explotable hoy**, impacto por determinar |
| [043](#bug-candidate-043) | Condición de victoria suministrada por el cliente, con manejador de premio **puesto** (no stub) | **Explotable hoy**, entrega un objeto de inventario |
| [046](#bug-candidate-046) | Canal de voz y `Tool` suministrados por el cliente, sin comprobar posesión | **Explotable hoy**, acotado a voz |
| [043](#bug-candidate-043) | El cliente decide si ha ganado el peluche, y aquí sí hay premio | Máquinas / Seguridad | Bug probable / Requiere pruebas de seguridad | Media | **Muy alta** en la forma |
| [044](#bug-candidate-044) | La ruleta tiene una casilla que no paga y un sesgo del doble hacia la casilla 1 | Máquinas / Economía | Confirmado por análisis estático | Baja | **Muy alta** en la aritmética |
| [045](#bug-candidate-045) | El caché de assets pierde el filtro de tipo al reintentar, y puede dejar colgado a quien espera | Karaoke / Assets | Confirmado (el filtro) + Requiere pruebas de concurrencia (el bloqueo) | Baja / Media | **Muy alta** / baja |
| [046](#bug-candidate-046) | Cualquiera puede entrar en cualquier canal de walkie, y el objeto en el que escribe el servidor lo elige el cliente | Walkie-talkie / Seguridad | Bug probable / Requiere pruebas de seguridad | Media | **Muy alta** en la forma |
| [047](#bug-candidate-047) | 46 muebles y todas las herramientas colocables comparten una descripción de relleno | Tiendas / Construcción | Confirmado por análisis estático | Baja (presentación) | **Muy alta** |
| [040](#bug-candidate-040) | Las dos tablas globales del place de donaciones llaman a un método que no existe | Donaciones / Persistencia | Confirmado por análisis estático | Media | **Muy alta** |
| [041](#bug-candidate-041) | El bucle compartido cree que atrapa los errores de sus tareas, y no atrapa ninguno | Utilidades compartidas | Confirmado por análisis estático | Media | **Muy alta** |
| [042](#bug-candidate-042) | El comando de administración se comprueba en el chat y no en el remote | Comandos / Seguridad | Posible bug / Requiere pruebas de seguridad | Por determinar | Alta en la forma |

### Entradas de seguridad

Las que tratan superficie de ataque en vez de corrección funcional. Se escriben en el mismo
formato que el resto: teoría con justificación, no acusaciones.

| ID | Vector | Estado hoy |
|---|---|---|
| [012](#bug-candidate-012) | Lectura de roles y baneos de una casa sin comprobación de permisos, por dos sistemas distintos | **Explotable hoy**, impacto bajo |
| [014](#bug-candidate-014) | Secreto compartido en cuatro archivos —uno replicado al cliente—, proxy en HTTP plano, remote sin límite de frecuencia | **Expuesto hoy**, recuperable desde el cliente |
| [015](#bug-candidate-015) | Escritura arbitraria de moneda desde el cliente | **Latente** — desactivado por un booleano |
| [016](#bug-candidate-016) | Valor de recompensa suministrado por el cliente | **Latente** — el manejador de premio es un stub |
| [017](#bug-candidate-017) | Ventana de revocación de privilegios de administrador | **Presente hoy**, impacto bajo |
| [020](#bug-candidate-020) | Dato de tamaño arbitrario, controlado por el cliente, persistido en el perfil de una casa ajena | **Presente hoy**, impacto por determinar |
| [022](#bug-candidate-022) | Id de asset suministrado por el cliente, sin comprobación de propiedad | **Explotable hoy** si un `EnumItem` viaja por el remote |
| [023](#bug-candidate-023) | Colocación con autoridad de cliente en casa ajena | **Explotable hoy**, impacto de vandalismo |
| [024](#bug-candidate-024) | `SoundId` y modelo suministrados por el cliente, sin moderación | **Explotable hoy**, acotado por las restricciones de audio de Roblox |
| [039](#bug-candidate-039) | Clave y estado de tutorial suministrados por el cliente, persistidos en el perfil | **Latente** — la tabla de recompensas es un stub |
| [025](#bug-candidate-025) | Reglas de interacción solo en el cliente en 21 de 25 manejadores | **Explotable hoy**, impacto bajo |
| [027](#bug-candidate-027) | Reparentado arbitrario de `Instance` desde un remote | **Explotable hoy**, control sobre el mundo compartido |
| [028](#bug-candidate-028) | Guarda de autorización que mira al servidor en vez de al llamante | **Explotable hoy**, pero sin fuga de datos: el llamante acaba expulsado |
| [030](#bug-candidate-030) | Amplificación de red: una llamada del cliente difunde a todos, sin límite de frecuencia | **Explotable hoy**, sin necesidad de permisos ajenos |

#### Lo que se revisó y salió limpio

Registrado con el mismo cuidado, porque una lista de hallazgos sin lo revisado y correcto es
engañosa:

| Superficie | Resultado |
|---|---|
| Remotes de moderación de Karaoke | **Correcto, y es la postura más dura del proyecto.** Cinco de los ocho manejadores comprueban al llamante lo primero y, si no cumple, `IntenteSerAdmin` lo **expulsa** con un aviso explícito. Los baneos exigen además el rango `KaraokeSuperAdmin`. |
| Saltar una canción en un televisor | **Correcto.** Es una votación: hay que estar escuchando para votar, el voto se puede retirar, y salta con el dueño o con la mayoría de oyentes descontando al dueño. |
| Registrar cualquier modelo como televisor | **Correcto.** `TV.new` exige un hijo `Screen` que contenga un `SurfaceGui`. |
| Difusión de datos de moderación | **Correcto.** `FireOnlyAdmins` recorre `AdminsActive` y `ObtenerMusica` revalida por página: la página de baneos exige superadministrador incluso en la ruta de difusión. |
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
| Escala de un mueble | **Correcto.** `Posicionamientos.GetScale` pasa el valor del cliente por `math.clamp` contra el rango que declara el `Settings` de ese modelo. |
| Qué mueble se coloca | **Correcto.** `verificarExistencia` resuelve el nombre contra `decoration template` y `Assets/ToolsModels` en el servidor; un nombre inventado no produce nada. |
| Orden entre dos manejadores de `PlayerRemoving` en Invitaciones | **Correcto, y es el patrón a imitar.** `ReferralMain` usa `PlayerDataService.onBeforeClose` en vez de `Players.PlayerRemoving`, con el motivo escrito: el orden entre dos conexiones al mismo evento no está garantizado. Es la forma del arreglo que le falta a BUG-CANDIDATE-018. |
| Doble conteo de segundos al arrancar Invitaciones | **Correcto.** No recorre `Players:GetPlayers()` porque `PlayerInit` ya reejecuta el callback: hacerlo sería sumar dos veces. Es de las pocas veces que un consumidor demuestra haber leído el contrato de `PlayerInit`. |
| Apertura de la hoja de compartir | **Correcto.** Un mapa `sharing` impide solapes, Studio recibe un aviso en vez de un 403 confuso, y si Roblox rechaza la caducidad se reintenta con la suya por defecto para no dejar al jugador sin link. |
| Toda la ruta de regalos en Robux | **Correcto, y es el camino mejor protegido del repositorio.** `ProcessReceipt` resuelve **toda** decisión dudosa no otorgando y dejando que Roblox reintente: producto de regalo sin destinatario, comprador igual al receptor, propiedad no verificable, `applyItem` que no devuelve `true`. Un producto creado solo para regalar jamás cae al comprador por defecto, y el código lo marca como «Seguridad crítica». |
| Reutilizar una intención de regalo | **Correcto.** Lleva TTL, está atada a un `productId` concreto, y se consume **antes** de comprobar la caducidad, así que una vencida no queda rondando para el siguiente recibo. |
| Varios `ProcessReceipt` compitiendo | **Correcto.** `grep` sobre todo `src/` confirma una única asignación, en `GiftHandler.server.luau`. Es un asignador global: dos scripts que lo pongan se pisan en silencio. |
| Entrega de un regalo en Robux con el receptor ausente | **Correcto, y es el módulo mejor razonado del repositorio.** `GiftInbox` documenta por qué no puede ir en el perfil —el lease es de un solo escritor y aquí el servidor del comprador escribe sobre otra identidad—, devuelve `false` si no pudo escribir para que el recibo no se dé por bueno, y no borra el buzón si la lectura falla. |
| Buzón de regalos creciendo sin límite | **Correcto.** `MAX_ENTRIES = 50`, cancelando la escritura con `nil`, que además no gasta la operación. |
| Despacho de métodos por nombre en Trabajos | **Correcto, y es el mejor patrón del repositorio para esto.** El cliente manda el nombre del método, pero hay una lista blanca **por instancia** —cuatro o cinco nombres declarados junto al objeto— y quien la burla recibe `Player:Kick("Exploiter detected.")`. `LimpiarPiso` incluso deja la lista vacía para las instancias que no deben aceptar nada. |
| Acumular trabajos | **Correcto.** `UsosPlayer` es uno por jugador y empezar otro renuncia al anterior; la limpieza compara `== getMetatable` antes de borrar, para que una señal tardía no pise el trabajo nuevo. |
| Pago del botón VIP | **Correcto.** Solo se paga si `state == "Success"`, y `Proccess[Player]` más `MarkPrompt` impiden compras solapadas. |
| Peticiones solapadas de permisos de micrófono | **Correcto, y es un patrón de coalescencia bien hecho.** Cada petición incrementa una versión y los resultados viejos se descartan; una bandera impide dos trabajadores; y si llega otra petición durante la espera, el bucle repite. |
| Superficie de red del micrófono y del nametag | **Correcto.** `UpdateMicEvent` es solo servidor → cliente, y cada jugador recibe únicamente su fila de la matriz. `NametagServer` no declara ningún remote. |
| Precio de una caja de botín | **Correcto.** El cliente elige moneda, no importe, y `LOOTBOX_PRICES` actúa como lista blanca; se cobra antes de conceder y se rechaza antes de cobrar si no queda nada por dar. |
| Reconectar para cobrar el sueldo antes de tiempo | **Correcto.** `PlaytimeRewardSystem` compara `GetJoinData().SourceGameId` con `game.GameId`: un teleport interno respeta el temporizador, un inicio de sesión nuevo lo reinicia. |
| Reclamar una misión | **Correcto, y de lo más completo del repositorio.** Lista blanca de grupos, tipo del hueco, la misión existe, no está reclamada, el progreso llega al objetivo, y la recompensa sale de la configuración del servidor. |
| Doble reclamación de una misión | **Correcto hoy, por una propiedad frágil.** `Claimed = true` se escribe después de conceder, pero en todo el recorrido no hay un solo punto de suspensión, así que dos llamadas no se entrelazan. Añadir cualquier espera a `Collections.Give` o a `saveData` abriría la ventana. |
| Giro de la ruleta | **Correcto.** `requestSpinRF` valida en cadena con un motivo por rechazo, comprueba el recurso **antes** de cobrarlo, y usa `CooldownManager` para el giro gratuito. |
| Posesión de un baile | **Correcto.** Se comprueba contra la carpeta `Animations` del jugador y el intento fallido se registra con su nombre. El remote `AddAnimation` se eliminó a propósito, con el motivo anotado en el código. |
| Consumo de ingredientes en la cocina | **Correcto.** Pasa por `InventoryManager.removeItem`, la ruta validada del inventario, no por manipulación directa. |
| Autorización para editar un cuadro | **Correcto.** `UpdateCuadros` exige que el modelo tenga la etiqueta `Paint`/`CuadrosPaint` y que su atributo `Owner`/`InInUse` —puesto por el servidor— sea el `UserId` del llamante. |
| Borrado de un cuadro ajeno | **Correcto.** `Remove` comprueba `Format.IsOwner` contra el dato **leído del DataStore**, no contra lo que manda el cliente, y además que no esté colgado en una casa. |
| Pago de una venta de cuadro con el vendedor desconectado | **Correcto, y es el mejor patrón del juego para esto.** Viaja por el buzón idempotente del perfil de DataKit, con `sellerHere` para no pagar dos veces. |
| Validación de entrada en el inventario | **Correcto, y es la referencia del proyecto.** Los cinco remotes validan tipo, entereza y rango, y `InventoryManager` **vuelve a validarlo todo** por su cuenta más la propiedad. Es el único sistema leído que valida en las dos capas. |
| Conceder un objeto que no existe | **Correcto.** `getToolAsset` busca la `Tool` real en `Assets/Tools` antes de `addItem` y `setItemCount`. |
| Re-conceder objetos que el jugador gastó | **Correcto, y razonado en el propio código.** La bandera `defaultsInitialised` es explícitamente preferida a «¿está vacío el inventario?», con el comentario que lo justifica. |
| Uso de la herramienta de otro jugador | **Correcto en `Cannon` y `GloveGun`.** Ambos exigen `IsA("Tool")` y `tool.Parent == character`, y el cañón añade un cooldown de 5 s. |
| Validación de entrada en `Fridge` | **Correcto, y es el modelo a imitar.** Comprueba que el modelo sea una `Model`, que tenga la etiqueta `Fridge` y la distancia al jugador, las tres cosas antes de actuar. |
| Recoger o usar un objeto colocado en el mundo | **Correcto, y es la mejor validación del repositorio.** `canUsePlacedModel` comprueba tipo, contenedor esperado, etiqueta, propiedad, personaje vivo y distancia (30 studs), y los cuatro remotes de `ToolPlacementServer` empiezan llamándola. |
| Doble consumo de una ración de comida | **Correcto.** `modelLocks[model]` es un cerrojo por objeto, y se libera en **cada** camino de salida, no solo en el feliz. |
| Colocar una herramienta que no llevas | **Correcto.** `character:FindFirstChild(toolName)` más `IsA("Tool")` y el atributo `Colocable`. |
| `Bin` como interactuable sin modelo | **Correcto.** No acepta ninguna `Instance` del cliente: actúa sobre la `Tool` equipada, y solo si tiene el atributo `Kitchen`. |
| Bloqueo permanente de duchas y lavabos al morir dentro | **Correcto.** `humanoid.Died:Once` libera el `Occupant`. |
| Recolorear partes arbitrarias de un mueble | **Correcto.** Solo se aceptan partes llamadas `LightColor` o terminadas en dígito, y un valor que no sea `Color3` se sustituye por blanco. |
| Amueblar la casa de otro como vía de transferencia de moneda | **Correcto.** Pasa por `donacion.GetState` y `donacion.Quitar`: consume el mismo tope diario de 1 000 que una donación directa. |
| Importe de las compras en Robux | **Correcto.** `Compras.Comprar` usa `self.ProductActive`, estado de servidor, y lee el precio de `GetProduct`. |
| Concesión de gamepasses persistidos | **Correcto.** `GamePassService` no tiene remotes. `syncFromRoblox` verifica con `UserOwnsGamePassAsync`, y la ruta de compra exige `wasPurchased` y que el id esté declarado en `ShopInfo`. |
| Prompts de compra entrelazados | **Correcto, y deliberado.** `MarkAdded:decition` compara id e `InfoType` del prompt que se cierra contra el que se abrió, y reporta `"Closed"` si no coinciden. Los seis eventos `Prompt*Finished` están conectados, no solo los dos que el juego usa. |

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

### Un secreto compartido y un host proxy están escritos a fuego en cuatro archivos, uno de ellos replicado al cliente

**Sistema:** Infraestructura / Seguridad · **Clasificación:** Confirmado por análisis estático
**Estado:** Sin verificar (la *exposición* es segura; el *impacto* no)
**Gravedad si se confirma:** Alta · **Confianza:** Alta

**Código relacionado:** las constantes `MY_PROXY_URL` / `PROXY_URL` y `MY_SECRET_KEY` /
`SECRET_KEY`, al principio de cuatro archivos:
`Core/…/ServerScripts/WorldsBrowser.server.luau`,
`Core/…/Data/Main/PlayerGamesFetcher.luau`,
`Core/ServerStorage/SoundInfo.luau` y
**`Core/ReplicatedStorage/Shared/Monetization/MainModule.luau`**
**Documentación relacionada:** [Casas → Identidad y propiedad](../systems/housing/identity.md),
[Monetización](../systems/monetization.md)

:::note El secreto no se reproduce aquí

Esta página nombra el archivo y las constantes. No repite el valor, y ningún otro documento
debería hacerlo. El valor está en el repositorio y en su historial de git, que es
precisamente el motivo de esta entrada.

:::

:::danger Ampliado tras leer Monetización — la exposición es mayor de lo registrado

La primera versión de esta entrada nombraba **un** archivo, en `ServerScriptService`. Al
leer el sistema de monetización aparecieron **tres más**, con la misma IP y el mismo
secreto literal, y uno de ellos está bajo `ReplicatedStorage`.

Eso cambia la naturaleza del problema. Ya no es solo «un secreto en el repositorio»: es un
secreto que **se envía a la máquina de cada jugador** con el resto del contenido replicado.

:::

#### Comportamiento observado — HECHO

Cuatro archivos declaran, como literales de cadena al principio del archivo:

- una URL `http://` con IP desnuda hacia un proxy autoalojado, descrito en un comentario
  como *«Nuestro servidor VPS privado (Puerto 80)»* / *«Nuestro Proxy Privado»*;
- un secreto compartido, enviado como cabecera `My-Secret` de cada petición.

| Archivo | Servicio en ejecución | Para qué usa el proxy |
|---|---|---|
| `ServerScripts/WorldsBrowser.server.luau` | `ServerScriptService` | Buscar jugadores por nombre |
| `Data/Main/PlayerGamesFetcher.luau` | `ServerScriptService` | Juegos y grupos de un usuario, y sus miniaturas |
| `ServerStorage/SoundInfo.luau` | `ServerStorage` | Metadatos de audio del toolbox |
| **`Shared/Monetization/MainModule.luau`** | **`ReplicatedStorage`** | Catálogo de artículos creados por un jugador |

Los cuatro valores son **idénticos**, carácter por carácter. Rotar el secreto obliga a tocar
los cuatro sitios; cambiar tres y olvidar uno deja el sistema roto o el secreto vivo.

#### Por qué es un problema

Tres cuestiones distintas, en orden decreciente de certeza:

1. **Uno de los cuatro archivos se replica al cliente.**
   `Shared/Monetization/MainModule.luau` vive bajo `ReplicatedStorage`, así que la
   `Instance` del `ModuleScript` —y su código— llega a la máquina de cada jugador. Solo lo
   requiere el servidor (`RecolectarInfo = not client and require(...)`), pero eso decide
   quién lo *ejecuta*, no quién lo *recibe*.

   Un `LocalScript` normal no puede leer `.Source`: Roblox lo bloquea por identidad. Un
   ejecutor de exploits sí puede, y volcar los módulos replicados es una de sus capacidades
   básicas. **INFERENCIA:** el secreto es recuperable por cualquier jugador con esas
   herramientas, sin acceso al repositorio.
2. **El secreto está versionado.** Cualquiera con acceso de lectura al repositorio —ahora, o
   en cualquier punto de su historial— lo tiene. Rotar el archivo no rota el historial.
3. **El transporte es HTTP plano contra una IP desnuda.** La cabecera viaja sin cifrar y el
   host no está autenticado, así que es interceptable y suplantable en tránsito.
4. **El remote que llega hasta ahí no tiene límite de frecuencia.**
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

- Los literales están en los cuatro archivos, idénticos — **HECHO**.
- `Shared/Monetization/MainModule.luau` está bajo `Core/ReplicatedStorage/` y su
  `.meta.json` no cambia su destino: solo fija un `SourceAssetId` — **HECHO**.
- Cuatro superficies distintas del proxy están en uso (`/users`, `/games`, `/groups`,
  `/thumbnails`, `/catalog`, `/apis/toolbox-service`), así que el secreto no abre un solo
  endpoint — **HECHO**.
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

**Actualización.** Al leer las seis máquinas enteras se comprobó que la clasificación
«latente» **no vale para todas**: `ToyMachine` sí tiene manejador de premio, y entrega un
objeto de inventario. Ese caso se separó en
[BUG-CANDIDATE-043](#bug-candidate-043). Esta entrada sigue describiendo a las otras cuatro
—`Stacker`, `PopTheLock`, `Basketball` y `Pong`—, y ahí sí sigue siendo latente. La tabla de
qué llega del cliente en cada una está en
[Máquinas de arcade](../systems/machines.md#las-otras-cuatro).

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

:::tip El patrón de arreglo ya existe en este repositorio

`ReferralMain.server.luau` se topó con **exactamente este riesgo** y lo resolvió, dejando
escrito el porqué:

```lua
--[[
	El volcado va por onBeforeClose y no por PlayerRemoving: PlayerDataInit tambien
	escucha PlayerRemoving para cerrar el perfil, y el orden entre dos conexiones
	al mismo evento no esta garantizado. Si el perfil se cerrara primero, los
	segundos de la sesion se perderian y un teleport a una casa reiniciaria la
	cuenta. onBeforeClose corre siempre antes del cierre.
]]
PlayerDataService.onBeforeClose(function(player)
	ReferralService.OnPlayerLeaving(player)
end)
```

`PlayerDataService.onBeforeClose` **sí** tiene orden garantizado: `close` ejecuta los
callbacks antes de soltar el store, y lo hace dentro de `pcall`.

Aplicado aquí, la limpieza de `DataComplete` dejaría de depender de qué manejador de
`Players.PlayerRemoving` gane la carrera. `Data.Main` ya usa ese mecanismo para su secuencia
de salida —`setExitSequence`, que corre dentro de `finalize`—; lo que quedó fuera es
justamente el borrado de la entrada.

Es una observación sobre la forma del arreglo, no una corrección aplicada: este proyecto no
cambia código.

:::

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

:::note Un segundo camino, con otro destino

`Stores/Added.luau` —la variante del place de donaciones— tiene la misma forma y el mismo
hueco:

```lua
for Name, Valor in ColorTexture do
	if not Changes[Name] then continue end
	v.Value:SetAttribute(Name, Valor)
end
```

Filtra el **nombre** contra `ColorTexture` y no toca el **valor**. El destino cambia: aquí
va a un `BoolValue` bajo `StoresData`, que `SPEC` persiste en el perfil `WorldsPlayer` del
propio jugador, no en el de una casa ajena. El daño sería a los datos de quien lo hace, lo
que baja mucho la gravedad de esta variante, pero el patrón es idéntico y conviene arreglar
los dos a la vez.

Una diferencia técnica que hay que comprobar: aquí el valor pasa por `Instance:SetAttribute`,
que impone sus propios límites de tipo y quizá de tamaño, mientras que en la ruta de casas
va directo a una tabla del DataStore.

:::

#### Incógnitas

- Qué hace DataKit ante una escritura que supera el límite del DataStore: si rechaza
  limpiamente y deja el perfil anterior intacto, la gravedad baja mucho.
- Si `UpdateStore` valida el tamaño de la sección antes de escribir. `WorldService.UpdateStore`
  no se ha releído con esta pregunta en mente.
- Cuántas ranuras `(carpeta, modelo)` tiene una casa real. Determina el techo acumulable.
- Si `Instance:SetAttribute` limita la longitud de una cadena. Decide si la variante de
  `Added.luau` es explotable o se cierra sola.

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


## BUG-CANDIDATE-022

### Un jugador puede añadir a su escaparate cualquier artículo del catálogo, sea suyo o no

**Sistema:** Monetización / Seguridad · **Clasificación:** Bug probable / Requiere pruebas de seguridad
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Alta

**Código relacionado:** `Core/…/Shared/Monetization/init.luau`, `AddedProductPlayer` y su
conexión en `Works`; `Core/…/Shared/Monetization/MainModule.luau`, `LoadProductInfo`
**Documentación relacionada:** [Monetización](../systems/monetization.md#sharedmonetization-el-camino-abierto)

#### Comportamiento observado — HECHO

El remote está conectado sin filtro, y el manejador toma dos argumentos del cliente:

```lua
self.Events.AddedProductPlayer.OnServerEvent:Connect(function(...) self:AddedProductPlayer(...) end)
```

```lua
function module:AddedProductPlayer(Player, ProductId, InfoType)
	if client then ...
	elseif typeof(ProductId) == 'number' and typeof(InfoType) == 'EnumItem' then

		local InventoryItems = Player and Player:FindFirstChild('InventoryItemsProucts')

		if InventoryItems and not InventoryItems:FindFirstChild(tostring(ProductId)) then
			...
			local product = self.RecolectarInfo.LoadProductInfo(ProductId, InfoType)

			if product and self.listItems[tostring(product.assetType)] then
				self.AddItem(tostring(ProductId), InfoType.Name).Parent = InventoryItems
```

Las comprobaciones que hace, en orden: que `ProductId` sea un número, que `InfoType` sea un
`EnumItem`, que el jugador tenga la carpeta, que no esté ya, y que el **tipo de asset** esté
en una lista de cuatro.

#### Por qué esto puede ser un problema — HECHO

`LoadProductInfo` es una consulta de **metadatos**, no de propiedad:

```lua
module.LoadProductInfo = function(ID, tipo)
	if not tonumber(ID) then return end
	local nice, product = pcall(function()
		return MPS:GetProductInfo(ID, tipo)
	end)
```

`GetProductInfo` devuelve nombre, precio y tipo de **cualquier** asset público de Roblox.
No dice nada sobre quién lo creó ni sobre quién lo posee. **En toda la ruta no hay ninguna
llamada a `UserOwnsGamePassAsync`, `PlayerOwnsAsset` ni equivalente.**

El contraste es directo dentro del mismo repositorio: `GamePassService.syncFromRoblox`, para
conceder un pase, sí llama a `UserOwnsGamePassAsync`. La comprobación existe y se usa a
cincuenta metros de aquí.

El destino tampoco es efímero: `InventoryItemsProucts` es una carpeta de `SPEC`, es decir
**se persiste en el perfil del jugador** y sobrevive a la sesión.

#### Teoría — TEORÍA

Un cliente modificado puede disparar `AddedProductPlayer` con el id de una camiseta, un
pantalón, una imagen o un gamepass creados por otra persona, y quedárselo listado en su
escaparate. Después, `GetProductPlayer` lo devuelve a todos los clientes junto a los
artículos que sí creó, sin distinguirlos.

Lo que **no** es: robo de Robux. Si otro jugador compra ese artículo, Roblox paga a su
creador real; el juego no interviene en el cobro. El daño es de atribución —un jugador
aparece vendiendo trabajo ajeno— y de contenido: `assetType` `0` es una imagen, así que la
lista blanca permite meter imágenes arbitrarias de Roblox en un escaparate del juego.

Hay una limpieza posterior, pero comprueba lo mismo:

```lua
if productSearched and self.listItems[tostring(productSearched.assetType)] then
	table.insert(newAdded.Data, productSearched)
else
	product:Destroy()
end
```

Filtra por tipo, no por autoría. Un artículo inyectado del tipo correcto sobrevive a la
limpieza indefinidamente.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `AddedProductPlayer.OnServerEvent` se conecta sin envoltorio ni validación previa |
| 2 | `ProductId` e `InfoType` vienen del cliente; solo se comprueba su **tipo de dato** |
| 3 | `LoadProductInfo` usa `GetProductInfo`, que es metadatos públicos |
| 4 | No hay ninguna llamada de propiedad en la ruta — `grep` sobre el módulo lo confirma |
| 5 | `GamePassService` sí verifica propiedad, en el mismo repositorio, para el caso análogo |
| 6 | `InventoryItemsProucts` está en `SPEC`, así que lo inyectado se persiste |
| 7 | La revalidación de `GetProductPlayer` filtra por `assetType`, no por autoría |

#### Incógnitas

- Si un `EnumItem` se puede enviar tal cual por un `RemoteEvent`. **INFERENCIA:** sí, Roblox
  los serializa; es lo primero que hay que confirmar y se comprueba en un minuto. Si no se
  pudiera, la guarda `typeof(InfoType) == 'EnumItem'` cerraría la entrada entera.
- Qué hace la interfaz con `ProductsPlayer`: si solo lo enseña, el daño es de imagen; si
  además abre un prompt de compra, la suplantación es más visible.
- Si `loadItems`, que consulta el proxy por `CreatorName`, se usa como fuente autoritativa
  en algún otro punto. Ahí la autoría **sí** está garantizada por la consulta.

#### Escenario de ejemplo

Un jugador copia el id de la camiseta más vendida de otro usuario y la añade a su
escaparate. Aparece listada como suya, junto a sus propias creaciones, y sigue ahí en las
siguientes sesiones porque está en su perfil.

**Comportamiento esperado:** solo se listan artículos que el jugador creó, que es lo que
`loadItems` obtiene del proxy.
**Comportamiento posible:** se lista cualquier asset público de los cuatro tipos admitidos.

#### Plan de verificación — *Seguridad*

1. Comprueba primero que un `EnumItem` viaja por un `RemoteEvent`: dispara
   `AddedProductPlayer` con `(1234567, Enum.InfoType.Asset)` y mira si el manejador entra en
   la rama del `elseif`. Si no entra, la entrada queda cerrada.
2. Con una cuenta que no haya creado nada, dispara el remote con el id de una camiseta
   pública de otro creador.
3. Mira si aparece un `StringValue` con ese id bajo `InventoryItemsProucts`.
4. Sal y vuelve a entrar; comprueba si sigue ahí.
5. Repite con un asset de tipo imagen (`assetType` `0`) y observa dónde se muestra.

**Pasa:** el remote rechaza el artículo por no pertenecer al jugador.
**Falla:** el artículo se añade, se persiste y se lista.

**Instrumentación sugerida:** un `warn` con el llamante y el id en cada
`AddedProductPlayer` aceptado. Diría de inmediato si esto ocurre ya en producción, y con qué
ids.


## BUG-CANDIDATE-023

### La posición de lo que se coloca la decide el cliente y el servidor no la comprueba

**Sistema:** Tiendas / Casas · **Clasificación:** Observación / Requiere pruebas de seguridad
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja · **Confianza:** Alta

**Código relacionado:** `Core/…/Shared/Stores/DecorFuncs/AddedDecor/init.luau`,
`module:Update`; `Core/…/Shared/Stores/init.luau`, `fn:UpdateDecor`
**Documentación relacionada:** [Tiendas y decoración](../systems/stores.md#los-trece-remotes)

#### Comportamiento observado — HECHO

El remote `Update` lleva una tabla del cliente hasta `AddedDecor:Update`, y ahí la posición
se aplica sin más:

```lua
model:PivotTo(Data.Position or model:GetPivot())
if not self.Data.NoScale then model:ScaleTo(Data.Scale) end
```

Lo llamativo es el **contraste con lo que sí se valida** en las líneas de alrededor:

| Campo del cliente | Qué se le hace |
|---|---|
| `Data.Scale` | `Positions.GetScale` lo pasa por `math.clamp` contra el rango declarado en el `Settings` del modelo |
| `Data.Colors` | Solo se aplican partes cuyo nombre sea `LightColor` o termine en dígito, y el color se sustituye por blanco si no es un `Color3` |
| `Data.IsOn` | Solo se acepta si el modelo tiene la etiqueta `Lamp` o `Interruptor` |
| El nombre del mueble | `verificarExistencia` lo resuelve contra `decoration template` o `Assets/ToolsModels` en el servidor |
| **`Data.Position`** | **Nada.** Se aplica tal cual |

#### Por qué esto puede ser un problema — HECHO

Toda la lógica de colocación vive en el cliente. `Client/Posicionamientos.luau` tiene
`IsInArea`, `GetFusion` y `getFace`; `Stores/init.luau` construye `RaycastParams` con
`fn:RayParams`; `AddedDecor/Collitions.luau` marca qué caras aceptan apoyo.

El servidor no ejecuta nada de eso. `Collitions.General` solo escribe un atributo
`Whitelist`, que es un dato **para** el cliente:

```lua
function module:General()
	if self.Disabled then
		local Part = self.Disabled.PrimaryPart or self.Disabled:FindFirstChild("Primary")
		if Part then
			Part:SetAttribute("Whitelist", table.concat({"Back","Front","Left","Right","Top"}, ","))
		end
	end
end
```

Y el resultado **se persiste**: `UpdateData` escribe el atributo `Position` en el `BoolValue`
del mueble, que acaba en `content.Objects` del perfil `World`.

#### Teoría — TEORÍA

Un cliente modificado puede colocar mobiliario en cualquier CFrame: atravesando paredes,
flotando fuera de la casa, dentro de otro mueble, o a coordenadas extremas. Como el permiso
lo concede `GetStore` a cualquier rol distinto de `46`, un invitado puede hacerlo en casa
ajena, y el resultado sobrevive al reinicio del servidor.

No es un exploit de economía: el mueble se paga igual. Es que **todas las reglas de
colocación son sugerencias**, porque quien las aplica es la parte que no manda.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `model:PivotTo(Data.Position or …)` sin ninguna comprobación previa |
| 2 | `Data.Scale` sí pasa por `math.clamp`: la validación de rango existe en el mismo bloque, para otro campo |
| 3 | `Posicionamientos`, `RayParams` y `Collitions` viven en el lado cliente o solo producen datos para él |
| 4 | `UpdateData` persiste `Position` como atributo, y de ahí va a `content.Objects` |
| 5 | El único punto donde se exige un `CFrame` es la primera colocación (`typeof(Data.Position)=="CFrame"`); en las actualizaciones posteriores un valor de otro tipo simplemente conserva la posición actual |

:::note Un segundo camino, y una asimetría que lo hace más claro

Colocar **herramientas** tiene el mismo hueco, en otro archivo.
`ToolPlacementServer.server.luau` valida los cuatro argumentos de `PlaceTool` por tipo, que
el jugador lleve puesta la herramienta y que sea `Colocable` — y después aplica la posición
tal cual:

```lua
local finalPosition = position + Vector3.new(0, size.Y / 2, 0)
local finalCFrame = CFrame.new(finalPosition) * CFrame.Angles(0, math.rad(rotY + 180), 0)
...
newModel:PivotTo(finalCFrame)
```

Lo llamativo es que **ese mismo archivo sí comprueba distancia para recoger**:
`canUsePlacedModel` rechaza a más de `MAX_PICKUP_DISTANCE = 30` studs, además de comprobar
contenedor, etiqueta y propiedad.

Es decir: recoger un objeto exige estar cerca; **colocarlo, no**. Un cliente modificado puede
dejar objetos a cualquier distancia, y después no poder recogerlos él mismo. La comprobación
que falta está escrita quince líneas más arriba, en el mismo archivo, para la operación
inversa.

Eso refuerza que es un olvido y no una decisión, y acota bastante la corrección: reutilizar
`canUsePlacedModel` —o solo su tramo de distancia— en `PlaceTool`.

:::

#### Incógnitas

- Si el juego se apoya en la física para corregir posiciones imposibles. Los muebles anclados
  no se mueven solos, así que probablemente no.
- Qué hace Roblox con un `CFrame` de coordenadas extremas o con `NaN`. `PivotTo` puede lanzar
  error, en cuyo caso el caso más burdo falla cerrado por accidente.
- Si existe una comprobación de límites en el sistema de construcción de parcelas
  (`BuildingSystem`), que es otro camino y no se ha leído.

#### Escenario de ejemplo

Un invitado con rol de constructor coloca una veintena de muebles atravesando las paredes y
flotando sobre el tejado de la casa de otro. El dueño vuelve a entrar al día siguiente y
siguen ahí, porque están guardados en el perfil.

**Comportamiento esperado:** el servidor rechaza una posición que el cliente no habría podido
producir jugando con normalidad.
**Comportamiento posible:** la acepta y la guarda.

#### Plan de verificación — *Seguridad*, *Funcional*

1. Entra en una casa con permiso de construcción y coloca un mueble por el camino normal.
2. Desde la consola del cliente, dispara `Decors.Update` con el mismo `BoolValue` y una tabla
   `{ Position = CFrame.new(0, 500, 0) }`.
3. Comprueba si el mueble se mueve ahí.
4. Reinicia el servidor de la casa y vuelve a entrar.
5. Comprueba si sigue en esa posición.

**Pasa:** la posición se rechaza o se corrige.
**Falla:** el mueble aparece a 500 studs de altura, y sigue ahí tras el reinicio.

**Instrumentación sugerida:** registrar la distancia entre `Data.Position` y el centro de la
casa en cada actualización. Un umbral generoso bastaría para detectar el abuso sin tener
que reimplementar las reglas de colocación en el servidor.


## BUG-CANDIDATE-024

### `MusicPlayer` reproduce el audio que le diga el cliente, en el modelo que le diga el cliente

**Sistema:** Interactuables / Seguridad · **Clasificación:** Bug probable / Requiere pruebas de seguridad
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Alta

**Código relacionado:** `Core/…/ServerScripts/interactable/MusicPlayer.server.luau` — el
archivo entero son 17 líneas
**Documentación relacionada:** [Interactuables](../systems/interactables.md#el-caso-peor-musicplayer)

#### Comportamiento observado — HECHO

```lua
remotes.Interactable.MusicPlayer.OnServerEvent:Connect(function(player, model, id)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local emitter = model.Emitter.Sound
	emitter.SoundId = id
	emitter:Play()
	print("aaa", id)
end)
```

La única comprobación —que el jugador tenga un `Humanoid`— no dice nada sobre `model` ni
sobre `id`. No hay comprobación de tipo, de etiqueta, de distancia, de propiedad, de lista
blanca de audios ni de frecuencia.

#### Por qué esto puede ser un problema — HECHO

El juego tiene un sistema entero dedicado a **moderar el audio**: `Karaoke/RevisarCanciones`
mantiene una cola de revisión, tiene métodos `AdminAdded` / `AdminRemoved`, y `Data.Main` lo
conecta al sistema de comandos de administración. `BusquedaMusicas` busca y cachea
canciones. Existe una decisión explícita de que no cualquier audio suene en el juego.

Esta ruta no pasa por nada de eso. Un `SoundId` va directo de un `RemoteEvent` a
`Sound.SoundId` y a `:Play()`.

#### Teoría — TEORÍA

Un cliente modificado puede reproducir **cualquier asset de audio de Roblox** en cualquier
modelo que tenga la ruta `Emitter.Sound`, y lo oye todo el que esté cerca de ese modelo. Ni
el `model` tiene que ser un tocadiscos ni el jugador tiene que estar cerca de él.

Es el vector clásico de vandalismo por audio, y además **elude la moderación de canciones
que el juego ya implementa** para el karaoke.

Segundo efecto, menor: `emitter:Play()` sin límite de frecuencia. Un bucle de llamadas
reinicia el sonido continuamente, lo que a los demás jugadores les llega como un chasquido
sostenido.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | El archivo completo son 17 líneas; no hay más validación en ninguna parte |
| 2 | `model.Emitter.Sound` se indexa directamente: no hay `HasTag("MusicPlayer")` ni `IsA("Model")` |
| 3 | `id` se asigna a `SoundId` sin comparar contra ninguna lista |
| 4 | Otros manejadores del mismo directorio **sí** comprueban etiqueta y distancia: `Fridge` hace las dos. La comprobación existe en el proyecto, no aquí |
| 5 | `Karaoke/RevisarCanciones` y `BusquedaMusicas` demuestran que la moderación de audio es un requisito reconocido del juego |
| 6 | Queda un `print("aaa", id)` de depuración, lo que sugiere que el archivo no llegó a revisarse |

#### Incógnitas

- Cuántos modelos del juego tienen la ruta `Emitter.Sound`. Determina el alcance: si solo la
  tienen los tocadiscos, el vandalismo se limita a esos puntos.
- Si el `Sound` es 3D con `RollOffMaxDistance` corto, lo que acotaría quién lo oye.
- Si Roblox filtra el audio al reproducirlo. Los assets de audio subidos por terceros están
  restringidos desde 2022, lo que **reduce mucho** la gravedad: la mayoría de ids ajenos no
  sonarían. Es lo primero que hay que comprobar, y puede rebajar esta entrada a molestia.

#### Escenario de ejemplo

Un jugador dispara el remote en bucle con el id de un audio desagradable, apuntando al
tocadiscos de una casa llena de gente. Nadie más puede pararlo desde la interfaz, porque la
interfaz no es la que lo está mandando.

**Comportamiento esperado:** solo suenan audios aprobados, en tocadiscos reales, para quien
esté cerca.
**Comportamiento posible:** suena cualquier audio, en cualquier emisor, desde cualquier
distancia.

#### Plan de verificación — *Seguridad*

1. Comprueba primero si Roblox permite reproducir un audio ajeno en esta experiencia. Si no,
   la gravedad baja a «puede reiniciar el sonido en bucle».
2. Desde la consola del cliente, dispara `Interactable.MusicPlayer` con un tocadiscos
   legítimo y un id arbitrario.
3. Repite estando al otro lado del mapa.
4. Repite apuntando a un modelo que no sea un tocadiscos pero tenga `Emitter.Sound`.
5. Llama en bucle y observa el efecto para el resto de jugadores.
6. **Repite los pasos 2 a 5 con un piano.** `Piano.luau` dispara este mismo remote —no
   tiene uno propio, ni script de servidor propio— así que una prueba que solo mire los
   tocadiscos no cubre la mitad de la superficie. Ver
   [Catálogo de tipos](../systems/interactable-types.md#dos-tipos-que-comparten-el-remote-de-otro).

**Pasa:** el servidor rechaza el modelo, la distancia o el id.
**Falla:** cualquiera de los pasos produce sonido.

**Instrumentación sugerida:** el `print` que ya está ahí, convertido en `warn` con el nombre
del jugador y la distancia al modelo, diría de inmediato si esto ya ocurre en producción.

---

## BUG-CANDIDATE-025

### La distancia de interacción la comprueba solo el cliente

**Sistema:** Interactuables · **Clasificación:** Observación / Requiere pruebas de seguridad
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja · **Confianza:** Alta

**Código relacionado:** `Core/…/Client/interactable/Interactable/init.luau`, constantes de
distancia y línea de visión; los 25 scripts de `Core/…/ServerScripts/interactable/`
**Documentación relacionada:** [Interactuables → La matriz de validación](../systems/interactables.md#la-matriz-de-validación)

#### Comportamiento observado — HECHO

La clase base declara las reglas de interacción:

```lua
local MAX_INTERACTION_DISTANCE = 18
local LINE_OF_SIGHT_INTERVAL = .05
local LINE_OF_SIGHT_MARGIN = 5
```

y las aplica sobre `players.LocalPlayer`. Es un módulo de cliente: el servidor no lo carga.

De los 25 manejadores de servidor, **cuatro** vuelven a comprobar la distancia: `Fridge`,
`Tijeras`, `Bed` y `DoubleBed`. Los otros veintiuno operan sobre la `Instance` que reciben.

#### Por qué esto puede ser un problema — HECHO

Varios de esos veintiuno tienen efectos reales:

| Manejador | Efecto sin comprobar distancia |
|---|---|
| `Shower`, `Washbasin`, `Toilet`, `Bath` | `character:PivotTo(...)` — **teletransportan al jugador** al objeto, esté donde esté |
| `Shower`, `Washbasin` | Escriben `Occupant.Value = player` sobre el modelo recibido |
| `ClassicDoor` | Abre y cierra una puerta desde cualquier distancia |
| `Display` | Escribe el atributo `Video` de un modelo cualquiera |
| `DiscoBall`, `SmokeMachine`, `Lamp` | Activan efectos a distancia |
| `Treadmill`, `Weight` | Conceden progreso de estadísticas |

`Washbasin` es el más ilustrativo porque indexa `model.Occupant` y `model.Player`
directamente: cualquier modelo con esos dos hijos sirve como destino de teletransporte y
puede quedar «ocupado» por quien lo pida.

#### Teoría — TEORÍA

La consecuencia no es un exploit de economía: es que **las reglas de interacción son
decorativas**. Un cliente modificado puede usar cualquier interactuable del mapa sin
acercarse, ocupar objetos que no está usando para que otros no puedan, y teletransportarse
a cualquier lavabo o ducha del place.

Lo que hace de esto una observación de arquitectura y no un fallo puntual es que **el
framework no ofrece la comprobación**. `Interactable` monta el `ProximityPrompt` y aplica la
distancia en el cliente, pero no expone nada que un script de servidor pueda invocar para
comprobar lo mismo. Los cuatro que lo hacen bien lo escriben a mano, cada uno a su manera:
`Bed` y `DoubleBed` usan `player:DistanceFromCharacter(...) > 20`, `Tijeras` una constante
propia, `Fridge` la resta de posiciones.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | Las tres constantes de interacción están en un módulo que solo el cliente carga |
| 2 | 4 de 25 manejadores comprueban distancia; 8 de 25 comprueban la etiqueta |
| 3 | Los que la comprueban usan formas y umbrales distintos: 18 en el cliente, 20 en `Bed` y `DoubleBed`, 30 en `ToolPlacementServer` |
| 4 | `Washbasin` indexa `model.Occupant` y `model.Player` sin comprobar nada |
| 5 | No existe ninguna función auxiliar compartida de validación en `ServerScripts/interactable/` — aunque sí una equivalente, privada, en `ToolPlacementServer.server.luau` |

#### Incógnitas

- Si alguna capa anterior filtra estos remotes. No se ha encontrado ninguna, pero
  `StarterPlayerScripts.rbxm` es binario (ver **U-001**) y podría contener algo, aunque el
  cliente no puede imponer nada al servidor.
- Cuál es el umbral correcto. El cliente usa 18, `Bed` usa 20. Elegir uno es una decisión de
  producto, no de lectura de código.

#### Escenario de ejemplo

Un jugador se sienta en un rincón del mapa y va marcando estadísticas de higiene en todas
las duchas del place sin moverse, mientras deja «ocupados» los lavabos de una casa ajena.

**Comportamiento esperado:** el servidor rechaza una interacción que el cliente no habría
podido iniciar por distancia.
**Comportamiento posible:** la acepta.

#### Plan de verificación — *Seguridad*

1. Colócate lejos de una ducha y dispara `Interactable.Shower` con su modelo.
2. Comprueba si tu personaje se teletransporta.
3. Repite con `WashHands` sobre un lavabo de otra casa y mira si su `Occupant` queda fijado.
4. Repite con `Treadmill` y comprueba si las estadísticas suben.
5. Contrasta con `Fridge`, que debería rechazarte.

**Pasa:** todos los manejadores rechazan por distancia, como hace `Fridge`.
**Falla:** cualquiera de ellos actúa.

:::tip Esa función ya existe en el repositorio

`ToolPlacementServer.server.luau` tiene `canUsePlacedModel(player, model)`, que comprueba
tipo, contenedor esperado, etiqueta de `CollectionService`, propiedad, personaje vivo **y
distancia**, y con la que empiezan sus cuatro manejadores.

Es exactamente la forma de la solución que este plan propone. Está escrita, funciona, y es
privada a ese archivo. Extraerla a un módulo compartido es bastante menos trabajo que
escribirla desde cero, y da además un criterio único de umbral —hoy conviven 18 en el
cliente, 20 en `Bed` y 30 aquí.

:::

**Instrumentación sugerida:** en vez de parchear 21 archivos, extraer la función que ya
existe —`canUsePlacedModel`— a un módulo compartido, y una pasada añadiéndola al principio de
cada manejador. Es un **cambio de código**, así que queda registrado aquí y no aplicado; se
menciona porque la forma de la solución explica por qué el problema existe: hoy no hay
dónde ponerla.


## BUG-CANDIDATE-026

### El globo está implementado entero y ningún jugador lo recibe nunca

**Sistema:** Inventario · **Clasificación:** Bug probable / Confirmado por análisis estático
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja · **Confianza:** **Muy alta**

**Código relacionado:** `Core/…/ServerScripts/inventory/InventoryManager/DefaultTools.luau`,
la entrada `Ballon`; `InventoryManager/init.luau`, `ensureDefaultInventory`
**Documentación relacionada:** [Inventario y herramientas](../systems/inventory.md#el-equipamiento-por-defecto-solo-ocurre-una-vez)

#### Comportamiento observado — HECHO

`DefaultTools` declara diez objetos. La entrada `Ballon` dice esto:

```lua
Ballon = {
	Name = 'GloveGun',
	Value = true,
	DefaultSlot = 6
},
```

El campo `Name` dice `GloveGun`. La entrada inmediatamente anterior es:

```lua
GloveGun = {
	Name = 'GloveGun',
	Value = true,
	DefaultSlot = 5
},
```

Y el bucle que concede los objetos **usa el campo `Name`, no la clave de la tabla**:

```lua
for _, toolData in pairs(DefaultTools) do
	if toolData.Value == true and typeof(toolData.Name) == "string" then
		local toolName = toolData.Name
		inventory.items[toolName] = 1
		if toolData.DefaultSlot then
			...
			inventory.wheel[tostring(slot)] = toolName
		end
	end
end
```

#### Por qué esto es un problema — HECHO

El resultado es aritmético, no hipotético:

| | Lo que se pretendía | Lo que ocurre |
|---|---|---|
| `items` | `GloveGun = 1`, `Ballon = 1` | `GloveGun = 1` escrito dos veces. **`Ballon` no existe** |
| `wheel["5"]` | `GloveGun` | `GloveGun` |
| `wheel["6"]` | `Ballon` | `GloveGun` otra vez |

Y `Ballon` **no es un objeto a medio hacer**. Está completo:

| Pieza | Ruta |
|---|---|
| Modelo de la herramienta | `Assets/Tools/Toys/Ballon/` |
| Script de cliente | `Assets/Tools/Toys/Ballon/MainTool.client.luau` |
| `RemoteEvent` | `Events/Tools/Ballon` |
| Manejador de servidor | `ToolsServer.server.luau`, `ballonRemote.OnServerEvent` |
| Malla | `Assets/VisualItems/Ballon.rbxm` |

Un `grep` por `Ballon` sobre todo `src/` no encuentra **ninguna otra vía** de concesión: ni
tienda, ni recompensa de gamepass, ni comando. `DefaultTools` es el único camino, y está
roto.

#### Lo que agrava la consecuencia — HECHO

`ensureDefaultInventory` corre **una sola vez en la vida de los datos de cada jugador**:

```lua
if inventory.defaultsInitialised then
	return
end
```

La bandera es correcta y está bien razonada —evita devolver objetos que alguien gastó a
propósito—, pero significa que **arreglar el typo no repara a nadie**. Todo jugador que ya
haya entrado tiene su `defaultsInitialised` a `true` y nunca volverá a pasar por ese bucle.
Repararlo exigiría una migración explícita.

#### Teoría — TEORÍA

Lo único que la lectura estática no puede confirmar es si algún sistema no leído concede
`Ballon` por otra vía. La búsqueda dice que no, pero 481 archivos siguen sin leerse.

También cabe que sea deliberado: que el globo se retirase y se dejara la entrada apuntando a
otro objeto para no tocar los slots. En contra de esa lectura está que `DefaultSlot = 6`
sigue ahí, produciendo un `GloveGun` duplicado en la rueda, que no beneficia a nadie.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | El campo `Name` de `Ballon` dice `GloveGun` |
| 2 | El bucle de concesión lee `toolData.Name`, no la clave |
| 3 | El globo tiene modelo, script de cliente, remote y manejador de servidor |
| 4 | `grep -rn Ballon src/` no muestra ninguna otra ruta de concesión |
| 5 | `defaultsInitialised` hace la consecuencia permanente para los jugadores existentes |
| 6 | El resultado colateral —dos slots de rueda con `GloveGun`— no tiene ninguna utilidad |

#### Incógnitas

- Si el globo se retiró a propósito del juego. Es una pregunta para el equipo, no para el
  código.
- Cuántos jugadores tienen ya `defaultsInitialised`, que es cuánta gente necesitaría la
  migración.

#### Escenario de ejemplo

Un jugador nuevo entra. Recibe nueve objetos en vez de diez, y su rueda tiene el mismo
lanzaguantes en los huecos 5 y 6. Nunca ve el globo, y no hay forma de conseguirlo.

**Comportamiento esperado:** `items.Ballon = 1` y `wheel["6"] = "Ballon"`.
**Comportamiento posible:** `Ballon` no aparece y el hueco 6 duplica el hueco 5.

#### Plan de verificación — *Funcional*

1. En un place de pruebas, entra con una cuenta que no haya jugado nunca.
2. Vuelca `PlayerDataService.getData(player).inventory` desde la consola del servidor.
3. Comprueba si existe la clave `Ballon` en `items`.
4. Mira qué hay en `wheel["5"]` y `wheel["6"]`.
5. Mira la mochila: comprueba si hay una `Tool` llamada `Ballon`.

**Pasa:** `items.Ballon` existe y la rueda tiene dos objetos distintos.
**Falla:** no existe `Ballon` y los huecos 5 y 6 dicen ambos `GloveGun`.

**Instrumentación sugerida:** ninguna. Es una comprobación de dos minutos con un `print`, y
el diagnóstico ya está cerrado. Lo que hace falta decidir es la migración para las cuentas
que ya pasaron por ahí.

---

## BUG-CANDIDATE-027

### `ToolsServer` reparenta y manipula las `Instance` que le diga el cliente

**Sistema:** Herramientas / Seguridad · **Clasificación:** Bug probable / Requiere pruebas de seguridad
**Estado:** Sin verificar · **Gravedad si se confirma:** Alta · **Confianza:** Alta

**Código relacionado:** `Core/…/ServerScripts/ToolsServer.server.luau` —
`equipRemoteAccesory`, `flyRemote`, `equipRemote`
**Documentación relacionada:** [Inventario y herramientas → Las herramientas](../systems/inventory.md#las-herramientas)

#### Comportamiento observado — HECHO

El caso más directo son diez líneas:

```lua
equipRemoteAccesory.OnServerEvent:Connect(function(player: Player, handle: Part, accesory: BasePart, isEquipping: boolean)
	local character = player.Character or player.CharacterAdded:Wait()

	if not accesory or not handle then return end

	if isEquipping then
		accesory.Parent = character
	else
		accesory.Parent = handle.Parent
	end
end)
```

`accesory` y `handle` son referencias a `Instance` que **elige el cliente**. No se comprueba
su clase, ni dónde están, ni de quién son. Las anotaciones de tipo `Part` y `BasePart` son
documentación: Luau no las impone en tiempo de ejecución, y un `RemoteEvent` acepta cualquier
`Instance`.

Los otros dos tienen la misma forma con menos alcance:

```lua
equipRemote.OnServerEvent:Connect(function(player, handle: Part)
	local equipSound = handle:FindFirstChild("EquipSound")
	if equipSound and equipSound:IsA("Sound") then
		equipSound:Play()
	end
end)

flyRemote.OnServerEvent:Connect(function(player, particles1, particles2, toggle, startSound, runningSound, stopSound)
	...
	particles1.Enabled = toggle
	particles2.Enabled = toggle
	if toggle then startSound:Play() ...
```

#### Por qué esto puede ser un problema — HECHO

`equipRemoteAccesory` es una **primitiva de reparentado arbitrario** accesible desde
cualquier cliente:

| Llamada | Efecto |
|---|---|
| `accesory` = una parte del mundo, `isEquipping` = true | Esa parte se mueve al personaje de quien llama |
| `accesory` = la `Tool` de otro jugador, `isEquipping` = true | La herramienta ajena se reparenta al personaje de quien llama |
| `accesory` = cualquier cosa, `handle` = cualquier cosa, `isEquipping` = false | Reparentado de A al padre de B: dos referencias arbitrarias, un movimiento arbitrario |

Reparentar es además cómo se destruye lógica en Roblox: mover un modelo fuera de su
contenedor rompe los `WaitForChild` y las jerarquías que otros scripts asumen. En este
repositorio hay bastante código que depende de la jerarquía —`model.Emitter.Sound`,
`model.Occupant`, `self.Added.DataObjects`— y ese código se rompe o cambia de sentido si su
árbol se mueve.

Lo llamativo es que **el mismo archivo contiene el ejemplo correcto**, dos manejadores más
abajo:

```lua
cannonRemote.OnServerEvent:Connect(function(player, action, tool, a, b, c)
	if not tool or not tool:IsA("Tool") then return end
	...
	if tool.Parent ~= character then
		return
	end
```

Clase y propiedad, antes de nada, más un cooldown de cinco segundos. `GloveGun` hace lo
mismo. La comprobación existe, en el archivo, escrita por la misma mano.

#### Teoría — TEORÍA

Un cliente modificado puede mover objetos del mundo a su personaje, retirar objetos de otros
jugadores, y desmontar jerarquías de las que dependen otros sistemas. Con `flyRemote`, además,
puede activar cualquier `ParticleEmitter` y reproducir cualquier `Sound` del DataModel.

Ninguna de estas rutas concede moneda, así que no es un exploit económico. Es control sobre
el mundo compartido.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `accesory.Parent = character` sin comprobación de clase, ubicación ni propiedad |
| 2 | `accesory.Parent = handle.Parent` — las dos referencias vienen del cliente |
| 3 | Las anotaciones `: Part` y `: BasePart` no se validan en ejecución |
| 4 | `flyRemote` escribe `.Enabled` y llama a `:Play()` sobre cinco referencias del cliente |
| 5 | `Cannon` y `GloveGun`, en el mismo archivo, sí comprueban `IsA("Tool")` y `tool.Parent == character` |
| 6 | No hay límite de frecuencia en ninguno de los tres |

#### Incógnitas

- Si la replicación de Roblox permite al cliente pasar una referencia a una `Instance` que su
  cliente no ve. Para cualquier cosa en `Workspace` y `ReplicatedStorage`, sí.
- Qué rompe en la práctica reparentar un modelo de mobiliario: los sistemas de casas escuchan
  `AncestryChanged` y podrían tratarlo como una eliminación, lo que llevaría el efecto hasta
  el perfil persistido.

#### Escenario de ejemplo

Un jugador dispara `EquipToolAccesory` con la `Tool` equipada de otro jugador y
`isEquipping = true`. La herramienta se mueve a su personaje. Repite con muebles de una casa
para sacarlos de `DataObjects`, que es donde el sistema de casas espera encontrarlos.

**Comportamiento esperado:** el servidor solo reparenta accesorios de una herramienta que el
jugador tiene equipada.
**Comportamiento posible:** reparenta lo que se le pida.

#### Plan de verificación — *Seguridad*

1. Con dos cuentas, la segunda con una herramienta equipada.
2. Desde la consola del cliente de la primera, dispara `Tools.EquipToolAccesory` con esa
   herramienta y `isEquipping = true`.
3. Comprueba dónde acaba la herramienta.
4. Repite con un mueble colocado dentro de una casa y observa si el sistema de casas lo
   trata como eliminado (y si eso llega al perfil).
5. Contrasta con `Tools.Cannon` usando la herramienta de otro: debería rechazarte.

**Pasa:** los tres manejadores rechazan `Instance` que no pertenecen al llamante.
**Falla:** cualquiera de los pasos 3 o 4 tiene efecto.

**Instrumentación sugerida:** registrar el `GetFullName()` de `accesory` y el nombre de quien
llama. Dos líneas, y diría de inmediato si esto ya se está usando.


## BUG-CANDIDATE-028

### Tres cargadores de moderación comprueban que haya un administrador conectado, no que quien llama lo sea

**Sistema:** Karaoke / Seguridad · **Clasificación:** Posible bug / Requiere pruebas de seguridad
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja · **Confianza:** Alta

**Código relacionado:** `Core/…/Shared/Karaoke/RevisarCanciones/init.luau` —
`CargarMusicasServer`, `CargarMusicaReport`, `CargarMusicasBaneadas`, `IsAviableToUpdate`
**Documentación relacionada:** [Karaoke → Dónde se rompe el patrón](../systems/karaoke.md#dónde-se-rompe-el-patrón)

#### Comportamiento observado — HECHO

El manejador reparte sin comprobar nada, y confía la autorización a cada método:

```lua
self.Events.CargarMusicas.OnServerEvent:Connect(function(Staff, TypeBusqueda, Page)
	if TypeBusqueda == "CargarMusicasServer" then
		self:CargarMusicasServer(Page, Staff)
	elseif TypeBusqueda == "CargarMusicaReport" then
		self:CargarMusicaReport(Page, Staff)
	elseif TypeBusqueda == "CargarMusicasBaneadas" then
		self:CargarMusicasBaneadas(Page, Staff)
	elseif self.Admins:IsAdmin(Staff) then          -- ← la única rama que comprueba al llamante
		self:UpdateMusicas()
	end
end)
```

Y los tres métodos comprueban otra cosa:

```lua
elseif #self.AdminsActive > 0 and typeof(Page) == 'number' then
	local Data, NewData = self.DataStore:GetData('RevisionRating', true, self.SongPorPagina, Page)
```

`AdminsActive` es la lista de administradores **presentes en este servidor**. La condición
dice «hay algún moderador conectado», no «tú eres moderador». El parámetro `Staff` llega al
método y no se usa para autorizar.

`CargarMusicasBaneadas` usa `IsAviableToUpdate(true)`, que parece más estricto pero mira lo
mismo:

```lua
function module:IsAviableToUpdate(SuperAdmin)
	if not SuperAdmin or #self.AdminsActive == 0 then return #self.AdminsActive > 0 end
	for _, Admin in self.AdminsActive do
		if self.Admins:IsAdmin(Admin, true) then
			return true
		end
	end
end
```

Recorre a **los administradores conectados** buscando un superadministrador. Nunca mira a
quien llamó.

#### Por qué esto puede ser un problema — HECHO

Con un moderador conectado, cualquier jugador puede disparar:

| Efecto | Detalle |
|---|---|
| Una lectura paginada de DataStore | `GetData('RevisionRating' \| 'DenunciasRating' \| 'BaneosRating', …)`, contra la cuota del juego |
| El vaciado de la caché de páginas | `ListDatas = NewData and {} or ListDatas` reemplaza lo que los moderadores tenían precargado |
| Con la página que quiera | `Page` solo se comprueba con `typeof(Page) == 'number'`: ni entero, ni rango |

#### Lo que limita el daño — HECHO

Y es importante decirlo, porque cambia la gravedad. `CargarMusicasServer` termina así:

```lua
self:ObtenerMusica(0, nil, Player)
```

`ObtenerMusica` **sí** comprueba al llamante, y no es amable:

```lua
if self.Admins:IsAdmin(StaffRequerest, Page == 2) then
	self.Events.ObtenerMusicas:FireClient(StaffRequerest, Page, self.PreloadSongs[Selection])
else
	self.Admins:IntenteSerAdmin(StaffRequerest)   -- Player:Kick(...)
end
```

De modo que un no administrador **es expulsado** al final del recorrido, y **no recibe
ninguno de los datos**. No es una fuga de información: la lista de canciones en revisión no
sale del servidor.

Lo que sí ocurre antes de la expulsión es el trabajo: la lectura de DataStore se hace y la
caché se reemplaza. El atacante puede volver a entrar y repetir.

#### Teoría — TEORÍA

Es una defensa en profundidad que funciona a medias. La guarda correcta está en el sitio
equivocado —al final, en vez de a la entrada—, así que la autorización protege los **datos**
pero no los **recursos**. Un cliente en bucle de entrar-disparar-ser expulsado-volver puede
consumir cuota de DataStore y mantener la interfaz de los moderadores vaciándose sola.

Lo que hace pensar que es un descuido y no un diseño es el contraste dentro del mismo
archivo: `ViewLyric`, `Desbanear`, `ActionSongDenunce`, `AprovarRechazarMusicaAction` y
`PublishRevisarMusic` **sí** comprueban al llamante lo primero. Estos tres son la excepción.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | La condición es `#self.AdminsActive > 0`, una propiedad del servidor, no del llamante |
| 2 | El parámetro `Staff`/`Player` llega a los tres métodos y no se usa para autorizar |
| 3 | `IsAviableToUpdate` recorre los administradores conectados, nunca al llamante |
| 4 | `Page` solo se comprueba de tipo, y va directo a una lectura paginada de DataStore |
| 5 | Los otros cinco manejadores del archivo comprueban al llamante lo primero |
| 6 | La expulsión llega **después** de la lectura, no antes |

#### Incógnitas

- Cuánto cuesta realmente `GetData` con paginación. Si cachea agresivamente, el abuso de
  cuota es despreciable y esto se queda en una molestia para los moderadores.
- Si `Page` fuera de rango produce un error atrapado o una lectura cara. No se ha leído
  `GlobalDataStore:GetData`.
- Cuánto tarda Roblox en dejar volver a entrar a un jugador expulsado. Determina la
  frecuencia máxima del abuso.

#### Escenario de ejemplo

Un jugador con un cliente modificado espera a ver a un moderador conectado, dispara
`CargarMusicas` con `"CargarMusicaReport"`, es expulsado, vuelve a entrar y repite. El
moderador ve su lista de denuncias vaciarse y recargarse sin haber tocado nada.

**Comportamiento esperado:** el remote rechaza —o expulsa— antes de leer nada.
**Comportamiento posible:** lee, reemplaza la caché, y expulsa después.

#### Plan de verificación — *Seguridad*

1. Con dos cuentas, una con el rango `KaraokeAdmins` en el grupo, ambas en el mismo servidor.
2. Desde la consola del cliente de la cuenta sin rango, dispara
   `Karaoke.CargarMusicas` con `("CargarMusicasServer", 0)`.
3. Comprueba en el registro del servidor si la lectura de DataStore ocurre.
4. Comprueba si la cuenta sin rango es expulsada, y si recibió algún dato antes.
5. Comprueba en el cliente del moderador si su lista se recarga.
6. Repite con el moderador desconectado: no debería ocurrir nada.

**Pasa:** no hay lectura de DataStore cuando quien llama no es administrador.
**Falla:** la lectura ocurre y la caché se reemplaza, aunque el llamante acabe expulsado.

**Instrumentación sugerida:** un `warn` con el nombre del llamante y su condición de
administrador al principio de los tres métodos. Diría de inmediato si esto se está usando y,
de paso, es donde tendría que ir la comprobación.


## BUG-CANDIDATE-029

### Borrar un cuadro reintenta por recursión, sin límite y sin cortacircuitos

**Sistema:** Cuadros · **Clasificación:** Posible bug / Requiere inyección de fallos
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Alta

**Código relacionado:** `Core/…/Shared/Paint/ServerClient/init.luau`, `module:Remove` — las
funciones locales `GetData` y `Delete`
**Documentación relacionada:** [Cuadros → El borrado y sus reintentos](../systems/paint.md#el-borrado-y-sus-reintentos)

#### Comportamiento observado — HECHO

Dentro de `Remove` hay dos funciones locales que reintentan llamándose a sí mismas:

```lua
local esperar = task.wait
local function GetData()
	local Sucesss, DataPintura = self.DataBase:GetData("DataPinturas", KeyCuadro)
	local OwnerCuadro = Sucesss and DataPintura and Format.IsOwner(Player, DataPintura)
	if OwnerCuadro then
		local function Delete()
			local success, _ = self.DataBase:DeleteData('DataPinturas', KeyCuadro)
			if not success then
				warn('error al eliminar este cuadro, intentando de nuevo.')
				Delete(esperar(self.ColaLoad.TimeExhauste / self.ColaLoad.MaxLoads))
			else
				warn('Cuadro eliminado por completo.')
			end
		end
		Delete()
	elseif not Sucesss then
		warn('error al obtener el dato del cuadro, intentando de nuevo.')
		GetData(esperar(self.ColaLoad.TimeExhauste / self.ColaLoad.MaxLoads))
	else
		warn('No eres dueño del cuadro, no puedes eliminarlo.')
	end
end
GetData()
```

Ni `GetData` ni `Delete` aceptan parámetros: el `esperar(...)` que se les pasa está ahí solo
para introducir la pausa antes de la llamada. **Ninguna de las dos tiene contador de
intentos ni condición de parada** distinta del éxito.

#### Por qué esto puede ser un problema — HECHO

Tres cosas se acumulan:

1. **No es un bucle, es recursión.** Una llamada en posición de sentencia no es una llamada
   de cola en Luau, así que cada reintento **añade un marco de pila**. Un fallo persistente
   crece la pila hasta agotarla.
2. **No hay techo de intentos.** Con el DataStore caído, el hilo reintenta indefinidamente,
   una vez cada 3 segundos (`TimeExhauste / MaxLoads` = 60/20).
3. **No hay cortacircuitos.** Esto usa `GlobalDataStore`, que llama a `DataStoreService`
   directamente, **fuera de DataKit**, así que no tiene detrás el `Health` que corta tras
   cinco fallos y que protege al resto del juego (ver **U-008**).

Además, los efectos visibles ya ocurrieron **antes** del bucle: `table.remove` sobre la lista
del jugador, `RemoveCache`, y `Load` reenviando la lista al cliente. Para el jugador el
cuadro ya no existe; lo que puede quedar colgado indefinidamente es el borrado real.

#### Teoría — TEORÍA

Con `DataStoreService` degradado —throttling, incidencia de Roblox— cada intento de borrado
deja un hilo vivo reintentando cada 3 segundos y creciendo en pila. Varios jugadores
borrando durante la incidencia dejan varios hilos así. Ninguno se rinde, ninguno avisa a
nadie más allá de un `warn`, y el consumo de cuota de DataStore sigue durante toda la
incidencia, que es justo cuando conviene reducirlo.

El desenlace probable es un error de desbordamiento de pila muchos minutos después, no una
caída inmediata. Eso lo hace difícil de correlacionar con su causa.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `Delete` se llama a sí misma en la rama de fallo, sin contador |
| 2 | `GetData` hace lo mismo, con la misma forma |
| 3 | La llamada está en posición de sentencia, no `return`: no es una llamada de cola |
| 4 | El intervalo es fijo: `TimeExhauste / MaxLoads`, sin retroceso exponencial |
| 5 | `GlobalDataStore` está fuera de DataKit, así que no hay `Health` que corte |
| 6 | Los efectos en la lista del jugador y en la caché ya se aplicaron antes de entrar al bucle |

#### Incógnitas

- ~~Si `GlobalDataStore:GetData` y `DeleteData` traen su propio reintento interno.~~
  **Resuelto:** no lo traen. Cada operación es un único `pcall` sin reintento y sin
  cortacircuitos, así que este bucle es el único reintento del sistema — y sigue siendo el
  único sin techo. Ver [Persistencia fuera de DataKit](../systems/global-storage.md).
- **Añadido tras leer `GlobalDataStore`:** este bucle puede dispararse **sin que el DataStore
  falle**. Si el borrado colisiona con una escritura sobre la misma clave, `DeleteData`
  devuelve `nil` sin haber borrado, el bucle lo lee como fallo y reintenta. Ver
  [BUG-CANDIDATE-033](#bug-candidate-033).
- Cuántos marcos de pila aguanta Luau aquí. A un reintento cada 3 segundos, alcanzar el
  límite lleva horas: la consecuencia realista es el consumo sostenido, no el desbordamiento.

#### Escenario de ejemplo

Roblox tiene una incidencia de DataStore. Diez jugadores borran un cuadro. Diez hilos
reintentan cada tres segundos durante las dos horas que dura la incidencia, sumando cuota
justo cuando está limitada. En los registros solo se ve `error al eliminar este cuadro,
intentando de nuevo` repetido.

**Comportamiento esperado:** unos pocos reintentos con retroceso, y después rendirse
dejando constancia.
**Comportamiento posible:** reintentos indefinidos que crecen en pila.

#### Plan de verificación — *Recuperación ante fallos*

1. En un place de pruebas, sustituye temporalmente `DataBase.DeleteData` por una función que
   devuelva siempre fallo. *(Instrumentación para la prueba, no una corrección.)*
2. Borra un cuadro.
3. Cuenta los `warn` durante cinco minutos y confirma el intervalo de 3 segundos.
4. Comprueba si el hilo se detiene alguna vez por sí solo.
5. Repite con `GetData` fallando, para la otra rama.

**Pasa:** los reintentos se detienen tras un número acotado.
**Falla:** siguen indefinidamente.

**Instrumentación sugerida:** un contador de intentos en el `warn`. Convierte «esto falló
otra vez» en «este es el intento 240», que es la información que hace falta para actuar.

---

## BUG-CANDIDATE-030

### El límite de ritmo al editar un cuadro solo existe en el cliente, y el servidor difunde a todos

**Sistema:** Cuadros / Seguridad · **Clasificación:** Posible bug / Requiere pruebas de seguridad
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Alta

**Código relacionado:** `Core/…/Shared/Paint/ServerClient/init.luau`, `module:UpdateCuadros`
y las constantes `timeUpdate` / `MaxUpdateDistance` de `module.init`
**Documentación relacionada:** [Cuadros → La red](../systems/paint.md#la-red)

#### Comportamiento observado — HECHO

`UpdateCuadros` corre en los dos lados. El límite de ritmo está dentro de la rama de cliente:

```lua
if IsClient then
	local now = tick()
	if not force and (self.DateTimeUpdate and (now - self.DateTimeUpdate) < (self.timeUpdate or 0.5)) then
		return
	end
	self.DateTimeUpdate = now
end
```

Y la difusión, dentro de la de servidor:

```lua
for _, OtherPlayer in game:GetService('Players'):GetPlayers() do
	if ModeloCuadro:GetAttribute("Owner") or OtherPlayer ~= Player then
		events:FindFirstChild('Update'):FireClient(OtherPlayer, ModeloCuadro, serializacion)
	end
end
```

En el servidor no se comprueba ningún ritmo. `DateTimeUpdate` solo se escribe en la rama de
cliente.

#### Por qué esto puede ser un problema — HECHO

Las guardas de **autorización** están bien puestas —etiqueta del modelo y atributo `Owner`
o `InInUse` igual al `UserId`, ambos escritos por el servidor— así que un jugador solo puede
editar su propio lienzo. El problema no es quién, es **cuántas veces**:

| | Valor |
|---|---|
| Intervalo previsto entre actualizaciones | `timeUpdate = 3` segundos |
| Dónde se impone | Solo en el cliente |
| Destinatarios de cada actualización | Todos los jugadores del servidor |
| Tamaño de cada mensaje | La serialización completa del cuadro, sin tope (ver el formato en la página) |

Es una **amplificación**: una llamada del cliente produce N mensajes salientes, con N igual
al número de jugadores conectados, y sin límite de frecuencia.

**HECHO adicional.** `MaxUpdateDistance = 160` se declara en `module.init` y **no se usa en
ningún sitio**: un `grep` sobre todo `src/` solo encuentra la declaración. La intención de
limitar la difusión a quien esté cerca existió y no llegó a implementarse, ni en el cliente
ni en el servidor.

#### Teoría — TEORÍA

Un cliente modificado que llame a `Update` en bucle sobre su propio lienzo genera tráfico
saliente proporcional al aforo del servidor, con una carga útil que él mismo controla en
tamaño. No necesita permisos que no tenga: solo su propio cuadro.

Es el mismo patrón que [BUG-CANDIDATE-025](#bug-candidate-025) —una regla declarada en el
cliente que el servidor no reevalúa— pero aquí lo que se pierde no es una regla de juego,
es el presupuesto de red del servidor.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | El bloque del límite está dentro de `if IsClient then` |
| 2 | `DateTimeUpdate` solo se asigna en esa rama |
| 3 | El bucle de difusión no consulta ningún tiempo |
| 4 | `MaxUpdateDistance` se declara y no aparece en ninguna otra línea del repositorio |
| 5 | El parámetro `force` permite al propio cliente saltarse su límite, así que ni siquiera es firme de ese lado |
| 6 | `SeguridadFormato` valida la forma de la serialización, no su tamaño |

#### Incógnitas

- Cuánto pesa una serialización real. Determina si esto es una molestia o una saturación.
- Si Roblox impone su propio límite al ritmo de `FireClient` por servidor. Si lo hace, acota
  el daño sin arreglar la causa.
- Si el cliente aplica alguna otra limitación en el `.rbxm` de la interfaz, que no es
  inspeccionable (ver **U-001**). Aunque la aplicara, seguiría siendo del lado que no manda.

#### Escenario de ejemplo

Un jugador entra a un servidor lleno, se pone delante de su lienzo y llama a `Update` en
bucle con una serialización grande. Los demás jugadores reciben esa carga varias veces por
segundo cada uno, aunque estén al otro lado del mapa: el límite de distancia que iba a
evitarlo está declarado y no se usa.

**Comportamiento esperado:** el servidor descarta actualizaciones más frecuentes que
`timeUpdate`, y difunde solo a quien esté a menos de `MaxUpdateDistance`.
**Comportamiento posible:** acepta y difunde todas, a todos.

#### Plan de verificación — *Seguridad*, *Carga*

1. Entra a un servidor de pruebas con varias cuentas.
2. Desde la consola del cliente, llama a `Paint.Update` con tu propio lienzo diez veces por
   segundo.
3. Mide el tráfico entrante de las otras cuentas.
4. Comprueba si las que están lejos también lo reciben.
5. Repite con una serialización grande y compara.

**Pasa:** el servidor descarta las llamadas por encima del ritmo previsto.
**Falla:** todas se difunden a todos.

**Instrumentación sugerida:** llevar en el servidor el mismo `DateTimeUpdate` por jugador
que ya existe en el cliente. La estructura está escrita; lo que falta es aplicarla del lado
que decide.


## BUG-CANDIDATE-031

### Se puede hacer bailar al personaje de otro jugador

**Sistema:** Animación · **Clasificación:** Posible bug / Requiere pruebas multijugador
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja · **Confianza:** Alta

**Código relacionado:** `Core/…/ServerScripts/AnimationSystem/init.server.luau` —
`playAnimation`, `stopAnimation` y el manejador de `Animator.PlayAnimation`
**Documentación relacionada:** [Barrido → Animación y bailes](../systems/survey.md#animación-y-bailes)

#### Comportamiento observado — HECHO

El remote acepta un `Humanoid` del cliente y lo pasa tal cual:

```lua
remotes.Animator.PlayAnimation.OnServerEvent:Connect(function(player, name: string?, humanoid: Humanoid?)
	if name then
		stopAnimation(player, humanoid)
		playAnimation(player, name, humanoid)
	end
end)
```

Y `playAnimation` usa ese `humanoid` como destino, mientras comprueba la posesión contra
**quien llama**:

```lua
local function playAnimation(player: Player, name: string, humanoid: Humanoid?)
	if not humanoid then
		humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	end

	local animFolder = player:FindFirstChild("Animations")
	local animValue = animFolder and animFolder:FindFirstChild(name)

	if not animValue then
		warn(player.Name .. " intentó bailar " .. name .. " sin tenerlo.")
		return
	end
	...
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	...
	local track = animator:LoadAnimation(animation)
	track:Play()
```

Las dos mitades miran a personas distintas: **la posesión se comprueba contra el llamante, y
la animación se carga sobre el `Humanoid` que el llamante eligió.**

#### Por qué esto puede ser un problema — HECHO

El respaldo `if not humanoid then humanoid = player.Character…` demuestra la intención: el
parámetro existe para el caso normal, en el que se omite y se usa el propio personaje. Lo que
no hay es nada que rechace un `Humanoid` ajeno cuando sí se manda.

`stopAnimation(player, humanoid)` tiene la misma forma, así que también se puede cortar el
baile de otro.

Lo que hace de esto una inconsistencia y no un descuido general es que **este archivo es de
los que más cuidado tienen**: comprueba la posesión, registra el intento fallido con el
nombre del jugador, y lleva escrita una decisión de seguridad previa:

```lua
-- Eliminamos AddAnimation remote por seguridad.
```

Alguien ya endureció este sistema. El parámetro `humanoid` quedó fuera de esa revisión.

#### Teoría — TEORÍA

Un jugador que posea al menos un baile puede reproducirlo en el personaje de cualquier otro,
y detener los bailes ajenos. Es vandalismo, no robo: no concede nada ni accede a datos.

El alcance está acotado por dos cosas. Las pistas se marcan con
`track:SetAttribute("Dance", true)` y `stopAnimation` solo detiene las marcadas así, de modo
que no se pueden cortar animaciones que no sean bailes. Y hay que poseer el baile, así que no
se puede reproducir cualquier `AnimationId`: solo los que el atacante haya comprado.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | El manejador declara `humanoid: Humanoid?` y lo reenvía sin comprobar |
| 2 | La comprobación de posesión usa `player`, el destino usa `humanoid` |
| 3 | El respaldo `if not humanoid then …` enseña que el caso previsto es omitirlo |
| 4 | `stopAnimation` repite la forma |
| 5 | `remotes.Animate`, el otro remote de baile, **no** acepta destino: usa siempre el personaje del llamante. Los dos caminos existen y solo uno tiene el agujero |
| 6 | El comentario sobre `AddAnimation` prueba que este archivo ya pasó una revisión de seguridad |

#### Incógnitas

- Para qué se añadió el parámetro. Puede haber un uso legítimo —bailes en pareja, un NPC—
  que exigiría una comprobación en vez de quitarlo.
- Si `LoadAnimation` sobre el `Animator` de otro jugador replica a todos los clientes o solo
  al servidor. Determina si los demás lo ven.

#### Escenario de ejemplo

Un jugador compra un baile y, desde la consola, lo reproduce en el personaje de otro cada
pocos segundos. La víctima ve a su avatar bailando sin haberlo pedido y no encuentra en la
interfaz nada que lo detenga, porque no salió de su interfaz.

**Comportamiento esperado:** el baile se reproduce en el personaje de quien lo pide.
**Comportamiento posible:** se reproduce en el personaje que se indique.

#### Plan de verificación — *Multijugador*

1. Dos cuentas en el mismo servidor. La primera con al menos un baile comprado.
2. Desde su consola de cliente, dispara `Animator.PlayAnimation` con el nombre del baile y el
   `Humanoid` de la segunda cuenta.
3. Comprueba si la segunda cuenta baila, y si lo ven los dos clientes.
4. Prueba `stopAnimation` mientras la segunda cuenta baila algo suyo.
5. Repite con un baile que la primera cuenta **no** posea: debería rechazarse y dejar un
   `warn`.

**Pasa:** el paso 2 no tiene efecto sobre la segunda cuenta.
**Falla:** la segunda cuenta baila.

**Instrumentación sugerida:** en el `warn` que ya existe, añadir a quién se dirigía la
animación. Con eso se ve en producción si el parámetro se está usando para algo distinto del
propio personaje — que es también la información necesaria para decidir si se quita o se
comprueba.


## BUG-CANDIDATE-032

### Una condición de trabajo mal escrita permite la acción en silencio

**Sistema:** Trabajos · **Clasificación:** Observación / Requiere verificación en ejecución
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja · **Confianza:** Alta

**Código relacionado:** `Core/…/Shared/JobSystem/init.luau`, el bucle de condicionales
dentro de `Interaccion`; `Core/…/Shared/JobSystem/ConditionsUses.luau`
**Documentación relacionada:** [Trabajos → El escalón que sí conviene conocer](../systems/jobs.md#el-escalón-que-sí-conviene-conocer)

#### Comportamiento observado — HECHO

El modelo declara sus condiciones en un atributo, y cada una se busca por nombre compuesto y
se llama de inmediato:

```lua
local condicionalTag = string.split(getMetatable.model:GetAttribute('conditional') or 'NoConditional', ",")
for _, condicional in condicionalTag do
	local modifi = EliminarEspacios(condicional)
	if modifi then
		if not condicionales[string.format("%s_%s", modifi, Key)](getMetatable, Player) then
			return warn(modifi)
		end
	end
end
```

No se comprueba que la clave exista antes de invocarla. Lo que impide el error es todo el
contenido de `ConditionsUses`, que son doce líneas:

```lua
local module = {}
...
setmetatable(module, {__index = function() return function() return true end end})

function module:NoSignalClient_SetFinishLocation()
	return IsClient
end

return module
```

Cualquier clave desconocida devuelve una función que devuelve `true`.

#### Por qué esto puede ser un problema — HECHO

El respaldo es **necesario** para el caso normal. Cuando un modelo no declara nada, el valor
por defecto es `'NoConditional'`, y sin el metatable habría que escribir
`NoConditional_trabajar`, `NoConditional_renunciar`, `NoConditional_Preparar`… una entrada
por cada método de cada trabajo. La solución es razonable.

El coste es que **el valor por defecto ante lo desconocido es permitir**, y no hay forma de
distinguir «esta acción no tiene condiciones» de «la condición está mal escrita»:

| Situación | Qué ocurre |
|---|---|
| Modelo sin atributo `conditional` | `NoConditional_X` → permitido. Correcto |
| Condición escrita bien | Se evalúa la función real |
| Condición **con una errata** | → permitido, sin aviso |
| Condición correcta, método equivocado | → permitido, sin aviso |
| Condición nueva declarada en el modelo antes de implementarla | → permitido, sin aviso |

Las tres últimas filas son el problema, y ninguna deja rastro: no hay `warn`, no hay error,
no hay nada en el registro. La guarda simplemente no está.

#### Teoría — TEORÍA

Hoy el alcance es mínimo: existe una sola condición real,
`NoSignalClient_SetFinishLocation`, usada por `CajasTransport`, que la declara en dos sitios
con la cadena literal `"NoSignalClient"`. Si esa cadena se escribiera mal en uno de los dos,
`SetFinishLocation` pasaría a aceptarse desde el cliente sin restricción, y nada lo diría.

El riesgo real es de crecimiento: es el escalón donde este sistema pondrá sus reglas de
negocio —«solo si estás trabajando», «solo si llevas una caja»—, y cada una que se añada
hereda el mismo modo de fallo. Es la misma forma que
[BUG-CANDIDATE-001](#bug-candidate-001) para el chat de voz: fallar abierto cuando no se
sabe.

Merece registrarse precisamente porque el resto del sistema es de lo mejor del repositorio.
La lista blanca de métodos es explícita, corta y se aplica expulsando a quien la burla. El
escalón de al lado hace lo contrario ante lo desconocido.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `condicionales[...]` se indexa y se llama en la misma expresión, sin comprobar existencia |
| 2 | El `__index` del metatable devuelve una función que devuelve `true` para **cualquier** clave |
| 3 | Solo existe una condición real implementada |
| 4 | El nombre compuesto es `"<condición>_<método>"`, así que una errata en **cualquiera** de los dos lados cae en el respaldo |
| 5 | No hay ningún `warn` en la ruta del respaldo |
| 6 | La lista blanca de métodos, en el mismo bucle, sí falla cerrado y además expulsa |

#### Incógnitas

- Si el respaldo permisivo fue deliberado o es un efecto colateral de querer evitar el
  error. El comentario no existe, así que es una pregunta para quien lo escribió.
- Cuántas condiciones piensa añadir el equipo. Con una, esto es una nota; con quince, es
  una fuente de fallos silenciosos.

#### Escenario de ejemplo

Alguien añade una condición «solo el que está trabajando puede entregar la caja» y la
declara en el modelo como `"EstaTrabajando"`, pero implementa
`module:EstaTrabajando_Entregar` cuando el método se llama `GiveBox`. La condición nunca se
evalúa. La entrega funciona para todos, la prueba manual pasa —porque el caso normal
también funciona— y nadie se entera hasta que alguien la explota.

**Comportamiento esperado:** una condición declarada y no encontrada debería avisar, o
denegar.
**Comportamiento posible:** se permite en silencio.

#### Plan de verificación — *Ejecución*

1. En un place de pruebas, pon el atributo `conditional` de un modelo de trabajo a un valor
   inventado, por ejemplo `"NoExiste"`.
2. Usa ese trabajo con normalidad.
3. Comprueba si funciona y si aparece algo en el registro del servidor.
4. Repite con `"NoSignalClient"` bien escrito sobre `SetFinishLocation` y confirma que la
   condición real **sí** rechaza desde el servidor.
5. Repite con `"NoSignalCliente"` —una letra de más— y comprueba si vuelve a permitirse.

**Pasa:** el paso 2 se rechaza o al menos avisa; el paso 5 se comporta como el 4.
**Falla:** los pasos 2 y 5 funcionan sin dejar rastro.

**Instrumentación sugerida:** que el `__index` avise en vez de callar. Devolver la misma
función permisiva y además hacer `warn` con la clave buscada mantendría el comportamiento
actual y convertiría cada errata en algo visible en el registro. Es un **cambio de código**,
así que queda registrado aquí y no aplicado.


## BUG-CANDIDATE-033

### Las cuatro operaciones de `GlobalDataStore` comparten una señal y no coinciden en qué lleva

**Sistema:** Persistencia · **Clasificación:** Posible bug / Requiere pruebas de concurrencia
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Alta

**Código relacionado:** `Core/ServerStorage/GlobalDataStore/init.luau` — `GetData`,
`UpdateData`, `SetData`, `DeleteData`, y la tabla `AsyncInProcess`
**Documentación relacionada:** [Persistencia fuera de DataKit](../systems/global-storage.md#la-deduplicación-de-operaciones-en-vuelo)

#### Comportamiento observado — HECHO

Las cuatro operaciones evitan solaparse sobre la misma clave con un `BindableEvent`
guardado bajo `"<NameType>:<key>"`. La tabla declara cuatro espacios:

```lua
AsyncInProcess = {
	Set = {},
	Update = {},
	Get = {},
	Delete = {},
},
```

y **las cuatro operaciones usan `AsyncInProcess.Get`**. Las otras tres tablas no aparecen en
ninguna línea del archivo.

Compartir un espacio sería correcto —una escritura debería esperar a una lectura en curso de
la misma clave— si todas estuvieran de acuerdo en qué transporta la señal. No lo están:

| Operación | Al terminar dispara | En contención hace |
|---|---|---|
| `GetData` | `bin:Fire(n, s)` — con resultado | `local n,s = process:Wait()` → **usa el resultado ajeno** |
| `DeleteData` | `bin:Fire(n, s)` — con resultado | `return process:Wait()` → **devuelve el resultado ajeno** |
| `SetData` | `bin:Fire()` — **sin argumentos** | `process:Wait()` y luego **reintenta lo suyo** |
| `UpdateData` | `bin:Fire()` — **sin argumentos** | `process:Wait()` y luego **reintenta lo suyo** |

#### Por qué esto puede ser un problema — HECHO

Dos operaciones emiten carga útil y dos no; dos consumen la carga y dos reintentan. Cuando
las que se cruzan son del mismo tipo, todo cuadra. Cuando no, no:

| Colisión sobre la misma clave | Qué pasa |
|---|---|
| `DeleteData` espera a un `SetData` o `UpdateData` | `process:Wait()` devuelve **nada**. `DeleteData` devuelve `nil` y **el borrado nunca se intenta** |
| `GetData` espera a un `SetData` o `UpdateData` | `process:Wait()` devuelve nada → `n` es `nil` → **informa de fallo sin haber leído** |
| `SetData` o `UpdateData` esperan a un `GetData` o `DeleteData` | Reintentan lo suyo. Correcto |
| Dos del mismo tipo | Correcto |

La primera fila es la que importa: **un borrado que devuelve `nil` no ha borrado nada y no
dice que haya fallado.** `nil` no es `false`; quien lo interprete como «hecho» dejará el dato
en su sitio para siempre.

`SetData` y `UpdateData` demuestran la forma correcta —esperar y reintentar la operación
propia— así que la asimetría parece un olvido, no una decisión.

#### Teoría — TEORÍA

`DeleteData` es la única de las cuatro que no reintenta lo suyo tras esperar. Basta con que
una escritura sobre la misma clave esté en vuelo para que un borrado se pierda en silencio.

Hay un efecto encadenado con [BUG-CANDIDATE-029](#bug-candidate-029): `Paint:Remove` reintenta
el borrado indefinidamente mientras `DeleteData` no devuelva éxito. Si el borrado colisiona
con una escritura, devuelve `nil` —falso para el bucle— y `Paint` reintenta. Es decir, ese
bucle infinito puede dispararse **sin que el DataStore falle en absoluto**, solo por
contención. Es un camino de activación que aquella entrada no contemplaba.

Lo que acota todo esto: las claves son por entidad —un GUID por cuadro, un identificador por
canción— así que dos operaciones distintas sobre la **misma** clave a la vez no es lo
habitual. La probabilidad es baja; el mecanismo es seguro.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `AsyncInProcess` declara cuatro tablas y solo se usa `Get`, en las cuatro operaciones |
| 2 | `GetData` y `DeleteData` hacen `bin:Fire(n, s)`; `SetData` y `UpdateData` hacen `bin:Fire()` |
| 3 | `DeleteData` en contención hace `return process:Wait()` sin volver a intentar |
| 4 | `SetData` y `UpdateData` en contención sí reintentan, lo que enseña la forma prevista |
| 5 | `nil` y `false` no se distinguen en la mayoría de los sitios que consumen estos valores |
| 6 | `GlobalDataStore` no tiene reintento propio ni cortacircuitos, así que nada de esto se corrige después |

#### Incógnitas

- Cuántos consumidores tratan `nil` como fallo y cuántos como éxito. Solo se ha leído el de
  `Paint`, que lo trata como fallo — y por eso reintenta sin fin.
- Si hay alguna clave compartida de verdad entre varios jugadores a la vez. Las de karaoke
  van por canción; la lista de palabras clave de `BusquedaMusicas` podría no ir por entidad,
  y no se ha leído.
- Si `bin:Fire()` sin argumentos entrega `nil` o no entrega nada a `Wait()`. A efectos de
  `local n, s = process:Wait()` es lo mismo, pero conviene confirmarlo en Studio.

#### Escenario de ejemplo

Un jugador borra un cuadro justo mientras otro sistema guarda algo sobre esa misma clave.
`DeleteData` espera, devuelve `nil` y no borra. `Paint:Remove` lo lee como fallo y entra en
su bucle de reintentos, que no tiene techo. El cuadro ya desapareció de la lista del jugador
—eso ocurre antes— pero el dato sigue en el DataStore, y un hilo lo reintenta cada tres
segundos indefinidamente.

**Comportamiento esperado:** el borrado espera a la escritura en curso y **entonces se
ejecuta**, como hace `SetData`.
**Comportamiento posible:** devuelve `nil` sin ejecutarse.

#### Plan de verificación — *Concurrencia*, *Persistencia*

1. En un place de pruebas, lanza en paralelo sobre la misma clave un `SetData` con un dato
   grande —para que tarde— y, medio segundo después, un `DeleteData`.
2. Anota lo que devuelve el `DeleteData`.
3. Lee la clave después y comprueba si el dato sigue ahí.
4. Repite invirtiendo el orden (`DeleteData` primero, `SetData` después) y comprueba que ese
   sentido sí funciona.
5. Repite con `GetData` colisionando con un `SetData` y mira si informa de fallo pese a que
   el dato existe.

**Pasa:** el borrado se ejecuta tras esperar, y devuelve `true`.
**Falla:** devuelve `nil` y el dato sigue en el DataStore.

**Instrumentación sugerida:** hacer que las cuatro operaciones disparen la misma forma de
señal —`bin:Fire(n, s)` en todas— y que las cuatro reintenten lo suyo tras esperar, como ya
hacen `SetData` y `UpdateData`. Es un **cambio de código**, así que queda registrado aquí y
no aplicado; se menciona porque la simetría es la explicación más corta de qué falta.


## BUG-CANDIDATE-034

### Un `RemoteFunction` en la carpeta de televisores nunca quedaría atado

**Sistema:** Karaoke · **Clasificación:** Confirmado por análisis estático — **latente**
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja hoy · **Confianza:** **Muy alta**

**Código relacionado:** `Core/…/Shared/Karaoke/KaraokeTV/init.luau`, el bucle final de
`module:Works`
**Documentación relacionada:** [Karaoke → Despacho por nombre de remote](../systems/karaoke.md#despacho-por-nombre-de-remote)

#### Comportamiento observado — HECHO

El bucle que ata los remotes de `Televisiones/Instance` tiene dos ramas. La de
`RemoteEvent` conecta bien. La de `RemoteFunction` no ata nada:

```lua
if Remotes:IsA('RemoteEvent') then
	local EventActive = IsClient and Remotes.OnClientEvent or Remotes.OnServerEvent
	table.insert(self.actives, EventActive:Connect(function(...) FuncionesTV[Remotes.Name](self, ...) end))
elseif Remotes:IsA('RemoteFunction') then
	local EventActive = IsClient and Remotes.OnClientInvoke or Remotes.OnServerInvoke
	EventActive = function(...) return FuncionesTV[Remotes.Name](self, ...) end
end
```

La segunda rama declara una **variable local** con el valor actual de `OnServerInvoke` —que
es `nil`— y acto seguido **reasigna esa variable local**. La propiedad del `RemoteFunction`
no se toca en ningún momento.

Compárese con la rama de arriba, que sí funciona porque `Connect` es un **método** del
objeto que devuelve `OnServerEvent`: la referencia local basta. Con `OnServerInvoke`, que es
una **propiedad que hay que escribir**, la referencia local no sirve de nada.

La forma correcta sería `Remotes.OnServerInvoke = function(...) ... end`.

#### Por qué esto puede ser un problema — HECHO

Hoy **no rompe nada**, y conviene decirlo con claridad: los siete remotes de
`Televisiones/Instance` son `RemoteEvent`. Se ha comprobado uno por uno en sus
`.model.json`:

| Remote | `className` |
|---|---|
| `AddedSong`, `RemovedSong`, `SetOwner`, `Skip`, `init`, `listening`, `reproducir` | `RemoteEvent` |

La rama muerta no se ejecuta nunca. Es un fallo **latente**, del mismo tipo que
[BUG-CANDIDATE-015](#bug-candidate-015) —desactivado por un booleano— y
[BUG-CANDIDATE-016](#bug-candidate-016) —el manejador es un stub—.

Lo que lo hace digno de registrarse es **cómo va a fallar**. Este sistema está construido
para que añadir una función sea añadir un remote con el nombre del método: no hay lista que
tocar, el bucle lo recoge solo. Quien añada un `RemoteFunction` seguirá esa convención,
comprobará que el nombre coincide con su función en `FunctActionsTV`, y verá que el cliente
se queda colgado esperando —o recibe *«OnServerInvoke has not been set»`*— sin ningún indicio
de por qué. El bucle que debería atarlo está ahí, se ejecuta, y no hace nada.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `EventActive` se declara `local` y se reasigna; la propiedad del remote no se escribe |
| 2 | La rama de `RemoteEvent` funciona porque `Connect` es un método, no una propiedad |
| 3 | El valor inicial que se asigna a la local es `Remotes.OnServerInvoke`, que en ese momento es `nil` — leerlo no tiene ningún propósito |
| 4 | Los siete `.model.json` de esa carpeta declaran `RemoteEvent`, así que la rama está muerta hoy |
| 5 | La convención del sistema —añade un remote con el nombre del método y listo— es justo lo que llevará a alguien a caer en esto |

#### Incógnitas

- Si alguna vez hubo un `RemoteFunction` ahí y se quitó por «no funcionaba». No hay forma de
  saberlo desde el árbol actual.
- Si el cliente se queda colgado indefinidamente o recibe error. Roblox lanza
  *«OnServerInvoke has not been set»* al invocar, pero conviene confirmarlo.

#### Escenario de ejemplo

Alguien añade `GetQueue` como `RemoteFunction` para que el cliente consulte la cola de
canciones, y escribe `module:GetQueue(Player, Model)` en `FunctActionsTV`. Todo sigue la
convención del sistema. Al invocarlo desde el cliente no pasa nada. El nombre coincide, la
función existe, el bucle recorre la carpeta y encuentra el remote — y aun así no está atado.

**Comportamiento esperado:** el `RemoteFunction` queda atado a su método, igual que los
eventos.
**Comportamiento posible:** se queda sin `OnServerInvoke`, en silencio.

#### Plan de verificación — *Funcional*

1. En un place de pruebas, añade un `RemoteFunction` llamado `Prueba` bajo
   `Events/Karaoke/Televisiones/Instance`.
2. Añade `function module:Prueba() return true end` a `FunctActionsTV`.
3. Invócalo desde el cliente.
4. Observa si devuelve, se cuelga o lanza error.
5. Cambia la línea a `Remotes.OnServerInvoke = function(...) ... end` y repite, para confirmar
   que ese es el arreglo.

**Pasa:** el paso 3 devuelve `true`.
**Falla:** se cuelga o lanza *«OnServerInvoke has not been set»*.

**Instrumentación sugerida:** ninguna. El diagnóstico está cerrado y el arreglo es una línea.
Lo único que hay que decidir es si se corrige ahora o cuando alguien lo necesite — y el
argumento para hacerlo ahora es que la persona que lo necesite no tendrá ninguna pista.


## BUG-CANDIDATE-035

### El limitador de ritmo de la búsqueda de canciones está invertido

**Sistema:** Karaoke / Persistencia · **Clasificación:** Bug probable / Confirmado por análisis estático
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** **Muy alta**

**Código relacionado:** `Core/ServerStorage/BusquedaMusicas.luau`, línea 294, dentro de
`module:SearchPalabrasClaves`
**Documentación relacionada:** [Karaoke → La búsqueda de canciones](../systems/karaoke.md#la-búsqueda-de-canciones)

#### Comportamiento observado — HECHO

El bucle que drena la cola de palabras buscadas espera así entre lecturas de DataStore:

```lua
task.wait(self.DataPalabras.MaxLoads / self.DataPalabras.TimeExhauste)
```

`self` aquí es `GlobalDataStore`, y su tabla `DataPalabras` declara:

```lua
DataPalabras = {
	PalabrasBuscadas = 0,
	MaxLoads = 20,
	TimeExhauste = 60,
	...
},
```

De modo que la espera es **20 / 60 = 0,333 segundos**.

#### Por qué esto es un problema — HECHO

Los nombres dicen lo que significan: **`MaxLoads` cargas como máximo por cada
`TimeExhauste` segundos**. El intervalo correcto entre cargas es, por tanto,
`TimeExhauste / MaxLoads` = 60 / 20 = **3 segundos**.

Y así se escribe en el resto del repositorio. **Once usos, en cinco archivos, escriben la
división en ese orden. Solo esta línea la escribe al revés:**

| Archivo | Expresión |
|---|---|
| `Paint/ServerClient` (líneas 116, 255, 263, 552, 576) | `TimeExhauste / MaxLoads` |
| `Stores/Compras` (283, 304) | `TimeExhauste / MaxLoads` |
| `Karaoke/CrearCancion` (816) | `TimeExhauste / MaxLoads` |
| `BusquedaMusicas` (230, 352, 369) | `TimeExhauste / MaxLoads` |
| **`BusquedaMusicas` (294)** | **`MaxLoads / TimeExhauste`** |

Las otras tres líneas del **mismo archivo** usan el orden correcto. No es una convención
distinta de este módulo: es una línea suelta.

#### Teoría — TEORÍA

La cola de búsqueda drena a **3 lecturas por segundo** en vez de una cada 3 segundos: nueve
veces el presupuesto que la propia configuración declara, y nueve veces el de cualquier otra
cola del juego.

Cada iteración hace `self:GetData('OrderNombre', selectt)`, que es una lectura real de
DataStore. Y ese camino pasa por `GlobalDataStore`, que —como establece
[Persistencia fuera de DataKit](../systems/global-storage.md)— **no tiene reintentos ni
cortacircuitos**: si Roblox empieza a limitar por cuota, no hay nada que reduzca el ritmo.

Lo que hace esto peor que un simple exceso de cuota es que el bucle se realimenta:
`SearchPalabrasClaves` se vuelve a llamar a sí misma al terminar, así que mientras haya
palabras en cola el ritmo se mantiene.

**Lo que acota el daño:** la cola solo crece cuando alguien busca, y una palabra ya buscada
se cachea `UpdateSuccess = 120` segundos. Con poca gente buscando, la cola está vacía casi
siempre y esto no se nota. Se notaría con muchos jugadores buscando a la vez — es decir, en
el momento en que menos conviene.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | La expresión es `MaxLoads / TimeExhauste`, invertida respecto a las otras once del repositorio |
| 2 | Las otras tres apariciones **del mismo archivo** usan el orden correcto |
| 3 | Los nombres —«cargas máximas» y «tiempo de agotamiento»— solo tienen sentido en el orden `TimeExhauste / MaxLoads` |
| 4 | `self.DataPalabras` resuelve a la tabla de `GlobalDataStore`, con `MaxLoads = 20` y `TimeExhauste = 60`: la espera resultante es 0,333 s |
| 5 | Cada iteración hace una lectura real de DataStore (`GetData('OrderNombre', …)`) |
| 6 | `GlobalDataStore` no tiene reintentos ni cortacircuitos que amortigüen el exceso |

#### Incógnitas

- Cuánta gente busca canciones a la vez en un servidor real. Determina si esto es teórico o
  ya está pasando.
- Si `GetData` cachea lo suficiente como para que muchas de esas iteraciones no lleguen al
  DataStore. No se ha leído la rama de caché de `GetData` con esta pregunta en mente.
- Si el límite de cuota que se agota es el del juego entero o el de la clave. En el primer
  caso, esto afecta también a los perfiles de jugador y a las casas.

#### Escenario de ejemplo

Un servidor lleno, y diez jugadores buscando canciones en el karaoke. La cola de palabras se
llena, y el bucle empieza a leer del DataStore tres veces por segundo en vez de una cada
tres. Roblox empieza a limitar por cuota. Como no hay cortacircuitos, el bucle sigue
insistiendo al mismo ritmo, y otros sistemas que comparten la cuota del juego empiezan a
fallar sus guardados.

**Comportamiento esperado:** una lectura cada 3 segundos, que es lo que la configuración
declara.
**Comportamiento posible:** tres por segundo.

#### Plan de verificación — *Persistencia*, *Carga*

1. En un place de pruebas, añade un `print(os.clock())` justo antes del `task.wait` de la
   línea 294.
2. Busca varias canciones distintas seguidas, para llenar la cola.
3. Mide el intervalo real entre iteraciones.
4. Compáralo con el de `Paint`, que usa el orden correcto con los mismos valores.
5. Comprueba si aparecen avisos de límite de DataStore en el registro del servidor.

**Pasa:** el intervalo es de ~3 segundos.
**Falla:** es de ~0,33 segundos.

**Instrumentación sugerida:** ninguna hace falta para el diagnóstico, que está cerrado. Lo
que sí conviene, al corregirlo, es extraer esa división a una función con nombre —algo como
`intervaloEntreCargas(cola)`— para que no se pueda volver a escribir al revés en el sitio
número doce.


## BUG-CANDIDATE-036

### La lista de favoritos crece sin tope, con cadenas que elige el cliente

**Sistema:** Casas / Persistencia · **Clasificación:** Observación / Requiere pruebas de seguridad
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja · **Confianza:** Alta

**Código relacionado:** `Core/…/ServerScripts/FavoriteService.server.luau`, `onGiveFavorite`
**Documentación relacionada:** [Recompensas → Favoritos](../systems/rewards.md#favoritos)

#### Comportamiento observado — HECHO

El manejador comprueba el **tipo** de lo que llega y que no esté repetido, y nada más:

```lua
local function onGiveFavorite(player: Player, serverKey: string)
	if typeof(serverKey) ~= "string" then return false end

	local store = PlayerDataService.get(player)
	if not store or not store:isReady() then return false end

	local data = store:get()
	if table.find(data.favorites, serverKey) then return false end

	store:update(function(current)
		if not table.find(current.favorites, serverKey) then
			table.insert(current.favorites, serverKey)
		end
		return current
	end)
```

No comprueba que `serverKey` corresponda a una casa que exista, ni cuánto mide, ni cuántos
favoritos lleva ya el jugador.

#### Por qué esto puede ser un problema — HECHO

`favorites` es una clave del perfil `WorldsPlayer`, es decir **se persiste**. Un cliente
puede añadir cadenas arbitrarias, de longitud arbitraria, hasta llenar el perfil.

El contraste está en el propio repositorio, que sí acota en todas las estructuras
equivalentes:

| Estructura | Tope | Dónde |
|---|---|---|
| Cuadros por jugador | `maxSlots = 9` | `Paint/ServerClient` |
| Buzón de regalos | `MAX_ENTRIES = 50` | `GiftInbox` |
| Mensajes del perfil | `maxMessages = 2000` | `Profiles.WorldsPlayer` |
| Huecos de la rueda | `WHEEL_SLOTS = 8` | `InventoryManager` |
| Construcciones por invitado | `MaxBuildPlace = 5` | `Stores` |
| **Favoritos** | **ninguno** | `FavoriteService` |

#### Teoría — TEORÍA

Un cliente modificado puede llamar a `GiveFavorite` en bucle con cadenas distintas y hacer
crecer su propio perfil hasta acercarse al límite de 4 MB por clave de DataStore. A partir
de ahí, **los guardados de ese jugador empezarían a fallar** — y con ellos su moneda, su
inventario y sus casas, porque van todos en el mismo perfil.

Es el mismo patrón que [BUG-CANDIDATE-020](#bug-candidate-020), con dos diferencias que lo
hacen menos grave: aquí el daño es al perfil **de quien lo hace**, no al de un tercero, y no
hace falta ningún permiso.

Que el daño sea autoinfligido no lo vuelve inofensivo: un jugador que se rompa el perfil se
convierte en una incidencia de soporte, y no hay nada en el código que lo impida ni que lo
detecte.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | No hay comprobación de longitud de `serverKey` |
| 2 | No hay tope en el número de elementos de `favorites` |
| 3 | No se valida que la clave corresponda a una casa existente |
| 4 | `favorites` va en el perfil persistido, no en memoria de sesión |
| 5 | Cinco estructuras equivalentes del mismo repositorio **sí** llevan tope |
| 6 | `RemoveFavorite` existe, así que el jugador puede deshacerlo — pero solo si sabe qué claves metió |

#### Incógnitas

- Qué hace DataKit ante un perfil que supera el límite del DataStore. La misma incógnita que
  BUG-CANDIDATE-020, y responderla vale para las dos.
- Si la interfaz limita cuántos favoritos se pueden marcar. Aunque lo hiciera, el remote es
  invocable directamente.
- Cuál sería un tope razonable. Es una decisión de producto: en el repositorio conviven
  topes de 5, 8, 9, 50 y 2 000.

#### Escenario de ejemplo

Un jugador con un cliente modificado llama a `GiveFavorite` diez mil veces con cadenas
generadas. Su perfil crece hasta que DataKit no puede guardarlo. A partir de ese momento
pierde monedas, objetos y progreso en cada sesión, y desde fuera parece un fallo del juego.

**Comportamiento esperado:** el remote rechaza pasado un tope, o valida que la clave exista.
**Comportamiento posible:** acepta indefinidamente.

#### Plan de verificación — *Seguridad*, *Persistencia*

1. En un place de pruebas, invoca `GiveFavorite` en bucle con cadenas aleatorias.
2. Vuelca `PlayerDataService.getData(player).favorites` y comprueba que crecen.
3. Sigue hasta que el guardado falle, y anota en cuántos elementos ocurre.
4. Comprueba si el fallo se reporta o pasa en silencio.
5. Comprueba si el jugador puede recuperarse: ¿se le carga el perfil la siguiente vez?

**Pasa:** hay un tope, o las claves inexistentes se rechazan.
**Falla:** la lista crece sin límite hasta romper el guardado.

**Instrumentación sugerida:** registrar el tamaño de `favorites` al guardar, junto al del
resto de secciones. Es la misma instrumentación que pide BUG-CANDIDATE-020 y cubre las dos.

---

## BUG-CANDIDATE-037

### La caja de botín es estrictamente mejor que la tienda de bailes

**Sistema:** Economía · **Clasificación:** Observación / Pregunta de diseño
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** Alta

:::note Esto puede ser exactamente lo que se quiere

Una caja de botín **debe** ser atractiva. Lo que esta entrada señala no es que sea buena
compra, sino que hace la tienda de bailes **inútil por completo**, y que eso puede no
haberse calculado. Es una pregunta de diseño con los números delante, no una acusación.

:::

**Código relacionado:** `Core/…/ServerScripts/LootBoxService.server.luau`, `LOOTBOX_PRICES`
y `getUnownedLoot`; `Core/ReplicatedStorage/DancesInfo.luau`
**Documentación relacionada:** [Recompensas → La caja de botín](../systems/rewards.md#la-caja-de-botín)

#### Comportamiento observado — HECHO

Los números están todos en el código, y no hace falta interpretarlos:

| | Valor | Dónde |
|---|---|---|
| Precio de la caja | **500 Coins** (o 1 ChestKey) | `LOOTBOX_PRICES` |
| Precio de un baile en la tienda | **1 000 Coins**, los 14 | `DancesInfo` |
| Bailes a la venta | 14 de 14 (`IsForSale = true`) | `DancesInfo` |
| ¿La caja puede dar repetidos? | **No** | `getUnownedLoot` filtra lo ya poseído |
| ¿La caja puede fallar? | No, si queda algo por conseguir | Rechaza **antes** de cobrar si el catálogo está agotado |

#### Por qué esto puede ser un problema — HECHO

La caja cuesta **la mitad** que el artículo más barato que puede entregar, **nunca repite**,
y además puede dar juguetes. Como el catálogo se filtra contra lo que el jugador ya tiene,
cada compra es un artículo nuevo garantizado.

De ahí se sigue algo aritmético: **no existe ninguna situación en la que comprar un baile en
la tienda sea mejor que comprar una caja.** La tienda solo aporta elegir *cuál*, y esa
ventaja se agota sola: comprando cajas se acaban teniendo todos.

Conseguir los 14 bailes cuesta 14 000 Coins en la tienda. Por cajas cuesta **7 000 como
máximo**, y de camino salen todos los juguetes.

#### Teoría — TEORÍA

Con el sueldo por tiempo jugado a 150 Coins/hora, la diferencia es de unas 46 horas de juego
frente a unas 93. No es un matiz de balance: es un factor de dos sobre el precio de todo el
contenido cosmético.

Lo que hace pensar que no está calculado —y no que sea una promoción deliberada— es que
`DancesInfo` declara `rarityWeight` para cada baile, y la caja **no lo usa**: reparte
uniforme con `math.random(1, #lootList)`. Ese campo sí lo honra `ShopServerSystem` para
ponderar su rotación. Alguien previó que las cajas tuvieran rarezas; el código que las
reparte no llegó a leerlas.

Con pesos aplicados, un baile raro podría costar muchas cajas y el equilibrio sería otro.
Sin ellos, todo vale lo mismo y la caja es simplemente un descuento del 50 %.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `LOOTBOX_PRICES.Coins = 500`; los 14 bailes valen 1 000 |
| 2 | `getUnownedLoot` garantiza que nunca se repite |
| 3 | Se rechaza antes de cobrar si no queda nada por conseguir, así que tampoco se puede desperdiciar |
| 4 | `getRandomReward` es uniforme: no consulta `rarityWeight` |
| 5 | `rarityWeight` **sí** lo usa `ShopServerSystem` para su rotación, así que el campo funciona: es este consumidor el que lo ignora |
| 6 | Los 14 bailes tienen `rarityWeight = 100`, de modo que hoy aplicarlo no cambiaría nada — el problema aparece al añadir uno raro |

#### Incógnitas

- Si `ChestKey` se consigue de alguna forma que cambie el cálculo. No se ha encontrado dónde
  se concede.
- Cuántos juguetes hay en `Assets/Tools/Toys`, que es lo que determina el tamaño real del
  catálogo y por tanto cuántas cajas hacen falta.
- Si la tienda de bailes tiene alguna ventaja que no se vea en el código —una rotación
  limitada, por ejemplo— que justifique el doble de precio.

#### Escenario de ejemplo

Un jugador quiere el baile del robot. En la tienda son 1 000 Coins. Compra dos cajas por el
mismo dinero, se lleva dos cosmética distintos, y una de ellas puede ser justo ese baile. La
tienda nunca es la opción razonable.

**Comportamiento esperado:** la caja compensa el azar con precio, no lo contrario.
**Comportamiento posible:** la caja es mejor en todos los ejes a la vez.

#### Plan de verificación — *Funcional*

Esto no se verifica ejecutando, se verifica decidiendo. Aun así conviene medirlo:

1. Cuenta los juguetes de `Assets/Tools/Toys` para conocer el tamaño del catálogo.
2. Calcula el coste medio de completarlo por cajas y compáralo con comprarlo suelto.
3. Comprueba cómo se consigue `ChestKey` y qué vale en Coins equivalentes.
4. Decide si `rarityWeight` debe aplicarse en la caja; si sí, es un cambio de una línea en
   `getRandomReward`.
5. Decide precios con esos números delante.

**Pasa:** los números salen de una decisión consciente.
**Falla:** nadie los había puesto uno al lado del otro.

**Instrumentación sugerida:** registrar cuántas cajas se abren y cuántos bailes se compran
en la tienda. Si la segunda cifra es cerca de cero, la pregunta está respondida sin
necesidad de discutir el balance.


## BUG-CANDIDATE-038

### El filtro de errores del micrófono está invertido: solo se avisa del fallo esperado

**Sistema:** Chat de voz · **Clasificación:** Bug probable / Confirmado por análisis estático
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** **Muy alta**

**Código relacionado:** `Core/…/ServerScripts/MicManagerServer.server.luau`, dentro de
`requestMicUpdate`
**Documentación relacionada:** [Nametags y micrófono](../systems/nametags.md#lo-que-sí-falla)

#### Comportamiento observado — HECHO

```lua
local success, result = pcall(function()
	return (VoiceChatService :: any):GetChatGroupsAsync(allPlayers)
end)

if not success then
	if not RunService:IsStudio() and tostring(result):find("disabled") then
		warn("[MicServer] ❌ Error en GetChatGroupsAsync. Detalles:", result)
	end
elseif myVersion ~= requestVersion then
	...
```

La condición para avisar es que el mensaje de error **contenga** `"disabled"`.

#### Por qué esto es un problema — HECHO

`"disabled"` es el mensaje del caso **esperado y benigno**: el chat de voz no está activado
en ese universo o para ese jugador. Es justo el que no interesa registrar, y es el único que
se registra.

Cualquier otro fallo —throttling, un error transitorio de Roblox, un cambio en la API, un
`allPlayers` inesperado— **no imprime nada**. El `pcall` lo traga y el código sigue.

| Tipo de fallo | ¿Se avisa? | ¿Debería? |
|---|---|---|
| Chat de voz desactivado | **Sí** | No — es el caso normal cuando está apagado |
| Throttling o error transitorio | **No** | Sí |
| Cambio o retirada de la API | **No** | Sí |
| Cualquier otra excepción | **No** | Sí |

La forma que tendría sentido es la contraria: `not tostring(result):find("disabled")`.

#### Lo que agrava la consecuencia — HECHO

Un fallo no solo es silencioso: **no se reintenta**. Tras el `pcall` fallido el flujo cae al
final del bucle:

```lua
if myVersion == requestVersion then
	break
end
```

Como el fallo no incrementa `requestVersion`, la condición se cumple y el trabajador
termina. No hay reintento, no hay retroceso, no hay nada hasta que alguien entre o salga del
servidor y dispare otra pasada.

Y mientras tanto, `sendMicPermissions` no llega a llamarse, así que **`UpdateMicEvent` no se
dispara**. Los clientes conservan la matriz anterior; un jugador recién entrado no tiene
ninguna.

#### Teoría — TEORÍA

Si `GetChatGroupsAsync` empieza a fallar por un motivo que no sea «desactivado», el sistema
de permisos de micrófono se queda congelado **sin dejar rastro en el registro**. Los
jugadores nuevos no aparecen en la matriz de nadie, y los que ya estaban mantienen una foto
vieja: gente que debería poder hablar no puede, o al revés.

Desde fuera se ve como «el chat de voz va raro», que es de las incidencias más difíciles de
diagnosticar, y en el registro del servidor no hay absolutamente nada que apunte a la causa.

Es la misma familia que [BUG-CANDIDATE-001](#bug-candidate-001) —el control de chat de voz
del arranque, que falla abierto— y refuerza lo que ya señala
[Dependencias](../systems/../architecture/dependencies.md): en este repositorio los fallos
relacionados con `VoiceChatService` tienden a pasar desapercibidos.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | La condición es `tostring(result):find("disabled")` sin negar |
| 2 | `"disabled"` corresponde al caso esperado, no al excepcional |
| 3 | No hay ninguna rama `else` que registre los demás fallos |
| 4 | Un fallo no incrementa `requestVersion`, así que el bucle termina sin reintentar |
| 5 | Sin `sendMicPermissions`, `UpdateMicEvent` no se dispara y las matrices quedan como estaban |
| 6 | El resto del archivo está cuidadosamente escrito —coalescencia por versión, bandera de trabajador, comprobación de presencia— lo que hace pensar en una condición mal tecleada, no en un descuido general |

#### Incógnitas

- El texto exacto que devuelve Roblox cuando el chat de voz está desactivado. Si no contiene
  `"disabled"`, entonces **no se avisa de nada nunca**, y el problema es aún más simple de lo
  descrito.
- Con qué frecuencia falla `GetChatGroupsAsync` en producción por motivos distintos. Hoy no
  hay forma de saberlo, que es precisamente el problema.
- Si el cliente hace algo sensato cuando nunca recibe una matriz. `NametagMicClient` no se
  ha leído.

#### Escenario de ejemplo

Roblox tiene una incidencia y `GetChatGroupsAsync` empieza a lanzar durante veinte minutos.
Nadie ve nada en el registro. Los jugadores que entran en ese rato no pueden hablar con
nadie —o pueden hablar con todos, según lo que hiciera el cliente sin matriz— y cuando pasa
la incidencia el problema desaparece solo. En el postmortem no hay ni una línea.

**Comportamiento esperado:** se avisa de los fallos inesperados y se calla el esperado.
**Comportamiento posible:** exactamente lo contrario.

#### Plan de verificación — *Recuperación ante fallos*

1. En un place de pruebas, sustituye la llamada por una que lance un error que **no**
   contenga `"disabled"`. *(Instrumentación para la prueba.)*
2. Entra con dos cuentas y comprueba el registro del servidor: no debería aparecer nada.
3. Comprueba si los clientes reciben alguna matriz.
4. Repite lanzando un error que **sí** contenga `"disabled"` y confirma que ese sí se avisa.
5. Comprueba si una tercera entrada al servidor recupera el sistema, o si sigue congelado.

**Pasa:** los fallos inesperados aparecen en el registro.
**Falla:** solo aparece el de «disabled».

**Instrumentación sugerida:** negar la condición y añadir un contador de fallos consecutivos.
Es un **cambio de código**, así que queda registrado aquí y no aplicado; se menciona porque
la corrección es de un carácter y el resto del archivo ya está bien construido para
aprovecharla.


## BUG-CANDIDATE-039

### El servidor marca un tutorial como terminado porque el cliente se lo dice

**Sistema:** Tutoriales / Seguridad · **Clasificación:** Confirmado por análisis estático — **latente**
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja hoy, Alta el día que haya recompensas · **Confianza:** **Muy alta**

**Código relacionado:** `Core/ReplicatedStorage/Shared/GuideService/Server/init.luau`,
`CloseGuide`; `Core/ReplicatedStorage/Shared/GuideService/Server/Rewards.luau`
**Documentación relacionada:** [Tutoriales y guías](../systems/tutorials.md#lo-que-el-servidor-no-comprueba)

#### Comportamiento observado — HECHO

El único remote del sistema se conecta así, sin envoltorio:

```lua
if not IsClient then
	event:WaitForChild('EndAction').OnServerEvent:Connect(module.CloseGuide)
end
```

Y el manejador, en su rama de servidor:

```lua
local parametro = {...}
local Guide:BoolValue = module.GetGuide(parametro[1])
local Key:string = quitarEspacios(parametro[2])
local IsDone = parametro[3] or "pending"
if Guide and typeof(Key)=='string' then
	if module.GetState(parametro[1], Key) ~= UserInputState.End then
		Guide:SetAttribute(Key,IsDone)
		if IsDone == "ended" then
			Rewards[Key](parametro[1])
		end
	end
end
```

`OnServerEvent` antepone el `Player`, así que `parametro[2]` es la **clave** y
`parametro[3]` el **estado**, y los dos vienen del cliente tal cual.

#### Por qué esto es un problema — HECHO

El recorrido del tutorial —`Bind`, `AddPage`, `Start`, pasar páginas, llegar al final— vive
**entero en el cliente**. El servidor no ve ni una página. Lo único que le llega es el
aviso final, y ese aviso es el que decide qué se escribe.

| Lo que el servidor comprueba | Lo que no |
|---|---|
| Que la clave sea una cadena | Que el tutorial exista |
| Que el estado guardado no sea ya `"ended"` | Que el jugador lo haya empezado |
| | Que lo haya recorrido |
| | Que el estado enviado sea uno de los tres válidos |

Es decir: `EndAction:FireServer("LoQueSea", "ended")` escribe el atributo `LoQueSea = "ended"`
y llama a la entrada `"LoQueSea"` de `Rewards` con el jugador como argumento.

#### Lo que hoy lo mantiene inofensivo — HECHO

`Rewards.luau` completo:

```lua
local module = {}
setmetatable(module, {__index = function() return print end})
return module
```

Cualquier índice devuelve `print`. Ningún tutorial concede nada, así que la escritura
falsificada no vale moneda ni objetos. Es exactamente la misma forma que
[BUG-CANDIDATE-016](#bug-candidate-016): superficie abierta, manejador vacío.

El metatable también explica por qué una clave inventada **no lanza error**: si `Rewards`
fuera una tabla normal, `Rewards["LoQueSea"]` sería `nil` y llamarlo reventaría el hilo del
remote. El `__index` convierte lo que sería un fallo ruidoso en un `print` silencioso.

#### Lo que agrava la consecuencia — HECHO

Lo escrito **se persiste**. `PlayerSchema` declara `guide = { Name = "GuideService", Value = false }`
y `PlayerDataReplicator` lo trata como `kind = "record"`, cuyo serializador recorre
`GetAttributes()` y guarda todos. El atributo falsificado entra en el perfil del jugador y
vuelve en la siguiente sesión.

Y como la clave es libre, el número de atributos distintos que un cliente puede sembrar en
su propio perfil **no tiene tope declarado en este código**. El límite real lo pone el
tamaño máximo del perfil en DataKit; ver [Persistencia](../architecture/persistence.md).
Es la misma familia que
[BUG-CANDIDATE-036](#bug-candidate-036) —lista sin tope con cadenas elegidas por el
cliente— y que [BUG-CANDIDATE-020](#bug-candidate-020).

#### Teoría — TEORÍA

Hoy: un jugador puede saltarse el tutorial de bienvenida, o marcarse como «ya lo vi» sin
verlo, o llenar su propio perfil de atributos basura. Nada de eso le da ventaja.

El día que alguien rellene `Rewards` —que es evidentemente para lo que está— cada entrada
se convierte en un concesor de recompensa invocable desde el cliente, una vez por clave y
por jugador. Y la persona que rellene esa tabla estará mirando `Rewards.luau`, no
`CloseGuide`, así que no hay razón para que se dé cuenta.

Lo que hace esta entrada distinta de las demás de su familia es que la guarda que falta no
se puede añadir en el sitio obvio: el servidor **no dispone del dato** con el que
comprobarlo. Cerrarlo bien exige que el recorrido —o al menos su inicio y su avance— pase
por el servidor. Eso es rediseño, no un parche, y por eso queda registrado y no propuesto.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `OnServerEvent:Connect(module.CloseGuide)` conecta el manejador sin ninguna capa intermedia |
| 2 | `parametro[2]` (clave) y `parametro[3]` (estado) vienen del cliente |
| 3 | La única guarda de estado es `~= UserInputState.End`: limita a una escritura por clave, no a claves legítimas |
| 4 | No existe ninguna lista de tutoriales válidos en el lado servidor |
| 5 | `Bind`, `AddPage` y `Start` son código de cliente; el servidor no ve el recorrido |
| 6 | `Rewards` devuelve `print` para cualquier índice, lo que hoy anula el impacto y silencia el error |
| 7 | `PlayerSchema` y `PlayerDataReplicator` persisten el `BoolValue` y sus atributos |
| 8 | `IsDone` no se valida contra `{"pending","cancel","ended"}`: cualquier cadena se guarda |

#### Incógnitas

- Si `Rewards` está pensado para rellenarse o si el diseño es que los tutoriales nunca den
  nada. El `READ ME` del autor dice que el recorrido «se guardará en el dataStore», pero no
  menciona recompensas.
- El tope real de tamaño de un perfil de DataKit, y qué ocurre al superarlo: si el guardado
  falla entero o si se trunca. `Store.luau` está leído solo en parte.
- Si algún otro sistema lee estos atributos para decidir algo. La única lectura encontrada
  es la del propio `GuideService`.

#### Escenario de ejemplo

Meses después alguien añade al tutorial de bienvenida una recompensa de 500 monedas
rellenando `Rewards.Bienvenida = function(p) Collections.Give(p, "Coins", 500) end`. La
prueba pasa: se hace el tutorial, llegan las monedas. Lo que no se prueba es que
`EndAction:FireServer("Bienvenida", "ended")` desde la consola del cliente hace lo mismo sin
ver una sola página, y que si se añaden diez tutoriales con recompensa son diez cobros de
una línea cada uno.

**Comportamiento esperado:** el servidor concede porque le consta que el tutorial se recorrió.
**Comportamiento posible:** el servidor concede porque el cliente afirma que se recorrió.

#### Plan de verificación — *Seguridad*

1. En un place de pruebas, añade a `Rewards` una entrada con un `print` distinguible para la
   clave `Bienvenida`. *(Instrumentación para la prueba.)*
2. Entra y **no** hagas el tutorial. Desde un `LocalScript`, dispara
   `EndAction:FireServer("Bienvenida", "ended")`.
3. Comprueba el registro del servidor: ¿aparece la entrada instrumentada?
4. Comprueba el atributo `Bienvenida` sobre el `BoolValue` `GuideService` del jugador.
5. Dispara con una clave inventada (`"NoExiste"`) y confirma que se escribe el atributo y que
   no se lanza ningún error.
6. Repite el paso 2 y confirma que la segunda vez **no** vuelve a conceder.
7. Sal y vuelve a entrar: comprueba si el atributo falsificado ha sobrevivido al perfil.

**Pasa:** el paso 3 no registra nada y el paso 4 no encuentra el atributo.
**Falla:** cualquiera de los dos ocurre.

**Instrumentación sugerida:** ninguna que sea un parche. Lo mínimo honesto sería una lista
blanca de claves en el lado servidor y validar `IsDone` contra los tres valores; eso corta
las claves inventadas, pero **no** cierra el problema de fondo, que es que el servidor no
presencia el recorrido. Es un **cambio de código** y aquí no se aplica.


## BUG-CANDIDATE-040

### Las dos tablas globales del place de donaciones llaman a un método que no existe

**Sistema:** Donaciones / Persistencia · **Clasificación:** Confirmado por análisis estático
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** **Muy alta**

**Código relacionado:** `Core/ReplicatedStorage/Shared/ComprasTablero/init.luau`,
`SaveChangePlayer` (línea 248) y el bucle de `UpdateLeaderboards`;
`Core/ServerStorage/WorldSystem/PlayerDataReplicator.luau`
**Documentación relacionada:** [Place de donaciones](../systems/donations-place.md#las-tablas-globales)

#### Comportamiento observado — HECHO

```lua
function module:SaveChangePlayer(Player:Player, Data)
	if Client or not Player then return end
	if not self.UpdateUpdatePlayer[Player] or tick()-self.UpdateUpdatePlayer[Player] >= 40 then
		self.UpdateUpdatePlayer[Player] = Player:IsDescendantOf(game) and tick() or nil
		Data = typeof(Data)=='table' and Data or (self.DataBase.Bye(Player) or {SaveAllStats = function() return {} end}):SaveAllStats()
		self.GlobalData:SetData("TopSellers", tostring(Player.UserId), self:GetStat(Data,"Sell"))
		self.GlobalData:SetData("TopBuyers",  tostring(Player.UserId), self:GetStat(Data,"Buy"))
```

`self.DataBase` lo inyecta `Data/Main/init.server.luau`:

```lua
Tablero.DataBase = PlayerDataReplicator
```

#### Por qué esto es un problema — HECHO

`PlayerDataReplicator` no tiene `Bye`. Su superficie pública, entera:

| Miembro | |
|---|---|
| `PlayerDataReplicator.hydrate(player)` | |
| `PlayerDataReplicator.markReady(player)` | |
| `PlayerDataReplicator.setExitSequence(fn)` | |
| `PlayerDataReplicator.flush(player)` | |
| `PlayerDataReplicator.finalize(player)` | |
| `PlayerDataReplicator.DataComplete` | tabla |
| `PlayerDataReplicator.KaraokeFactory` | inyectada |

`Bye` no está. Y `SaveAllStats` tampoco existe en ningún archivo del repositorio, salvo en
el respaldo escrito en esa misma línea.

**El respaldo no protege de esto.** En `A.Bye(Player) or B`, Lua evalúa la llamada primero;
llamar a `nil` lanza `attempt to call a nil value` antes de que el `or` mire la alternativa.
El `or` cubre el caso «`Bye` devolvió `nil`», no el caso «`Bye` no existe».

`SaveChangePlayer` solo se llama desde un sitio, y siempre sin `Data`:

```lua
if self.DataBase.DataComplete[Player.UserId] then
	self:SaveChangePlayer(Player)
end
```

Con `Data` nulo, la rama del `or` es la única que se evalúa. Siempre.

#### Lo que agrava la consecuencia — HECHO

El bucle que lo llama vive en un `task.spawn` **sin `pcall`**:

```lua
self.SpawnUpdateLeaderboard = self.SpawnUpdateLeaderboard or task.spawn(function()
	while true do
		for _,Player:Player in Players:GetPlayers() do
			if self.DataBase.DataComplete[Player.UserId] then
				self:SaveChangePlayer(Player)
			end
		end
		local list = {}
		for index,value in {Buyings = "TopBuyers",Sellers ="TopSellers"} do
			list[index] = self:GetLeaderboard(value)
		end
		self.LeaderActual = list
		self.LeaderSignal:FireAllClients(self.LeaderActual)
		task.wait(60 * 3)
	end
end)
```

El error mata el hilo en la primera vuelta en que haya un jugador con datos cargados, que en
la práctica es la primera vuelta. Y **la guarda perezosa impide que se reintente**:
`self.SpawnUpdateLeaderboard` sigue siendo verdadera —apunta a un hilo muerto— así que
ningún `UpdateLeaderboards` posterior vuelve a arrancarlo.

Cadena completa:

| Efecto | |
|---|---|
| `GetLeaderboard` | no llega a ejecutarse nunca |
| `self.LeaderActual` | se queda en `nil` para siempre |
| `LeaderSignal:FireClient(Player, self.LeaderActual or {})` | manda `{}` a cada cliente que lo pide |
| El cliente | ve `NoPlayers.Visible = true` en las dos tablas |
| `RatingBuyers` / `RatingSellers` en `GlobalDataStore` | no las escribe **nadie más** en el repositorio |

#### Teoría — TEORÍA

Las dos tablas globales del place de donaciones —mayores compradores y mayores
vendedores— están vacías desde siempre y no se van a llenar solas. No es que muestren datos
viejos: es que no hay datos, porque el único escritor es el mismo bucle que muere antes de
escribir.

Desde fuera se ve como «las tablas no funcionan», sin ningún síntoma más. El teletipo de
compras, que es la parte visible del mismo módulo, **sí funciona**: va por otra ruta
(`AddCompras` ← `MessagingService`) que no toca `SaveChangePlayer`. Eso hace fácil creer que
`ComprasTablero` está bien.

Lo más probable es que `ComprasTablero` se escribiera contra una versión anterior de la capa
de datos, con un `Bye(Player)` que devolvía un objeto de sesión, y que la reescritura de
`PlayerDataReplicator` a `hydrate` / `flush` / `finalize` no arrastrara esta llamada. Es la
misma familia que [BUG-CANDIDATE-034](#bug-candidate-034) —código correcto en su día que
quedó colgando de un nombre que ya no está— pero aquí el efecto **no es latente: es hoy**.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `grep -rn "Bye" --include=*.luau src` devuelve exactamente una línea: la llamada |
| 2 | `grep -rn "SaveAllStats"` devuelve la misma línea y ninguna más |
| 3 | `PlayerDataReplicator` declara cinco funciones, ninguna llamada `Bye` |
| 4 | `Tablero.DataBase = PlayerDataReplicator` es la única asignación de `DataBase` en el módulo |
| 5 | `SaveChangePlayer` se llama desde un solo sitio y siempre sin el segundo argumento |
| 6 | El `or` no protege: la llamada se evalúa antes que la alternativa |
| 7 | El bucle no tiene `pcall` |
| 8 | La guarda `self.SpawnUpdateLeaderboard or task.spawn(...)` no distingue un hilo vivo de uno muerto |
| 9 | `SaveChangePlayer` es el único escritor de `TopBuyers` y `TopSellers` en todo el repositorio |

#### Incógnitas

- Si el place de donaciones está publicado y en uso. Si nunca se abrió al público, esto no ha
  afectado a nadie todavía.
- Si `GlobalDataStore` contiene datos de `RatingBuyers` / `RatingSellers` escritos por una
  versión anterior del código. Solo se puede saber leyendo el DataStore real.
- Si el error aparece en el registro del servidor. Un error en un `task.spawn` sí se imprime
  en Roblox, así que debería haber un rastro — pero solo uno, en el arranque, y luego
  silencio.

#### Escenario de ejemplo

Se abre el place de donaciones. El teletipo de compras funciona: las tarjetas aparecen,
cambian de color según el importe y se van. Las dos tablas de la pared dicen «no hay
jugadores» y siguen diciéndolo al día siguiente, y al mes. En el registro del servidor hay
un `attempt to call a nil value` de hace semanas, perdido entre el ruido del arranque.

**Comportamiento esperado:** las tablas se refrescan cada 3 minutos con los totales del perfil.
**Comportamiento posible:** el bucle muere en la primera vuelta y las tablas nunca se llenan.

#### Plan de verificación — *Ciclo de vida*

1. Abre el place de donaciones (`PlaceId` 82871403803520) en Studio con **Enable Studio
   Access to API Services** activado.
2. Entra con una cuenta y espera a que `DataComplete[UserId]` deje de ser `'no complete'`.
3. Mira la salida: debería aparecer un error de `attempt to call a nil value` procedente de
   `ComprasTablero`, línea 248.
4. Comprueba `Tablero.SpawnUpdateLeaderboard`: debería seguir siendo un `thread` cuyo estado
   es `dead`.
5. Espera más de 3 minutos y comprueba que `Tablero.LeaderActual` sigue siendo `nil`.
6. Comprueba las dos GUI etiquetadas `TopBuyersGUI` y `TopSellersGUI`: `NoPlayers` visible.
7. Comprueba en `GlobalDataStore` si `RatingBuyers` tiene alguna entrada.
8. Confirma por contraste que el **teletipo sí funciona**: haz una compra y comprueba que la
   tarjeta aparece. Eso separa este fallo del resto del módulo.

**Pasa:** las tablas se pueblan y `LeaderActual` deja de ser `nil`.
**Falla:** el error del paso 3 aparece y el paso 5 sigue en `nil`.

**Instrumentación sugerida:** ninguna hace falta para observarlo — basta mirar la salida. La
corrección exige decidir de dónde salen los totales ahora que `Bye` no existe, y eso es un
**cambio de código** que aquí no se aplica. Cuando se haga, conviene envolver el bucle en un
`pcall` y comprobar `coroutine.status` en la guarda perezosa, porque las dos cosas que lo
hicieron invisible siguen ahí.


## BUG-CANDIDATE-041

### El bucle compartido cree que atrapa los errores de sus tareas, y no atrapa ninguno

**Sistema:** Utilidades compartidas · **Clasificación:** Confirmado por análisis estático
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** **Muy alta**

**Código relacionado:** `Core/ReplicatedStorage/Shared/Running.luau`, la función `Running`
**Documentación relacionada:** [Utilidades compartidas](../systems/shared-utilities.md#runningluau-el-bucle-compartido)

#### Comportamiento observado — HECHO

```lua
for _,v in module.Functions do
	if not v.aviable or (now - v.startTime) < v.cold then continue end
	v.startTime = now
	local nice, ErrorMessage = pcall(task.spawn, v.fun, delta)
	if not nice then
		warn(ErrorMessage)
		module:ElimineFunct(v)
	end
end
```

La intención se lee sola: si una tarea del bucle falla, se avisa y se saca de la lista para
que no siga fallando cada fotograma.

#### Por qué esto es un problema — HECHO

`pcall(task.spawn, v.fun, delta)` protege la llamada a **`task.spawn`**, no la ejecución de
`v.fun`. `task.spawn` arranca un hilo nuevo; un error dentro de ese hilo se reporta a la
salida de Roblox pero **no vuelve** al llamante, así que el `pcall` no lo ve.

| Qué falla | ¿Lo ve el `pcall`? |
|---|---|
| `v.fun` lanza un error | **No** — está en otro hilo |
| `v.fun` lanza tras un `task.wait` | **No** |
| `task.spawn` recibe algo que no es función ni hilo | Sí — pero `AddFunct` ya lo filtra con `typeof(fun) ~= 'function'` |

El único caso que el `pcall` puede atrapar es justo el que `AddFunct` ya hizo imposible. La
rama `if not nice` es **código muerto**: nunca se entra en ella.

#### Lo que agrava la consecuencia — HECHO

`Running` es compartido. Lo usan `ComprasTablero`, `AreaSystem` y tres consumidores más, y
es **una sola lista y una sola conexión** por contexto: `Heartbeat` en el servidor,
`RenderStepped` en el cliente.

Una tarea que empiece a lanzar sigue en la lista para siempre, se relanza cada fotograma —o
cada `cold` segundos— y llena la salida. Nada la retira. En el cliente eso es 60 errores por
segundo si su `cold` es cero.

**OBSERVACIÓN, dentro de lo mismo.** `ElimineFunct` hace `table.remove` sobre
`module.Functions`, y algunas tareas se retiran a sí mismas desde dentro de su propia
ejecución —`ComprasTablero:CreateRunning` lo hace—. Como `task.spawn` ejecuta el cuerpo de
forma síncrona hasta el primer `yield`, esa retirada ocurre **durante** el `for` que recorre
la lista, y el elemento siguiente se salta ese fotograma. Con `aviable` y el enfriamiento por
medio el efecto es un fotograma de retraso, no una pérdida. Se anota, no se eleva.

#### Teoría — TEORÍA

Cuando una tarea del bucle empiece a fallar —un `Gui` destruido que se sigue indexando, un
jugador que se fue— el juego no se cae, pero la salida se inunda y no hay nada que corte la
sangría. Y como la rama de retirada existe y está escrita, quien lea el archivo buscando por
qué no se retiró va a concluir que la tarea no falló, cuando lo que pasa es que el bucle
nunca se enteró.

La forma correcta sería `task.spawn(function() ... pcall(v.fun, delta) ... end)` o
`local ok, err = pcall(v.fun, delta)` sin `task.spawn`, según se quiera que la tarea pueda
ceder o no. Las dos son **cambios de código**, y aquí no se aplican.

Es la misma familia que [BUG-CANDIDATE-038](#bug-candidate-038): una guarda escrita al
revés que convierte un fallo ruidoso en uno invisible — con el matiz de que aquí el fallo
**sí** se imprime (lo imprime Roblox, no el `warn` del archivo) y lo que se pierde es la
retirada.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `pcall(task.spawn, v.fun, delta)` pasa `v.fun` como argumento de `task.spawn`, no lo llama dentro del `pcall` |
| 2 | `task.spawn` no repropaga los errores del hilo que crea |
| 3 | `AddFunct` ya rechaza lo que no sea función, así que el único fallo posible de `task.spawn` no puede darse |
| 4 | La rama `if not nice then warn(...); ElimineFunct(v) end` es por tanto inalcanzable |
| 5 | `module.Functions` y `active` son de módulo: una sola lista y una sola conexión por contexto |
| 6 | Cinco consumidores comparten esa lista |

#### Incógnitas

- Si alguna de las cinco tareas registradas hoy puede lanzar. Ninguna de las leídas lo hace
  de forma obvia, pero `AreaSystem` toca instancias del mundo, que es donde suelen aparecer
  estos errores.
- Si el error de un hilo de `task.spawn` aparece en el registro del servidor o solo en la
  salida de Studio. Debería aparecer en los dos, pero conviene comprobarlo.

#### Escenario de ejemplo

Alguien registra en `Running` una tarea que anima una GUI. La GUI se destruye al cambiar de
pantalla. A partir de ese momento la tarea lanza cada fotograma. La consola del cliente se
llena, el rendimiento cae por el coste de crear un hilo 60 veces por segundo para que muera
al instante, y en el código hay una rama que dice, negro sobre blanco, que eso no debería
poder pasar.

**Comportamiento esperado:** una tarea que falla se retira de la lista.
**Comportamiento posible:** nunca se retira, porque el `pcall` no ve el fallo.

#### Plan de verificación — *Recuperación ante fallos*

1. En un place de pruebas, registra una tarea que lance siempre:
   `Running:AddFunct(function() error("prueba") end)`. *(Instrumentación para la prueba.)*
2. Mira la salida: el error debería aparecer repetidamente.
3. Comprueba `#Running.Functions`: debería seguir siendo el mismo número.
4. Comprueba que el `warn(ErrorMessage)` del archivo **no** aparece en la salida — ese es el
   indicador de que el `pcall` no se disparó.
5. Repite con `cold = 1` y confirma que el error aparece una vez por segundo, no una vez.

**Pasa:** la tarea se retira tras el primer fallo y el error deja de aparecer.
**Falla:** el error se repite y la lista no encoge.

**Instrumentación sugerida:** mover el `pcall` dentro del hilo. Es un **cambio de código**
y aquí queda registrado, no aplicado.


## BUG-CANDIDATE-042

### El comando de administración se comprueba en el chat y no en el remote

**Sistema:** Comandos / Seguridad · **Clasificación:** Posible bug / Requiere pruebas de seguridad
**Estado:** Sin verificar · **Gravedad si se confirma:** Por determinar · **Confianza:** Alta en la forma, **baja en el impacto**

**Código relacionado:** `Core/ReplicatedStorage/Shared/Commands.luau`, `SearchCommand` y
`Works`; `Events/Other/Commands`
**Documentación relacionada:** [Utilidades compartidas](../systems/shared-utilities.md#commandsluau-los-comandos-de-chat)

#### Comportamiento observado — HECHO

Hay dos caminos hasta el mismo remote, y solo uno comprueba el rol.

**Camino del chat**, con comprobación:

```lua
if string.sub(message,1,1) == '/' then
	...
	if not Commands.IsWihAdmin or self.AdminPanel:IsAdmin(player, Commands.SuperAdmin) then
		return Commands.typee
	end
```

`self.AdminPanel` es el módulo de Karaoke, inyectado por `Data/Main`, y su `IsAdmin` delega
en `RoleService:IsRole(Player, "KaraokeSuperAdmin" | "KaraokeAdmins")`. Es una comprobación
de rol de verdad.

**Camino del remote**, sin ella:

```lua
self.Event.OnServerEvent:Connect(function(Player:Player, number, option)
	if typeof(number)=="number" then
		self:Fire(Player, number, option)
	end
end)
```

Comprueba que `number` sea un número y lo devuelve al mismo jugador con `FireClient`.
`IsAdmin` no aparece.

#### Por qué esto es un problema — HECHO

Los `typee` marcados `IsWihAdmin` son 3 (`/revisarcanciones`), 5 (`/reportes`) y 10
(`/musicasbaneadas`, además `SuperAdmin`). Un cliente que dispare el remote con `3` recibe
de vuelta un `3` sin que nadie mire su rol.

Lo mismo con `option`, que atraviesa sin ninguna comprobación de tipo ni de contenido.

Es exactamente la forma de
[BUG-CANDIDATE-028](#bug-candidate-028) —dos caminos hasta la misma acción, uno con guarda y
otro sin ella— y de [BUG-CANDIDATE-008](#bug-candidate-008), donde lo que difiere es la ruta
de persistencia. La regla que estos casos comparten: **una comprobación que vive en un solo
camino no es una comprobación.**

#### Lo que acota el impacto — HECHO

El remote solo **le responde al que llamó**. No difunde, no escribe nada, no toca datos. Lo
único que consigue quien lo dispara es que su propio cliente reciba un número.

Lo que ese número abre está en un `LocalScript` dentro de un `.rbxm` —la interfaz de la
tablet—, y **el código de un `.rbxm` va comprimido**, así que no se ha podido leer. Por eso
esta entrada se clasifica como *requiere pruebas* y no como *confirmado*: la forma es clara,
la consecuencia no.

Si el panel que se abre solo pinta, esto es cosmético. Si desde ese panel salen llamadas que
el servidor atiende, el impacto es el de **esas** llamadas — y ahí conviene leer
[BUG-CANDIDATE-028](#bug-candidate-028), porque los tres cargadores de moderación de karaoke
comprueban que **haya** un administrador conectado, no que quien llama lo sea. Las dos
entradas se componen mal: una abre el panel a cualquiera, la otra no distingue quién lo usa.

#### Teoría — TEORÍA

Un jugador sin rol puede abrir en su propia pantalla el panel de revisar canciones, el de
reportes o el de canciones baneadas. Lo que pueda hacer desde ahí depende de si el servidor
valida cada acción por separado. La suma de esta entrada con la 028 sugiere que la validación
de karaoke se apoya más de lo que debería en que el panel esté cerrado.

Merece la pena mirarlo de una pieza: la 028 y la 042 son la misma pregunta vista desde los
dos extremos del mismo remote.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `SearchCommand` comprueba `IsAdmin` y devuelve `nil` si falla |
| 2 | El manejador de `OnServerEvent` no lo comprueba |
| 3 | La única validación del manejador es `typeof(number)=="number"` |
| 4 | `option` no se valida en absoluto |
| 5 | Tres `typee` están marcados `IsWihAdmin`, uno además `SuperAdmin` |
| 6 | `IsAdmin` delega en `RoleService:IsRole`, así que el camino del chat sí es sólido |
| 7 | El receptor de `OnClientEvent` no está en ningún `.luau` del repositorio |

#### Incógnitas

- **La principal:** qué hace el cliente con el número. Sin leer la interfaz de la tablet no
  se puede decir si esto es cosmético o no.
- Si el panel abierto por esta vía puede disparar acciones que el servidor acepte. Ahí es
  donde se cruza con la 028.
- Para qué existe el camino del remote. Si el chat ya traduce el comando, un segundo camino
  que no comprueba nada parece pensado para que la interfaz se abra sola desde un botón — y
  entonces la comprobación tendría que estar también aquí.

#### Escenario de ejemplo

Un jugador sin rol abre la consola del cliente y dispara el remote con `10`. Su tablet abre
el panel de canciones baneadas. Si el panel se limita a pedir la lista y el servidor la
manda sin comprobar rol, ya ha visto algo que no le tocaba. Si además puede desbanear desde
ahí, el problema es mucho mayor — y esa pregunta no se puede responder desde este
repositorio.

**Comportamiento esperado:** los dos caminos hasta el remote comprueban el rol.
**Comportamiento posible:** solo el del chat.

#### Plan de verificación — *Seguridad*

1. Entra con una cuenta **sin** rol de administrador de karaoke.
2. Comprueba primero el camino legítimo: escribe `/revisarcanciones` en el chat. No debería
   pasar nada.
3. Desde un `LocalScript`, dispara `Events.Other.Commands:FireServer(3)`.
4. Observa si la tablet abre el panel de revisar canciones.
5. Si lo abre, intenta **usarlo**: aprobar o rechazar una canción, y comprueba en el servidor
   si la acción se aplicó.
6. Repite con `10` (`SuperAdmin`) y con una cuenta que tenga `KaraokeAdmins` pero no
   `KaraokeSuperAdmin`.
7. Prueba `FireServer(3, {})`, `FireServer(3, "x")` y `FireServer(999)` para ver qué hace el
   cliente con un `option` y un `typee` inesperados.

**Pasa:** el paso 4 no abre nada.
**Falla:** el panel se abre. Si además el paso 5 aplica el cambio, la gravedad sube a Alta y
la entrada deja de depender de la 028: es independiente.

**Instrumentación sugerida:** ninguna. Todo esto se observa desde el cliente y desde el
registro del servidor. La corrección —llamar a `IsAdmin` también en el manejador del
remote— es un **cambio de código** y aquí no se aplica.


## BUG-CANDIDATE-043

### El cliente decide si ha ganado el peluche, y aquí sí hay premio

**Sistema:** Máquinas / Seguridad · **Clasificación:** Bug probable / Requiere pruebas de seguridad
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** **Muy alta** en la forma

**Código relacionado:** `Core/…/ServerScripts/machines/ToyMachine.luau`, el `bind` de
`Machines.ToyPress` y `_handle`
**Documentación relacionada:** [Máquinas de arcade](../systems/machines.md#la-máquina-de-peluches)

#### Comportamiento observado — HECHO

```lua
self._machine:bind(remotes.Machines.ToyPress, function(player, inGreenZone, hookPos)
	self.model.Hook:PivotTo(CFrame.new(hookPos))
	if inGreenZone then
		self._trove:Add(task.spawn(function()
			self:_handleGreenZone(player)
		end))
	else
		self:stop()
	end
end)
```

Al final de `_handleGreenZone`:

```lua
if toy then
	self:_handle(self._machine:getPlayer(), toy.Name)
end
```

Y `_handle`:

```lua
function ToyMachine:_handle(player: Player, toyName: string)
	InventoryManager.addItem(player, toyName)
	SoundManager:Play(nil, 13697778590, { Volume = 1 }, self.model)
end
```

`inGreenZone` es el segundo argumento del `FireServer`. Lo pone el cliente.

#### Por qué esto es distinto de la 016 — HECHO

[BUG-CANDIDATE-016](#bug-candidate-016) registra que las máquinas aceptan del cliente el
valor de la recompensa, y se clasificó **latente** porque los manejadores de premio son
`warn`. Eso sigue siendo cierto para `Stacker`, `PopTheLock`, `Basketball` y `Pong`.

`ToyMachine` **no es un stub**. Es la única de las seis que entrega de verdad, y lo que
entrega es un objeto de inventario:

| Máquina | `_handle` | ¿Entrega? |
|---|---|---|
| `Stacker` | `warn` | No |
| `PopTheLock` | `warn` | No |
| `Basketball` | `warn` | No |
| `Pong` | `warn` | No |
| **`ToyMachine`** | **`InventoryManager.addItem`** | **Sí** |

Por eso va como entrada aparte: la 016 es una superficie a la espera de un manejador; ésta
tiene el manejador puesto.

#### Lo que sí sujeta — HECHO

No es una escritura arbitraria, y conviene decirlo con precisión:

| Control | Cómo |
|---|---|
| Solo puede llamar quien está en **esta** máquina | `Machine:bind` comprueba `model == self.model and table.find(self._players, player)` |
| El objeto **no lo elige el cliente** | `_getRandomToy()` sortea entre cinco `ReplicatedStorage.Assets.Tools.Toy1..5` en el servidor |
| Entrar cuesta | `Machines.Request` descuenta `model:GetAttribute("Price")` antes de dejar jugar |
| Una partida a la vez | `_maxPlayers = 1`, y `machineByPlayer` bloquea entrar en dos |

Es decir: lo que se salta no es el precio ni el catálogo, sino **la habilidad**. Quien
explote esto gana un peluche en cada partida en vez de en las que acierte, pagando el precio
cada vez.

#### Lo que agrava — HECHO

`hookPos` va directo a `CFrame.new(hookPos)` sin comprobar tipo ni rango, y el resultado se
aplica a una pieza del mundo que ven todos:

```lua
self.model.Hook:PivotTo(CFrame.new(hookPos))
```

Si no es un `Vector3`, `CFrame.new` lanza dentro del manejador y la llamada muere ahí —falla
cerrado—. Si lo es, el gancho de la máquina se teletransporta a donde diga el cliente, para
todo el servidor. Es vandalismo acotado a esa pieza, de la familia de la
[BUG-CANDIDATE-023](#bug-candidate-023).

#### Teoría — TEORÍA

Un jugador con un script puede convertir la máquina de peluches en una compra a precio fijo:
paga, dispara `ToyPress` con `inGreenZone = true`, recibe peluche. Cuánto importa depende
enteramente de para qué sirven los cinco peluches —si son cosméticos, es poco; si valen algo
en el juego o se pueden vender, es una fuente de ingreso—, y eso no se puede responder desde
este repositorio.

Lo que sí se puede afirmar es que **el servidor no tiene con qué comprobarlo**: la posición
del gancho, el momento de soltar y la zona verde viven todos en el cliente. Cerrar esto
como está exigiría que el servidor simulara la grúa, que es lo que ya hace `Pong` con su
pelota. Eso es rediseño, no un parche.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `inGreenZone` es un argumento del `FireServer`, no un cálculo del servidor |
| 2 | La rama `if inGreenZone` es lo único que separa ganar de perder |
| 3 | `_handle` llama a `InventoryManager.addItem`, no a un `warn` |
| 4 | Las otras cuatro máquinas sí tienen `_handle` vacío |
| 5 | `hookPos` se pasa a `CFrame.new` sin validar |
| 6 | `Machine:bind` sí comprueba que quien llama esté en esta máquina — lo que acota, no elimina |
| 7 | El peluche lo sortea el servidor entre cinco fijos |

#### Incógnitas

- **La principal:** qué valen `Toy1` a `Toy5`. Si son herramientas cosméticas sin valor de
  cambio, la gravedad baja a Baja.
- Si `InventoryManager.addItem` tiene tope de inventario o deduplicación. `InventoryManager`
  está leído, pero no se ha comprobado el caso de cinco mil peluches.
- Cuánto cuesta jugar: `Price` es un atributo del modelo y no está en este repositorio.
- Si el cliente puede saltarse `Machines.Request` y llegar a `ToyPress` sin pagar. No debería
  —`Machine:bind` exige estar en `_players`, y solo `join` mete ahí— pero es lo primero que
  hay que probar.

#### Escenario de ejemplo

Alguien mira el remote, ve dos argumentos, prueba `ToyPress:FireServer(model, true, Vector3.new())`
y le cae un peluche. Repite en bucle mientras le queden monedas. La máquina sigue cobrando,
así que en el registro económico no se ve nada raro: solo alguien con mucha suerte en la
grúa.

**Comportamiento esperado:** el servidor sabe si el gancho estaba en la zona verde.
**Comportamiento posible:** se lo pregunta al cliente.

#### Plan de verificación — *Seguridad*

1. Averigua primero qué son `Toy1` a `Toy5` y si tienen valor de cambio. Eso fija la gravedad.
2. Entra a una máquina de peluches por la vía normal y comprueba que se te cobra el `Price`.
3. Desde la consola del cliente: `Machines.ToyPress:FireServer(model, true, Vector3.new(0,0,0))`.
4. Comprueba si el peluche llega al inventario.
5. Repite sin haber pulsado `Machines.Request` antes, para confirmar que `Machine:bind` te
   rechaza si no estás en `_players`.
6. Repite apuntando a **otra** máquina de peluches distinta de la tuya, para confirmar que
   `model == self.model` te rechaza.
7. Dispara con `hookPos` fuera del mapa —`Vector3.new(0, 10000, 0)`— y mira si el gancho se
   va y si otros jugadores lo ven.
8. Dispara con `hookPos` que no sea un `Vector3` y confirma que falla cerrado.
9. Repite el paso 3 cincuenta veces y comprueba qué hace `InventoryManager` con cincuenta
   peluches.

**Pasa:** los pasos 3 y 4 no entregan nada.
**Falla:** llega el peluche. Si además el paso 5 funciona, la gravedad sube a Alta: se ganaría
sin pagar.

**Instrumentación sugerida:** ninguna. Cerrar esto de verdad exige simular la grúa en el
servidor —el patrón que ya usa `Pong`—, y eso es un **cambio de código** que aquí no se
aplica.


## BUG-CANDIDATE-044

### La ruleta tiene una casilla que no paga y un sesgo del doble hacia la casilla 1

**Sistema:** Máquinas / Economía · **Clasificación:** Confirmado por análisis estático
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja · **Confianza:** **Muy alta** en la aritmética, media en el encaje con el modelo

**Código relacionado:** `Core/…/ServerScripts/machines/Roulette.luau`, la función `modulo` y
`applyPrizeReward`; `Core/ReplicatedStorage/Shared/machines/roulettePrizes.luau`
**Documentación relacionada:** [Máquinas de arcade → La ruleta](../systems/machines.md#la-ruleta)

Son dos defectos pequeños en la misma función de sorteo. Van juntos porque quien vaya a
tocar uno va a tocar el otro.

#### Primero: la casilla 11 no entrega nada — HECHO

`roulettePrizes` devuelve 16 premios, y el número 11 es:

```lua
local FURNITURE = {
	type = "Mueble",
	reward = { _Special = "Furniture" }, -- TODO
}
```

`applyPrizeReward` sabe hacer exactamente dos cosas: sumar los campos **numéricos** de
`reward` a `leaderstats`, y el caso `_Special == "Dance"`. Para `Furniture`:

```lua
if reward._Special == "Furniture" then
	-- TODO: cuando exista el sistema de construcción, aquí se entrega
end
```

Un bloque vacío. Ni premio ni aviso: el jugador ve la rueda pararse en «Mueble» y no recibe
nada, sin ningún mensaje que lo explique.

**Lo que hace notar que fue un descuido y no una decisión:** el caso `Dance` **sí** tiene
respaldo. Si el jugador ya tiene todos los bailes, se le dan `+2 Spins` con un aviso —«Ya
tienes todos los bailes. Te damos +2 Spins»— precisamente *para que el premio no salga
vacío*. Quien escribió esa red de seguridad estaba pensando en este problema. `Furniture` se
quedó sin ella.

#### Segundo: el sorteo está sesgado — HECHO

```lua
local function modulo(a, b)
	if a < b then
		return a
	else
		return a % b + 1
	end
end

function Roulette:_getRandomTurns()
	return self._parts * math.random(2, 4) + math.random(0, self._parts)
end
```

Con `P = self._parts`, los giros son `P·k + r` con `k ∈ {2,3,4}` y **`r ∈ {0, …, P}`**: eso
son `P+1` valores equiprobables, no `P`.

Como `P·k + r ≥ 2P ≥ P`, siempre se toma la rama `a % b + 1`. Y `(P·k + r) % P = r % P`:

| `r` | `r % P` | Casilla |
|---|---|---|
| `0` | 0 | **1** |
| `1` … `P-1` | 1 … P-1 | 2 … P |
| **`P`** | **0** | **1** |

`r = 0` y `r = P` caen los dos en la casilla 1. Con 16 casillas:

| Casilla | Probabilidad |
|---|---|
| **1** | **2/17 ≈ 11,8 %** |
| 2 … 16 | 1/17 ≈ 5,9 % cada una |

**Exactamente el doble.** Y la casilla 1 es `EXTRA_SPIN`, `reward = { Spins = 2 }` — el
premio que te devuelve a la ruleta con más tiradas.

La causa es que `math.random(0, self._parts)` es inclusivo por los dos extremos y devuelve
`P+1` valores distintos para repartir entre `P` casillas.

**OBSERVACIÓN.** La rama `if a < b then return a end` es **inalcanzable** —los giros nunca
bajan de `2P`—, y si lo fuera devolvería `0` para `a = 0`, que no es una casilla válida. Es
otra señal de que la función se escribió con un modelo mental distinto del que acabó
teniendo.

#### Teoría — TEORÍA

Una de cada dieciséis tiradas no paga nada y el jugador no sabe por qué. Y la casilla de
tiradas gratis sale al doble de lo previsto, lo que abarata la ruleta frente a lo que diga la
hoja de balance — si la hay.

Ninguno de los dos hunde el juego. Los dos son de los que nadie reporta porque desde dentro
son indistinguibles de la mala suerte, y de los que no se detectan sin contar tiradas. Por
eso quedan aquí: son exactamente el tipo de cosa para la que sirve un plan de verificación.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `roulettePrizes` devuelve una lista de 16, con `FURNITURE` en la posición 11 |
| 2 | La rama `_Special == "Furniture"` está vacía salvo un comentario `TODO` |
| 3 | `applyPrizeReward` solo suma campos numéricos y atiende `_Special == "Dance"` |
| 4 | El caso `Dance` sí tiene respaldo con aviso, lo que prueba que el premio vacío se consideró un problema |
| 5 | `math.random(0, P)` devuelve `P+1` valores equiprobables |
| 6 | `(P·k + r) % P` vale 0 tanto para `r = 0` como para `r = P` |
| 7 | Por tanto la casilla 1 sale con probabilidad `2/(P+1)` y las demás con `1/(P+1)` |
| 8 | La casilla 1 es `EXTRA_SPIN`, `{ Spins = 2 }` |
| 9 | La rama `a < b` de `modulo` es inalcanzable con los giros que genera `_getRandomTurns` |

#### Incógnitas

- **`self._parts` es el número de hijos de `model.Parts`, y ese modelo no está en este
  repositorio.** Toda la aritmética de arriba supone `_parts = 16` para que encaje con
  `roulettePrizes`. Si no lo fuera, el problema es otro y peor: con `_parts > 16` habría
  resultados sin premio (`prize missing`, ya avisado con `warn`), y con `_parts < 16` las
  casillas altas serían inalcanzables. **Esto hay que medirlo en Studio antes que nada.**
- Si existe una tabla de probabilidades previstas contra la que comparar. Sin ella, «sesgo»
  significa «distinto de uniforme», que es lo que se afirma aquí.
- Si el sistema de construcción al que apunta el `TODO` está previsto a corto plazo. Si lo
  está, la casilla 11 se arregla sola y solo queda decidir qué hacer mientras.

#### Escenario de ejemplo

Un jugador gasta veinte spins. Dos veces cae en «Mueble» y no le llega nada; escribe en el
Discord que la ruleta está rota y nadie sabe decirle si es un fallo o si el mueble llega más
tarde. Al mismo tiempo nota que le tocan tiradas gratis «bastante seguido», lo que le gusta y
no reporta.

**Comportamiento esperado:** las 16 casillas pagan, y todas con la misma probabilidad.
**Comportamiento posible:** una no paga, y otra sale el doble.

#### Plan de verificación — *Corrección funcional*

1. **Lo primero:** en Studio, cuenta los hijos de `model.Parts` y compáralo con las 16
   entradas de `roulettePrizes`. Si no coinciden, para y registra eso: es un problema mayor
   que los dos de esta entrada.
2. Instrumenta `Roulette:_handle` para registrar `result` en cada tirada. *(Instrumentación
   para la prueba.)*
3. Ejecuta 2 000 tiradas y cuenta cuántas veces sale cada casilla.
4. Comprueba si la casilla 1 sale en torno al 11,8 % y las demás en torno al 5,9 %.
5. Fuerza una tirada en la casilla 11 y comprueba `leaderstats` y el inventario antes y
   después.
6. Comprueba que no aparece ninguna notificación al jugador en ese caso.
7. Comprueba por contraste que la casilla 7 (`DANCE`) sí entrega, y que su respaldo de
   `+2 Spins` funciona con una cuenta que ya tenga todos los bailes.

**Pasa:** el reparto es uniforme y las 16 casillas entregan algo.
**Falla:** la casilla 1 sale al doble, o la 11 no entrega nada.

**Instrumentación sugerida:** solo el registro del paso 2. La corrección —cambiar
`math.random(0, self._parts)` por `math.random(0, self._parts - 1)`, o el `+1` del `modulo`,
y decidir qué hacer con `Furniture`— es un **cambio de código** y aquí no se aplica. Ojo al
tocarlo: los dos extremos interactúan, y cambiar uno sin el otro desplaza el sesgo en vez de
quitarlo.


## BUG-CANDIDATE-045

### El caché de assets pierde el filtro de tipo al reintentar, y puede dejar colgado a quien espera

**Sistema:** Karaoke / Assets · **Clasificación:** Confirmado por análisis estático (el filtro) + Posible bug / Requiere pruebas de concurrencia (el bloqueo)
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja el primero, Media el segundo · **Confianza:** **Muy alta** en el filtro, **baja** en el bloqueo

**Código relacionado:** `Core/ReplicatedStorage/Client/InsertService.luau`, `module.LoadAsset`
**Documentación relacionada:** [Cliente — interfaz y utilidades](../systems/client-ui.md#insertserviceluau-corre-en-el-servidor)

Dos cosas en la misma función. Van juntas porque quien la toque va a leer las dos.

### Primero: el reintento pierde el `IsA` — HECHO

```lua
function module.LoadAsset(AssetId, IsA)
	if typeof(AssetId) ~= "number" then return end
	local AssetLoaded = Cache[AssetId]
	if AssetLoaded then
		if AssetLoaded.Item then
			AssetLoaded.DateBusqueda = DateTime.now().UnixTimestampMillis
			return GetIsAModel(AssetLoaded.Item, IsA)
		elseif GetElapsedTime(AssetLoaded.DateBusqueda) >= HoldToUpdate then
			Cache[AssetId] = nil
			return module.LoadAsset(AssetId)   -- ← IsA no se pasa
		end
	end
```

La llamada recursiva **no reenvía `IsA`**. Y `GetIsAModel` es lo único que aplica el filtro:

```lua
local function GetIsAModel(item : Instance, IsA)
	return item and (not IsA or item:IsA(IsA)) and item:Clone()
end
```

Con `IsA` nulo, `not IsA` es verdadero y **se clona lo que sea**.

#### Por qué importa — HECHO

Los dos consumidores pasan `"Decal"` y **los dos dependen de ello**:

| Consumidor | Qué hace con el resultado | Si no es un `Decal` |
|---|---|---|
| `Karaoke/CrearCancion/Attributes.luau` | `NewMiniatura.Parent = Song.Recursos` | Parentea una instancia arbitraria dentro de la canción |
| `ServerStorage/BusquedaMusicas.luau` | `Data.Miniatura = decal.Texture` | Indexar `.Texture` en algo que no lo tiene lanza, dentro de un `task.spawn` sin `pcall`: el hilo muere y `Data.IsLoaded` no se pone nunca |

Y el `AssetId` **lo elige el jugador**: es la miniatura que pone al crear una canción. Ver
[Karaoke](../systems/karaoke.md).

#### Cuándo se alcanza — HECHO, y acota mucho

Solo por esta secuencia:

1. El asset **falla** al cargar (`pcall` de `LoadAsset` devuelve falso).
2. Se cachea el fallo (`Item = nil`) durante `HoldToUpdate` = 10 s.
3. Pasados esos 10 s, alguien vuelve a pedirlo → rama del reintento, sin `IsA`.
4. Esta vez **sí** carga, y lo que carga **no** es un `Decal`.

Si el asset sigue fallando, `Item` es `nil` y `GetIsAModel` devuelve falso igual que antes:
no hay diferencia. El daño necesita un fallo transitorio seguido de un acierto de tipo
equivocado. Por eso la gravedad es Baja: el mecanismo es seguro, la ocasión es rara y un
jugador no controla cuándo falla `InsertService`.

Lo que sí es seguro es que **el filtro de tipo no es fiable**, y ese filtro es la única
comprobación de forma que hay sobre un asset elegido por un jugador. Los scripts ya los quita
`elimineScrips` —eso está bien hecho—; el tipo, no siempre.

### Segundo: `bin:Destroy()` justo después de `bin:Fire()` — TEORÍA

La deduplicación de peticiones en vuelo:

```lua
local Process = InProcess[AssetId]
if Process then
	Process:Wait()
	local Cached = Cache[AssetId]
	return GetIsAModel(Cached and Cached.Item, IsA)
end
local bin = Instance.new("BindableEvent")
InProcess[AssetId] = bin.Event
...
bin:Fire()
bin:Destroy()
InProcess[AssetId] = nil
```

**La intención es correcta y buena:** si dos llamadas piden el mismo asset a la vez, la
segunda espera a la primera en vez de cargarlo dos veces.

**La duda es el `Destroy` inmediato.** `Destroy()` sobre un `BindableEvent` desconecta sus
conexiones, y `Event:Wait()` es una conexión por debajo. Con el comportamiento de señales
*Deferred* —el de por defecto en Roblox— `Fire()` **no reanuda al que espera en el acto**:
lo encola. Queda por saber si una reanudación ya encolada sobrevive al `Destroy` de la línea
siguiente.

- Si sobrevive, esto funciona y no hay nada que arreglar.
- Si no, **el que esperaba se queda colgado para siempre**, y con él la corrutina que lo
  llamó. En `BusquedaMusicas` eso es una entrada de caché que nunca se marca `IsLoaded`.

**No se afirma que falle.** Se afirma que depende de un detalle del motor que no está en este
repositorio y que el código no documenta. Es la clase de cosa que funciona en las pruebas
—donde las peticiones no se solapan— y aparece cuando varios jugadores abren el buscador de
canciones a la vez.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | La llamada recursiva es `module.LoadAsset(AssetId)`, sin el segundo argumento |
| 2 | `GetIsAModel` con `IsA` nulo clona cualquier tipo |
| 3 | Los dos consumidores pasan `"Decal"` y usan el resultado como tal |
| 4 | `BusquedaMusicas` lee `.Texture`, que no existe fuera de unos pocos tipos |
| 5 | `Attributes` parentea el resultado dentro de la canción |
| 6 | El `AssetId` proviene de la miniatura que elige el jugador |
| 7 | `bin:Destroy()` está en la línea siguiente a `bin:Fire()` |
| 8 | `Process:Wait()` no tiene tiempo límite ni salida alternativa |

#### Incógnitas

- **La principal:** si una reanudación encolada por `Fire` sobrevive al `Destroy`. Sin
  responder esto, el segundo hallazgo no pasa de teoría.
- Si el place usa `SignalBehavior` *Deferred* o *Immediate*. No está en este repositorio.
  Con *Immediate* el `Fire` reanuda antes del `Destroy` y el problema no existe.
- Con qué frecuencia falla `InsertService:LoadAsset` en producción. De eso depende que la
  primera parte se alcance alguna vez.
- Qué tipos de asset devuelve Roblox para un id de imagen inválido o moderado. Si siempre es
  un fallo limpio, la primera parte es inalcanzable en la práctica.

#### Escenario de ejemplo

Diez jugadores abren el buscador de canciones a la vez y varias piden la misma miniatura.
Nueve entran por `Process:Wait()`. Si el `Destroy` corta la reanudación, esas nueve
corrutinas no vuelven: sus canciones se quedan sin miniatura y sin `IsLoaded`, y en el
registro no aparece nada porque nadie ha lanzado un error — simplemente no ha vuelto.

**Comportamiento esperado:** el que espera se reanuda y recibe el asset cacheado, filtrado por tipo.
**Comportamiento posible:** puede no reanudarse; y si el asset falló y se reintenta, el filtro
de tipo ya no se aplica.

#### Plan de verificación — *Concurrencia y recuperación ante fallos*

Primero el filtro, que es el determinista:

1. Elige un id de asset que **no** sea un `Decal` —un `Model`, por ejemplo—.
2. Instrumenta `LoadAsset` para forzar que el primer `pcall` falle. *(Instrumentación para la
   prueba.)*
3. Llama a `LoadAsset(id, "Decal")`. Debe devolver `nil`.
4. Espera más de 10 segundos y vuelve a llamar con `"Decal"`, ya sin forzar el fallo.
5. Comprueba qué devuelve: si devuelve el `Model`, el filtro se perdió.

Luego el bloqueo:

6. Sin instrumentar nada, lanza veinte corrutinas que pidan el **mismo** id a la vez.
7. Cuenta cuántas vuelven. Deberían volver las veinte.
8. Registra el tiempo de cada una: las que esperaron deberían volver justo después de la
   primera.
9. Repite con un id que falle al cargar.
10. Repite con `SignalBehavior` puesto a *Immediate* y compara.

**Pasa:** el paso 5 devuelve `nil` y el paso 7 cuenta veinte.
**Falla:** el paso 5 devuelve el `Model`, o el paso 7 cuenta menos de veinte.

**Instrumentación sugerida:** solo la del paso 2. Las correcciones —pasar `IsA` en la
recursión, y mover el `Destroy` a después de que los que esperan hayan vuelto— son **cambios
de código** y aquí no se aplican.


## BUG-CANDIDATE-046

### Cualquiera puede entrar en cualquier canal de walkie, y el objeto en el que escribe el servidor lo elige el cliente

**Sistema:** Walkie-talkie / Seguridad · **Clasificación:** Bug probable / Requiere pruebas de seguridad
**Estado:** Sin verificar · **Gravedad si se confirma:** Media · **Confianza:** **Muy alta** en la forma

**Código relacionado:** `Core/…/ServerScripts/WalkieServer.server.luau`, el manejador de
`Events/Tools/Walkie` y `joinChannel`;
`Core/ReplicatedStorage/Assets/Tools/Toys/Walkie/LocalScript.client.luau`
**Documentación relacionada:** [Servidor — piezas sueltas](../systems/server-misc.md#el-walkie-talkie)

#### Comportamiento observado — HECHO

El manejador completo:

```lua
RemoteEvent.OnServerEvent:Connect(function(player, channel, tool)
	if #channel == 3 then
		leaveChannel(player)
		joinChannel(player, channel, tool)
	end
end)
```

Y lo que `joinChannel` hace con el segundo argumento:

```lua
local receiver = tool:FindFirstChild("Receiver") or Instance.new("AudioListener")
receiver.Name = "Receiver"
receiver.Parent = tool
```

El cliente legítimo manda `(CurrentChannel, Tool)`, donde `Tool` es la herramienta en la que
vive su `LocalScript`.

#### Por qué esto es un problema — HECHO

Son tres cosas distintas, y conviene separarlas:

**1. No se comprueba que el jugador tenga un walkie.** No hay ni un `FindFirstChild`, ni una
consulta al inventario, ni una comprobación de que `tool` esté equipado por quien llama.
Cualquiera puede entrar en cualquier canal sin poseer el objeto.

**2. `tool` es una `Instance` elegida por el cliente y el servidor le escribe dentro.** Un
`AudioListener` llamado `Receiver` se parentea en lo que sea que llegue. No se comprueba que
sea un `Tool`, ni que sea del jugador, ni que sea suyo siquiera.

**3. El primero que entra en un canal se queda de transmisor.**

```lua
if not channels[channel] then
	channels[channel] = {transmitter = player, receivers = {}}
end
```

Y el transmisor es **el único que habla**: `connectTransmitterToReceivers` cablea su emisor
a los oídos de los demás, nunca al revés. Quien ocupe un canal primero es el único con voz en
él mientras siga dentro.

**4. `#channel == 3` no comprueba que sea una cadena.** `#` sobre una tabla de tres elementos
también vale 3, y esa tabla sirve como clave de `channels`. Sobre un número, `#` lanza y la
llamada muere ahí —falla cerrado—. Es más una rareza que un problema, pero significa que
`channel` no es necesariamente texto.

#### Lo que acota el impacto — HECHO

| Control | Qué cubre |
|---|---|
| El espacio de canales es 1 000 | Tres cifras; se pueden recorrer todos, y son pocos |
| Solo se transmite voz | No hay datos, ni economía, ni escrituras persistentes |
| `PlayerRemoving` limpia | `leaveChannel` + `cleanWires` destruyen los `Wire` |
| Roblox exige chat de voz habilitado | Sin él, la cadena de audio no lleva nada |

Y la contraparte: **el walkie es un objeto que se concede** —está en `DefaultTools`—, así que
esto no da acceso a algo que de otro modo estuviera cerrado; da acceso sin tener el objeto y,
sobre todo, permite **ocupar** un canal.

#### Teoría — TEORÍA

Dos cosas se pueden hacer con esto:

**Ocupar canales.** Un script que recorra los 1 000 canales y entre en cada uno se queda de
transmisor en todos los que estén vacíos. Los jugadores que entren después son receptores
suyos: oyen a quien ocupó el canal y no pueden hablar entre ellos. Con mil canales y un
bucle, el walkie deja de funcionar para todo el servidor.

**Escuchar sin walkie.** Entrar en un canal ajeno como receptor y oír a su transmisor sin
tener el objeto. Es escucha de voz sin consentimiento, que es la parte que más importa de esta
entrada: [BUG-CANDIDATE-001](#bug-candidate-001) y
[BUG-CANDIDATE-038](#bug-candidate-038) ya señalan que en este repositorio lo relacionado con
voz tiende a fallar hacia el lado abierto, y ésta es la tercera.

El tercer efecto —parentear un `AudioListener` en una instancia arbitraria— es el menos claro:
depende de qué acepte Roblox como padre de un `AudioListener` y de qué haga uno colgado de
algo raro. Va como incógnita, no como afirmación.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | El manejador solo comprueba `#channel == 3` |
| 2 | No hay ninguna comprobación de posesión del walkie |
| 3 | `tool` llega del cliente y se usa como padre de un `AudioListener` |
| 4 | El cliente legítimo manda su `Tool`, así que el servidor está diseñado para fiarse |
| 5 | `channels[channel].transmitter` se fija al primero y solo cambia si se va |
| 6 | `connectTransmitterToReceivers` cablea en un solo sentido |
| 7 | El espacio de canales son tres cifras: 1 000 posibilidades |
| 8 | `#` sobre una tabla también puede valer 3 |

#### Incógnitas

- Si Roblox permite parentear un `AudioListener` en cualquier clase de instancia, y qué pasa
  entonces. Puede que la asignación falle sola.
- Si el chat de voz está habilitado en esta experiencia. Sin él nada de esto suena —ver
  [BUG-CANDIDATE-001](#bug-candidate-001)—, pero la ocupación de canales seguiría dejando el
  walkie inservible para los demás.
- Qué oye realmente un receptor cableado a un emisor lejano: si la atenuación por distancia
  del `AudioEmitter` del walkie lo hace inaudible a distancia, la escucha ajena se acota sola.
- Si el walkie es de uso extendido en el juego. Si casi nadie lo usa, la gravedad baja.

#### Escenario de ejemplo

Alguien escribe cuatro líneas que disparan el remote con `"000"`, `"001"`, … `"999"`. Se
queda de transmisor en todos los canales vacíos. Un grupo de amigos entra al canal `"123"`
para hablar y descubre que se oyen a un desconocido y no entre ellos. Nadie sabe por qué:
el walkie «no va».

**Comportamiento esperado:** entrar en un canal exige tener el walkie, y el servidor identifica
la herramienta por su cuenta.
**Comportamiento posible:** basta con disparar el remote con tres caracteres.

#### Plan de verificación — *Seguridad*

1. Comprueba primero si el chat de voz está habilitado. Si no, todo lo de sonido queda en
   teoría y solo aplica la ocupación de canales.
2. Con una cuenta **sin** walkie en el inventario, dispara
   `Events.Tools.Walkie:FireServer("123", workspace)`.
3. Comprueba en el servidor si `channels["123"]` existe y si su `transmitter` eres tú.
4. Mira si aparece un `AudioListener` llamado `Receiver` dentro de `workspace`.
5. Repite con `nil` y con `123` (número) como segundo y primer argumento, y comprueba que
   falla cerrado.
6. Con dos cuentas más, entra en el mismo canal y comprueba quién oye a quién.
7. Recorre 50 canales desde una cuenta y comprueba que quedas de transmisor en todos.
8. Sal de la partida y comprueba que `leaveChannel` deshace los 50.
9. Prueba con una tabla de tres elementos como `channel` y mira si `channels` acepta esa clave.

**Pasa:** el paso 2 no crea canal y el paso 4 no encuentra nada.
**Falla:** cualquiera de los dos ocurre.

**Instrumentación sugerida:** ninguna. La corrección —resolver la herramienta desde el
personaje en el servidor, como ya hace `connectTransmitterToReceivers`, y comprobar posesión—
es un **cambio de código** y aquí no se aplica. Nótese que la mitad de la solución ya está
escrita en el mismo archivo: esa función **no** se fía del cliente para encontrar la
herramienta del receptor.


## BUG-CANDIDATE-047

### 46 muebles y todas las herramientas colocables comparten una descripción de relleno

**Sistema:** Tiendas / Construcción · **Clasificación:** Confirmado por análisis estático
**Estado:** Sin verificar · **Gravedad si se confirma:** Baja (presentación) · **Confianza:** **Muy alta**

**Código relacionado:** `src/ServerStorage/Templates/SettingsTemplate.luau`;
`Core/…/ServerScripts/ToolModelGenerator/Settings.luau` y `init.server.luau` línea 153;
`BuildingSystem/…/Main/FurnitureFrame/init.luau` líneas 108–109
**Documentación relacionada:** [Servidor — piezas sueltas](../systems/server-misc.md#el-generador-de-modelos-de-herramienta)

#### Comportamiento observado — HECHO

La plantilla de ajustes de un objeto colocable trae esto:

```lua
module.Gui = {
	Name = script.Parent.Name,
	Description = [[
	uawhuduoahwudhouhnasuobd baouwb dawnduoabuyowid aw
	awdouabwudalw cadbaiybuob3oabouaousnocubo ap3
	...
	]],
	Icon = nil,
}
```

Es texto de relleno: alguien pasó la mano por el teclado para tener algo que enseñar mientras
maquetaba la ficha.

Y la interfaz de construcción lo muestra tal cual:

```lua
local DescriptionText:TextLabel = infoFrame.Information.DescriptionProduct
DescriptionText.Text = setting.Gui.Description
```

#### Por dónde llega a los jugadores — HECHO

Por dos caminos independientes.

**Los muebles.** Cada modelo de decoración lleva su propio `Settings` dentro. Buscando la
cadena de relleno en el árbol:

```
grep -rl "uawhuduoahwudhouhnasuobd" src --include=*.rbxm  →  46 archivos
find src -path '*decoration template*' -name '*.rbxm'     →  51 archivos
```

**46 de los 51 muebles** conservan el texto de la plantilla. Entre ellos `Bar.rbxm`,
`Berth.rbxm`, `Interruptor.rbxm`, `Nevera Polo Culinario.rbxm` y ocho camas y cunas con
nombre propio — es decir, objetos terminados y bautizados, no bocetos.

**Las herramientas colocables.** `ToolModelGenerator` fabrica en el arranque un modelo por
cada `Tool` con `Colocable = true`, y a todos les mete el mismo `Settings`:

```lua
script:FindFirstChild("Settings"):Clone().Parent = model
```

Ese `Settings` es una copia sin modificar de la plantilla. Así que **todas** las herramientas
colocables comparten descripción — y también precio: `Price = {Coins = 30, Gems = 10}`,
idéntico para todas, sea lo que sea la herramienta.

#### Por qué está aquí y no en una lista de tareas — HECHO

Porque el precio va en el mismo archivo. Un texto feo es contenido; que todas las herramientas
colocables cuesten exactamente 30 monedas y 10 gemas **es una decisión económica tomada por
omisión**, y quien la mire pensando que es intencionada no tiene forma de saber que no lo es.

`Name` sí se resuelve bien —`script.Parent.Name`, y el `Settings` se parentea dentro del
modelo, así que cada uno toma el suyo—. Lo que no se resuelve es nada de lo demás.

#### Teoría — TEORÍA

Un jugador abre el catálogo de construcción y ve, bajo el nombre de un mueble con nombre
cuidado, un párrafo de letras al azar. No es un fallo funcional: se compra, se coloca, todo
va. Es de las cosas que hacen que un juego parezca sin terminar aunque funcione, y de las que
nadie reporta como bug porque es evidente que nadie lo escribió a propósito.

Y por debajo, todas las herramientas colocables valen lo mismo.

#### Evidencia

| # | Evidencia |
|---|---|
| 1 | `SettingsTemplate.luau` trae la cadena de relleno como `Gui.Description` |
| 2 | `ToolModelGenerator/Settings.luau` es una copia sin tocar de esa plantilla |
| 3 | La línea 153 de `ToolModelGenerator/init.server.luau` la clona en **cada** modelo generado |
| 4 | `FurnitureFrame` asigna `setting.Gui.Description` a un `TextLabel` visible |
| 5 | 46 de los 51 `.rbxm` de decoración contienen la cadena |
| 6 | Los afectados incluyen objetos con nombre propio y terminado, no bocetos |
| 7 | `Price = {Coins = 30, Gems = 10}` es el mismo para todas las herramientas generadas |
| 8 | `Name = script.Parent.Name` sí se resuelve por objeto, lo que confirma que el archivo se pensó para personalizarse |

#### Incógnitas

- Si los 5 muebles restantes tienen descripción de verdad o simplemente no llevan `Settings`.
  Hay que abrirlos en Studio.
- Si el precio de las herramientas colocables se sobrescribe en otro sitio antes de mostrarse.
  No se ha encontrado, pero `Compras.luau` está leído solo en parte.
- Cuántas herramientas tienen `Colocable = true`. El atributo vive en los `.rbxm`, así que el
  número exacto solo se ve en Studio.
- Si hay una lista de descripciones escrita en otro sitio esperando a conectarse.

#### Escenario de ejemplo

Se publica el sistema de construcción. El primer vídeo que alguien graba abriendo el catálogo
muestra doce muebles seguidos con el mismo párrafo de letras al azar en la ficha. La respuesta
es «es un placeholder, lo cambiamos», y sigue ahí seis meses después porque no está en ninguna
lista.

**Comportamiento esperado:** cada objeto tiene su descripción y su precio.
**Comportamiento posible:** 46 muebles comparten un texto de relleno, y todas las herramientas
colocables comparten además el precio.

#### Plan de verificación — *Contenido y economía*

1. En Studio, abre el catálogo de construcción y recorre las fichas. Cuenta cuántas muestran
   el texto de relleno.
2. Compara con los 46 que da el `grep`. Si salen más, es que alguna herramienta generada
   también aparece ahí.
3. Comprueba el precio que muestra la ficha de dos herramientas colocables distintas.
4. Si coinciden en 30 monedas y 10 gemas, confirma que viene del `Settings` clonado y no de
   otro sitio.
5. Abre los 5 `.rbxm` que **no** contienen la cadena y comprueba si tienen `Settings` propio.
6. Comprueba si `Gui.Icon` (nulo en la plantilla) causa algún problema en la ficha, o si la
   interfaz lo tolera.

**Pasa:** cada objeto muestra su propia descripción y su propio precio.
**Falla:** aparecen descripciones repetidas de relleno, o precios idénticos entre herramientas
distintas.

**Instrumentación sugerida:** ninguna. Esto se arregla escribiendo contenido y decidiendo
precios, no tocando lógica — pero conviene decidir antes si `ToolModelGenerator` debe seguir
clonando un `Settings` común o si cada herramienta debe traer el suyo, porque eso sí es un
**cambio de código** y aquí no se aplica.


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
| Invitaciones: `ReferralConfig`, `ReferralMain` | Sí | La configuración razonada y los tres remotes |
| Invitaciones: `ReferralCommands`, `ReferralShared`, `ReferralClient` | **No** | En cola |
| `PlayerDataService`, `WorldSystem/PlayerDataReplicator.luau` | Sí | |
| `Data/Main/init.server.luau` | Sí | El orquestador de sesión; ver [Data.Main](../systems/session-orchestrator.md) |
| `AddValues`, `BreakDown` | En parte | Solo el camino de materialización de atributos, para cerrar la duda del tope de donación |
| `Collections` (moneda) | Sí | Leído entero: la pasada de seguridad (BUG-CANDIDATE-015), la ruta de persistencia (BUG-CANDIDATE-008) y la escritura silenciosa de `Give` (BUG-CANDIDATE-019) |
| `RoleService`, `EventCommands`, `ReferralCommands` | **En parte** | Solo la ruta de autorización, para la pasada de seguridad |
| `machines/Machine`, `machines/PopTheLock` | **En parte** | Solo las rutas de enlace y de premio |
| `GiftInbox` | Sí | Cierra **U-008** |
| `GlobalDataStore/init` | En parte | Las cuatro operaciones y la deduplicación; no la rama paginada de `OrderedDataStore` |
| `Shared/Stores`: `init`, `HouseAdded`, `ColorTexture` | Sí | Los trece manejadores de remotes y el ciclo de `content` |
| `Shared/Stores`: `Compras` | En parte | Solo `Comprar` y la forma general |
| `Shared/Stores`: `DecorFuncs/` (3 archivos), `DecorsPlayer` | Sí | La colocación y el índice por jugador |
| `Client/Posicionamientos` | En parte | `GetScale`, `IsInArea`, `GetFusion`, `getFace` |
| `Shared/Stores`: `Added` | Sí | Los puestos del place de donaciones |
| `Shared/Monetization` (4 archivos), `WorldSystem/GamePassService/init` | Sí | |
| `GamePassService/GamePassRewards` | En parte | Solo `ensure` |
| `ShopInfo`, `inventory/InventoryManager` | **No** | En cola; alimentan a `GamePassService` |
| Interactuables: registrador, clase base, `bindToTag` | Sí | |
| Interactuables: los 25 scripts de servidor | En parte | Solo su validación de entrada, para la matriz |
| Interactuables: los 36 módulos de cliente por tipo | **No** | Decisión deliberada: la pregunta era la estructura, no el catálogo |
| Inventario: `init.server`, `InventoryManager`, `DefaultTools` | Sí | |
| `ToolsServer.server.luau` | En parte | Los ocho manejadores y su validación; no la mecánica del cañón ni del guante |
| `ToolPlacementServer`, `Client/inventory/`, `ToolUseManagge` | **No** | En cola |
| `Karaoke/init.luau` | Sí | |
| `RevisarCanciones`, `CrearCancion` | En parte | El modelo de administración, los manejadores y sus guardas; no la paginación ni el editor |
| `KaraokeTV/` (3 archivos) | En parte | Registro de televisores, despacho de remotes y sus guardas |
| `BusquedaMusicas` | En parte | Las colas, su ritmo y la búsqueda por palabra clave; no el guardado de palabras ni la caché por sección |
| `Paint/ServerClient`, `Paint/FormatPinturaData` | En parte | Red, guardado, borrado, actualización y venta; no `like`, `MarkPaint` ni los marcos |
| `Paint/Paint/`, `Paint/Load/` | **No** | En cola — el editor es de cliente |
| Misiones, Máquinas, Animación, Cocina | **Barrido** | Solo su superficie de red y sus guardas; ver [Barrido](../systems/survey.md) |
| `JobSystem/init`, `ConditionsUses` | Sí | El despacho, la lista blanca y las condiciones |
| `JobSystem`: los cuatro módulos de trabajo | **En parte** | Solo su `WhiteList` y dónde pagan |
| `ToolPlacementServer` | En parte | Los cuatro remotes, la validación y los cerrojos; no las animaciones de apertura |
| `BuildingSystem` | Su papel, sí | Es interfaz de cliente sin remotes propios; su UI no se ha leído |
| `GiftHandler.server.luau` | Sí | La ruta de regalos y `ProcessReceipt` |
| `BusquedaMusicas` | En parte | Las colas, su ritmo y la búsqueda por palabra clave; no el guardado de palabras ni la caché por sección |
| `LootBoxService`, `PlaytimeRewardSystem`, `FavoriteService`, `DancesInfo` | Sí | Sistemas que no estaban ni en la lista |
| `ServerScripts/stats/` | En parte | Su papel y sus constantes |
| `MicManagerServer` | Sí | |
| `NametagServer` | En parte | Superficie, fuentes de datos y orden de etiquetas |
| `Shared/BartenderSystem/init.luau` | Sí | El registro y el despacho por acción fija |
| `BartenderSystem/Instance`, `NPC_Custom/` (5), `DialogModule` | En parte | La superficie de red y sus guardas; no la coreografía ni la interfaz |
| `Shared/GuideService/` (6 archivos), `Shared/Tutorials/` (2) | Sí | Salvo `InterfaceController`, que es montaje de GUI |
| Los 44 módulos de tipo de `Client/interactable/` | Sí, en superficie | Acciones y remotes de cada uno; la coreografía interna no |
| Máquinas: `Machine`, `MachineFactory`, `init.server`, `Roulette`, `ToyMachine`, `Stacker`, `PopTheLock`, `Basketball` | Sí | Las dos rutas de entrada y los seis manejadores de premio |
| `machines/Pong.luau`, `Shared/pong/` | En parte | Quién simula y quién cuenta; la física no |
| `Client/machines/` (16 archivos) | **Superficie** | Animación e interfaz, sin autoridad |
| `Client/InsertService.luau` | Sí | El caché, la deduplicación y el borrado de scripts |
| `Client/topbar.server.luau`, `Event`, `Disconnects` | Sí | |
| `Client/` — los otros 15 archivos sueltos y 13 carpetas pequeñas | **Superficie** | Su papel y a qué sistema pertenecen |
| `WalkieServer`, `collisions`, `fireExcept`, `ToolModelGenerator` | Sí | |
| `ServerScripts/Ragdoll/`, `stats/`, `AnimationSystem/` | En parte | Su papel y sus fuentes de datos |
| `Shared/Nametag/` (3) | En parte | Qué son; las tablas no se transcriben |
| `Assets/**/*.luau` (10) | En parte | El del walkie entero; los otros nueve en superficie |
| `Shared/ComprasTablero/` (2 archivos) | Sí | El teletipo entre servidores y la tabla global |
| `ReplicatedStorage/ShopInfo.luau` | Sí | Las 18 entradas y sus tres consumidores |
| `Shared/Nametag/`, `NametagMicClient` | **No** | En cola |
| Sistemas de juego (~413 archivos) | **No** | En cola |
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

Tras la segunda pasada, ya **sí** están revisados los trece remotes de `Stores` y los cinco
de `Monetization`, con los resultados de las entradas 020, 021 y 022.

Los 43 remotes de `Interactable` están revisados **en cuanto a validación de entrada** —esa
es la matriz de la página de Interactuables y las entradas 024 y 025—, no en cuanto a la
lógica interna de cada uno.

Los ocho remotes de `Tools` están revisados en cuanto a validación de entrada (entrada 027),
y los cinco de `Inventory` enteros.

Los remotes de moderación de `Karaoke` están revisados en cuanto a autorización (entrada 028).

Los ocho remotes de `Paint` están revisados en cuanto a autorización y ritmo (entrada 030).

**Siguen sin revisar:** los remotes de la cocina, `ToolPlacementServer`, los
televisores de karaoke, y el sistema de construcción. Son exactamente el tipo de superficie donde suelen aparecer más
hallazgos, así que esta sección debe leerse como un barrido en curso, no como una garantía.
