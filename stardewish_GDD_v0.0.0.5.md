# Stardew-ish Project â€” Living GDD

**Current prototype version:** v0.0.0.6
**Engine:** Godot 4.x  
**Scripting:** GDScript  
**Current phase:** movement / interaction / item-inventory prototype

## v0.0.0.6 update

The prototype now includes generic E interaction, shaking fruit trees, scattered world pickups, a configurable player inventory (16 slots by default), and a 32-slot small chest and a 64-slot large chest with supplied open/closed sprites. Bush slow terrain now consists of individual directional sprites with small base footprints. I opens player inventory; drag or click-then-place to arrange stacks, and double-click to transfer when the chest is open. Item data and drop settings are documented in README.md. Inventory and chest contents persist only during the current run.

The v0.0.0.5 design history below remains useful for movement and presentation. Interaction and basic inventory are now implemented; larger systems remain out of scope.

## 1. High-level concept

A cozy 2D game inspired by the readability, pacing, and approachable systems of games such as Stardew Valley, without committing the game to farming as its central activity.

The intended direction is:

> **2D mechanics + stronger 3/4 perspective artwork + Y-sorting**

The world remains mechanically 2D. Depth is created through taller sprites, visible front faces, shadows, walk-behind / walk-in-front layering, and Y-based draw ordering rather than a true 3D camera.

The project is deliberately being built from a small movement sandbox outward. The current priority is to make controlling the character feel good before adding larger systems.

## 2. Design principles

- **Feel first.** Movement should be tested and tuned before building content-heavy systems.
- **Keep mechanics 2D.** Do not switch to a true 3D world just to create visual depth.
- **Use 3/4 presentation.** Trees, walls, rocks, characters, buildings, etc. can show height/front faces.
- **Data-driven tuning.** Values likely to change during balancing should live in `data/game_config.json`, not be scattered as magic numbers.
- **Avoid premature architecture.** Future hooks are fine, but do not build unused systems just because they may exist later.
- **Prototype with temporary assets.** Final visual identity can come later.

## 3. Current player controls

| Action | Input |
|---|---|
| Move | WASD |
| Run | Hold Shift while moving |
| Dash | Left Alt |
| Infinite stamina debug toggle | F1 |
| Change prototype skin | F2 |
| Interact / close chest | E |
| Player inventory | I |
| Close inventory | Esc |

Movement is 8-directional.

When dashing:
- If the player is moving, dash uses the current movement direction.
- If standing still, dash uses the last facing direction.
- Dash has a stamina cost and cooldown.
- Infinite stamina disables stamina consumption but does **not** remove dash cooldown.

## 4. Current movement and stamina values

These are tuning defaults, not permanent design commitments.

| Setting | Current value |
|---|---:|
| Walk speed | 100 |
| Run speed | 170 |
| Dash speed | 340 |
| Dash duration | 0.18 s |
| Dash stamina cost | 25 |
| Dash cooldown | 0.35 s |
| Maximum stamina | 100 |
| Running stamina cost | 15 / sec |
| Stamina regeneration | 25 / sec |
| Regen delay after spending stamina | 0.75 s |

The current config lives in:

`data/game_config.json`

## 5. Terrain and collision rules

### Normal terrain
- Movement multiplier: `1.00`

### Bush terrain
- Walkable.
- Slows player movement.
- Current multiplier: `0.75`

### Rocky terrain
- Walkable.
- Slows player more strongly.
- Current multiplier: `0.55`

### Trees
- **Only the trunk/base is solid.**
- The canopy is visually tall and walk-under.
- The player should be able to disappear behind the canopy when positioned behind the tree.
- This behavior is important to the 3/4 visual direction.

### Walls / building facades
- Impassable.
- Artwork can show front faces and top lips to create height.

Terrain penalties currently affect walk, run, and dash.

## 6. Visual direction

The original prototype started very flat. The chosen direction now uses:

- mechanically flat 2D ground
- taller object sprites
- shadows beneath objects
- visible trunks / fronts / wall faces
- player origin treated approximately as the feet
- Y-based depth ordering
- player can render behind or in front of objects based on position

This is not intended to be fully isometric.

The desired visual target is closer to a **Stardew-like readable 2D world with stronger depth cues**, rather than a real 3D environment.

## 7. Current character system

The prototype now uses the supplied Lexlom character pack:

`https://lexlom.itch.io/32-character-pack-pixel-art-4-direction-idle-walking`

Runtime player sheets are stored in:

