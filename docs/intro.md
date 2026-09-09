---
sidebar_position: 1
title: Introduction
---

# Voz Hispana — Engineering Documentation

This site documents the Voz Hispana Roblox project **as it is actually written**, not as
it might ideally be designed. Every statement here is derived from source in this
repository. Where the source cannot settle a question, the page says so explicitly
rather than guessing.

## How to read this site

The documentation is layered. Each layer narrows the scope of the one above it:

```
PROJECT  →  ARCHITECTURE  →  LIFECYCLES  →  SYSTEMS  →  FLOWS  →  SCRIPTS  →  MODULES  →  FUNCTIONS
```

| Layer | Section |
|---|---|
| Architecture & lifecycles | **Architecture** |
| Systems and their flows | **Systems** |
| Per-script and per-asset reference | **Reference** |
| Public module APIs | **API Reference** (Moonwave, extracted from source comments) |
| Suspected defects and how to test them | **Verification** |

Use the sidebar to navigate; the sections above appear there as they are written.

## What this project is, structurally

Voz Hispana is **not** a single Roblox place with a single script tree. Three facts
shape everything else:

1. **The committed source tree is mostly a set of *templates*, not the live game.**
   `src/ServerScriptService/ImportTemplates.server.luau` pulls three published Roblox
   assets at runtime with `InsertService:LoadAsset` and merges them into the live
   services. What is committed under `src/ServerStorage/TemplatesTesting/` are
   *local overrides* of those assets, used in place of the published versions when
   present. See **Architecture → Initialization**.

2. **Most scripts ship disabled and are switched on after the import finishes.**
   104 of the 170 `.meta.json` files set `Disabled: true`.
   `src/ServerScriptService/InitScripts.server.luau` walks the DataModel after the
   templates land and re-enables them.

3. **The game spans multiple places.** A player's house runs in a *reserved server* of a
   different `PlaceId` (declared in `ReplicatedStorage/HousesInfo`), reached through
   `TeleportService`. The lobby, karaoke, arcade and donation places are separate
   `PlaceId`s too. See [Housing](./systems/housing/overview.md).

Because of (1), a reader who only greps `src/` will misjudge what runs where. Because of
(2), a script's file suffix does not tell you whether it is enabled — or even whether it
runs on the client. **Architecture → Initialization** states the rules that actually
apply.

## Conventions used throughout

Claims are tagged so the reader always knows how much weight they carry:

| Tag | Meaning |
|---|---|
| **FACT** | Directly visible in source in this repository. |
| **INFERENCE** | A reasonable conclusion drawn from several places in the source. |
| **THEORY** | A hypothesis about runtime behaviour that static reading cannot settle. |
| **UNKNOWN** | Cannot be determined from the available source at all. |

Suspected defects are never called bugs. They are recorded as
`BUG-CANDIDATE-XXX` entries with a classification, the evidence behind them, what
remains unknown, and a reproducible plan to confirm or dismiss them. See
**Verification**.

## Not inspectable from this repository

320 `.rbxm` files are binary and their contents cannot be read. Several of them matter a
great deal — notably `src/StarterPlayer/StarterPlayerScripts.rbxm` and
`src/StarterPlayer/StarterCharacterScripts.rbxm`, which may hold the real client entry
points. Pages that depend on them state the gap instead of filling it. The full list is
in [Binary assets](./reference/binary-assets.md).
