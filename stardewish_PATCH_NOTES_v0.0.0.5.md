# Patch Notes / Development History

These notes reflect both what was implemented and what the user actually reported during testing.

---

## v0.0.0.1 — Initial movement sandbox

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

## v0.0.0.2 — Tree collision / first visual + resize attempt

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

## v0.0.0.3 — Terrain rendering + responsive test window/HUD

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

## v0.0.0.4 — 3/4 presentation shift + Y-sorting

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

## v0.0.0.5 — Animated player sprites + skin switching

### Source asset
Lexlom 32-character pixel-art pack:

`https://lexlom.itch.io/32-character-pack-pixel-art-4-direction-idle-walking`

The user supplied the editable Krita `.kra` source files.

### Added
- Replaced the hand-drawn placeholder player with an actual sprite-based character.
- Exported/organized **15 runtime player skins**.
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

The producing environment could inspect files but could not launch Godot, so v0.0.0.5 should be locally run and verified before further feature work.

---

# Current build summary

**Latest:** v0.0.0.5

Controls:

```text
WASD      Move
Shift     Run
Left Alt  Dash
F1        Toggle infinite stamina
F2        Change player skin
```

Current focus:

> Verify movement + animation + depth presentation before adding larger gameplay systems.
