---
sidebar_position: 14
title: Persistencia fuera de DataKit
---

# Persistencia fuera de DataKit

[Persistencia](../architecture/persistence.md) dice que **todo** el estado duradero pasa por
DataKit. Es casi cierto: hay dos módulos que llaman a `DataStoreService` directamente, y
esta página existe para explicar por qué, porque los motivos son distintos y uno de ellos es
una decisión de diseño correcta y bien razonada.

Esto cierra la incógnita **U-008**, que preguntaba si estos dos duplicaban las garantías de
DataKit. **No las duplican**, y ninguno de los dos debería moverse a DataKit sin entender
antes lo que sigue.

| Módulo | Líneas | Por qué está fuera |
|---|---|---|
| `WorldSystem/GiftInbox` | 89 | **A propósito y correctamente.** El modelo de DataKit no sirve para este caso |
| `ServerStorage/GlobalDataStore` | 335 | Es una capa propia anterior, con listas ordenadas que DataKit no cubre |

## `GiftInbox` — cuándo el modelo de DataKit no sirve

**HECHO.** El módulo explica su propia existencia, y el razonamiento es correcto:

```lua
--[[
	Va en un DataStore aparte y no en el perfil a propósito: el perfil tiene un único
	escritor por lease, y aquí el servidor del comprador escribe sobre la identidad de
	otro jugador. `UpdateAsync` da la atomicidad necesaria si dos compradores regalan
	a la misma persona a la vez.
]]
```

Ese es exactamente el límite de DataKit. Un [`Store`](/api/Store) reclama un
[`Lease`](/api/Lease) sobre una identidad, y **solo su poseedor escribe**. Regalar es lo
contrario: el servidor de A escribe en los datos de B, que puede estar desconectado o en
otro servidor. Pedir el lease de B para dejarle un regalo sería robarle la sesión.

**HECHO.** El problema que resuelve también está escrito:

```lua
--[[
	Existe porque devolver `NotProcessedYet` con el receptor ausente deja el recibo en
	el limbo: Roblox solo lo reintenta mientras el COMPRADOR esté conectado, y si el
	receptor no vuelve a coincidir con él, los Robux se cobran y no se entrega nada
	nunca.
]]
```

**Registrado como correcto, y es el módulo mejor razonado del repositorio.** Guardar el
regalo, dar el recibo por bueno y entregarlo al entrar es la única forma de no perder Robux
cobrados. Y las tres decisiones de detalle acompañan:

| Decisión | Por qué importa |
|---|---|
| `push` devuelve `false` si no pudo escribir, y el comentario dice explícitamente que quien llama **no** debe dar el recibo por bueno | Sin eso, un fallo de DataStore cobraría sin entregar |
| `drain` devuelve lista vacía **sin borrar** si la lectura falla | Un fallo transitorio no destruye regalos |
| El tope `MAX_ENTRIES = 50` cancela la escritura devolviendo `nil` | Un buzón no puede crecer sin límite; devolver `nil` a `UpdateAsync` no gasta la escritura |
| `drain` devuelve `nil` cuando el buzón ya está vacío | «no gastamos una escritura», dice el comentario |

## `GlobalDataStore` — la capa anterior

**HECHO.** Es la capa de datos del karaoke y de los cuadros: letras, canciones en revisión,
canciones públicas, denuncias, baneos, pinturas, y las **listas ordenadas** de valoración y
de top de vendedores y compradores.

Las listas ordenadas son el motivo estructural de que no pueda ser DataKit: usa
`OrderedDataStore` con paginación, y DataKit no expone nada equivalente.

**HECHO.** Cuatro operaciones —`GetData`, `UpdateData`, `SetData`, `DeleteData`— y **ningún
reintento ni cortacircuitos**. Cada una hace un solo `pcall` sobre la llamada de Roblox y
devuelve el resultado:

```lua
local n, s = pcall(section.SetAsync, sending, key, Data)
self.AsyncInProcess.Get[ProcessKey] = nil
bin:Fire()
bin:Destroy()
return n, n and (...) or s
```

:::note Esto responde una incógnita de BUG-CANDIDATE-029

Esa entrada dejaba abierto si `GlobalDataStore` traía su propio reintento, en cuyo caso los
reintentos de `Paint` estarían anidados. **No lo trae.** El bucle de `Paint` es el único
reintento del sistema, y sigue siendo el único sin límite.

