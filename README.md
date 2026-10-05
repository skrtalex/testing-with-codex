# Stardew-ish Movement Sandbox â€” v0.0.7

## UI and testing areas — v0.0.7

- The normal HUD shows stamina, a short control hint, and version. **Esc** opens a paused test menu with Debug, Keybinds, and Test areas tabs. When an inventory is open, Esc closes it first.
- **F1** toggles infinite stamina, **F2** cycles skins, **F3** shows diagnostics, and **F4** overlays solid/terrain/player footprints and interaction reach. Keyboard and menu commands share behavior. A toast appears beneath stamina for one second; a newer command replaces it. Timers continue while the menu is open.
- The menu also refills stamina, returns the player to the current arrival point, travels between areas, and resets the current area's world after confirmation. Player inventory and the other area's state survive reset.
- Scene 1's top-center opening leads to Scene 2's bottom-center opening. Arrival points sit clear of triggers to prevent immediate return. Travel retains player inventory, skin, stamina/debug state and each area's chests, pickups and harvest state during the run. Inactive areas stop processing.
- `scenes/SystemsLab.tscn` reserves cooking and combat zones. An ingredient chest works with the existing inventory; counters, stove and targets are floor markers. Cooking, attacks, enemies, damage and equipment are not implemented.

A tiny Godot 4.x prototype focused on movement feel, stamina, terrain, 3/4 presentation, and a real animated player sprite.

## Interaction and inventory

- Face a nearby tree or chest and press **E**. The closest eligible object in front is selected; walls block interaction.
- Trees shake and scatter 1–3 fruit by default, with a 3-second cooldown. Each tree keeps its assigned fruit for the run.
- Walk over drops to collect them. Pickups wait briefly after spawning, and full inventories leave excess fruit in the world.
- Press **I** for the 16-slot player inventory. Drag a stack onto a slot, or click a stack then a destination, to move, merge, or swap it.
- Both chests are inside the top-middle storage building: the small chest on the left has **32 slots**, and the large chest on the right has **64 slots**. Each is prefilled with six fruit stacks. Press E to open both inventories; double-click a stack to transfer as much as the destination accepts. Dragging or click-then-place allows precise placement, merging, and swapping within either inventory or between them.
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
- Bush terrain uses the configured multiplier (currently 90%)
- Rocky terrain uses the configured multiplier (currently 75%)
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

- Walk speed: 120
- Run speed: 190
- Dash speed: 350
- Dash duration: 0.18 s
- Dash cost: 20 stamina
- Dash cooldown: 0.35 s
- Run cost: 13 stamina/s
- Regen: 25 stamina/s
- Regen delay: 0.50 s
- Bush multiplier: 0.90
- Rock multiplier: 0.75
- Walk animation: 6 FPS
- Run animation: 10 FPS
- Dash animation: 14 FPS

## Future-proofing kept intentionally small

`player.modifiers` and `progression.skills.athletics` are placeholders so future leveling can feed bonuses into movement/stamina without redesigning the data file. They are not active systems in this version.

## Earlier sprite work

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

Tune player capacity in `inventory.player_slots`, interaction range in `interaction`, drop settings in `tree_drops`, and pickup range/delay in `pickups`, all in `data/game_config.json`. Chest capacities are 32 and 64 slots; each chest owns a separate inventory.

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

### Inventory mouse controls

| Action | Result |
|---|---|
| Drag to an empty slot | Move the whole stack |
| Drag onto the same item | Merge to its stack limit; excess stays in the source slot |
| Drag onto a different item | Swap stacks, within or between player/chest inventories |
| Click a stack, then another slot | The same targeted move/merge/swap behavior |
| Double-click with chest open | Transfer to the other inventory, retaining anything that does not fit |
| Double-click with player inventory alone | No quick transfer; items remain in place |
| Drop outside or close during a drag | Cancel without moving or losing items |

InventorySlot handles native Godot drag previews, targeted drops, click selection, and double-click transfers. Slot controls remain in place during inventory updates so pointer gestures survive refreshes. ItemInventory.move_to_slot updates both inventories atomically before emitting change signals. Full matching stacks reject drops; drag data is checked against the current source stack to reject stale drags.

Rendered tests exercise double-click transfer both ways, dragging within the chest and player inventory, cross-inventory swaps, partial/full merges, outside cancellation, closing mid-drag, and small-window controls.

## Chest and bush graphics

Small chest: `box.png` when closed, `box-open.png` while its transfer UI is open. Large chest: `box-large.png` / `box-large-open.png`. Closing with I, E, Esc, or the Close button restores the closed sprite. Both have footprint collision and preserve independent contents during the run. The large chest's 64-slot grid scrolls vertically so slots stay readable on small windows; drag/drop, click-to-place, and double-click transfers work in both chests.

Eleven individual walkable bushes replace the old bush-tile strips and procedural decorative bush. They cycle through all four `plant_bush_NE/NW/SE/SW.png` textures, with transparent export padding excluded using Sprite2D texture regions. The PNGs remain unchanged. Slowing applies only in each bush's small elliptical footprint near its base; gaps between bushes are normal terrain. Rock strips now use dense pebble sprite fields with one continuous configured slowing footprint per patch.

Tune `terrain.bush.display_width`, `slow_half_width`, `slow_half_height`, `slow_offset_y`, and `movement_multiplier` in `data/game_config.json`. `SlowBush` uses the existing terrain detector/overlap system, preserving slowest-overlap behavior and Y sorting from each bush's ground position. `ground/bush_tile.png` remains in the repository as an unused asset; runtime code no longer loads it.

## Asset overhaul — first iteration

The top-right garden contains six fruiting plants: bush1 -> blackberry; bush2 -> red/purple raspberry; shrub -> goldenberry with bare/husked variants; cactus -> dragon fruit. The upright cactus is placeholder artwork for a future climbing dragon-fruit cactus. Strawberries and other ground/vine crops are not part of this bush pass. Existing decorative slowing bushes remain separate from harvestable plants.

E uses the existing generic interaction detector. `HarvestablePlant` shares shake, cooldown, randomized quantity, and scattering between `FruitTree` and `FruitBush`; drops remain generic world pickups. Each configured garden plant keeps one item ID for the run. `plant_drops.plants` controls texture, item, position, and display size; the same section controls min/max drop quantity, cooldown, scatter, and shake. Fruiting plants remain walkable and have a small slowing footprint.

`PebblePatch` renders dense, staggered, slightly jittered pebble clusters inside each former rock patch. The whole patch slows movement continuously to avoid speed flicker between small sprites. Configurable `terrain.rocks` values include pebble width, spacing, jitter, and a layout seed. Both pebble fields are walkable; neither creates solid collision. Leaving a field restores normal terrain speed unless another slowing terrain overlaps.

Terrain runtime assets are organized as:

```text
assets/terrain/
  ground/                 retained, currently unused bush/rock tiles
  plants/decorative/      four directional slowing-plant sprites
  plants/fruiting/        bush1, bush2, shrub
  plants/cacti/           placeholder cactus
  rocks/                 pebbles
```

Import metadata moves with assets, with texture paths updated. The source library under `assets/source/` is unchanged. Original supplied PNG pixels are preserved. The storage doorway and central aisle stay clear; approach the small chest from the aisle to its right and the large chest from the aisle to its left.

New area/UI regression checks: run `--headless --path $project --script res://tests/test_areas_test.gd`. Verify the passage, menu and footprint presentation manually after pulling.
