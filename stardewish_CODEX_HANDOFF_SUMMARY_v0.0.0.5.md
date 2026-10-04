# Conversation / Codex Handoff Summary

## Why this document exists

The original ChatGPT conversation became long and increasingly awkward to continue. This document is intended to let development continue in Codex without needing the full chat history.

**Current source-of-truth build:** `StarDewy` v0.0.0.6

The interaction/item/inventory slice is documented in README.md. Use E for interaction, I for player inventory, and click stacks for chest transfers. The version-specific details below describe the earlier v0.0.0.5 movement handoff.

## Project goal

Build a game with a Stardew Valley-like level of readability and approachable systems, but **not necessarily a farming-centered game**.

The project began by intentionally reducing the problem to a movement sandbox.

The current preferred technical/art direction is:

> **Godot 4.x + GDScript + 2D mechanics + stronger 3/4 perspective artwork + Y-sorting**

Do not convert the prototype to real 3D just to get a lower camera feeling.

## Decisions made in the conversation

### Engine
Godot 4.x was chosen.

Reasons discussed:
- strong 2D workflow
- free/open ecosystem
- suitable for tile/world/NPC/inventory-style games
- GDScript is approachable for this project

### First prototype scope
The first versions should test control feel rather than build actual game content.

Core features chosen:
- WASD 8-direction movement
- Shift to run
- Left Alt to dash
- stamina consumed by running/dashing
- automatic stamina regeneration
- F1 infinite-stamina debug toggle

Dash was specifically moved from Space to **Left Alt**.

### Terrain
- bushes are walkable and slow movement
- rocky terrain is walkable and slows movement more strongly
- walls are solid
- tree **trunks** are solid
- tree **canopies/leaves are not solid**

This was an important correction: the player must be able to walk under tree foliage.

Current terrain multipliers:
- normal: 1.00
- bush: 0.75
- rocks: 0.55

### Configuration
The user wants balancing values easy to change.

Therefore:
- gameplay tuning values are stored in `data/game_config.json`
- code should avoid scattered magic numbers
- config and future save data should remain separate concepts

A small future-proof structure was added for:
- stat modifiers
- progression
- an Athletics skill

But the user explicitly did **not** want to design/build leveling in detail yet.

### Progression concept
Only a future hook is desired for now.

Important design idea:
- movement code should eventually consume final stat values
- leveling/perks/equipment can modify those values without rewriting movement
- Athletics is reserved as a plausible future movement/stamina skill

No actual leveling logic exists.

### Visual direction discussion
A generated visual mockup that looked too isometric/painted was rejected.

The direction that was accepted was instead:

> keep the mechanics fully 2D, but make the artwork feel more 3/4 and use Y-sorting

That means:
- taller trees
- visible trunks
- front faces on walls/buildings
- shadows
- player sorted by feet/base position
- walk behind canopies
- more depth without true 3D

The user tested v0.0.0.4 and said it was a **good improvement**, with only small touches still needed.

### Character asset
The user chose:

`https://lexlom.itch.io/32-character-pack-pixel-art-4-direction-idle-walking`

The user supplied `.kra` files in the project ZIP.

v0.0.0.5 converts/organizes these into:
- runtime PNG sheets under `assets/characters/villagers/`
- original editable `.kra` files under `assets/source/characters/lexlom/`

9 runtime-compatible prototype skins are currently available.

F2 cycles player skin.

## Current controls

- WASD = move
- Shift = run
- Left Alt = dash
- F1 = infinite stamina on/off
- F2 = next player skin

## Current balance defaults

```text
max stamina:              100
walk speed:               100
run speed:                170
dash speed:               340
dash duration:            0.18 s
dash cost:                25
dash cooldown:            0.35 s
run stamina cost:         15 / second
stamina regen:            25 / second
regen delay:              0.75 s

normal terrain:           1.00
bush terrain:             0.75
rock terrain:             0.55

walk animation:           6 FPS
run animation:            10 FPS
dash animation:           14 FPS
player sprite offset Y:   -8
```

