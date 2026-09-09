# Documentation Progress

> Persistent memory for the Voz Hispana technical-documentation project.
> **Read this file completely before doing any documentation work.**
>
> Working branch: `docs/moonwave-documentation`
> Rule in force: **documentation only** — no executable Lua/Luau may change.

---

## Current Phase

**Phase 3 — Systems** (starting; Housing first)

---

## Overall Progress

**18 %**

Rationale for the number (kept deliberately conservative):
the repository holds **552 inspectable `.luau` files / ~80 500 lines** plus
**320 non-inspectable `.rbxm` binaries**. Phases 0–2 are complete: infrastructure
is in place and the whole architecture layer is written from source read end to end
(~26 files). That is roughly 5 % of the Luau by file count, but a much larger share
of the *load-bearing* code — bootstrap, world system, reservation, presence and the
persistence package. The remaining ~500 files are gameplay systems, largely
unexamined.

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
| World & Housing (`WorldSystem`) | `Core/ServerStorage/WorldSystem`, `Core/…/WorldManager.server.luau`, `PlayerHouses/*`, `GameWorlds/*` | **Documenting** — reservation path documented, house entity in progress |
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

**Status:** Documenting

Conceptual documentation:

- [x] Overview (architecture level — `docs/architecture/reserved-servers.md`)
- [ ] House identity, creation, ownership
- [x] Architecture (two registries, staging claim)
- [ ] House persistent lifecycle
- [x] Reserved-server lifecycle
- [x] Networking (`JoinServer` / `JoinWorld`)
- [x] Persistence (`Profiles.World`, `onConflict = "deny"`, card projection)
- [ ] Permissions, roles, bans, guests
- [x] Concurrency
- [x] Cleanup / shutdown
- [ ] Error handling (full matrix)

Diagrams:

- [x] Player entry / reservation sequence
- [x] Concurrency decision flow
- [ ] House persistent lifecycle (state diagram)
- [ ] Reserved-server startup sequence
- [ ] Player exit / last player
- [ ] Shutdown flow
- [ ] Persistence flow
- [ ] Registry / lease flow

Scripts:

- `WorldManager.server.luau` — Analyzed
- `ServerPresence.luau` — Documented (Moonwave)
- `Profiles.luau` — Analyzed
- `PlayerWorld_Init.lua.server.luau` — Analyzed
- `WorldService.luau` — Analyzed
- `PublicServerInit.lua.server.luau` — Analyzed
- `HousesInfo.luau`, `RolesInfo.luau` — Analyzed
- `WorldDataReplicator.server.luau` — Pending
- `ModeratorManager.server.luau` — Pending
- `EventService.luau` — Pending
- `ServerDirectory.server.luau` — Pending
- `WorldsBrowser.server.luau` — Pending
- `GamePassService/*` — Pending

Unknowns: U-002 (how `PlayerHouses` is imported), and how a house is *purchased*
(`BuySlot`, `HouseBuyLoad`, `rooms` on the player profile) — not yet read.

Possible bugs: BUG-CANDIDATE-004, 005, 006.

---

## Scripts

Per-script status tracking begins in Phase 4. As of now:

- **552** `.luau` files — **26 Analyzed or Documented**, the rest `Pending`
- **Read end-to-end so far (status `Analyzed`):**
  - `src/ServerScriptService/ImportTemplates.server.luau`
  - `src/ServerScriptService/InitScripts.server.luau`
  - `src/ReplicatedStorage/InitAfterTemplates.luau`
  - `src/ReplicatedStorage/PlayerInit.luau`
  - `src/ReplicatedStorage/Client/visualsManager.server.luau`
  - `…/Core/ServerScriptService/ServerScripts/WorldManager.server.luau`
  - `…/Core/ServerStorage/WorldSystem/ServerPresence.luau`
  - `…/Core/ServerStorage/WorldSystem/Profiles.luau`
  - `…/PlayerHouses/ServerScriptService/PlayerWorld_Init.lua.server.luau`
  - `…/PlayerHouses/ServerScriptService/WorldService.luau`
  - `…/Core/ReplicatedStorage/HousesInfo.luau`
  - `…/PlayerHouses/ReplicatedStorage/RolesInfo.luau`
  - `…/GameWorlds/ServerScriptService/ServerScripts/PublicServerInit.lua.server.luau`
  - `…/Core/ServerScriptService/ServerScripts/playerManager.server.luau`
  - `…/Core/ReplicatedStorage/Client/PlayerManager.server.luau`
  - `…/Core/ReplicatedStorage/Client/MainPS.server.luau`
  - `…/Core/StarterGui/LocalScript.client.luau`
  - `…/Core/ServerStorage/DataKit/init.luau`
  - `…/Core/ServerStorage/DataKit/Profile.luau`
  - `…/Core/ServerStorage/DataKit/Lease.luau`
  - `…/Core/ServerStorage/DataKit/Mutex.luau`
  - `…/Core/ServerStorage/DataKit/Health.luau`
  - `…/Core/ServerStorage/DataKit/Store.luau` — **partly**: ownership, staging,
    save/close read; `transfer`, `Inbox` and the message pipeline not yet
  - `…/Core/ServerStorage/DataKit/BaseStore.luau` — **partly**: the envelope format only

