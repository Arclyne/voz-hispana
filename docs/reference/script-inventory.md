---
sidebar_position: 1
title: Inventario de scripts
---

# Inventario de scripts

Todos los archivos `.luau` inspeccionables del repositorio, con la ruta del DataModel que
ocupan en ejecución y hasta dónde ha llegado este proyecto de documentación con cada uno.

Hay dos columnas porque el nombre del archivo miente sobre ambas cosas:

* **Ruta en ejecución** — la importación de plantillas saca todo de
  `ServerStorage/TemplatesTesting/<Plantilla>/<Servicio>/` hacia `<Servicio>`. Ver
  [Inicialización](../architecture/initialization.md).
* **Contexto** — el `RunContext` del `.meta.json` hermano manda sobre el sufijo
  `.server.luau` / `.client.luau`. Una celda vacía significa que no hay `RunContext`, así
  que decide el sufijo.

**Desactivado** marca un script que se distribuye apagado y se activa después: por
`InitScripts` en el servidor, o por algo ajeno a este repositorio en el cliente
([BUG-CANDIDATE-007](../testing/verification-plan.md#bug-candidate-007)).

## Estado

| Estado | Significado | Cantidad |
|---|---|---|
| **Documentado** | Leído entero y anotado con Moonwave por este proyecto | 8 |
| Analizado | Leído entero; su comportamiento se describe en alguna página del sitio | 139 |
| Analizado (en parte) | Leído solo en las partes relevantes para una pregunta concreta | 181 |
| Frontera (terceros) | Librería externa: se documenta qué es y quién la usa, **no se lee por dentro** — ver [Librerías de terceros](../architecture/third-party.md) | 160 |
| Pendiente | Aún sin leer | 64 |

**Total: 552 archivos, 80,608 líneas.**

## Fuera de las plantillas

8 archivos, 621 líneas, 5 leídos.

<details>
<summary><code>src/ReplicatedStorage/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `InitAfterTemplates.luau` | ModuleScript | — | — | 80 | `ReplicatedStorage.InitAfterTemplates` | **Documentado** |
| `PlayerInit.luau` | ModuleScript | — | — | 123 | `ReplicatedStorage.PlayerInit` | **Documentado** |

</details>

<details>
<summary><code>src/ReplicatedStorage/Client/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `visualsManager.server.luau` | Script | Client | yes | 49 | `ReplicatedStorage.Client.visualsManager.server` | Analizado |

</details>

<details>
<summary><code>src/ServerScriptService/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `ImportTemplates.server.luau` | Script | — | — | 144 | `ServerScriptService.ImportTemplates.server` | Analizado |
| `InitScripts.server.luau` | Script | — | — | 56 | `ServerScriptService.InitScripts.server` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/Templates/</code> — 3 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `SettingsTemplate.luau` | ModuleScript | — | — | 28 | `ServerStorage.Templates.SettingsTemplate` | Pendiente |
| `TemplateJob.luau` | ModuleScript | — | — | 97 | `ServerStorage.Templates.TemplateJob` | Pendiente |
| `TemplateUIS.luau` | ModuleScript | — | — | 44 | `ServerStorage.Templates.TemplateUIS` | Pendiente |

</details>

## Plantilla `Core`

530 archivos, 76,305 líneas, 477 leídos.

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/</code> — 6 archivo(s) — 4/6 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `BannersConfig.luau` | ModuleScript | — | — | 51 | `ReplicatedStorage.BannersConfig` | Pendiente |
| `DancesInfo.luau` | ModuleScript | — | — | 192 | `ReplicatedStorage.DancesInfo` | Analizado (en parte) |
| `GeneralConfiguration.luau` | ModuleScript | — | — | 40 | `ReplicatedStorage.GeneralConfiguration` | Analizado |
| `HousesInfo.luau` | ModuleScript | — | — | 54 | `ReplicatedStorage.HousesInfo` | Analizado |
| `ShopInfo.luau` | ModuleScript | — | — | 228 | `ReplicatedStorage.ShopInfo` | Analizado |
| `ShopSettings.luau` | ModuleScript | — | — | 17 | `ReplicatedStorage.ShopSettings` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Notas_Creacion_Plato.server.luau` | Script | — | yes | 3 | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Notas_Creacion_Plato.server` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/Ballon/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `MainTool.client.luau` | LocalScript | — | yes | 78 | `ReplicatedStorage.Assets.Tools.Toys.Ballon.MainTool.client` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/BigPotion/MainTool/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.client.luau` | LocalScript | — | yes | 59 | `ReplicatedStorage.Assets.Tools.Toys.BigPotion.MainTool.init.client` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/Cannon/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `MainTool.client.luau` | LocalScript | — | yes | 203 | `ReplicatedStorage.Assets.Tools.Toys.Cannon.MainTool.client` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/GloveGun/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `MainTool.client.luau` | LocalScript | — | yes | 75 | `ReplicatedStorage.Assets.Tools.Toys.GloveGun.MainTool.client` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/MiniPotion/MainTool/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.client.luau` | LocalScript | — | yes | 62 | `ReplicatedStorage.Assets.Tools.Toys.MiniPotion.MainTool.init.client` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/SlimeBomb/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `LocalScript.client.luau` | LocalScript | — | yes | 29 | `ReplicatedStorage.Assets.Tools.Toys.SlimeBomb.LocalScript.client` | Analizado (en parte) |
| `Script.server.luau` | Script | — | yes | 347 | `ReplicatedStorage.Assets.Tools.Toys.SlimeBomb.Script.server` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/SpyJetpack/MainTool/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.client.luau` | LocalScript | — | yes | 304 | `ReplicatedStorage.Assets.Tools.Toys.SpyJetpack.MainTool.init.client` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/Walkie/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `LocalScript.client.luau` | LocalScript | — | yes | 93 | `ReplicatedStorage.Assets.Tools.Toys.Walkie.LocalScript.client` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/</code> — 19 archivo(s) — 19/19 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Attributes.luau` | ModuleScript | — | — | 89 | `ReplicatedStorage.Client.Attributes` | Analizado (en parte) |
| `BusquedaSettings.luau` | ModuleScript | — | — | 210 | `ReplicatedStorage.Client.BusquedaSettings` | Analizado (en parte) |
| `CreatePath.luau` | ModuleScript | — | — | 38 | `ReplicatedStorage.Client.CreatePath` | Analizado (en parte) |
| `DesingData.luau` | ModuleScript | — | — | 38 | `ReplicatedStorage.Client.DesingData` | Analizado (en parte) |
| `Disconnects.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Client.Disconnects` | Analizado |
| `Event.luau` | ModuleScript | — | — | 44 | `ReplicatedStorage.Client.Event` | Analizado |
| `InsertService.luau` | ModuleScript | — | — | 120 | `ReplicatedStorage.Client.InsertService` | Analizado |
| `MainPS.server.luau` | Script | Client | yes | 94 | `ReplicatedStorage.Client.MainPS.server` | Analizado |
| `Math.luau` | ModuleScript | — | — | 35 | `ReplicatedStorage.Client.Math` | Analizado (en parte) |
| `NametagMicClient.server.luau` | Script | Client | yes | 259 | `ReplicatedStorage.Client.NametagMicClient.server` | Analizado (en parte) |
| `PaintActives.luau` | ModuleScript | — | — | 3 | `ReplicatedStorage.Client.PaintActives` | Analizado |
| `PlayerManager.server.luau` | Script | Client | yes | 59 | `ReplicatedStorage.Client.PlayerManager.server` | Analizado |
| `Posicionamientos.luau` | ModuleScript | — | — | 246 | `ReplicatedStorage.Client.Posicionamientos` | Analizado (en parte) |
| `SettingsInfo.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Client.SettingsInfo` | Analizado (en parte) |
| `SurfacePlacer.server.luau` | Script | Client | yes | 63 | `ReplicatedStorage.Client.SurfacePlacer.server` | Analizado (en parte) |
| `UiManager.server.luau` | Script | Client | yes | 166 | `ReplicatedStorage.Client.UiManager.server` | Analizado (en parte) |
| `messagesManager.server.luau` | Script | Client | yes | 79 | `ReplicatedStorage.Client.messagesManager.server` | Analizado (en parte) |
| `stats.server.luau` | Script | Client | yes | 69 | `ReplicatedStorage.Client.stats.server` | Analizado (en parte) |
| `topbar.server.luau` | Script | Client | yes | 282 | `ReplicatedStorage.Client.topbar.server` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/Animator/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 166 | `ReplicatedStorage.Client.Animator.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/ClickDetectorHandler/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `MouseAction.luau` | ModuleScript | — | — | 9 | `ReplicatedStorage.Client.ClickDetectorHandler.MouseAction` | Analizado (en parte) |
| `init.server.luau` | Script | Client | yes | 176 | `ReplicatedStorage.Client.ClickDetectorHandler.init.server` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/CodeExamples/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `MicStatusExample.server.luau` | Script | Client | yes | 118 | `ReplicatedStorage.Client.CodeExamples.MicStatusExample.server` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/EconomySystem/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Collections.luau` | ModuleScript | — | — | 176 | `ReplicatedStorage.Client.EconomySystem.Collections` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/ProgressBarStarter/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `ProgressBarController.luau` | ModuleScript | — | — | 98 | `ReplicatedStorage.Client.ProgressBarStarter.ProgressBarController` | Analizado (en parte) |
| `init.server.luau` | Script | Client | yes | 2 | `ReplicatedStorage.Client.ProgressBarStarter.init.server` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/QuestClient/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `QuestClient.server.luau` | Script | Client | yes | 205 | `ReplicatedStorage.Client.QuestClient.QuestClient.server` | Analizado (en parte) |
| `QuestPickableClient.server.luau` | Script | Client | yes | 97 | `ReplicatedStorage.Client.QuestClient.QuestPickableClient.server` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/Ragdoll/</code> — 4 archivo(s) — 4/4 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `GettingUpAssist.server.luau` | Script | Client | yes | 32 | `ReplicatedStorage.Client.Ragdoll.GettingUpAssist.server` | Analizado (en parte) |
| `RToRagdoll.server.luau` | Script | Client | yes | 28 | `ReplicatedStorage.Client.Ragdoll.RToRagdoll.server` | Analizado (en parte) |
| `RagdollAtHighSpeeds.server.luau` | Script | Client | yes | 44 | `ReplicatedStorage.Client.Ragdoll.RagdollAtHighSpeeds.server` | Analizado (en parte) |
| `RagdollRemote.server.luau` | Script | Client | yes | 34 | `ReplicatedStorage.Client.Ragdoll.RagdollRemote.server` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/ReferralClient/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `ReferralClient.server.luau` | Script | Client | yes | 683 | `ReplicatedStorage.Client.ReferralClient.ReferralClient.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/RouletteUIStarter/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `RouletteUIController.luau` | ModuleScript | — | — | 224 | `ReplicatedStorage.Client.RouletteUIStarter.RouletteUIController` | Analizado (en parte) |
| `init.server.luau` | Script | Client | yes | 2 | `ReplicatedStorage.Client.RouletteUIStarter.init.server` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/WorldSystem/ClientDataManager/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Channel.luau` | ModuleScript | — | — | 16 | `ReplicatedStorage.Client.WorldSystem.ClientDataManager.Channel` | Analizado (en parte) |
| `init.client.luau` | LocalScript | — | yes | 10 | `ReplicatedStorage.Client.WorldSystem.ClientDataManager.init.client` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/WorldSystem/Modules/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `InventoryController.luau` | ModuleScript | — | — | 22 | `ReplicatedStorage.Client.WorldSystem.Modules.InventoryController` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/animation/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.server.luau` | Script | Client | yes | 109 | `ReplicatedStorage.Client.animation.init.server` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/cooking/</code> — 7 archivo(s) — 7/7 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Blender.luau` | ModuleScript | — | — | 28 | `ReplicatedStorage.Client.cooking.Blender` | Analizado (en parte) |
| `CookingInteractable.luau` | ModuleScript | — | — | 179 | `ReplicatedStorage.Client.cooking.CookingInteractable` | Analizado (en parte) |
| `CuttingBoard.luau` | ModuleScript | — | — | 195 | `ReplicatedStorage.Client.cooking.CuttingBoard` | Analizado (en parte) |
| `Microwave.luau` | ModuleScript | — | — | 124 | `ReplicatedStorage.Client.cooking.Microwave` | Analizado (en parte) |
| `Oven.luau` | ModuleScript | — | — | 63 | `ReplicatedStorage.Client.cooking.Oven` | Analizado (en parte) |
| `Stove.luau` | ModuleScript | — | — | 35 | `ReplicatedStorage.Client.cooking.Stove` | Analizado (en parte) |
| `init.server.luau` | Script | Client | yes | 20 | `ReplicatedStorage.Client.cooking.init.server` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/</code> — 34 archivo(s) — 34/34 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `BarraBartender.luau` | ModuleScript | — | — | 131 | `ReplicatedStorage.Client.interactable.BarraBartender` | Analizado (en parte) |
| `Bath.luau` | ModuleScript | — | — | 72 | `ReplicatedStorage.Client.interactable.Bath` | Analizado (en parte) |
| `Bed.luau` | ModuleScript | — | — | 152 | `ReplicatedStorage.Client.interactable.Bed` | Analizado (en parte) |
| `Bin.luau` | ModuleScript | — | — | 35 | `ReplicatedStorage.Client.interactable.Bin` | Analizado (en parte) |
| `ButtonVipMoney.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Client.interactable.ButtonVipMoney` | Analizado |
| `CajasWork.luau` | ModuleScript | — | — | 54 | `ReplicatedStorage.Client.interactable.CajasWork` | Analizado (en parte) |
| `Chair.luau` | ModuleScript | — | — | 57 | `ReplicatedStorage.Client.interactable.Chair` | Analizado (en parte) |
| `ClassicDoor.luau` | ModuleScript | — | — | 48 | `ReplicatedStorage.Client.interactable.ClassicDoor` | Analizado (en parte) |
| `Computer.luau` | ModuleScript | — | — | 19 | `ReplicatedStorage.Client.interactable.Computer` | Analizado |
| `CuadrosPaint.luau` | ModuleScript | — | — | 147 | `ReplicatedStorage.Client.interactable.CuadrosPaint` | Analizado (en parte) |
| `DoorSalaKaraoke.luau` | ModuleScript | — | — | 113 | `ReplicatedStorage.Client.interactable.DoorSalaKaraoke` | Analizado (en parte) |
| `DoubleBed.luau` | ModuleScript | — | — | 252 | `ReplicatedStorage.Client.interactable.DoubleBed` | Analizado (en parte) |
| `Fridge.luau` | ModuleScript | — | — | 719 | `ReplicatedStorage.Client.interactable.Fridge` | Analizado (en parte) |
| `IdleToggle.luau` | ModuleScript | — | — | 56 | `ReplicatedStorage.Client.interactable.IdleToggle` | Analizado (en parte) |
| `Interruptor.luau` | ModuleScript | — | — | 119 | `ReplicatedStorage.Client.interactable.Interruptor` | Analizado (en parte) |
| `Lamp.luau` | ModuleScript | — | — | 85 | `ReplicatedStorage.Client.interactable.Lamp` | Analizado (en parte) |
| `MusicPlayer.luau` | ModuleScript | — | — | 67 | `ReplicatedStorage.Client.interactable.MusicPlayer` | Analizado (en parte) |
| `NightClub.luau` | ModuleScript | — | — | 76 | `ReplicatedStorage.Client.interactable.NightClub` | Analizado (en parte) |
| `NpcDialog.luau` | ModuleScript | — | — | 228 | `ReplicatedStorage.Client.interactable.NpcDialog` | Analizado (en parte) |
| `Paint.luau` | ModuleScript | — | — | 251 | `ReplicatedStorage.Client.interactable.Paint` | Analizado (en parte) |
| `Pee.luau` | ModuleScript | — | — | 79 | `ReplicatedStorage.Client.interactable.Pee` | Analizado (en parte) |
| `Piano.luau` | ModuleScript | — | — | 67 | `ReplicatedStorage.Client.interactable.Piano` | Analizado (en parte) |
| `PlaceTool.luau` | ModuleScript | — | — | 59 | `ReplicatedStorage.Client.interactable.PlaceTool` | Analizado |
| `PurchaseGamepass.luau` | ModuleScript | — | — | 60 | `ReplicatedStorage.Client.interactable.PurchaseGamepass` | Analizado |
| `QuestPickable.luau` | ModuleScript | — | — | 89 | `ReplicatedStorage.Client.interactable.QuestPickable` | Analizado (en parte) |
| `Shower.luau` | ModuleScript | — | — | 104 | `ReplicatedStorage.Client.interactable.Shower` | Analizado (en parte) |
| `SmokeMachine.luau` | ModuleScript | — | — | 74 | `ReplicatedStorage.Client.interactable.SmokeMachine` | Analizado (en parte) |
| `Stores.luau` | ModuleScript | — | — | 57 | `ReplicatedStorage.Client.interactable.Stores` | Analizado |
| `Toilet.luau` | ModuleScript | — | — | 45 | `ReplicatedStorage.Client.interactable.Toilet` | Analizado (en parte) |
| `ToolInteractable.luau` | ModuleScript | — | — | 241 | `ReplicatedStorage.Client.interactable.ToolInteractable` | Analizado (en parte) |
| `Washbasin.luau` | ModuleScript | — | — | 57 | `ReplicatedStorage.Client.interactable.Washbasin` | Analizado (en parte) |
| `Weight.luau` | ModuleScript | — | — | 54 | `ReplicatedStorage.Client.interactable.Weight` | Analizado (en parte) |
| `init.server.luau` | Script | Client | yes | 20 | `ReplicatedStorage.Client.interactable.init.server` | Analizado |
| `test.luau` | ModuleScript | — | — | 54 | `ReplicatedStorage.Client.interactable.test` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/DiscoBall/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Laser.server.luau` | Script | Client | yes | 86 | `ReplicatedStorage.Client.interactable.DiscoBall.Laser.server` | Analizado (en parte) |
| `init.luau` | ModuleScript | — | — | 157 | `ReplicatedStorage.Client.interactable.DiscoBall.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Display/</code> — 3 archivo(s) — 3/3 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `VideoPlayer.luau` | ModuleScript | — | — | 88 | `ReplicatedStorage.Client.interactable.Display.VideoPlayer` | Analizado (en parte) |
| `Videos.luau` | ModuleScript | — | — | 13 | `ReplicatedStorage.Client.interactable.Display.Videos` | Analizado (en parte) |
| `init.luau` | ModuleScript | — | — | 167 | `ReplicatedStorage.Client.interactable.Display.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 438 | `ReplicatedStorage.Client.interactable.Interactable.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/ActionWheel/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 95 | `ReplicatedStorage.Client.interactable.Interactable.ActionWheel.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/ActionWheel/Page/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 273 | `ReplicatedStorage.Client.interactable.Interactable.ActionWheel.Page.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/ActionWheel/Page/UI/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 121 | `ReplicatedStorage.Client.interactable.Interactable.ActionWheel.Page.UI.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/CustomPrompt/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 128 | `ReplicatedStorage.Client.interactable.Interactable.CustomPrompt.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Player/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Tijeras.luau` | ModuleScript | — | — | 181 | `ReplicatedStorage.Client.interactable.Player.Tijeras` | Analizado (en parte) |
| `init.luau` | ModuleScript | — | — | 78 | `ReplicatedStorage.Client.interactable.Player.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Treadmill/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 85 | `ReplicatedStorage.Client.interactable.Treadmill.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/inventory/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `InventoryWheel.luau` | ModuleScript | — | — | 343 | `ReplicatedStorage.Client.inventory.InventoryWheel` | Pendiente |
| `init.server.luau` | Script | Client | yes | 334 | `ReplicatedStorage.Client.inventory.init.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/inventory/InventoryList/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 65 | `ReplicatedStorage.Client.inventory.InventoryList.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/inventory/InventoryList/InventoryItem/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 170 | `ReplicatedStorage.Client.inventory.InventoryList.InventoryItem.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/</code> — 5 archivo(s) — 5/5 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `MachineFactory.luau` | ModuleScript | — | — | 26 | `ReplicatedStorage.Client.machines.MachineFactory` | Analizado (en parte) |
| `MachinePrompt.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Client.machines.MachinePrompt` | Analizado (en parte) |
| `Pong.luau` | ModuleScript | — | — | 184 | `ReplicatedStorage.Client.machines.Pong` | Analizado (en parte) |
| `init.server.luau` | Script | Client | yes | 133 | `ReplicatedStorage.Client.machines.init.server` | Analizado (en parte) |
| `machineUtil.luau` | ModuleScript | — | — | 70 | `ReplicatedStorage.Client.machines.machineUtil` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/Basketball/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Prediction.luau` | ModuleScript | — | — | 68 | `ReplicatedStorage.Client.machines.Basketball.Prediction` | Analizado (en parte) |
| `init.luau` | ModuleScript | — | — | 241 | `ReplicatedStorage.Client.machines.Basketball.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/PopTheLock/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Controller.luau` | ModuleScript | — | — | 177 | `ReplicatedStorage.Client.machines.PopTheLock.Controller` | Analizado (en parte) |
| `init.luau` | ModuleScript | — | — | 130 | `ReplicatedStorage.Client.machines.PopTheLock.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/Roulette/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 163 | `ReplicatedStorage.Client.machines.Roulette.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/Stacker/</code> — 5 archivo(s) — 5/5 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Board.luau` | ModuleScript | — | — | 197 | `ReplicatedStorage.Client.machines.Stacker.Board` | Analizado (en parte) |
| `Controller.luau` | ModuleScript | — | — | 225 | `ReplicatedStorage.Client.machines.Stacker.Controller` | Analizado (en parte) |
| `Figure.luau` | ModuleScript | — | — | 71 | `ReplicatedStorage.Client.machines.Stacker.Figure` | Analizado (en parte) |
| `idle.luau` | ModuleScript | — | — | 62 | `ReplicatedStorage.Client.machines.Stacker.idle` | Analizado (en parte) |
| `init.luau` | ModuleScript | — | — | 98 | `ReplicatedStorage.Client.machines.Stacker.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/ToyMachine/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 161 | `ReplicatedStorage.Client.machines.ToyMachine.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/notificationsManager/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.server.luau` | Script | Client | yes | 223 | `ReplicatedStorage.Client.notificationsManager.init.server` | Analizado (en parte) |
| `statsNotifications.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Client.notificationsManager.statsNotifications` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/</code> — 3 archivo(s) — 3/3 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `debug.luau` | ModuleScript | — | — | 160 | `ReplicatedStorage.Kinetic.debug` | Frontera (terceros) |
| `init.luau` | ModuleScript | — | — | 338 | `ReplicatedStorage.Kinetic.init` | Frontera (terceros) |
| `types.luau` | ModuleScript | — | — | 181 | `ReplicatedStorage.Kinetic.types` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/animatable/</code> — 3 archivo(s) — 3/3 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `adapters.luau` | ModuleScript | — | — | 169 | `ReplicatedStorage.Kinetic.animatable.adapters` | Frontera (terceros) |
| `color.luau` | ModuleScript | — | — | 87 | `ReplicatedStorage.Kinetic.animatable.color` | Frontera (terceros) |
| `init.luau` | ModuleScript | — | — | 77 | `ReplicatedStorage.Kinetic.animatable.init` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/constants/</code> — 3 archivo(s) — 3/3 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `configs.luau` | ModuleScript | — | — | 22 | `ReplicatedStorage.Kinetic.constants.configs` | Frontera (terceros) |
| `easings.luau` | ModuleScript | — | — | 150 | `ReplicatedStorage.Kinetic.constants.easings` | Frontera (terceros) |
| `init.luau` | ModuleScript | — | — | 13 | `ReplicatedStorage.Kinetic.constants.init` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/core/</code> — 5 archivo(s) — 5/5 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `AnimationConfig.luau` | ModuleScript | — | — | 92 | `ReplicatedStorage.Kinetic.core.AnimationConfig` | Frontera (terceros) |
| `Controller.luau` | ModuleScript | — | — | 835 | `ReplicatedStorage.Kinetic.core.Controller` | Frontera (terceros) |
| `FrameLoop.luau` | ModuleScript | — | — | 146 | `ReplicatedStorage.Kinetic.core.FrameLoop` | Frontera (terceros) |
| `Interpolation.luau` | ModuleScript | — | — | 224 | `ReplicatedStorage.Kinetic.core.Interpolation` | Frontera (terceros) |
| `SpringValue.luau` | ModuleScript | — | — | 758 | `ReplicatedStorage.Kinetic.core.SpringValue` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/orchestration/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Transition.luau` | ModuleScript | — | — | 305 | `ReplicatedStorage.Kinetic.orchestration.Transition` | Frontera (terceros) |
| `init.luau` | ModuleScript | — | — | 130 | `ReplicatedStorage.Kinetic.orchestration.init` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/targets/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `instance.luau` | ModuleScript | — | — | 183 | `ReplicatedStorage.Kinetic.targets.instance` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/util/</code> — 3 archivo(s) — 3/3 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Completion.luau` | ModuleScript | — | — | 145 | `ReplicatedStorage.Kinetic.util.Completion` | Frontera (terceros) |
| `Signal.luau` | ModuleScript | — | — | 78 | `ReplicatedStorage.Kinetic.util.Signal` | Frontera (terceros) |
| `timeGuard.luau` | ModuleScript | — | — | 44 | `ReplicatedStorage.Kinetic.util.timeGuard` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/</code> — 44 archivo(s) — 44/44 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `AddValues.luau` | ModuleScript | — | — | 59 | `ReplicatedStorage.Shared.AddValues` | Analizado (en parte) |
| `AdjustBoxFrame.luau` | ModuleScript | — | — | 131 | `ReplicatedStorage.Shared.AdjustBoxFrame` | Analizado (en parte) |
| `AnimationButtons.luau` | ModuleScript | — | — | 299 | `ReplicatedStorage.Shared.AnimationButtons` | Analizado (en parte) |
| `AreaSystem.luau` | ModuleScript | — | — | 148 | `ReplicatedStorage.Shared.AreaSystem` | Analizado (en parte) |
| `AssetsToPreload.luau` | ModuleScript | — | — | 14 | `ReplicatedStorage.Shared.AssetsToPreload` | Analizado |
| `BreakDown.luau` | ModuleScript | — | — | 86 | `ReplicatedStorage.Shared.BreakDown` | Analizado |
| `ButtonMotion.luau` | ModuleScript | — | — | 420 | `ReplicatedStorage.Shared.ButtonMotion` | Analizado (en parte) |
| `CardSlots.luau` | ModuleScript | — | — | 477 | `ReplicatedStorage.Shared.CardSlots` | Analizado (en parte) |
| `Carousel.luau` | ModuleScript | — | — | 354 | `ReplicatedStorage.Shared.Carousel` | Analizado (en parte) |
| `CircularBuffer.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.CircularBuffer` | Analizado |
| `Clock.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Clock` | Analizado |
| `CollisionModule.luau` | ModuleScript | — | — | 63 | `ReplicatedStorage.Shared.CollisionModule` | Analizado |
| `Commands.luau` | ModuleScript | — | — | 127 | `ReplicatedStorage.Shared.Commands` | Analizado |
| `GuiScaleManager.luau` | ModuleScript | — | — | 106 | `ReplicatedStorage.Shared.GuiScaleManager` | Analizado (en parte) |
| `InfoCoins.luau` | ModuleScript | — | — | 10 | `ReplicatedStorage.Shared.InfoCoins` | Analizado |
| `InputPlayer.luau` | ModuleScript | — | — | 85 | `ReplicatedStorage.Shared.InputPlayer` | Analizado (en parte) |
| `KeyGenerator.luau` | ModuleScript | — | — | 28 | `ReplicatedStorage.Shared.KeyGenerator` | Analizado |
| `MovedScrollButton.luau` | ModuleScript | — | — | 222 | `ReplicatedStorage.Shared.MovedScrollButton` | Analizado (en parte) |
| `MovingPlayers.luau` | ModuleScript | — | — | 98 | `ReplicatedStorage.Shared.MovingPlayers` | Analizado (en parte) |
| `NetworkTimer.luau` | ModuleScript | — | — | 41 | `ReplicatedStorage.Shared.NetworkTimer` | Analizado |
| `ObjectCache.luau` | ModuleScript | — | — | 174 | `ReplicatedStorage.Shared.ObjectCache` | Analizado (en parte) |
| `PrettyPrint.luau` | ModuleScript | — | — | 35 | `ReplicatedStorage.Shared.PrettyPrint` | Analizado (en parte) |
| `Running.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.Running` | Analizado |
| `RutaCreate.luau` | ModuleScript | — | — | 135 | `ReplicatedStorage.Shared.RutaCreate` | Analizado (en parte) |
| `SellHousePrompt.luau` | ModuleScript | — | — | 289 | `ReplicatedStorage.Shared.SellHousePrompt` | Analizado (en parte) |
| `ShopHighlight.luau` | ModuleScript | — | — | 377 | `ReplicatedStorage.Shared.ShopHighlight` | Analizado (en parte) |
| `Signal.luau` | ModuleScript | — | — | 432 | `ReplicatedStorage.Shared.Signal` | Frontera (terceros) |
| `SignalsGame.luau` | ModuleScript | — | — | 56 | `ReplicatedStorage.Shared.SignalsGame` | Analizado |
| `SizeManager.luau` | ModuleScript | — | — | 165 | `ReplicatedStorage.Shared.SizeManager` | Analizado (en parte) |
| `SmoothShiftLock.luau` | ModuleScript | — | — | 232 | `ReplicatedStorage.Shared.SmoothShiftLock` | Analizado (en parte) |
| `SoundManager.luau` | ModuleScript | — | — | 230 | `ReplicatedStorage.Shared.SoundManager` | Analizado (en parte) |
| `Spring.luau` | ModuleScript | — | — | 31 | `ReplicatedStorage.Shared.Spring` | Analizado |
| `ToolUseManagge.luau` | ModuleScript | — | — | 109 | `ReplicatedStorage.Shared.ToolUseManagge` | Analizado (en parte) |
| `Trove.luau` | ModuleScript | — | — | 612 | `ReplicatedStorage.Shared.Trove` | Frontera (terceros) |
| `UpdatingCountText.luau` | ModuleScript | — | — | 136 | `ReplicatedStorage.Shared.UpdatingCountText` | Analizado (en parte) |
| `VoiceModulator.luau` | ModuleScript | — | — | 71 | `ReplicatedStorage.Shared.VoiceModulator` | Analizado |
| `attach.luau` | ModuleScript | — | — | 7 | `ReplicatedStorage.Shared.attach` | Analizado |
| `basketUtil.luau` | ModuleScript | — | — | 67 | `ReplicatedStorage.Shared.basketUtil` | Analizado (en parte) |
| `bindToTag.luau` | ModuleScript | — | — | 24 | `ReplicatedStorage.Shared.bindToTag` | Analizado |
| `lerp.luau` | ModuleScript | — | — | 5 | `ReplicatedStorage.Shared.lerp` | Analizado |
| `makeClientPart.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.makeClientPart` | Analizado |
| `promptText.luau` | ModuleScript | — | — | 53 | `ReplicatedStorage.Shared.promptText` | Analizado (en parte) |
| `showExitButton.luau` | ModuleScript | — | — | 33 | `ReplicatedStorage.Shared.showExitButton` | Analizado (en parte) |
| `textScaler.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.textScaler` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/BartenderSystem/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 234 | `ReplicatedStorage.Shared.BartenderSystem.init` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/BartenderSystem/Instance/</code> — 2 archivo(s) — 1/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `ActionsBartender.luau` | ModuleScript | — | — | 61 | `ReplicatedStorage.Shared.BartenderSystem.Instance.ActionsBartender` | Pendiente |
| `init.luau` | ModuleScript | — | — | 549 | `ReplicatedStorage.Shared.BartenderSystem.Instance.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/ComprasTablero/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Settings.luau` | ModuleScript | — | — | 28 | `ReplicatedStorage.Shared.ComprasTablero.Settings` | Analizado |
| `init.luau` | ModuleScript | — | — | 378 | `ReplicatedStorage.Shared.ComprasTablero.init` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Cooldown/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `CooldownManager.luau` | ModuleScript | — | — | 76 | `ReplicatedStorage.Shared.Cooldown.CooldownManager` | Analizado |
| `CooldownShared.luau` | ModuleScript | — | — | 55 | `ReplicatedStorage.Shared.Cooldown.CooldownShared` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/DialogModule/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 405 | `ReplicatedStorage.Shared.DialogModule.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Dialogs/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `FrameShop.luau` | ModuleScript | — | — | 60 | `ReplicatedStorage.Shared.Dialogs.FrameShop` | Analizado (en parte) |
| `KaraokeRoomRent.luau` | ModuleScript | — | — | 51 | `ReplicatedStorage.Shared.Dialogs.KaraokeRoomRent` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/FastCastRedux/</code> — 6 archivo(s) — 6/6 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `ActiveCast.luau` | ModuleScript | — | — | 770 | `ReplicatedStorage.Shared.FastCastRedux.ActiveCast` | Frontera (terceros) |
| `Signal.luau` | ModuleScript | — | — | 153 | `ReplicatedStorage.Shared.FastCastRedux.Signal` | Frontera (terceros) |
| `Table.luau` | ModuleScript | — | — | 108 | `ReplicatedStorage.Shared.FastCastRedux.Table` | Frontera (terceros) |
| `TypeDefinitions.luau` | ModuleScript | — | — | 89 | `ReplicatedStorage.Shared.FastCastRedux.TypeDefinitions` | Frontera (terceros) |
| `TypeMarshaller.luau` | ModuleScript | — | — | 21 | `ReplicatedStorage.Shared.FastCastRedux.TypeMarshaller` | Frontera (terceros) |
| `init.luau` | ModuleScript | — | — | 145 | `ReplicatedStorage.Shared.FastCastRedux.init` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/GuideService/</code> — 4 archivo(s) — 3/4 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Disconnects.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.GuideService.Disconnects` | Analizado |
| `QuitarEspacios.luau` | ModuleScript | — | — | 5 | `ReplicatedStorage.Shared.GuideService.QuitarEspacios` | Analizado |
| `READ ME.client.luau` | LocalScript | — | yes | 121 | `ReplicatedStorage.Shared.GuideService.READ ME.client` | Pendiente |
| `init.luau` | ModuleScript | — | — | 89 | `ReplicatedStorage.Shared.GuideService.init` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/GuideService/PageController/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 92 | `ReplicatedStorage.Shared.GuideService.PageController.init` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/GuideService/PageController/InterfaceController/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 61 | `ReplicatedStorage.Shared.GuideService.PageController.InterfaceController.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/GuideService/PageController/VerificacionPages/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Changed.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Shared.GuideService.PageController.VerificacionPages.Changed` | Analizado (en parte) |
| `init.luau` | ModuleScript | — | — | 65 | `ReplicatedStorage.Shared.GuideService.PageController.VerificacionPages.init` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/GuideService/Server/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Rewards.luau` | ModuleScript | — | — | 5 | `ReplicatedStorage.Shared.GuideService.Server.Rewards` | Analizado |
| `init.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.GuideService.Server.init` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/</code> — 6 archivo(s) — 6/6 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Attribute.luau` | ModuleScript | — | — | 35 | `ReplicatedStorage.Shared.Icon.Attribute` | Frontera (terceros) |
| `Reference.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Icon.Reference` | Frontera (terceros) |
| `Types.luau` | ModuleScript | — | — | 477 | `ReplicatedStorage.Shared.Icon.Types` | Frontera (terceros) |
| `Utility.luau` | ModuleScript | — | — | 462 | `ReplicatedStorage.Shared.Icon.Utility` | Frontera (terceros) |
| `VERSION.luau` | ModuleScript | — | — | 51 | `ReplicatedStorage.Shared.Icon.VERSION` | Frontera (terceros) |
| `init.luau` | ModuleScript | — | — | 1253 | `ReplicatedStorage.Shared.Icon.init` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/Elements/</code> — 8 archivo(s) — 8/8 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Caption.luau` | ModuleScript | — | — | 316 | `ReplicatedStorage.Shared.Icon.Elements.Caption` | Frontera (terceros) |
| `Container.luau` | ModuleScript | — | — | 215 | `ReplicatedStorage.Shared.Icon.Elements.Container` | Frontera (terceros) |
| `Dropdown.luau` | ModuleScript | — | — | 315 | `ReplicatedStorage.Shared.Icon.Elements.Dropdown` | Frontera (terceros) |
| `Indicator.luau` | ModuleScript | — | — | 91 | `ReplicatedStorage.Shared.Icon.Elements.Indicator` | Frontera (terceros) |
| `Menu.luau` | ModuleScript | — | — | 180 | `ReplicatedStorage.Shared.Icon.Elements.Menu` | Frontera (terceros) |
| `Notice.luau` | ModuleScript | — | — | 113 | `ReplicatedStorage.Shared.Icon.Elements.Notice` | Frontera (terceros) |
| `Selection.luau` | ModuleScript | — | — | 49 | `ReplicatedStorage.Shared.Icon.Elements.Selection` | Frontera (terceros) |
| `Widget.luau` | ModuleScript | — | — | 437 | `ReplicatedStorage.Shared.Icon.Elements.Widget` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/Features/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Gamepad.luau` | ModuleScript | — | — | 201 | `ReplicatedStorage.Shared.Icon.Features.Gamepad` | Frontera (terceros) |
| `Overflow.luau` | ModuleScript | — | — | 360 | `ReplicatedStorage.Shared.Icon.Features.Overflow` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/Features/Themes/</code> — 3 archivo(s) — 3/3 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Classic.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Icon.Features.Themes.Classic` | Frontera (terceros) |
| `Default.luau` | ModuleScript | — | — | 75 | `ReplicatedStorage.Shared.Icon.Features.Themes.Default` | Frontera (terceros) |
| `init.luau` | ModuleScript | — | — | 353 | `ReplicatedStorage.Shared.Icon.Features.Themes.init` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/Packages/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `GoodSignal.luau` | ModuleScript | — | — | 182 | `ReplicatedStorage.Shared.Icon.Packages.GoodSignal` | Frontera (terceros) |
| `Janitor.luau` | ModuleScript | — | — | 322 | `ReplicatedStorage.Shared.Icon.Packages.Janitor` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/JobSystem/</code> — 4 archivo(s) — 2/4 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Bartender.luau` | ModuleScript | — | — | 447 | `ReplicatedStorage.Shared.JobSystem.Bartender` | Pendiente |
| `ConditionsUses.luau` | ModuleScript | — | — | 12 | `ReplicatedStorage.Shared.JobSystem.ConditionsUses` | Analizado |
| `LimpiarPiso.luau` | ModuleScript | — | — | 246 | `ReplicatedStorage.Shared.JobSystem.LimpiarPiso` | Pendiente |
| `init.luau` | ModuleScript | — | — | 305 | `ReplicatedStorage.Shared.JobSystem.init` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/JobSystem/ButtonMoney/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 245 | `ReplicatedStorage.Shared.JobSystem.ButtonMoney.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/JobSystem/CajasTransport/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 261 | `ReplicatedStorage.Shared.JobSystem.CajasTransport.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Karaoke/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 177 | `ReplicatedStorage.Shared.Karaoke.init` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Karaoke/CrearCancion/</code> — 3 archivo(s) — 1/3 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Attributes.luau` | ModuleScript | — | — | 83 | `ReplicatedStorage.Shared.Karaoke.CrearCancion.Attributes` | Pendiente |
| `Generos.luau` | ModuleScript | — | — | 25 | `ReplicatedStorage.Shared.Karaoke.CrearCancion.Generos` | Pendiente |
| `init.luau` | ModuleScript | — | — | 869 | `ReplicatedStorage.Shared.Karaoke.CrearCancion.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Karaoke/KaraokeTV/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `FunctActionsTV.luau` | ModuleScript | — | — | 223 | `ReplicatedStorage.Shared.Karaoke.KaraokeTV.FunctActionsTV` | Analizado (en parte) |
| `init.luau` | ModuleScript | — | — | 309 | `ReplicatedStorage.Shared.Karaoke.KaraokeTV.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Karaoke/KaraokeTV/TV/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 420 | `ReplicatedStorage.Shared.Karaoke.KaraokeTV.TV.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Karaoke/RevisarCanciones/</code> — 3 archivo(s) — 1/3 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `AttributesRequerest.luau` | ModuleScript | — | — | 11 | `ReplicatedStorage.Shared.Karaoke.RevisarCanciones.AttributesRequerest` | Pendiente |
| `Script.server.luau` | Script | — | yes | 75 | `ReplicatedStorage.Shared.Karaoke.RevisarCanciones.Script.server` | Pendiente |
| `init.luau` | ModuleScript | — | — | 1111 | `ReplicatedStorage.Shared.Karaoke.RevisarCanciones.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Monetization/</code> — 4 archivo(s) — 4/4 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Beneficios.luau` | ModuleScript | — | — | 18 | `ReplicatedStorage.Shared.Monetization.Beneficios` | Analizado |
| `MainModule.luau` | ModuleScript | — | — | 73 | `ReplicatedStorage.Shared.Monetization.MainModule` | Analizado |
| `MarkAdded.luau` | ModuleScript | — | — | 40 | `ReplicatedStorage.Shared.Monetization.MarkAdded` | Analizado |
| `init.luau` | ModuleScript | — | — | 335 | `ReplicatedStorage.Shared.Monetization.init` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/NPC_Custom/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Actions.luau` | ModuleScript | — | — | 100 | `ReplicatedStorage.Shared.NPC_Custom.Actions` | Analizado (en parte) |
| `init.luau` | ModuleScript | — | — | 105 | `ReplicatedStorage.Shared.NPC_Custom.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/NPC_Custom/Instance/</code> — 3 archivo(s) — 3/3 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `CustomizeSettings.luau` | ModuleScript | — | — | 24 | `ReplicatedStorage.Shared.NPC_Custom.Instance.CustomizeSettings` | Analizado (en parte) |
| `FormatPathNpc.luau` | ModuleScript | — | — | 58 | `ReplicatedStorage.Shared.NPC_Custom.Instance.FormatPathNpc` | Analizado (en parte) |
| `init.luau` | ModuleScript | — | — | 196 | `ReplicatedStorage.Shared.NPC_Custom.Instance.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Nametag/</code> — 3 archivo(s) — 3/3 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Countries.luau` | ModuleScript | — | — | 209 | `ReplicatedStorage.Shared.Nametag.Countries` | Analizado (en parte) |
| `LevelStyler.luau` | ModuleScript | — | — | 164 | `ReplicatedStorage.Shared.Nametag.LevelStyler` | Analizado (en parte) |
| `MicStatus.luau` | ModuleScript | — | — | 80 | `ReplicatedStorage.Shared.Nametag.MicStatus` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Nametag/GroupRoles/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 47 | `ReplicatedStorage.Shared.Nametag.GroupRoles.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Observers/</code> — 6 archivo(s) — 6/6 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 15 | `ReplicatedStorage.Shared.Observers.init` | Frontera (terceros) |
| `observeAttribute.luau` | ModuleScript | — | — | 119 | `ReplicatedStorage.Shared.Observers.observeAttribute` | Frontera (terceros) |
| `observeCharacter.luau` | ModuleScript | — | — | 82 | `ReplicatedStorage.Shared.Observers.observeCharacter` | Frontera (terceros) |
| `observePlayer.luau` | ModuleScript | — | — | 80 | `ReplicatedStorage.Shared.Observers.observePlayer` | Frontera (terceros) |
| `observeProperty.luau` | ModuleScript | — | — | 67 | `ReplicatedStorage.Shared.Observers.observeProperty` | Frontera (terceros) |
| `observeTag.luau` | ModuleScript | — | — | 192 | `ReplicatedStorage.Shared.Observers.observeTag` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Paint/Create/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 40 | `ReplicatedStorage.Shared.Paint.Create.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Paint/FormatPinturaData/</code> — 2 archivo(s) — 1/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `SplitRespectingBrackets.luau` | ModuleScript | — | — | 31 | `ReplicatedStorage.Shared.Paint.FormatPinturaData.SplitRespectingBrackets` | Pendiente |
| `init.luau` | ModuleScript | — | — | 55 | `ReplicatedStorage.Shared.Paint.FormatPinturaData.init` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Paint/Load/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 101 | `ReplicatedStorage.Shared.Paint.Load.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Paint/Load/LoadFrame/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Frames.luau` | ModuleScript | — | — | 7 | `ReplicatedStorage.Shared.Paint.Load.LoadFrame.Frames` | Pendiente |
| `init.luau` | ModuleScript | — | — | 235 | `ReplicatedStorage.Shared.Paint.Load.LoadFrame.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Paint/Paint/</code> — 3 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `PaletteColor.luau` | ModuleScript | — | — | 160 | `ReplicatedStorage.Shared.Paint.Paint.PaletteColor` | Pendiente |
| `Save.luau` | ModuleScript | — | — | 161 | `ReplicatedStorage.Shared.Paint.Paint.Save` | Pendiente |
| `init.luau` | ModuleScript | — | — | 507 | `ReplicatedStorage.Shared.Paint.Paint.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Paint/ServerClient/</code> — 2 archivo(s) — 1/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Marcos.server.luau` | Script | — | yes | 3 | `ReplicatedStorage.Shared.Paint.ServerClient.Marcos.server` | Pendiente |
| `init.luau` | ModuleScript | — | — | 737 | `ReplicatedStorage.Shared.Paint.ServerClient.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/PartCache/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Table.luau` | ModuleScript | — | — | 107 | `ReplicatedStorage.Shared.PartCache.Table` | Frontera (terceros) |
| `init.luau` | ModuleScript | — | — | 192 | `ReplicatedStorage.Shared.PartCache.init` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Promise/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 2068 | `ReplicatedStorage.Shared.Promise.init` | Frontera (terceros) |
| `init.spec.luau` | ModuleScript | — | — | 1844 | `ReplicatedStorage.Shared.Promise.init.spec` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/PrompBuy/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 109 | `ReplicatedStorage.Shared.PrompBuy.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Quests/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `QuestConfig.luau` | ModuleScript | — | — | 221 | `ReplicatedStorage.Shared.Quests.QuestConfig` | Pendiente |
| `QuestShared.luau` | ModuleScript | — | — | 49 | `ReplicatedStorage.Shared.Quests.QuestShared` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Referrals/</code> — 3 archivo(s) — 1/3 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `ProgressRing.luau` | ModuleScript | — | — | 114 | `ReplicatedStorage.Shared.Referrals.ProgressRing` | Pendiente |
| `ReferralConfig.luau` | ModuleScript | — | — | 196 | `ReplicatedStorage.Shared.Referrals.ReferralConfig` | Analizado (en parte) |
| `ReferralShared.luau` | ModuleScript | — | — | 309 | `ReplicatedStorage.Shared.Referrals.ReferralShared` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Sift/</code> — 3 archivo(s) — 3/3 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `None.luau` | ModuleScript | — | — | 16 | `ReplicatedStorage.Shared.Sift.None` | Frontera (terceros) |
| `Types.luau` | ModuleScript | — | — | 16 | `ReplicatedStorage.Shared.Sift.Types` | Frontera (terceros) |
| `init.luau` | ModuleScript | — | — | 58 | `ReplicatedStorage.Shared.Sift.init` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Sift/Array/</code> — 48 archivo(s) — 48/48 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `at.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Array.at` | Frontera (terceros) |
| `concat.luau` | ModuleScript | — | — | 46 | `ReplicatedStorage.Shared.Sift.Array.concat` | Frontera (terceros) |
| `concatDeep.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.Sift.Array.concatDeep` | Frontera (terceros) |
| `copy.luau` | ModuleScript | — | — | 19 | `ReplicatedStorage.Shared.Sift.Array.copy` | Frontera (terceros) |
| `copyDeep.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Array.copyDeep` | Frontera (terceros) |
| `count.luau` | ModuleScript | — | — | 42 | `ReplicatedStorage.Shared.Sift.Array.count` | Frontera (terceros) |
| `create.luau` | ModuleScript | — | — | 19 | `ReplicatedStorage.Shared.Sift.Array.create` | Frontera (terceros) |
| `difference.luau` | ModuleScript | — | — | 42 | `ReplicatedStorage.Shared.Sift.Array.difference` | Frontera (terceros) |
| `differenceSymmetric.luau` | ModuleScript | — | — | 42 | `ReplicatedStorage.Shared.Sift.Array.differenceSymmetric` | Frontera (terceros) |
| `equals.luau` | ModuleScript | — | — | 63 | `ReplicatedStorage.Shared.Sift.Array.equals` | Frontera (terceros) |
| `equalsDeep.luau` | ModuleScript | — | — | 63 | `ReplicatedStorage.Shared.Sift.Array.equalsDeep` | Frontera (terceros) |
| `every.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.Sift.Array.every` | Frontera (terceros) |
| `filter.luau` | ModuleScript | — | — | 43 | `ReplicatedStorage.Shared.Sift.Array.filter` | Frontera (terceros) |
| `find.luau` | ModuleScript | — | — | 33 | `ReplicatedStorage.Shared.Sift.Array.find` | Frontera (terceros) |
| `findLast.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.Sift.Array.findLast` | Frontera (terceros) |
| `findWhere.luau` | ModuleScript | — | — | 39 | `ReplicatedStorage.Shared.Sift.Array.findWhere` | Frontera (terceros) |
| `findWhereLast.luau` | ModuleScript | — | — | 43 | `ReplicatedStorage.Shared.Sift.Array.findWhereLast` | Frontera (terceros) |
| `first.luau` | ModuleScript | — | — | 23 | `ReplicatedStorage.Shared.Sift.Array.first` | Frontera (terceros) |
| `flatten.luau` | ModuleScript | — | — | 44 | `ReplicatedStorage.Shared.Sift.Array.flatten` | Frontera (terceros) |
| `freeze.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Array.freeze` | Frontera (terceros) |
| `freezeDeep.luau` | ModuleScript | — | — | 39 | `ReplicatedStorage.Shared.Sift.Array.freezeDeep` | Frontera (terceros) |
| `includes.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Array.includes` | Frontera (terceros) |
| `init.luau` | ModuleScript | — | — | 82 | `ReplicatedStorage.Shared.Sift.Array.init` | Frontera (terceros) |
| `insert.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.Sift.Array.insert` | Frontera (terceros) |
| `is.luau` | ModuleScript | — | — | 25 | `ReplicatedStorage.Shared.Sift.Array.is` | Frontera (terceros) |
| `last.luau` | ModuleScript | — | — | 23 | `ReplicatedStorage.Shared.Sift.Array.last` | Frontera (terceros) |
| `map.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.Sift.Array.map` | Frontera (terceros) |
| `pop.luau` | ModuleScript | — | — | 33 | `ReplicatedStorage.Shared.Sift.Array.pop` | Frontera (terceros) |
| `push.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Shared.Sift.Array.push` | Frontera (terceros) |
| `reduce.luau` | ModuleScript | — | — | 47 | `ReplicatedStorage.Shared.Sift.Array.reduce` | Frontera (terceros) |
| `reduceRight.luau` | ModuleScript | — | — | 48 | `ReplicatedStorage.Shared.Sift.Array.reduceRight` | Frontera (terceros) |
| `removeIndex.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Shared.Sift.Array.removeIndex` | Frontera (terceros) |
| `removeIndices.luau` | ModuleScript | — | — | 41 | `ReplicatedStorage.Shared.Sift.Array.removeIndices` | Frontera (terceros) |
| `removeValue.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Array.removeValue` | Frontera (terceros) |
| `removeValues.luau` | ModuleScript | — | — | 33 | `ReplicatedStorage.Shared.Sift.Array.removeValues` | Frontera (terceros) |
| `reverse.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Array.reverse` | Frontera (terceros) |
| `set.luau` | ModuleScript | — | — | 39 | `ReplicatedStorage.Shared.Sift.Array.set` | Frontera (terceros) |
| `shift.luau` | ModuleScript | — | — | 33 | `ReplicatedStorage.Shared.Sift.Array.shift` | Frontera (terceros) |
| `shuffle.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.Sift.Array.shuffle` | Frontera (terceros) |
| `slice.luau` | ModuleScript | — | — | 43 | `ReplicatedStorage.Shared.Sift.Array.slice` | Frontera (terceros) |
| `some.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.Sift.Array.some` | Frontera (terceros) |
| `sort.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Array.sort` | Frontera (terceros) |
| `splice.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.Sift.Array.splice` | Frontera (terceros) |
| `toSet.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Array.toSet` | Frontera (terceros) |
| `unshift.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Array.unshift` | Frontera (terceros) |
| `update.luau` | ModuleScript | — | — | 68 | `ReplicatedStorage.Shared.Sift.Array.update` | Frontera (terceros) |
| `zip.luau` | ModuleScript | — | — | 47 | `ReplicatedStorage.Shared.Sift.Array.zip` | Frontera (terceros) |
| `zipAll.luau` | ModuleScript | — | — | 51 | `ReplicatedStorage.Shared.Sift.Array.zipAll` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Sift/Dictionary/</code> — 30 archivo(s) — 30/30 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `copy.luau` | ModuleScript | — | — | 20 | `ReplicatedStorage.Shared.Sift.Dictionary.copy` | Frontera (terceros) |
| `copyDeep.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Dictionary.copyDeep` | Frontera (terceros) |
| `count.luau` | ModuleScript | — | — | 42 | `ReplicatedStorage.Shared.Sift.Dictionary.count` | Frontera (terceros) |
| `entries.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Dictionary.entries` | Frontera (terceros) |
| `equals.luau` | ModuleScript | — | — | 64 | `ReplicatedStorage.Shared.Sift.Dictionary.equals` | Frontera (terceros) |
| `equalsDeep.luau` | ModuleScript | — | — | 64 | `ReplicatedStorage.Shared.Sift.Dictionary.equalsDeep` | Frontera (terceros) |
| `every.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.Sift.Dictionary.every` | Frontera (terceros) |
| `filter.luau` | ModuleScript | — | — | 41 | `ReplicatedStorage.Shared.Sift.Dictionary.filter` | Frontera (terceros) |
| `flatten.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.Sift.Dictionary.flatten` | Frontera (terceros) |
| `flip.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Dictionary.flip` | Frontera (terceros) |
| `freeze.luau` | ModuleScript | — | — | 31 | `ReplicatedStorage.Shared.Sift.Dictionary.freeze` | Frontera (terceros) |
| `freezeDeep.luau` | ModuleScript | — | — | 38 | `ReplicatedStorage.Shared.Sift.Dictionary.freezeDeep` | Frontera (terceros) |
| `fromArrays.luau` | ModuleScript | — | — | 31 | `ReplicatedStorage.Shared.Sift.Dictionary.fromArrays` | Frontera (terceros) |
| `fromEntries.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Dictionary.fromEntries` | Frontera (terceros) |
| `has.luau` | ModuleScript | — | — | 25 | `ReplicatedStorage.Shared.Sift.Dictionary.has` | Frontera (terceros) |
| `includes.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Dictionary.includes` | Frontera (terceros) |
| `init.luau` | ModuleScript | — | — | 51 | `ReplicatedStorage.Shared.Sift.Dictionary.init` | Frontera (terceros) |
| `keys.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Dictionary.keys` | Frontera (terceros) |
| `map.luau` | ModuleScript | — | — | 40 | `ReplicatedStorage.Shared.Sift.Dictionary.map` | Frontera (terceros) |
| `merge.luau` | ModuleScript | — | — | 45 | `ReplicatedStorage.Shared.Sift.Dictionary.merge` | Frontera (terceros) |
| `mergeDeep.luau` | ModuleScript | — | — | 56 | `ReplicatedStorage.Shared.Sift.Dictionary.mergeDeep` | Frontera (terceros) |
| `removeKey.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Dictionary.removeKey` | Frontera (terceros) |
| `removeKeys.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Dictionary.removeKeys` | Frontera (terceros) |
| `removeValue.luau` | ModuleScript | — | — | 31 | `ReplicatedStorage.Shared.Sift.Dictionary.removeValue` | Frontera (terceros) |
| `removeValues.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Shared.Sift.Dictionary.removeValues` | Frontera (terceros) |
| `set.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Dictionary.set` | Frontera (terceros) |
| `some.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.Sift.Dictionary.some` | Frontera (terceros) |
| `update.luau` | ModuleScript | — | — | 60 | `ReplicatedStorage.Shared.Sift.Dictionary.update` | Frontera (terceros) |
| `values.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Dictionary.values` | Frontera (terceros) |
| `withKeys.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Dictionary.withKeys` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Sift/Set/</code> — 16 archivo(s) — 16/16 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `add.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Set.add` | Frontera (terceros) |
| `copy.luau` | ModuleScript | — | — | 21 | `ReplicatedStorage.Shared.Sift.Set.copy` | Frontera (terceros) |
| `count.luau` | ModuleScript | — | — | 42 | `ReplicatedStorage.Shared.Sift.Set.count` | Frontera (terceros) |
| `delete.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.Sift.Set.delete` | Frontera (terceros) |
| `difference.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.Sift.Set.difference` | Frontera (terceros) |
| `differenceSymmetric.luau` | ModuleScript | — | — | 41 | `ReplicatedStorage.Shared.Sift.Set.differenceSymmetric` | Frontera (terceros) |
| `filter.luau` | ModuleScript | — | — | 41 | `ReplicatedStorage.Shared.Sift.Set.filter` | Frontera (terceros) |
| `fromArray.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Set.fromArray` | Frontera (terceros) |
| `has.luau` | ModuleScript | — | — | 22 | `ReplicatedStorage.Shared.Sift.Set.has` | Frontera (terceros) |
| `init.luau` | ModuleScript | — | — | 38 | `ReplicatedStorage.Shared.Sift.Set.init` | Frontera (terceros) |
| `intersection.luau` | ModuleScript | — | — | 46 | `ReplicatedStorage.Shared.Sift.Set.intersection` | Frontera (terceros) |
| `isSubset.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Set.isSubset` | Frontera (terceros) |
| `isSuperset.luau` | ModuleScript | — | — | 25 | `ReplicatedStorage.Shared.Sift.Set.isSuperset` | Frontera (terceros) |
| `map.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.Sift.Set.map` | Frontera (terceros) |
| `merge.luau` | ModuleScript | — | — | 38 | `ReplicatedStorage.Shared.Sift.Set.merge` | Frontera (terceros) |
| `toArray.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Set.toArray` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Sift/Util/</code> — 4 archivo(s) — 4/4 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `equalObjects.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Util.equalObjects` | Frontera (terceros) |
| `func.luau` | ModuleScript | — | — | 15 | `ReplicatedStorage.Shared.Sift.Util.func` | Frontera (terceros) |
| `init.luau` | ModuleScript | — | — | 5 | `ReplicatedStorage.Shared.Sift.Util.init` | Frontera (terceros) |
| `isEmpty.luau` | ModuleScript | — | — | 26 | `ReplicatedStorage.Shared.Sift.Util.isEmpty` | Frontera (terceros) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Stores/</code> — 6 archivo(s) — 6/6 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Added.luau` | ModuleScript | — | — | 205 | `ReplicatedStorage.Shared.Stores.Added` | Analizado |
| `ColorTexture.luau` | ModuleScript | — | — | 26 | `ReplicatedStorage.Shared.Stores.ColorTexture` | Analizado |
| `Compras.luau` | ModuleScript | — | — | 487 | `ReplicatedStorage.Shared.Stores.Compras` | Analizado (en parte) |
| `DecorsPlayer.luau` | ModuleScript | — | — | 92 | `ReplicatedStorage.Shared.Stores.DecorsPlayer` | Analizado |
| `HouseAdded.luau` | ModuleScript | — | — | 297 | `ReplicatedStorage.Shared.Stores.HouseAdded` | Analizado |
| `init.luau` | ModuleScript | — | — | 992 | `ReplicatedStorage.Shared.Stores.init` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Stores/DecorFuncs/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 117 | `ReplicatedStorage.Shared.Stores.DecorFuncs.init` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Stores/DecorFuncs/AddedDecor/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Collitions.luau` | ModuleScript | — | — | 17 | `ReplicatedStorage.Shared.Stores.DecorFuncs.AddedDecor.Collitions` | Analizado |
| `init.luau` | ModuleScript | — | — | 341 | `ReplicatedStorage.Shared.Stores.DecorFuncs.AddedDecor.init` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Tutorials/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `ParametrosGuideClaim.luau` | ModuleScript | — | — | 49 | `ReplicatedStorage.Shared.Tutorials.ParametrosGuideClaim` | Analizado |
| `ParametrosTutorialBienvenida.luau` | ModuleScript | — | — | 139 | `ReplicatedStorage.Shared.Tutorials.ParametrosTutorialBienvenida` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/machines/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `roulettePrizes.luau` | ModuleScript | — | — | 104 | `ReplicatedStorage.Shared.machines.roulettePrizes` | Analizado |
| `rouletteUtil.luau` | ModuleScript | — | — | 12 | `ReplicatedStorage.Shared.machines.rouletteUtil` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/pong/</code> — 4 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Ball.luau` | ModuleScript | — | — | 559 | `ReplicatedStorage.Shared.pong.Ball` | Pendiente |
| `Input.luau` | ModuleScript | — | — | 21 | `ReplicatedStorage.Shared.pong.Input` | Pendiente |
| `Paddle.luau` | ModuleScript | — | — | 222 | `ReplicatedStorage.Shared.pong.Paddle` | Pendiente |
| `createPongSession.luau` | ModuleScript | — | — | 48 | `ReplicatedStorage.Shared.pong.createPongSession` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/Data/Main/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `PlayerGamesFetcher.luau` | ModuleScript | — | — | 112 | `ServerScriptService.Data.Main.PlayerGamesFetcher` | Analizado (en parte) |
| `init.server.luau` | Script | — | yes | 393 | `ServerScriptService.Data.Main.init.server` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/</code> — 20 archivo(s) — 20/20 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `EventBootstrap.server.luau` | Script | — | yes | 34 | `ServerScriptService.ServerScripts.EventBootstrap.server` | Analizado |
| `EventCommands.server.luau` | Script | — | yes | 180 | `ServerScriptService.ServerScripts.EventCommands.server` | Analizado (en parte) |
| `FavoriteService.server.luau` | Script | Server | yes | 55 | `ServerScriptService.ServerScripts.FavoriteService.server` | Analizado (en parte) |
| `GiftHandler.server.luau` | Script | Server | yes | 355 | `ServerScriptService.ServerScripts.GiftHandler.server` | Analizado (en parte) |
| `LootBoxService.server.luau` | Script | — | yes | 104 | `ServerScriptService.ServerScripts.LootBoxService.server` | Analizado (en parte) |
| `MicManagerServer.server.luau` | Script | Server | yes | 197 | `ServerScriptService.ServerScripts.MicManagerServer.server` | Analizado (en parte) |
| `NametagServer.server.luau` | Script | Server | yes | 513 | `ServerScriptService.ServerScripts.NametagServer.server` | Analizado (en parte) |
| `PlayerDataInit.server.luau` | Script | Server | yes | 42 | `ServerScriptService.ServerScripts.PlayerDataInit.server` | Analizado |
| `PlayerDataReplicator.server.luau` | Script | Server | yes | 116 | `ServerScriptService.ServerScripts.PlayerDataReplicator.server` | Analizado |
| `PlaytimeRewardSystem.server.luau` | Script | — | yes | 107 | `ServerScriptService.ServerScripts.PlaytimeRewardSystem.server` | Analizado (en parte) |
| `ServerDirectory.server.luau` | Script | Server | yes | 432 | `ServerScriptService.ServerScripts.ServerDirectory.server` | Analizado |
| `ShopServerSystem.server.luau` | Script | Server | yes | 310 | `ServerScriptService.ServerScripts.ShopServerSystem.server` | Analizado (en parte) |
| `ToolPlacementServer.server.luau` | Script | Server | yes | 881 | `ServerScriptService.ServerScripts.ToolPlacementServer.server` | Analizado (en parte) |
| `ToolsServer.server.luau` | Script | — | yes | 989 | `ServerScriptService.ServerScripts.ToolsServer.server` | Analizado (en parte) |
| `WalkieServer.server.luau` | Script | Server | yes | 148 | `ServerScriptService.ServerScripts.WalkieServer.server` | Analizado |
| `WorldManager.server.luau` | Script | Server | yes | 228 | `ServerScriptService.ServerScripts.WorldManager.server` | Analizado |
| `WorldsBrowser.server.luau` | Script | Server | yes | 140 | `ServerScriptService.ServerScripts.WorldsBrowser.server` | Analizado |
| `collisions.server.luau` | Script | Server | yes | 37 | `ServerScriptService.ServerScripts.collisions.server` | Analizado |
| `fireExcept.luau` | ModuleScript | — | — | 11 | `ServerScriptService.ServerScripts.fireExcept` | Analizado |
| `playerManager.server.luau` | Script | — | yes | 208 | `ServerScriptService.ServerScripts.playerManager.server` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/AnimationSystem/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `AnimationManager.luau` | ModuleScript | — | — | 73 | `ServerScriptService.ServerScripts.AnimationSystem.AnimationManager` | Analizado (en parte) |
| `init.server.luau` | Script | Server | yes | 104 | `ServerScriptService.ServerScripts.AnimationSystem.init.server` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/Quests/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `QuestMain.server.luau` | Script | — | yes | 75 | `ServerScriptService.ServerScripts.Quests.QuestMain.server` | Analizado |
| `QuestService.luau` | ModuleScript | — | — | 347 | `ServerScriptService.ServerScripts.Quests.QuestService` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/Quests/Pickables/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `QuestPickableService.luau` | ModuleScript | — | — | 316 | `ServerScriptService.ServerScripts.Quests.Pickables.QuestPickableService` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/Ragdoll/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `DisableJointsWhenFalling.server.luau` | Script | — | yes | 63 | `ServerScriptService.ServerScripts.Ragdoll.DisableJointsWhenFalling.server` | Analizado (en parte) |
| `PhysicallySimulatedUpperBody.server.luau` | Script | — | yes | 47 | `ServerScriptService.ServerScripts.Ragdoll.PhysicallySimulatedUpperBody.server` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/Referrals/</code> — 2 archivo(s) — 1/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `ReferralCommands.server.luau` | Script | — | yes | 333 | `ServerScriptService.ServerScripts.Referrals.ReferralCommands.server` | Pendiente |
| `ReferralMain.server.luau` | Script | — | yes | 233 | `ServerScriptService.ServerScripts.Referrals.ReferralMain.server` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/ToolModelGenerator/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Settings.luau` | ModuleScript | — | — | 32 | `ServerScriptService.ServerScripts.ToolModelGenerator.Settings` | Analizado |
| `init.server.luau` | Script | Server | yes | 170 | `ServerScriptService.ServerScripts.ToolModelGenerator.init.server` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/cooking/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `CookingStation.luau` | ModuleScript | — | — | 270 | `ServerScriptService.ServerScripts.cooking.CookingStation` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/cooking/interactables/</code> — 5 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Blender.server.luau` | Script | Server | yes | 54 | `ServerScriptService.ServerScripts.cooking.interactables.Blender.server` | Pendiente |
| `CuttingBoard.server.luau` | Script | Server | yes | 113 | `ServerScriptService.ServerScripts.cooking.interactables.CuttingBoard.server` | Pendiente |
| `Microwave.server.luau` | Script | Server | yes | 233 | `ServerScriptService.ServerScripts.cooking.interactables.Microwave.server` | Pendiente |
| `Oven.server.luau` | Script | Server | yes | 72 | `ServerScriptService.ServerScripts.cooking.interactables.Oven.server` | Pendiente |
| `Stove.server.luau` | Script | Server | yes | 93 | `ServerScriptService.ServerScripts.cooking.interactables.Stove.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/interactable/</code> — 21 archivo(s) — 21/21 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `BarraBartender.server.luau` | Script | Server | yes | 24 | `ServerScriptService.ServerScripts.interactable.BarraBartender.server` | Analizado |
| `Bath.server.luau` | Script | Server | yes | 41 | `ServerScriptService.ServerScripts.interactable.Bath.server` | Analizado |
| `Bin.server.luau` | Script | Server | yes | 17 | `ServerScriptService.ServerScripts.interactable.Bin.server` | Analizado |
| `ClassicDoor.server.luau` | Script | Server | yes | 151 | `ServerScriptService.ServerScripts.interactable.ClassicDoor.server` | Analizado |
| `CuadrosPaint.server.luau` | Script | Server | yes | 11 | `ServerScriptService.ServerScripts.interactable.CuadrosPaint.server` | Analizado |
| `DiscoBall.server.luau` | Script | Server | yes | 7 | `ServerScriptService.ServerScripts.interactable.DiscoBall.server` | Analizado |
| `Display.server.luau` | Script | Server | yes | 31 | `ServerScriptService.ServerScripts.interactable.Display.server` | Analizado |
| `Fridge.server.luau` | Script | Server | yes | 137 | `ServerScriptService.ServerScripts.interactable.Fridge.server` | Analizado |
| `Lamp.server.luau` | Script | Server | yes | 116 | `ServerScriptService.ServerScripts.interactable.Lamp.server` | Analizado |
| `MusicPlayer.server.luau` | Script | Server | yes | 17 | `ServerScriptService.ServerScripts.interactable.MusicPlayer.server` | Analizado |
| `NpcDialog.server.luau` | Script | Server | yes | 27 | `ServerScriptService.ServerScripts.interactable.NpcDialog.server` | Analizado |
| `Paint.server.luau` | Script | Server | yes | 19 | `ServerScriptService.ServerScripts.interactable.Paint.server` | Analizado |
| `Pee.server.luau` | Script | Server | yes | 222 | `ServerScriptService.ServerScripts.interactable.Pee.server` | Analizado |
| `Seat.server.luau` | Script | Server | yes | 27 | `ServerScriptService.ServerScripts.interactable.Seat.server` | Analizado |
| `Shower.server.luau` | Script | Server | yes | 68 | `ServerScriptService.ServerScripts.interactable.Shower.server` | Analizado |
| `SmokeMachine.server.luau` | Script | Server | yes | 7 | `ServerScriptService.ServerScripts.interactable.SmokeMachine.server` | Analizado |
| `Tijeras.server.luau` | Script | Server | yes | 153 | `ServerScriptService.ServerScripts.interactable.Tijeras.server` | Analizado |
| `Toilet.server.luau` | Script | Server | yes | 98 | `ServerScriptService.ServerScripts.interactable.Toilet.server` | Analizado |
| `Treadmill.server.luau` | Script | Server | yes | 64 | `ServerScriptService.ServerScripts.interactable.Treadmill.server` | Analizado |
| `Washbasin.server.luau` | Script | Server | yes | 49 | `ServerScriptService.ServerScripts.interactable.Washbasin.server` | Analizado |
| `Weight.server.luau` | Script | Server | yes | 38 | `ServerScriptService.ServerScripts.interactable.Weight.server` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/interactable/Bed/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Bed.luau` | ModuleScript | — | — | 186 | `ServerScriptService.ServerScripts.interactable.Bed.Bed` | Analizado |
| `init.server.luau` | Script | Server | yes | 20 | `ServerScriptService.ServerScripts.interactable.Bed.init.server` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/interactable/DoubleBed/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `DoubleBed.luau` | ModuleScript | — | — | 255 | `ServerScriptService.ServerScripts.interactable.DoubleBed.DoubleBed` | Analizado |
| `init.server.luau` | Script | Server | yes | 23 | `ServerScriptService.ServerScripts.interactable.DoubleBed.init.server` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/inventory/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.server.luau` | Script | Server | yes | 95 | `ServerScriptService.ServerScripts.inventory.init.server` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/inventory/InventoryManager/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `DefaultTools.luau` | ModuleScript | — | — | 53 | `ServerScriptService.ServerScripts.inventory.InventoryManager.DefaultTools` | Analizado |
| `init.luau` | ModuleScript | — | — | 561 | `ServerScriptService.ServerScripts.inventory.InventoryManager.init` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/machines/</code> — 10 archivo(s) — 10/10 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Basketball.luau` | ModuleScript | — | — | 92 | `ServerScriptService.ServerScripts.machines.Basketball` | Analizado |
| `Machine.luau` | ModuleScript | — | — | 86 | `ServerScriptService.ServerScripts.machines.Machine` | Analizado |
| `MachineFactory.luau` | ModuleScript | — | — | 26 | `ServerScriptService.ServerScripts.machines.MachineFactory` | Analizado |
| `Pong.luau` | ModuleScript | — | — | 388 | `ServerScriptService.ServerScripts.machines.Pong` | Analizado (en parte) |
| `PopTheLock.luau` | ModuleScript | — | — | 55 | `ServerScriptService.ServerScripts.machines.PopTheLock` | Analizado |
| `Roulette.luau` | ModuleScript | — | — | 177 | `ServerScriptService.ServerScripts.machines.Roulette` | Analizado |
| `Stacker.luau` | ModuleScript | — | — | 50 | `ServerScriptService.ServerScripts.machines.Stacker` | Analizado |
| `ToyMachine.luau` | ModuleScript | — | — | 158 | `ServerScriptService.ServerScripts.machines.ToyMachine` | Analizado |
| `init.server.luau` | Script | Server | yes | 186 | `ServerScriptService.ServerScripts.machines.init.server` | Analizado |
| `oldPong.luau` | ModuleScript | — | — | 114 | `ServerScriptService.ServerScripts.machines.oldPong` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/stats/</code> — 3 archivo(s) — 3/3 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Stats.luau` | ModuleScript | — | — | 71 | `ServerScriptService.ServerScripts.stats.Stats` | Analizado (en parte) |
| `Timer.luau` | ModuleScript | — | — | 56 | `ServerScriptService.ServerScripts.stats.Timer` | Analizado (en parte) |
| `init.server.luau` | Script | Server | yes | 84 | `ServerScriptService.ServerScripts.stats.init.server` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `BusquedaMusicas.luau` | ModuleScript | — | — | 455 | `ServerStorage.BusquedaMusicas` | Analizado (en parte) |
| `SoundInfo.luau` | ModuleScript | — | — | 37 | `ServerStorage.SoundInfo` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/DataKit/</code> — 9 archivo(s) — 7/9 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `BaseStore.luau` | ModuleScript | — | — | 330 | `ServerStorage.DataKit.BaseStore` | Analizado (en parte) |
| `Health.luau` | ModuleScript | — | — | 82 | `ServerStorage.DataKit.Health` | Analizado |
| `Inbox.luau` | ModuleScript | — | — | 71 | `ServerStorage.DataKit.Inbox` | Pendiente |
| `Lease.luau` | ModuleScript | — | — | 254 | `ServerStorage.DataKit.Lease` | Analizado |
| `Mutex.luau` | ModuleScript | — | — | 62 | `ServerStorage.DataKit.Mutex` | Analizado |
| `Profile.luau` | ModuleScript | — | — | 149 | `ServerStorage.DataKit.Profile` | Analizado |
| `Signal.luau` | ModuleScript | — | — | 56 | `ServerStorage.DataKit.Signal` | Pendiente |
| `Store.luau` | ModuleScript | — | — | 1237 | `ServerStorage.DataKit.Store` | Analizado (en parte) |
| `init.luau` | ModuleScript | — | — | 56 | `ServerStorage.DataKit.init` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/DataKit/Adapters/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Types.luau` | ModuleScript | — | — | 62 | `ServerStorage.DataKit.Adapters.Types` | Pendiente |
| `init.luau` | ModuleScript | — | — | 46 | `ServerStorage.DataKit.Adapters.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/DataKit/Util/</code> — 5 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `capitalize.luau` | ModuleScript | — | — | 14 | `ServerStorage.DataKit.Util.capitalize` | Pendiente |
| `deepCopy.luau` | ModuleScript | — | — | 26 | `ServerStorage.DataKit.Util.deepCopy` | Pendiente |
| `deepEquals.luau` | ModuleScript | — | — | 31 | `ServerStorage.DataKit.Util.deepEquals` | Pendiente |
| `reconcile.luau` | ModuleScript | — | — | 27 | `ServerStorage.DataKit.Util.reconcile` | Pendiente |
| `retry.luau` | ModuleScript | — | — | 41 | `ServerStorage.DataKit.Util.retry` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/GlobalDataStore/</code> — 3 archivo(s) — 2/3 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `ReadMe.server.luau` | Script | Server | — | 60 | `ServerStorage.GlobalDataStore.ReadMe.server` | Analizado |
| `Testeo_GlobalDataStore.luau` | ModuleScript | — | — | 164 | `ServerStorage.GlobalDataStore.Testeo_GlobalDataStore` | Pendiente |
| `init.luau` | ModuleScript | — | — | 335 | `ServerStorage.GlobalDataStore.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/RoleService/</code> — 2 archivo(s) — 1/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `RolesGroup.luau` | ModuleScript | — | — | 16 | `ServerStorage.RoleService.RolesGroup` | Pendiente |
| `init.luau` | ModuleScript | — | — | 135 | `ServerStorage.RoleService.init` | **Documentado** |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/WorldSystem/</code> — 8 archivo(s) — 8/8 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `EventService.luau` | ModuleScript | — | — | 456 | `ServerStorage.WorldSystem.EventService` | Analizado |
| `GiftInbox.luau` | ModuleScript | — | — | 89 | `ServerStorage.WorldSystem.GiftInbox` | Analizado |
| `PlayerDataReplicator.luau` | ModuleScript | — | — | 555 | `ServerStorage.WorldSystem.PlayerDataReplicator` | Analizado |
| `PlayerDataService.luau` | ModuleScript | — | — | 116 | `ServerStorage.WorldSystem.PlayerDataService` | **Documentado** |
| `PlayerSchema.luau` | ModuleScript | — | — | 151 | `ServerStorage.WorldSystem.PlayerSchema` | **Documentado** |
| `Profiles.luau` | ModuleScript | — | — | 320 | `ServerStorage.WorldSystem.Profiles` | **Documentado** |
| `ReferralService.luau` | ModuleScript | — | — | 1244 | `ServerStorage.WorldSystem.ReferralService` | Analizado |
| `ServerPresence.luau` | ModuleScript | — | — | 366 | `ServerStorage.WorldSystem.ServerPresence` | **Documentado** |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/WorldSystem/GamePassService/</code> — 2 archivo(s) — 2/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `GamePassRewards.luau` | ModuleScript | — | — | 60 | `ServerStorage.WorldSystem.GamePassService.GamePassRewards` | Analizado (en parte) |
| `init.luau` | ModuleScript | — | — | 162 | `ServerStorage.WorldSystem.GamePassService.init` | **Documentado** |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/StarterGui/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `LocalScript.client.luau` | LocalScript | — | yes | 26 | `StarterGui.LocalScript.client` | Analizado |

</details>

## Plantilla `GameWorlds`

1 archivos, 68 líneas, 1 leídos.

<details>
<summary><code>src/ServerStorage/TemplatesTesting/GameWorlds/ServerScriptService/ServerScripts/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `PublicServerInit.lua.server.luau` | Script | — | yes | 68 | `ServerScriptService.ServerScripts.PublicServerInit.lua.server` | Analizado |

</details>

## Plantilla `PlayerHouses`

5 archivos, 864 líneas, 5 leídos.

<details>
<summary><code>src/ServerStorage/TemplatesTesting/PlayerHouses/ReplicatedStorage/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `RolesInfo.luau` | ModuleScript | — | — | 10 | `ReplicatedStorage.RolesInfo` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/PlayerHouses/ServerScriptService/</code> — 4 archivo(s) — 4/4 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `ModeratorManager.server.luau` | Script | — | yes | 156 | `ServerScriptService.ModeratorManager.server` | Analizado |
| `PlayerWorld_Init.lua.server.luau` | Script | — | yes | 291 | `ServerScriptService.PlayerWorld_Init.lua.server` | Analizado |
| `WorldDataReplicator.server.luau` | Script | — | yes | 241 | `ServerScriptService.WorldDataReplicator.server` | Analizado |
| `WorldService.luau` | ModuleScript | — | — | 166 | `ServerScriptService.WorldService` | Analizado |

</details>

## Plantilla `BuildingSystem`

8 archivos, 2,750 líneas, 0 leídos.

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `ColorFormat.luau` | ModuleScript | — | — | 43 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.ColorFormat` | Pendiente |
| `init.luau` | ModuleScript | — | — | 151 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/Color/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 291 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Color.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/Main/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 201 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Main.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/Main/DesingFrame/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 494 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Main.DesingFrame.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/Main/FurnitureFrame/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 325 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Main.FurnitureFrame.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/Main/Inventory/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 180 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Main.Inventory.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/MoveAndPlaceent/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 1065 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.MoveAndPlaceent.init` | Pendiente |

</details>
