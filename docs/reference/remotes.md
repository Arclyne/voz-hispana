---
sidebar_position: 3
title: Remotes y bindables
---

# Remotes y bindables

Todos los `RemoteEvent`, `RemoteFunction`, `BindableEvent` y `BindableFunction` declarados
en este repositorio, con la ruta del DataModel que ocupan en tiempo de ejecución.

Se **declaran como archivos `.model.json` de Rojo**, no se crean en código, así que esta
lista es completa para el código inspeccionable. Las instancias que crea un script en
ejecución —por ejemplo `TemplatesReady`, que `ImportTemplates` crea con `Instance.new`— se
anotan aparte al final.

Para qué se usan, ver [Arquitectura → Red](../architecture/networking.md).

| Clase | Cantidad |
|---|---|
| `RemoteEvent` | 174 |
| `RemoteFunction` | 40 |
| `BindableEvent` | 11 |
| `BindableFunction` | 1 |

## RemoteEvent (174)

| Ruta en ejecución | Plantilla |
|---|---|
| `ReplicatedStorage.Assets.Tools.Toys.SlimeBomb.RemoteEvent` | Core |
| `ReplicatedStorage.Events.Animate` | Core |
| `ReplicatedStorage.Events.Animator.AddAnimation` | Core |
| `ReplicatedStorage.Events.Animator.PlayAnimation` | Core |
| `ReplicatedStorage.Events.Collections.Get` | Core |
| `ReplicatedStorage.Events.Collections.Give` | Core |
| `ReplicatedStorage.Events.Collections.SetAmount` | Core |
| `ReplicatedStorage.Events.CustomClickDetector.BuyDanceTest` | Core |
| `ReplicatedStorage.Events.CustomClickDetector.GiveCoins` | Core |
| `ReplicatedStorage.Events.CustomClickDetector.ListenSettings` | Core |
| `ReplicatedStorage.Events.CustomClickDetector.Test` | Core |
| `ReplicatedStorage.Events.Decors.BuyDecor` | Core |
| `ReplicatedStorage.Events.Decors.Delete` | Core |
| `ReplicatedStorage.Events.Decors.GetDecor` | Core |
| `ReplicatedStorage.Events.Decors.SellDecor` | Core |
| `ReplicatedStorage.Events.Decors.Update` | Core |
| `ReplicatedStorage.Events.DonarCoins` | Core |
| `ReplicatedStorage.Events.GameLoad.InitScriptsRequest` | Core |
| `ReplicatedStorage.Events.Interactable.Bar` | Core |
| `ReplicatedStorage.Events.Interactable.BarraBartender` | Core |
| `ReplicatedStorage.Events.Interactable.Bath` | Core |
| `ReplicatedStorage.Events.Interactable.Bed` | Core |
| `ReplicatedStorage.Events.Interactable.Bin` | Core |
| `ReplicatedStorage.Events.Interactable.Blender` | Core |
| `ReplicatedStorage.Events.Interactable.CancellCut` | Core |
| `ReplicatedStorage.Events.Interactable.CancellCut2` | Core |
| `ReplicatedStorage.Events.Interactable.ClassicDoor` | Core |
| `ReplicatedStorage.Events.Interactable.CuadrosPaint` | Core |
| `ReplicatedStorage.Events.Interactable.CutBar` | Core |
| `ReplicatedStorage.Events.Interactable.CuttingBoard` | Core |
| `ReplicatedStorage.Events.Interactable.DiscoBall` | Core |
| `ReplicatedStorage.Events.Interactable.Display` | Core |
| `ReplicatedStorage.Events.Interactable.DoubleBed` | Core |
| `ReplicatedStorage.Events.Interactable.EndCut` | Core |
| `ReplicatedStorage.Events.Interactable.FocusNpcDialog` | Core |
| `ReplicatedStorage.Events.Interactable.FoodPlate` | Core |
| `ReplicatedStorage.Events.Interactable.Fridge` | Core |
| `ReplicatedStorage.Events.Interactable.GiveCoffee` | Core |
| `ReplicatedStorage.Events.Interactable.GiveWater` | Core |
| `ReplicatedStorage.Events.Interactable.Lamp` | Core |
| `ReplicatedStorage.Events.Interactable.Microwave` | Core |
| `ReplicatedStorage.Events.Interactable.MusicPlayer` | Core |
| `ReplicatedStorage.Events.Interactable.OpenFoodContainer` | Core |
| `ReplicatedStorage.Events.Interactable.Oven` | Core |
| `ReplicatedStorage.Events.Interactable.Paint` | Core |
| `ReplicatedStorage.Events.Interactable.Pee` | Core |
| `ReplicatedStorage.Events.Interactable.PickupTool` | Core |
| `ReplicatedStorage.Events.Interactable.PlaceTool` | Core |
| `ReplicatedStorage.Events.Interactable.ReturnFoodServing` | Core |
| `ReplicatedStorage.Events.Interactable.Shower` | Core |
| `ReplicatedStorage.Events.Interactable.Sit` | Core |
| `ReplicatedStorage.Events.Interactable.SmokeMachine` | Core |
| `ReplicatedStorage.Events.Interactable.StartCut` | Core |
| `ReplicatedStorage.Events.Interactable.Stove` | Core |
| `ReplicatedStorage.Events.Interactable.TakeFoodServing` | Core |
| `ReplicatedStorage.Events.Interactable.Toilet` | Core |
| `ReplicatedStorage.Events.Interactable.Treadmill` | Core |
| `ReplicatedStorage.Events.Interactable.WashHands` | Core |
| `ReplicatedStorage.Events.Interactable.WashTeeth` | Core |
| `ReplicatedStorage.Events.Interactable.Weight` | Core |
| `ReplicatedStorage.Events.Interactable.salaKaraoke` | Core |
| `ReplicatedStorage.Events.Interactable.salaKaraoke.BuyStyles` | Core |
| `ReplicatedStorage.Events.Inventory.Equip` | Core |
| `ReplicatedStorage.Events.Inventory.Unequip` | Core |
| `ReplicatedStorage.Events.Inventory.WheelAdd` | Core |
| `ReplicatedStorage.Events.Inventory.WheelRemove` | Core |
| `ReplicatedStorage.Events.Karaoke.Administracion` | Core |
| `ReplicatedStorage.Events.Karaoke.RevisarAdmis.AccionarDenuncias` | Core |
| `ReplicatedStorage.Events.Karaoke.RevisarAdmis.ApReMusica` | Core |
| `ReplicatedStorage.Events.Karaoke.RevisarAdmis.AprobarMusica` | Core |
| `ReplicatedStorage.Events.Karaoke.RevisarAdmis.CargarMusicas` | Core |
| `ReplicatedStorage.Events.Karaoke.RevisarAdmis.DenunciarMusica` | Core |
| `ReplicatedStorage.Events.Karaoke.RevisarAdmis.Desbanear` | Core |
| `ReplicatedStorage.Events.Karaoke.RevisarAdmis.DescartarDenuncia` | Core |
| `ReplicatedStorage.Events.Karaoke.RevisarAdmis.EliminarMusicaPublica` | Core |
| `ReplicatedStorage.Events.Karaoke.RevisarAdmis.ObtenerMusicas` | Core |
| `ReplicatedStorage.Events.Karaoke.RevisarAdmis.PublishRevisarMusic` | Core |
| `ReplicatedStorage.Events.Karaoke.RevisarAdmis.RechazarMusica` | Core |
| `ReplicatedStorage.Events.Karaoke.RevisarAdmis.ViewLyric` | Core |
| `ReplicatedStorage.Events.Karaoke.Televisiones.CargarMusicas` | Core |
| `ReplicatedStorage.Events.Karaoke.Televisiones.GetTelevisiones` | Core |
| `ReplicatedStorage.Events.Karaoke.Televisiones.Instance` | Core |
| `ReplicatedStorage.Events.Karaoke.Televisiones.Instance.AddedSong` | Core |
| `ReplicatedStorage.Events.Karaoke.Televisiones.Instance.RemovedSong` | Core |
| `ReplicatedStorage.Events.Karaoke.Televisiones.Instance.SetOwner` | Core |
| `ReplicatedStorage.Events.Karaoke.Televisiones.Instance.Skip` | Core |
| `ReplicatedStorage.Events.Karaoke.Televisiones.Instance.listening` | Core |
| `ReplicatedStorage.Events.Karaoke.Televisiones.Instance.reproducir` | Core |
| `ReplicatedStorage.Events.Karaoke.Televisiones.ObtenerMusicas` | Core |
| `ReplicatedStorage.Events.Karaoke.Televisiones.TVAdded` | Core |
| `ReplicatedStorage.Events.Karaoke.Televisiones.TVRemoved` | Core |
| `ReplicatedStorage.Events.Machines.BasketFinish` | Core |
| `ReplicatedStorage.Events.Machines.BasketReturnBall` | Core |
| `ReplicatedStorage.Events.Machines.BasketScore` | Core |
| `ReplicatedStorage.Events.Machines.BasketThrowBall` | Core |
| `ReplicatedStorage.Events.Machines.PongBallUpdate` | Core |
| `ReplicatedStorage.Events.Machines.PongInput` | Core |
| `ReplicatedStorage.Events.Machines.PongPaddleUpdate` | Core |
| `ReplicatedStorage.Events.Machines.PongShot` | Core |
| `ReplicatedStorage.Events.Machines.PongSpawn` | Core |
| `ReplicatedStorage.Events.Machines.PongTick` | Core |
| `ReplicatedStorage.Events.Machines.PopTheLockClaim` | Core |
| `ReplicatedStorage.Events.Machines.PopTheLockFinish` | Core |
| `ReplicatedStorage.Events.Machines.PopTheLockFlip` | Core |
| `ReplicatedStorage.Events.Machines.StackerFinish` | Core |
| `ReplicatedStorage.Events.Machines.StackerPosition` | Core |
| `ReplicatedStorage.Events.Machines.Start` | Core |
| `ReplicatedStorage.Events.Machines.Stop` | Core |
| `ReplicatedStorage.Events.Machines.ToyPress` | Core |
| `ReplicatedStorage.Events.MainEvent` | Core |
| `ReplicatedStorage.Events.Monetization.AddedProductPlayer` | Core |
| `ReplicatedStorage.Events.Monetization.Gamepass` | Core |
| `ReplicatedStorage.Events.Monetization.Product` | Core |
| `ReplicatedStorage.Events.Monetization.ProductsPlayer` | Core |
| `ReplicatedStorage.Events.Monetization.PromptBulkPurchaseFinished` | Core |
| `ReplicatedStorage.Events.Monetization.PurchaseProduct` | Core |
| `ReplicatedStorage.Events.Other.Commands` | Core |
| `ReplicatedStorage.Events.Other.cofreEvent` | Core |
| `ReplicatedStorage.Events.Paint.DataCache` | Core |
| `ReplicatedStorage.Events.Paint.GetAllPaints` | Core |
| `ReplicatedStorage.Events.Paint.Load` | Core |
| `ReplicatedStorage.Events.Paint.Remove` | Core |
| `ReplicatedStorage.Events.Paint.Save` | Core |
| `ReplicatedStorage.Events.Paint.Update` | Core |
| `ReplicatedStorage.Events.Player.LoadCharacterRequest` | Core |
| `ReplicatedStorage.Events.Player.PlaySound` | Core |
| `ReplicatedStorage.Events.Player.RagdollTarget` | Core |
| `ReplicatedStorage.Events.Player.ShowMessage` | Core |
| `ReplicatedStorage.Events.Player.ShowNotification` | Core |
| `ReplicatedStorage.Events.Prompt` | Core |
| `ReplicatedStorage.Events.Quests.ClaimQuest` | Core |
| `ReplicatedStorage.Events.Quests.CollectQuestPickable` | Core |
| `ReplicatedStorage.Events.Quests.QuestPickablesUpdated` | Core |
| `ReplicatedStorage.Events.Quests.QuestUpdated` | Core |
| `ReplicatedStorage.Events.Referrals.ClaimReferralReward` | Core |
| `ReplicatedStorage.Events.Referrals.ReferralUpdated` | Core |
| `ReplicatedStorage.Events.Referrals.ShareReferralLink` | Core |
| `ReplicatedStorage.Events.StartClientPlayer` | Core |
| `ReplicatedStorage.Events.Stores.ActionCompras` | Core |
| `ReplicatedStorage.Events.Stores.ActiveModeConstruction` | Core |
| `ReplicatedStorage.Events.Stores.BuyStore` | Core |
| `ReplicatedStorage.Events.Stores.ChangeDesing` | Core |
| `ReplicatedStorage.Events.Stores.ClaimStore` | Core |
| `ReplicatedStorage.Events.Stores.ComprarMaterial` | Core |
| `ReplicatedStorage.Events.Stores.ExitModeCOnstrccion` | Core |
| `ReplicatedStorage.Events.Stores.GetInfoHouse` | Core |
| `ReplicatedStorage.Events.Stores.LikeCuadro` | Core |
| `ReplicatedStorage.Events.Stores.StartClientPlayer` | Core |
| `ReplicatedStorage.Events.Tools.Ballon` | Core |
| `ReplicatedStorage.Events.Tools.Cannon` | Core |
| `ReplicatedStorage.Events.Tools.EquipTool` | Core |
| `ReplicatedStorage.Events.Tools.EquipToolAccesory` | Core |
| `ReplicatedStorage.Events.Tools.Fly` | Core |
| `ReplicatedStorage.Events.Tools.GloveGun` | Core |
| `ReplicatedStorage.Events.Tools.Maximizate` | Core |
| `ReplicatedStorage.Events.Tools.Minimizate` | Core |
| `ReplicatedStorage.Events.Tools.Walkie` | Core |
| `ReplicatedStorage.Events.WorldSystem.HouseBuyLoad` | Core |
| `ReplicatedStorage.Events.WorldSystem.RequestServerList` | Core |
| `ReplicatedStorage.Events.WorldSystem.ServerList` | Core |
| `ReplicatedStorage.Events.WorldSystem.ServerListToPlayer` | Core |
| `ReplicatedStorage.Events.WorldSystem.ShopUpdated` | Core |
| `ReplicatedStorage.Events.WorldSystem.UpdateDances` | Core |
| `ReplicatedStorage.Events.WorldSystem.UpdateFavoriteWorlds` | Core |
| `ReplicatedStorage.Events.WorldSystem.UpdateGamePasses` | Core |
| `ReplicatedStorage.Events.WorldSystem.UpdateHouses` | Core |
| `ReplicatedStorage.Events.WorldSystem.UpdateSlots` | Core |
| `ReplicatedStorage.Events.WorldSystem.currencyControl` | Core |
| `ReplicatedStorage.Events.WorldSystem.houseControl` | Core |
| `ReplicatedStorage.Shared.ComprasTablero.Leaderboard` | Core |
| `ReplicatedStorage.Shared.ComprasTablero.Message` | Core |
| `ReplicatedStorage.Shared.ComprasTablero.Signal` | Core |
| `ReplicatedStorage.Shared.GuideService.Events.EndAction` | Core |
| `ReplicatedStorage.Events.WorldSystem.WorldDataUpdated` | PlayerHouses |

