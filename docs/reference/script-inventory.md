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
| Analizado | Leído entero; su comportamiento se describe en alguna página del sitio | 74 |
| Analizado (en parte) | Leído solo en las partes relevantes para una pregunta concreta | 45 |
| Pendiente | Aún sin leer | 425 |

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

530 archivos, 76,305 líneas, 116 leídos.

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
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Notas_Creacion_Plato.server.luau` | Script | — | yes | 3 | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Notas_Creacion_Plato.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/Ballon/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `MainTool.client.luau` | LocalScript | — | yes | 78 | `ReplicatedStorage.Assets.Tools.Toys.Ballon.MainTool.client` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/BigPotion/MainTool/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.client.luau` | LocalScript | — | yes | 59 | `ReplicatedStorage.Assets.Tools.Toys.BigPotion.MainTool.init.client` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/Cannon/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `MainTool.client.luau` | LocalScript | — | yes | 203 | `ReplicatedStorage.Assets.Tools.Toys.Cannon.MainTool.client` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/GloveGun/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `MainTool.client.luau` | LocalScript | — | yes | 75 | `ReplicatedStorage.Assets.Tools.Toys.GloveGun.MainTool.client` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/MiniPotion/MainTool/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.client.luau` | LocalScript | — | yes | 62 | `ReplicatedStorage.Assets.Tools.Toys.MiniPotion.MainTool.init.client` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/SlimeBomb/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `LocalScript.client.luau` | LocalScript | — | yes | 29 | `ReplicatedStorage.Assets.Tools.Toys.SlimeBomb.LocalScript.client` | Pendiente |
| `Script.server.luau` | Script | — | yes | 347 | `ReplicatedStorage.Assets.Tools.Toys.SlimeBomb.Script.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/SpyJetpack/MainTool/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.client.luau` | LocalScript | — | yes | 304 | `ReplicatedStorage.Assets.Tools.Toys.SpyJetpack.MainTool.init.client` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/Walkie/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `LocalScript.client.luau` | LocalScript | — | yes | 93 | `ReplicatedStorage.Assets.Tools.Toys.Walkie.LocalScript.client` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/</code> — 19 archivo(s) — 3/19 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Attributes.luau` | ModuleScript | — | — | 89 | `ReplicatedStorage.Client.Attributes` | Pendiente |
| `BusquedaSettings.luau` | ModuleScript | — | — | 210 | `ReplicatedStorage.Client.BusquedaSettings` | Pendiente |
| `CreatePath.luau` | ModuleScript | — | — | 38 | `ReplicatedStorage.Client.CreatePath` | Pendiente |
| `DesingData.luau` | ModuleScript | — | — | 38 | `ReplicatedStorage.Client.DesingData` | Pendiente |
| `Disconnects.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Client.Disconnects` | Pendiente |
| `Event.luau` | ModuleScript | — | — | 44 | `ReplicatedStorage.Client.Event` | Pendiente |
| `InsertService.luau` | ModuleScript | — | — | 120 | `ReplicatedStorage.Client.InsertService` | Pendiente |
| `MainPS.server.luau` | Script | Client | yes | 94 | `ReplicatedStorage.Client.MainPS.server` | Analizado |
| `Math.luau` | ModuleScript | — | — | 35 | `ReplicatedStorage.Client.Math` | Pendiente |
| `NametagMicClient.server.luau` | Script | Client | yes | 259 | `ReplicatedStorage.Client.NametagMicClient.server` | Pendiente |
| `PaintActives.luau` | ModuleScript | — | — | 3 | `ReplicatedStorage.Client.PaintActives` | Pendiente |
| `PlayerManager.server.luau` | Script | Client | yes | 59 | `ReplicatedStorage.Client.PlayerManager.server` | Analizado |
| `Posicionamientos.luau` | ModuleScript | — | — | 246 | `ReplicatedStorage.Client.Posicionamientos` | Analizado (en parte) |
| `SettingsInfo.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Client.SettingsInfo` | Pendiente |
| `SurfacePlacer.server.luau` | Script | Client | yes | 63 | `ReplicatedStorage.Client.SurfacePlacer.server` | Pendiente |
| `UiManager.server.luau` | Script | Client | yes | 166 | `ReplicatedStorage.Client.UiManager.server` | Pendiente |
| `messagesManager.server.luau` | Script | Client | yes | 79 | `ReplicatedStorage.Client.messagesManager.server` | Pendiente |
| `stats.server.luau` | Script | Client | yes | 69 | `ReplicatedStorage.Client.stats.server` | Pendiente |
| `topbar.server.luau` | Script | Client | yes | 282 | `ReplicatedStorage.Client.topbar.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/Animator/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 166 | `ReplicatedStorage.Client.Animator.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/ClickDetectorHandler/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `MouseAction.luau` | ModuleScript | — | — | 9 | `ReplicatedStorage.Client.ClickDetectorHandler.MouseAction` | Pendiente |
| `init.server.luau` | Script | Client | yes | 176 | `ReplicatedStorage.Client.ClickDetectorHandler.init.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/CodeExamples/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `MicStatusExample.server.luau` | Script | Client | yes | 118 | `ReplicatedStorage.Client.CodeExamples.MicStatusExample.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/EconomySystem/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Collections.luau` | ModuleScript | — | — | 176 | `ReplicatedStorage.Client.EconomySystem.Collections` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/ProgressBarStarter/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `ProgressBarController.luau` | ModuleScript | — | — | 98 | `ReplicatedStorage.Client.ProgressBarStarter.ProgressBarController` | Pendiente |
| `init.server.luau` | Script | Client | yes | 2 | `ReplicatedStorage.Client.ProgressBarStarter.init.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/QuestClient/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `QuestClient.server.luau` | Script | Client | yes | 205 | `ReplicatedStorage.Client.QuestClient.QuestClient.server` | Pendiente |
| `QuestPickableClient.server.luau` | Script | Client | yes | 97 | `ReplicatedStorage.Client.QuestClient.QuestPickableClient.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/Ragdoll/</code> — 4 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `GettingUpAssist.server.luau` | Script | Client | yes | 32 | `ReplicatedStorage.Client.Ragdoll.GettingUpAssist.server` | Pendiente |
| `RToRagdoll.server.luau` | Script | Client | yes | 28 | `ReplicatedStorage.Client.Ragdoll.RToRagdoll.server` | Pendiente |
| `RagdollAtHighSpeeds.server.luau` | Script | Client | yes | 44 | `ReplicatedStorage.Client.Ragdoll.RagdollAtHighSpeeds.server` | Pendiente |
| `RagdollRemote.server.luau` | Script | Client | yes | 34 | `ReplicatedStorage.Client.Ragdoll.RagdollRemote.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/ReferralClient/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `ReferralClient.server.luau` | Script | Client | yes | 683 | `ReplicatedStorage.Client.ReferralClient.ReferralClient.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/RouletteUIStarter/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `RouletteUIController.luau` | ModuleScript | — | — | 224 | `ReplicatedStorage.Client.RouletteUIStarter.RouletteUIController` | Pendiente |
| `init.server.luau` | Script | Client | yes | 2 | `ReplicatedStorage.Client.RouletteUIStarter.init.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/WorldSystem/ClientDataManager/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Channel.luau` | ModuleScript | — | — | 16 | `ReplicatedStorage.Client.WorldSystem.ClientDataManager.Channel` | Pendiente |
| `init.client.luau` | LocalScript | — | yes | 10 | `ReplicatedStorage.Client.WorldSystem.ClientDataManager.init.client` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/WorldSystem/Modules/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `InventoryController.luau` | ModuleScript | — | — | 22 | `ReplicatedStorage.Client.WorldSystem.Modules.InventoryController` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/animation/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.server.luau` | Script | Client | yes | 109 | `ReplicatedStorage.Client.animation.init.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/cooking/</code> — 7 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Blender.luau` | ModuleScript | — | — | 28 | `ReplicatedStorage.Client.cooking.Blender` | Pendiente |
| `CookingInteractable.luau` | ModuleScript | — | — | 179 | `ReplicatedStorage.Client.cooking.CookingInteractable` | Pendiente |
| `CuttingBoard.luau` | ModuleScript | — | — | 195 | `ReplicatedStorage.Client.cooking.CuttingBoard` | Pendiente |
| `Microwave.luau` | ModuleScript | — | — | 124 | `ReplicatedStorage.Client.cooking.Microwave` | Pendiente |
| `Oven.luau` | ModuleScript | — | — | 63 | `ReplicatedStorage.Client.cooking.Oven` | Pendiente |
| `Stove.luau` | ModuleScript | — | — | 35 | `ReplicatedStorage.Client.cooking.Stove` | Pendiente |
| `init.server.luau` | Script | Client | yes | 20 | `ReplicatedStorage.Client.cooking.init.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/</code> — 34 archivo(s) — 1/34 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `BarraBartender.luau` | ModuleScript | — | — | 131 | `ReplicatedStorage.Client.interactable.BarraBartender` | Pendiente |
| `Bath.luau` | ModuleScript | — | — | 72 | `ReplicatedStorage.Client.interactable.Bath` | Pendiente |
| `Bed.luau` | ModuleScript | — | — | 152 | `ReplicatedStorage.Client.interactable.Bed` | Pendiente |
| `Bin.luau` | ModuleScript | — | — | 35 | `ReplicatedStorage.Client.interactable.Bin` | Pendiente |
| `ButtonVipMoney.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Client.interactable.ButtonVipMoney` | Pendiente |
| `CajasWork.luau` | ModuleScript | — | — | 54 | `ReplicatedStorage.Client.interactable.CajasWork` | Pendiente |
| `Chair.luau` | ModuleScript | — | — | 57 | `ReplicatedStorage.Client.interactable.Chair` | Pendiente |
| `ClassicDoor.luau` | ModuleScript | — | — | 48 | `ReplicatedStorage.Client.interactable.ClassicDoor` | Pendiente |
| `Computer.luau` | ModuleScript | — | — | 19 | `ReplicatedStorage.Client.interactable.Computer` | Pendiente |
| `CuadrosPaint.luau` | ModuleScript | — | — | 147 | `ReplicatedStorage.Client.interactable.CuadrosPaint` | Pendiente |
| `DoorSalaKaraoke.luau` | ModuleScript | — | — | 113 | `ReplicatedStorage.Client.interactable.DoorSalaKaraoke` | Pendiente |
| `DoubleBed.luau` | ModuleScript | — | — | 252 | `ReplicatedStorage.Client.interactable.DoubleBed` | Pendiente |
| `Fridge.luau` | ModuleScript | — | — | 719 | `ReplicatedStorage.Client.interactable.Fridge` | Pendiente |
| `IdleToggle.luau` | ModuleScript | — | — | 56 | `ReplicatedStorage.Client.interactable.IdleToggle` | Pendiente |
| `Interruptor.luau` | ModuleScript | — | — | 119 | `ReplicatedStorage.Client.interactable.Interruptor` | Pendiente |
| `Lamp.luau` | ModuleScript | — | — | 85 | `ReplicatedStorage.Client.interactable.Lamp` | Pendiente |
| `MusicPlayer.luau` | ModuleScript | — | — | 67 | `ReplicatedStorage.Client.interactable.MusicPlayer` | Pendiente |
| `NightClub.luau` | ModuleScript | — | — | 76 | `ReplicatedStorage.Client.interactable.NightClub` | Pendiente |
| `NpcDialog.luau` | ModuleScript | — | — | 228 | `ReplicatedStorage.Client.interactable.NpcDialog` | Pendiente |
| `Paint.luau` | ModuleScript | — | — | 251 | `ReplicatedStorage.Client.interactable.Paint` | Pendiente |
| `Pee.luau` | ModuleScript | — | — | 79 | `ReplicatedStorage.Client.interactable.Pee` | Pendiente |
| `Piano.luau` | ModuleScript | — | — | 67 | `ReplicatedStorage.Client.interactable.Piano` | Pendiente |
| `PlaceTool.luau` | ModuleScript | — | — | 59 | `ReplicatedStorage.Client.interactable.PlaceTool` | Pendiente |
| `PurchaseGamepass.luau` | ModuleScript | — | — | 60 | `ReplicatedStorage.Client.interactable.PurchaseGamepass` | Pendiente |
| `QuestPickable.luau` | ModuleScript | — | — | 89 | `ReplicatedStorage.Client.interactable.QuestPickable` | Pendiente |
| `Shower.luau` | ModuleScript | — | — | 104 | `ReplicatedStorage.Client.interactable.Shower` | Pendiente |
| `SmokeMachine.luau` | ModuleScript | — | — | 74 | `ReplicatedStorage.Client.interactable.SmokeMachine` | Pendiente |
| `Stores.luau` | ModuleScript | — | — | 57 | `ReplicatedStorage.Client.interactable.Stores` | Pendiente |
| `Toilet.luau` | ModuleScript | — | — | 45 | `ReplicatedStorage.Client.interactable.Toilet` | Pendiente |
| `ToolInteractable.luau` | ModuleScript | — | — | 241 | `ReplicatedStorage.Client.interactable.ToolInteractable` | Pendiente |
| `Washbasin.luau` | ModuleScript | — | — | 57 | `ReplicatedStorage.Client.interactable.Washbasin` | Pendiente |
| `Weight.luau` | ModuleScript | — | — | 54 | `ReplicatedStorage.Client.interactable.Weight` | Pendiente |
| `init.server.luau` | Script | Client | yes | 20 | `ReplicatedStorage.Client.interactable.init.server` | Analizado |
| `test.luau` | ModuleScript | — | — | 54 | `ReplicatedStorage.Client.interactable.test` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/DiscoBall/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Laser.server.luau` | Script | Client | yes | 86 | `ReplicatedStorage.Client.interactable.DiscoBall.Laser.server` | Pendiente |
| `init.luau` | ModuleScript | — | — | 157 | `ReplicatedStorage.Client.interactable.DiscoBall.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Display/</code> — 3 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `VideoPlayer.luau` | ModuleScript | — | — | 88 | `ReplicatedStorage.Client.interactable.Display.VideoPlayer` | Pendiente |
| `Videos.luau` | ModuleScript | — | — | 13 | `ReplicatedStorage.Client.interactable.Display.Videos` | Pendiente |
| `init.luau` | ModuleScript | — | — | 167 | `ReplicatedStorage.Client.interactable.Display.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 438 | `ReplicatedStorage.Client.interactable.Interactable.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/ActionWheel/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 95 | `ReplicatedStorage.Client.interactable.Interactable.ActionWheel.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/ActionWheel/Page/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 273 | `ReplicatedStorage.Client.interactable.Interactable.ActionWheel.Page.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/ActionWheel/Page/UI/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 121 | `ReplicatedStorage.Client.interactable.Interactable.ActionWheel.Page.UI.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/CustomPrompt/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 128 | `ReplicatedStorage.Client.interactable.Interactable.CustomPrompt.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Player/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Tijeras.luau` | ModuleScript | — | — | 181 | `ReplicatedStorage.Client.interactable.Player.Tijeras` | Pendiente |
| `init.luau` | ModuleScript | — | — | 78 | `ReplicatedStorage.Client.interactable.Player.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Treadmill/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 85 | `ReplicatedStorage.Client.interactable.Treadmill.init` | Pendiente |

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
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/</code> — 5 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `MachineFactory.luau` | ModuleScript | — | — | 26 | `ReplicatedStorage.Client.machines.MachineFactory` | Pendiente |
| `MachinePrompt.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Client.machines.MachinePrompt` | Pendiente |
| `Pong.luau` | ModuleScript | — | — | 184 | `ReplicatedStorage.Client.machines.Pong` | Pendiente |
| `init.server.luau` | Script | Client | yes | 133 | `ReplicatedStorage.Client.machines.init.server` | Pendiente |
| `machineUtil.luau` | ModuleScript | — | — | 70 | `ReplicatedStorage.Client.machines.machineUtil` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/Basketball/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Prediction.luau` | ModuleScript | — | — | 68 | `ReplicatedStorage.Client.machines.Basketball.Prediction` | Pendiente |
| `init.luau` | ModuleScript | — | — | 241 | `ReplicatedStorage.Client.machines.Basketball.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/PopTheLock/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Controller.luau` | ModuleScript | — | — | 177 | `ReplicatedStorage.Client.machines.PopTheLock.Controller` | Pendiente |
| `init.luau` | ModuleScript | — | — | 130 | `ReplicatedStorage.Client.machines.PopTheLock.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/Roulette/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 163 | `ReplicatedStorage.Client.machines.Roulette.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/Stacker/</code> — 5 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Board.luau` | ModuleScript | — | — | 197 | `ReplicatedStorage.Client.machines.Stacker.Board` | Pendiente |
| `Controller.luau` | ModuleScript | — | — | 225 | `ReplicatedStorage.Client.machines.Stacker.Controller` | Pendiente |
| `Figure.luau` | ModuleScript | — | — | 71 | `ReplicatedStorage.Client.machines.Stacker.Figure` | Pendiente |
| `idle.luau` | ModuleScript | — | — | 62 | `ReplicatedStorage.Client.machines.Stacker.idle` | Pendiente |
| `init.luau` | ModuleScript | — | — | 98 | `ReplicatedStorage.Client.machines.Stacker.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/ToyMachine/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 161 | `ReplicatedStorage.Client.machines.ToyMachine.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/notificationsManager/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.server.luau` | Script | Client | yes | 223 | `ReplicatedStorage.Client.notificationsManager.init.server` | Pendiente |
| `statsNotifications.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Client.notificationsManager.statsNotifications` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/</code> — 3 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `debug.luau` | ModuleScript | — | — | 160 | `ReplicatedStorage.Kinetic.debug` | Pendiente |
| `init.luau` | ModuleScript | — | — | 338 | `ReplicatedStorage.Kinetic.init` | Pendiente |
| `types.luau` | ModuleScript | — | — | 181 | `ReplicatedStorage.Kinetic.types` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/animatable/</code> — 3 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `adapters.luau` | ModuleScript | — | — | 169 | `ReplicatedStorage.Kinetic.animatable.adapters` | Pendiente |
| `color.luau` | ModuleScript | — | — | 87 | `ReplicatedStorage.Kinetic.animatable.color` | Pendiente |
| `init.luau` | ModuleScript | — | — | 77 | `ReplicatedStorage.Kinetic.animatable.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/constants/</code> — 3 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `configs.luau` | ModuleScript | — | — | 22 | `ReplicatedStorage.Kinetic.constants.configs` | Pendiente |
| `easings.luau` | ModuleScript | — | — | 150 | `ReplicatedStorage.Kinetic.constants.easings` | Pendiente |
| `init.luau` | ModuleScript | — | — | 13 | `ReplicatedStorage.Kinetic.constants.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/core/</code> — 5 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `AnimationConfig.luau` | ModuleScript | — | — | 92 | `ReplicatedStorage.Kinetic.core.AnimationConfig` | Pendiente |
| `Controller.luau` | ModuleScript | — | — | 835 | `ReplicatedStorage.Kinetic.core.Controller` | Pendiente |
| `FrameLoop.luau` | ModuleScript | — | — | 146 | `ReplicatedStorage.Kinetic.core.FrameLoop` | Pendiente |
| `Interpolation.luau` | ModuleScript | — | — | 224 | `ReplicatedStorage.Kinetic.core.Interpolation` | Pendiente |
| `SpringValue.luau` | ModuleScript | — | — | 758 | `ReplicatedStorage.Kinetic.core.SpringValue` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/orchestration/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Transition.luau` | ModuleScript | — | — | 305 | `ReplicatedStorage.Kinetic.orchestration.Transition` | Pendiente |
| `init.luau` | ModuleScript | — | — | 130 | `ReplicatedStorage.Kinetic.orchestration.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/targets/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `instance.luau` | ModuleScript | — | — | 183 | `ReplicatedStorage.Kinetic.targets.instance` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/util/</code> — 3 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Completion.luau` | ModuleScript | — | — | 145 | `ReplicatedStorage.Kinetic.util.Completion` | Pendiente |
| `Signal.luau` | ModuleScript | — | — | 78 | `ReplicatedStorage.Kinetic.util.Signal` | Pendiente |
| `timeGuard.luau` | ModuleScript | — | — | 44 | `ReplicatedStorage.Kinetic.util.timeGuard` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/</code> — 44 archivo(s) — 3/44 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `AddValues.luau` | ModuleScript | — | — | 59 | `ReplicatedStorage.Shared.AddValues` | Analizado (en parte) |
| `AdjustBoxFrame.luau` | ModuleScript | — | — | 131 | `ReplicatedStorage.Shared.AdjustBoxFrame` | Pendiente |
| `AnimationButtons.luau` | ModuleScript | — | — | 299 | `ReplicatedStorage.Shared.AnimationButtons` | Pendiente |
| `AreaSystem.luau` | ModuleScript | — | — | 148 | `ReplicatedStorage.Shared.AreaSystem` | Pendiente |
| `AssetsToPreload.luau` | ModuleScript | — | — | 14 | `ReplicatedStorage.Shared.AssetsToPreload` | Pendiente |
| `BreakDown.luau` | ModuleScript | — | — | 86 | `ReplicatedStorage.Shared.BreakDown` | Analizado |
| `ButtonMotion.luau` | ModuleScript | — | — | 420 | `ReplicatedStorage.Shared.ButtonMotion` | Pendiente |
| `CardSlots.luau` | ModuleScript | — | — | 477 | `ReplicatedStorage.Shared.CardSlots` | Pendiente |
| `Carousel.luau` | ModuleScript | — | — | 354 | `ReplicatedStorage.Shared.Carousel` | Pendiente |
| `CircularBuffer.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.CircularBuffer` | Pendiente |
| `Clock.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Clock` | Pendiente |
| `CollisionModule.luau` | ModuleScript | — | — | 63 | `ReplicatedStorage.Shared.CollisionModule` | Pendiente |
| `Commands.luau` | ModuleScript | — | — | 127 | `ReplicatedStorage.Shared.Commands` | Pendiente |
| `GuiScaleManager.luau` | ModuleScript | — | — | 106 | `ReplicatedStorage.Shared.GuiScaleManager` | Pendiente |
| `InfoCoins.luau` | ModuleScript | — | — | 10 | `ReplicatedStorage.Shared.InfoCoins` | Pendiente |
| `InputPlayer.luau` | ModuleScript | — | — | 85 | `ReplicatedStorage.Shared.InputPlayer` | Pendiente |
| `KeyGenerator.luau` | ModuleScript | — | — | 28 | `ReplicatedStorage.Shared.KeyGenerator` | Pendiente |
| `MovedScrollButton.luau` | ModuleScript | — | — | 222 | `ReplicatedStorage.Shared.MovedScrollButton` | Pendiente |
| `MovingPlayers.luau` | ModuleScript | — | — | 98 | `ReplicatedStorage.Shared.MovingPlayers` | Pendiente |
| `NetworkTimer.luau` | ModuleScript | — | — | 41 | `ReplicatedStorage.Shared.NetworkTimer` | Pendiente |
| `ObjectCache.luau` | ModuleScript | — | — | 174 | `ReplicatedStorage.Shared.ObjectCache` | Pendiente |
| `PrettyPrint.luau` | ModuleScript | — | — | 35 | `ReplicatedStorage.Shared.PrettyPrint` | Pendiente |
| `Running.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.Running` | Pendiente |
| `RutaCreate.luau` | ModuleScript | — | — | 135 | `ReplicatedStorage.Shared.RutaCreate` | Pendiente |
| `SellHousePrompt.luau` | ModuleScript | — | — | 289 | `ReplicatedStorage.Shared.SellHousePrompt` | Pendiente |
| `ShopHighlight.luau` | ModuleScript | — | — | 377 | `ReplicatedStorage.Shared.ShopHighlight` | Pendiente |
| `Signal.luau` | ModuleScript | — | — | 432 | `ReplicatedStorage.Shared.Signal` | Pendiente |
| `SignalsGame.luau` | ModuleScript | — | — | 56 | `ReplicatedStorage.Shared.SignalsGame` | Pendiente |
| `SizeManager.luau` | ModuleScript | — | — | 165 | `ReplicatedStorage.Shared.SizeManager` | Pendiente |
| `SmoothShiftLock.luau` | ModuleScript | — | — | 232 | `ReplicatedStorage.Shared.SmoothShiftLock` | Pendiente |
| `SoundManager.luau` | ModuleScript | — | — | 230 | `ReplicatedStorage.Shared.SoundManager` | Pendiente |
| `Spring.luau` | ModuleScript | — | — | 31 | `ReplicatedStorage.Shared.Spring` | Pendiente |
| `ToolUseManagge.luau` | ModuleScript | — | — | 109 | `ReplicatedStorage.Shared.ToolUseManagge` | Pendiente |
| `Trove.luau` | ModuleScript | — | — | 612 | `ReplicatedStorage.Shared.Trove` | Pendiente |
| `UpdatingCountText.luau` | ModuleScript | — | — | 136 | `ReplicatedStorage.Shared.UpdatingCountText` | Pendiente |
| `VoiceModulator.luau` | ModuleScript | — | — | 71 | `ReplicatedStorage.Shared.VoiceModulator` | Pendiente |
| `attach.luau` | ModuleScript | — | — | 7 | `ReplicatedStorage.Shared.attach` | Pendiente |
| `basketUtil.luau` | ModuleScript | — | — | 67 | `ReplicatedStorage.Shared.basketUtil` | Pendiente |
| `bindToTag.luau` | ModuleScript | — | — | 24 | `ReplicatedStorage.Shared.bindToTag` | Analizado |
| `lerp.luau` | ModuleScript | — | — | 5 | `ReplicatedStorage.Shared.lerp` | Pendiente |
| `makeClientPart.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.makeClientPart` | Pendiente |
| `promptText.luau` | ModuleScript | — | — | 53 | `ReplicatedStorage.Shared.promptText` | Pendiente |
| `showExitButton.luau` | ModuleScript | — | — | 33 | `ReplicatedStorage.Shared.showExitButton` | Pendiente |
| `textScaler.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.textScaler` | Pendiente |

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
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Cooldown/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `CooldownManager.luau` | ModuleScript | — | — | 76 | `ReplicatedStorage.Shared.Cooldown.CooldownManager` | Pendiente |
| `CooldownShared.luau` | ModuleScript | — | — | 55 | `ReplicatedStorage.Shared.Cooldown.CooldownShared` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/DialogModule/</code> — 1 archivo(s) — 1/1 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 405 | `ReplicatedStorage.Shared.DialogModule.init` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Dialogs/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `FrameShop.luau` | ModuleScript | — | — | 60 | `ReplicatedStorage.Shared.Dialogs.FrameShop` | Pendiente |
| `KaraokeRoomRent.luau` | ModuleScript | — | — | 51 | `ReplicatedStorage.Shared.Dialogs.KaraokeRoomRent` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/FastCastRedux/</code> — 6 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `ActiveCast.luau` | ModuleScript | — | — | 770 | `ReplicatedStorage.Shared.FastCastRedux.ActiveCast` | Pendiente |
| `Signal.luau` | ModuleScript | — | — | 153 | `ReplicatedStorage.Shared.FastCastRedux.Signal` | Pendiente |
| `Table.luau` | ModuleScript | — | — | 108 | `ReplicatedStorage.Shared.FastCastRedux.Table` | Pendiente |
| `TypeDefinitions.luau` | ModuleScript | — | — | 89 | `ReplicatedStorage.Shared.FastCastRedux.TypeDefinitions` | Pendiente |
| `TypeMarshaller.luau` | ModuleScript | — | — | 21 | `ReplicatedStorage.Shared.FastCastRedux.TypeMarshaller` | Pendiente |
| `init.luau` | ModuleScript | — | — | 145 | `ReplicatedStorage.Shared.FastCastRedux.init` | Pendiente |

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
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/</code> — 6 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Attribute.luau` | ModuleScript | — | — | 35 | `ReplicatedStorage.Shared.Icon.Attribute` | Pendiente |
| `Reference.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Icon.Reference` | Pendiente |
| `Types.luau` | ModuleScript | — | — | 477 | `ReplicatedStorage.Shared.Icon.Types` | Pendiente |
| `Utility.luau` | ModuleScript | — | — | 462 | `ReplicatedStorage.Shared.Icon.Utility` | Pendiente |
| `VERSION.luau` | ModuleScript | — | — | 51 | `ReplicatedStorage.Shared.Icon.VERSION` | Pendiente |
| `init.luau` | ModuleScript | — | — | 1253 | `ReplicatedStorage.Shared.Icon.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/Elements/</code> — 8 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Caption.luau` | ModuleScript | — | — | 316 | `ReplicatedStorage.Shared.Icon.Elements.Caption` | Pendiente |
| `Container.luau` | ModuleScript | — | — | 215 | `ReplicatedStorage.Shared.Icon.Elements.Container` | Pendiente |
| `Dropdown.luau` | ModuleScript | — | — | 315 | `ReplicatedStorage.Shared.Icon.Elements.Dropdown` | Pendiente |
| `Indicator.luau` | ModuleScript | — | — | 91 | `ReplicatedStorage.Shared.Icon.Elements.Indicator` | Pendiente |
| `Menu.luau` | ModuleScript | — | — | 180 | `ReplicatedStorage.Shared.Icon.Elements.Menu` | Pendiente |
| `Notice.luau` | ModuleScript | — | — | 113 | `ReplicatedStorage.Shared.Icon.Elements.Notice` | Pendiente |
| `Selection.luau` | ModuleScript | — | — | 49 | `ReplicatedStorage.Shared.Icon.Elements.Selection` | Pendiente |
| `Widget.luau` | ModuleScript | — | — | 437 | `ReplicatedStorage.Shared.Icon.Elements.Widget` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/Features/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Gamepad.luau` | ModuleScript | — | — | 201 | `ReplicatedStorage.Shared.Icon.Features.Gamepad` | Pendiente |
| `Overflow.luau` | ModuleScript | — | — | 360 | `ReplicatedStorage.Shared.Icon.Features.Overflow` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/Features/Themes/</code> — 3 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Classic.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Icon.Features.Themes.Classic` | Pendiente |
| `Default.luau` | ModuleScript | — | — | 75 | `ReplicatedStorage.Shared.Icon.Features.Themes.Default` | Pendiente |
| `init.luau` | ModuleScript | — | — | 353 | `ReplicatedStorage.Shared.Icon.Features.Themes.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/Packages/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `GoodSignal.luau` | ModuleScript | — | — | 182 | `ReplicatedStorage.Shared.Icon.Packages.GoodSignal` | Pendiente |
| `Janitor.luau` | ModuleScript | — | — | 322 | `ReplicatedStorage.Shared.Icon.Packages.Janitor` | Pendiente |

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
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Nametag/</code> — 3 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Countries.luau` | ModuleScript | — | — | 209 | `ReplicatedStorage.Shared.Nametag.Countries` | Pendiente |
| `LevelStyler.luau` | ModuleScript | — | — | 164 | `ReplicatedStorage.Shared.Nametag.LevelStyler` | Pendiente |
| `MicStatus.luau` | ModuleScript | — | — | 80 | `ReplicatedStorage.Shared.Nametag.MicStatus` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Nametag/GroupRoles/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 47 | `ReplicatedStorage.Shared.Nametag.GroupRoles.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Observers/</code> — 6 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 15 | `ReplicatedStorage.Shared.Observers.init` | Pendiente |
| `observeAttribute.luau` | ModuleScript | — | — | 119 | `ReplicatedStorage.Shared.Observers.observeAttribute` | Pendiente |
| `observeCharacter.luau` | ModuleScript | — | — | 82 | `ReplicatedStorage.Shared.Observers.observeCharacter` | Pendiente |
| `observePlayer.luau` | ModuleScript | — | — | 80 | `ReplicatedStorage.Shared.Observers.observePlayer` | Pendiente |
| `observeProperty.luau` | ModuleScript | — | — | 67 | `ReplicatedStorage.Shared.Observers.observeProperty` | Pendiente |
| `observeTag.luau` | ModuleScript | — | — | 192 | `ReplicatedStorage.Shared.Observers.observeTag` | Pendiente |

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
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/PartCache/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Table.luau` | ModuleScript | — | — | 107 | `ReplicatedStorage.Shared.PartCache.Table` | Pendiente |
| `init.luau` | ModuleScript | — | — | 192 | `ReplicatedStorage.Shared.PartCache.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Promise/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 2068 | `ReplicatedStorage.Shared.Promise.init` | Pendiente |
| `init.spec.luau` | ModuleScript | — | — | 1844 | `ReplicatedStorage.Shared.Promise.init.spec` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/PrompBuy/</code> — 1 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 109 | `ReplicatedStorage.Shared.PrompBuy.init` | Pendiente |

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
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Sift/</code> — 3 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `None.luau` | ModuleScript | — | — | 16 | `ReplicatedStorage.Shared.Sift.None` | Pendiente |
| `Types.luau` | ModuleScript | — | — | 16 | `ReplicatedStorage.Shared.Sift.Types` | Pendiente |
| `init.luau` | ModuleScript | — | — | 58 | `ReplicatedStorage.Shared.Sift.init` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Sift/Array/</code> — 48 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `at.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Array.at` | Pendiente |
| `concat.luau` | ModuleScript | — | — | 46 | `ReplicatedStorage.Shared.Sift.Array.concat` | Pendiente |
| `concatDeep.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.Sift.Array.concatDeep` | Pendiente |
| `copy.luau` | ModuleScript | — | — | 19 | `ReplicatedStorage.Shared.Sift.Array.copy` | Pendiente |
| `copyDeep.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Array.copyDeep` | Pendiente |
| `count.luau` | ModuleScript | — | — | 42 | `ReplicatedStorage.Shared.Sift.Array.count` | Pendiente |
| `create.luau` | ModuleScript | — | — | 19 | `ReplicatedStorage.Shared.Sift.Array.create` | Pendiente |
| `difference.luau` | ModuleScript | — | — | 42 | `ReplicatedStorage.Shared.Sift.Array.difference` | Pendiente |
| `differenceSymmetric.luau` | ModuleScript | — | — | 42 | `ReplicatedStorage.Shared.Sift.Array.differenceSymmetric` | Pendiente |
| `equals.luau` | ModuleScript | — | — | 63 | `ReplicatedStorage.Shared.Sift.Array.equals` | Pendiente |
| `equalsDeep.luau` | ModuleScript | — | — | 63 | `ReplicatedStorage.Shared.Sift.Array.equalsDeep` | Pendiente |
| `every.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.Sift.Array.every` | Pendiente |
| `filter.luau` | ModuleScript | — | — | 43 | `ReplicatedStorage.Shared.Sift.Array.filter` | Pendiente |
| `find.luau` | ModuleScript | — | — | 33 | `ReplicatedStorage.Shared.Sift.Array.find` | Pendiente |
| `findLast.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.Sift.Array.findLast` | Pendiente |
| `findWhere.luau` | ModuleScript | — | — | 39 | `ReplicatedStorage.Shared.Sift.Array.findWhere` | Pendiente |
| `findWhereLast.luau` | ModuleScript | — | — | 43 | `ReplicatedStorage.Shared.Sift.Array.findWhereLast` | Pendiente |
| `first.luau` | ModuleScript | — | — | 23 | `ReplicatedStorage.Shared.Sift.Array.first` | Pendiente |
| `flatten.luau` | ModuleScript | — | — | 44 | `ReplicatedStorage.Shared.Sift.Array.flatten` | Pendiente |
| `freeze.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Array.freeze` | Pendiente |
| `freezeDeep.luau` | ModuleScript | — | — | 39 | `ReplicatedStorage.Shared.Sift.Array.freezeDeep` | Pendiente |
| `includes.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Array.includes` | Pendiente |
| `init.luau` | ModuleScript | — | — | 82 | `ReplicatedStorage.Shared.Sift.Array.init` | Pendiente |
| `insert.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.Sift.Array.insert` | Pendiente |
| `is.luau` | ModuleScript | — | — | 25 | `ReplicatedStorage.Shared.Sift.Array.is` | Pendiente |
| `last.luau` | ModuleScript | — | — | 23 | `ReplicatedStorage.Shared.Sift.Array.last` | Pendiente |
| `map.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.Sift.Array.map` | Pendiente |
| `pop.luau` | ModuleScript | — | — | 33 | `ReplicatedStorage.Shared.Sift.Array.pop` | Pendiente |
| `push.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Shared.Sift.Array.push` | Pendiente |
| `reduce.luau` | ModuleScript | — | — | 47 | `ReplicatedStorage.Shared.Sift.Array.reduce` | Pendiente |
| `reduceRight.luau` | ModuleScript | — | — | 48 | `ReplicatedStorage.Shared.Sift.Array.reduceRight` | Pendiente |
| `removeIndex.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Shared.Sift.Array.removeIndex` | Pendiente |
| `removeIndices.luau` | ModuleScript | — | — | 41 | `ReplicatedStorage.Shared.Sift.Array.removeIndices` | Pendiente |
| `removeValue.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Array.removeValue` | Pendiente |
| `removeValues.luau` | ModuleScript | — | — | 33 | `ReplicatedStorage.Shared.Sift.Array.removeValues` | Pendiente |
| `reverse.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Array.reverse` | Pendiente |
| `set.luau` | ModuleScript | — | — | 39 | `ReplicatedStorage.Shared.Sift.Array.set` | Pendiente |
| `shift.luau` | ModuleScript | — | — | 33 | `ReplicatedStorage.Shared.Sift.Array.shift` | Pendiente |
| `shuffle.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.Sift.Array.shuffle` | Pendiente |
| `slice.luau` | ModuleScript | — | — | 43 | `ReplicatedStorage.Shared.Sift.Array.slice` | Pendiente |
| `some.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.Sift.Array.some` | Pendiente |
| `sort.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Array.sort` | Pendiente |
| `splice.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.Sift.Array.splice` | Pendiente |
| `toSet.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Array.toSet` | Pendiente |
| `unshift.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Array.unshift` | Pendiente |
| `update.luau` | ModuleScript | — | — | 68 | `ReplicatedStorage.Shared.Sift.Array.update` | Pendiente |
| `zip.luau` | ModuleScript | — | — | 47 | `ReplicatedStorage.Shared.Sift.Array.zip` | Pendiente |
| `zipAll.luau` | ModuleScript | — | — | 51 | `ReplicatedStorage.Shared.Sift.Array.zipAll` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Sift/Dictionary/</code> — 30 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `copy.luau` | ModuleScript | — | — | 20 | `ReplicatedStorage.Shared.Sift.Dictionary.copy` | Pendiente |
| `copyDeep.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Dictionary.copyDeep` | Pendiente |
| `count.luau` | ModuleScript | — | — | 42 | `ReplicatedStorage.Shared.Sift.Dictionary.count` | Pendiente |
| `entries.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Dictionary.entries` | Pendiente |
| `equals.luau` | ModuleScript | — | — | 64 | `ReplicatedStorage.Shared.Sift.Dictionary.equals` | Pendiente |
| `equalsDeep.luau` | ModuleScript | — | — | 64 | `ReplicatedStorage.Shared.Sift.Dictionary.equalsDeep` | Pendiente |
| `every.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.Sift.Dictionary.every` | Pendiente |
| `filter.luau` | ModuleScript | — | — | 41 | `ReplicatedStorage.Shared.Sift.Dictionary.filter` | Pendiente |
| `flatten.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.Sift.Dictionary.flatten` | Pendiente |
| `flip.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Dictionary.flip` | Pendiente |
| `freeze.luau` | ModuleScript | — | — | 31 | `ReplicatedStorage.Shared.Sift.Dictionary.freeze` | Pendiente |
| `freezeDeep.luau` | ModuleScript | — | — | 38 | `ReplicatedStorage.Shared.Sift.Dictionary.freezeDeep` | Pendiente |
| `fromArrays.luau` | ModuleScript | — | — | 31 | `ReplicatedStorage.Shared.Sift.Dictionary.fromArrays` | Pendiente |
| `fromEntries.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Dictionary.fromEntries` | Pendiente |
| `has.luau` | ModuleScript | — | — | 25 | `ReplicatedStorage.Shared.Sift.Dictionary.has` | Pendiente |
| `includes.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Dictionary.includes` | Pendiente |
| `init.luau` | ModuleScript | — | — | 51 | `ReplicatedStorage.Shared.Sift.Dictionary.init` | Pendiente |
| `keys.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Dictionary.keys` | Pendiente |
| `map.luau` | ModuleScript | — | — | 40 | `ReplicatedStorage.Shared.Sift.Dictionary.map` | Pendiente |
| `merge.luau` | ModuleScript | — | — | 45 | `ReplicatedStorage.Shared.Sift.Dictionary.merge` | Pendiente |
| `mergeDeep.luau` | ModuleScript | — | — | 56 | `ReplicatedStorage.Shared.Sift.Dictionary.mergeDeep` | Pendiente |
| `removeKey.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Dictionary.removeKey` | Pendiente |
| `removeKeys.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Dictionary.removeKeys` | Pendiente |
| `removeValue.luau` | ModuleScript | — | — | 31 | `ReplicatedStorage.Shared.Sift.Dictionary.removeValue` | Pendiente |
| `removeValues.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Shared.Sift.Dictionary.removeValues` | Pendiente |
| `set.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Dictionary.set` | Pendiente |
| `some.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.Sift.Dictionary.some` | Pendiente |
| `update.luau` | ModuleScript | — | — | 60 | `ReplicatedStorage.Shared.Sift.Dictionary.update` | Pendiente |
| `values.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Dictionary.values` | Pendiente |
| `withKeys.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Dictionary.withKeys` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Sift/Set/</code> — 16 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `add.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Set.add` | Pendiente |
| `copy.luau` | ModuleScript | — | — | 21 | `ReplicatedStorage.Shared.Sift.Set.copy` | Pendiente |
| `count.luau` | ModuleScript | — | — | 42 | `ReplicatedStorage.Shared.Sift.Set.count` | Pendiente |
| `delete.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.Sift.Set.delete` | Pendiente |
| `difference.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.Sift.Set.difference` | Pendiente |
| `differenceSymmetric.luau` | ModuleScript | — | — | 41 | `ReplicatedStorage.Shared.Sift.Set.differenceSymmetric` | Pendiente |
| `filter.luau` | ModuleScript | — | — | 41 | `ReplicatedStorage.Shared.Sift.Set.filter` | Pendiente |
| `fromArray.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Set.fromArray` | Pendiente |
| `has.luau` | ModuleScript | — | — | 22 | `ReplicatedStorage.Shared.Sift.Set.has` | Pendiente |
| `init.luau` | ModuleScript | — | — | 38 | `ReplicatedStorage.Shared.Sift.Set.init` | Pendiente |
| `intersection.luau` | ModuleScript | — | — | 46 | `ReplicatedStorage.Shared.Sift.Set.intersection` | Pendiente |
| `isSubset.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Set.isSubset` | Pendiente |
| `isSuperset.luau` | ModuleScript | — | — | 25 | `ReplicatedStorage.Shared.Sift.Set.isSuperset` | Pendiente |
| `map.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.Sift.Set.map` | Pendiente |
| `merge.luau` | ModuleScript | — | — | 38 | `ReplicatedStorage.Shared.Sift.Set.merge` | Pendiente |
| `toArray.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Set.toArray` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Sift/Util/</code> — 4 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `equalObjects.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Util.equalObjects` | Pendiente |
| `func.luau` | ModuleScript | — | — | 15 | `ReplicatedStorage.Shared.Sift.Util.func` | Pendiente |
| `init.luau` | ModuleScript | — | — | 5 | `ReplicatedStorage.Shared.Sift.Util.init` | Pendiente |
| `isEmpty.luau` | ModuleScript | — | — | 26 | `ReplicatedStorage.Shared.Sift.Util.isEmpty` | Pendiente |

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
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/machines/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `roulettePrizes.luau` | ModuleScript | — | — | 104 | `ReplicatedStorage.Shared.machines.roulettePrizes` | Pendiente |
| `rouletteUtil.luau` | ModuleScript | — | — | 12 | `ReplicatedStorage.Shared.machines.rouletteUtil` | Pendiente |

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
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/</code> — 20 archivo(s) — 17/20 leídos</summary>

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
| `WalkieServer.server.luau` | Script | Server | yes | 148 | `ServerScriptService.ServerScripts.WalkieServer.server` | Pendiente |
| `WorldManager.server.luau` | Script | Server | yes | 228 | `ServerScriptService.ServerScripts.WorldManager.server` | Analizado |
| `WorldsBrowser.server.luau` | Script | Server | yes | 140 | `ServerScriptService.ServerScripts.WorldsBrowser.server` | Analizado |
| `collisions.server.luau` | Script | Server | yes | 37 | `ServerScriptService.ServerScripts.collisions.server` | Pendiente |
| `fireExcept.luau` | ModuleScript | — | — | 11 | `ServerScriptService.ServerScripts.fireExcept` | Pendiente |
| `playerManager.server.luau` | Script | — | yes | 208 | `ServerScriptService.ServerScripts.playerManager.server` | Analizado |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/AnimationSystem/</code> — 2 archivo(s) — 1/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `AnimationManager.luau` | ModuleScript | — | — | 73 | `ServerScriptService.ServerScripts.AnimationSystem.AnimationManager` | Pendiente |
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
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/Ragdoll/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `DisableJointsWhenFalling.server.luau` | Script | — | yes | 63 | `ServerScriptService.ServerScripts.Ragdoll.DisableJointsWhenFalling.server` | Pendiente |
| `PhysicallySimulatedUpperBody.server.luau` | Script | — | yes | 47 | `ServerScriptService.ServerScripts.Ragdoll.PhysicallySimulatedUpperBody.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/Referrals/</code> — 2 archivo(s) — 1/2 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `ReferralCommands.server.luau` | Script | — | yes | 333 | `ServerScriptService.ServerScripts.Referrals.ReferralCommands.server` | Pendiente |
| `ReferralMain.server.luau` | Script | — | yes | 233 | `ServerScriptService.ServerScripts.Referrals.ReferralMain.server` | Analizado (en parte) |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/ToolModelGenerator/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Settings.luau` | ModuleScript | — | — | 32 | `ServerScriptService.ServerScripts.ToolModelGenerator.Settings` | Pendiente |
| `init.server.luau` | Script | Server | yes | 170 | `ServerScriptService.ServerScripts.ToolModelGenerator.init.server` | Pendiente |

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
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/interactable/</code> — 21 archivo(s) — 4/21 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `BarraBartender.server.luau` | Script | Server | yes | 24 | `ServerScriptService.ServerScripts.interactable.BarraBartender.server` | Pendiente |
| `Bath.server.luau` | Script | Server | yes | 41 | `ServerScriptService.ServerScripts.interactable.Bath.server` | Pendiente |
| `Bin.server.luau` | Script | Server | yes | 17 | `ServerScriptService.ServerScripts.interactable.Bin.server` | Analizado |
| `ClassicDoor.server.luau` | Script | Server | yes | 151 | `ServerScriptService.ServerScripts.interactable.ClassicDoor.server` | Pendiente |
| `CuadrosPaint.server.luau` | Script | Server | yes | 11 | `ServerScriptService.ServerScripts.interactable.CuadrosPaint.server` | Analizado |
| `DiscoBall.server.luau` | Script | Server | yes | 7 | `ServerScriptService.ServerScripts.interactable.DiscoBall.server` | Pendiente |
| `Display.server.luau` | Script | Server | yes | 31 | `ServerScriptService.ServerScripts.interactable.Display.server` | Analizado |
| `Fridge.server.luau` | Script | Server | yes | 137 | `ServerScriptService.ServerScripts.interactable.Fridge.server` | Pendiente |
| `Lamp.server.luau` | Script | Server | yes | 116 | `ServerScriptService.ServerScripts.interactable.Lamp.server` | Pendiente |
| `MusicPlayer.server.luau` | Script | Server | yes | 17 | `ServerScriptService.ServerScripts.interactable.MusicPlayer.server` | Analizado |
| `NpcDialog.server.luau` | Script | Server | yes | 27 | `ServerScriptService.ServerScripts.interactable.NpcDialog.server` | Pendiente |
| `Paint.server.luau` | Script | Server | yes | 19 | `ServerScriptService.ServerScripts.interactable.Paint.server` | Pendiente |
| `Pee.server.luau` | Script | Server | yes | 222 | `ServerScriptService.ServerScripts.interactable.Pee.server` | Pendiente |
| `Seat.server.luau` | Script | Server | yes | 27 | `ServerScriptService.ServerScripts.interactable.Seat.server` | Pendiente |
| `Shower.server.luau` | Script | Server | yes | 68 | `ServerScriptService.ServerScripts.interactable.Shower.server` | Pendiente |
| `SmokeMachine.server.luau` | Script | Server | yes | 7 | `ServerScriptService.ServerScripts.interactable.SmokeMachine.server` | Pendiente |
| `Tijeras.server.luau` | Script | Server | yes | 153 | `ServerScriptService.ServerScripts.interactable.Tijeras.server` | Pendiente |
| `Toilet.server.luau` | Script | Server | yes | 98 | `ServerScriptService.ServerScripts.interactable.Toilet.server` | Pendiente |
| `Treadmill.server.luau` | Script | Server | yes | 64 | `ServerScriptService.ServerScripts.interactable.Treadmill.server` | Pendiente |
| `Washbasin.server.luau` | Script | Server | yes | 49 | `ServerScriptService.ServerScripts.interactable.Washbasin.server` | Pendiente |
| `Weight.server.luau` | Script | Server | yes | 38 | `ServerScriptService.ServerScripts.interactable.Weight.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/interactable/Bed/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Bed.luau` | ModuleScript | — | — | 186 | `ServerScriptService.ServerScripts.interactable.Bed.Bed` | Pendiente |
| `init.server.luau` | Script | Server | yes | 20 | `ServerScriptService.ServerScripts.interactable.Bed.init.server` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/interactable/DoubleBed/</code> — 2 archivo(s)</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `DoubleBed.luau` | ModuleScript | — | — | 255 | `ServerScriptService.ServerScripts.interactable.DoubleBed.DoubleBed` | Pendiente |
| `init.server.luau` | Script | Server | yes | 23 | `ServerScriptService.ServerScripts.interactable.DoubleBed.init.server` | Pendiente |

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
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/machines/</code> — 10 archivo(s) — 3/10 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Basketball.luau` | ModuleScript | — | — | 92 | `ServerScriptService.ServerScripts.machines.Basketball` | Pendiente |
| `Machine.luau` | ModuleScript | — | — | 86 | `ServerScriptService.ServerScripts.machines.Machine` | Analizado (en parte) |
| `MachineFactory.luau` | ModuleScript | — | — | 26 | `ServerScriptService.ServerScripts.machines.MachineFactory` | Pendiente |
| `Pong.luau` | ModuleScript | — | — | 388 | `ServerScriptService.ServerScripts.machines.Pong` | Pendiente |
| `PopTheLock.luau` | ModuleScript | — | — | 55 | `ServerScriptService.ServerScripts.machines.PopTheLock` | Analizado (en parte) |
| `Roulette.luau` | ModuleScript | — | — | 177 | `ServerScriptService.ServerScripts.machines.Roulette` | Pendiente |
| `Stacker.luau` | ModuleScript | — | — | 50 | `ServerScriptService.ServerScripts.machines.Stacker` | Pendiente |
| `ToyMachine.luau` | ModuleScript | — | — | 158 | `ServerScriptService.ServerScripts.machines.ToyMachine` | Pendiente |
| `init.server.luau` | Script | Server | yes | 186 | `ServerScriptService.ServerScripts.machines.init.server` | Analizado (en parte) |
| `oldPong.luau` | ModuleScript | — | — | 114 | `ServerScriptService.ServerScripts.machines.oldPong` | Pendiente |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/stats/</code> — 3 archivo(s) — 1/3 leídos</summary>

| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |
|---|---|---|---|---|---|---|
| `Stats.luau` | ModuleScript | — | — | 71 | `ServerScriptService.ServerScripts.stats.Stats` | Pendiente |
| `Timer.luau` | ModuleScript | — | — | 56 | `ServerScriptService.ServerScripts.stats.Timer` | Pendiente |
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
