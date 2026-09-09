---
sidebar_position: 1
title: Initialization
---

# Initialization

This page describes how a Voz Hispana server assembles itself from an almost-empty
DataModel into a running game. It is the single most important page on this site,
because nothing else in the codebase makes sense without it.

## The short version

Almost nothing that runs in Voz Hispana is in this repository's `src/` tree at the
place it will eventually live. At runtime, a server:

1. downloads three *template* assets from Roblox with `InsertService:LoadAsset`,
2. merges their contents into the live services (`ReplicatedStorage`,
   `ServerScriptService`, `StarterGui`, …),
3. and only then enables the scripts that arrived, which have been shipped disabled.

Everything else — player initialization, the world system, housing — happens after
that.

## The four bootstrap files

**FACT.** Only four files participate in the bootstrap, and they are the only Luau in
the repository outside the template folders:

| File | Kind | Role |
|---|---|---|
| `src/ServerScriptService/ImportTemplates.server.luau` | `Script` | Imports and merges the templates |
| `src/ServerScriptService/InitScripts.server.luau` | `Script` | Enables the imported scripts |
| `src/ReplicatedStorage/InitAfterTemplates.luau` | `ModuleScript` | Blocking "templates are ready" barrier |
| `src/ReplicatedStorage/PlayerInit.luau` | `ModuleScript` | Deferred `PlayerAdded` fan-out |

Both `Script`s carry the tag `IgnoreLoader` in their `.meta.json`. **INFERENCE:** the
tag exists so that a loader elsewhere skips them; nothing in this repository reads
`IgnoreLoader`, so the consumer is either in a template asset or unused.

## Boot sequence

```mermaid
sequenceDiagram
    autonumber
    participant RBX as Roblox
    participant IT as ImportTemplates<br/>(ServerScriptService)
    participant IS as InitScripts<br/>(ServerScriptService)
    participant IAT as InitAfterTemplates<br/>(ReplicatedStorage)
    participant RS as ReplicatedStorage
    participant Svc as Live services

    RBX->>IT: server start
    RBX->>IS: server start
    Note over IT,IS: Two sibling Scripts. Roblox guarantees<br/>no ordering between them.

    IT->>RS: create TemplatesReady (RemoteEvent)
    IT->>RS: create TemplatesReadyFlag (BoolValue = false)
    IS->>RS: create InitScriptsReadyFlag (BoolValue = false)

    IS->>IAT: require(...)
    activate IAT
    Note over IAT: blocks on TemplatesReadyFlag

    IT->>IT: require(PlayerInit)
    IT->>IT: PlayerInit.Connect(voice-chat gate)

    loop for each of 3 template asset IDs
        IT->>RBX: InsertService:LoadAsset(id)
        IT->>IT: prefer ServerStorage.TemplatesTesting[name] override
        IT->>Svc: processImportedModel -> merge into services
    end

    IT->>Svc: destroy ServerStorage.TemplatesTesting
    IT->>RS: TemplatesReadyFlag = true
    IT->>RS: TemplatesReady:FireAllClients()

    IAT-->>IS: returns true
    deactivate IAT
    IS->>IS: task.wait(1)
    IS->>Svc: enable every disabled BaseScript (with exclusions)
    IS->>RS: InitScriptsReadyFlag = true
```

### Related implementation

| Step | Code |
|---|---|
| Template asset IDs | `ImportTemplates.server.luau`, `TEMPLATES_IDS` |
| Override lookup | `ImportTemplates.server.luau`, `testOverrides` |
| Merge into services | `ImportTemplates.server.luau`, `processImportedModel` / `mergeInstances` |
| Readiness barrier | `InitAfterTemplates.luau` |
| Script enabling | `InitScripts.server.luau` |
| Player fan-out | [`PlayerInit`](/api/PlayerInit) |

## Step 1 — Template import

**FACT.** `ImportTemplates.server.luau` declares three asset IDs, in a fixed order,
with an explicit comment that the first must stay first:

```lua
local TEMPLATES_IDS = {
    137484964666215, -- CORE (siempre el primero)
    92258948630058,  -- GameWorlds
    94091855508048   -- BuildingSystem
}
```

For each ID it calls `InsertService:LoadAsset(assetId)` inside a `pcall`, takes the
first child of the returned model, and then chooses between two sources:

- if `ServerStorage.TemplatesTesting` contains a `Folder` or `Model` **with the same
  name**, that local copy is cloned and used instead, and the downloaded one is
  destroyed;
- otherwise the downloaded one is used.

