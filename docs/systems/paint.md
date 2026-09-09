---
sidebar_position: 11
title: Cuadros
---

# Cuadros

Los jugadores dibujan cuadros píxel a píxel, los guardan, los cuelgan en su casa y **los
venden por Robux a otros jugadores**. Es el único sistema del juego donde un jugador crea
contenido que otro compra con dinero real, así que su superficie de red importa más que su
tamaño.

## Las piezas

| Módulo | Líneas | Papel |
|---|---|---|
| `Shared/Paint/ServerClient` | 737 | La fachada de red: guardar, cargar, borrar, actualizar, «me gusta», venta |
| `Shared/Paint/Paint` | 506 | El editor: lienzo, paleta, guardado |
| `Shared/Paint/FormatPinturaData` | 85 | El formato serializado y su validación |
| `Shared/Paint/Load` | 336 | La carga diferida y su cola |
| `Client/interactable/Paint`, `CuadrosPaint` | 396 | Los interactuables del lienzo y del cuadro colgado |

**HECHO.** `Data.Main` lo cablea: `PaintServer.DataBase = GlobalDataStore`,
`PaintServer.Cuadros = Stores.ComprasList`, y la secuencia de salida vuelca los cuadros del
jugador al perfil.

## El formato

**HECHO.** Un cuadro es una cadena con campos separados por `|`. Los cinco primeros son la
cabecera:

| Índice | Contenido |
|---|---|
| 1 | Resolución |
| 2 | Id del creador |
| 3 | Id del propietario |
| 4 | Nombre del cuadro |
| 5 | Información extra, entre paréntesis o corchetes |
| 6+ | Los píxeles |

`SeguridadFormato` es el validador, y comprueba **la forma**:

```lua
return typeof(encontrar) == 'table' and encontrar[1] and
	tonumber(encontrar[2]) and tonumber(encontrar[3]) and encontrar[4]
	and module.GetInfoExtra(encontrar[5]) and encontrar
```

Los cinco campos presentes y con el tipo correcto. **No comprueba cuántos campos vienen
después, ni cuánto ocupa la cadena.**

**OBSERVACIÓN.** El campo 3, el propietario, **lo escribe el cliente en la propia cadena**, y
`IsOwner` se limita a compararlo con el `UserId` de quien pregunta. Al guardar, la clave es
un GUID nuevo y entra en la lista del que llama, así que declarar a otro como propietario no
te da acceso a nada suyo: el efecto es que el cuadro queda en tu lista y no puedes borrarlo,
porque `Remove` exige `IsOwner`. Se registra por completitud, no como vía de ataque.

## La red

**HECHO.** Ocho remotes, y el servidor gatea razonablemente bien lo que importa:

| Remote | Guarda en el servidor |
|---|---|
| `Save` | `SeguridadFormato(Data)` y tope de `maxSlots = 9` cuadros por jugador |
| `Remove` | `GetData` (está en tu lista), `IsNotPaintInHouse`, y `Format.IsOwner` contra el dato del DataStore |
| `Update` | El modelo debe ser una `Model` con la etiqueta `Paint` o `CuadrosPaint`, y su atributo `Owner` / `InInUse` debe ser tu `UserId` |
| `Load`, `DataCache`, `GetAllPaints` | Devuelven lo del propio jugador |
| `CuadrosPaint` | *(el manejador de servidor tiene el cuerpo vacío; ver [Interactuables](./interactables.md))* |

**Registrado como correcto.** `UpdateCuadros` comprueba etiqueta **y** propiedad mediante un
atributo que pone el servidor, no un campo de la carga útil. Es más estricto que la mayoría
de manejadores de interactuables.

