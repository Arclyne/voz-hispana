# Documentation Progress

> Persistent memory for the Voz Hispana technical-documentation project.
> **Read this file completely before doing any documentation work.**
>
> Working branch: `docs/moonwave-documentation`
> Rule in force: **documentation only** — no executable Lua/Luau may change.

---

## Current Phase

**Phase 3 — Systems** (Housing complete; other systems pending)

---

## Overall Progress

**28 %**

Rationale for the number (kept deliberately conservative):
the repository holds **552 inspectable `.luau` files / ~80 500 lines** plus
**320 non-inspectable `.rbxm` binaries**. Phases 0–2 are complete and Housing —
the system the brief singles out — is documented in depth. **32 of 552 files have
been read** (see `docs/reference/script-inventory.md` for the per-file status).

That is 6 % by file count but a far larger share of the load-bearing code:
the entire bootstrap, the entire world/housing system, the reservation and
presence layers, and the persistence package. The remaining ~520 files are
gameplay systems (interactables, karaoke, machines, tools, shops, quests, jobs)
plus vendored third-party libraries.

The percentage is deliberately *not* file-count-weighted, because 480 of the
remaining files are gameplay leaves whose documentation value per file is much
lower than the bootstrap's. It reflects: 7 architecture pages + 7 housing pages
+ 3 reference pages + 14 evidenced bug candidates, against a plan that still
needs ~8 more systems and the per-script Moonwave sweep.

---

## Phases

- [x] Phase 0 — Initial Analysis
- [x] Phase 1 — Documentation Infrastructure
- [x] Phase 2 — Architecture
- [ ] Phase 3 — Systems
- [ ] Phase 4 — Script & Moonwave Reference
- [ ] Phase 5 — Cross-System Analysis
- [ ] Phase 6 — Validation & Test Planning

---

## Repository Facts (Phase 0 — established by direct inspection)

### Build / sync tooling

| Fact | Evidence |
|---|---|
| Rojo project, Rojo `7.7.0` pinned via Rokit | `rokit.toml`, `default.project.json` |
| Mapped services: `ReplicatedFirst`, `ReplicatedStorage`, `ServerScriptService`, `ServerStorage`, `StarterGui`, `StarterPack`, `StarterPlayer` | `default.project.json` |
| `StarterPack` is declared in `default.project.json` but **`src/StarterPack` does not exist on disk** | `default.project.json` vs `find src -maxdepth 1` |
| A committed `sourcemap.json` (~1.1 MB) exists at the repo root | root listing |

### File inventory

| Extension | Count |
|---|---|
| `.luau` | 552 |
| `.json` (`.meta.json` / `.model.json` / other) | 503 |
| `.rbxm` (**binary, not inspectable**) | 320 |
| `.gitkeep` | 11 |
| `.txt` | 2 |

`.luau` classification (by filename convention, since Rojo derives class from suffix):

| Kind | Count |
|---|---|
| `ModuleScript` | 445 |
| `Script` (`*.server.luau`) | 96 |
| `LocalScript` (`*.client.luau`) | 11 |

Total inspectable Luau: **~80 556 lines**.

### Luau distribution by area

| Files | Lines | Area |
|---|---|---|
| 416 | 56 896 | `TemplatesTesting/Core/ReplicatedStorage` |
| 80 | 12 322 | `TemplatesTesting/Core/ServerScriptService` |
| 33 | 7 062 | `TemplatesTesting/Core/ServerStorage` |
| 8 | 2 757 | `TemplatesTesting/BuildingSystem/ReplicatedStorage` |
| 4 | 858 | `TemplatesTesting/PlayerHouses/ServerScriptService` |
| 3 | 171 | `ServerStorage/Templates` |
| 1 | 68 | `TemplatesTesting/GameWorlds/ServerScriptService` |
| 1 | 10 | `TemplatesTesting/PlayerHouses/ReplicatedStorage` |
| 1 | 26 | `TemplatesTesting/Core/StarterGui` |
| 5 | 366 | root bootstrap (`ServerScriptService/*`, `ReplicatedStorage/*`) |

### Remotes / Bindables (declared as Rojo `.model.json`)