`assets/characters/villagers/`

Current setup:
- 9 runtime-compatible player skins
- each runtime sheet is `96x192`
- frame cell is `32x64`
- 3 frames per direction row
- row 0 = down/front
- row 1 = up/back
- row 2 = side
- side art is horizontally flipped for left movement

Current animation behavior:
- idle: middle frame
- walking: `[0, 1, 2, 1]`
- running: same supplied walk cycle, played faster
- dash: reuses movement frames for now

Current animation defaults:
- walk: 6 FPS
- run: 10 FPS
- dash: 14 FPS

The original `.kra` files are retained separately as editable source material:

`assets/source/characters/lexlom/`

**Asset licensing should be rechecked before any public/commercial release.** Keep attribution/license documentation with the source assets.

## 8. HUD / debug display

The prototype HUD currently shows:
- stamina
- current terrain + movement multiplier
- movement state + speed
- infinite stamina state
- selected skin
- version number
- controls reminder

The test world is still based around a `960x600` logical area. It scales with the window, while HUD elements are positioned separately against the actual viewport and scale within a capped range.

For a larger real game world, this should eventually become a normal `Camera2D` world rather than treating the entire map as a single screen-sized test course.

## 9. Data/config direction

The project currently separates balance/configuration from code.

Important current config areas:

```text
player
â”œâ”€â”€ base_stats
â”œâ”€â”€ movement
â”œâ”€â”€ stamina
â”œâ”€â”€ modifiers
â””â”€â”€ visuals

terrain
â”œâ”€â”€ normal
â”œâ”€â”€ bush
â””â”€â”€ rocks

debug

progression
â””â”€â”€ skills
    â””â”€â”€ athletics
```

The `modifiers` and `progression.skills.athletics` sections are intentionally only placeholders.

### Future rule

The intended long-term stat flow is conceptually:

`base value -> modifiers -> final value`

That allows future levels, perks, equipment, buffs, or terrain to affect movement without rewriting the movement controller.

Do **not** implement the full leveling system yet unless the project explicitly moves into that phase.

## 10. Stamina vs future Energy

A useful distinction agreed during design:

- **Stamina:** short-term physical resource for running, dashing, and potentially combat/physical abilities. Regenerates relatively quickly.
- **Energy:** possible future long-term/day resource for work actions such as chopping, mining, farming, etc.

The current system is stamina.

## 11. Future progression direction

Progression is not implemented.

A possible later structure is skill-based rather than relying only on one global player level. An **Athletics** skill was reserved as a natural home for movement/stamina-related progression.

Possible future effects might include:
- maximum stamina
- stamina efficiency
- regeneration
- run speed
- dash behavior

These are only future hooks, not committed balance design.

## 12. Current test-map purpose

The sandbox exists to exercise:
- straight walking/running
- stamina consumption/regeneration
- dash feel
- collision with walls
- diagonal corner sliding
- tree trunk vs canopy behavior
- transition into and out of slow terrain
- bush/rock movement modifiers
- basic 3/4 layering
- Y-sorting
- character animation
- window/HUD scaling

It is not intended to be a final map.

## 13. Near-term development priorities

Recommended order after verifying v0.0.0.5:

1. **Verify and tune the new character animation**
   - walk rate
   - run rate
   - sprite vertical offset
   - collision at feet
   - dash visual readability

2. **Refine depth sorting**
   - confirm player transitions cleanly in front of / behind trees and facades
   - replace ad-hoc layering if needed with a cleaner Y-sort architecture

3. **Polish the test assets**
   - bush / rock presentation
   - tree proportions
   - walls/facades
   - shadows

4. **Move from a whole-screen test course toward a proper camera/world setup**
   - `Camera2D`
   - map larger than viewport
   - HUD remains viewport-based

5. **Add a simple interaction system**
   - likely an interact action near/facing an object
   - signs, boxes, doors, NPC placeholders, etc.

The basic inventory/chest slice is implemented in v0.0.0.6. Further expansion into tools, farming, NPCs, quests, time, save data, or progression remains deferred until the current flow feels stable.

## 14. Explicitly out of scope right now

- Full farming system
- Equipment, hotbars, weight, rarity, and expanded inventory features
- Tool system
- NPC schedules
- Dialogue tree system
- Quest system
- Combat
- Save/load
- Day/night cycle
- Weather
- Finished leveling/skills
- Final art pipeline
- Final game economy

These can be designed later. The current build should remain a focused movement sandbox.
