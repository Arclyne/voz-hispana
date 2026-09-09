---
sidebar_position: 7
title: Error handling
---

# Housing error handling

Every failure mode found in the housing path, what the code does about it, and what is left
open. Rows marked **UNKNOWN** are not gaps in this page — they are gaps in what static
reading can establish.

## Failure matrix

| Failure | Detected where | Handling | Player sees | Open question |
|---|---|---|---|---|
| Client sends a non-string `serverKey` | `JoinServerFunc` | Rejected before anything else | `(false, "Invalid Server Key")` | — |
| Key does not match `^(%d+)_(.+)$` | `parseRoomKey` | Falls through to the presence directory | `(false, "Server not found")` if absent | — |
| Room not in `HousesInfo` | `JoinServerFunc` / `PlayerWorld_Init` | Lobby: treated as a non-house key. House server: `onFailedServer` → `KickAll` | `"[Error] Unknown room X."` | — |
| `ReserveServer` fails | `reserveAccessCode` | `warn`, returns `nil`; `hostWorld` clears its local stage and calls `claim:release()` so the turn is freed immediately | `(false, "The server could not be reserved")` | No retry — is one attempt enough? |
| `TeleportAsync` fails | `safeTeleport` | 3 attempts, 0.5 s apart, each `pcall`ed | `(false, "TeleportFailed: …")` | — |
| Host metadata malformed | `teleportToHost` | Type-checks `placeId` and `accessCode` before use | `(false, "Malformed host metadata")` | — |
| Directory entry malformed | `JoinServerFunc` | Type-checks `placeId` and `jobId` | `(false, "Malformed directory entry")` | — |
| MemoryStore read fails | `ServerPresence.SafeGet` | Retries with backoff; abandons on throttle; returns an explicit error flag distinct from "not found" | `(false, "Error trying to get the server")` | — |
| MemoryStore throttled | `isThrottled` in `ServerPresence`, `Lease`, `ServerDirectory` | Stops retrying, pauses 60 s, keeps the existing cache | Stale data, no error | — |
| Another lobby is staging | `claimStaged` returns `kind = "staged"` | Polls `peekStaged` 10 × 1 s, then joins the same instance | `(false, "Server is pending")` if the poll times out | Is 10 s enough for a slow `ReserveServer`? |
| Staging lobby vanished | `waitForStagedHost` | `if not stager then return nil` — gives up at once rather than polling a dead claim | `(false, "The server could not be reserved")` | — |
| `TeleportData` missing or malformed | `extractPayload` | Returns `(nil, nil)`; `onPlayerAdded` does nothing, so the server stays uninitialised | Nothing — the player is in an inert server | **UNKNOWN**: no kick, no message. See below. |
| `WorldsPlayer` read fails | `hasRoom` | Distinguishes "read failed" from "does not own" | `"[Error] Failed getting the [id] rooms."` | — |
| Owner does not own the room | `hasRoom` | `onFailedServer` → `KickAll` | `"[Error] The user N does not have the X."` | — |
| Lease already held | `Store._resolveOwnership` → `onDenied` | `convergeToOwner`, 3 attempts | Teleported to the real host, or kicked | [BUG-CANDIDATE-004](../../testing/verification-plan.md#bug-candidate-004) |
| Store never becomes ready | `store:awaitReady()` returns false | `onFailedServer` unless already denied | `"[Error] The data server could not be obtained."` | — |
| Player not allowed to host | `canHostWorld` | `WorldService.destroy()` then `KickAll` | The specific refusal reason | — |
| `GetNameFromUserIdAsync` fails on first boot | `getRoomDisplayName` | Falls back to `"default Name"` | A house permanently named that | [BUG-CANDIDATE-009](../../testing/verification-plan.md#bug-candidate-009) |
| `IsFriendsWith` fails | `canHostWorld`, `canPlayerEnter` | Treated as "not a friend" — **fails closed** | Refused from a private house | — |
| `FilterStringAsync` fails | `SetWorldName` | Keeps the sanitised but unfiltered name — **fails open** | The name is applied | Noted in [Permissions](./permissions.md) |
| `store:update` fails | `WorldService.update` returns false | `warn`, remote returns `nil` / `false` | Nothing happens | No user-facing error |
| Kick fails | `ModeratorManager.kickPlayer` | `pcall`ed, warns | Stays in the house | — |
| `ListItemsAsync` fails | `ServerDirectory.fullSync` | 3 attempts; **preserves the existing cache** rather than replacing it with a partial one | Slightly stale server list | — |
| HTTP proxy unreachable | `WorldsBrowser.searchPlayer` | `pcall`, warns, returns `{}` | An empty search result | Indistinguishable from "no matches" |

## Two failure modes worth expanding

### A house server with no usable `TeleportData`

**FACT.** `extractPayload` returns `(nil, nil)` when `GetJoinData().TeleportData` is absent
or its `key` is not a string. `onPlayerAdded` then does nothing at all:

```lua
local key, accessCode = extractPayload(player)
if key then
    booting = true
    init(key, player, accessCode)
    booting = false
end
```

**INFERENCE.** No `else`. The player is left in a reserved server that never initialises:
no world data, no presence, no `isStarted`, and — because `PlayerAdded` was connected with
`:Once` — **no second chance from a later arrival**, since the `Once` connection was
consumed by this player.

Every other failure in `init` funnels through `onFailedServer`, which warns and kicks with
an explanation. This path alone is silent.

**UNKNOWN.** Whether a player can reach a `PlayerHouses` place without valid
`TeleportData`. `WorldManager` always sets it, so the reachable routes would be a direct
join to the place, a Roblox-initiated rejoin, or a teleport from code not in this
repository. Recorded as
[BUG-CANDIDATE-013](../../testing/verification-plan.md#bug-candidate-013).

### `ReserveServer` failure releases the turn but does not retry

**FACT.** `reserveAccessCode` makes exactly one attempt:

```lua
local ok, code = pcall(TeleportService.ReserveServer, TeleportService, placeId)
if ok then return code end
warn("[WorldManager] ReserveServer failed:", code)
return nil
```

and `hostWorld` unwinds cleanly:

```lua
if not code then
    localStages[serverKey] = nil
    claim:release()
    return false, "The server could not be reserved"
end
```

**INFERENCE — this is correct behaviour, not an omission.** Releasing the staging claim
immediately is what lets the *next* request retry from a clean state, rather than waiting
out the 30-second staging TTL. Compare `safeTeleport`, which does retry: a teleport is
idempotent from the caller's point of view, while a reservation holds a distributed claim
that others are blocked on. Retrying under the claim would extend everyone else's wait.

The observation stands only as a question about the *user-visible* result: the player sees
one failure message and must act again themselves.

## Error-reporting conventions

**FACT.** Two distinct conventions coexist, split by trust boundary:

| Layer | Convention |
|---|---|
| Remotes reached by clients (`JoinServer`, `JoinWorld`) | Return `(false, "reason")` — always a definite answer, never an error, never `nil` |
| House-server internals | `onFailedServer(msg)` → `warn` + `ServerPresence.KickAll(msg)` — the message is both the log line and the kick reason |
| Administrative remotes | Return `nil` or `(false, "Code")` and `warn` server-side |
| Everything touching a Roblox web API | Wrapped in `pcall`, without exception, in every path reviewed |

**INFERENCE.** The house-server convention means internal error messages are shown
verbatim to players — including strings like
`"[Error] Failed getting the [12345] rooms."`, which leaks a user id and an internal
bracket format into a user-facing kick dialog. Low severity, and mentioned here only
because the *same* string serves two audiences.

## What has no handling at all

**FACT**, stated so the absence is not mistaken for an omission in this page:

| No handling for | Consequence |
|---|---|
| The last player leaving | Nothing housing-specific runs; see [Server lifecycle](./server-lifecycle.md) |
| An empty house server timing out | Roblox decides; not expressible in this code |
| A `World` profile that fails to save at shutdown | `Store` retries internally; a total failure loses at most one autosave interval |
| A house whose owner no longer owns the room | Not reachable — nothing removes entries from `rooms` |
| Deleting or resetting a house | Not expressible; see [Persistence](./persistence.md) |

## Related implementation

| Concern | Code |
|---|---|
| Client-facing failures | `WorldManager.server.luau`, `JoinServerFunc`, `JoinWorldFunc` |
| Teleport retry | `WorldManager.server.luau`, `safeTeleport` |
| Reservation unwinding | `WorldManager.server.luau`, `hostWorld` |
| House-server failures | `PlayerWorld_Init.lua.server.luau`, `onFailedServer` |
| MemoryStore resilience | [`ServerPresence`](/api/ServerPresence); `ServerDirectory.server.luau`, `fullSync` |
| Store resilience | [`Store`](/api/Store), [`Health`](/api/Health) |