| ClassName | Count |
|---|---|
| `RemoteEvent` | 174 |
| `RemoteFunction` | 40 |
| `BindableEvent` | 11 |
| `BindableFunction` | 1 |

Full extracted list: `docs/reference/remotes.md` *(not yet generated — Phase 4)*.

### `.meta.json` facts

- 170 `.meta.json` files.
- **104 of them set `Disabled: true`.** This is load-bearing: `InitScripts.server.luau`
  re-enables disabled `BaseScript`s after templates finish importing.
- `RunContext` is set explicitly on 74 scripts: **47 `Server`, 27 `Client`**.
  Consequence (FACT): many files named `*.server.luau` under
  `Core/ReplicatedStorage/Client/` are actually **client-context `Script`s**, not server
  scripts. Filename suffix alone is not a reliable client/server discriminator in this
  repository — the sibling `.meta.json` must be consulted.
- Tags observed: `IgnoreAutoEnable` (4), `IgnoreLoader` (2), `Weight` (2),
  `TagEditorTagContainer` (1), `Configuration` (1), `InteractiveTool` (1).

### Entry points (FACT)

Only **two** server `Script`s exist outside the templates, both in
`ServerScriptService`, both tagged `IgnoreLoader`:

1. `src/ServerScriptService/ImportTemplates.server.luau`
2. `src/ServerScriptService/InitScripts.server.luau`

Plus two shared modules in `ReplicatedStorage`:

3. `src/ReplicatedStorage/PlayerInit.luau` — deferred `PlayerAdded` fan-out
4. `src/ReplicatedStorage/InitAfterTemplates.luau` — blocking "templates ready" barrier

And one client-context script: `src/ReplicatedStorage/Client/visualsManager.server.luau`
(`RunContext: Client`, `Disabled: true`).

### Template system (FACT)

`ImportTemplates.server.luau` loads three Roblox assets by ID with
`InsertService:LoadAsset` and merges their contents into live services:

| Asset ID | Template | Local override folder |
|---|---|---|
| `137484964666215` | `Core` (comment: "siempre el primero") | `ServerStorage/TemplatesTesting/Core` |
| `92258948630058` | `GameWorlds` | `ServerStorage/TemplatesTesting/GameWorlds` |
| `94091855508048` | `BuildingSystem` | `ServerStorage/TemplatesTesting/BuildingSystem` |

`ServerStorage/TemplatesTesting/PlayerHouses` exists on disk but is **not** in
`TEMPLATES_IDS`. **UNKNOWN** — see *Unknowns* below.

### Roblox service usage (files touching each API)

| API | Files |
|---|---|
| `MessagingService` | 9 |
| `MemoryStoreService` | 6 |
| `BindToClose` | 8 |
| `TeleportService` | 4 |
| `ReserveServer` | 4 |
| `DataStoreService` | 4 |
| `TeleportAsync` | 3 |
| `ReservedServerAccessCode` | 3 |
| `GetJoinData` | 5 |
| `PrivateServerId` | 1 |

---

## Architecture

| Page | File | Status |
|---|---|---|
| Overview | `docs/architecture/overview.md` | Documented |
| Initialization | `docs/architecture/initialization.md` | Documented (2 diagrams) |
| Server Lifecycle | `docs/architecture/server-lifecycle.md` | Documented (3 diagrams) |
| Player Lifecycle | `docs/architecture/player-lifecycle.md` | Documented (3 diagrams) |
| Character Lifecycle | `docs/architecture/character-lifecycle.md` | Documented (2 diagrams) |
| Client Lifecycle | `docs/architecture/client-lifecycle.md` | Documented (1 diagram) — **incomplete by construction**, see U-001 |
| Networking | `docs/architecture/networking.md` | Documented — scope-limited, ~200 gameplay remotes unreviewed |
| Persistence | `docs/architecture/persistence.md` | Documented (2 diagrams) |
| Reserved Servers | `docs/architecture/reserved-servers.md` | Documented (3 diagrams) |
| Data Flow | — | **Not written.** Folded into Persistence and Networking; a separate page is only worth adding if Phase 3 shows flows those two do not cover. |
| Dependencies | — | **Not written.** Deferred to Phase 5, where it can be built from real evidence across systems rather than from the bootstrap alone. |

