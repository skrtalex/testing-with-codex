Inventory control update: drag or click-then-place to move, merge, and swap within or between inventories. Double-click quick-transfers while a chest is open. Cancelled drops and partial merges preserve remaining items.

# v0.0.0.6 — Interaction, fruit drops, inventory and chest

- Added shared interaction, item catalog, inventory stack, world pickup, tree drop, and chest transfer scripts.
- Every existing tree shakes its canopy and scatters a configurable random quantity of an assigned fruit. Cooldown prevents repeated spawning; trunk collision remains unchanged.
- Added 42 fruit sprite variants with matching data definitions, retaining the original source pack.
- Added configurable 16-slot player inventory and a fixed 32-slot chest prefilled with fruit.
- Added I inventory controls and drag-and-drop, click-then-place, and double-click quick transfer in both directions. Partial additions retain excess fruit/stacks at their source.
- Added headless integration tests and a rendered key/mouse smoke test; human game-feel review remains required.

The v0.0.0.5 notes below are retained as release history.

# Patch Notes / Development History

These notes reflect both what was implemented and what the user actually reported during testing.

---

## v0.0.0.1 â€” Initial movement sandbox

### Added
- Godot 4.x project skeleton.
- 960x600 movement test area.
- WASD 8-direction walking.
- Shift running.
- **Left Alt** dash.
- Last-facing-direction dash when standing still.
- Stamina system:
  - 100 max stamina
  - running drain
  - dash cost
  - regen delay
  - automatic regeneration
- F1 infinite-stamina debug toggle.
- Debug HUD:
  - stamina
  - current terrain
  - current movement state / speed
  - infinite stamina state
- Terrain movement types:
  - normal = 100%
  - bushes = 75%
  - rocks = 55%
- Tree and wall collision.
- Test zones for:
  - straight movement
  - corners
  - terrain slowdown
  - obstacles
- `data/game_config.json` for tuning values.
- Minimal future hooks:
  - `player.modifiers`
  - disabled `progression.skills.athletics`

### Design decisions established
- Stamina is the short-term movement resource.
- A separate future Energy resource may exist for daily/work actions.
- Balance values should be easy to edit outside movement code.

---

## v0.0.0.2 â€” Tree collision / first visual + resize attempt

### Intended changes
- Add bush texture.
- Add rock texture.
- Make the window/project resize better.
- Make trees taller.
- Change tree collision so only the trunk is solid.
- Allow the player to walk underneath the leaves/canopy.

### User test result
The user reported that **only the tree part was clearly working**.

Specifically:
- trunk-only collision / taller tree: worked
- bush/rock texture presentation: did not appear as intended
- resize behavior: did not appear to solve the problem as intended

This version should be treated as an intermediate attempt rather than a fully successful patch.

---

## v0.0.0.3 â€” Terrain rendering + responsive test window/HUD

### Fixed / added
- Corrected bush/rock texture rendering so the terrain visuals could actually be seen.
- Kept slow-terrain gameplay behavior.
- Changed project/window setup to support resizing.
- Added world scaling based on viewport size.
- Centered the 960x600 logical test world in the available window.
- Moved HUD logic to viewport-relative layout using a `CanvasLayer`.
- HUD elements scale within a capped range so they remain readable.
- Controls panel stays near bottom center.
- Version text stays top-right.
- Debug/stamina panel stays top-left.
- Preserved trunk-only tree collision and walk-under canopy behavior.

### Important architecture note
This is still a single-screen sandbox scaled as one logical world. A larger actual game should eventually use `Camera2D`.

---

## v0.0.0.4 â€” 3/4 presentation shift + Y-sorting

### Goal
Move away from the flat/top-down prototype without converting the game to real 3D.

### Added / changed
- Kept all mechanics and collision 2D.
- Shifted presentation toward stronger 3/4 depth.
- Added Y-based z-index sorting.
- Player origin/sort behavior moved toward a feet/base model.
- Reworked placeholder player from a simple circle toward a more character-like 3/4 placeholder.
- Trees received:
  - taller trunk presentation
  - layered canopy
  - roots
  - grounding shadow
- Walls/obstacles received:
  - visible front face
  - top lip / height cue
  - shadows
- Added explicit decorative depth tests:
  - boulder
  - bush
  - small facade/building-front test
- Added subtle depth/light bands to the test area.
- Retained:
  - trunk-only tree collision
  - walk-under canopy
  - stamina/movement rules
  - terrain slowdowns
  - responsive HUD/window behavior

### User feedback
The user said this **looked good**, needed only some small touches, and was a **good improvement**.

This confirmed the chosen visual direction:

> 2D mechanics + stronger 3/4 artwork + Y-sorting

---

## v0.0.0.5 â€” Animated player sprites + skin switching

### Source asset
Lexlom 32-character pixel-art pack:

`https://lexlom.itch.io/32-character-pack-pixel-art-4-direction-idle-walking`

The user supplied the editable Krita `.kra` source files.

### Added
- Replaced the hand-drawn placeholder player with an actual sprite-based character.
- Exported/organized **9 runtime-compatible player skins**; six malformed fixed-width crops were removed.
- Added proper runtime asset folder:
  - `assets/characters/villagers/`
- Added proper editable-source folder:
  - `assets/source/characters/lexlom/`
- Retained original `.kra` files.
- Added `SOURCE.txt` with source URL and asset notes.
- Added directional sprite animation:
  - down/front
  - up/back
  - side
  - horizontal flip for left
- Added idle frame behavior.
- Added walking animation.
- Running reuses walking frames at a faster animation rate.
- Dashing reuses supplied movement frames for now.
- Added **F2** to cycle character skins.
- Added HUD display for current skin.
- Added animation tuning values to `game_config.json`:
  - default skin
  - walk animation FPS
  - run animation FPS
  - dash animation FPS
  - sprite Y offset
- Reduced player collision radius from 10 to **8** to better represent the character's feet.

### Current animation defaults
- Walk: 6 FPS
- Run: 10 FPS
- Dash: 14 FPS
- Sprite Y offset: -8

### Runtime verification
This was the newest build when the conversation handoff was created.

At the time of this release, the producing environment could inspect files but could not launch Godot. This is a historical verification limitation, not an instruction to assume Godot is unavailable. Current Codex sessions must follow [AGENTS.md](AGENTS.md) and attempt the headless editor and runtime checks when relevant. Visual appearance and game feel require interactive playtesting or suitable automated tests.

---

# Current build summary

**Latest:** v0.0.0.6

Controls:

```text
WASD      Move
Shift     Run
Left Alt  Dash
F1        Toggle infinite stamina
F2        Change player skin
E         Interact / close chest
I         Player inventory
Esc       Close inventory
```

Current focus:

> Verify movement + animation + depth presentation before adding larger gameplay systems.
