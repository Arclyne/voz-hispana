---
sidebar_position: 7
title: Networking
---

# Networking

## Shape of the remote surface

**FACT.** Remotes are not created in code. They are **declared as Rojo `.model.json`
files** and shipped as instances, so the full surface is knowable statically by reading
the file tree. There are:

| Class | Count |
|---|---|
| `RemoteEvent` | 174 |
| `RemoteFunction` | 40 |
| `BindableEvent` | 11 |
| `BindableFunction` | 1 |

169 of the `RemoteEvent`s and all 40 `RemoteFunction`s live under
`ReplicatedStorage.Events`, organised by topic. The remaining 5 are local to a feature
(for example `Assets/Tools/Toys/SlimeBomb/RemoteEvent`).

## Topic map

**FACT.** `ReplicatedStorage.Events` groups remotes into one folder per subsystem. The
count per folder is a fair first estimate of where the client↔server traffic actually is:

| Folder | `RemoteEvent` | `RemoteFunction` | `BindableEvent` |
|---|---|---|---|
| `Interactable` | 44 | — | — |
| `Karaoke` | 25 | — | — |
| `WorldSystem` (Core) | 12 | 21 | — |
| `Machines` | 18 | 1 | — |
| `Stores` | 10 | — | — |
| `Tools` | 9 | — | — |
| `IconsUI` | — | — | 8 |
| `Monetization` | 6 | — | — |
| `Paint` | 6 | — | — |
| `Decors` | 5 | — | — |
| `Player` | 5 | — | 2 |
| `(root)` | 5 | 1 | — |
| `CustomClickDetector` | 4 | — | — |
| `Inventory` | 4 | 1 | — |
| `Quests` | 4 | 2 | — |
| `Collections` | 3 | 1 | — |
| `Referrals` | 3 | 1 | — |
| `Animator` | 2 | 1 | — |
| `Other` | 2 | — | — |
| `GameLoad` | 1 | — | — |
| `LootBox` / `Roulette` | — | 1 each | — |
| `ShopUI` | — | — | 1 |
| `WorldSystem` (PlayerHouses) | 1 | 9 | — |

**INFERENCE.** Two things stand out. `WorldSystem` is the only area that leans on
`RemoteFunction`s (30 of the 40 across both templates) — because world/housing operations
are request→response by nature: *may I join, what are my houses, what does this cost*.
Everything else is overwhelmingly fire-and-forget `RemoteEvent`s.

## Two `WorldSystem` event folders

**FACT.** There are two distinct `Events/WorldSystem` folders, in different templates,
and they are merged into the same runtime folder by the
[template import](./initialization.md):

| Template | Remotes | Present in |
|---|---|---|
| `Core` | `JoinServer`, `JoinWorld`, `GetHouses`, `GetPlayerHouses`, `GetPlayerHouseServers`, `GetSlots`, `BuySlot`, `BuyItem`, `GetShopData`, `GetFriendServers`, `GetMostPlayedServers`, `GetFavoriteWorlds`, `houseControl`, `currencyControl`, … | Every place |
| `PlayerHouses` | `GetWorldSettings`, `GetRoles`, `GetUserRol`, `SetUserRole`, `GetBans`, `SetBan`, `SetWorldName`, `togglePrivacity`, `GetSlots`, `WorldDataUpdated` | House places |

**INFERENCE.** The split is by *where the operation can be answered*. `Core`'s remotes
answer questions about **which** worlds exist and how to reach them, and are served by a
lobby. `PlayerHouses`' remotes administer **this** world — its name, roles, bans,
privacy — and can only be served by the server that actually holds the world's data.

**OBSERVATION.** `GetSlots` is declared in **both** folders, both as a `RemoteFunction`.
Only one binder exists in the whole repository —
`Core/…/ServerScripts/PlayerDataReplicator.server.luau` sets
`GetSlots.OnServerInvoke = getPlayerSlots` — and only one consumer,
`Core/…/Client/WorldSystem/Modules/InventoryController.luau`. Nothing in the
`PlayerHouses` template references it.

If both templates are ever merged into the same place, the merge rules keep the
first-imported instance and destroy the second; since the classes are identical, the
result is one `RemoteFunction` with one binding, which is what the code already expects.
This is recorded as an observation, **not** a defect. Whether the two templates *are*
merged into the same place is **UNKNOWN** — `PlayerHouses` does not appear in
`TEMPLATES_IDS`.

