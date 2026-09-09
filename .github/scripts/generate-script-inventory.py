"""Regenera el inventario de scripts en docs/reference/.

These pages are generated, not hand-written: they are a mechanical census of the
repository, and hand-maintaining them would guarantee they drift. Re-run this
script after adding, removing or renaming files, and commit the result.

Run from the repository root:  python3 .github/scripts/generate-script-inventory.py

The status sets near the top are the one hand-maintained part: they record how
far the documentation project has read each file. Update them as files are read.
"""

import os, json, collections

ROOT = "src"
ANALYSED = {
    "src/ServerScriptService/ImportTemplates.server.luau",
    "src/ServerScriptService/InitScripts.server.luau",
    "src/ReplicatedStorage/InitAfterTemplates.luau",
    "src/ReplicatedStorage/PlayerInit.luau",
    "src/ReplicatedStorage/Client/visualsManager.server.luau",
}
def t(*parts):
    return "src/ServerStorage/TemplatesTesting/" + "/".join(parts)

# Librerias externas. No se leen por dentro: su papel y sus consumidores estan en
# docs/architecture/third-party.md, y su documentacion real vive aguas arriba.
# Marcarlas "Analizado (en parte)" seria mentir: no se han leido en absoluto.
THIRD_PARTY_PREFIXES = tuple(t(x) + "/" for x in (
    "Core/ReplicatedStorage/Shared/Sift",
    "Core/ReplicatedStorage/Shared/Icon",
    "Core/ReplicatedStorage/Kinetic",
    "Core/ReplicatedStorage/Shared/Promise",
    "Core/ReplicatedStorage/Shared/FastCastRedux",
    "Core/ReplicatedStorage/Shared/Observers",
    "Core/ReplicatedStorage/Shared/PartCache",
)) + (t("Core/ReplicatedStorage/Shared/Trove.luau"),
      t("Core/ReplicatedStorage/Shared/Signal.luau"),
      t("Core/ReplicatedStorage/Shared/Spring.luau"),
      t("Core/ReplicatedStorage/Shared/lerp.luau"))