These are expected to be tuned.

## Current architecture

Key files:

```text
project.godot
data/game_config.json

scenes/
â””â”€â”€ Main.tscn

scripts/
â”œâ”€â”€ game_config.gd
â”œâ”€â”€ main.gd
â””â”€â”€ player.gd

assets/
â”œâ”€â”€ characters/
â”‚   â””â”€â”€ villagers/
â”‚       â””â”€â”€ skin_01.png ... skin_09.png
â”œâ”€â”€ source/
â”‚   â””â”€â”€ characters/
â”‚       â””â”€â”€ lexlom/
â”‚           â”œâ”€â”€ ModelSheet.kra
â”‚           â”œâ”€â”€ VillagersSheet.kra
â”‚           â””â”€â”€ SOURCE.txt
â””â”€â”€ terrain/
    â”œâ”€â”€ bush_tile.png
    â””â”€â”€ rock_tile.png
```

### `game_config.gd`
Loads `data/game_config.json`.

### `player.gd`
Responsible for:
- movement
- run/dash
- stamina
- terrain multiplier
- infinite stamina
- facing direction
- animation state
- skin loading/cycling
- Y-based z-index

### `main.gd`
Responsible for:
- building the current procedural test course
- test trees/walls/terrain/decorative objects
- HUD updates
- viewport/world scaling
- some current 3/4 placeholder presentation

## Current character-sheet format

Each runtime skin PNG:
- 96 x 192
- frame size 32 x 64
- 3 frames per row

Rows:
1. down/front
2. up/back
3. side

Left-facing uses horizontal flip.

Walk sequence currently:
`0, 1, 2, 1`

Run reuses the walk frames at a faster rate.
Dash also reuses available movement frames.

## Important implementation notes

### Player collision
Player collision radius is currently `8.0`.

This was reduced when the real character sprite was introduced so collision better approximates the player's feet instead of the full visible body.

### Y-sorting
Current implementation is relatively simple/manual:
- player `z_index` is based on `global_position.y`
- world objects receive z-index values based on a chosen base/sort Y
- some canopy/front visual elements use additional z offsets

It works as a prototype direction, but it may need a cleaner sorting architecture later.

### Window scaling
The current test area has a logical size of 960x600.

The whole test world is uniformly scaled to fit the viewport.
HUD is on a `CanvasLayer` and positioned/scaled separately so it remains readable.

For a real world larger than one screen, replace this pattern with a normal world + `Camera2D`.

## Runtime verification status

Earlier versions were tested by the user.

Notably:
- v0.0.0.4 was reported to look good and be a clear improvement.
- v0.0.0.5 added the Lexlom animated sprite/skin system.

Historical context: the environment that produced these builds did not have Godot available. That limitation applied only to that environment and does not restrict current Codex sessions. Follow [AGENTS.md](AGENTS.md) for the installed executable and required technical validation. Attempt Godot validation before reporting it unavailable; report actual failures and request execution permission if needed.

When continuing in Codex, run the current checkout through the headless editor and runtime checks in [AGENTS.md](AGENTS.md), and fix any parser/runtime/import issues before adding new features. Visual appearance and game feel still require interactive playtesting or suitable automated tests.

## Historical issue worth knowing

v0.0.0.2 claimed to add terrain textures and resizing, but the user's screenshot showed that only the tree change was clearly working. The texture/rendering and resizing work was corrected in v0.0.0.3.

Do not assume every historical patch note means the feature worked correctly on the first attempt.

## Historical suggested v0.0.0.5 Codex task

Start with:

> Run/inspect v0.0.0.5. Verify the 9-skin player system, directional walk animation, F2 switching, Y-sorting, collision at the feet, and HUD/window scaling. Fix any actual runtime issues without adding unrelated systems. After it is stable, tune walk/run animation feel and sprite offset.

The project should remain a small movement prototype until those fundamentals feel good.