- **Moonwave-annotated by this project (status `Documented`):**
  - `src/ReplicatedStorage/PlayerInit.luau` — `@class PlayerInit`
  - `…/Core/ServerStorage/WorldSystem/ServerPresence.luau` — `@class ServerPresence`

- **Already Moonwave-annotated in-source before this project** (vendored packages;
  they appear in the API reference for free): `DataKit`, `Store`, `Profile`, `Lease`,
  `Mutex`, `Health`, `BaseStore`, `Signal`, `Inbox`, `Adapters`, plus the third-party
  `Promise`, `Sift`, `Trove`, `Observers`, `Kinetic`.

---

## Binary Assets

**320 `.rbxm` files — Binary / Not Inspectable.**

Their contents cannot be read from this repository and **must not be guessed**.
Notable ones referenced by the bootstrap or by UI flows:

| Path | Context |
|---|---|
| `src/ReplicatedFirst/LoadingScreenUI.rbxm` | Loading screen, replicated first |
| `src/StarterPlayer/StarterPlayerScripts.rbxm` | Client entry-point container — **contents unknown** |
| `src/StarterPlayer/StarterCharacterScripts.rbxm` | Character scripts — **contents unknown** |
| `src/StarterGui/ScreenGui.rbxm`, `src/StarterGui/BuildMenu.rbxm` | Root UI |
| `src/ServerStorage/RBX_ANIMSAVES.rbxm` | Animation editor saves |
| `…/Core/StarterGui/*.rbxm` (16 files) | Core template UI |
| `…/PlayerHouses/StarterGui/PermsGui.rbxm` | Housing permissions UI |
| `…/Core/MaterialService/*.rbxm` | Materials |
| `…/Core/ReplicatedStorage/Assets/**` | Tools, furniture, models |

A full enumerated table goes into `docs/reference/binary-assets.md` in Phase 4.

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

Seven entries, all written up in full in `docs/testing/verification-plan.md`.
**None is asserted as a confirmed bug.**

| ID | Title | System | Classification | Severity if confirmed | Confidence |
|---|---|---|---|---|---|
| BUG-CANDIDATE-001 | Voice-chat gate fails open when the Roblox check errors | Bootstrap | Observation / Requires Failure Injection | Low | High |
| BUG-CANDIDATE-002 | Presence entry can outlive its server by up to the TTL | World System | Possible Bug / Requires Lifecycle Testing | Medium | Medium |
| BUG-CANDIDATE-003 | A failed respawn leaves the player with no character | Character | Possible Bug / Requires Failure Injection | Medium | Medium |
| BUG-CANDIDATE-004 | Convergence after a denied host may strand players | Housing | Possible Bug / Requires Multiplayer Testing | High | Low |
| BUG-CANDIDATE-005 | Teleport with an access code whose instance has shut down | Housing | Requires Teleport Testing | Medium | Low |
| BUG-CANDIDATE-006 | A Studio session can publish a fake access code to the live registry | Housing | Likely Bug / Requires Integration Testing | High | Medium |
| BUG-CANDIDATE-007 | The client script loader is not in this repository | Client | Observation / Requires Runtime Verification | — | High |

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

---

## Last Completed Work

- **Phase:** 2 — Architecture (complete). Phases 0 and 1 also complete.
- **Systems touched:** Bootstrap / Template Loading; World & Housing (reservation path);
  Persistence (`DataKit`)
- **Files created:**
  - `DOCS_PROGRESS.md`
  - `moonwave.toml`
  - `.github/workflows/docs.yml`
  - `.github/scripts/enable-mermaid.py`
  - `.github/scripts/check-luau-code-unchanged.py`
  - `.github/scripts/check-docs-links.py`
  - `docs/intro.md`
  - `docs/architecture/` — `_category_.json`, `overview.md`, `initialization.md`,
    `server-lifecycle.md`, `player-lifecycle.md`, `character-lifecycle.md`,
    `client-lifecycle.md`, `networking.md`, `persistence.md`, `reserved-servers.md`
  - `docs/testing/` — `_category_.json`, `verification-plan.md`