ANALYSED |= {
    t("Core/ServerScriptService/ServerScripts/WorldManager.server.luau"),
    t("Core/ServerScriptService/ServerScripts/playerManager.server.luau"),
    t("Core/ServerScriptService/ServerScripts/PlayerDataReplicator.server.luau"),
    t("Core/ServerScriptService/ServerScripts/ServerDirectory.server.luau"),
    t("Core/ServerScriptService/ServerScripts/WorldsBrowser.server.luau"),
    t("Core/ServerStorage/WorldSystem/ServerPresence.luau"),
    t("Core/ServerStorage/WorldSystem/Profiles.luau"),
    t("Core/ServerStorage/WorldSystem/PlayerSchema.luau"),
    t("Core/ReplicatedStorage/HousesInfo.luau"),
    t("Core/ReplicatedStorage/GeneralConfiguration.luau"),
    t("Core/ReplicatedStorage/Client/PlayerManager.server.luau"),
    t("Core/ReplicatedStorage/Client/MainPS.server.luau"),
    t("Core/StarterGui/LocalScript.client.luau"),
    t("Core/ServerStorage/DataKit/init.luau"),
    t("Core/ServerStorage/DataKit/Profile.luau"),
    t("Core/ServerStorage/DataKit/Lease.luau"),
    t("Core/ServerStorage/DataKit/Mutex.luau"),
    t("Core/ServerStorage/DataKit/Health.luau"),
    t("GameWorlds/ServerScriptService/ServerScripts/PublicServerInit.lua.server.luau"),
    t("PlayerHouses/ServerScriptService/PlayerWorld_Init.lua.server.luau"),
    t("PlayerHouses/ServerScriptService/WorldService.luau"),
    t("PlayerHouses/ServerScriptService/WorldDataReplicator.server.luau"),
    t("PlayerHouses/ServerScriptService/ModeratorManager.server.luau"),
    t("PlayerHouses/ReplicatedStorage/RolesInfo.luau"),
    t("Core/ServerStorage/WorldSystem/PlayerDataService.luau"),
    t("Core/ServerStorage/WorldSystem/PlayerDataReplicator.luau"),
    t("Core/ServerScriptService/ServerScripts/PlayerDataInit.server.luau"),
    t("Core/ReplicatedStorage/Client/EconomySystem/Collections.luau"),
    t("Core/ServerStorage/WorldSystem/EventService.luau"),
    t("Core/ServerScriptService/ServerScripts/EventBootstrap.server.luau"),
    t("Core/ServerStorage/WorldSystem/ReferralService.luau"),
    t("Core/ServerScriptService/Data/Main/init.server.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/init.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/HouseAdded.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/ColorTexture.luau"),
    t("Core/ReplicatedStorage/Shared/BreakDown.luau"),
    t("Core/ReplicatedStorage/Shared/Monetization/init.luau"),
    t("Core/ReplicatedStorage/Shared/Monetization/MainModule.luau"),
    t("Core/ReplicatedStorage/Shared/Monetization/MarkAdded.luau"),
    t("Core/ReplicatedStorage/Shared/Monetization/Beneficios.luau"),
    t("Core/ServerStorage/WorldSystem/GamePassService/init.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/DecorsPlayer.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/DecorFuncs/init.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/DecorFuncs/AddedDecor/init.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/DecorFuncs/AddedDecor/Collitions.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/Added.luau"),
    t("Core/ReplicatedStorage/Client/interactable/init.server.luau"),
    t("Core/ReplicatedStorage/Shared/bindToTag.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/MusicPlayer.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Bin.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/CuadrosPaint.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Display.server.luau"),
    t("Core/ServerScriptService/ServerScripts/inventory/init.server.luau"),
    t("Core/ServerScriptService/ServerScripts/inventory/InventoryManager/init.luau"),
    t("Core/ServerScriptService/ServerScripts/inventory/InventoryManager/DefaultTools.luau"),
    t("Core/ReplicatedStorage/Shared/Karaoke/init.luau"),
    t("Core/ReplicatedStorage/Shared/Paint/FormatPinturaData/init.luau"),
    t("Core/ServerScriptService/ServerScripts/AnimationSystem/init.server.luau"),
    t("Core/ServerScriptService/ServerScripts/Quests/QuestMain.server.luau"),
    t("Core/ReplicatedStorage/Shared/JobSystem/init.luau"),
    t("Core/ReplicatedStorage/Shared/JobSystem/ConditionsUses.luau"),
    t("Core/ServerStorage/WorldSystem/GiftInbox.luau"),
    t("Core/ServerStorage/GlobalDataStore/ReadMe.server.luau"),
    t("Core/ReplicatedStorage/Shared/BartenderSystem/init.luau"),
    t("Core/ReplicatedStorage/ShopInfo.luau"),
    t("Core/ReplicatedStorage/Shared/Running.luau"),
    t("Core/ServerScriptService/ServerScripts/cooking/CookingStation.luau"),
    t("Core/ServerScriptService/ServerScripts/cooking/interactables/Blender.server.luau"),
    t("Core/ServerScriptService/ServerScripts/cooking/interactables/Oven.server.luau"),
    t("Core/ServerScriptService/ServerScripts/cooking/interactables/Stove.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/BarraBartender.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Bath.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Bin.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/ClassicDoor.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/CuadrosPaint.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/DiscoBall.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Display.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Fridge.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Lamp.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/MusicPlayer.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/NpcDialog.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Paint.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Pee.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Seat.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Shower.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/SmokeMachine.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Tijeras.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Toilet.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Treadmill.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Washbasin.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Weight.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Bed/Bed.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/Bed/init.server.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/DoubleBed/DoubleBed.luau"),
    t("Core/ServerScriptService/ServerScripts/interactable/DoubleBed/init.server.luau"),
    t("Core/ReplicatedStorage/Shared/Cooldown/CooldownManager.luau"),
    t("Core/ReplicatedStorage/Shared/Cooldown/CooldownShared.luau"),
    t("Core/ServerScriptService/ServerScripts/WalkieServer.server.luau"),
    t("Core/ServerScriptService/ServerScripts/collisions.server.luau"),
    t("Core/ServerScriptService/ServerScripts/fireExcept.luau"),
    t("Core/ServerScriptService/ServerScripts/ToolModelGenerator/init.server.luau"),
    t("Core/ServerScriptService/ServerScripts/ToolModelGenerator/Settings.luau"),
    t("Core/ReplicatedStorage/Assets/Tools/Toys/Walkie/LocalScript.client.luau"),
    t("Core/ReplicatedStorage/Client/InsertService.luau"),
    t("Core/ReplicatedStorage/Client/topbar.server.luau"),
    t("Core/ReplicatedStorage/Client/Event.luau"),
    t("Core/ReplicatedStorage/Client/Disconnects.luau"),
    t("Core/ReplicatedStorage/Client/PaintActives.luau"),
    t("Core/ServerScriptService/ServerScripts/machines/Machine.luau"),
    t("Core/ServerScriptService/ServerScripts/machines/MachineFactory.luau"),
    t("Core/ServerScriptService/ServerScripts/machines/init.server.luau"),
    t("Core/ServerScriptService/ServerScripts/machines/Roulette.luau"),
    t("Core/ServerScriptService/ServerScripts/machines/ToyMachine.luau"),
    t("Core/ServerScriptService/ServerScripts/machines/Stacker.luau"),
    t("Core/ServerScriptService/ServerScripts/machines/PopTheLock.luau"),
    t("Core/ServerScriptService/ServerScripts/machines/Basketball.luau"),
    t("Core/ReplicatedStorage/Shared/machines/roulettePrizes.luau"),
    t("Core/ReplicatedStorage/Shared/machines/rouletteUtil.luau"),
    t("Core/ReplicatedStorage/Client/interactable/ButtonVipMoney.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Computer.luau"),
    t("Core/ReplicatedStorage/Client/interactable/PlaceTool.luau"),
    t("Core/ReplicatedStorage/Client/interactable/PurchaseGamepass.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Stores.luau"),
    t("Core/ReplicatedStorage/Client/interactable/init.server.luau"),
    t("Core/ReplicatedStorage/Client/interactable/test.luau"),
    t("Core/ReplicatedStorage/Shared/SignalsGame.luau"),
    t("Core/ReplicatedStorage/Shared/Commands.luau"),
    t("Core/ReplicatedStorage/Shared/KeyGenerator.luau"),
    t("Core/ReplicatedStorage/Shared/VoiceModulator.luau"),
    t("Core/ReplicatedStorage/Shared/NetworkTimer.luau"),
    t("Core/ReplicatedStorage/Shared/InfoCoins.luau"),
    t("Core/ReplicatedStorage/Shared/attach.luau"),
    t("Core/ReplicatedStorage/Shared/lerp.luau"),
    t("Core/ReplicatedStorage/Shared/AssetsToPreload.luau"),
    t("Core/ReplicatedStorage/Shared/Clock.luau"),
    t("Core/ReplicatedStorage/Shared/CircularBuffer.luau"),
    t("Core/ReplicatedStorage/Shared/Spring.luau"),
    t("Core/ReplicatedStorage/Shared/makeClientPart.luau"),
    t("Core/ReplicatedStorage/Shared/CollisionModule.luau"),
    t("Core/ReplicatedStorage/Shared/ComprasTablero/init.luau"),
    t("Core/ReplicatedStorage/Shared/ComprasTablero/Settings.luau"),
    t("Core/ReplicatedStorage/Shared/GuideService/init.luau"),
    t("Core/ReplicatedStorage/Shared/GuideService/Server/init.luau"),
    t("Core/ReplicatedStorage/Shared/GuideService/Server/Rewards.luau"),
    t("Core/ReplicatedStorage/Shared/GuideService/Disconnects.luau"),
    t("Core/ReplicatedStorage/Shared/GuideService/QuitarEspacios.luau"),
    t("Core/ReplicatedStorage/Shared/GuideService/PageController/init.luau"),
    t("Core/ReplicatedStorage/Shared/GuideService/PageController/VerificacionPages/init.luau"),
    t("Core/ReplicatedStorage/Shared/Tutorials/ParametrosGuideClaim.luau"),
    t("Core/ReplicatedStorage/Shared/Tutorials/ParametrosTutorialBienvenida.luau"),
}
PARTIAL = {
    t("Core/ServerStorage/DataKit/Store.luau"),
    t("Core/ServerStorage/DataKit/BaseStore.luau"),
    t("Core/ServerScriptService/ServerScripts/ShopServerSystem.server.luau"),
    t("Core/ServerStorage/RoleService/init.luau"),
    t("Core/ServerScriptService/ServerScripts/machines/Machine.luau"),
    t("Core/ServerScriptService/ServerScripts/machines/PopTheLock.luau"),
    t("Core/ServerScriptService/ServerScripts/EventCommands.server.luau"),
    t("Core/ReplicatedStorage/Shared/AddValues.luau"),
    t("Core/ReplicatedStorage/Shared/Stores/Compras.luau"),
    t("Core/ServerStorage/WorldSystem/GamePassService/GamePassRewards.luau"),
    t("Core/ServerScriptService/Data/Main/PlayerGamesFetcher.luau"),
    t("Core/ServerStorage/SoundInfo.luau"),
    t("Core/ReplicatedStorage/Client/Posicionamientos.luau"),
    t("Core/ServerScriptService/ServerScripts/stats/init.server.luau"),
    t("Core/ServerScriptService/ServerScripts/NametagServer.server.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Interactable/init.luau"),
    t("Core/ServerScriptService/ServerScripts/ToolsServer.server.luau"),
    t("Core/ReplicatedStorage/Shared/Karaoke/RevisarCanciones/init.luau"),
    t("Core/ReplicatedStorage/Shared/Karaoke/CrearCancion/init.luau"),
    t("Core/ReplicatedStorage/Shared/Paint/ServerClient/init.luau"),
    t("Core/ServerScriptService/ServerScripts/Quests/QuestService.luau"),
    t("Core/ServerScriptService/ServerScripts/machines/init.server.luau"),
    t("Core/ServerScriptService/ServerScripts/cooking/CookingStation.luau"),
    t("Core/ServerScriptService/ServerScripts/cooking/CuttingBoard.server.luau"),
    t("Core/ReplicatedStorage/Shared/JobSystem/ButtonMoney/init.luau"),
    t("Core/ServerStorage/GlobalDataStore/init.luau"),
    t("Core/ServerStorage/BusquedaMusicas.luau"),
    t("Core/ServerScriptService/ServerScripts/LootBoxService.server.luau"),
    t("Core/ServerScriptService/ServerScripts/PlaytimeRewardSystem.server.luau"),
    t("Core/ServerScriptService/ServerScripts/FavoriteService.server.luau"),
    t("Core/ReplicatedStorage/DancesInfo.luau"),
    t("Core/ReplicatedStorage/Shared/Referrals/ReferralConfig.luau"),
    t("Core/ServerScriptService/ServerScripts/Referrals/ReferralMain.server.luau"),
    t("Core/ServerScriptService/ServerScripts/MicManagerServer.server.luau"),
    t("Core/ServerScriptService/ServerScripts/ToolPlacementServer.server.luau"),
    t("Core/ReplicatedStorage/Shared/Karaoke/KaraokeTV/init.luau"),
    t("Core/ReplicatedStorage/Shared/Karaoke/KaraokeTV/FunctActionsTV.luau"),
    t("Core/ReplicatedStorage/Shared/Karaoke/KaraokeTV/TV/init.luau"),
    t("Core/ServerScriptService/ServerScripts/GiftHandler.server.luau"),
    t("Core/ReplicatedStorage/Shared/BartenderSystem/Instance/init.luau"),
    t("Core/ReplicatedStorage/Shared/NPC_Custom/init.luau"),
    t("Core/ReplicatedStorage/Shared/NPC_Custom/Actions.luau"),
    t("Core/ReplicatedStorage/Shared/NPC_Custom/Instance/init.luau"),
    t("Core/ReplicatedStorage/Shared/NPC_Custom/Instance/CustomizeSettings.luau"),
    t("Core/ReplicatedStorage/Shared/NPC_Custom/Instance/FormatPathNpc.luau"),
    t("Core/ReplicatedStorage/Shared/DialogModule/init.luau"),
    t("Core/ReplicatedStorage/Shared/Trove.luau"),
    t("Core/ServerScriptService/ServerScripts/cooking/interactables/Microwave.server.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/None.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Types.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/init.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/copy.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/copyDeep.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/count.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/entries.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/equals.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/equalsDeep.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/every.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/filter.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/flatten.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/flip.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/freeze.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/freezeDeep.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/fromArrays.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/fromEntries.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/has.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/includes.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/init.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/keys.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/map.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/merge.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/mergeDeep.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/removeKey.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/removeKeys.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/removeValue.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/removeValues.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/set.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/some.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/update.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/values.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Dictionary/withKeys.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Util/equalObjects.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Util/func.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Util/init.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Util/isEmpty.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/at.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/concat.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/concatDeep.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/copy.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/copyDeep.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/count.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/create.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/difference.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/differenceSymmetric.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/equals.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/equalsDeep.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/every.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/filter.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/find.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/findLast.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/findWhere.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/findWhereLast.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/first.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/flatten.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/freeze.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/freezeDeep.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/includes.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/init.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/insert.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/is.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/last.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/map.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/pop.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/push.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/reduce.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/reduceRight.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/removeIndex.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/removeIndices.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/removeValue.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/removeValues.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/reverse.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/set.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/shift.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/shuffle.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/slice.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/some.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/sort.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/splice.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/toSet.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/unshift.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/update.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/zip.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Array/zipAll.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/add.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/copy.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/count.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/delete.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/difference.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/differenceSymmetric.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/filter.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/fromArray.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/has.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/init.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/intersection.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/isSubset.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/isSuperset.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/map.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/merge.luau"),
    t("Core/ReplicatedStorage/Shared/Sift/Set/toArray.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Attribute.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Reference.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Types.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Utility.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/VERSION.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/init.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Elements/Caption.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Elements/Container.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Elements/Dropdown.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Elements/Indicator.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Elements/Menu.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Elements/Notice.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Elements/Selection.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Elements/Widget.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Packages/GoodSignal.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Packages/Janitor.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Features/Gamepad.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Features/Overflow.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Features/Themes/Classic.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Features/Themes/Default.luau"),
    t("Core/ReplicatedStorage/Shared/Icon/Features/Themes/init.luau"),
    t("Core/ReplicatedStorage/Kinetic/debug.luau"),
    t("Core/ReplicatedStorage/Kinetic/init.luau"),
    t("Core/ReplicatedStorage/Kinetic/types.luau"),
    t("Core/ReplicatedStorage/Kinetic/util/Completion.luau"),
    t("Core/ReplicatedStorage/Kinetic/util/Signal.luau"),
    t("Core/ReplicatedStorage/Kinetic/util/timeGuard.luau"),
    t("Core/ReplicatedStorage/Kinetic/constants/configs.luau"),
    t("Core/ReplicatedStorage/Kinetic/constants/easings.luau"),
    t("Core/ReplicatedStorage/Kinetic/constants/init.luau"),
    t("Core/ReplicatedStorage/Kinetic/orchestration/Transition.luau"),
    t("Core/ReplicatedStorage/Kinetic/orchestration/init.luau"),
    t("Core/ReplicatedStorage/Kinetic/animatable/adapters.luau"),
    t("Core/ReplicatedStorage/Kinetic/animatable/color.luau"),
    t("Core/ReplicatedStorage/Kinetic/animatable/init.luau"),
    t("Core/ReplicatedStorage/Kinetic/targets/instance.luau"),
    t("Core/ReplicatedStorage/Kinetic/core/AnimationConfig.luau"),
    t("Core/ReplicatedStorage/Kinetic/core/Controller.luau"),
    t("Core/ReplicatedStorage/Kinetic/core/FrameLoop.luau"),
    t("Core/ReplicatedStorage/Kinetic/core/Interpolation.luau"),
    t("Core/ReplicatedStorage/Kinetic/core/SpringValue.luau"),
    t("Core/ReplicatedStorage/Shared/Promise/init.luau"),
    t("Core/ReplicatedStorage/Shared/Promise/init.spec.luau"),
    t("Core/ReplicatedStorage/Shared/FastCastRedux/ActiveCast.luau"),
    t("Core/ReplicatedStorage/Shared/FastCastRedux/Signal.luau"),
    t("Core/ReplicatedStorage/Shared/FastCastRedux/Table.luau"),
    t("Core/ReplicatedStorage/Shared/FastCastRedux/TypeDefinitions.luau"),
    t("Core/ReplicatedStorage/Shared/FastCastRedux/TypeMarshaller.luau"),
    t("Core/ReplicatedStorage/Shared/FastCastRedux/init.luau"),
    t("Core/ReplicatedStorage/Shared/Observers/init.luau"),
    t("Core/ReplicatedStorage/Shared/Observers/observeAttribute.luau"),
    t("Core/ReplicatedStorage/Shared/Observers/observeCharacter.luau"),
    t("Core/ReplicatedStorage/Shared/Observers/observePlayer.luau"),
    t("Core/ReplicatedStorage/Shared/Observers/observeProperty.luau"),
    t("Core/ReplicatedStorage/Shared/Observers/observeTag.luau"),
    t("Core/ReplicatedStorage/Shared/PartCache/Table.luau"),
    t("Core/ReplicatedStorage/Shared/PartCache/init.luau"),
    t("Core/ReplicatedStorage/Shared/Dialogs/FrameShop.luau"),
    t("Core/ReplicatedStorage/Shared/Dialogs/KaraokeRoomRent.luau"),
    t("Core/ReplicatedStorage/Shared/PrompBuy/init.luau"),
    t("Core/ServerScriptService/ServerScripts/Ragdoll/DisableJointsWhenFalling.server.luau"),
    t("Core/ServerScriptService/ServerScripts/Ragdoll/PhysicallySimulatedUpperBody.server.luau"),
    t("Core/ServerScriptService/ServerScripts/stats/Stats.luau"),
    t("Core/ServerScriptService/ServerScripts/stats/Timer.luau"),
    t("Core/ServerScriptService/ServerScripts/AnimationSystem/AnimationManager.luau"),
    t("Core/ReplicatedStorage/Shared/Nametag/Countries.luau"),
    t("Core/ReplicatedStorage/Shared/Nametag/LevelStyler.luau"),
    t("Core/ReplicatedStorage/Shared/Nametag/MicStatus.luau"),
    t("Core/ReplicatedStorage/Assets/Tools/Food/Kitchen/Notas_Creacion_Plato.server.luau"),
    t("Core/ReplicatedStorage/Assets/Tools/Toys/Ballon/MainTool.client.luau"),
    t("Core/ReplicatedStorage/Assets/Tools/Toys/SlimeBomb/LocalScript.client.luau"),
    t("Core/ReplicatedStorage/Assets/Tools/Toys/SlimeBomb/Script.server.luau"),
    t("Core/ReplicatedStorage/Assets/Tools/Toys/GloveGun/MainTool.client.luau"),
    t("Core/ReplicatedStorage/Assets/Tools/Toys/Cannon/MainTool.client.luau"),
    t("Core/ReplicatedStorage/Assets/Tools/Toys/MiniPotion/MainTool/init.client.luau"),
    t("Core/ReplicatedStorage/Assets/Tools/Toys/BigPotion/MainTool/init.client.luau"),
    t("Core/ReplicatedStorage/Assets/Tools/Toys/SpyJetpack/MainTool/init.client.luau"),
    t("Core/ReplicatedStorage/Client/Attributes.luau"),
    t("Core/ReplicatedStorage/Client/BusquedaSettings.luau"),
    t("Core/ReplicatedStorage/Client/CreatePath.luau"),
    t("Core/ReplicatedStorage/Client/DesingData.luau"),
    t("Core/ReplicatedStorage/Client/Math.luau"),
    t("Core/ReplicatedStorage/Client/NametagMicClient.server.luau"),
    t("Core/ReplicatedStorage/Client/SettingsInfo.luau"),
    t("Core/ReplicatedStorage/Client/SurfacePlacer.server.luau"),
    t("Core/ReplicatedStorage/Client/UiManager.server.luau"),
    t("Core/ReplicatedStorage/Client/messagesManager.server.luau"),
    t("Core/ReplicatedStorage/Client/stats.server.luau"),
    t("Core/ReplicatedStorage/Client/ProgressBarStarter/ProgressBarController.luau"),
    t("Core/ReplicatedStorage/Client/ProgressBarStarter/init.server.luau"),
    t("Core/ReplicatedStorage/Client/CodeExamples/MicStatusExample.server.luau"),
    t("Core/ReplicatedStorage/Client/ClickDetectorHandler/MouseAction.luau"),
    t("Core/ReplicatedStorage/Client/ClickDetectorHandler/init.server.luau"),
    t("Core/ReplicatedStorage/Client/notificationsManager/init.server.luau"),
    t("Core/ReplicatedStorage/Client/notificationsManager/statsNotifications.luau"),
    t("Core/ReplicatedStorage/Client/Animator/init.luau"),
    t("Core/ReplicatedStorage/Client/WorldSystem/Modules/InventoryController.luau"),
    t("Core/ReplicatedStorage/Client/WorldSystem/ClientDataManager/Channel.luau"),
    t("Core/ReplicatedStorage/Client/WorldSystem/ClientDataManager/init.client.luau"),
    t("Core/ReplicatedStorage/Client/Ragdoll/GettingUpAssist.server.luau"),
    t("Core/ReplicatedStorage/Client/Ragdoll/RToRagdoll.server.luau"),
    t("Core/ReplicatedStorage/Client/Ragdoll/RagdollAtHighSpeeds.server.luau"),
    t("Core/ReplicatedStorage/Client/Ragdoll/RagdollRemote.server.luau"),
    t("Core/ReplicatedStorage/Client/RouletteUIStarter/RouletteUIController.luau"),
    t("Core/ReplicatedStorage/Client/RouletteUIStarter/init.server.luau"),
    t("Core/ReplicatedStorage/Client/QuestClient/QuestClient.server.luau"),
    t("Core/ReplicatedStorage/Client/QuestClient/QuestPickableClient.server.luau"),
    t("Core/ReplicatedStorage/Client/animation/init.server.luau"),
    t("Core/ReplicatedStorage/Client/cooking/Blender.luau"),
    t("Core/ReplicatedStorage/Client/cooking/CookingInteractable.luau"),
    t("Core/ReplicatedStorage/Client/cooking/CuttingBoard.luau"),
    t("Core/ReplicatedStorage/Client/cooking/Microwave.luau"),
    t("Core/ReplicatedStorage/Client/cooking/Oven.luau"),
    t("Core/ReplicatedStorage/Client/cooking/Stove.luau"),
    t("Core/ReplicatedStorage/Client/cooking/init.server.luau"),
    t("Core/ServerScriptService/ServerScripts/machines/Pong.luau"),
    t("Core/ServerScriptService/ServerScripts/machines/oldPong.luau"),
    t("Core/ReplicatedStorage/Client/machines/Basketball/Prediction.luau"),
    t("Core/ReplicatedStorage/Client/machines/Basketball/init.luau"),
    t("Core/ReplicatedStorage/Client/machines/MachineFactory.luau"),
    t("Core/ReplicatedStorage/Client/machines/MachinePrompt.luau"),
    t("Core/ReplicatedStorage/Client/machines/Pong.luau"),
    t("Core/ReplicatedStorage/Client/machines/PopTheLock/Controller.luau"),
    t("Core/ReplicatedStorage/Client/machines/PopTheLock/init.luau"),
    t("Core/ReplicatedStorage/Client/machines/Roulette/init.luau"),
    t("Core/ReplicatedStorage/Client/machines/Stacker/Board.luau"),
    t("Core/ReplicatedStorage/Client/machines/Stacker/Controller.luau"),
    t("Core/ReplicatedStorage/Client/machines/Stacker/Figure.luau"),
    t("Core/ReplicatedStorage/Client/machines/Stacker/idle.luau"),
    t("Core/ReplicatedStorage/Client/machines/Stacker/init.luau"),
    t("Core/ReplicatedStorage/Client/machines/ToyMachine/init.luau"),
    t("Core/ReplicatedStorage/Client/machines/init.server.luau"),
    t("Core/ReplicatedStorage/Client/machines/machineUtil.luau"),
    t("Core/ReplicatedStorage/Client/interactable/BarraBartender.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Bath.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Bed.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Bin.luau"),
    t("Core/ReplicatedStorage/Client/interactable/CajasWork.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Chair.luau"),
    t("Core/ReplicatedStorage/Client/interactable/ClassicDoor.luau"),
    t("Core/ReplicatedStorage/Client/interactable/CuadrosPaint.luau"),
    t("Core/ReplicatedStorage/Client/interactable/DoorSalaKaraoke.luau"),
    t("Core/ReplicatedStorage/Client/interactable/DoubleBed.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Fridge.luau"),
    t("Core/ReplicatedStorage/Client/interactable/IdleToggle.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Interruptor.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Lamp.luau"),
    t("Core/ReplicatedStorage/Client/interactable/MusicPlayer.luau"),
    t("Core/ReplicatedStorage/Client/interactable/NightClub.luau"),
    t("Core/ReplicatedStorage/Client/interactable/NpcDialog.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Paint.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Pee.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Piano.luau"),
    t("Core/ReplicatedStorage/Client/interactable/QuestPickable.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Shower.luau"),
    t("Core/ReplicatedStorage/Client/interactable/SmokeMachine.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Toilet.luau"),
    t("Core/ReplicatedStorage/Client/interactable/ToolInteractable.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Washbasin.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Weight.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Display/VideoPlayer.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Display/Videos.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Display/init.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Player/Tijeras.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Player/init.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Interactable/init.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Interactable/CustomPrompt/init.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Interactable/ActionWheel/init.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Interactable/ActionWheel/Page/init.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Interactable/ActionWheel/Page/UI/init.luau"),
    t("Core/ReplicatedStorage/Client/interactable/DiscoBall/Laser.server.luau"),
    t("Core/ReplicatedStorage/Client/interactable/DiscoBall/init.luau"),
    t("Core/ReplicatedStorage/Client/interactable/Treadmill/init.luau"),
    t("Core/ReplicatedStorage/Shared/Signal.luau"),
    t("Core/ReplicatedStorage/Shared/CardSlots.luau"),
    t("Core/ReplicatedStorage/Shared/ButtonMotion.luau"),
    t("Core/ReplicatedStorage/Shared/ShopHighlight.luau"),
    t("Core/ReplicatedStorage/Shared/Carousel.luau"),
    t("Core/ReplicatedStorage/Shared/AnimationButtons.luau"),
    t("Core/ReplicatedStorage/Shared/SellHousePrompt.luau"),
    t("Core/ReplicatedStorage/Shared/SmoothShiftLock.luau"),
    t("Core/ReplicatedStorage/Shared/SoundManager.luau"),
    t("Core/ReplicatedStorage/Shared/MovedScrollButton.luau"),
    t("Core/ReplicatedStorage/Shared/ObjectCache.luau"),
    t("Core/ReplicatedStorage/Shared/SizeManager.luau"),
    t("Core/ReplicatedStorage/Shared/AreaSystem.luau"),
    t("Core/ReplicatedStorage/Shared/UpdatingCountText.luau"),
    t("Core/ReplicatedStorage/Shared/RutaCreate.luau"),
    t("Core/ReplicatedStorage/Shared/AdjustBoxFrame.luau"),
    t("Core/ReplicatedStorage/Shared/ToolUseManagge.luau"),
    t("Core/ReplicatedStorage/Shared/GuiScaleManager.luau"),
    t("Core/ReplicatedStorage/Shared/MovingPlayers.luau"),
    t("Core/ReplicatedStorage/Shared/InputPlayer.luau"),
    t("Core/ReplicatedStorage/Shared/basketUtil.luau"),
    t("Core/ReplicatedStorage/Shared/promptText.luau"),
    t("Core/ReplicatedStorage/Shared/textScaler.luau"),
    t("Core/ReplicatedStorage/Shared/PrettyPrint.luau"),
    t("Core/ReplicatedStorage/Shared/showExitButton.luau"),
    t("Core/ReplicatedStorage/Shared/GuideService/PageController/VerificacionPages/Changed.luau"),
}
DOCUMENTED = {
    "src/ReplicatedStorage/PlayerInit.luau",
    "src/ReplicatedStorage/InitAfterTemplates.luau",
    t("Core/ServerStorage/WorldSystem/ServerPresence.luau"),
    t("Core/ServerStorage/WorldSystem/Profiles.luau"),
    t("Core/ServerStorage/WorldSystem/PlayerDataService.luau"),
    t("Core/ServerStorage/WorldSystem/PlayerSchema.luau"),
    t("Core/ServerStorage/RoleService/init.luau"),
    t("Core/ServerStorage/WorldSystem/GamePassService/init.luau"),
}

