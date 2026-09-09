---
sidebar_position: 2
title: Assets binarios
---

# Assets binarios

**No inspeccionables.** Estos archivos son modelos binarios de Roblox. Su contenido no se
puede leer desde este repositorio, y **nada en este sitio describe lo que hay dentro**. Se
listan para que quien lea sepa qué existe, dónde acaba en tiempo de ejecución, y qué huecos
de la documentación explican.

Si una página dice que no se ha encontrado un productor o un consumidor, uno de estos
archivos es el sitio más probable donde está.

**320 archivos.**

## Los que más importan

| Archivo | Por qué importa |
|---|---|
| `src/StarterPlayer/StarterPlayerScripts.rbxm` | El sitio más probable del cargador de scripts del cliente y del emisor de `LoadCharacterRequest`. Explica [BUG-CANDIDATE-007](../testing/verification-plan.md#bug-candidate-007). |
| `src/StarterPlayer/StarterCharacterScripts.rbxm` | Lo que se añade a cada personaje. Hace que [Ciclo de vida del Character](../architecture/character-lifecycle.md) esté incompleto por construcción. |
| `src/ReplicatedFirst/LoadingScreenUI.rbxm` | Lo primero que ve un cliente. |
| `src/StarterGui/ScreenGui.rbxm`, `src/StarterGui/BuildMenu.rbxm` | UI raíz, fuera de las plantillas. |
| `…/PlayerHouses/StarterGui/PermsGui.rbxm` | La UI de permisos de casa — la mitad cliente de [Casas → Permisos](../systems/housing/permissions.md). |

## Fuera de las plantillas

**6 archivos.**

<details>
<summary><code>src/ReplicatedFirst/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `LoadingScreenUI.rbxm` | `ReplicatedFirst.LoadingScreenUI.rbxm` | 12 KB |

</details>

<details>
<summary><code>src/ServerStorage/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `RBX_ANIMSAVES.rbxm` | `ServerStorage.RBX_ANIMSAVES.rbxm` | 234 KB |

</details>

<details>
<summary><code>src/StarterGui/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `BuildMenu.rbxm` | `StarterGui.BuildMenu.rbxm` | 62 KB |
| `ScreenGui.rbxm` | `StarterGui.ScreenGui.rbxm` | 13 KB |

</details>

<details>
<summary><code>src/StarterPlayer/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `StarterCharacterScripts.rbxm` | `StarterPlayer.StarterCharacterScripts.rbxm` | 1 KB |
| `StarterPlayerScripts.rbxm` | `StarterPlayer.StarterPlayerScripts.rbxm` | 8 KB |

</details>

## Plantilla `BuildingSystem`

**65 archivos.**

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/Assets/VariableBuilds/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `EncimeraModernaEsquinaLeft.rbxm` | `ReplicatedStorage.Assets.VariableBuilds.EncimeraModernaEsquinaLeft.rbxm` | 9 KB |
| `EncimeraModernaEsquinaRight.rbxm` | `ReplicatedStorage.Assets.VariableBuilds.EncimeraModernaEsquinaRight.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `ConstruccionMode.rbxm` | `ReplicatedStorage.BuildInterface.ConstruccionMode.rbxm` | 37 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/Color/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `ColorTemplate.rbxm` | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Color.ColorTemplate.rbxm` | 10 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/Main/DesingFrame/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `ColorButton.rbxm` | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Main.DesingFrame.ColorButton.rbxm` | 7 KB |
| `MaterialButton.rbxm` | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Main.DesingFrame.MaterialButton.rbxm` | 17 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/Main/FurnitureFrame/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Template.rbxm` | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Main.FurnitureFrame.Template.rbxm` | 15 KB |
| `TemplateCoin.rbxm` | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Main.FurnitureFrame.TemplateCoin.rbxm` | 8 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/Main/Inventory/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Template.rbxm` | `ReplicatedStorage.BuildInterface.ConstructionModeModule.Main.Inventory.Template.rbxm` | 15 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/BuildInterface/ConstructionModeModule/MoveAndPlaceent/</code> — 3 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Beam.rbxm` | `ReplicatedStorage.BuildInterface.ConstructionModeModule.MoveAndPlaceent.Beam.rbxm` | 1 KB |
| `BillboardBuildingSystem.rbxm` | `ReplicatedStorage.BuildInterface.ConstructionModeModule.MoveAndPlaceent.BillboardBuildingSystem.rbxm` | 26 KB |
| `Highlight.rbxm` | `ReplicatedStorage.BuildInterface.ConstructionModeModule.MoveAndPlaceent.Highlight.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ReplicatedStorage/StoreTemplates/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `GaleryTemplate.rbxm` | `ReplicatedStorage.StoreTemplates.GaleryTemplate.rbxm` | 14 KB |
| `Simple.rbxm` | `ReplicatedStorage.StoreTemplates.Simple.rbxm` | 13 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ServerStorage/decoration template/House/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Sofa Confidente Que Escucha.rbxm` | `ServerStorage.decoration template.House.Sofa Confidente Que Escucha.rbxm` | 17 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ServerStorage/decoration template/Shared/</code> — 7 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Bar.rbxm` | `ServerStorage.decoration template.Shared.Bar.rbxm` | 123 KB |
| `Cuadro.rbxm` | `ServerStorage.decoration template.Shared.Cuadro.rbxm` | 8 KB |
| `Interruptor.rbxm` | `ServerStorage.decoration template.Shared.Interruptor.rbxm` | 5 KB |
| `Lampara aplique Serenity.rbxm` | `ServerStorage.decoration template.Shared.Lampara aplique Serenity.rbxm` | 14 KB |
| `Lampara de mesa Ambientia.rbxm` | `ServerStorage.decoration template.Shared.Lampara de mesa Ambientia.rbxm` | 20 KB |
| `Lampara de mesa Luminara.rbxm` | `ServerStorage.decoration template.Shared.Lampara de mesa Luminara.rbxm` | 15 KB |
| `Test.rbxm` | `ServerStorage.decoration template.Shared.Test.rbxm` | 4 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ServerStorage/decoration template/Shared/Interactable/</code> — 10 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Armarios.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Armarios.rbxm` | 107 KB |
| `Bath.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Bath.rbxm` | 92 KB |
| `Berth.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Berth.rbxm` | 104 KB |
| `Chair.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Chair.rbxm` | 347 KB |
| `Decoration.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Decoration.rbxm` | 55 KB |
| `Furniture.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Furniture.rbxm` | 180 KB |
| `Gym.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Gym.rbxm` | 22 KB |
| `Lamp.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Lamp.rbxm` | 114 KB |
| `Shower.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Shower.rbxm` | 40 KB |
| `Tables.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Tables.rbxm` | 182 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ServerStorage/decoration template/Shared/Interactable/Bed/</code> — 8 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Cama Cuna Rustica.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Bed.Cama Cuna Rustica.rbxm` | 39 KB |
| `Cama Individual Sueños Adolescentes.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Bed.Cama Individual Sueños Adolescentes.rbxm` | 33 KB |
| `Cama Individual con Orden.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Bed.Cama Individual con Orden.rbxm` | 25 KB |
| `Cama Individual metalica La Vintage.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Bed.Cama Individual metalica La Vintage.rbxm` | 49 KB |
| `Cama individual Descanso Primordial.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Bed.Cama individual Descanso Primordial.rbxm` | 30 KB |
| `Cama individual Pequeño Gran Niño.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Bed.Cama individual Pequeño Gran Niño.rbxm` | 35 KB |
| `Cama individual Soy Minimalista.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Bed.Cama individual Soy Minimalista.rbxm` | 48 KB |
| `Cuna El Infante.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Bed.Cuna El Infante.rbxm` | 40 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ServerStorage/decoration template/Shared/Interactable/CoffeePot/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Cafetera Elixir Matutino.rbxm` | `ServerStorage.decoration template.Shared.Interactable.CoffeePot.Cafetera Elixir Matutino.rbxm` | 16 KB |
| `Cafetera Eter De Cafe.rbxm` | `ServerStorage.decoration template.Shared.Interactable.CoffeePot.Cafetera Eter De Cafe.rbxm` | 19 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ServerStorage/decoration template/Shared/Interactable/Display/</code> — 3 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Monitor Pixelatelotodo.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Display.Monitor Pixelatelotodo.rbxm` | 12 KB |
| `PC Ordenador Atlas de Bits.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Display.PC Ordenador Atlas de Bits.rbxm` | 22 KB |
| `PC Ordenador Vintage Pulso Electronico.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Display.PC Ordenador Vintage Pulso Electronico.rbxm` | 25 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ServerStorage/decoration template/Shared/Interactable/DoubleBed/</code> — 7 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Cama Individual La Grandiosa.rbxm` | `ServerStorage.decoration template.Shared.Interactable.DoubleBed.Cama Individual La Grandiosa.rbxm` | 53 KB |
| `Cama de matrimonio modelo Cordelia.rbxm` | `ServerStorage.decoration template.Shared.Interactable.DoubleBed.Cama de matrimonio modelo Cordelia.rbxm` | 66 KB |
| `Cama doble Gran Confort.rbxm` | `ServerStorage.decoration template.Shared.Interactable.DoubleBed.Cama doble Gran Confort.rbxm` | 83 KB |
| `Cama doble La Perezosa.rbxm` | `ServerStorage.decoration template.Shared.Interactable.DoubleBed.Cama doble La Perezosa.rbxm` | 107 KB |
| `Cama doble Perritos Felices.rbxm` | `ServerStorage.decoration template.Shared.Interactable.DoubleBed.Cama doble Perritos Felices.rbxm` | 81 KB |
| `Cama doble Vaya Nochecita.rbxm` | `ServerStorage.decoration template.Shared.Interactable.DoubleBed.Cama doble Vaya Nochecita.rbxm` | 90 KB |
| `Cama individual Princesa de la Casa.rbxm` | `ServerStorage.decoration template.Shared.Interactable.DoubleBed.Cama individual Princesa de la Casa.rbxm` | 67 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ServerStorage/decoration template/Shared/Interactable/Encimeras/</code> — 6 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Encimera Moderna.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Encimeras.Encimera Moderna.rbxm` | 10 KB |
| `EncimeraModerna B.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Encimeras.EncimeraModerna B.rbxm` | 11 KB |
| `EncimeraModernaCut.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Encimeras.EncimeraModernaCut.rbxm` | 25 KB |
| `EncimeraModernaLavaboA.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Encimeras.EncimeraModernaLavaboA.rbxm` | 16 KB |
| `EncimeraModernaLavaboB.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Encimeras.EncimeraModernaLavaboB.rbxm` | 17 KB |
| `Horno.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Encimeras.Horno.rbxm` | 31 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ServerStorage/decoration template/Shared/Interactable/Kitchen/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Nevera Polo Culinario.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Kitchen.Nevera Polo Culinario.rbxm` | 133 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ServerStorage/decoration template/Shared/Interactable/Microwave/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Microondas Rayo Culinario.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Microwave.Microondas Rayo Culinario.rbxm` | 17 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ServerStorage/decoration template/Shared/Interactable/Party/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `DiscoBall.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Party.DiscoBall.rbxm` | 98 KB |
| `SmokeMachine.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Party.SmokeMachine.rbxm` | 23 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ServerStorage/decoration template/Shared/Interactable/Toilet/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Retrete inodoro Vater Emperador Augusto.rbxm` | `ServerStorage.decoration template.Shared.Interactable.Toilet.Retrete inodoro Vater Emperador Augusto.rbxm` | 26 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ServerStorage/decoration template/Shared/Interactable/WaterDispenser/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Fuente De Agua Oasis Urbano.rbxm` | `ServerStorage.decoration template.Shared.Interactable.WaterDispenser.Fuente De Agua Oasis Urbano.rbxm` | 16 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/BuildingSystem/ServerStorage/decoration template/Stores/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Lienzo.rbxm` | `ServerStorage.decoration template.Stores.Lienzo.rbxm` | 20 KB |

</details>

## Plantilla `Core`

**248 archivos.**

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/MaterialService/</code> — 8 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Aluminum.rbxm` | `MaterialService.Aluminum.rbxm` | 1 KB |
| `Dull Brass.rbxm` | `MaterialService.Dull Brass.rbxm` | 1 KB |
| `Good21.rbxm` | `MaterialService.Good21.rbxm` | 1 KB |
| `Smooth Fabric.rbxm` | `MaterialService.Smooth Fabric.rbxm` | 1 KB |
| `Test.rbxm` | `MaterialService.Test.rbxm` | 1 KB |
| `Wood Floor MV.rbxm` | `MaterialService.Wood Floor MV.rbxm` | 1 KB |
| `Wood3.rbxm` | `MaterialService.Wood3.rbxm` | 1 KB |
| `Wood4.rbxm` | `MaterialService.Wood4.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/MaterialService/Material_Base_Casa_1/</code> — 5 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Mat_Piscina.rbxm` | `MaterialService.Material_Base_Casa_1.Mat_Piscina.rbxm` | 1 KB |
| `Mat_Piso_Madera_1.rbxm` | `MaterialService.Material_Base_Casa_1.Mat_Piso_Madera_1.rbxm` | 1 KB |
| `Mat_Piso_Madera_2.rbxm` | `MaterialService.Material_Base_Casa_1.Mat_Piso_Madera_2.rbxm` | 1 KB |
| `Mat_Piso_Marmol.rbxm` | `MaterialService.Material_Base_Casa_1.Mat_Piso_Marmol.rbxm` | 1 KB |
| `Mat_Suelo_Piscina.rbxm` | `MaterialService.Material_Base_Casa_1.Mat_Suelo_Piscina.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Dummy.rbxm` | `ReplicatedStorage.Dummy.rbxm` | 36 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Effects/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `ArrowArea.rbxm` | `ReplicatedStorage.Assets.Effects.ArrowArea.rbxm` | 4 KB |
| `Glow.rbxm` | `ReplicatedStorage.Assets.Effects.Glow.rbxm` | 5 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Frames/Classic/</code> — 3 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `26x40.rbxm` | `ReplicatedStorage.Assets.Frames.Classic.26x40.rbxm` | 6 KB |
| `32x32.rbxm` | `ReplicatedStorage.Assets.Frames.Classic.32x32.rbxm` | 6 KB |
| `40x26.rbxm` | `ReplicatedStorage.Assets.Frames.Classic.40x26.rbxm` | 6 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Frames/Elegante/</code> — 3 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `26x40.rbxm` | `ReplicatedStorage.Assets.Frames.Elegante.26x40.rbxm` | 9 KB |
| `32x32.rbxm` | `ReplicatedStorage.Assets.Frames.Elegante.32x32.rbxm` | 9 KB |
| `40x26.rbxm` | `ReplicatedStorage.Assets.Frames.Elegante.40x26.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Frames/Enredado/</code> — 3 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `26x40.rbxm` | `ReplicatedStorage.Assets.Frames.Enredado.26x40.rbxm` | 9 KB |
| `32x32.rbxm` | `ReplicatedStorage.Assets.Frames.Enredado.32x32.rbxm` | 10 KB |
| `40x26.rbxm` | `ReplicatedStorage.Assets.Frames.Enredado.40x26.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Frames/Gold/</code> — 3 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `26x40.rbxm` | `ReplicatedStorage.Assets.Frames.Gold.26x40.rbxm` | 6 KB |
| `32x32.rbxm` | `ReplicatedStorage.Assets.Frames.Gold.32x32.rbxm` | 6 KB |
| `40x26.rbxm` | `ReplicatedStorage.Assets.Frames.Gold.40x26.rbxm` | 6 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Frames/Lava/</code> — 3 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `26x40.rbxm` | `ReplicatedStorage.Assets.Frames.Lava.26x40.rbxm` | 8 KB |
| `32x32.rbxm` | `ReplicatedStorage.Assets.Frames.Lava.32x32.rbxm` | 8 KB |
| `40x26.rbxm` | `ReplicatedStorage.Assets.Frames.Lava.40x26.rbxm` | 8 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Frames/Neon/</code> — 3 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `26x40.rbxm` | `ReplicatedStorage.Assets.Frames.Neon.26x40.rbxm` | 8 KB |
| `32x32.rbxm` | `ReplicatedStorage.Assets.Frames.Neon.32x32.rbxm` | 8 KB |
| `40x26.rbxm` | `ReplicatedStorage.Assets.Frames.Neon.40x26.rbxm` | 8 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Furnitures/</code> — 6 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `EncimeraModernaA.rbxm` | `ReplicatedStorage.Assets.Furnitures.EncimeraModernaA.rbxm` | 9 KB |
| `EncimeraModernaLavaboB.rbxm` | `ReplicatedStorage.Assets.Furnitures.EncimeraModernaLavaboB.rbxm` | 16 KB |
| `LamparaMagmaTeide.rbxm` | `ReplicatedStorage.Assets.Furnitures.LamparaMagmaTeide.rbxm` | 11 KB |
| `Mesa.rbxm` | `ReplicatedStorage.Assets.Furnitures.Mesa.rbxm` | 10 KB |
| `Pan.rbxm` | `ReplicatedStorage.Assets.Furnitures.Pan.rbxm` | 26 KB |
| `Pot.rbxm` | `ReplicatedStorage.Assets.Furnitures.Pot.rbxm` | 39 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Interactable/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `DiscoBeam.rbxm` | `ReplicatedStorage.Assets.Interactable.DiscoBeam.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Interactable/Billboard/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Bar.rbxm` | `ReplicatedStorage.Assets.Interactable.Billboard.Bar.rbxm` | 5 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Interactable/Pee/Animations/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Pee.rbxm` | `ReplicatedStorage.Assets.Interactable.Pee.Animations.Pee.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Interactable/Weight/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Animation.rbxm` | `ReplicatedStorage.Assets.Interactable.Weight.Animation.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Machines/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Basket-Ball.rbxm` | `ReplicatedStorage.Assets.Machines.Basket-Ball.rbxm` | 7 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Models/</code> — 4 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `CannonModel.rbxm` | `ReplicatedStorage.Assets.Models.CannonModel.rbxm` | 28 KB |
| `PeeModel.rbxm` | `ReplicatedStorage.Assets.Models.PeeModel.rbxm` | 13 KB |
| `SlimeBombMesh2.rbxm` | `ReplicatedStorage.Assets.Models.SlimeBombMesh2.rbxm` | 14 KB |
| `SlimeMesh.rbxm` | `ReplicatedStorage.Assets.Models.SlimeMesh.rbxm` | 13 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Models/BoxTools/Box/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Models.BoxTools.Box.Handle.rbxm` | 6 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Models/BoxTools/Box2/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Models.BoxTools.Box2.Handle.rbxm` | 5 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Models/LootBoxStage/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Box.rbxm` | `ReplicatedStorage.Assets.Models.LootBoxStage.Box.rbxm` | 38 KB |
| `BoxScenery.rbxm` | `ReplicatedStorage.Assets.Models.LootBoxStage.BoxScenery.rbxm` | 3 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Models/Trashes/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `trash1.rbxm` | `ReplicatedStorage.Assets.Models.Trashes.trash1.rbxm` | 17 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/NightClub/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Character.rbxm` | `ReplicatedStorage.Assets.NightClub.Character.rbxm` | 29 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Paint/</code> — 4 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `26x40.rbxm` | `ReplicatedStorage.Assets.Paint.26x40.rbxm` | 11 KB |
| `32x32.rbxm` | `ReplicatedStorage.Assets.Paint.32x32.rbxm` | 11 KB |
| `40x26.rbxm` | `ReplicatedStorage.Assets.Paint.40x26.rbxm` | 11 KB |
| `Model.rbxm` | `ReplicatedStorage.Assets.Paint.Model.rbxm` | 12 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Quests/PickableObjects/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `TestObject.rbxm` | `ReplicatedStorage.Assets.Quests.PickableObjects.TestObject.rbxm` | 11 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Quests/UI/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `QuestTemplate.rbxm` | `ReplicatedStorage.Assets.Quests.UI.QuestTemplate.rbxm` | 13 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Chocolate/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Chocolate.Handle.rbxm` | 7 KB |
| `drink.019.rbxm` | `ReplicatedStorage.Assets.Tools.Chocolate.drink.019.rbxm` | 4 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Pan Cortado.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Pan Cortado.rbxm` | 13 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/CoffeePot/Americano/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.CoffeePot.Americano.Handle.rbxm` | 7 KB |
| `drink.019.rbxm` | `ReplicatedStorage.Assets.Tools.Food.CoffeePot.Americano.drink.019.rbxm` | 4 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/CoffeePot/Cafe/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.CoffeePot.Cafe.Handle.rbxm` | 7 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/CoffeePot/Capuccino/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.CoffeePot.Capuccino.Handle.rbxm` | 6 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Preparada/Palomitas/Palomitas - 1/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Palomitas.Palomitas - 1.Handle.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Preparada/Palomitas/Palomitas - 2/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Palomitas.Palomitas - 2.Handle.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Preparada/Perritos Calientes/Perritos Calientes - 1/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Perritos Calientes.Perritos Calientes - 1.Handle.rbxm` | 7 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Preparada/Perritos Calientes/Perritos Calientes - 1/FoodNumber/</code> — 6 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `1.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Perritos Calientes.Perritos Calientes - 1.FoodNumber.1.rbxm` | 9 KB |
| `2.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Perritos Calientes.Perritos Calientes - 1.FoodNumber.2.rbxm` | 9 KB |
| `3.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Perritos Calientes.Perritos Calientes - 1.FoodNumber.3.rbxm` | 9 KB |
| `4.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Perritos Calientes.Perritos Calientes - 1.FoodNumber.4.rbxm` | 9 KB |
| `5.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Perritos Calientes.Perritos Calientes - 1.FoodNumber.5.rbxm` | 9 KB |
| `6.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Perritos Calientes.Perritos Calientes - 1.FoodNumber.6.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Preparada/Perritos Calientes/Perritos Calientes - 2/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Perritos Calientes.Perritos Calientes - 2.Handle.rbxm` | 7 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Preparada/Perritos Calientes/Perritos Calientes - 2/FoodNumber/</code> — 6 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `1.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Perritos Calientes.Perritos Calientes - 2.FoodNumber.1.rbxm` | 11 KB |
| `2.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Perritos Calientes.Perritos Calientes - 2.FoodNumber.2.rbxm` | 11 KB |
| `3.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Perritos Calientes.Perritos Calientes - 2.FoodNumber.3.rbxm` | 11 KB |
| `4.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Perritos Calientes.Perritos Calientes - 2.FoodNumber.4.rbxm` | 11 KB |
| `5.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Perritos Calientes.Perritos Calientes - 2.FoodNumber.5.rbxm` | 11 KB |
| `6.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Preparada.Perritos Calientes.Perritos Calientes - 2.FoodNumber.6.rbxm` | 11 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Principales/Albondigas con patatas/Albondigas con patatas - 1/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Albondigas con patatas.Albondigas con patatas - 1.Handle.rbxm` | 3 KB |
| `Model.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Albondigas con patatas.Albondigas con patatas - 1.Model.rbxm` | 20 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Principales/Albondigas con patatas/Albondigas con patatas - 2/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Albondigas con patatas.Albondigas con patatas - 2.Handle.rbxm` | 4 KB |
| `Model.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Albondigas con patatas.Albondigas con patatas - 2.Model.rbxm` | 32 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Principales/Albondigas con patatas/Albondigas con patatas - 3/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Albondigas con patatas.Albondigas con patatas - 3.Handle.rbxm` | 8 KB |
| `Model.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Albondigas con patatas.Albondigas con patatas - 3.Model.rbxm` | 22 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Principales/Huevos con bacon/Huevos con bacon - 1/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Huevos con bacon.Huevos con bacon - 1.Handle.rbxm` | 4 KB |
| `Model.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Huevos con bacon.Huevos con bacon - 1.Model.rbxm` | 28 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Principales/Huevos con bacon/Huevos con bacon - 2/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Huevos con bacon.Huevos con bacon - 2.Handle.rbxm` | 4 KB |
| `Model.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Huevos con bacon.Huevos con bacon - 2.Model.rbxm` | 21 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Principales/Huevos con bacon/Huevos con bacon - 3/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Huevos con bacon.Huevos con bacon - 3.Handle.rbxm` | 8 KB |
| `Model.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Huevos con bacon.Huevos con bacon - 3.Model.rbxm` | 16 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Principales/Pollo con verduras/Pollo con verduras - 1/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Pollo con verduras.Pollo con verduras - 1.Handle.rbxm` | 4 KB |
| `Model.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Pollo con verduras.Pollo con verduras - 1.Model.rbxm` | 30 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Principales/Pollo con verduras/Pollo con verduras - 2/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Pollo con verduras.Pollo con verduras - 2.Handle.rbxm` | 4 KB |
| `Model.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Pollo con verduras.Pollo con verduras - 2.Model.rbxm` | 31 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Principales/Pollo con verduras/Pollo con verduras - 3/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Pollo con verduras.Pollo con verduras - 3.Handle.rbxm` | 7 KB |
| `Model.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Kitchen.Principales.Pollo con verduras.Pollo con verduras - 3.Model.rbxm` | 20 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Other/PizzaCocinada/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinada.Handle.rbxm` | 7 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Other/PizzaCocinada/FoodNumber/</code> — 8 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `1.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinada.FoodNumber.1.rbxm` | 8 KB |
| `2.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinada.FoodNumber.2.rbxm` | 8 KB |
| `3.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinada.FoodNumber.3.rbxm` | 8 KB |
| `4.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinada.FoodNumber.4.rbxm` | 8 KB |
| `5.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinada.FoodNumber.5.rbxm` | 8 KB |
| `6.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinada.FoodNumber.6.rbxm` | 8 KB |
| `7.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinada.FoodNumber.7.rbxm` | 8 KB |
| `8.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinada.FoodNumber.8.rbxm` | 8 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Other/PizzaCocinadaCaja/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `AnimationController.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinadaCaja.AnimationController.rbxm` | 1 KB |
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinadaCaja.Handle.rbxm` | 14 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Other/PizzaCocinadaCaja/FoodNumber/</code> — 8 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `1.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinadaCaja.FoodNumber.1.rbxm` | 8 KB |
| `2.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinadaCaja.FoodNumber.2.rbxm` | 7 KB |
| `3.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinadaCaja.FoodNumber.3.rbxm` | 8 KB |
| `4.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinadaCaja.FoodNumber.4.rbxm` | 8 KB |
| `5.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinadaCaja.FoodNumber.5.rbxm` | 8 KB |
| `6.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinadaCaja.FoodNumber.6.rbxm` | 8 KB |
| `7.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinadaCaja.FoodNumber.7.rbxm` | 8 KB |
| `8.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Other.PizzaCocinadaCaja.FoodNumber.8.rbxm` | 8 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Overcooked/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Overcooked.Handle.rbxm` | 8 KB |
| `dish.009.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Overcooked.dish.009.rbxm` | 15 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Food/Pan Entero/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Content.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Pan Entero.Content.rbxm` | 13 KB |
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Food.Pan Entero.Handle.rbxm` | 4 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Fuegos artificales/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Fuegos artificales.Handle.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Gamepasses/Invisible/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Gamepasses.Invisible.Handle.rbxm` | 7 KB |
| `drink.019.rbxm` | `ReplicatedStorage.Assets.Tools.Gamepasses.Invisible.drink.019.rbxm` | 4 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Gamepasses/MagicClock/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Gamepasses.MagicClock.Handle.rbxm` | 7 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Grab/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Grab.Handle.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Mancuerna/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Mancuerna.Handle.rbxm` | 4 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/MenuBar/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `DrinkTest.rbxm` | `ReplicatedStorage.Assets.Tools.MenuBar.DrinkTest.rbxm` | 31 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Mop/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Mop.Handle.rbxm` | 4 KB |
| `Union2.rbxm` | `ReplicatedStorage.Assets.Tools.Mop.Union2.rbxm` | 3 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/OtherTools/Gym Mancuerna Baby/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.OtherTools.Gym Mancuerna Baby.Handle.rbxm` | 4 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Pistola Gancho/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Pistola Gancho.Handle.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Plate/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Plate.Handle.rbxm` | 7 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toy1/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Toy1.Handle.rbxm` | 7 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toy2/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Toy2.Handle.rbxm` | 7 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toy3/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Toy3.Handle.rbxm` | 8 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toy4/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Toy4.Handle.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toy5/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Toy5.Handle.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `SelfieStick.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.SelfieStick.rbxm` | 18 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/Ballon/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.Ballon.Handle.rbxm` | 13 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/BigPotion/</code> — 4 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Cylinder.001.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.BigPotion.Cylinder.001.rbxm` | 4 KB |
| `Cylinder.002.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.BigPotion.Cylinder.002.rbxm` | 8 KB |
| `Cylinder.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.BigPotion.Cylinder.rbxm` | 11 KB |
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.BigPotion.Handle.rbxm` | 4 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/BigPotion/MainTool/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Drink.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.BigPotion.MainTool.Drink.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/Cannon/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.Cannon.Handle.rbxm` | 2 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/GloveGun/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.GloveGun.Handle.rbxm` | 33 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/MiniPotion/</code> — 4 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Cylinder.001.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.MiniPotion.Cylinder.001.rbxm` | 4 KB |
| `Cylinder.002.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.MiniPotion.Cylinder.002.rbxm` | 8 KB |
| `Cylinder.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.MiniPotion.Cylinder.rbxm` | 11 KB |
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.MiniPotion.Handle.rbxm` | 4 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/MiniPotion/MainTool/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Drink.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.MiniPotion.MainTool.Drink.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/SlimeBomb/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.SlimeBomb.Handle.rbxm` | 18 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/SpyJetpack/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.SpyJetpack.Handle.rbxm` | 3 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/SpyJetpack/MainTool/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Jetpack.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.SpyJetpack.MainTool.Jetpack.rbxm` | 10 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/Tijeras/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Circle.001.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.Tijeras.Circle.001.rbxm` | 10 KB |
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.Tijeras.Handle.rbxm` | 11 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/Tools/Toys/Walkie/</code> — 3 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Handle.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.Walkie.Handle.rbxm` | 5 KB |
| `Listener.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.Walkie.Listener.rbxm` | 1 KB |
| `Transmitter.rbxm` | `ReplicatedStorage.Assets.Tools.Toys.Walkie.Transmitter.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/ToolsAssets/SccisorsAccesorys/</code> — 3 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Brown Floof Hair.rbxm` | `ReplicatedStorage.Assets.ToolsAssets.SccisorsAccesorys.Brown Floof Hair.rbxm` | 4 KB |
| `BrownNeatBoyHair.rbxm` | `ReplicatedStorage.Assets.ToolsAssets.SccisorsAccesorys.BrownNeatBoyHair.rbxm` | 5 KB |
| `Hair.rbxm` | `ReplicatedStorage.Assets.ToolsAssets.SccisorsAccesorys.Hair.rbxm` | 6 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/ToolsAssets/SccisorsAssets/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Sounds.rbxm` | `ReplicatedStorage.Assets.ToolsAssets.SccisorsAssets.Sounds.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/UI/</code> — 3 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `InteractionMessageUI.rbxm` | `ReplicatedStorage.Assets.UI.InteractionMessageUI.rbxm` | 10 KB |
| `JetpackMobileButtons.rbxm` | `ReplicatedStorage.Assets.UI.JetpackMobileButtons.rbxm` | 4 KB |
| `SellHousePrompt.rbxm` | `ReplicatedStorage.Assets.UI.SellHousePrompt.rbxm` | 18 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/UI/Banners/</code> — 3 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `BailesEnOferta.rbxm` | `ReplicatedStorage.Assets.UI.Banners.BailesEnOferta.rbxm` | 18 KB |
| `CasasEnOferta.rbxm` | `ReplicatedStorage.Assets.UI.Banners.CasasEnOferta.rbxm` | 15 KB |
| `Destacado.rbxm` | `ReplicatedStorage.Assets.UI.Banners.Destacado.rbxm` | 11 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Assets/VisualItems/</code> — 9 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Ballon.rbxm` | `ReplicatedStorage.Assets.VisualItems.Ballon.rbxm` | 11 KB |
| `Cannon.rbxm` | `ReplicatedStorage.Assets.VisualItems.Cannon.rbxm` | 25 KB |
| `GloveGun.rbxm` | `ReplicatedStorage.Assets.VisualItems.GloveGun.rbxm` | 27 KB |
| `Pocion.rbxm` | `ReplicatedStorage.Assets.VisualItems.Pocion.rbxm` | 13 KB |
| `SelfieStick.rbxm` | `ReplicatedStorage.Assets.VisualItems.SelfieStick.rbxm` | 13 KB |
| `SlimeBomb.rbxm` | `ReplicatedStorage.Assets.VisualItems.SlimeBomb.rbxm` | 17 KB |
| `SpyJetpack.rbxm` | `ReplicatedStorage.Assets.VisualItems.SpyJetpack.rbxm` | 4 KB |
| `Tijeras.rbxm` | `ReplicatedStorage.Assets.VisualItems.Tijeras.rbxm` | 21 KB |
| `Walkie.rbxm` | `ReplicatedStorage.Assets.VisualItems.Walkie.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/Animator/Actions/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Bartender1.rbxm` | `ReplicatedStorage.Client.Animator.Actions.Bartender1.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/Animator/Movimientos/</code> — 10 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `climb.rbxm` | `ReplicatedStorage.Client.Animator.Movimientos.climb.rbxm` | 1 KB |
| `climbRun.rbxm` | `ReplicatedStorage.Client.Animator.Movimientos.climbRun.rbxm` | 1 KB |
| `fall.rbxm` | `ReplicatedStorage.Client.Animator.Movimientos.fall.rbxm` | 1 KB |
| `idle.rbxm` | `ReplicatedStorage.Client.Animator.Movimientos.idle.rbxm` | 1 KB |
| `jump.rbxm` | `ReplicatedStorage.Client.Animator.Movimientos.jump.rbxm` | 1 KB |
| `run.rbxm` | `ReplicatedStorage.Client.Animator.Movimientos.run.rbxm` | 1 KB |
| `sit.rbxm` | `ReplicatedStorage.Client.Animator.Movimientos.sit.rbxm` | 1 KB |
| `swim.rbxm` | `ReplicatedStorage.Client.Animator.Movimientos.swim.rbxm` | 1 KB |
| `swimIdle.rbxm` | `ReplicatedStorage.Client.Animator.Movimientos.swimIdle.rbxm` | 1 KB |
| `walk.rbxm` | `ReplicatedStorage.Client.Animator.Movimientos.walk.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/animation/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Template.rbxm` | `ReplicatedStorage.Client.animation.Template.rbxm` | 3 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/ActionWheel/Assets/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Billboard.rbxm` | `ReplicatedStorage.Client.interactable.Interactable.ActionWheel.Assets.Billboard.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/ActionWheel/Page/UI/Assets/</code> — 4 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `ActionButton.rbxm` | `ReplicatedStorage.Client.interactable.Interactable.ActionWheel.Page.UI.Assets.ActionButton.rbxm` | 9 KB |
| `ControlButton.rbxm` | `ReplicatedStorage.Client.interactable.Interactable.ActionWheel.Page.UI.Assets.ControlButton.rbxm` | 8 KB |
| `Page.rbxm` | `ReplicatedStorage.Client.interactable.Interactable.ActionWheel.Page.UI.Assets.Page.rbxm` | 1 KB |
| `PageButton.rbxm` | `ReplicatedStorage.Client.interactable.Interactable.ActionWheel.Page.UI.Assets.PageButton.rbxm` | 11 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Interactable/CustomPrompt/Assets/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `ProximityPromptUI.rbxm` | `ReplicatedStorage.Client.interactable.Interactable.CustomPrompt.Assets.ProximityPromptUI.rbxm` | 14 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/interactable/Treadmill/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `RunAnimation.rbxm` | `ReplicatedStorage.Client.interactable.Treadmill.RunAnimation.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/inventory/InventoryList/InventoryItem/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `frame.rbxm` | `ReplicatedStorage.Client.inventory.InventoryList.InventoryItem.frame.rbxm` | 10 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/Roulette/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `SurfaceGuiPart.rbxm` | `ReplicatedStorage.Client.machines.Roulette.SurfaceGuiPart.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Client/machines/ToyMachine/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `ScreenGui.rbxm` | `ReplicatedStorage.Client.machines.ToyMachine.ScreenGui.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Events/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `BartenderSystem.rbxm` | `ReplicatedStorage.Events.BartenderSystem.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/BartenderSystem/Instance/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Rig.rbxm` | `ReplicatedStorage.Shared.BartenderSystem.Instance.Rig.rbxm` | 43 KB |
| `Template.rbxm` | `ReplicatedStorage.Shared.BartenderSystem.Instance.Template.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/ComprasTablero/</code> — 2 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Template.rbxm` | `ReplicatedStorage.Shared.ComprasTablero.Template.rbxm` | 11 KB |
| `TemplateLeaderboard.rbxm` | `ReplicatedStorage.Shared.ComprasTablero.TemplateLeaderboard.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/GuideService/PageController/InterfaceController/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `InterfaceGuide.rbxm` | `ReplicatedStorage.Shared.GuideService.PageController.InterfaceController.InterfaceGuide.rbxm` | 12 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/GuideService/PageController/VerificacionPages/</code> — 3 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Copy.rbxm` | `ReplicatedStorage.Shared.GuideService.PageController.VerificacionPages.Copy.rbxm` | 6 KB |
| `Image.rbxm` | `ReplicatedStorage.Shared.GuideService.PageController.VerificacionPages.Image.rbxm` | 4 KB |
| `TextLabel.rbxm` | `ReplicatedStorage.Shared.GuideService.PageController.VerificacionPages.TextLabel.rbxm` | 4 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Icon/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `PackageLink.rbxm` | `ReplicatedStorage.Shared.Icon.PackageLink.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/JobSystem/ButtonMoney/Billetes/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Billete.rbxm` | `ReplicatedStorage.Shared.JobSystem.ButtonMoney.Billetes.Billete.rbxm` | 6 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/JobSystem/CajasTransport/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Idle.rbxm` | `ReplicatedStorage.Shared.JobSystem.CajasTransport.Idle.rbxm` | 1 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Karaoke/KaraokeTV/TV/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `KaraokeTemplate.rbxm` | `ReplicatedStorage.Shared.Karaoke.KaraokeTV.TV.KaraokeTemplate.rbxm` | 11 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Nametag/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `NameTag.rbxm` | `ReplicatedStorage.Shared.Nametag.NameTag.rbxm` | 9 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Nametag/GroupRoles/Templates/</code> — 9 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `4Admin.rbxm` | `ReplicatedStorage.Shared.Nametag.GroupRoles.Templates.4Admin.rbxm` | 4 KB |
| `4ContentCreator.rbxm` | `ReplicatedStorage.Shared.Nametag.GroupRoles.Templates.4ContentCreator.rbxm` | 4 KB |
| `4Dev.rbxm` | `ReplicatedStorage.Shared.Nametag.GroupRoles.Templates.4Dev.rbxm` | 4 KB |
| `4Mod.rbxm` | `ReplicatedStorage.Shared.Nametag.GroupRoles.Templates.4Mod.rbxm` | 4 KB |
| `4Owner.rbxm` | `ReplicatedStorage.Shared.Nametag.GroupRoles.Templates.4Owner.rbxm` | 4 KB |
| `5Vip.rbxm` | `ReplicatedStorage.Shared.Nametag.GroupRoles.Templates.5Vip.rbxm` | 4 KB |
| `6CloseMic.rbxm` | `ReplicatedStorage.Shared.Nametag.GroupRoles.Templates.6CloseMic.rbxm` | 7 KB |
| `6NoMic.rbxm` | `ReplicatedStorage.Shared.Nametag.GroupRoles.Templates.6NoMic.rbxm` | 7 KB |
| `6OpenMic.rbxm` | `ReplicatedStorage.Shared.Nametag.GroupRoles.Templates.6OpenMic.rbxm` | 7 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Paint/Load/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `Template.rbxm` | `ReplicatedStorage.Shared.Paint.Load.Template.rbxm` | 10 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/Paint/Load/LoadFrame/</code> — 3 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `TemplateGamepasses.rbxm` | `ReplicatedStorage.Shared.Paint.Load.LoadFrame.TemplateGamepasses.rbxm` | 11 KB |
| `TemplateMarcos.rbxm` | `ReplicatedStorage.Shared.Paint.Load.LoadFrame.TemplateMarcos.rbxm` | 9 KB |
| `TemplateType.rbxm` | `ReplicatedStorage.Shared.Paint.Load.LoadFrame.TemplateType.rbxm` | 4 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/ReplicatedStorage/Shared/PrompBuy/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `FrameBuy.rbxm` | `ReplicatedStorage.Shared.PrompBuy.FrameBuy.rbxm` | 15 KB |

</details>

<details>
<summary><code>src/ServerStorage/TemplatesTesting/Core/StarterGui/</code> — 15 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `AnimationsUI.rbxm` | `StarterGui.AnimationsUI.rbxm` | 23 KB |
| `ExitUI.rbxm` | `StarterGui.ExitUI.rbxm` | 5 KB |
| `FoodUI.rbxm` | `StarterGui.FoodUI.rbxm` | 27 KB |
| `GamePassOwnershipNotice.rbxm` | `StarterGui.GamePassOwnershipNotice.rbxm` | 11 KB |
| `InventoryUI.rbxm` | `StarterGui.InventoryUI.rbxm` | 15 KB |
| `LymMain.rbxm` | `StarterGui.LymMain.rbxm` | 140 KB |
| `NotificationsUI.rbxm` | `StarterGui.NotificationsUI.rbxm` | 14 KB |
| `PAndSUi.rbxm` | `StarterGui.PAndSUi.rbxm` | 27 KB |
| `PlayPrompt.rbxm` | `StarterGui.PlayPrompt.rbxm` | 12 KB |
| `Prompt.rbxm` | `StarterGui.Prompt.rbxm` | 12 KB |
| `Roulette.rbxm` | `StarterGui.Roulette.rbxm` | 17 KB |
| `StatsUI.rbxm` | `StarterGui.StatsUI.rbxm` | 19 KB |
| `Walkie.rbxm` | `StarterGui.Walkie.rbxm` | 15 KB |
| `WorldSystemUI.rbxm` | `StarterGui.WorldSystemUI.rbxm` | 222 KB |
| `dialog.rbxm` | `StarterGui.dialog.rbxm` | 11 KB |

</details>

## Plantilla `PlayerHouses`

**1 archivos.**

<details>
<summary><code>src/ServerStorage/TemplatesTesting/PlayerHouses/StarterGui/</code> — 1 archivo(s)</summary>

| Archivo | Ruta en ejecución | Tamaño |
|---|---|---|
| `PermsGui.rbxm` | `StarterGui.PermsGui.rbxm` | 40 KB |

</details>