Lo que no está en el servidor es el **ritmo**:
[BUG-CANDIDATE-030](../testing/verification-plan.md#bug-candidate-030).

## El borrado y sus reintentos

**HECHO.** Borrar un cuadro del DataStore reintenta hasta conseguirlo, y lo hace
**llamándose a sí mismo**:

```lua
local function Delete()
	local success, _ = self.DataBase:DeleteData('DataPinturas', KeyCuadro)
	if not success then
		warn('error al eliminar este cuadro, intentando de nuevo.')
		Delete(esperar(self.ColaLoad.TimeExhauste / self.ColaLoad.MaxLoads))
	else
		warn('Cuadro eliminado por completo.')
	end
end
```

Sin contador de intentos y sin techo. `GetData`, unas líneas más arriba, tiene la misma
forma. Ver [BUG-CANDIDATE-029](../testing/verification-plan.md#bug-candidate-029).

**Contexto que importa:** esto usa `GlobalDataStore`, que llama a `DataStoreService`
**fuera de DataKit** (ver **U-008**), así que no tiene detrás el cortacircuitos `Health` que
protege al resto del juego.

## La venta

**HECHO.** Vender un cuadro es una compra en Robux gestionada por
[`Stores/Compras`](./stores.md) y [Monetización](./monetization.md). Cuando la venta ocurre
en otro servidor, llega por el **buzón del perfil**, no por `MessagingService`:

```lua
PlayerDataService.load(Player):onDelivered():Connect(function(message)
	if typeof(message) ~= 'table' or message.kind ~= 'paintSold' then return end
	PaintServer:VentaRemota(Player, message)
	if message.sellerHere then return end
	local price = tonumber(message.price)
	if price and price > 0 then
		Cobros.Give(Player, {Sell = price}, true)
	end
end)
```

**Registrado como correcto.** Es la única ruta de pago del juego que usa la entrega
idempotente de DataKit en vez de un mensaje efímero: si el vendedor estaba desconectado, el
cobro le espera en su perfil y se aplica al entrar. La comprobación `message.sellerHere`
evita pagar dos veces cuando ya se le pagó en vivo.

## Controles que sí sujetan

| Control | Cómo |
|---|---|
| **Tope de cuadros por jugador** | `maxSlots = 9`, comprobado en el servidor antes de generar la clave |
| **Borrar exige ser el dueño** | `Format.IsOwner` contra el dato **leído del DataStore**, no contra lo que manda el cliente |
| **No se borra un cuadro colgado en una casa** | `IsNotPaintInHouse`, y además se comprueba `data.IsInUse` |
| **Editar exige ser el dueño del lienzo** | Atributo `Owner` / `InInUse` puesto por el servidor |
| **El pago de una venta remota es idempotente** | Viaja por el buzón del perfil de DataKit, con `sellerHere` para no duplicar |
| **Las colas tienen presupuesto** | `ColaLoad` y `ColaLike` declaran `MaxLoads = 20` y `TimeExhauste = 60` |

## Puntos de verificación

| Aspecto | Entrada |
|---|---|
| El borrado reintenta por recursión, sin límite y sin cortacircuitos | [BUG-CANDIDATE-029](../testing/verification-plan.md#bug-candidate-029) |
| El límite de ritmo de `Update` solo existe en el cliente, y el servidor difunde a todos | [BUG-CANDIDATE-030](../testing/verification-plan.md#bug-candidate-030) |
| El tamaño del cuadro serializado no se comprueba | [BUG-CANDIDATE-020](../testing/verification-plan.md#bug-candidate-020), mismo patrón |

## Observaciones registradas, que no son defectos

| Observación | Detalle |
|---|---|
| `MaxUpdateDistance = 160` se declara y **no se usa en ninguna parte** | Un `grep` sobre todo `src/` solo encuentra la declaración |
| El campo «propietario» viaja dentro de la cadena que manda el cliente | Sin consecuencia práctica, por cómo funciona `Save`; ver arriba |
| `SeguridadFormato` se llama a sí misma para normalizar cadena → tabla | Recursión de un solo nivel, acotada por el cambio de tipo |
| El manejador de servidor de `CuadrosPaint` tiene el cuerpo vacío | Validado en [Interactuables](./interactables.md) |

## Qué queda por leer

| Archivo | Líneas | Estado |
|---|---|---|
| `Paint/ServerClient/init.luau` | 737 | **En parte** — red, guardado, borrado, actualización y venta; no `like`, `MarkPaint` ni los marcos |
| `Paint/FormatPinturaData/` | 85 | Leído |
| `Paint/Paint/` (3 archivos) | 826 | **Pendiente** — el editor es cliente |
| `Paint/Load/` (2 archivos) | 336 | **Pendiente** |

## Implementación relacionada

| Aspecto | Código |
|---|---|
| Formato y validación | `Shared/Paint/FormatPinturaData/init.luau` |
| Red | `Shared/Paint/ServerClient/init.luau`, `Works` |
| Guardado y borrado | `ServerClient`, `Save`, `Remove`, `AddedSave` |
| Edición replicada | `ServerClient`, `UpdateCuadros` |
| Venta remota | `ServerClient`, `VentaRemota`; `Data/Main/init.server.luau`, `onDelivered` |
| Almacenamiento | `ServerStorage/GlobalDataStore` — fuera de DataKit |