def meta_for(p):
    stem = p[:-len(".luau")]
    for suf in (".server", ".client"):
        if stem.endswith(suf):
            stem = stem[:-len(suf)]
            break
    return stem + ".meta.json"

def runtime_path(p):
    rel = p[len(ROOT) + 1:]
    parts = rel.split("/")
    if parts[:2] == ["ServerStorage", "TemplatesTesting"] and len(parts) > 3:
        return f"{parts[3]}." + ".".join(parts[4:]).replace(".luau", ""), parts[2]
    return ".".join(parts).replace(".luau", ""), "(root)"

rows = []
for dp, _, fn in os.walk(ROOT):
    for f in sorted(fn):
        if not f.endswith(".luau"):
            continue
        p = os.path.join(dp, f)
        kind = "Script" if ".server." in f else ("LocalScript" if ".client." in f else "ModuleScript")
        ctx, disabled = "", ""
        m = meta_for(p)
        if os.path.exists(m):
            try:
                pr = json.load(open(m, encoding="utf-8")).get("properties", {})
                ctx = pr.get("RunContext", "")
                disabled = "yes" if pr.get("Disabled") else ""
            except Exception:
                pass
        lines = sum(1 for _ in open(p, encoding="utf-8", errors="replace"))
        rt, tmpl = runtime_path(p)
        if p in DOCUMENTED:
            status = "**Documentado**"
        elif p in ANALYSED:
            status = "Analizado"
        elif any(p.startswith(pref) for pref in THIRD_PARTY_PREFIXES):
            status = "Frontera (terceros)"
        elif p in PARTIAL:
            status = "Analizado (en parte)"
        else:
            status = "Pendiente"
        rows.append(dict(path=p, kind=kind, ctx=ctx, disabled=disabled,
                         lines=lines, rt=rt, tmpl=tmpl, status=status))