## RemoteFunction (40)

| Ruta en ejecución | Plantilla |
|---|---|
| `ReplicatedStorage.Events.Animator.GetAnimations` | Core |
| `ReplicatedStorage.Events.Collections.charge` | Core |
| `ReplicatedStorage.Events.Inventory.GetWheel` | Core |
| `ReplicatedStorage.Events.LootBox.PurchaseLootBoxRF` | Core |
| `ReplicatedStorage.Events.Machines.Request` | Core |
| `ReplicatedStorage.Events.MainFunction` | Core |
| `ReplicatedStorage.Events.Quests.GetQuestPickables` | Core |
| `ReplicatedStorage.Events.Quests.GetQuestState` | Core |
| `ReplicatedStorage.Events.Referrals.GetReferralState` | Core |
| `ReplicatedStorage.Events.Roulette.RequestSpin` | Core |
| `ReplicatedStorage.Events.WorldSystem.BuyItem` | Core |
| `ReplicatedStorage.Events.WorldSystem.BuySlot` | Core |
| `ReplicatedStorage.Events.WorldSystem.CanAcquireGamePass` | Core |
| `ReplicatedStorage.Events.WorldSystem.GetActiveEvent` | Core |
| `ReplicatedStorage.Events.WorldSystem.GetDances` | Core |
| `ReplicatedStorage.Events.WorldSystem.GetFavoriteWorlds` | Core |
| `ReplicatedStorage.Events.WorldSystem.GetFriendServers` | Core |
| `ReplicatedStorage.Events.WorldSystem.GetGamePasses` | Core |
| `ReplicatedStorage.Events.WorldSystem.GetHouses` | Core |
| `ReplicatedStorage.Events.WorldSystem.GetMostPlayedServers` | Core |
| `ReplicatedStorage.Events.WorldSystem.GetPlayerHouseServers` | Core |
| `ReplicatedStorage.Events.WorldSystem.GetPlayerHouses` | Core |
| `ReplicatedStorage.Events.WorldSystem.GetServerInfo` | Core |
| `ReplicatedStorage.Events.WorldSystem.GetShopData` | Core |
| `ReplicatedStorage.Events.WorldSystem.GetSlots` | Core |
| `ReplicatedStorage.Events.WorldSystem.GiveFavorite` | Core |
| `ReplicatedStorage.Events.WorldSystem.JoinServer` | Core |
| `ReplicatedStorage.Events.WorldSystem.JoinWorld` | Core |
| `ReplicatedStorage.Events.WorldSystem.RemoveFavorite` | Core |
| `ReplicatedStorage.Events.WorldSystem.RequestGift` | Core |
| `ReplicatedStorage.Events.WorldSystem.SearchPlayer` | Core |
| `ReplicatedStorage.Events.WorldSystem.GetBans` | PlayerHouses |
| `ReplicatedStorage.Events.WorldSystem.GetRoles` | PlayerHouses |
| `ReplicatedStorage.Events.WorldSystem.GetSlots` | PlayerHouses |
| `ReplicatedStorage.Events.WorldSystem.GetUserRol` | PlayerHouses |
| `ReplicatedStorage.Events.WorldSystem.GetWorldSettings` | PlayerHouses |
| `ReplicatedStorage.Events.WorldSystem.SetBan` | PlayerHouses |
| `ReplicatedStorage.Events.WorldSystem.SetUserRole` | PlayerHouses |
| `ReplicatedStorage.Events.WorldSystem.SetWorldName` | PlayerHouses |
| `ReplicatedStorage.Events.WorldSystem.togglePrivacity` | PlayerHouses |

