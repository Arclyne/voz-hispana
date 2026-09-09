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
| `EventService`, `ServerDirectory`, `ReferralService` | **No** | Queued |
| Player data (`PlayerDataService`, `PlayerDataReplicator`, `PlayerSchema`) | **No** | Queued |
| Gameplay systems (~500 files) | **No** | Queued |
| 320 `.rbxm` binaries | **Not inspectable** | |

Absence of an entry for an area on this page means it has not been examined, **not** that
it is clean.