counts = collections.Counter(r["status"] for r in rows)
out = ["""---
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
"""]
for label, meaning in [
    ("**Documentado**", "Leído entero y anotado con Moonwave por este proyecto"),
    ("Analizado", "Leído entero; su comportamiento se describe en alguna página del sitio"),
    ("Analizado (en parte)", "Leído solo en las partes relevantes para una pregunta concreta"),
    ("Frontera (terceros)", "Librería externa: se documenta qué es y quién la usa, **no se lee por dentro** — ver [Librerías de terceros](../architecture/third-party.md)"),
    ("Pendiente", "Aún sin leer"),
]:
    out.append(f"| {label} | {meaning} | {counts.get(label, 0)} |\n")
out.append(f"\n**Total: {len(rows)} archivos, {sum(r['lines'] for r in rows):,} líneas.**\n")

order = ["(root)", "Core", "GameWorlds", "PlayerHouses", "BuildingSystem"]
by_tmpl = collections.defaultdict(list)
for r in rows:
    by_tmpl[r["tmpl"]].append(r)

for tmpl in order + sorted(k for k in by_tmpl if k not in order):
    if tmpl not in by_tmpl:
        continue
    group = by_tmpl[tmpl]
    label = "Fuera de las plantillas" if tmpl == "(root)" else f"Plantilla `{tmpl}`"
    done = sum(1 for r in group if r["status"] != "Pendiente")
    out.append(f"\n## {label}\n\n{len(group)} archivos, "
               f"{sum(r['lines'] for r in group):,} líneas, {done} leídos.\n")
    by_dir = collections.defaultdict(list)
    for r in group:
        by_dir[os.path.dirname(r["path"])].append(r)
    for d in sorted(by_dir):
        entries = by_dir[d]
        read = sum(1 for r in entries if r["status"] != "Pendiente")
        badge = f" — {read}/{len(entries)} leídos" if read else ""
        out.append(f"\n<details>\n<summary><code>{d}/</code> — {len(entries)} archivo(s)"
                   f"{badge}</summary>\n\n")
        out.append("| Archivo | Tipo | Contexto | Desactivado | Líneas | Ruta en ejecución | Estado |\n"
                   "|---|---|---|---|---|---|---|\n")
        for r in sorted(entries, key=lambda x: x["path"]):
            out.append(f"| `{os.path.basename(r['path'])}` | {r['kind']} | {r['ctx'] or '—'} "
                       f"| {r['disabled'] or '—'} | {r['lines']} | `{r['rt']}` | {r['status']} |\n")
        out.append("\n</details>\n")

open("docs/reference/script-inventory.md", "w", encoding="utf-8").write("".join(out))
print("script-inventory.md:", len(rows), "files;", dict(counts))