## BindableEvent (11)

| Ruta en ejecución | Plantilla |
|---|---|
| `ReplicatedStorage.Events.IconsUI.FavoriteWorld` | Core |
| `ReplicatedStorage.Events.IconsUI.OpenAdminPanel` | Core |
| `ReplicatedStorage.Events.IconsUI.OpenAudioPlayers` | Core |
| `ReplicatedStorage.Events.IconsUI.OpenDances` | Core |
| `ReplicatedStorage.Events.IconsUI.OpenGiftShop` | Core |
| `ReplicatedStorage.Events.IconsUI.OpenStats` | Core |
| `ReplicatedStorage.Events.IconsUI.OpenTablet` | Core |
| `ReplicatedStorage.Events.IconsUI.OpenTools` | Core |
| `ReplicatedStorage.Events.Player.ShowMessageBindable` | Core |
| `ReplicatedStorage.Events.Player.ShowNotificationBindable` | Core |
| `ReplicatedStorage.Events.ShopUI.FocusShopItem` | Core |

## BindableFunction (1)

| Ruta en ejecución | Plantilla |
|---|---|
| `ServerStorage.WorldSystem.GetOwnerServers` | Core |

## Creados en ejecución, no declarados

| Nombre | Clase | Lo crea |
|---|---|---|
| `ReplicatedStorage.TemplatesReady` | `RemoteEvent` | `ImportTemplates.server.luau` |
| `ReplicatedStorage.TemplatesReadyFlag` | `BoolValue` | `ImportTemplates.server.luau` |
| `ReplicatedStorage.InitScriptsReadyFlag` | `BoolValue` | `InitScripts.server.luau` |
| `ReplicatedStorage.IsInEvent` | `Configuration` | `Core/StarterGui/LocalScript.client.luau`, si no existe |