Diagram count so far: **16 Mermaid diagrams** across the architecture layer.

---

## Systems

Preliminary system list, derived from real directory/namespace boundaries in the
repository. Not yet validated — Phase 3 confirms or merges these.

| System | Primary location | Status |
|---|---|---|
| Bootstrap / Template Loading | `src/ServerScriptService`, `src/ReplicatedStorage` | **Documented** (architecture layer) |
| World & Housing (`WorldSystem`) | `Core/ServerStorage/WorldSystem`, `Core/…/WorldManager.server.luau`, `PlayerHouses/*`, `GameWorlds/*` | **Documented** — 7 pages, 14 diagrams, 8 bug candidates. Not `Verified`: that needs Studio. |
| Persistence (`DataKit`) | `Core/ServerStorage/DataKit` | **Documented** (architecture layer); `Store.transfer` and `Inbox` still unread |
| Player Data | `Core/ServerStorage/WorldSystem/PlayerData*`, `Core/…/PlayerDataInit.server.luau`, `Core/ServerScriptService/Data` | Pending |
| Referrals | `Core/ServerStorage/WorldSystem/ReferralService.luau`, `Core/…/Referrals`, `Shared/Referrals` | Pending |
| Events (in-game scheduled events) | `Core/ServerStorage/WorldSystem/EventService.luau`, `EventBootstrap`, `EventCommands` | Pending |
| Inventory / Tools | `Core/…/ServerScripts/inventory`, `ToolsServer`, `ToolPlacementServer`, `Client/inventory` | Pending |
| Interactables | `Core/…/ServerScripts/interactable`, `Client/interactable` | Pending |
| Arcade Machines | `Core/…/ServerScripts/machines`, `Shared/machines`, `Shared/pong` | Pending |
| Karaoke | `Shared/Karaoke`, `ServerStorage/BusquedaMusicas.luau` | Pending |
| Paint | `Shared/Paint`, `interactable/Paint`, `ServerStorage/Paint` | Pending |
| Shops / Stores / Economy | `ShopServerSystem`, `Shared/Stores`, `Shared/ComprasTablero`, `ShopInfo` | Pending |
| Monetization | `Shared/Monetization`, `Events/Monetization`, `WorldSystem/GamePassService` | Pending |
| Quests | `ServerScripts/Quests`, `Shared/Quests`, `Client/QuestClient` | Pending |
| Animation | `ServerScripts/AnimationSystem`, `Client/Animator`, `Client/animation` | Pending |
| Ragdoll | `ServerScripts/Ragdoll`, `Client/Ragdoll` | Pending |
| Jobs | `Shared/JobSystem`, `Events/Jobs` | Pending |
| Nametags / Mic | `NametagServer`, `Shared/Nametag`, `MicManagerServer`, `NametagMicClient` | Pending |
| Building System | `BuildingSystem/ReplicatedStorage/BuildInterface` | Pending |
| Cooking / Food | `ServerScripts/cooking`, `Shared/cooking`, `Client/cooking` | Pending |
| UI framework (`Icon`, `Kinetic`) | `Shared/Icon`, `Kinetic` | Pending (likely vendored third-party) |
| Vendored libraries | `Shared/Promise`, `Shared/Signal`, `Shared/Trove`, `Shared/Sift`, `Shared/FastCastRedux`, `Shared/Observers`, `Shared/PartCache` | Pending (mark as third-party, document boundary only) |

No system has reached `Verified`. Verification requires running the plans in
`docs/testing/verification-plan.md`, which needs Roblox Studio.

### Housing — detail

**Status:** Documented (not Verified — verification requires Roblox Studio)

Pages: `docs/systems/housing/` — `overview.md`, `identity.md`, `persistence.md`,
`entry-flow.md`, `server-lifecycle.md`, `permissions.md`, `error-handling.md`.

Conceptual documentation:

- [x] Overview, responsibilities, components, architecture
- [x] House identity, creation, ownership, purchase (houses **and** slots)
- [x] House persistent lifecycle
- [x] Reserved-server lifecycle, including reserved-but-never-joined and last-player
- [x] Networking (`JoinServer` / `JoinWorld` / the administrative remotes)
- [x] Persistence (`Profiles.World`, `onConflict = "deny"`, the card projection,
      the four storage locations)