## The request→response pattern

**FACT.** `RemoteFunction`s in the world system consistently return
`(ok: boolean, err: string?)`. `WorldManager` is the clearest example:

```lua
JoinServerFunc.OnServerInvoke = function(player: Player, serverKey: string)
    if typeof(serverKey) ~= "string" then
        return false, "Invalid Server Key"
    end
    …
    return false, "Server not found"
end
```

Every failure path returns a *string reason*, never `nil` and never an error. The client
therefore always gets a definite answer, and a `pcall` around the invoke is not needed
to distinguish "denied" from "broke".

## Input validation

**FACT.** Server handlers in the reviewed path validate client input by *type* before
using it, and resolve identifiers through server-side tables rather than trusting them:

| Handler | Validation |
|---|---|
| `JoinServer` | `typeof(serverKey) ~= "string"` → reject; then `parseRoomKey` must match `^(%d+)_(.+)$`; then `HousesInfo[roomName]` must exist |
| `JoinWorld` | `typeof(placeKey) ~= "string"` → reject; `PlaceKeyToPlaceId[placeKey]` must exist, otherwise `"Invalid place key"` |
| `LoadCharacterRequest` | player validity, a 2-second cooldown, `InitScriptsReadyFlag`, and a one-character-per-session flag |
| `teleportToHost` | `meta.placeId` must be a `number` and `meta.accessCode` a `string`, else `"Malformed host metadata"` |
| `JoinServer` (`default` hosting) | `placeId` must be a `number` and `jobId` a `string`, else `"Malformed directory entry"` |

**INFERENCE — the security property that matters.** A client can name *what* it wants to
reach, never *how*. `PlaceId`s come from `HousesInfo` or `PlaceKeyToPlaceId`;
`accessCode`s come from MemoryStore. The source states the rule for events directly:

```lua
-- El code sale del registro de MemoryStore, nunca del cliente.
```

**Scope note.** This assessment covers the bootstrap, player and world-system paths that
have been read end-to-end. The other ~200 remotes — `Interactable`, `Karaoke`,
`Machines`, `Stores`, `Tools` — have **not** been reviewed yet, and nothing here should
be read as a statement about them. They are queued for Phase 3/4.

## Server → server communication

**FACT.** `MessagingService` is used by 9 files. The topics established in the reviewed
path:

| Topic | Publisher | Payload |
|---|---|---|
| `UserServerRegistryUpdate` | `ServerPresence.RefreshNow` | `{ key = serverKey, info = payload }` |
| `UserServerRegistryClosed` | `ServerPresence.Cleanup` | `serverKey` |

**INFERENCE.** These exist so that a server browsing the directory learns about changes
without polling MemoryStore. The MemoryStore entry remains the source of truth — the
message is a hint that it changed. Every publish is wrapped in `pcall` and a failure only
warns, so a dropped message degrades freshness rather than correctness.

Other `MessagingService` users — `DataKit.Store`/`BaseStore`, `ServerDirectory`,
`ShopServerSystem`, `Karaoke/RevisarCanciones`, `Paint/ServerClient`, `ComprasTablero`,
`Referrals/ReferralMain` — are documented with their systems.

## Bindables

**FACT.** 11 `BindableEvent`s and 1 `BindableFunction`. 8 of the `BindableEvent`s are in
`Events/IconsUI`, 2 in `Events/Player`, 1 in `Events/ShopUI`.

**INFERENCE.** Bindables here are same-side decoupling (mostly client UI), not
client↔server transport. Their small number relative to 214 remotes suggests most
intra-side coupling is done by direct `require` instead.

## Related implementation

| Concern | Code |
|---|---|
| World/housing remotes | `Core/…/ServerScripts/WorldManager.server.luau` |
| World administration remotes | `PlayerHouses/ServerScriptService/WorldDataReplicator.server.luau` |
| Directory queries | `Core/…/ServerScripts/ServerDirectory.server.luau`, `WorldsBrowser.server.luau` |
| Cross-server messaging | [`ServerPresence`](/api/ServerPresence); `DataKit/Store.luau`, `DataKit/BaseStore.luau` |
| Character request | `Core/…/ServerScripts/playerManager.server.luau` |
