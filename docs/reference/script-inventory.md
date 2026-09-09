---
sidebar_position: 1
title: Script inventory
---

# Script inventory

Every inspectable `.luau` file in the repository, with the DataModel path it occupies at
runtime and how far this documentation project has got with it.

Two columns exist because the filename lies about both:

* **Runtime path** — the template import moves everything out of
  `ServerStorage/TemplatesTesting/<Template>/<Service>/` into `<Service>`. See
  [Initialization](../architecture/initialization.md).
* **Context** — `RunContext` from the sibling `.meta.json` overrides the `.server.luau` /
  `.client.luau` suffix. A blank cell means no `RunContext` is set, so the suffix decides.

**Disabled** marks a script that ships switched off and is enabled later — by
`InitScripts` on the server, or by something outside this repository on the client
([BUG-CANDIDATE-007](../testing/verification-plan.md#bug-candidate-007)).

## Status

| Status | Meaning | Count |
|---|---|---|
| **Documented** | Read in full and annotated with Moonwave by this project | 2 |
| Analyzed | Read in full; its behaviour is described somewhere on this site | 27 |
| Analyzed (partly) | Read in the parts that mattered for a specific question | 3 |
| Pending | Not yet read | 520 |

**Total: 552 files, 80,441 lines.**

## Outside the templates

8 files, 583 lines, 5 read.

<details>
<summary><code>src/ReplicatedStorage/</code> — 2 file(s) — 2/2 read</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `InitAfterTemplates.luau` | ModuleScript | — | — | 43 | `ReplicatedStorage.InitAfterTemplates` | Analyzed |
| `PlayerInit.luau` | ModuleScript | — | — | 122 | `ReplicatedStorage.PlayerInit` | **Documented** |

</details>

<details>
<summary><code>src/ReplicatedStorage/Client/</code> — 1 file(s) — 1/1 read</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `visualsManager.server.luau` | Script | Client | yes | 49 | `ReplicatedStorage.Client.visualsManager.server` | Analyzed |

</details>

<details>
<summary><code>src/ServerScriptService/</code> — 2 file(s) — 2/2 read</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `ImportTemplates.server.luau` | Script | — | — | 144 | `ServerScriptService.ImportTemplates.server` | Analyzed |
| `InitScripts.server.luau` | Script | — | — | 56 | `ServerScriptService.InitScripts.server` | Analyzed |

</details>

<details>
<summary><code>src/ServerStorage/Templates/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `SettingsTemplate.luau` | ModuleScript | — | — | 28 | `ServerStorage.Templates.SettingsTemplate` | Pending |
| `TemplateJob.luau` | ModuleScript | — | — | 97 | `ServerStorage.Templates.TemplateJob` | Pending |
| `TemplateUIS.luau` | ModuleScript | — | — | 44 | `ServerStorage.Templates.TemplateUIS` | Pending |

</details>

## `Core` template

530 files, 76,176 lines, 21 read.

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/</code> — 6 file(s) — 2/6 read</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `BannersConfig.luau` | ModuleScript | — | — | 51 | `ReplicatedStorage.BannersConfig` | Pending |
| `DancesInfo.luau` | ModuleScript | — | — | 192 | `ReplicatedStorage.DancesInfo` | Pending |
| `GeneralConfiguration.luau` | ModuleScript | — | — | 40 | `ReplicatedStorage.GeneralConfiguration` | Analyzed |
| `HousesInfo.luau` | ModuleScript | — | — | 54 | `ReplicatedStorage.HousesInfo` | Analyzed |
| `ShopInfo.luau` | ModuleScript | — | — | 228 | `ReplicatedStorage.ShopInfo` | Pending |
| `ShopSettings.luau` | ModuleScript | — | — | 17 | `ReplicatedStorage.ShopSettings` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Notas_Creacion_Plato.server.luau` | Script | — | yes | 3 | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Notas_Creacion_Plato.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/Ballon/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `MainTool.client.luau` | LocalScript | — | yes | 78 | `ReplicatedStorage.Assets.Tools.Toys.Ballon.MainTool.client` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/BigPotion/MainTool/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.client.luau` | LocalScript | — | yes | 59 | `ReplicatedStorage.Assets.Tools.Toys.BigPotion.MainTool.init.client` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/Cannon/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `MainTool.client.luau` | LocalScript | — | yes | 203 | `ReplicatedStorage.Assets.Tools.Toys.Cannon.MainTool.client` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/GloveGun/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `MainTool.client.luau` | LocalScript | — | yes | 75 | `ReplicatedStorage.Assets.Tools.Toys.GloveGun.MainTool.client` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/MiniPotion/MainTool/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.client.luau` | LocalScript | — | yes | 62 | `ReplicatedStorage.Assets.Tools.Toys.MiniPotion.MainTool.init.client` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/SlimeBomb/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `LocalScript.client.luau` | LocalScript | — | yes | 29 | `ReplicatedStorage.Assets.Tools.Toys.SlimeBomb.LocalScript.client` | Pending |
| `Script.server.luau` | Script | — | yes | 347 | `ReplicatedStorage.Assets.Tools.Toys.SlimeBomb.Script.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/SpyJetpack/MainTool/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.client.luau` | LocalScript | — | yes | 304 | `ReplicatedStorage.Assets.Tools.Toys.SpyJetpack.MainTool.init.client` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/Walkie/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `LocalScript.client.luau` | LocalScript | — | yes | 93 | `ReplicatedStorage.Assets.Tools.Toys.Walkie.LocalScript.client` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/</code> — 19 file(s) — 2/19 read</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Attributes.luau` | ModuleScript | — | — | 89 | `ReplicatedStorage.Client.Attributes` | Pending |
| `BusquedaSettings.luau` | ModuleScript | — | — | 210 | `ReplicatedStorage.Client.BusquedaSettings` | Pending |
| `CreatePath.luau` | ModuleScript | — | — | 38 | `ReplicatedStorage.Client.CreatePath` | Pending |
| `DesingData.luau` | ModuleScript | — | — | 38 | `ReplicatedStorage.Client.DesingData` | Pending |
| `Disconnects.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Client.Disconnects` | Pending |
| `Event.luau` | ModuleScript | — | — | 44 | `ReplicatedStorage.Client.Event` | Pending |
| `InsertService.luau` | ModuleScript | — | — | 120 | `ReplicatedStorage.Client.InsertService` | Pending |
| `MainPS.server.luau` | Script | Client | yes | 94 | `ReplicatedStorage.Client.MainPS.server` | Analyzed |
| `Math.luau` | ModuleScript | — | — | 35 | `ReplicatedStorage.Client.Math` | Pending |
| `NametagMicClient.server.luau` | Script | Client | yes | 259 | `ReplicatedStorage.Client.NametagMicClient.server` | Pending |
| `PaintActives.luau` | ModuleScript | — | — | 3 | `ReplicatedStorage.Client.PaintActives` | Pending |
| `PlayerManager.server.luau` | Script | Client | yes | 59 | `ReplicatedStorage.Client.PlayerManager.server` | Analyzed |
| `Posicionamientos.luau` | ModuleScript | — | — | 246 | `ReplicatedStorage.Client.Posicionamientos` | Pending |
| `SettingsInfo.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Client.SettingsInfo` | Pending |
| `SurfacePlacer.server.luau` | Script | Client | yes | 63 | `ReplicatedStorage.Client.SurfacePlacer.server` | Pending |
| `UiManager.server.luau` | Script | Client | yes | 166 | `ReplicatedStorage.Client.UiManager.server` | Pending |
| `messagesManager.server.luau` | Script | Client | yes | 79 | `ReplicatedStorage.Client.messagesManager.server` | Pending |
| `stats.server.luau` | Script | Client | yes | 69 | `ReplicatedStorage.Client.stats.server` | Pending |
| `topbar.server.luau` | Script | Client | yes | 282 | `ReplicatedStorage.Client.topbar.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/Animator/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 166 | `ReplicatedStorage.Client.Animator.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/ClickDetectorHandler/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `MouseAction.luau` | ModuleScript | — | — | 9 | `ReplicatedStorage.Client.ClickDetectorHandler.MouseAction` | Pending |
| `init.server.luau` | Script | Client | yes | 176 | `ReplicatedStorage.Client.ClickDetectorHandler.init.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/CodeExamples/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `MicStatusExample.server.luau` | Script | Client | yes | 118 | `ReplicatedStorage.Client.CodeExamples.MicStatusExample.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/EconomySystem/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Collections.luau` | ModuleScript | — | — | 176 | `ReplicatedStorage.Client.EconomySystem.Collections` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/ProgressBarStarter/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `ProgressBarController.luau` | ModuleScript | — | — | 98 | `ReplicatedStorage.Client.ProgressBarStarter.ProgressBarController` | Pending |
| `init.server.luau` | Script | Client | yes | 2 | `ReplicatedStorage.Client.ProgressBarStarter.init.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/QuestClient/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `QuestClient.server.luau` | Script | Client | yes | 205 | `ReplicatedStorage.Client.QuestClient.QuestClient.server` | Pending |
| `QuestPickableClient.server.luau` | Script | Client | yes | 97 | `ReplicatedStorage.Client.QuestClient.QuestPickableClient.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/Ragdoll/</code> — 4 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `GettingUpAssist.server.luau` | Script | Client | yes | 32 | `ReplicatedStorage.Client.Ragdoll.GettingUpAssist.server` | Pending |
| `RToRagdoll.server.luau` | Script | Client | yes | 28 | `ReplicatedStorage.Client.Ragdoll.RToRagdoll.server` | Pending |
| `RagdollAtHighSpeeds.server.luau` | Script | Client | yes | 44 | `ReplicatedStorage.Client.Ragdoll.RagdollAtHighSpeeds.server` | Pending |
| `RagdollRemote.server.luau` | Script | Client | yes | 34 | `ReplicatedStorage.Client.Ragdoll.RagdollRemote.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/ReferralClient/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `ReferralClient.server.luau` | Script | Client | yes | 683 | `ReplicatedStorage.Client.ReferralClient.ReferralClient.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/RouletteUIStarter/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `RouletteUIController.luau` | ModuleScript | — | — | 224 | `ReplicatedStorage.Client.RouletteUIStarter.RouletteUIController` | Pending |
| `init.server.luau` | Script | Client | yes | 2 | `ReplicatedStorage.Client.RouletteUIStarter.init.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/WorldSystem/ClientDataManager/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Channel.luau` | ModuleScript | — | — | 16 | `ReplicatedStorage.Client.WorldSystem.ClientDataManager.Channel` | Pending |
| `init.client.luau` | LocalScript | — | yes | 10 | `ReplicatedStorage.Client.WorldSystem.ClientDataManager.init.client` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/WorldSystem/Modules/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `InventoryController.luau` | ModuleScript | — | — | 22 | `ReplicatedStorage.Client.WorldSystem.Modules.InventoryController` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/animation/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.server.luau` | Script | Client | yes | 109 | `ReplicatedStorage.Client.animation.init.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/cooking/</code> — 7 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Blender.luau` | ModuleScript | — | — | 28 | `ReplicatedStorage.Client.cooking.Blender` | Pending |
| `CookingInteractable.luau` | ModuleScript | — | — | 179 | `ReplicatedStorage.Client.cooking.CookingInteractable` | Pending |
| `CuttingBoard.luau` | ModuleScript | — | — | 195 | `ReplicatedStorage.Client.cooking.CuttingBoard` | Pending |
| `Microwave.luau` | ModuleScript | — | — | 124 | `ReplicatedStorage.Client.cooking.Microwave` | Pending |
| `Oven.luau` | ModuleScript | — | — | 63 | `ReplicatedStorage.Client.cooking.Oven` | Pending |
| `Stove.luau` | ModuleScript | — | — | 35 | `ReplicatedStorage.Client.cooking.Stove` | Pending |
| `init.server.luau` | Script | Client | yes | 20 | `ReplicatedStorage.Client.cooking.init.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/</code> — 34 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `BarraBartender.luau` | ModuleScript | — | — | 131 | `ReplicatedStorage.Client.interactable.BarraBartender` | Pending |
| `Bath.luau` | ModuleScript | — | — | 72 | `ReplicatedStorage.Client.interactable.Bath` | Pending |
| `Bed.luau` | ModuleScript | — | — | 152 | `ReplicatedStorage.Client.interactable.Bed` | Pending |
| `Bin.luau` | ModuleScript | — | — | 35 | `ReplicatedStorage.Client.interactable.Bin` | Pending |
| `ButtonVipMoney.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Client.interactable.ButtonVipMoney` | Pending |
| `CajasWork.luau` | ModuleScript | — | — | 54 | `ReplicatedStorage.Client.interactable.CajasWork` | Pending |
| `Chair.luau` | ModuleScript | — | — | 57 | `ReplicatedStorage.Client.interactable.Chair` | Pending |
| `ClassicDoor.luau` | ModuleScript | — | — | 48 | `ReplicatedStorage.Client.interactable.ClassicDoor` | Pending |
| `Computer.luau` | ModuleScript | — | — | 19 | `ReplicatedStorage.Client.interactable.Computer` | Pending |
| `CuadrosPaint.luau` | ModuleScript | — | — | 147 | `ReplicatedStorage.Client.interactable.CuadrosPaint` | Pending |
| `DoorSalaKaraoke.luau` | ModuleScript | — | — | 113 | `ReplicatedStorage.Client.interactable.DoorSalaKaraoke` | Pending |
| `DoubleBed.luau` | ModuleScript | — | — | 252 | `ReplicatedStorage.Client.interactable.DoubleBed` | Pending |
| `Fridge.luau` | ModuleScript | — | — | 719 | `ReplicatedStorage.Client.interactable.Fridge` | Pending |
| `IdleToggle.luau` | ModuleScript | — | — | 56 | `ReplicatedStorage.Client.interactable.IdleToggle` | Pending |
| `Interruptor.luau` | ModuleScript | — | — | 119 | `ReplicatedStorage.Client.interactable.Interruptor` | Pending |
| `Lamp.luau` | ModuleScript | — | — | 85 | `ReplicatedStorage.Client.interactable.Lamp` | Pending |
| `MusicPlayer.luau` | ModuleScript | — | — | 67 | `ReplicatedStorage.Client.interactable.MusicPlayer` | Pending |
| `NightClub.luau` | ModuleScript | — | — | 76 | `ReplicatedStorage.Client.interactable.NightClub` | Pending |
| `NpcDialog.luau` | ModuleScript | — | — | 228 | `ReplicatedStorage.Client.interactable.NpcDialog` | Pending |
| `Paint.luau` | ModuleScript | — | — | 251 | `ReplicatedStorage.Client.interactable.Paint` | Pending |
| `Pee.luau` | ModuleScript | — | — | 79 | `ReplicatedStorage.Client.interactable.Pee` | Pending |
| `Piano.luau` | ModuleScript | — | — | 67 | `ReplicatedStorage.Client.interactable.Piano` | Pending |
| `PlaceTool.luau` | ModuleScript | — | — | 59 | `ReplicatedStorage.Client.interactable.PlaceTool` | Pending |
| `PurchaseGamepass.luau` | ModuleScript | — | — | 60 | `ReplicatedStorage.Client.interactable.PurchaseGamepass` | Pending |
| `QuestPickable.luau` | ModuleScript | — | — | 89 | `ReplicatedStorage.Client.interactable.QuestPickable` | Pending |
| `Shower.luau` | ModuleScript | — | — | 104 | `ReplicatedStorage.Client.interactable.Shower` | Pending |
| `SmokeMachine.luau` | ModuleScript | — | — | 74 | `ReplicatedStorage.Client.interactable.SmokeMachine` | Pending |
| `Stores.luau` | ModuleScript | — | — | 57 | `ReplicatedStorage.Client.interactable.Stores` | Pending |
| `Toilet.luau` | ModuleScript | — | — | 45 | `ReplicatedStorage.Client.interactable.Toilet` | Pending |
| `ToolInteractable.luau` | ModuleScript | — | — | 241 | `ReplicatedStorage.Client.interactable.ToolInteractable` | Pending |
| `Washbasin.luau` | ModuleScript | — | — | 57 | `ReplicatedStorage.Client.interactable.Washbasin` | Pending |
| `Weight.luau` | ModuleScript | — | — | 54 | `ReplicatedStorage.Client.interactable.Weight` | Pending |
| `init.server.luau` | Script | Client | yes | 20 | `ReplicatedStorage.Client.interactable.init.server` | Pending |
| `test.luau` | ModuleScript | — | — | 54 | `ReplicatedStorage.Client.interactable.test` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/DiscoBall/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Laser.server.luau` | Script | Client | yes | 86 | `ReplicatedStorage.Client.interactable.DiscoBall.Laser.server` | Pending |
| `init.luau` | ModuleScript | — | — | 157 | `ReplicatedStorage.Client.interactable.DiscoBall.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Display/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `VideoPlayer.luau` | ModuleScript | — | — | 88 | `ReplicatedStorage.Client.interactable.Display.VideoPlayer` | Pending |
| `Videos.luau` | ModuleScript | — | — | 13 | `ReplicatedStorage.Client.interactable.Display.Videos` | Pending |
| `init.luau` | ModuleScript | — | — | 167 | `ReplicatedStorage.Client.interactable.Display.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 438 | `ReplicatedStorage.Client.interactable.Interactable.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/ActionWheel/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 95 | `ReplicatedStorage.Client.interactable.Interactable.ActionWheel.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/ActionWheel/Page/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 273 | `ReplicatedStorage.Client.interactable.Interactable.ActionWheel.Page.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/ActionWheel/Page/UI/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 121 | `ReplicatedStorage.Client.interactable.Interactable.ActionWheel.Page.UI.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/CustomPrompt/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 128 | `ReplicatedStorage.Client.interactable.Interactable.CustomPrompt.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Player/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Tijeras.luau` | ModuleScript | — | — | 181 | `ReplicatedStorage.Client.interactable.Player.Tijeras` | Pending |
| `init.luau` | ModuleScript | — | — | 78 | `ReplicatedStorage.Client.interactable.Player.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Treadmill/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 85 | `ReplicatedStorage.Client.interactable.Treadmill.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/inventory/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `InventoryWheel.luau` | ModuleScript | — | — | 343 | `ReplicatedStorage.Client.inventory.InventoryWheel` | Pending |
| `init.server.luau` | Script | Client | yes | 334 | `ReplicatedStorage.Client.inventory.init.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/inventory/InventoryList/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 65 | `ReplicatedStorage.Client.inventory.InventoryList.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/inventory/InventoryList/InventoryItem/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 170 | `ReplicatedStorage.Client.inventory.InventoryList.InventoryItem.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/</code> — 5 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `MachineFactory.luau` | ModuleScript | — | — | 26 | `ReplicatedStorage.Client.machines.MachineFactory` | Pending |
| `MachinePrompt.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Client.machines.MachinePrompt` | Pending |
| `Pong.luau` | ModuleScript | — | — | 184 | `ReplicatedStorage.Client.machines.Pong` | Pending |
| `init.server.luau` | Script | Client | yes | 133 | `ReplicatedStorage.Client.machines.init.server` | Pending |
| `machineUtil.luau` | ModuleScript | — | — | 70 | `ReplicatedStorage.Client.machines.machineUtil` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/Basketball/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Prediction.luau` | ModuleScript | — | — | 68 | `ReplicatedStorage.Client.machines.Basketball.Prediction` | Pending |
| `init.luau` | ModuleScript | — | — | 241 | `ReplicatedStorage.Client.machines.Basketball.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/PopTheLock/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Controller.luau` | ModuleScript | — | — | 177 | `ReplicatedStorage.Client.machines.PopTheLock.Controller` | Pending |
| `init.luau` | ModuleScript | — | — | 130 | `ReplicatedStorage.Client.machines.PopTheLock.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/Roulette/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 163 | `ReplicatedStorage.Client.machines.Roulette.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/Stacker/</code> — 5 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Board.luau` | ModuleScript | — | — | 197 | `ReplicatedStorage.Client.machines.Stacker.Board` | Pending |
| `Controller.luau` | ModuleScript | — | — | 225 | `ReplicatedStorage.Client.machines.Stacker.Controller` | Pending |
| `Figure.luau` | ModuleScript | — | — | 71 | `ReplicatedStorage.Client.machines.Stacker.Figure` | Pending |
| `idle.luau` | ModuleScript | — | — | 62 | `ReplicatedStorage.Client.machines.Stacker.idle` | Pending |
| `init.luau` | ModuleScript | — | — | 98 | `ReplicatedStorage.Client.machines.Stacker.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/ToyMachine/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 161 | `ReplicatedStorage.Client.machines.ToyMachine.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/notificationsManager/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.server.luau` | Script | Client | yes | 223 | `ReplicatedStorage.Client.notificationsManager.init.server` | Pending |
| `statsNotifications.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Client.notificationsManager.statsNotifications` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `debug.luau` | ModuleScript | — | — | 160 | `ReplicatedStorage.Kinetic.debug` | Pending |
| `init.luau` | ModuleScript | — | — | 338 | `ReplicatedStorage.Kinetic.init` | Pending |
| `types.luau` | ModuleScript | — | — | 181 | `ReplicatedStorage.Kinetic.types` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/animatable/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `adapters.luau` | ModuleScript | — | — | 169 | `ReplicatedStorage.Kinetic.animatable.adapters` | Pending |
| `color.luau` | ModuleScript | — | — | 87 | `ReplicatedStorage.Kinetic.animatable.color` | Pending |
| `init.luau` | ModuleScript | — | — | 77 | `ReplicatedStorage.Kinetic.animatable.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/constants/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `configs.luau` | ModuleScript | — | — | 22 | `ReplicatedStorage.Kinetic.constants.configs` | Pending |
| `easings.luau` | ModuleScript | — | — | 150 | `ReplicatedStorage.Kinetic.constants.easings` | Pending |
| `init.luau` | ModuleScript | — | — | 13 | `ReplicatedStorage.Kinetic.constants.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/core/</code> — 5 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `AnimationConfig.luau` | ModuleScript | — | — | 92 | `ReplicatedStorage.Kinetic.core.AnimationConfig` | Pending |
| `Controller.luau` | ModuleScript | — | — | 835 | `ReplicatedStorage.Kinetic.core.Controller` | Pending |
| `FrameLoop.luau` | ModuleScript | — | — | 146 | `ReplicatedStorage.Kinetic.core.FrameLoop` | Pending |
| `Interpolation.luau` | ModuleScript | — | — | 224 | `ReplicatedStorage.Kinetic.core.Interpolation` | Pending |
| `SpringValue.luau` | ModuleScript | — | — | 758 | `ReplicatedStorage.Kinetic.core.SpringValue` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/orchestration/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Transition.luau` | ModuleScript | — | — | 305 | `ReplicatedStorage.Kinetic.orchestration.Transition` | Pending |
| `init.luau` | ModuleScript | — | — | 130 | `ReplicatedStorage.Kinetic.orchestration.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/targets/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `instance.luau` | ModuleScript | — | — | 183 | `ReplicatedStorage.Kinetic.targets.instance` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Kinetic/util/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Completion.luau` | ModuleScript | — | — | 145 | `ReplicatedStorage.Kinetic.util.Completion` | Pending |
| `Signal.luau` | ModuleScript | — | — | 78 | `ReplicatedStorage.Kinetic.util.Signal` | Pending |
| `timeGuard.luau` | ModuleScript | — | — | 44 | `ReplicatedStorage.Kinetic.util.timeGuard` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/</code> — 44 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `AddValues.luau` | ModuleScript | — | — | 59 | `ReplicatedStorage.Shared.AddValues` | Pending |
| `AdjustBoxFrame.luau` | ModuleScript | — | — | 131 | `ReplicatedStorage.Shared.AdjustBoxFrame` | Pending |
| `AnimationButtons.luau` | ModuleScript | — | — | 299 | `ReplicatedStorage.Shared.AnimationButtons` | Pending |
| `AreaSystem.luau` | ModuleScript | — | — | 148 | `ReplicatedStorage.Shared.AreaSystem` | Pending |
| `AssetsToPreload.luau` | ModuleScript | — | — | 14 | `ReplicatedStorage.Shared.AssetsToPreload` | Pending |
| `BreakDown.luau` | ModuleScript | — | — | 86 | `ReplicatedStorage.Shared.BreakDown` | Pending |
| `ButtonMotion.luau` | ModuleScript | — | — | 420 | `ReplicatedStorage.Shared.ButtonMotion` | Pending |
| `CardSlots.luau` | ModuleScript | — | — | 477 | `ReplicatedStorage.Shared.CardSlots` | Pending |
| `Carousel.luau` | ModuleScript | — | — | 354 | `ReplicatedStorage.Shared.Carousel` | Pending |
| `CircularBuffer.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.CircularBuffer` | Pending |
| `Clock.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Clock` | Pending |
| `CollisionModule.luau` | ModuleScript | — | — | 63 | `ReplicatedStorage.Shared.CollisionModule` | Pending |
| `Commands.luau` | ModuleScript | — | — | 127 | `ReplicatedStorage.Shared.Commands` | Pending |
| `GuiScaleManager.luau` | ModuleScript | — | — | 106 | `ReplicatedStorage.Shared.GuiScaleManager` | Pending |
| `InfoCoins.luau` | ModuleScript | — | — | 10 | `ReplicatedStorage.Shared.InfoCoins` | Pending |
| `InputPlayer.luau` | ModuleScript | — | — | 85 | `ReplicatedStorage.Shared.InputPlayer` | Pending |
| `KeyGenerator.luau` | ModuleScript | — | — | 28 | `ReplicatedStorage.Shared.KeyGenerator` | Pending |
| `MovedScrollButton.luau` | ModuleScript | — | — | 222 | `ReplicatedStorage.Shared.MovedScrollButton` | Pending |
| `MovingPlayers.luau` | ModuleScript | — | — | 98 | `ReplicatedStorage.Shared.MovingPlayers` | Pending |
| `NetworkTimer.luau` | ModuleScript | — | — | 41 | `ReplicatedStorage.Shared.NetworkTimer` | Pending |
| `ObjectCache.luau` | ModuleScript | — | — | 174 | `ReplicatedStorage.Shared.ObjectCache` | Pending |
| `PrettyPrint.luau` | ModuleScript | — | — | 35 | `ReplicatedStorage.Shared.PrettyPrint` | Pending |
| `Running.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.Running` | Pending |
| `RutaCreate.luau` | ModuleScript | — | — | 135 | `ReplicatedStorage.Shared.RutaCreate` | Pending |
| `SellHousePrompt.luau` | ModuleScript | — | — | 289 | `ReplicatedStorage.Shared.SellHousePrompt` | Pending |
| `ShopHighlight.luau` | ModuleScript | — | — | 377 | `ReplicatedStorage.Shared.ShopHighlight` | Pending |
| `Signal.luau` | ModuleScript | — | — | 432 | `ReplicatedStorage.Shared.Signal` | Pending |
| `SignalsGame.luau` | ModuleScript | — | — | 56 | `ReplicatedStorage.Shared.SignalsGame` | Pending |
| `SizeManager.luau` | ModuleScript | — | — | 165 | `ReplicatedStorage.Shared.SizeManager` | Pending |
| `SmoothShiftLock.luau` | ModuleScript | — | — | 232 | `ReplicatedStorage.Shared.SmoothShiftLock` | Pending |
| `SoundManager.luau` | ModuleScript | — | — | 230 | `ReplicatedStorage.Shared.SoundManager` | Pending |
| `Spring.luau` | ModuleScript | — | — | 31 | `ReplicatedStorage.Shared.Spring` | Pending |
| `ToolUseManagge.luau` | ModuleScript | — | — | 109 | `ReplicatedStorage.Shared.ToolUseManagge` | Pending |
| `Trove.luau` | ModuleScript | — | — | 612 | `ReplicatedStorage.Shared.Trove` | Pending |
| `UpdatingCountText.luau` | ModuleScript | — | — | 136 | `ReplicatedStorage.Shared.UpdatingCountText` | Pending |
| `VoiceModulator.luau` | ModuleScript | — | — | 71 | `ReplicatedStorage.Shared.VoiceModulator` | Pending |
| `attach.luau` | ModuleScript | — | — | 7 | `ReplicatedStorage.Shared.attach` | Pending |
| `basketUtil.luau` | ModuleScript | — | — | 67 | `ReplicatedStorage.Shared.basketUtil` | Pending |
| `bindToTag.luau` | ModuleScript | — | — | 24 | `ReplicatedStorage.Shared.bindToTag` | Pending |
| `lerp.luau` | ModuleScript | — | — | 5 | `ReplicatedStorage.Shared.lerp` | Pending |
| `makeClientPart.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.makeClientPart` | Pending |
| `promptText.luau` | ModuleScript | — | — | 53 | `ReplicatedStorage.Shared.promptText` | Pending |
| `showExitButton.luau` | ModuleScript | — | — | 33 | `ReplicatedStorage.Shared.showExitButton` | Pending |
| `textScaler.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.textScaler` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/BartenderSystem/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 234 | `ReplicatedStorage.Shared.BartenderSystem.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/BartenderSystem/Instance/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `ActionsBartender.luau` | ModuleScript | — | — | 61 | `ReplicatedStorage.Shared.BartenderSystem.Instance.ActionsBartender` | Pending |
| `init.luau` | ModuleScript | — | — | 549 | `ReplicatedStorage.Shared.BartenderSystem.Instance.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/ComprasTablero/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Settings.luau` | ModuleScript | — | — | 28 | `ReplicatedStorage.Shared.ComprasTablero.Settings` | Pending |
| `init.luau` | ModuleScript | — | — | 378 | `ReplicatedStorage.Shared.ComprasTablero.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Cooldown/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `CooldownManager.luau` | ModuleScript | — | — | 76 | `ReplicatedStorage.Shared.Cooldown.CooldownManager` | Pending |
| `CooldownShared.luau` | ModuleScript | — | — | 55 | `ReplicatedStorage.Shared.Cooldown.CooldownShared` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/DialogModule/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 405 | `ReplicatedStorage.Shared.DialogModule.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Dialogs/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `FrameShop.luau` | ModuleScript | — | — | 60 | `ReplicatedStorage.Shared.Dialogs.FrameShop` | Pending |
| `KaraokeRoomRent.luau` | ModuleScript | — | — | 51 | `ReplicatedStorage.Shared.Dialogs.KaraokeRoomRent` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/FastCastRedux/</code> — 6 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `ActiveCast.luau` | ModuleScript | — | — | 770 | `ReplicatedStorage.Shared.FastCastRedux.ActiveCast` | Pending |
| `Signal.luau` | ModuleScript | — | — | 153 | `ReplicatedStorage.Shared.FastCastRedux.Signal` | Pending |
| `Table.luau` | ModuleScript | — | — | 108 | `ReplicatedStorage.Shared.FastCastRedux.Table` | Pending |
| `TypeDefinitions.luau` | ModuleScript | — | — | 89 | `ReplicatedStorage.Shared.FastCastRedux.TypeDefinitions` | Pending |
| `TypeMarshaller.luau` | ModuleScript | — | — | 21 | `ReplicatedStorage.Shared.FastCastRedux.TypeMarshaller` | Pending |
| `init.luau` | ModuleScript | — | — | 145 | `ReplicatedStorage.Shared.FastCastRedux.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/GuideService/</code> — 4 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Disconnects.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.GuideService.Disconnects` | Pending |
| `QuitarEspacios.luau` | ModuleScript | — | — | 5 | `ReplicatedStorage.Shared.GuideService.QuitarEspacios` | Pending |
| `READ ME.client.luau` | LocalScript | — | yes | 121 | `ReplicatedStorage.Shared.GuideService.READ ME.client` | Pending |
| `init.luau` | ModuleScript | — | — | 89 | `ReplicatedStorage.Shared.GuideService.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/GuideService/PageController/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 92 | `ReplicatedStorage.Shared.GuideService.PageController.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/GuideService/PageController/InterfaceController/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 61 | `ReplicatedStorage.Shared.GuideService.PageController.InterfaceController.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/GuideService/PageController/VerificacionPages/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Changed.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Shared.GuideService.PageController.VerificacionPages.Changed` | Pending |
| `init.luau` | ModuleScript | — | — | 65 | `ReplicatedStorage.Shared.GuideService.PageController.VerificacionPages.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/GuideService/Server/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Rewards.luau` | ModuleScript | — | — | 5 | `ReplicatedStorage.Shared.GuideService.Server.Rewards` | Pending |
| `init.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.GuideService.Server.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/</code> — 6 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Attribute.luau` | ModuleScript | — | — | 35 | `ReplicatedStorage.Shared.Icon.Attribute` | Pending |
| `Reference.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Icon.Reference` | Pending |
| `Types.luau` | ModuleScript | — | — | 477 | `ReplicatedStorage.Shared.Icon.Types` | Pending |
| `Utility.luau` | ModuleScript | — | — | 462 | `ReplicatedStorage.Shared.Icon.Utility` | Pending |
| `VERSION.luau` | ModuleScript | — | — | 51 | `ReplicatedStorage.Shared.Icon.VERSION` | Pending |
| `init.luau` | ModuleScript | — | — | 1253 | `ReplicatedStorage.Shared.Icon.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/Elements/</code> — 8 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Caption.luau` | ModuleScript | — | — | 316 | `ReplicatedStorage.Shared.Icon.Elements.Caption` | Pending |
| `Container.luau` | ModuleScript | — | — | 215 | `ReplicatedStorage.Shared.Icon.Elements.Container` | Pending |
| `Dropdown.luau` | ModuleScript | — | — | 315 | `ReplicatedStorage.Shared.Icon.Elements.Dropdown` | Pending |
| `Indicator.luau` | ModuleScript | — | — | 91 | `ReplicatedStorage.Shared.Icon.Elements.Indicator` | Pending |
| `Menu.luau` | ModuleScript | — | — | 180 | `ReplicatedStorage.Shared.Icon.Elements.Menu` | Pending |
| `Notice.luau` | ModuleScript | — | — | 113 | `ReplicatedStorage.Shared.Icon.Elements.Notice` | Pending |
| `Selection.luau` | ModuleScript | — | — | 49 | `ReplicatedStorage.Shared.Icon.Elements.Selection` | Pending |
| `Widget.luau` | ModuleScript | — | — | 437 | `ReplicatedStorage.Shared.Icon.Elements.Widget` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/Features/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Gamepad.luau` | ModuleScript | — | — | 201 | `ReplicatedStorage.Shared.Icon.Features.Gamepad` | Pending |
| `Overflow.luau` | ModuleScript | — | — | 360 | `ReplicatedStorage.Shared.Icon.Features.Overflow` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/Features/Themes/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Classic.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Icon.Features.Themes.Classic` | Pending |
| `Default.luau` | ModuleScript | — | — | 75 | `ReplicatedStorage.Shared.Icon.Features.Themes.Default` | Pending |
| `init.luau` | ModuleScript | — | — | 353 | `ReplicatedStorage.Shared.Icon.Features.Themes.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/Packages/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `GoodSignal.luau` | ModuleScript | — | — | 182 | `ReplicatedStorage.Shared.Icon.Packages.GoodSignal` | Pending |
| `Janitor.luau` | ModuleScript | — | — | 322 | `ReplicatedStorage.Shared.Icon.Packages.Janitor` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/JobSystem/</code> — 4 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Bartender.luau` | ModuleScript | — | — | 447 | `ReplicatedStorage.Shared.JobSystem.Bartender` | Pending |
| `ConditionsUses.luau` | ModuleScript | — | — | 12 | `ReplicatedStorage.Shared.JobSystem.ConditionsUses` | Pending |
| `LimpiarPiso.luau` | ModuleScript | — | — | 246 | `ReplicatedStorage.Shared.JobSystem.LimpiarPiso` | Pending |
| `init.luau` | ModuleScript | — | — | 305 | `ReplicatedStorage.Shared.JobSystem.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/JobSystem/ButtonMoney/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 245 | `ReplicatedStorage.Shared.JobSystem.ButtonMoney.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/JobSystem/CajasTransport/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 261 | `ReplicatedStorage.Shared.JobSystem.CajasTransport.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Karaoke/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 177 | `ReplicatedStorage.Shared.Karaoke.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Karaoke/CrearCancion/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Attributes.luau` | ModuleScript | — | — | 83 | `ReplicatedStorage.Shared.Karaoke.CrearCancion.Attributes` | Pending |
| `Generos.luau` | ModuleScript | — | — | 25 | `ReplicatedStorage.Shared.Karaoke.CrearCancion.Generos` | Pending |
| `init.luau` | ModuleScript | — | — | 869 | `ReplicatedStorage.Shared.Karaoke.CrearCancion.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Karaoke/KaraokeTV/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `FunctActionsTV.luau` | ModuleScript | — | — | 223 | `ReplicatedStorage.Shared.Karaoke.KaraokeTV.FunctActionsTV` | Pending |
| `init.luau` | ModuleScript | — | — | 309 | `ReplicatedStorage.Shared.Karaoke.KaraokeTV.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Karaoke/KaraokeTV/TV/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 420 | `ReplicatedStorage.Shared.Karaoke.KaraokeTV.TV.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Karaoke/RevisarCanciones/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `AttributesRequerest.luau` | ModuleScript | — | — | 11 | `ReplicatedStorage.Shared.Karaoke.RevisarCanciones.AttributesRequerest` | Pending |
| `Script.server.luau` | Script | — | yes | 75 | `ReplicatedStorage.Shared.Karaoke.RevisarCanciones.Script.server` | Pending |
| `init.luau` | ModuleScript | — | — | 1111 | `ReplicatedStorage.Shared.Karaoke.RevisarCanciones.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Monetization/</code> — 4 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Beneficios.luau` | ModuleScript | — | — | 18 | `ReplicatedStorage.Shared.Monetization.Beneficios` | Pending |
| `MainModule.luau` | ModuleScript | — | — | 73 | `ReplicatedStorage.Shared.Monetization.MainModule` | Pending |
| `MarkAdded.luau` | ModuleScript | — | — | 40 | `ReplicatedStorage.Shared.Monetization.MarkAdded` | Pending |
| `init.luau` | ModuleScript | — | — | 335 | `ReplicatedStorage.Shared.Monetization.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/NPC_Custom/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Actions.luau` | ModuleScript | — | — | 100 | `ReplicatedStorage.Shared.NPC_Custom.Actions` | Pending |
| `init.luau` | ModuleScript | — | — | 105 | `ReplicatedStorage.Shared.NPC_Custom.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/NPC_Custom/Instance/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `CustomizeSettings.luau` | ModuleScript | — | — | 24 | `ReplicatedStorage.Shared.NPC_Custom.Instance.CustomizeSettings` | Pending |
| `FormatPathNpc.luau` | ModuleScript | — | — | 58 | `ReplicatedStorage.Shared.NPC_Custom.Instance.FormatPathNpc` | Pending |
| `init.luau` | ModuleScript | — | — | 196 | `ReplicatedStorage.Shared.NPC_Custom.Instance.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Nametag/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Countries.luau` | ModuleScript | — | — | 209 | `ReplicatedStorage.Shared.Nametag.Countries` | Pending |
| `LevelStyler.luau` | ModuleScript | — | — | 164 | `ReplicatedStorage.Shared.Nametag.LevelStyler` | Pending |
| `MicStatus.luau` | ModuleScript | — | — | 80 | `ReplicatedStorage.Shared.Nametag.MicStatus` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Nametag/GroupRoles/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 47 | `ReplicatedStorage.Shared.Nametag.GroupRoles.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Observers/</code> — 6 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 15 | `ReplicatedStorage.Shared.Observers.init` | Pending |
| `observeAttribute.luau` | ModuleScript | — | — | 119 | `ReplicatedStorage.Shared.Observers.observeAttribute` | Pending |
| `observeCharacter.luau` | ModuleScript | — | — | 82 | `ReplicatedStorage.Shared.Observers.observeCharacter` | Pending |
| `observePlayer.luau` | ModuleScript | — | — | 80 | `ReplicatedStorage.Shared.Observers.observePlayer` | Pending |
| `observeProperty.luau` | ModuleScript | — | — | 67 | `ReplicatedStorage.Shared.Observers.observeProperty` | Pending |
| `observeTag.luau` | ModuleScript | — | — | 192 | `ReplicatedStorage.Shared.Observers.observeTag` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Paint/Create/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 40 | `ReplicatedStorage.Shared.Paint.Create.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Paint/FormatPinturaData/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `SplitRespectingBrackets.luau` | ModuleScript | — | — | 31 | `ReplicatedStorage.Shared.Paint.FormatPinturaData.SplitRespectingBrackets` | Pending |
| `init.luau` | ModuleScript | — | — | 55 | `ReplicatedStorage.Shared.Paint.FormatPinturaData.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Paint/Load/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 101 | `ReplicatedStorage.Shared.Paint.Load.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Paint/Load/LoadFrame/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Frames.luau` | ModuleScript | — | — | 7 | `ReplicatedStorage.Shared.Paint.Load.LoadFrame.Frames` | Pending |
| `init.luau` | ModuleScript | — | — | 235 | `ReplicatedStorage.Shared.Paint.Load.LoadFrame.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Paint/Paint/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `PaletteColor.luau` | ModuleScript | — | — | 160 | `ReplicatedStorage.Shared.Paint.Paint.PaletteColor` | Pending |
| `Save.luau` | ModuleScript | — | — | 161 | `ReplicatedStorage.Shared.Paint.Paint.Save` | Pending |
| `init.luau` | ModuleScript | — | — | 507 | `ReplicatedStorage.Shared.Paint.Paint.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Paint/ServerClient/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Marcos.server.luau` | Script | — | yes | 3 | `ReplicatedStorage.Shared.Paint.ServerClient.Marcos.server` | Pending |
| `init.luau` | ModuleScript | — | — | 737 | `ReplicatedStorage.Shared.Paint.ServerClient.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/PartCache/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Table.luau` | ModuleScript | — | — | 107 | `ReplicatedStorage.Shared.PartCache.Table` | Pending |
| `init.luau` | ModuleScript | — | — | 192 | `ReplicatedStorage.Shared.PartCache.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Promise/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 2068 | `ReplicatedStorage.Shared.Promise.init` | Pending |
| `init.spec.luau` | ModuleScript | — | — | 1844 | `ReplicatedStorage.Shared.Promise.init.spec` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/PrompBuy/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 109 | `ReplicatedStorage.Shared.PrompBuy.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Quests/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `QuestConfig.luau` | ModuleScript | — | — | 221 | `ReplicatedStorage.Shared.Quests.QuestConfig` | Pending |
| `QuestShared.luau` | ModuleScript | — | — | 49 | `ReplicatedStorage.Shared.Quests.QuestShared` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Referrals/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `ProgressRing.luau` | ModuleScript | — | — | 114 | `ReplicatedStorage.Shared.Referrals.ProgressRing` | Pending |
| `ReferralConfig.luau` | ModuleScript | — | — | 196 | `ReplicatedStorage.Shared.Referrals.ReferralConfig` | Pending |
| `ReferralShared.luau` | ModuleScript | — | — | 309 | `ReplicatedStorage.Shared.Referrals.ReferralShared` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Sift/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `None.luau` | ModuleScript | — | — | 16 | `ReplicatedStorage.Shared.Sift.None` | Pending |
| `Types.luau` | ModuleScript | — | — | 16 | `ReplicatedStorage.Shared.Sift.Types` | Pending |
| `init.luau` | ModuleScript | — | — | 58 | `ReplicatedStorage.Shared.Sift.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Sift/Array/</code> — 48 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `at.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Array.at` | Pending |
| `concat.luau` | ModuleScript | — | — | 46 | `ReplicatedStorage.Shared.Sift.Array.concat` | Pending |
| `concatDeep.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.Sift.Array.concatDeep` | Pending |
| `copy.luau` | ModuleScript | — | — | 19 | `ReplicatedStorage.Shared.Sift.Array.copy` | Pending |
| `copyDeep.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Array.copyDeep` | Pending |
| `count.luau` | ModuleScript | — | — | 42 | `ReplicatedStorage.Shared.Sift.Array.count` | Pending |
| `create.luau` | ModuleScript | — | — | 19 | `ReplicatedStorage.Shared.Sift.Array.create` | Pending |
| `difference.luau` | ModuleScript | — | — | 42 | `ReplicatedStorage.Shared.Sift.Array.difference` | Pending |
| `differenceSymmetric.luau` | ModuleScript | — | — | 42 | `ReplicatedStorage.Shared.Sift.Array.differenceSymmetric` | Pending |
| `equals.luau` | ModuleScript | — | — | 63 | `ReplicatedStorage.Shared.Sift.Array.equals` | Pending |
| `equalsDeep.luau` | ModuleScript | — | — | 63 | `ReplicatedStorage.Shared.Sift.Array.equalsDeep` | Pending |
| `every.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.Sift.Array.every` | Pending |
| `filter.luau` | ModuleScript | — | — | 43 | `ReplicatedStorage.Shared.Sift.Array.filter` | Pending |
| `find.luau` | ModuleScript | — | — | 33 | `ReplicatedStorage.Shared.Sift.Array.find` | Pending |
| `findLast.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.Sift.Array.findLast` | Pending |
| `findWhere.luau` | ModuleScript | — | — | 39 | `ReplicatedStorage.Shared.Sift.Array.findWhere` | Pending |
| `findWhereLast.luau` | ModuleScript | — | — | 43 | `ReplicatedStorage.Shared.Sift.Array.findWhereLast` | Pending |
| `first.luau` | ModuleScript | — | — | 23 | `ReplicatedStorage.Shared.Sift.Array.first` | Pending |
| `flatten.luau` | ModuleScript | — | — | 44 | `ReplicatedStorage.Shared.Sift.Array.flatten` | Pending |
| `freeze.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Array.freeze` | Pending |
| `freezeDeep.luau` | ModuleScript | — | — | 39 | `ReplicatedStorage.Shared.Sift.Array.freezeDeep` | Pending |
| `includes.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Array.includes` | Pending |
| `init.luau` | ModuleScript | — | — | 82 | `ReplicatedStorage.Shared.Sift.Array.init` | Pending |
| `insert.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.Sift.Array.insert` | Pending |
| `is.luau` | ModuleScript | — | — | 25 | `ReplicatedStorage.Shared.Sift.Array.is` | Pending |
| `last.luau` | ModuleScript | — | — | 23 | `ReplicatedStorage.Shared.Sift.Array.last` | Pending |
| `map.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.Sift.Array.map` | Pending |
| `pop.luau` | ModuleScript | — | — | 33 | `ReplicatedStorage.Shared.Sift.Array.pop` | Pending |
| `push.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Shared.Sift.Array.push` | Pending |
| `reduce.luau` | ModuleScript | — | — | 47 | `ReplicatedStorage.Shared.Sift.Array.reduce` | Pending |
| `reduceRight.luau` | ModuleScript | — | — | 48 | `ReplicatedStorage.Shared.Sift.Array.reduceRight` | Pending |
| `removeIndex.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Shared.Sift.Array.removeIndex` | Pending |
| `removeIndices.luau` | ModuleScript | — | — | 41 | `ReplicatedStorage.Shared.Sift.Array.removeIndices` | Pending |
| `removeValue.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Array.removeValue` | Pending |
| `removeValues.luau` | ModuleScript | — | — | 33 | `ReplicatedStorage.Shared.Sift.Array.removeValues` | Pending |
| `reverse.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Array.reverse` | Pending |
| `set.luau` | ModuleScript | — | — | 39 | `ReplicatedStorage.Shared.Sift.Array.set` | Pending |
| `shift.luau` | ModuleScript | — | — | 33 | `ReplicatedStorage.Shared.Sift.Array.shift` | Pending |
| `shuffle.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.Sift.Array.shuffle` | Pending |
| `slice.luau` | ModuleScript | — | — | 43 | `ReplicatedStorage.Shared.Sift.Array.slice` | Pending |
| `some.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.Sift.Array.some` | Pending |
| `sort.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Array.sort` | Pending |
| `splice.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.Sift.Array.splice` | Pending |
| `toSet.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Array.toSet` | Pending |
| `unshift.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Array.unshift` | Pending |
| `update.luau` | ModuleScript | — | — | 68 | `ReplicatedStorage.Shared.Sift.Array.update` | Pending |
| `zip.luau` | ModuleScript | — | — | 47 | `ReplicatedStorage.Shared.Sift.Array.zip` | Pending |
| `zipAll.luau` | ModuleScript | — | — | 51 | `ReplicatedStorage.Shared.Sift.Array.zipAll` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Sift/Dictionary/</code> — 30 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `copy.luau` | ModuleScript | — | — | 20 | `ReplicatedStorage.Shared.Sift.Dictionary.copy` | Pending |
| `copyDeep.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Dictionary.copyDeep` | Pending |
| `count.luau` | ModuleScript | — | — | 42 | `ReplicatedStorage.Shared.Sift.Dictionary.count` | Pending |
| `entries.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Dictionary.entries` | Pending |
| `equals.luau` | ModuleScript | — | — | 64 | `ReplicatedStorage.Shared.Sift.Dictionary.equals` | Pending |
| `equalsDeep.luau` | ModuleScript | — | — | 64 | `ReplicatedStorage.Shared.Sift.Dictionary.equalsDeep` | Pending |
| `every.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.Sift.Dictionary.every` | Pending |
| `filter.luau` | ModuleScript | — | — | 41 | `ReplicatedStorage.Shared.Sift.Dictionary.filter` | Pending |
| `flatten.luau` | ModuleScript | — | — | 52 | `ReplicatedStorage.Shared.Sift.Dictionary.flatten` | Pending |
| `flip.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Dictionary.flip` | Pending |
| `freeze.luau` | ModuleScript | — | — | 31 | `ReplicatedStorage.Shared.Sift.Dictionary.freeze` | Pending |
| `freezeDeep.luau` | ModuleScript | — | — | 38 | `ReplicatedStorage.Shared.Sift.Dictionary.freezeDeep` | Pending |
| `fromArrays.luau` | ModuleScript | — | — | 31 | `ReplicatedStorage.Shared.Sift.Dictionary.fromArrays` | Pending |
| `fromEntries.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Dictionary.fromEntries` | Pending |
| `has.luau` | ModuleScript | — | — | 25 | `ReplicatedStorage.Shared.Sift.Dictionary.has` | Pending |
| `includes.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Dictionary.includes` | Pending |
| `init.luau` | ModuleScript | — | — | 51 | `ReplicatedStorage.Shared.Sift.Dictionary.init` | Pending |
| `keys.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Dictionary.keys` | Pending |
| `map.luau` | ModuleScript | — | — | 40 | `ReplicatedStorage.Shared.Sift.Dictionary.map` | Pending |
| `merge.luau` | ModuleScript | — | — | 45 | `ReplicatedStorage.Shared.Sift.Dictionary.merge` | Pending |
| `mergeDeep.luau` | ModuleScript | — | — | 56 | `ReplicatedStorage.Shared.Sift.Dictionary.mergeDeep` | Pending |
| `removeKey.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Dictionary.removeKey` | Pending |
| `removeKeys.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Dictionary.removeKeys` | Pending |
| `removeValue.luau` | ModuleScript | — | — | 31 | `ReplicatedStorage.Shared.Sift.Dictionary.removeValue` | Pending |
| `removeValues.luau` | ModuleScript | — | — | 36 | `ReplicatedStorage.Shared.Sift.Dictionary.removeValues` | Pending |
| `set.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Dictionary.set` | Pending |
| `some.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.Sift.Dictionary.some` | Pending |
| `update.luau` | ModuleScript | — | — | 60 | `ReplicatedStorage.Shared.Sift.Dictionary.update` | Pending |
| `values.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Dictionary.values` | Pending |
| `withKeys.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Dictionary.withKeys` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Sift/Set/</code> — 16 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `add.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Set.add` | Pending |
| `copy.luau` | ModuleScript | — | — | 21 | `ReplicatedStorage.Shared.Sift.Set.copy` | Pending |
| `count.luau` | ModuleScript | — | — | 42 | `ReplicatedStorage.Shared.Sift.Set.count` | Pending |
| `delete.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.Sift.Set.delete` | Pending |
| `difference.luau` | ModuleScript | — | — | 37 | `ReplicatedStorage.Shared.Sift.Set.difference` | Pending |
| `differenceSymmetric.luau` | ModuleScript | — | — | 41 | `ReplicatedStorage.Shared.Sift.Set.differenceSymmetric` | Pending |
| `filter.luau` | ModuleScript | — | — | 41 | `ReplicatedStorage.Shared.Sift.Set.filter` | Pending |
| `fromArray.luau` | ModuleScript | — | — | 30 | `ReplicatedStorage.Shared.Sift.Set.fromArray` | Pending |
| `has.luau` | ModuleScript | — | — | 22 | `ReplicatedStorage.Shared.Sift.Set.has` | Pending |
| `init.luau` | ModuleScript | — | — | 38 | `ReplicatedStorage.Shared.Sift.Set.init` | Pending |
| `intersection.luau` | ModuleScript | — | — | 46 | `ReplicatedStorage.Shared.Sift.Set.intersection` | Pending |
| `isSubset.luau` | ModuleScript | — | — | 29 | `ReplicatedStorage.Shared.Sift.Set.isSubset` | Pending |
| `isSuperset.luau` | ModuleScript | — | — | 25 | `ReplicatedStorage.Shared.Sift.Set.isSuperset` | Pending |
| `map.luau` | ModuleScript | — | — | 34 | `ReplicatedStorage.Shared.Sift.Set.map` | Pending |
| `merge.luau` | ModuleScript | — | — | 38 | `ReplicatedStorage.Shared.Sift.Set.merge` | Pending |
| `toArray.luau` | ModuleScript | — | — | 27 | `ReplicatedStorage.Shared.Sift.Set.toArray` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Sift/Util/</code> — 4 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `equalObjects.luau` | ModuleScript | — | — | 32 | `ReplicatedStorage.Shared.Sift.Util.equalObjects` | Pending |
| `func.luau` | ModuleScript | — | — | 15 | `ReplicatedStorage.Shared.Sift.Util.func` | Pending |
| `init.luau` | ModuleScript | — | — | 5 | `ReplicatedStorage.Shared.Sift.Util.init` | Pending |
| `isEmpty.luau` | ModuleScript | — | — | 26 | `ReplicatedStorage.Shared.Sift.Util.isEmpty` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Stores/</code> — 6 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Added.luau` | ModuleScript | — | — | 205 | `ReplicatedStorage.Shared.Stores.Added` | Pending |
| `ColorTexture.luau` | ModuleScript | — | — | 26 | `ReplicatedStorage.Shared.Stores.ColorTexture` | Pending |
| `Compras.luau` | ModuleScript | — | — | 487 | `ReplicatedStorage.Shared.Stores.Compras` | Pending |
| `DecorsPlayer.luau` | ModuleScript | — | — | 92 | `ReplicatedStorage.Shared.Stores.DecorsPlayer` | Pending |
| `HouseAdded.luau` | ModuleScript | — | — | 297 | `ReplicatedStorage.Shared.Stores.HouseAdded` | Pending |
| `init.luau` | ModuleScript | — | — | 992 | `ReplicatedStorage.Shared.Stores.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Stores/DecorFuncs/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 117 | `ReplicatedStorage.Shared.Stores.DecorFuncs.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Stores/DecorFuncs/AddedDecor/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Collitions.luau` | ModuleScript | — | — | 17 | `ReplicatedStorage.Shared.Stores.DecorFuncs.AddedDecor.Collitions` | Pending |
| `init.luau` | ModuleScript | — | — | 341 | `ReplicatedStorage.Shared.Stores.DecorFuncs.AddedDecor.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Tutorials/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `ParametrosGuideClaim.luau` | ModuleScript | — | — | 49 | `ReplicatedStorage.Shared.Tutorials.ParametrosGuideClaim` | Pending |
| `ParametrosTutorialBienvenida.luau` | ModuleScript | — | — | 139 | `ReplicatedStorage.Shared.Tutorials.ParametrosTutorialBienvenida` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/machines/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `roulettePrizes.luau` | ModuleScript | — | — | 104 | `ReplicatedStorage.Shared.machines.roulettePrizes` | Pending |
| `rouletteUtil.luau` | ModuleScript | — | — | 12 | `ReplicatedStorage.Shared.machines.rouletteUtil` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/pong/</code> — 4 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Ball.luau` | ModuleScript | — | — | 559 | `ReplicatedStorage.Shared.pong.Ball` | Pending |
| `Input.luau` | ModuleScript | — | — | 21 | `ReplicatedStorage.Shared.pong.Input` | Pending |
| `Paddle.luau` | ModuleScript | — | — | 222 | `ReplicatedStorage.Shared.pong.Paddle` | Pending |
| `createPongSession.luau` | ModuleScript | — | — | 48 | `ReplicatedStorage.Shared.pong.createPongSession` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/Data/Main/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `PlayerGamesFetcher.luau` | ModuleScript | — | — | 112 | `ServerScriptService.Data.Main.PlayerGamesFetcher` | Pending |
| `init.server.luau` | Script | — | yes | 393 | `ServerScriptService.Data.Main.init.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/</code> — 20 file(s) — 6/20 read</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `EventBootstrap.server.luau` | Script | — | yes | 34 | `ServerScriptService.ServerScripts.EventBootstrap.server` | Pending |
| `EventCommands.server.luau` | Script | — | yes | 180 | `ServerScriptService.ServerScripts.EventCommands.server` | Pending |
| `FavoriteService.server.luau` | Script | Server | yes | 55 | `ServerScriptService.ServerScripts.FavoriteService.server` | Pending |
| `GiftHandler.server.luau` | Script | Server | yes | 355 | `ServerScriptService.ServerScripts.GiftHandler.server` | Pending |
| `LootBoxService.server.luau` | Script | — | yes | 104 | `ServerScriptService.ServerScripts.LootBoxService.server` | Pending |
| `MicManagerServer.server.luau` | Script | Server | yes | 197 | `ServerScriptService.ServerScripts.MicManagerServer.server` | Pending |
| `NametagServer.server.luau` | Script | Server | yes | 513 | `ServerScriptService.ServerScripts.NametagServer.server` | Pending |
| `PlayerDataInit.server.luau` | Script | Server | yes | 42 | `ServerScriptService.ServerScripts.PlayerDataInit.server` | Pending |
| `PlayerDataReplicator.server.luau` | Script | Server | yes | 116 | `ServerScriptService.ServerScripts.PlayerDataReplicator.server` | Analyzed |
| `PlaytimeRewardSystem.server.luau` | Script | — | yes | 107 | `ServerScriptService.ServerScripts.PlaytimeRewardSystem.server` | Pending |
| `ServerDirectory.server.luau` | Script | Server | yes | 432 | `ServerScriptService.ServerScripts.ServerDirectory.server` | Analyzed |
| `ShopServerSystem.server.luau` | Script | Server | yes | 310 | `ServerScriptService.ServerScripts.ShopServerSystem.server` | Analyzed (partly) |
| `ToolPlacementServer.server.luau` | Script | Server | yes | 881 | `ServerScriptService.ServerScripts.ToolPlacementServer.server` | Pending |
| `ToolsServer.server.luau` | Script | — | yes | 989 | `ServerScriptService.ServerScripts.ToolsServer.server` | Pending |
| `WalkieServer.server.luau` | Script | Server | yes | 148 | `ServerScriptService.ServerScripts.WalkieServer.server` | Pending |
| `WorldManager.server.luau` | Script | Server | yes | 228 | `ServerScriptService.ServerScripts.WorldManager.server` | Analyzed |
| `WorldsBrowser.server.luau` | Script | Server | yes | 140 | `ServerScriptService.ServerScripts.WorldsBrowser.server` | Analyzed |
| `collisions.server.luau` | Script | Server | yes | 37 | `ServerScriptService.ServerScripts.collisions.server` | Pending |
| `fireExcept.luau` | ModuleScript | — | — | 11 | `ServerScriptService.ServerScripts.fireExcept` | Pending |
| `playerManager.server.luau` | Script | — | yes | 208 | `ServerScriptService.ServerScripts.playerManager.server` | Analyzed |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/AnimationSystem/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `AnimationManager.luau` | ModuleScript | — | — | 73 | `ServerScriptService.ServerScripts.AnimationSystem.AnimationManager` | Pending |
| `init.server.luau` | Script | Server | yes | 104 | `ServerScriptService.ServerScripts.AnimationSystem.init.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/Quests/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `QuestMain.server.luau` | Script | — | yes | 75 | `ServerScriptService.ServerScripts.Quests.QuestMain.server` | Pending |
| `QuestService.luau` | ModuleScript | — | — | 347 | `ServerScriptService.ServerScripts.Quests.QuestService` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/Quests/Pickables/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `QuestPickableService.luau` | ModuleScript | — | — | 316 | `ServerScriptService.ServerScripts.Quests.Pickables.QuestPickableService` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/Ragdoll/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `DisableJointsWhenFalling.server.luau` | Script | — | yes | 63 | `ServerScriptService.ServerScripts.Ragdoll.DisableJointsWhenFalling.server` | Pending |
| `PhysicallySimulatedUpperBody.server.luau` | Script | — | yes | 47 | `ServerScriptService.ServerScripts.Ragdoll.PhysicallySimulatedUpperBody.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/Referrals/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `ReferralCommands.server.luau` | Script | — | yes | 333 | `ServerScriptService.ServerScripts.Referrals.ReferralCommands.server` | Pending |
| `ReferralMain.server.luau` | Script | — | yes | 233 | `ServerScriptService.ServerScripts.Referrals.ReferralMain.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/ToolModelGenerator/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Settings.luau` | ModuleScript | — | — | 32 | `ServerScriptService.ServerScripts.ToolModelGenerator.Settings` | Pending |
| `init.server.luau` | Script | Server | yes | 170 | `ServerScriptService.ServerScripts.ToolModelGenerator.init.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/cooking/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `CookingStation.luau` | ModuleScript | — | — | 270 | `ServerScriptService.ServerScripts.cooking.CookingStation` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/cooking/interactables/</code> — 5 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Blender.server.luau` | Script | Server | yes | 54 | `ServerScriptService.ServerScripts.cooking.interactables.Blender.server` | Pending |
| `CuttingBoard.server.luau` | Script | Server | yes | 113 | `ServerScriptService.ServerScripts.cooking.interactables.CuttingBoard.server` | Pending |
| `Microwave.server.luau` | Script | Server | yes | 233 | `ServerScriptService.ServerScripts.cooking.interactables.Microwave.server` | Pending |
| `Oven.server.luau` | Script | Server | yes | 72 | `ServerScriptService.ServerScripts.cooking.interactables.Oven.server` | Pending |
| `Stove.server.luau` | Script | Server | yes | 93 | `ServerScriptService.ServerScripts.cooking.interactables.Stove.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/interactable/</code> — 21 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `BarraBartender.server.luau` | Script | Server | yes | 24 | `ServerScriptService.ServerScripts.interactable.BarraBartender.server` | Pending |
| `Bath.server.luau` | Script | Server | yes | 41 | `ServerScriptService.ServerScripts.interactable.Bath.server` | Pending |
| `Bin.server.luau` | Script | Server | yes | 17 | `ServerScriptService.ServerScripts.interactable.Bin.server` | Pending |
| `ClassicDoor.server.luau` | Script | Server | yes | 151 | `ServerScriptService.ServerScripts.interactable.ClassicDoor.server` | Pending |
| `CuadrosPaint.server.luau` | Script | Server | yes | 11 | `ServerScriptService.ServerScripts.interactable.CuadrosPaint.server` | Pending |
| `DiscoBall.server.luau` | Script | Server | yes | 7 | `ServerScriptService.ServerScripts.interactable.DiscoBall.server` | Pending |
| `Display.server.luau` | Script | Server | yes | 31 | `ServerScriptService.ServerScripts.interactable.Display.server` | Pending |
| `Fridge.server.luau` | Script | Server | yes | 137 | `ServerScriptService.ServerScripts.interactable.Fridge.server` | Pending |
| `Lamp.server.luau` | Script | Server | yes | 116 | `ServerScriptService.ServerScripts.interactable.Lamp.server` | Pending |
| `MusicPlayer.server.luau` | Script | Server | yes | 17 | `ServerScriptService.ServerScripts.interactable.MusicPlayer.server` | Pending |
| `NpcDialog.server.luau` | Script | Server | yes | 27 | `ServerScriptService.ServerScripts.interactable.NpcDialog.server` | Pending |
| `Paint.server.luau` | Script | Server | yes | 19 | `ServerScriptService.ServerScripts.interactable.Paint.server` | Pending |
| `Pee.server.luau` | Script | Server | yes | 222 | `ServerScriptService.ServerScripts.interactable.Pee.server` | Pending |
| `Seat.server.luau` | Script | Server | yes | 27 | `ServerScriptService.ServerScripts.interactable.Seat.server` | Pending |
| `Shower.server.luau` | Script | Server | yes | 68 | `ServerScriptService.ServerScripts.interactable.Shower.server` | Pending |
| `SmokeMachine.server.luau` | Script | Server | yes | 7 | `ServerScriptService.ServerScripts.interactable.SmokeMachine.server` | Pending |
| `Tijeras.server.luau` | Script | Server | yes | 153 | `ServerScriptService.ServerScripts.interactable.Tijeras.server` | Pending |
| `Toilet.server.luau` | Script | Server | yes | 98 | `ServerScriptService.ServerScripts.interactable.Toilet.server` | Pending |
| `Treadmill.server.luau` | Script | Server | yes | 64 | `ServerScriptService.ServerScripts.interactable.Treadmill.server` | Pending |
| `Washbasin.server.luau` | Script | Server | yes | 49 | `ServerScriptService.ServerScripts.interactable.Washbasin.server` | Pending |
| `Weight.server.luau` | Script | Server | yes | 38 | `ServerScriptService.ServerScripts.interactable.Weight.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/interactable/Bed/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Bed.luau` | ModuleScript | — | — | 186 | `ServerScriptService.ServerScripts.interactable.Bed.Bed` | Pending |
| `init.server.luau` | Script | Server | yes | 20 | `ServerScriptService.ServerScripts.interactable.Bed.init.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/interactable/DoubleBed/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `DoubleBed.luau` | ModuleScript | — | — | 255 | `ServerScriptService.ServerScripts.interactable.DoubleBed.DoubleBed` | Pending |
| `init.server.luau` | Script | Server | yes | 23 | `ServerScriptService.ServerScripts.interactable.DoubleBed.init.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/inventory/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.server.luau` | Script | Server | yes | 95 | `ServerScriptService.ServerScripts.inventory.init.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/inventory/InventoryManager/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `DefaultTools.luau` | ModuleScript | — | — | 53 | `ServerScriptService.ServerScripts.inventory.InventoryManager.DefaultTools` | Pending |
| `init.luau` | ModuleScript | — | — | 561 | `ServerScriptService.ServerScripts.inventory.InventoryManager.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/machines/</code> — 10 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Basketball.luau` | ModuleScript | — | — | 92 | `ServerScriptService.ServerScripts.machines.Basketball` | Pending |
| `Machine.luau` | ModuleScript | — | — | 86 | `ServerScriptService.ServerScripts.machines.Machine` | Pending |
| `MachineFactory.luau` | ModuleScript | — | — | 26 | `ServerScriptService.ServerScripts.machines.MachineFactory` | Pending |
| `Pong.luau` | ModuleScript | — | — | 388 | `ServerScriptService.ServerScripts.machines.Pong` | Pending |
| `PopTheLock.luau` | ModuleScript | — | — | 55 | `ServerScriptService.ServerScripts.machines.PopTheLock` | Pending |
| `Roulette.luau` | ModuleScript | — | — | 177 | `ServerScriptService.ServerScripts.machines.Roulette` | Pending |
| `Stacker.luau` | ModuleScript | — | — | 50 | `ServerScriptService.ServerScripts.machines.Stacker` | Pending |
| `ToyMachine.luau` | ModuleScript | — | — | 158 | `ServerScriptService.ServerScripts.machines.ToyMachine` | Pending |
| `init.server.luau` | Script | Server | yes | 186 | `ServerScriptService.ServerScripts.machines.init.server` | Pending |
| `oldPong.luau` | ModuleScript | — | — | 114 | `ServerScriptService.ServerScripts.machines.oldPong` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerScriptService/ServerScripts/stats/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Stats.luau` | ModuleScript | — | — | 71 | `ServerScriptService.ServerScripts.stats.Stats` | Pending |
| `Timer.luau` | ModuleScript | — | — | 56 | `ServerScriptService.ServerScripts.stats.Timer` | Pending |
| `init.server.luau` | Script | Server | yes | 84 | `ServerScriptService.ServerScripts.stats.init.server` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `BusquedaMusicas.luau` | ModuleScript | — | — | 455 | `ServerStorage.BusquedaMusicas` | Pending |
| `SoundInfo.luau` | ModuleScript | — | — | 37 | `ServerStorage.SoundInfo` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/DataKit/</code> — 9 file(s) — 7/9 read</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `BaseStore.luau` | ModuleScript | — | — | 330 | `ServerStorage.DataKit.BaseStore` | Analyzed (partly) |
| `Health.luau` | ModuleScript | — | — | 82 | `ServerStorage.DataKit.Health` | Analyzed |
| `Inbox.luau` | ModuleScript | — | — | 71 | `ServerStorage.DataKit.Inbox` | Pending |
| `Lease.luau` | ModuleScript | — | — | 254 | `ServerStorage.DataKit.Lease` | Analyzed |
| `Mutex.luau` | ModuleScript | — | — | 62 | `ServerStorage.DataKit.Mutex` | Analyzed |
| `Profile.luau` | ModuleScript | — | — | 149 | `ServerStorage.DataKit.Profile` | Analyzed |
| `Signal.luau` | ModuleScript | — | — | 56 | `ServerStorage.DataKit.Signal` | Pending |
| `Store.luau` | ModuleScript | — | — | 1237 | `ServerStorage.DataKit.Store` | Analyzed (partly) |
| `init.luau` | ModuleScript | — | — | 56 | `ServerStorage.DataKit.init` | Analyzed |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/DataKit/Adapters/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `Types.luau` | ModuleScript | — | — | 62 | `ServerStorage.DataKit.Adapters.Types` | Pending |
| `init.luau` | ModuleScript | — | — | 46 | `ServerStorage.DataKit.Adapters.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/DataKit/Util/</code> — 5 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `capitalize.luau` | ModuleScript | — | — | 14 | `ServerStorage.DataKit.Util.capitalize` | Pending |
| `deepCopy.luau` | ModuleScript | — | — | 26 | `ServerStorage.DataKit.Util.deepCopy` | Pending |
| `deepEquals.luau` | ModuleScript | — | — | 31 | `ServerStorage.DataKit.Util.deepEquals` | Pending |
| `reconcile.luau` | ModuleScript | — | — | 27 | `ServerStorage.DataKit.Util.reconcile` | Pending |
| `retry.luau` | ModuleScript | — | — | 41 | `ServerStorage.DataKit.Util.retry` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/GlobalDataStore/</code> — 3 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `ReadMe.server.luau` | Script | Server | — | 60 | `ServerStorage.GlobalDataStore.ReadMe.server` | Pending |
| `Testeo_GlobalDataStore.luau` | ModuleScript | — | — | 164 | `ServerStorage.GlobalDataStore.Testeo_GlobalDataStore` | Pending |
| `init.luau` | ModuleScript | — | — | 335 | `ServerStorage.GlobalDataStore.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/RoleService/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `RolesGroup.luau` | ModuleScript | — | — | 16 | `ServerStorage.RoleService.RolesGroup` | Pending |
| `init.luau` | ModuleScript | — | — | 117 | `ServerStorage.RoleService.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/WorldSystem/</code> — 8 file(s) — 3/8 read</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `EventService.luau` | ModuleScript | — | — | 456 | `ServerStorage.WorldSystem.EventService` | Pending |
| `GiftInbox.luau` | ModuleScript | — | — | 89 | `ServerStorage.WorldSystem.GiftInbox` | Pending |
| `PlayerDataReplicator.luau` | ModuleScript | — | — | 555 | `ServerStorage.WorldSystem.PlayerDataReplicator` | Pending |
| `PlayerDataService.luau` | ModuleScript | — | — | 90 | `ServerStorage.WorldSystem.PlayerDataService` | Pending |
| `PlayerSchema.luau` | ModuleScript | — | — | 126 | `ServerStorage.WorldSystem.PlayerSchema` | Analyzed |
| `Profiles.luau` | ModuleScript | — | — | 296 | `ServerStorage.WorldSystem.Profiles` | Analyzed |
| `ReferralService.luau` | ModuleScript | — | — | 1244 | `ServerStorage.WorldSystem.ReferralService` | Pending |
| `ServerPresence.luau` | ModuleScript | — | — | 361 | `ServerStorage.WorldSystem.ServerPresence` | **Documented** |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ServerStorage/WorldSystem/GamePassService/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `GamePassRewards.luau` | ModuleScript | — | — | 60 | `ServerStorage.WorldSystem.GamePassService.GamePassRewards` | Pending |
| `init.luau` | ModuleScript | — | — | 131 | `ServerStorage.WorldSystem.GamePassService.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/StarterGui/</code> — 1 file(s) — 1/1 read</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `LocalScript.client.luau` | LocalScript | — | yes | 26 | `StarterGui.LocalScript.client` | Analyzed |

</details>

## `GameWorlds` template

1 files, 68 lines, 1 read.

<details>
<summary><code>src/ServerStorage/TemplatesTesting/GameWorlds/ServerScriptService/ServerScripts/</code> — 1 file(s) — 1/1 read</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `PublicServerInit.lua.server.luau` | Script | — | yes | 68 | `ServerScriptService.ServerScripts.PublicServerInit.lua.server` | Analyzed |

</details>

## `PlayerHouses` template

5 files, 864 lines, 5 read.

<details>
<summary><code>src/ServerStorage/TemplatesTesting/PlayerHouses/ReplicatedStorage/</code> — 1 file(s) — 1/1 read</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `RolesInfo.luau` | ModuleScript | — | — | 10 | `ReplicatedStorage.RolesInfo` | Analyzed |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/PlayerHouses/ServerScriptService/</code> — 4 file(s) — 4/4 read</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `ModeratorManager.server.luau` | Script | — | yes | 156 | `ServerScriptService.ModeratorManager.server` | Analyzed |
| `PlayerWorld_Init.lua.server.luau` | Script | — | yes | 291 | `ServerScriptService.PlayerWorld_Init.lua.server` | Analyzed |
| `WorldDataReplicator.server.luau` | Script | — | yes | 241 | `ServerScriptService.WorldDataReplicator.server` | Analyzed |
| `WorldService.luau` | ModuleScript | — | — | 166 | `ServerScriptService.WorldService` | Analyzed |

</details>

## `BuildingSystem` template

8 files, 2,750 lines, 0 read.

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/</code> — 2 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `ColorFormat.luau` | ModuleScript | — | — | 43 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.ColorFormat` | Pending |
| `init.luau` | ModuleScript | — | — | 151 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/Color/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 291 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Color.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/Main/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 201 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Main.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/Main/DesingFrame/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 494 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Main.DesingFrame.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/Main/FurnitureFrame/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 325 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Main.FurnitureFrame.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/Main/Inventory/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 180 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Main.Inventory.init` | Pending |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/MoveAndPlaceent/</code> — 1 file(s)</summary>

| File | Kind | Context | Disabled | Lines | Runtime path | Status |
|---|---|---|---|---|---|---|
| `init.luau` | ModuleScript | — | — | 1065 | `ReplicatedStorage.BuildInterface.ConstructionModeModule.MoveAndPlaceent.init` | Pending |

</details>
