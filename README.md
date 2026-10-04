# Stardew-ish Movement Sandbox â€” v0.0.0.5

A tiny Godot 4.x prototype focused on movement feel, stamina, terrain, 3/4 presentation, and a real animated player sprite.

## v0.0.0.6: interaction and inventory

- Face a nearby tree or chest and press **E**. The closest eligible object in front is selected; walls block interaction.
- Trees shake and scatter 1–3 fruit by default, with a 3-second cooldown. Each tree keeps its assigned fruit for the run.
- Walk over drops to collect them. Pickups wait briefly after spawning, and full inventories leave excess fruit in the world.
- Press **I** for the 16-slot player inventory. Click a stack, then another slot to move, merge, or swap it.
- The test chest near the starting position has exactly **32 slots**, prefilled with six fruit stacks. Press E to open both inventories; click any stack to transfer as much as the destination accepts.
- **I / Esc** closes the inventory; **E** also closes the chest. Movement and pickup pause while a panel is open. Chest contents persist during the run; no save system is added.

## Included

- WASD 8-direction walking
- Hold Shift to run
- Left Alt dash
- Dash uses the current movement direction, or the last facing direction if standing still
- Stamina drain while running
- Fixed stamina cost for dash
- Stamina regeneration after a short delay
- F1 toggles infinite stamina
- Bush terrain slows movement to 75%
- Rocky terrain slows movement to 55%
- Tree trunks and walls are impassable; tree canopies are walk-under
- 3/4-style depth presentation and Y-based sorting
- Animated player sprite using the supplied Lexlom character pack
- 9 selectable prototype skins
- F2 cycles through player skins
- All tuning values kept in `data/game_config.json`
- Reserved progression structure for a future Athletics/leveling system, but no leveling logic yet

## Run it

1. Install Godot 4.x.
2. Open Godot Project Manager.
3. Click **Import** and select this folder's `project.godot`.
4. Open the project and press **F6/F5** (Play).

## Technical validation in Codex

Follow [AGENTS.md](AGENTS.md) for the configured Godot executable and headless editor/runtime checks. Run technical validation when relevant and report actual results. Earlier handoff and patch notes describe historical environments; they do not prohibit running Godot in the current environment. Visual appearance and game feel require interactive playtesting or suitable automated tests.

## Controls

- **WASD** â€” walk
- **Shift + WASD** â€” run
- **Left Alt** â€” dash
- **F1** â€” toggle infinite stamina
- **F2** â€” cycle player skin

## Player sprite assets

Runtime-ready player sheets live in:

`assets/characters/villagers/`

Each of the nine `skin_XX.png` files is a 96x192 sheet made of 32x64 cells:

- row 1: facing down/front
- row 2: facing up/back
- row 3: side-facing; Godot flips it horizontally for left
- 3 animation frames per direction

The original editable Krita files supplied for this prototype were moved to:

`assets/source/characters/lexlom/`

The source URL is recorded in `SOURCE.txt` in that folder.

Walking uses the three-frame walk cycle. Running reuses the same artwork at a faster animation rate for now. Dashing also reuses the supplied movement frames until a dedicated dash animation exists.

## Easy balancing

Edit:

`data/game_config.json`

The current defaults are:

- Walk speed: 100
- Run speed: 170
- Dash speed: 340
- Dash duration: 0.18 s
- Dash cost: 25 stamina
- Dash cooldown: 0.35 s
- Run cost: 15 stamina/s
- Regen: 25 stamina/s
- Regen delay: 0.75 s
- Bush multiplier: 0.75
- Rock multiplier: 0.55
- Walk animation: 6 FPS
- Run animation: 10 FPS
- Dash animation: 14 FPS

## Future-proofing kept intentionally small

`player.modifiers` and `progression.skills.athletics` are placeholders so future leveling can feed bonuses into movement/stamina without redesigning the data file. They are not active systems in this version.

## v0.0.0.5

- Added animated character sprites from the supplied Lexlom `.kra` files.
- Exported 9 runtime-compatible PNG skin sheets.
- Added F2 skin cycling and current-skin HUD display.
- Added configurable animation rates and sprite offset.
- Moved original `.kra` source files into a dedicated source-assets folder.
- Reduced the player collision radius slightly so collision matches the character's feet better.

## Reusable systems

- `data/items.json` stores stable item IDs, display names, icon paths, maximum stacks (20), category, and type. `ItemCatalog` validates and loads definitions/icons.
- `ItemInventory` stores generic `{item_id, quantity}` stacks and empty slots. It supports capacity queries, adding/removing items, moving/merging/swapping stacks, and partial transfers. Only accepted quantities are removed from their source.
- `WorldPickup` renders the catalog icon, waits the configurable spawn grace period, and collects by proximity. It retains unaccepted quantities.
- `InteractionDetector` uses player facing, reach, width, and a wall-blocking ray check. `Interactable` is the common base for `FruitTree` and `TestChest`; the player controller contains no tree/chest cases.
- `FruitTree` receives an assigned item ID and a drop definition from configuration. Assignment happens once at startup, cycling through `tree_drops.fruit_ids`. Each interaction randomizes quantity and scatter, with configurable cooldown/shake timing. Only the canopy shakes; trunk collision stays fixed.
- `InventoryUI` builds screen-space grids, scales to fit the window, and displays icons, counts, empty slots, and capacity feedback.

Tune player capacity in `inventory.player_slots`, interaction range in `interaction`, drop settings in `tree_drops`, and pickup range/delay in `pickups`, all in `data/game_config.json`. Chest capacity is fixed at 32 by this prototype's requirements.

## Fruit assets

42 fruit sprite variants were copied unchanged from the pack's 32×32 unscaled PNGs into `assets/items/food/fruits/`. Cut/whole and color variants have distinct definitions matching their actual artwork (for example, `orange` is the whole `orange2` source sprite; `orange_slice` uses `orange`). The pack only supplies a cut peach sprite; its display name is Peach Half.

Skipped: `_o` outlined duplicates and the scaled duplicate set, to use one consistent pixel scale/style. Vegetables and cooking produce (including tomatoes, peppers, cucumbers, eggplant, pumpkin, and zucchini) are outside this fruit slice. The original source pack is unchanged.

## Validation

Run the configured Godot executable against this checkout; use `AGENTS.md` as the local executable reference and replace `--path` if using a separate checkout.

```powershell
& $godot --headless --path $project --editor --quit
& $godot --headless --path $project --quit-after 120
& $godot --headless --path $project --script res://tests/vertical_slice_test.gd
& $godot --path $project --script res://tests/visual_smoke.gd
```

The headless suite verifies capacity, splitting/merging/swapping, partial pickup/transfer without item loss, closest/facing interaction, tree cooldown/drop range, icon loading, chest persistence, UI layout, skins, dash stamina, terrain slowing, and scaled depth order. The rendered smoke test sends E/I/Esc and mouse clicks through the viewport and captures the flow. Set `V006_CAPTURE_DIR` to choose a screenshot output directory (defaults to `user://visual_checks`).

Human playtest checklist: walk/run/dash to every tree, face it and press E, inspect the shake and fruit scatter, collect fruit, move stacks with I, transfer both ways at the chest, fill inventory to check leftovers, reopen the chest, cycle skins, and resize the window to inspect canopy depth and HUD. Automated input checks do not establish game feel or replace this manual review.
