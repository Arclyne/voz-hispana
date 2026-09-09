# Documentation Progress

> Persistent memory for the Voz Hispana technical-documentation project.
> **Read this file completely before doing any documentation work.**
>
> Working branch: `docs/moonwave-documentation`
> Rule in force: **documentation only** — no executable Lua/Luau may change.

---

## Current Phase

**Phase 0 — Initial Analysis** (in progress → closing)

---

## Overall Progress

**4 %**

Rationale for the number (kept deliberately conservative):
the repository holds **552 inspectable `.luau` files / ~80 500 lines** plus
**320 non-inspectable `.rbxm` binaries**. So far only the bootstrap chain, the
world/housing reservation path and the presence layer have been read end-to-end.
Everything else is inventoried but not yet analysed.

---

## Phases

- [ ] Phase 0 — Initial Analysis
- [ ] Phase 1 — Documentation Infrastructure
- [ ] Phase 2 — Architecture
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

| Page | Status |
|---|---|
| Overview | Pending |
| Server Lifecycle | Pending (bootstrap chain read, not written up) |
| Player Lifecycle | Pending |
| Character Lifecycle | Pending |
| Client Lifecycle | Pending |
| Initialization | Pending |
| Networking | Pending |
| Data Flow | Pending |
| Persistence | Pending |
| Dependencies | Pending |
| Reserved Servers | Pending (reservation path read, not written up) |

---

## Systems

Preliminary system list, derived from real directory/namespace boundaries in the
repository. Not yet validated — Phase 3 confirms or merges these.

| System | Primary location | Status |
|---|---|---|
| Bootstrap / Template Loading | `src/ServerScriptService`, `src/ReplicatedStorage` | Analyzing |
| World & Housing (`WorldSystem`) | `Core/ServerStorage/WorldSystem`, `Core/…/WorldManager.server.luau`, `PlayerHouses/*`, `GameWorlds/*` | Analyzing |
| Persistence (`DataKit`) | `Core/ServerStorage/DataKit` | Pending |
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

No system has reached `Documented` or `Verified` yet.

---

## Scripts

Per-script status tracking begins in Phase 4. As of now:

- **552** `.luau` files — status `Pending`
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
| U-005 | Actual runtime ordering between `ImportTemplates` and `InitScripts` | Both are top-level `Script`s in `ServerScriptService`; Roblox does not guarantee an order between sibling scripts. `InitScripts` blocks on `InitAfterTemplates`, which suggests intent, but the exact interleaving is a runtime property. |

---

## Problems Found

No `BUG-CANDIDATE-XXX` entries have been *written up* yet. Suspicions recorded during
Phase 0 that must be turned into properly evidenced candidates (or dismissed) in
Phase 3:

| Tentative | Area | One-line reason to investigate |
|---|---|---|
| T-a | Housing reservation | `WorldManager.hostWorld` guards concurrent reservation with a **per-server-instance** table (`localStages`) plus `Profiles.World.claimStaged`. Whether the cross-server guard is atomic depends on `DataKit`, which has not been read yet. |
| T-b | Housing registry | `ServerPresence` writes a MemoryStore hash-map entry with `ACTIVE_TTL = 120`, refreshed every 30 s, removed in `Cleanup()`. `Cleanup()` is only reached via `BindToClose` / `onDenied`. Staleness window and abrupt-shutdown behaviour need analysis. |
| T-c | Housing reservation | `reserveAccessCode` returns a `HttpService:GenerateGUID` in Studio; the resulting fake code is still written into the shared profile meta. Effect on live data is unclear. |
| T-d | Bootstrap | `ImportTemplates` destroys `ServerStorage.TemplatesTesting` after import; any script that later expects that folder would fail. Needs a consumer search. |
| T-e | Voice-chat gate | `onPlayerAdded` kicks players without voice chat, but on a *failed* `IsVoiceEnabledForUserIdAsync` it only `warn`s (the comment says a kick "maybe" should happen too). Intent vs behaviour mismatch — needs classification, not a fix. |

**These are not bug candidates yet.** They are leads. Each one must reach the
Section 39 format with real evidence before it gets a `BUG-CANDIDATE-` id.

---

## Verification & Test Plan

`docs/testing/verification-plan.md` — not yet created (Phase 6, seeded during Phase 3).

Roblox Studio is **not available in this environment**, so every runtime test will be
authored as a manual, reproducible plan rather than executed.

---

## Last Completed Work

- **Phase:** 0 — Initial Analysis
- **System:** Bootstrap / Template Loading; World & Housing (reading only)
- **Files created:** `DOCS_PROGRESS.md`
- **Diagrams:** none yet
- **Bug candidates:** none formalised (5 leads recorded above)
- **Last commit:** *(this commit)* `docs: initialize documentation analysis`

---

## Next Recommended Work

**Phase 1 — Documentation Infrastructure.** Concretely, in this order:

1. Add Moonwave configuration (`moonwave.toml` at the repo root) pointing at
   `src/` for the API layer and `docs/` for the conceptual layer. Confirm the
   Moonwave CLI can actually run in this environment (`npx moonwave build`);
   if the network blocks the install, record that and still land the config +
   the CI workflow, which will install it on GitHub's runners.
2. Create the `docs/` skeleton — **only pages that will actually be written**:
   `docs/index.md`, `docs/architecture/`, `docs/systems/`, `docs/testing/`.
   Do **not** create empty placeholder pages.
3. Add `.github/workflows/docs.yml`: build Moonwave, fail loudly on build error,
   deploy to GitHub Pages via `actions/deploy-pages`.
4. Commit as three separate checkpoints:
   `docs: configure Moonwave`, `docs: add documentation structure`,
   `ci: add GitHub Pages documentation workflow`.

Then **Phase 2 — Architecture**, starting with `docs/architecture/initialization.md`
and `docs/architecture/server-lifecycle.md`, both of which are already backed by
fully-read source.

Before Phase 3 can properly cover Housing, `Core/ServerStorage/DataKit/` must be read
in full (`init`, `Profile`, `Store`, `BaseStore`, `Lease`, `Mutex`, `Adapters`) —
the reservation-concurrency question (lead **T-a**) cannot be answered without it.
