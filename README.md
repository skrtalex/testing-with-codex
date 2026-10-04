# Stardew-ish Movement Sandbox — v0.0.0.5

A tiny Godot 4.x prototype focused on movement feel, stamina, terrain, 3/4 presentation, and a real animated player sprite.

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

## Controls

- **WASD** — walk
- **Shift + WASD** — run
- **Left Alt** — dash
- **F1** — toggle infinite stamina
- **F2** — cycle player skin

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