**This is why the repository looks the way it does.** `src/ServerStorage/TemplatesTesting/Core/…`
is a local override of the published `Core` asset. It is not where that code lives at
runtime — at runtime its `ReplicatedStorage` subfolder's contents are children of the
real `ReplicatedStorage`.

So a path like:

```
src/ServerStorage/TemplatesTesting/Core/ServerStorage/WorldSystem/Profiles.luau
```

is, at runtime:

```
ServerStorage.WorldSystem.Profiles
```

which is exactly how other scripts require it:

```lua
local worldSystemStorage = ServerStorage:WaitForChild("WorldSystem")
local Profiles = require(worldSystemStorage:WaitForChild("Profiles"))
```

### Which services can receive content

**FACT.** Only folders whose name is in `validServices` are merged; anything else in a
template's root is ignored:

```
ReplicatedFirst, StarterGui, ServerScriptService, ReplicatedStorage, ServerStorage,
StarterPack, StarterPlayer, SoundService, Lighting, MaterialService
```

### Merge semantics

**FACT.** `mergeInstances(source, target)` walks the source's children:

| Case | Behaviour |
|---|---|
| Target has no child of that name | The instance is re-parented into the target |
| Target has a child of that name, **same** `ClassName` | Recurse into it, then destroy the incoming instance |
| Target has a child of that name, **different** `ClassName` | The incoming instance is destroyed, silently |

**INFERENCE.** The existing instance always wins. Because `Core` is imported first,
`Core` wins every name collision against `GameWorlds` and `BuildingSystem`. That is
what "CORE (siempre el primero)" buys.

**Note the asymmetry:** a same-class collision merges *children* but keeps the existing
instance itself. For a `Folder` that is a union. For a `ModuleScript` or a `Script`, the
incoming source code is discarded — the existing one is kept and the new one destroyed.

### Cleanup

**FACT.** After the loop, the whole override folder is removed:

```lua
local folderTest = ServerStorage:FindFirstChild("TemplatesTesting")
if folderTest then
    folderTest:Destroy()
    Debris:AddItem(folderTest)
end
```

**OBSERVATION.** `Destroy()` then `Debris:AddItem()` on the same already-destroyed
instance is redundant, not harmful. It is recorded as an observation only; it is not a
defect and requires no change.

## Step 2 — The readiness barrier

**FACT.** `InitAfterTemplates` is a `ModuleScript` that **blocks until templates are
ready and then returns `true`**. Requiring it is the wait:

```lua
require(ReplicatedStorage:WaitForChild("InitAfterTemplates"))
```

It resolves differently per side:

| Side | Source of truth |
|---|---|
| Server (`RunService:IsServer()`) | `TemplatesReadyFlag` (a `BoolValue`), read now and watched via `.Changed` |
| Client | `TemplatesReady` (a `RemoteEvent`) `OnClientEvent`, **plus** an immediate read of `TemplatesReadyFlag` for the case where the event already fired |

Both branches then `repeat task.wait() until ready`.

Because Luau caches `ModuleScript` results, the block happens **once per side**; every
later `require` returns the cached `true` immediately.

## Step 3 — Enabling the imported scripts

**FACT.** Templates ship their scripts disabled — 104 of the 170 `.meta.json` files in
this repository set `Disabled: true`. `InitScripts.server.luau` turns them on:

```mermaid
flowchart TD
    A["require(InitAfterTemplates)"] --> B["task.wait(1)"]
    B --> C["for obj in game:GetDescendants()"]
    C --> D{"descendant of<br/>Players or ServerStorage?"}
    D -- yes --> C
    D -- no --> E{"descendant of<br/>ReplicatedStorage.Client?"}
    E -- yes --> C
    E -- no --> F{"BaseScript with<br/>Enabled == false?"}
    F -- no --> C
    F -- yes --> G{"tagged<br/>IgnoreAutoEnable?"}
    G -- yes --> H["ignoredCount += 1"]
    G -- no --> I["pcall: obj.Enabled = true"]
    I --> J["enabledCount += 1"]
    H --> C
    J --> C
    C --> K["InitScriptsReadyFlag = true"]
```

Three exclusions, all **FACT**:

1. **`Players` and `ServerStorage` descendants are skipped.** Scripts inside a player's
   `Backpack`/`PlayerGui`, and anything left in `ServerStorage`, stay as they are.
2. **`ReplicatedStorage.Client` descendants are skipped.** This folder holds
   `RunContext = "Client"` scripts; the server does not enable them.
3. **Anything tagged `IgnoreAutoEnable`** is counted and skipped. Four scripts in the
   repository carry this tag.