- [x] Permissions — all four checks, roles, bans, guests, private/public
- [x] Concurrency
- [x] Cleanup / shutdown ordering
- [x] Error handling — full failure matrix

Diagrams (14 across the housing and reserved-server pages):

- [x] Housing architecture
- [x] House persistent lifecycle (state)
- [x] Reserved-server lifecycle (state)
- [x] Server reservation sequence
- [x] Reserved-server startup sequence (inside the entry-flow sequence)
- [x] Player entry flow
- [x] Guest entry (documented in prose — it is the same path, with a different
      `canHostWorld` outcome; a separate diagram would duplicate the entry sequence)
- [x] Shutdown flow
- [x] Concurrency / reservation decision flow
- [x] House browser assembly flow
- [x] House purchase sequence
- [x] `canHostWorld` decision flow
- [x] `canPlayerEnter` decision flow, with its triggers
- [ ] A dedicated registry/lease diagram — **deliberately not added**: the two
      registries are already covered by a comparison table plus the reservation
      sequence, and a third view would restate them.

Scripts:

- `WorldManager.server.luau` — Analyzed
- `ServerPresence.luau` — **Documented** (Moonwave)
- `Profiles.luau` — Analyzed
- `PlayerSchema.luau` — Analyzed
- `PlayerWorld_Init.lua.server.luau` — Analyzed
- `WorldService.luau` — Analyzed
- `WorldDataReplicator.server.luau` — Analyzed
- `ModeratorManager.server.luau` — Analyzed
- `PublicServerInit.lua.server.luau` — Analyzed
- `ServerDirectory.server.luau` — Analyzed
- `WorldsBrowser.server.luau` — Analyzed
- `PlayerDataReplicator.server.luau` — Analyzed
- `ShopServerSystem.server.luau` — Analyzed (partly: `ProcessPurchase` only)
- `HousesInfo.luau`, `RolesInfo.luau`, `GeneralConfiguration.luau` — Analyzed
- `GamePassService/*` — Pending
- `EventService.luau` — Pending (events share the reservation machinery)

Unknowns still open: **U-002** (how `PlayerHouses` is imported), **U-007**
(nothing enforces `slots` as a cap on open houses), and the `content` section of
the `World` profile, which is declared and never written by any script read so far —
`BuildingSystem` is the likely writer.

Possible bugs: BUG-CANDIDATE-004, 005, 006, 008, 009, 010, 011, 012, 013, 014.

---

## Scripts

**Per-file status now lives in `docs/reference/script-inventory.md`**, which is generated
by `.github/scripts/generate-script-inventory.py` and lists all 552 files with their
runtime DataModel path, `RunContext`, `Disabled` flag, line count and status.

Summary as of this run:

| Status | Count |
|---|---|
| **Documented** (read in full + Moonwave-annotated by this project) | 2 |
| Analyzed (read in full, described on the site) | 27 |
| Analyzed (partly) | 3 |
| Pending | 520 |

The 3 partial reads and why:

| File | What was read | What was not |
|---|---|---|
| `DataKit/Store.luau` (1 237 lines) | Ownership resolution, staging, save/close, heartbeat | `transfer`, the message pipeline, projections |
| `DataKit/BaseStore.luau` (330) | The durable envelope format (`__dkFence` / `__dkData` / `__dkMsgs`) | Commit, fencing, inbox mechanics |
| `ShopServerSystem.server.luau` (?) | `ProcessPurchase` | Shop rotation, `MessagingService` sync, `MemoryStore` use |

**Already Moonwave-annotated in-source before this project** — they appear in the API
reference for free, and are third-party or vendored: `DataKit`, `Store`, `Profile`,
`Lease`, `Mutex`, `Health`, `BaseStore`, `Signal`, `Inbox`, `Adapters`, `Promise`, `Sift`,
`Trove`, `Observers`, `Kinetic`, `Icon`.

---

## Binary Assets

**320 `.rbxm` files — Binary / Not Inspectable.** Full enumeration, grouped by directory
with runtime paths, is in `docs/reference/binary-assets.md` (generated by
`.github/scripts/generate-reference.py`).

The five that actually block documentation:

| Path | Blocks |
|---|---|
| `src/StarterPlayer/StarterPlayerScripts.rbxm` | The client loader and the `LoadCharacterRequest` sender → BUG-CANDIDATE-007 |
| `src/StarterPlayer/StarterCharacterScripts.rbxm` | The full character lifecycle |
| `src/ReplicatedFirst/LoadingScreenUI.rbxm` | The first thing a client sees |
| `src/StarterGui/ScreenGui.rbxm`, `BuildMenu.rbxm` | Root UI |
| `…/PlayerHouses/StarterGui/PermsGui.rbxm` | The client half of housing permissions |

---

## Unknowns

| # | Unknown | Why it cannot be resolved statically |
|---|---|---|
| U-001 | Contents of `StarterPlayerScripts.rbxm` / `StarterCharacterScripts.rbxm` | Binary. The real client entry point may live here, and it cannot be read. Client-lifecycle documentation will be explicitly incomplete until these are inspected in Studio. |
| U-002 | Which template asset ID ships `PlayerHouses` | `PlayerHouses` exists under `TemplatesTesting` (the override folder) but is absent from `TEMPLATES_IDS` in `ImportTemplates.server.luau`. It is plausible that the house `PlaceId`s (`126499097860226`, `80492586639096`) run a *different* Rojo project/place whose own `ImportTemplates` includes it — **not verifiable from this repository**. |
| U-003 | Whether the three template asset IDs' published contents match `TemplatesTesting/` on disk | The disk copies are only used as *overrides*; the authoritative content is the published Roblox asset. |
| U-004 | `src/StarterPack` declared in `default.project.json` but missing on disk | Cannot tell whether Rojo tolerates this or whether a file is missing from the commit. |
| U-005 | Actual runtime ordering between `ImportTemplates` and `InitScripts` | Both are top-level `Script`s in `ServerScriptService`; Roblox does not guarantee an order between sibling scripts. `InitScripts` blocks on `InitAfterTemplates`, which suggests intent, but the exact interleaving is a runtime property. **Partly resolved:** the barrier makes the order irrelevant for the templates-ready dependency. What remains open is ordering *between* template scripts as the enable sweep walks `GetDescendants()`. |
| U-006 | Which script enables the 27 client-context scripts | No `.luau` here assigns `Enabled = true`. Promoted to a formal entry: **BUG-CANDIDATE-007**, with a two-minute Studio plan. |
| U-007 | How a house is purchased and recorded on the player profile | `BuySlot` and `HouseBuyLoad` remotes exist and `PlayerWorld_Init.hasRoom` reads `data.rooms`, but the writer of `rooms` has not been located yet. Phase 3. |
| U-008 | Whether `GlobalDataStore` and `GiftInbox` duplicate `DataKit`'s guarantees | Both call `DataStoreService` directly, outside `DataKit`. Neither has been read. |

---

## Problems Found

Fourteen entries, all written up in full in `docs/testing/verification-plan.md`.
**None is asserted as a confirmed bug.** Two are classified *Confirmed by Static
Analysis*, and even those state only what the code demonstrably does — 011 confirms an
inconsistency, not which side of it is wrong; 014 confirms an exposure, not its impact.

**BUG-CANDIDATE-014 is the one to act on first.** It is a committed credential, and
unlike the others its remediation does not wait on a test result. It is out of scope for
this documentation project, which changes no code, but it should not sit in a backlog.

