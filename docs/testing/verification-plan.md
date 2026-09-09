---
sidebar_position: 1
title: Verification plan
---

# Verification plan

This page records things that **look wrong or unproven** in the source, together with the
evidence for each and a reproducible plan to settle it.

:::danger Nothing here is a confirmed bug

Every entry is a hypothesis with evidence, not a defect report. Several of them will turn
out to be correct-by-design once run. **No code has been changed** to address anything on
this page; that is out of scope for this documentation project by instruction.

:::

## How to read an entry

| Field | Meaning |
|---|---|
| **Classification** | See the taxonomy below. |
| **Verification status** | `Unverified` until someone runs the plan. |
| **Severity if confirmed** | The impact *assuming* the theory holds. Not a claim that it does. |
| **Confidence** | How likely the theory is to hold, given static reading alone. |
| **Observed behaviour** | What the code demonstrably does. Always **FACT**. |
| **Theory** | What might happen at runtime. Always **THEORY**. |
| **Unknowns** | What static reading cannot settle. |

### Classification taxonomy

`Observation` · `Possible Bug` · `Likely Bug` · `Confirmed by Static Analysis` ·
`Requires Runtime Verification` · `Requires Integration Testing` ·
`Requires Multiplayer Testing` · `Requires Concurrency Testing` ·
`Requires Lifecycle Testing` · `Requires Persistence Testing` ·
`Requires Failure Injection` · `Requires Security Testing`

### Test types

`Functional` · `Integration` · `Multiplayer` · `Concurrency` · `Lifecycle` ·
`Persistence` · `Failure Recovery` · `Teleport` · `Security` · `Load`

:::note Roblox Studio is not available in this environment

Nothing on this page has been executed. Each plan is written to be run by hand in Studio
or in a live test place.

:::

## Index