**FACT.** The `task.wait(1)` between the barrier and the sweep is unconditional and
unexplained in the source.

## Reading the repository correctly

Two conventions in this repository will mislead a reader who assumes standard Roblox
practice.

### The `.server.luau` suffix does not mean "server"

**FACT.** Rojo derives a script's class from the filename suffix, but `RunContext` in a
sibling `.meta.json` overrides where it actually runs. In this repository `RunContext`
is set explicitly on 74 scripts: **47 `Server` and 27 `Client`**.

Every file under `Core/ReplicatedStorage/Client/` named `*.server.luau` is a
**client-context** `Script`. For example
`Core/ReplicatedStorage/Client/PlayerManager.server.luau` uses `Players.LocalPlayer` and
its `.meta.json` says `"RunContext": "Client"`.

> **Always read the sibling `.meta.json` before concluding where a script runs.**

### A script's file location is not its runtime location

Covered above: everything under `TemplatesTesting/<Template>/<Service>/` ends up under
`<Service>` at runtime.

## Ordering guarantees

**FACT.** `ImportTemplates` and `InitScripts` are sibling `Script`s in
`ServerScriptService`. Roblox does not define an execution order between sibling
scripts.

**INFERENCE.** The design does not rely on one. `InitScripts` blocks on
`InitAfterTemplates`, which blocks on a `BoolValue` that `ImportTemplates` sets last.
Whichever starts first, `InitScripts` cannot proceed past the barrier until
`ImportTemplates` has finished. Similarly, `InitAfterTemplates` uses
`WaitForChild` for `TemplatesReady`/`TemplatesReadyFlag`, so it tolerates being required
before `ImportTemplates` has created them.

**THEORY — not verified.** There is one ordering the barrier does not cover. The
`TemplatesReadyFlag` `BoolValue` is created by `ImportTemplates`, but `InitScripts`
creates `InitScriptsReadyFlag` itself and template scripts wait on *that*. What is not
covered is a template script that begins running the moment it is enabled and reads
state a *later*-enabled script was supposed to publish; the sweep order over
`game:GetDescendants()` is not defined by the source. This is recorded, not asserted.

## Two flags and one remote

**FACT.** The bootstrap publishes three instances into `ReplicatedStorage`:

| Name | Class | Created by | Meaning |
|---|---|---|---|
| `TemplatesReady` | `RemoteEvent` | `ImportTemplates` | Fired to all clients once templates are merged |
| `TemplatesReadyFlag` | `BoolValue` | `ImportTemplates` | Server-side source of truth for the same fact |
| `InitScriptsReadyFlag` | `BoolValue` | `InitScripts` | Set once the enable sweep has finished |

`InitScriptsReadyFlag` is read outside the bootstrap: `playerManager.server.luau`
refuses `LoadCharacterRequest` while it is false. See
[Player lifecycle](./player-lifecycle.md).

## The voice-chat gate

**FACT.** `ImportTemplates.server.luau` also registers the game's entry requirement,
before it does any importing:

```lua
PlayerInit.Connect(onPlayerAdded)
```

For each player it calls `VoiceChatService:IsVoiceEnabledForUserIdAsync(player.UserId)`
inside a `pcall`:

- call succeeded **and** voice is disabled → the player is kicked;
- call succeeded and voice is enabled → nothing happens;
- call **failed** → only `warn`, the player stays.

The source comment on the failure branch reads *"quizas conviene que le hagamos kick
tambien"* ("maybe we should kick them too"), so the third branch is a known open
decision rather than an oversight. Recorded as **BUG-CANDIDATE-001** in
**Verification**.

## What is not knowable from this repository

| | |
|---|---|
| **UNKNOWN** | Whether the published contents of assets `137484964666215`, `92258948630058` and `94091855508048` match `TemplatesTesting/Core`, `/GameWorlds` and `/BuildingSystem` on disk. The override only applies when a same-named folder exists locally; in production the published asset is what ships. |
| **UNKNOWN** | Where `PlayerHouses` is imported. It exists under `TemplatesTesting/` but no asset ID in `TEMPLATES_IDS` is commented as such, and `PlayerHouses` is not one of the three. See **Systems → Housing**. |
| **UNKNOWN** | What is inside `src/StarterPlayer/StarterPlayerScripts.rbxm` and `StarterCharacterScripts.rbxm`. Binary. See [Client lifecycle](./client-lifecycle.md). |
| **OBSERVATION** | `default.project.json` maps `StarterPack` to `src/StarterPack`, which does not exist in the repository. |