- **Files annotated (comments only, verified by the CI guard):**
  - `src/ReplicatedStorage/PlayerInit.luau`
  - `…/Core/ServerStorage/WorldSystem/ServerPresence.luau`
- **Diagrams:** 16 Mermaid diagrams (flowchart, sequence, state)
- **Bug candidates:** 7 written up; 2 leads closed as not-defects
- **Last commit:** `docs: add verification plan with seven bug candidates`

### Tooling notes for the next run

- **Moonwave cannot be built locally in this environment.** The CLI installs from npm,
  but `moonwave build` fetches its extractor binary from
  `latest-github-release.eryn.io` / `github.com`, both outside the network allowlist
  (HTTP 403). The build is validated on GitHub Actions runners instead.
  Compensating local checks, both wired into CI and both worth running before every
  commit:
  - `python3 .github/scripts/check-docs-links.py` — relative links, heading anchors,
    and `/api/<Class>` targets against the real `@class` annotations
  - `python3 .github/scripts/check-luau-code-unchanged.py main` — proves only comments
    changed
- **Mermaid** is not part of Moonwave 1.4.2's Docusaurus template. The workflow builds
  twice: a warm-up build populates Moonwave's cached project, the theme is installed
  into it with `--no-save --no-package-lock` so the cache is not wiped, and only then is
  it switched on. Failure to install is a warning, not an error.
- **`git push` is currently blocked.** `git push -u origin docs/moonwave-documentation`
  returns HTTP 403: *"Claude doesn't have GitHub access to Arclyne/voz-hispana for your
  organization."* All work is committed locally on `docs/moonwave-documentation`.
  An org admin must install the Claude GitHub App for the repository before any of this
  reaches GitHub — and GitHub Pages cannot build until it does.

---

## Next Recommended Work

**Phase 3 — Systems, starting with Housing.** It is the system the brief asks to be
covered most deeply, and it is the one already half-analysed.

Do this next, in order:

1. **Read the housing scripts not yet read**, in this order — they answer the questions
   the current documentation cannot:
   - `PlayerHouses/ServerScriptService/WorldDataReplicator.server.luau` — how house
     settings, roles and bans reach the client, and how they are written back
   - `PlayerHouses/ServerScriptService/ModeratorManager.server.luau` — moderation
   - `Core/…/ServerScripts/PlayerDataReplicator.server.luau` and
     `Core/ServerStorage/WorldSystem/PlayerDataReplicator.luau` — `GetSlots`, and where
     `data.rooms` is written (answers **U-007**: how a house is bought)
   - `Core/…/ServerScripts/WorldsBrowser.server.luau` and `ServerDirectory.server.luau` —
     how the house/server list is built and how it uses the presence registry
   - `Core/ServerStorage/WorldSystem/GamePassService/*`
2. **Write `docs/systems/housing/`** as several pages, not one:
   `overview.md`, `identity.md` (HouseId, ownership, `HousesInfo`, purchase),
   `persistence.md`, `reserved-server-lifecycle.md`, `entry-flow.md`,
   `permissions.md` (roles, bans, guests, `canHostWorld`), `error-handling.md`.
   Each with the Section-11 headings that actually apply — **do not emit empty
   headings** to satisfy the template.
3. **Add the housing diagrams still missing** (listed under *Systems → Housing* above).
4. **Cross-link** `docs/architecture/reserved-servers.md` into the new housing pages, and
   convert the two remaining plain-text `**Systems → Housing**` references in
   `docs/architecture/initialization.md` and `docs/intro.md` into real links.
5. **Update this file, then commit.** Suggested commits:
   `docs: document housing identity and persistence`,
   `docs: document housing reserved-server lifecycle`,
   `docs: document housing permissions and error handling`,
   `docs: update documentation progress`.

After Housing, the next most valuable systems are **Player Data** (it underpins
everything else and is small) and **Referrals** (`ReferralService.luau` is 1 243 lines,
the single largest non-vendored module in the repository).

**Do not** start Phase 4's per-script sweep before Housing is finished — the brief is
explicit that five systems understood deeply beat fifty described shallowly.

### Before finishing any future run

1. Run both check scripts above.
2. Update *Current Phase*, *Last Completed Work*, *Next Recommended Work*, *Unknowns*,
   and any new bug candidates.
3. Commit. Attempt a push; if it still fails with 403, say so explicitly in the summary
   so the access problem stays visible.