| ID | Title | System | Classification | Severity if confirmed | Confidence |
|---|---|---|---|---|---|
| [001](#bug-candidate-001) | Voice-chat gate fails open when the Roblox check errors | Bootstrap | Observation / Requires Failure Injection | Low | High |
| [002](#bug-candidate-002) | Presence entry can outlive its server by up to the TTL | World System | Possible Bug / Requires Lifecycle Testing | Medium | Medium |
| [003](#bug-candidate-003) | A failed respawn leaves the player with no character and nothing retries | Character | Possible Bug / Requires Failure Injection | Medium | Medium |
| [004](#bug-candidate-004) | Convergence after a denied host may strand players | Housing | Possible Bug / Requires Multiplayer Testing | High | Low |
| [005](#bug-candidate-005) | Teleport with an access code whose instance has already shut down | Housing | Requires Teleport Testing | Medium | Low |
| [006](#bug-candidate-006) | A Studio session can publish a fake access code to the live registry | Housing | Likely Bug / Requires Integration Testing | High | Medium |
| [007](#bug-candidate-007) | The client script loader is not in this repository | Client | Observation / Requires Runtime Verification | — | High |
| [008](#bug-candidate-008) | A purchase grants the item before it charges for it | Housing / Economy | Possible Bug / Requires Failure Injection | Medium | Medium |
| [009](#bug-candidate-009) | A first-boot name lookup failure names the house permanently | Housing | Possible Bug / Requires Failure Injection | Low | High |
| [010](#bug-candidate-010) | `WorldDataReplicator` misses an already-`ready` server | Housing | Likely Bug / Requires Lifecycle Testing | Medium | Medium |
| [011](#bug-candidate-011) | The `moderator` role cannot moderate | Housing | Likely Bug / Confirmed by Static Analysis | Medium | High |
| [012](#bug-candidate-012) | House roles, settings and bans are readable by any occupant | Housing | Observation / Requires Security Testing | Low | High |
| [013](#bug-candidate-013) | A house server with no `TeleportData` strands its player silently | Housing | Possible Bug / Requires Runtime Verification | Medium | Medium |
| [014](#bug-candidate-014) | A shared secret and a proxy host are hardcoded in a committed source file | Housing / Security | Confirmed by Static Analysis | High | High |

---

## BUG-CANDIDATE-001

### Voice-chat gate fails open when the Roblox check errors

**System:** Bootstrap · **Classification:** Observation / Requires Failure Injection
**Verification status:** Unverified · **Severity if confirmed:** Low · **Confidence:** High

**Related code:** `src/ServerScriptService/ImportTemplates.server.luau`, `onPlayerAdded`
**Related documentation:** [Player lifecycle](../architecture/player-lifecycle.md)

#### Observed behaviour — FACT

```lua
local success, isVoiceEnabled = pcall(function()
    return VoiceChatService:IsVoiceEnabledForUserIdAsync(player.UserId)
end)

if success then
    if not isVoiceEnabled then
        player:Kick("Este juego es exclusivo para usuarios con Chat de Voz. …")
    end
else
    -- Si Roblox falla la red al verificar, quizas conviene que le hagamos kick tambien
    warn("No se pudo verificar el estado del chat de voz de " .. player.Name)
end
```

Three branches: voice off → kick; voice on → allow; **check errored → allow**.

#### Why this may be a problem

Voz Hispana is voice-chat-only by design, and this is the only place that requirement is
enforced. The third branch admits a player whose eligibility was never established.

#### Theory — THEORY

During a Roblox voice-service incident, `IsVoiceEnabledForUserIdAsync` would fail for
many players at once and the gate would admit all of them for the duration.

#### Evidence

The source comment on the failure branch — *"quizas conviene que le hagamos kick
tambien"* — shows the author considered kicking here and left it open. This is a
**recorded open decision**, not an oversight, which is why it is classified as an
Observation.

#### Unknowns

- The real failure rate of `IsVoiceEnabledForUserIdAsync`.
- Which behaviour the team actually wants. Failing closed during a Roblox outage would
  make the game unplayable; failing open admits ineligible players. Both are defensible.

#### Example scenario

1. Roblox voice services degrade.
2. Players join. Every `pcall` returns `false`.
3. Every player is admitted, including players with voice chat disabled.

#### Expected vs possible actual behaviour

| Expected | Possible actual |
|---|---|
| Only voice-enabled players are in the game | Players without voice chat are present during the incident |

#### Verification plan — *Failure Recovery*, *Functional*

1. In a test place, temporarily point the check at a stub that raises.
   **Do not modify the shipped script** — copy it into a scratch place.
2. Join with two accounts, one voice-enabled and one not.
3. Observe that both are admitted and that the `warn` appears in the server log.
4. Repeat with the real service to confirm the kick path still works.

**Pass:** the team confirms fail-open is the intended policy, and it is documented.
**Fail:** fail-open is not intended — in which case this becomes a product decision, not
a code defect to be fixed silently.

**Instrumentation suggested:** count `pcall` failures per hour with a distinct log tag, so
the real-world frequency is known before anyone changes the policy.

---

## BUG-CANDIDATE-002

### Presence entry can outlive its server by up to the TTL

**System:** World System · **Classification:** Possible Bug / Requires Lifecycle Testing
**Verification status:** Unverified · **Severity if confirmed:** Medium · **Confidence:** Medium

**Related code:** `Core/ServerStorage/WorldSystem/ServerPresence.luau` — `Cleanup`,
`safeRemove`, `isThrottled`
**Related functions:** [`ServerPresence:Cleanup`](/api/ServerPresence),
[`ServerPresence.SafeGet`](/api/ServerPresence)
**Related documentation:** [Server lifecycle](../architecture/server-lifecycle.md)

#### Observed behaviour — FACT

- The registry entry is written with `ACTIVE_TTL = 120` seconds and refreshed every 30.
- `Cleanup` removes it, and is reached only from `game:BindToClose` (or, for houses, from
  the `onDenied` path).
- `safeRemove` retries up to `MAX_RETRIES = 6` with exponential backoff, but **abandons
  the removal entirely** when MemoryStore reports throttling:

```lua
elseif isThrottled(err) then
    throttled = true
    warn("[ServerPresence] RemoveAsync throttled; abandono los reintentos.")
```

#### Why this may be a problem

Between a server's death and its entry expiring, the directory advertises a server that
no longer exists. A player who picks it from a browser is teleported to a dead `JobId`.

#### Theory — THEORY

Three routes to a stale entry: `BindToClose` exceeding its window; a crash where nothing
runs at all; or MemoryStore throttling during shutdown, where the abandonment is by
design. In all three the entry survives until its TTL, ≤120 s.

#### Evidence

The TTL is what bounds the damage, and the design leans on it — see `Lease`'s comment
that *"El TTL da la liveness"*. `ServerPresence` also disconnects its player connections
before removing the key precisely so a late `PlayerRemoving` cannot resurrect it, which
shows staleness was considered.

#### Unknowns

- What Roblox does with a teleport to a `ServerInstanceId` that no longer exists — a
  clean error the caller can present, or a poor user-facing failure.
- Whether any consumer surfaces that failure to the player.

#### Example scenario

1. Two players are in a public server; it shuts down abruptly.
2. Within 120 s a third player opens the server browser and selects it.
3. `JoinServer` finds the entry, reads `jobId`, and calls `TeleportAsync`.

#### Verification plan — *Lifecycle*, *Teleport*, *Failure Recovery*

1. Start a public server; confirm its key in `UserServerRegistry_Test`.
2. Force-close it without a graceful shutdown.
3. Poll the map every 10 s and record when the entry disappears. Expect ≤120 s.
4. Inside that window, have another player select that server.
5. Record what `safeTeleport` returns and what the player sees.
6. Repeat with a normal shutdown and confirm the entry disappears immediately.

**Pass:** the entry clears within the TTL, and a teleport inside the window fails with a
message the player understands.
**Fail:** the entry outlives the TTL, or the teleport hangs or leaves the player in a
broken state.

**Instrumentation suggested:** log `serverKey`, `os.time()` and the outcome at the start
and end of `Cleanup`, and log every `safeTeleport` failure with its reason.

---

## BUG-CANDIDATE-003

### A failed respawn leaves the player with no character and nothing retries

**System:** Character · **Classification:** Possible Bug / Requires Failure Injection
**Verification status:** Unverified · **Severity if confirmed:** Medium · **Confidence:** Medium

**Related code:** `Core/…/ServerScripts/playerManager.server.luau` — `respawnPlayer`,
`onCharacterAdded`
**Related documentation:** [Character lifecycle](../architecture/character-lifecycle.md)

#### Observed behaviour — FACT

```lua
task.delay(RESPAWN_DELAY, function()
    if player.Parent ~= Players then respawning[player] = nil; return end
    local ok, err = pcall(function() player:LoadCharacterAsync() end)
    if not ok then warn("[playerManager] Error respawneando a", player.Name, err) end
    respawning[player] = nil
end)
```

`Humanoid.Died` is connected with `:Once`, so it will not fire again for the dead
character. `playersLoaded[player]` stays `true`, and the request path rejects a client
`LoadCharacterRequest` while it is set.

#### Why this may be a problem

If `LoadCharacterAsync` throws, the failure is warned and the flag cleared, but nothing
retries. The death handler cannot fire again, and the client's request path is closed by
`playersLoaded`.

#### Theory — THEORY

A player whose respawn call fails is stranded without a character until they rejoin.

#### Evidence

`respawnPlayer` has no retry loop. `canProcessLoadCharacterRequest` rejects when
`playersLoaded[player]` is set, and `respawnPlayer` never clears it — only the *join*
path clears it, and only when *its own* `LoadCharacterAsync` fails.

#### Unknowns

- How often `LoadCharacterAsync` actually throws for a player still in the server.
- Whether another system (possibly in a binary asset) also spawns characters and would
  paper over this.

#### Example scenario

1. Player dies. `Humanoid.Died` fires once.
2. `respawnPlayer` waits 3 s and calls `LoadCharacterAsync`, which throws.
3. The warning is logged; `respawning` is cleared; `playersLoaded` remains `true`.
4. The client asks for a character; `canProcessLoadCharacterRequest` rejects it as
   "Character ya solicitado/cargado".

#### Expected vs possible actual behaviour

| Expected | Possible actual |
|---|---|
| The player respawns, perhaps after a retry | The player is stuck with no character until they rejoin |

#### Verification plan — *Failure Recovery*, *Lifecycle*

1. In a scratch copy of the place, wrap `LoadCharacterAsync` so it throws on the first
   respawn only.
2. Join, die, and observe.
3. Confirm whether a character eventually appears, and by what route.
4. From the client, fire `LoadCharacterRequest` and confirm it is rejected.

**Pass:** the player recovers, by retry or by another system.
**Fail:** no character appears and the client's request is refused.

**Instrumentation suggested:** log every `LoadCharacterAsync` failure with the player and
the path (join vs respawn), and log rejected `LoadCharacterRequest`s with their reason —
today two of the four rejection reasons are silent by design.

---

## BUG-CANDIDATE-004

### Convergence after a denied host may strand players

**System:** Housing · **Classification:** Possible Bug / Requires Multiplayer Testing
**Verification status:** Unverified · **Severity if confirmed:** High · **Confidence:** Low

**Related code:** `PlayerHouses/ServerScriptService/PlayerWorld_Init.lua.server.luau` —
`convergeToOwner`; `DataKit/Store.luau` — `_resolveOwnership`
**Related documentation:** [Reserved servers](../architecture/reserved-servers.md)

:::note Confidence is deliberately Low

The mechanism this entry questions is the *mitigation*, not a gap. The double-reservation
race is genuinely guarded — see [Reserved servers](../architecture/reserved-servers.md).
This entry asks only whether the last-resort path behaves well under load.

:::

#### Observed behaviour — FACT

When a second house instance boots for a world that is already hosted, its `Store` has
`onConflict = "deny"`, so `_resolveOwnership` fires `onDenied(owner, ownerMeta)`.
`PlayerWorld_Init` then:

1. cleans up its presence;
2. calls `convergeToOwner`, which teleports all present players to `ownerMeta.accessCode`,
   retrying `CONVERGE_ATTEMPTS = 3` times with `CONVERGE_RETRY = 0.5` s;
3. **kicks** everyone if all three attempts fail:

```lua
for _, plr in players do
    plr:Kick("[Error] This world is already hosted. Please try joining again.")
end
```

It also connects `Players.PlayerAdded` so later arrivals are forwarded too.

#### Why this may be a problem

Three attempts over 1.5 s is a short budget for a teleport, and the fallback is a kick.

#### Theory — THEORY

Under teleport throttling, or if `ownerMeta` is stale by the time convergence runs, the
attempts exhaust and players are kicked from a house they are entitled to enter.

#### Evidence

`convergeToOwner` returns `false` without attempting anything when `ownerMeta` is
malformed or when `ownerMeta.accessCode == selfAccessCode`; in that case `onFailedServer`
runs and `ServerPresence.KickAll` ejects everyone. So there are two distinct routes to a
kick, not one.

#### Unknowns

- The real success rate of `TeleportAsync` between two reserved servers under load.
- How often the residual race actually occurs — it requires two lobbies to interleave
  inside a window of milliseconds.

#### Example scenario

1. Lobby A stages house `123_playaRoom` and reserves instance X.
2. Instance X boots and claims the lease.
3. Lobby B's hosted-check ran *just* before X's claim, so B also stages, reserves
   instance Y, and sends its player there.
4. Y boots, is denied, and tries to converge its player to X.
5. All three teleports fail.
6. The player is kicked.

#### Verification plan — *Multiplayer*, *Concurrency*, *Teleport*

1. Two accounts in two different lobby servers, same `HouseId`, not yet hosted.
2. Trigger `JoinServer` on both as close to simultaneously as possible; repeat 20 times,
   varying the offset from 0 to 500 ms.
3. For each run record: how many reserved instances were created, whether any instance
   logged `[PlayerWorld] World already hosted`, and where each player ended up.
4. Repeat 5 more runs with the network throttled to force teleport failures.

**Pass:** both players always end up in the same instance; no kicks in the unthrottled
runs.
**Fail:** two live instances of the same house persist, or a player is kicked in an
unthrottled run.

**Instrumentation suggested:** log `serverKey`, `game.JobId`, `accessCode` and
`os.clock()` at every stage of `hostWorld` and at every `onDenied`, so runs can be
correlated across servers.

---

## BUG-CANDIDATE-005

### Teleport with an access code whose instance has already shut down

**System:** Housing · **Classification:** Requires Teleport Testing
**Verification status:** Unverified · **Severity if confirmed:** Medium · **Confidence:** Low

**Related code:** `WorldManager.server.luau` — `teleportToHost`; `DataKit/Lease.luau`
**Related documentation:** [Reserved servers](../architecture/reserved-servers.md)

#### Observed behaviour — FACT

A house's reachability is the `DataKitLeases` entry for `World/{key}`, with a 120-second
TTL refreshed every 30 s. `store:close()` releases it on a graceful shutdown; an abrupt
death leaves it to expire.

Within that window `claimStaged` returns `kind = "hosted"` and `WorldManager` teleports
the player using the dead instance's `accessCode`.

#### Why this may be a problem

The player is sent to a reserved instance that no longer exists.

#### Theory — THEORY

Roblox's documented behaviour is that teleporting with a `ReservedServerAccessCode` whose
instance has shut down **starts a fresh instance** with that same code. If so this is
benign: the new instance boots, finds the lease expired or expiring, and takes over.

This documentation does not assert that behaviour, because it is not established by this
repository's source. That is the whole point of the entry.

#### Unknowns

- Whether a shut-down reserved instance's access code is genuinely reusable.
- What the new instance does if it boots while the *old* lease has not yet expired — it
  would be denied and try to converge to a dead owner, which loops back into
  [BUG-CANDIDATE-004](#bug-candidate-004).

#### Example scenario

1. A house server runs, then crashes without `BindToClose` completing.
2. Within 120 s the owner tries to re-enter.
3. `claimStaged` reports `hosted` with the dead `accessCode`.
4. `TeleportAsync` is called with it.

#### Verification plan — *Teleport*, *Lifecycle*, *Failure Recovery*

1. Open a house; record its `accessCode` from `DataKitLeases`.
2. Force-close the instance without a graceful shutdown.
3. **Immediately** (well inside 120 s) have the owner re-enter.
4. Record whether a new instance starts, whether it holds the same `accessCode`, and
   whether it acquires the lease or is denied.
5. Repeat starting at 130 s, after the lease has certainly expired, as the control.

**Pass:** step 3 lands the player in a working house in both timings.
**Fail:** step 3 errors, hangs, or produces an instance that immediately denies itself.

**Instrumentation suggested:** log `accessCode` and `game.JobId` on every house boot, and
log the `claimStaged` outcome (`hosted` / `staged` / won / MemoryStore failure) on every
`hostWorld`.

---

## BUG-CANDIDATE-006

### A Studio session can publish a fake access code to the live registry

**System:** Housing · **Classification:** Likely Bug / Requires Integration Testing
**Verification status:** Unverified · **Severity if confirmed:** High · **Confidence:** Medium

**Related code:** `WorldManager.server.luau` — `reserveAccessCode`, `safeTeleport`,
`hostWorld`
**Related documentation:** [Reserved servers](../architecture/reserved-servers.md)

#### Observed behaviour — FACT

`reserveAccessCode` returns a **fabricated GUID** in Studio instead of reserving:

```lua
local function reserveAccessCode(placeId: number): string?
    if RunService:IsStudio() then
        return HttpService:GenerateGUID(false)
    end
    …
```

`safeTeleport` also becomes a no-op in Studio:

```lua
if not RunService:IsStudio() then
    … TeleportAsync …
else
    warn("[WorldManager] Teleport ignored in studio")
end
return true, nil
```

But the code path **between** those two is not Studio-aware. `hostWorld` still calls
`Profiles.World.claimStaged`, and on success still runs `claim:setMeta(meta)` and
`claim:tryClaim()` — writes that go to **MemoryStore**, which is universe-scoped and
shared with live servers.

#### Why this may be a problem

MemoryStore and DataStore are not sandboxed per environment. A Studio session with API
access enabled writes into the same `DataKitLeases` map that production reads.

#### Theory — THEORY

A developer testing in Studio stages a house key and publishes a `staged/World/{key}`
entry whose `accessCode` is a random GUID that reserves nothing. For the staging TTL
(30 s), a live player asking for that same house is told the world is `staged`, polls
`peekStaged`, receives the fake code, and is teleported with a
`ReservedServerAccessCode` that was never issued by `TeleportService`.

#### Evidence

- `reserveAccessCode` fabricates the code — **FACT**.
- `claimStaged` writes to the real MemoryStore with no Studio guard — **FACT**, and the
  presence of `RunService:IsStudio()` guards on either side shows the author was
  environment-aware precisely here and did not guard this step.
- The staging key is namespaced by profile name and id only (`staged/World/{userId}_{room}`),
  not by environment — **FACT**.
- `ACTIVE_MAP_NAME = "UserServerRegistry_Test"` — the `_Test` suffix suggests the
  *presence* map is at least conventionally separated. The lease map name,
  `DataKitLeases`, carries no such suffix.

#### Unknowns

- Whether "Enable Studio Access to API Services" is actually on for this universe. If it
  is off, MemoryStore calls fail in Studio and the whole scenario collapses — which is
  why confidence is Medium and not High.
- Whether Studio testing is ever done against the production universe rather than a
  separate one.

#### Example scenario

1. A developer opens the house place in Studio with API access enabled.
2. A player joins the local session; `PlayerWorld_Init` uses the Studio fallback key
   `"{UserId}_defaultRoom"`.
3. In another Studio session on the lobby place, `JoinServer` is invoked for that key.
4. `claimStaged` wins, `reserveAccessCode` returns a GUID, and it is published.
5. Within 30 s, a live player asks for the same house and receives the fabricated code.

#### Expected vs possible actual behaviour

| Expected | Possible actual |
|---|---|
| Studio testing cannot affect live players | A live player is teleported with an access code that reserves nothing |

#### Verification plan — *Integration*, *Security*, *Teleport*

1. Confirm whether API access is enabled for the universe, and whether Studio testing
   targets the production universe. **If both are no, close this entry as not applicable
   and record that.**
2. If yes: in Studio, invoke `JoinServer` for a house key you own. Read
   `staged/World/{key}` from `DataKitLeases` with a separate script.
3. Check whether an entry exists and whether its `accessCode` is a GUID rather than a
   real reserved code.
4. In a live server, within 30 s, request the same house and record the outcome.

**Pass:** no staging entry is written from Studio, or the live request is unaffected.
**Fail:** a fabricated code reaches a live player.

**Instrumentation suggested:** log `RunService:IsStudio()`, `game.JobId` and the code's
provenance (reserved vs generated) on every `reserveAccessCode`, so Studio-origin entries
are identifiable in the registry.

---

## BUG-CANDIDATE-007

### The client script loader is not in this repository

**System:** Client · **Classification:** Observation / Requires Runtime Verification
**Verification status:** Unverified · **Severity if confirmed:** — · **Confidence:** High

**Related code:** `src/ServerScriptService/InitScripts.server.luau`;
`Core/ReplicatedStorage/Events/GameLoad/InitScriptsRequest.model.json`
**Related documentation:** [Client lifecycle](../architecture/client-lifecycle.md)

This is not a suspected defect. It is a **documentation gap** recorded in the same format
because it needs the same kind of runtime answer.

#### Observed behaviour — FACT

- All 27 `RunContext = "Client"` scripts under `Core/ReplicatedStorage/Client` ship
  `Disabled: true`.
- `InitScripts.server.luau` explicitly skips descendants of `ReplicatedStorage.Client`.
- No `.luau` file in this repository assigns `Enabled = true` to any `Script` or
  `LocalScript`.
- A `RemoteEvent` named `InitScriptsRequest` exists under `Events/GameLoad` and is
  referenced by **no** `.luau` file here.
- Three of the four scripts tagged `IgnoreAutoEnable` live under
  `ReplicatedStorage/Client` — a folder the server-side sweep already skips wholesale, so
  the tag is redundant for the server loader and only meaningful to a *client* one.
- The tag `IgnoreLoader`, on both bootstrap scripts, likewise has no consumer here.

#### Theory — THEORY

A client-side loader exists outside this repository — most plausibly inside
`src/StarterPlayer/StarterPlayerScripts.rbxm` — which waits for `InitAfterTemplates`,
enables the client scripts, honours `IgnoreAutoEnable`, and probably uses
`InitScriptsRequest` to coordinate with the server.

#### Why it matters

Until it is confirmed, [Client lifecycle](../architecture/client-lifecycle.md) is
incomplete by construction, and any statement about client startup order is unfounded.

#### Verification plan — *Functional* — about two minutes

1. Open the place in Roblox Studio.
2. Inspect `StarterPlayer.StarterPlayerScripts` and `StarterPlayer.StarterCharacterScripts`
   in the Explorer.
3. Search the whole DataModel for `Enabled = true`, `InitScriptsRequest` and
   `IgnoreAutoEnable`.
4. Record every script found, with its full path and source.

**Pass:** the loader is found and can be documented.
**Fail:** no such loader exists — which would be a far more serious finding, since the
client scripts would then never run, and would need its own entry.

---

---

## BUG-CANDIDATE-008

### A purchase grants the item before it charges for it

**System:** Housing / Economy · **Classification:** Possible Bug / Requires Failure Injection
**Verification status:** Unverified · **Severity if confirmed:** Medium · **Confidence:** Medium

**Related code:** `Core/…/ServerScripts/ShopServerSystem.server.luau`, `ProcessPurchase`;
`Core/…/ServerScripts/PlayerDataReplicator.server.luau`, `buySlot`
**Related documentation:** [Housing → Identity and ownership](../systems/housing/identity.md)

#### Observed behaviour — FACT

Both purchase paths mutate the player's profile **before** deducting the currency.

In `ProcessPurchase`:

```lua
store:update(function(current)
    if not table.find(current.rooms, itemIdToBuy) then
        table.insert(current.rooms, itemIdToBuy)
    end
    return current
end)
UpdateHouses:FireClient(player, store:get().rooms)
if not RunService:IsStudio() then
    collections.SetAmount(player, value, tonumber(value.Value) - finalPrice)
end
```

`buySlot` has the same shape: `store:update(...)` then `collections.SetAmount(...)`.

#### Why this may be a problem

The two writes are not atomic and are not ordered defensively. Anything that prevents the
second from completing leaves the player owning an item they were not charged for.

#### Theory — THEORY

If `collections.SetAmount` raises, yields past a server shutdown, or writes to a store
that fails, the room stays in `rooms` — which `DataKit` will persist on its next
autosave — while the currency is untouched.

#### Evidence

- The ordering is direct and unambiguous — **FACT**.
- The funds check reads `value.Value` *before* the update and the deduction recomputes
  from `tonumber(value.Value)` *after* it, so the two reads are separated by a yielding
  call — **FACT**.
- `buySlot` carries an explicit comment showing the author reasoned about concurrent
  invokes (*"dos invokes simultáneos leerían el mismo `slots` y cobrarían dos veces"*) and
  added a per-player guard, but did not reorder the grant and the charge — **FACT**. This
  is why confidence is Medium rather than High: the concurrency angle was considered, so
  the ordering may be a deliberate "grant first, never lose a purchase" choice.

#### Unknowns

- Whether `collections.SetAmount` can fail. `Collections` has not been read.
- Whether the currency lives in the same `DataKit` store as `rooms`. If it does, both
  writes land in one save and the window is far smaller than it looks.

#### Example scenario

1. A player with exactly 4 000 Coins buys `playaRoom` for 4 000.
2. `store:update` inserts the room; the client is told it owns it.
3. `SetAmount` fails.
4. The player owns the house and still has 4 000 Coins.

#### Expected vs possible actual behaviour

| Expected | Possible actual |
|---|---|
| Either both the grant and the charge happen, or neither | The item is granted and not paid for |

#### Verification plan — *Failure Recovery*, *Persistence*, *Functional*

1. Read `Client/EconomySystem/Collections.luau` first and establish where currency is
   stored. **If it is the same `DataKit` store as `rooms`, re-assess — the window may be
   negligible.**
2. In a scratch place, stub `collections.SetAmount` to raise.
3. Buy a house. Confirm whether the room appears in `rooms` and whether the currency
   changed.
4. Rejoin to confirm what persisted.
5. Repeat for `buySlot`.

**Pass:** the grant does not persist without the charge.
**Fail:** the player keeps the item and the currency.

**Instrumentation suggested:** log a single purchase record — player, item, price,
balance before, balance after — written after both operations, so a mismatch is
detectable in aggregate.

---

## BUG-CANDIDATE-009

### A first-boot name lookup failure names the house permanently

**System:** Housing · **Classification:** Possible Bug / Requires Failure Injection
**Verification status:** Unverified · **Severity if confirmed:** Low · **Confidence:** High

**Related code:** `PlayerHouses/ServerScriptService/PlayerWorld_Init.lua.server.luau`,
`getRoomDisplayName`; `PlayerHouses/ServerScriptService/WorldService.luau`, `start`
**Related documentation:** [Housing → Persistence](../systems/housing/persistence.md)

#### Observed behaviour — FACT

```lua
local function getRoomDisplayName(ownerId: number, roomName: string): string
    local success, playerName = pcall(function()
        return Players:GetNameFromUserIdAsync(ownerId)
    end)
    if success then
        return ("%s's %s"):format(playerName, HousesInfo[roomName].name)
    else
        return "default Name"
    end
end
```

and the value is written only once, guarded by the sentinel:

```lua
store:update(function(data)
    if data.settings.OwnerId == 0 then
        data.settings.OwnerId = config.ownerId
        data.settings.Name = config.displayName
    end
    return data
end)
```

#### Why this may be a problem

The initialisation is one-shot by design. A transient Roblox failure during the very first
boot of a house is therefore written into permanent state, and no later boot corrects it.

#### Theory — THEORY

A house first opened during a Roblox API hiccup is called `"default Name"` for the rest of
its existence, in the browser and in the directory, until its owner renames it by hand.

#### Evidence

The `OwnerId == 0` guard is the whole mechanism — **FACT**. Since `OwnerId` is written in
the same statement as `Name`, a successful boot with a failed name lookup closes the door
on both. Confidence is High because this needs no timing coincidence: one failed call at
one moment is enough.

#### Unknowns

- The real failure rate of `GetNameFromUserIdAsync`.
- Whether the affected owner would notice and rename.

#### Example scenario

1. A player buys `VistaLujosaRoom` and opens it for the first time.
2. `GetNameFromUserIdAsync` fails.
3. `settings.Name` is set to `"default Name"` and `OwnerId` to the real id.
4. Every later boot finds `OwnerId ~= 0` and skips the initialisation.

#### Expected vs possible actual behaviour

| Expected | Possible actual |
|---|---|
| The house is named `"<Owner>'s Casa Vista Lujosa"` | It is named `"default Name"` forever |

#### Verification plan — *Failure Recovery*, *Persistence*

1. In a scratch place, stub `Players:GetNameFromUserIdAsync` to raise.
2. Open a house that has never been opened before.
3. Confirm `settings.Name == "default Name"` and `OwnerId` is correct.
4. Remove the stub, shut down, reopen.
5. Confirm the name is **not** corrected.
6. Confirm `SetWorldName` still works.

**Pass:** the name is corrected on a later boot, or the failure does not write `OwnerId`
either.
**Fail:** the house keeps `"default Name"` after step 5.

**Instrumentation suggested:** log every first-boot initialisation with the owner id, the
resolved name, and whether the lookup succeeded.

---

## BUG-CANDIDATE-010

### `WorldDataReplicator` misses an already-`ready` server

**System:** Housing · **Classification:** Likely Bug / Requires Lifecycle Testing
**Verification status:** Unverified · **Severity if confirmed:** Medium · **Confidence:** Medium

**Related code:** `PlayerHouses/ServerScriptService/WorldDataReplicator.server.luau`
(bottom of file); compare `PlayerHouses/ServerScriptService/ModeratorManager.server.luau`
**Related documentation:** [Housing → Server lifecycle](../systems/housing/server-lifecycle.md)

#### Observed behaviour — FACT

`WorldDataReplicator` wires all of its replication inside a change listener, and never
checks the current value:

```lua
ServerInfo:GetAttributeChangedSignal("status"):Connect(function()
    if ServerInfo:GetAttribute("status") ~= "ready" then return end
    if replicationWired then return end
    replicationWired = true
    for _, storeName in ReplicatedDataStores do pushStore(storeName) end
    WorldService.OnStoreUpdated:Connect(function(storeName) … end)
end)
```

`ModeratorManager`, in the same folder, handles both cases:

```lua
if ServerInfo:GetAttribute("status") == "ready" then
    onReady()
else
    local conn
    conn = ServerInfo:GetAttributeChangedSignal("status"):Connect(function() … end)
end
```

#### Why this may be a problem

If the attribute is already `"ready"` when `WorldDataReplicator` starts, the signal never
fires again for that transition, `replicationWired` stays `false`, and **two** things never
happen: the initial push of settings/roles/bans to privileged clients, and the subscription
to `WorldService.OnStoreUpdated` that keeps them current.

#### Theory — THEORY

The owner opens the house's administration UI and sees nothing — no roles, no bans, no
settings — and changes made by others never appear. The administrative *remotes* still work,
because they are `RemoteFunction`s bound at file scope, outside the listener. So the symptom
is "the panel is empty" rather than "administration is broken".

#### Evidence

- The asymmetry between two files in the same folder solving the same problem — **FACT**,
  and strong evidence the omission is unintentional.
- The remotes are bound outside the listener while replication is inside it — **FACT** —
  which is what makes the symptom partial rather than total.
- Reachability: `WorldDataReplicator` ships `Disabled: true` and is enabled by
  `InitScripts`, which runs `task.wait(1)` plus a full `game:GetDescendants()` walk. A
  reserved house server boots *because* a player is teleporting into it, and
  `PlayerWorld_Init` starts the presence layer as soon as that player arrives. The two
  sequences overlap. **INFERENCE**, and the reason confidence is Medium rather than High —
  the ordering is plausible but unproven.

#### Unknowns

- Whether the enable sweep reliably completes before the first player triggers
  `PlayerWorld_Init`, in a real reserved server.
- Whether `GetDescendants()` ordering makes one of the two scripts consistently earlier.

#### Example scenario

1. A reserved house server boots with a player already teleporting in.
2. `InitScripts` begins its 1-second wait.
3. The player arrives; `PlayerWorld_Init` — already enabled — initialises, and presence
   reports ready. `ServerInfo.status` becomes `"ready"`.
4. `InitScripts` finishes and enables `WorldDataReplicator`.
5. Its listener waits for a transition that has already happened.

#### Expected vs possible actual behaviour

| Expected | Possible actual |
|---|---|
| The owner's admin panel is populated and stays current | It is empty and never updates |

#### Verification plan — *Lifecycle*, *Integration*

1. Add a log line at the top of `WorldDataReplicator`, and inside its listener, recording
   `ServerInfo:GetAttribute("status")` and `os.clock()`.
2. Add the same at the top of `ModeratorManager` and in `onHouseStarted`.
3. Open a house 20 times and record the ordering each time.
4. In runs where the status was already `"ready"`, confirm whether the admin UI is
   populated.
5. Force the case by delaying `PlayerWorld_Init`'s enablement relative to
   `WorldDataReplicator`'s.

**Pass:** replication is wired in every run.
**Fail:** any run where the status was already `"ready"` and replication never wired.

**Instrumentation suggested:** log `replicationWired` and the observed status at
`WorldDataReplicator` startup — one line is enough to settle this in production.

---

## BUG-CANDIDATE-011

### The `moderator` role cannot moderate

**System:** Housing · **Classification:** Likely Bug / Confirmed by Static Analysis
**Verification status:** Unverified · **Severity if confirmed:** Medium · **Confidence:** High

**Related code:** `PlayerHouses/ServerScriptService/WorldDataReplicator.server.luau`,
`canModerate`, `pushStore`
**Related documentation:** [Housing → Permissions](../systems/housing/permissions.md)

#### Observed behaviour — FACT

```lua
local function canModerate(data: any, player: Player): boolean
    if data.settings.OwnerId == player.UserId then
        return true
    end
    return roleFor(data, player.UserId) > RolesInfo["moderator"]
end
```

`RolesInfo.moderator == 48`, so a player whose role is exactly `moderator` evaluates
`48 > 48` → `false`.

In the **same file**, replication uses `>=`:

```lua
if role >= RolesInfo["moderator"] or data.settings.OwnerId == plr.UserId then
```

And `ModeratorManager`'s entry check also uses `>=`:

```lua
local function hasAtLeastGuestRole(rolesMap, userId): boolean
    local val = rolesMap and rolesMap[tostring(userId)] or 0
    return val >= getGuestThreshold()
end
```

#### Why this may be a problem

Two comparisons against the same ladder, in the same file, disagree. A `moderator`
**receives** the roles, settings and bans payloads — so the administration UI is populated
for them — but every administrative remote refuses them.

#### Theory — THEORY

A player granted `moderator` sees a working-looking admin panel in which every action
silently fails. `SetBan`, `SetUserRole` and `SetWorldName` return `nil` on refusal, and
`togglePrivacity` only `warn`s server-side, so the client gets no error to display.

#### Evidence

- The `>` / `>=` split within one file — **FACT**. This is the core of the finding.
- `canModerate` is *named* for the role it excludes — **FACT**.
- `designer` (47) and `guest` (46) are also excluded, which is presumably intended; the
  ladder only makes sense if some rung is the administrative threshold, and `moderator` is
  the one the name points at.

This is classified **Confirmed by Static Analysis** for the *inconsistency*, which is
certain, and **Likely Bug** for the *intent*, which is not — the fix could equally be to
rename the function or to move the threshold. That is a product decision.

#### A second, related finding

`SetUserRole` checks that the caller can moderate and that the target is not the owner. It
does **not** check that the caller outranks the role being granted:

```lua
if targetUserId == data.settings.OwnerId then return false, "CannotEditOwner" end
if roleName ~= "none" and RolesInfo[roleName] == nil then return false, "InvalidRole" end
```

So an `admin` (49) may grant `coOwner` (50), to another player or to themselves. Whether
that is intended is a product question; it is recorded here because it belongs to the same
review of the role model.

#### Unknowns

- Which of the two behaviours the team wants for `moderator`.
- Whether privilege escalation from `admin` to `coOwner` is deliberate.

#### Example scenario

1. The owner grants a friend `moderator`.
2. The friend opens the panel and sees the roles and bans lists — `pushStore` sent them.
3. They try to ban someone. `SetBan` returns `nil`. Nothing happens, no error.

#### Expected vs possible actual behaviour

| Expected | Possible actual |
|---|---|
| A `moderator` can ban and manage roles | They see the UI and every action silently fails |

#### Verification plan — *Functional*, *Security*

1. In a test house, grant a second account `moderator`.
2. Confirm the admin panel is populated for them.
3. Attempt `SetBan`, `SetUserRole`, `SetWorldName`, `togglePrivacity`. Record each result.
4. Repeat with `admin` (49) as the control — all should succeed.
5. As `admin`, grant `coOwner` to a third account, and to yourself. Record whether it is
   allowed.

**Pass:** step 3 succeeds, or the panel is correctly hidden from a moderator.
**Fail:** the panel is shown and every action is refused.

**Instrumentation suggested:** log every refused administrative call with the caller's
role and the threshold — this would surface the mismatch immediately in production.

---

## BUG-CANDIDATE-012

### House roles, settings and bans are readable by any occupant

**System:** Housing · **Classification:** Observation / Requires Security Testing
**Verification status:** Unverified · **Severity if confirmed:** Low · **Confidence:** High

**Related code:** `PlayerHouses/ServerScriptService/WorldDataReplicator.server.luau` —
`GetRolesRf`, `GetWorldSettingRF`, `GetBansRF`, `GetUserRolRF`
**Related documentation:** [Housing → Permissions](../systems/housing/permissions.md)

#### Observed behaviour — FACT

The four read remotes have no permission check:

```lua
GetRolesRf.OnServerInvoke = function(_player: Player)
    local data = WorldService.get()
    return data and data.roles or nil
end
```

Note `_player` — the caller is explicitly ignored. `GetWorldSettingRF` and `GetBansRF` are
the same shape. `GetUserRolRF` accepts an arbitrary `userId` and returns that user's role.

Meanwhile the **push** path is restricted:

```lua
if role >= RolesInfo["moderator"] or data.settings.OwnerId == plr.UserId then
    WorldDataUpdated:FireClient(plr, storeName, payload)
end
```

#### Why this may be a problem

The same three payloads are restricted when pushed and unrestricted when pulled. Whatever
the push restriction was protecting is obtainable by invoking the corresponding
`RemoteFunction` directly.

#### Theory — THEORY

Any player inside a house can read its full ban list and role table — a set of user ids and
their privilege levels. That is not sensitive in the way credentials are, but it is
information the code demonstrably intended to restrict.

#### Evidence

- The asymmetry between `pushStore`'s role bar and the read remotes' absence of one —
  **FACT**. This is why it is recorded at all: the intent to restrict is visible.
- `_player` is named with a leading underscore, the Luau convention for a deliberately
  unused parameter — **FACT**. So the omission is at least explicit.

#### Unknowns

- Whether restricting the reads was ever intended, or whether `pushStore`'s bar exists
  only to avoid sending payloads no one will use.

#### Example scenario

1. A player joins a public house they have no role in.
2. From the client console, they invoke `GetBans` and `GetRoles`.
3. They receive the complete ban list and role table.

#### Verification plan — *Security*, *Functional*

1. Join a house as a player with no role.
2. Invoke each of the four read remotes from the client.
3. Record what comes back.
4. Confirm `WorldDataUpdated` is **not** fired to that player, establishing the asymmetry.

**Pass:** the reads are refused, or the team confirms the data is intentionally public.
**Fail:** a role-less occupant obtains data the push path withholds.

**Instrumentation suggested:** log the caller's role on each of the four read remotes for
a period, to see whether role-less callers occur in practice.

---

## BUG-CANDIDATE-013

### A house server with no `TeleportData` strands its player silently

**System:** Housing · **Classification:** Possible Bug / Requires Runtime Verification
**Verification status:** Unverified · **Severity if confirmed:** Medium · **Confidence:** Medium

**Related code:** `PlayerHouses/ServerScriptService/PlayerWorld_Init.lua.server.luau` —
`extractPayload`, `onPlayerAdded`
**Related documentation:** [Housing → Error handling](../systems/housing/error-handling.md)

#### Observed behaviour — FACT

```lua
local function onPlayerAdded(player: Player)
    if booting or presence then
        return
    end
    local key, accessCode = extractPayload(player)
    if key then
        booting = true
        init(key, player, accessCode)
        booting = false
    end
end

Players.PlayerAdded:Once(onPlayerAdded)
```

`extractPayload` returns `(nil, nil)` when `GetJoinData().TeleportData` is missing or its
`key` is not a string. There is no `else`.

Every other failure inside `init` calls `onFailedServer`, which warns and kicks with an
explanation. This path alone produces no warning, no kick, and no state.

#### Why this may be a problem

Two effects compound. The player is left in a server with no world data, no presence and
no `isStarted`. And because the connection is `:Once`, it has now been **consumed** — a
later, correctly-teleported player cannot initialise the server either.

#### Theory — THEORY

One player arriving without valid `TeleportData` permanently poisons that reserved
instance for everyone who follows, with no log line to explain it.

#### Evidence

- `:Once` rather than `:Connect` — **FACT**. The `booting`/`presence` guards would already
  prevent double initialisation, so `:Once` adds nothing except this consumption.
- Every sibling failure path funnels through `onFailedServer` — **FACT**. This one does
  not, which makes it the odd one out.
- The loop over `Players:GetPlayers()` before the `:Once` uses `task.spawn`, so an
  already-present player is handled in parallel — **FACT**, and it means ordering between
  the two entry points is not deterministic.

#### Unknowns

- Whether a player can reach a `PlayerHouses` place without valid `TeleportData` at all.
  `WorldManager` always sets it, so candidate routes are a direct place join, a
  Roblox-initiated rejoin after a disconnect, or a teleport from code outside this
  repository. **This is the question that decides whether the entry matters**, which is why
  confidence is Medium.
- What `GetJoinData()` returns on a Roblox-initiated rejoin into a reserved server.

#### Example scenario

1. A player is teleported into a house and disconnects mid-teleport.
2. Roblox rejoins them into the reserved instance without the original `TeleportData`.
3. `extractPayload` returns nil; nothing happens; `:Once` is consumed.
4. The owner arrives correctly moments later, and the server still never initialises.

#### Expected vs possible actual behaviour

| Expected | Possible actual |
|---|---|
| An invalid arrival is rejected with a message, and the server still initialises for the next valid one | The server is inert and stays inert |

#### Verification plan — *Runtime*, *Teleport*, *Failure Recovery*

1. Establish first whether the case is reachable: teleport into a house place **without**
   `TeleportData` (a direct join to the reserved place, or a teleport with no data). **If
   Roblox refuses the join outright, close this entry and record that.**
2. If reachable, add a log line to `extractPayload`'s nil branch and confirm it is hit.
3. Have a second, correctly-teleported player join the same instance.
4. Record whether the server ever initialises.
5. Repeat by disconnecting a player mid-teleport and letting Roblox rejoin them.

**Pass:** the case is unreachable, or a later valid player still initialises the server.
**Fail:** the instance stays inert after a valid arrival.

**Instrumentation suggested:** a warning in the nil branch naming the player and dumping
`GetJoinData()`, which would make the case visible in production even before it is
reproduced.


---

## BUG-CANDIDATE-014

### A shared secret and a proxy host are hardcoded in a committed source file

**System:** Housing / Security · **Classification:** Confirmed by Static Analysis
**Verification status:** Unverified (the *exposure* is certain; the *impact* is not)
**Severity if confirmed:** High · **Confidence:** High

**Related code:** `Core/…/ServerScripts/WorldsBrowser.server.luau`, top of file —
the `MY_PROXY_URL` and `MY_SECRET_KEY` constants, used by `searchPlayer`
**Related documentation:** [Housing → Identity and ownership](../systems/housing/identity.md)

:::note The secret is not reproduced here

This page names the file and the constants. It does not repeat the value, and neither
should any other document. The value is in the repository and in its git history, which is
the point of this entry.

:::

#### Observed behaviour — FACT

`WorldsBrowser.server.luau` declares, as plain string literals at the top of a committed
file:

- a bare-IP `http://` URL for a self-hosted proxy, described in a comment as *"Nuestro
  servidor VPS privado (Puerto 80)"*;
- a shared secret, sent as the `My-Secret` request header.

`searchPlayer` then calls `HttpService:GetAsync(url, true, headers)` against that host to
resolve a player-name search.

#### Why this is a problem

Three distinct issues, in decreasing certainty:

1. **The secret is committed.** Anyone with read access to the repository — now, or at any
   point in its history — has it. Rotating the file does not rotate the history.
2. **The transport is plain HTTP to a bare IP.** The header travels unencrypted and the
   host is unauthenticated, so it is interceptable and spoofable in transit.
3. **The remote that reaches it is unthrottled.** `SearchPlayerRF.OnServerInvoke` calls
   `searchPlayer` with the client's keyword directly, with no rate limit, no length cap and
   no cooldown — unlike `LoadCharacterRequest`, which has a 2-second cooldown. Every invoke
   is one outbound HTTP request to the proxy.

The keyword itself is URL-encoded with `HttpService:UrlEncode`, so query-parameter
injection is handled.

#### Theory — THEORY

An attacker holding the secret can query the proxy directly, bypassing the game. If the
proxy exposes anything beyond user search, the blast radius is larger than this one
endpoint. Separately, a client looping `SearchPlayer` can drive traffic to the VPS at
whatever rate the server will process, which is a denial-of-service vector against
infrastructure the game depends on.

#### Evidence

- The literals are in the file — **FACT**.
- `SearchPlayerRF.OnServerInvoke` has no guard of any kind — **FACT**:

  ```lua
  SearchPlayerRF.OnServerInvoke = function(player: Player, keyword: string)
      print("🔍 Buscando jugador:", keyword)
      return searchPlayer(keyword)
  end
  ```

  Note also that `keyword` is not type-checked, unlike every remote in `WorldManager`. A
  non-string reaches `HttpService:UrlEncode`.

#### Unknowns

- What else the proxy exposes, and what the secret authorises. Not knowable from this
  repository.
- Whether the repository is private, and who has had access to it.
- Whether the proxy applies its own rate limiting.

#### Verification plan — *Security*

**Do not perform this against production infrastructure without the owner's explicit
authorisation.** These steps are for the people who own the VPS.

1. Confirm the secret is present in the current `main` and in the git history.
2. Determine the full surface the proxy exposes and what the secret grants.
3. Review the proxy's access logs for requests not originating from Roblox servers.
4. Measure what one client can do: invoke `SearchPlayer` in a loop and observe the
   outbound request rate.

**Pass:** the secret grants nothing of value, and the proxy rate-limits independently.
**Fail:** the secret authorises anything worth protecting, or a single client can saturate
the proxy.

#### Recommended remediation

Out of scope for this documentation project — **no code has been changed** — but recorded
so it is not lost:

- Rotate the secret; assume the committed one is compromised.
- Move it out of source into a server-side secret store, and purge it from git history.
- Serve the proxy over HTTPS with a hostname and a valid certificate.
- Rate-limit and type-check `SearchPlayer`, following the pattern already used by
  `canProcessLoadCharacterRequest`.


## Coverage

What has and has not been examined, so this page is not mistaken for a full audit.

| Area | Read end to end | Notes |
|---|---|---|
| Bootstrap (4 files) | Yes | |
| `WorldManager`, `ServerPresence`, `Profiles` | Yes | |
| `PlayerWorld_Init`, `WorldService`, `PublicServerInit` | Yes | |
| `DataKit`: `init`, `Profile`, `Lease`, `Mutex`, `Health` | Yes | Already Moonwave-documented in-source |
| `DataKit`: `Store`, `BaseStore` | Partly | Ownership, staging, save/close read; transfer and inbox not yet |
| `playerManager`, `Client/PlayerManager` | Yes | |
| `PlayerWorld_Init`, `WorldService`, `WorldDataReplicator`, `ModeratorManager` | Yes | The whole `PlayerHouses` template |
| `ServerDirectory`, `WorldsBrowser` | Yes | |
| `PlayerDataReplicator` (server script), `PlayerSchema`, `HousesInfo`, `RolesInfo`, `GeneralConfiguration` | Yes | |
| `ShopServerSystem` | Partly | `ProcessPurchase` only; the shop rotation and `MessagingService` sync not yet |
| `EventService`, `ReferralService` | **No** | Queued |
| `PlayerDataService`, `WorldSystem/PlayerDataReplicator.luau` | **No** | Queued |
| `Collections` (currency) | **No** | Needed to close BUG-CANDIDATE-008 |
| `GlobalDataStore`, `GiftInbox` | **No** | Both use DataStoreService outside DataKit |
| Gameplay systems (~480 files) | **No** | Queued |
| 320 `.rbxm` binaries | **Not inspectable** | |

Absence of an entry for an area on this page means it has not been examined, **not** that
it is clean.