| ID | Title | System | Classification | Severity if confirmed | Confidence |
|---|---|---|---|---|---|
| BUG-CANDIDATE-001 | Voice-chat gate fails open when the Roblox check errors | Bootstrap | Observation / Requires Failure Injection | Low | High |
| BUG-CANDIDATE-002 | Presence entry can outlive its server by up to the TTL | World System | Possible Bug / Requires Lifecycle Testing | Medium | Medium |
| BUG-CANDIDATE-003 | A failed respawn leaves the player with no character | Character | Possible Bug / Requires Failure Injection | Medium | Medium |
| BUG-CANDIDATE-004 | Convergence after a denied host may strand players | Housing | Possible Bug / Requires Multiplayer Testing | High | Low |
| BUG-CANDIDATE-005 | Teleport with an access code whose instance has shut down | Housing | Requires Teleport Testing | Medium | Low |
| BUG-CANDIDATE-006 | A Studio session can publish a fake access code to the live registry | Housing | Likely Bug / Requires Integration Testing | High | Medium |
| BUG-CANDIDATE-007 | The client script loader is not in this repository | Client | Observation / Requires Runtime Verification | — | High |
| BUG-CANDIDATE-008 | A purchase grants the item before it charges for it | Housing / Economy | Possible Bug / Requires Failure Injection | Medium | Medium |
| BUG-CANDIDATE-009 | A first-boot name lookup failure names the house permanently | Housing | Possible Bug / Requires Failure Injection | Low | High |
| BUG-CANDIDATE-010 | `WorldDataReplicator` misses an already-`ready` server | Housing | Likely Bug / Requires Lifecycle Testing | Medium | Medium |
| BUG-CANDIDATE-011 | The `moderator` role cannot moderate | Housing | Likely Bug / Confirmed by Static Analysis | Medium | High |
| BUG-CANDIDATE-012 | House roles, settings and bans readable by any occupant | Housing | Observation / Requires Security Testing | Low | High |
| BUG-CANDIDATE-013 | A house server with no `TeleportData` strands its player silently | Housing | Possible Bug / Requires Runtime Verification | Medium | Medium |
| BUG-CANDIDATE-014 | A shared secret and proxy host hardcoded in a committed file | Housing / Security | Confirmed by Static Analysis | High | High |

### Leads investigated and closed during Phases 1–2

Recorded so a future run does not re-open them:

| Lead | Outcome |
|---|---|
| T-a — "housing reservation may lack a cross-server guard" | **Closed — not a defect.** `Profiles.World.claimStaged` claims a `staged/World/{key}` MemoryStore key through `Lease.tryClaim`, a single atomic `UpdateAsync` compare-and-set. The residual non-atomic window is explicitly documented in `Store.luau` and absorbed by `onConflict = "deny"` plus `convergeToOwner`. Only the *mitigation's* behaviour under load remains open → BUG-CANDIDATE-004. |
| T-b — "MemoryStore registry may go stale" | **Kept, narrowed** → BUG-CANDIDATE-002. Bounded by the 120 s TTL by design. |
| T-c — "Studio fake access code" | **Kept, sharpened** → BUG-CANDIDATE-006. The reserve and teleport calls *are* Studio-guarded; the MemoryStore write between them is not. |
| T-d — "`ImportTemplates` destroys `TemplatesTesting`; something may still need it" | **Closed — not a defect.** `grep` shows `TemplatesTesting` is referenced only inside `ImportTemplates.server.luau` itself. |
| T-e — "voice-chat gate intent vs behaviour" | **Kept** → BUG-CANDIDATE-001, classified as an Observation because the source comments on the open decision itself. |

### Observations recorded, not defects

| Observation | Where |
|---|---|
| `folderTest:Destroy()` followed by `Debris:AddItem(folderTest)` is redundant | `ImportTemplates.server.luau` |
| The `IgnoreLoader` tag has no consumer in this repository | Both bootstrap scripts |
| 3 of the 4 `IgnoreAutoEnable`-tagged scripts are under `ReplicatedStorage/Client`, which the server sweep already skips wholesale — evidence for the client loader theory | supports BUG-CANDIDATE-007 |
| `GetSlots` is declared in both the `Core` and `PlayerHouses` event folders, same class, one binder, one consumer | `docs/architecture/networking.md` |
| `default.project.json` maps `StarterPack`, which does not exist on disk | root |

## Verification & Test Plan

`docs/testing/verification-plan.md` — **created**, 7 entries, each with pass/fail
conditions and suggested instrumentation. Every entry is `Unverified`.

Roblox Studio is **not available in this environment**, so no plan has been executed.
Each is written to be run by hand.

**Recommended execution order** (cheapest and most informative first):

1. BUG-CANDIDATE-007 — ~2 minutes in Studio, and it unblocks the whole client-lifecycle
   chapter.