Tampoco hay nada equivalente a [`Health`](/api/Health): DataKit corta el circuito tras cinco
fallos; aquí no hay circuito que cortar.

:::

### La deduplicación de operaciones en vuelo

**HECHO.** Las cuatro operaciones evitan pisarse sobre la misma clave con un
`BindableEvent` guardado en una tabla, con clave `"<NameType>:<key>"`. La tabla se declara
así:

```lua
AsyncInProcess = {
	Set = {},
	Update = {},
	Get = {},
	Delete = {},
},
```

**y solo se usa `Get`.** Las cuatro operaciones escriben y leen en `AsyncInProcess.Get`; las
otras tres tablas no se tocan en ninguna línea del archivo. Compartir un solo espacio de
nombres es defendible —una escritura debería esperar a una lectura en curso de la misma
clave— pero no es lo que la declaración dice, y lleva a que las cuatro discrepen sobre qué
significa la señal compartida: [BUG-CANDIDATE-033](../testing/verification-plan.md#bug-candidate-033).

## Controles que sí sujetan

| Control | Cómo |
|---|---|
| **Un regalo no se pierde por un fallo de DataStore** | `push` devuelve `false` y quien llama no confirma el recibo; `drain` no borra si la lectura falla |
| **Dos regalos simultáneos al mismo jugador no se pisan** | `UpdateAsync`, que es comparar-y-fijar |
| **Un buzón no crece sin límite** | `MAX_ENTRIES = 50`, cancelando la escritura con `nil` |
| **No se gastan escrituras en vacío** | `drain` devuelve `nil` si no había nada |
| **Dos escrituras a la misma clave no se solapan** | La deduplicación por `BindableEvent` de `GlobalDataStore` |
| **Los datos devueltos se clonan** | `GetData` y `SetData` devuelven `table.clone`, así que quien llama no muta la caché |

## Puntos de verificación

| Aspecto | Entrada |
|---|---|
| Las cuatro operaciones comparten señal y no coinciden en qué lleva | [BUG-CANDIDATE-033](../testing/verification-plan.md#bug-candidate-033) |
| El reintento de borrado de cuadros no tiene techo | [BUG-CANDIDATE-029](../testing/verification-plan.md#bug-candidate-029) |

## Observaciones registradas, que no son defectos

| Observación | Detalle |
|---|---|
| `AsyncInProcess.Set`, `.Update` y `.Delete` se declaran y nunca se usan | Todo pasa por `.Get` |
| `SetData` y `UpdateData` reintentan por recursión al encontrar contención | Acotado por la contención real, no por un fallo; distinto de BUG-CANDIDATE-029 |
| `ReadMe.server.luau` empieza con `if true then return end` | Es documentación ejecutable desactivada: ejemplos de uso de las cuatro operaciones, y un enlace a un vídeo explicativo |
| `DatasTesteo` y `Testeo_GlobalDataStore` sustituyen el DataStore real en Studio | Para tres claves de karaoke |

## Qué queda por leer

| Archivo | Líneas | Estado |
|---|---|---|
| `WorldSystem/GiftInbox.luau` | 89 | Leído |
| `GlobalDataStore/init.luau` | 335 | **En parte** — las cuatro operaciones y la deduplicación; no la rama paginada de `OrderedDataStore` |
| `GlobalDataStore/Testeo_GlobalDataStore.luau` | 164 | **Pendiente** — el doble de pruebas |
| `ServerScripts/GiftHandler.server.luau` | — | **Pendiente** — quien llama a `push` y a `drain` |
| `ServerStorage/BusquedaMusicas.luau` | — | **Pendiente** |

## Implementación relacionada

| Aspecto | Código |
|---|---|
| Buzón de regalos | `WorldSystem/GiftInbox.luau`, `push`, `drain` |
| Claves y secciones | `GlobalDataStore/init.luau`, `Keys`, `SetSections`, `GetSection` |
| Las cuatro operaciones | `GlobalDataStore/init.luau`, `GetData`, `UpdateData`, `SetData`, `DeleteData` |
| Deduplicación en vuelo | `GlobalDataStore/init.luau`, `AsyncInProcess` |
| Ejemplos de uso | `GlobalDataStore/ReadMe.server.luau` — desactivado con `if true then return end` |