2. BUG-CANDIDATE-006 — starts with a configuration question ("is Studio API access on for
   this universe?") that may close it outright.
3. BUG-CANDIDATE-002 — single-player, observable from a MemoryStore reader.
4. BUG-CANDIDATE-003 — single-player with one injected failure.
5. BUG-CANDIDATE-005 — needs a forced crash and tight timing.
6. BUG-CANDIDATE-004 — needs two accounts on two servers, 20+ runs.
7. BUG-CANDIDATE-001 — a product decision more than a test.

Housing entries, in the same spirit — cheapest first:

8. BUG-CANDIDATE-014 — no test needed; check whether the repository is private and
   whether the secret has been rotated. **Do this first regardless of order.**
9. BUG-CANDIDATE-011 — two accounts, five minutes, and it needs no failure injection.
10. BUG-CANDIDATE-012 — one account, invoke four remotes from the client console.
11. BUG-CANDIDATE-009 — one stubbed call, one fresh house.
12. BUG-CANDIDATE-010 — add two log lines, open a house 20 times.
13. BUG-CANDIDATE-008 — read `Collections` first; that may shrink or close it.
14. BUG-CANDIDATE-013 — starts with "is this even reachable?", which may close it.

---

## Last Completed Work

- **Phase:** 3 — Systems. Housing complete. Phases 0, 1 and 2 complete.
- **Systems touched:** Bootstrap / Template Loading; World & Housing; Persistence
  (`DataKit`); Player Data (partly, via the housing path)
- **Files created this run:**
  - `DOCS_PROGRESS.md`, `moonwave.toml`, `.github/workflows/docs.yml`
  - `.github/scripts/` — `enable-mermaid.py`, `check-luau-code-unchanged.py`,
    `check-docs-links.py`, `generate-reference.py`, `generate-script-inventory.py`
  - `docs/intro.md`
  - `docs/architecture/` — 9 files (`_category_.json` + 8 pages)
  - `docs/systems/` — `_category_.json`, `housing/_category_.json` + 7 pages
  - `docs/testing/` — `_category_.json`, `verification-plan.md`
  - `docs/reference/` — `_category_.json` + 3 generated pages
- **Files annotated (comments only, proven by the CI guard):**
  - `src/ReplicatedStorage/PlayerInit.luau`
  - `…/Core/ServerStorage/WorldSystem/ServerPresence.luau`
- **Diagrams:** 30 Mermaid diagrams (flowchart, sequence, state)
- **Bug candidates:** 14 written up in full; 2 Phase-0 leads closed as not-defects
- **Scripts read:** 32 of 552
- **Last commit:** `docs: add generated reference inventories`

### Answers to the brief's headline questions

Recorded here so a future run does not re-derive them:

| Question | Answer | Where |
|---|---|---|
| What starts first on a server? | Two sibling `Script`s with **no guaranteed order**; a `BoolValue` barrier makes the order irrelevant | `docs/architecture/initialization.md` |
| How is a player initialised? | No central bootstrap — systems register with `PlayerInit` and start concurrently and unordered | `docs/architecture/player-lifecycle.md` |
| How is the client initialised? | **Cannot be answered from this repository.** Nothing here enables the 27 client scripts | `docs/architecture/client-lifecycle.md`, BUG-CANDIDATE-007 |
| Can two players reserve the same house at once? | **No — it is guarded**, by an atomic MemoryStore compare-and-set, plus deny-and-converge for the residual window | `docs/architecture/reserved-servers.md` |
| How is a stale server reference detected? | It is not — it is **prevented**. Nothing durable points at a server; reachability *is* a lease and liveness *is* its TTL | `docs/systems/housing/server-lifecycle.md` |
| What happens when the last player leaves? | Nothing housing-specific. No handler exists, and none is needed | `docs/systems/housing/server-lifecycle.md` |
| How is a house reopened? | There is no reopen path. A closed house is one with no lease | `docs/systems/housing/server-lifecycle.md` |

### Tooling notes for the next run

- **Moonwave cannot be built locally in this environment.** The CLI installs from npm, but
  `moonwave build` fetches its extractor binary from `latest-github-release.eryn.io` /
  `github.com`, both outside the network allowlist (HTTP 403). The build is validated on
  GitHub Actions runners instead. **Run these two before every commit** — they are the
  local stand-in, and both are wired into CI:
  - `python3 .github/scripts/check-docs-links.py`
  - `python3 .github/scripts/check-luau-code-unchanged.py main`
- **Regenerate the reference pages** after reading new files, and update the `ANALYSED` /
  `PARTIAL` / `DOCUMENTED` sets at the top of `generate-script-inventory.py`:
  - `python3 .github/scripts/generate-reference.py`
  - `python3 .github/scripts/generate-script-inventory.py`
- **Mermaid** is not in Moonwave 1.4.2's Docusaurus template. The workflow builds twice: a
  warm-up populates Moonwave's cached project, the theme is installed into it with
  `--no-save --no-package-lock` so the cache survives, then the real build runs. A failed
  install warns rather than failing.
- **`git push` is blocked, and this has not changed.** Every attempt returns HTTP 403:
  *"Claude doesn't have GitHub access to Arclyne/voz-hispana for your organization."*
  All work is committed locally on `docs/moonwave-documentation`. **Nothing reaches GitHub,
  and GitHub Pages cannot build, until an org admin installs the Claude GitHub App for this
  repository** (https://github.com/apps/claude/installations/select_target). The
  documentation workflow is otherwise ready and will run on the first successful push.

---

## Next Recommended Work

Housing is done. **Do not start Phase 4's per-script sweep yet** — the brief is explicit
that five systems understood deeply beat fifty described shallowly, and there are more
systems worth that treatment.

### 1. Player Data (recommended next — small, and everything depends on it)

Read, in this order:

- `Core/ServerStorage/WorldSystem/PlayerDataService.luau` (1.9 KB)
- `Core/ServerStorage/WorldSystem/PlayerDataReplicator.luau` (555 lines) — the
  DataStore-to-`Instance` replication whose contract `PlayerSchema` describes
- `Core/ServerScriptService/ServerScripts/PlayerDataInit.server.luau`
- `Core/ServerScriptService/Data/Main/init.server.luau` (392 lines)
- `Core/ReplicatedStorage/Client/EconomySystem/Collections.luau` — **also closes
  BUG-CANDIDATE-008**, which cannot be assessed without knowing where currency lives

Then write `docs/systems/player-data.md` and finish
`docs/architecture/persistence.md`'s open question about `GlobalDataStore` and
`GiftInbox`, which call `DataStoreService` outside `DataKit`.

### 2. Referrals

`Core/ServerStorage/WorldSystem/ReferralService.luau` is **1 243 lines**, the largest
non-vendored module in the repository. Its message-driven half is already partly described
in `docs/architecture/persistence.md` (the `onMessage` idempotence contract). Pair it with
`ServerScripts/Referrals/*` and `Shared/Referrals/*`.

### 3. Events

`Core/ServerStorage/WorldSystem/EventService.luau` — the third `ReserveServer` caller, and
the only one not yet documented. It shares all the reservation machinery already written
up, so this should be fast. Pair with `EventBootstrap.server.luau` and
`EventCommands.server.luau`.

### 4. Then the gameplay systems

Inventory / Tools, Interactables (44 remotes), Machines, Karaoke (25 remotes), Paint,
Shops, Quests, Jobs, Animation, Building. Roughly 480 files. Take one at a time, and
commit per system.

### Deferred deliberately, with reasons

| Deferred | Why |
|---|---|
| `docs/architecture/data-flow.md` | Persistence and Networking already cover the flows found. Add it only if a later system shows one they do not. |
| `docs/architecture/dependencies.md` | Phase 5. Building it now, from four systems, would produce a graph that has to be redrawn. |
| `classOrder` in `moonwave.toml` | Phase 4, once the full set of `@class` annotations exists. Naming a class that does not exist would fail the build. |
| Per-script Moonwave sweep | Phase 4. Two modules are annotated so far; ~16 more are already annotated in-source by their vendors. |

### Before finishing any future run

1. Run both check scripts.
2. Regenerate the two reference pages and update the status sets.
3. Update *Current Phase*, *Last Completed Work*, *Next Recommended Work*, *Unknowns*, and
   any new bug candidates in **both** this file and `docs/testing/verification-plan.md`.
4. Commit. Attempt a push; if it still returns 403, say so explicitly in the summary so the
   access problem stays visible rather than being quietly absorbed.
