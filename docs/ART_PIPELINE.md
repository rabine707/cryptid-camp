# Art Pipeline

Cryptid Camp's prototype must not depend on any single concept-art source.

## Rule

Gameplay scenes reference semantic art slots through `ArtRegistry`. If an asset does not exist yet, the game uses simple text/shape placeholders. This lets us replace concept visuals with commissioned or licensed production art without rewriting gameplay.

## Visual direction

- Cozy illustrated field guide
- National-park / campground signage
- Warm lantern light against cool moonlit forests
- Handmade, tactile UI
- Cute folklore silhouettes that remain recognizable
- Large readable shapes for phones

## Production asset requirements

Preferred source: layered PNG/PSD/Krita or SVG where appropriate.
Export transparent creature sprites as PNG.
Keep UI icons separate from backgrounds.
Do not bake labels or game text into illustrations.
Keep interaction props separate where animation is expected.

## Current production slots

See `data/art_manifest.json`.

The files listed there intentionally do not need to exist during prototype development. Missing assets fall back safely.

## Handoff

An artist should be able to replace an asset at the manifest path, import it in Godot, and see it appear without changing lure logic, trust, saves, encounters, or progression.

## Sanctuary campground placeholders

The Sanctuary uses Godot vector scenery and UI with replaceable resident art.
The illustrated art pass supplies a generated Mothling PNG; there is no runtime
art service. See `ILLUSTRATED_ART.md` for asset provenance and prompts.
`scripts/sanctuary/camp_world.gd` owns presentation
and one waypoint movement controller. `scripts/sanctuary/sanctuary.gd` owns UI
and calls the existing GameState save methods. The save format is unchanged.

All layout uses a 360 x 380 logical world scaled inside the portrait UI. Each
prop and the resident are sorted by their ground-contact Y coordinate. Human
art can replace any one placeholder through the manifest without affecting
movement, saves, or interactions. Textures are cached once and fitted with
preserved aspect ratio; missing files safely retain vector placeholders.

| Manifest slot | Logical artwork box | Notes |
| --- | --- | --- |
| background.sanctuary | 360 x 380 | Ground, paths and fence only; leave dynamic props and decoration plots out. |
| scenery.sanctuary.cabin | 140 x 109 | Transparent canvas; bottom edge at the cabin steps. |
| scenery.sanctuary.pine | 56 x 83 | Transparent tree; trunk near bottom, reused at varying scales. |
| scenery.sanctuary.pond | 87 x 65 | Water, bank, reeds and pads. |
| scenery.sanctuary.campfire | 48 x 49 | Fire and stone circle; transparent surrounding space. |
| decoration.old_lamp | 24 x 40 | Lantern and stand; the world still draws its warm light. |
| cryptid.mothling.<variant> | 48 x 46 | Feet 4 units above the bottom; shadow and heart remain separate. |

Use these aspect ratios and transparent padding to preserve alignment. Export
at 3x size or greater for the project's 1080 x 1920 canvas. Resident variant
slots fall back to classic art, then to a vector Mothling. Current replacement
sprites are static textures with procedural bobbing; a future animated sprite
can be connected at `_creature()` without changing the movement controller.
Background replacement does not include dynamic trees, cabin, pond, fire or lamp.

The two garden plots now accept five free decorations. `decor_catalog.gd` owns
stable item/moment IDs and copy; `decoration_art.gd` shares each vector drawing
between the world and the picker. Replace `decoration.mushroom_stool`,
`decoration.flower_patch`, `decoration.moss_cushion`, `decoration.wind_chimes` or
`decoration.star_blanket` through the manifest. Each uses a transparent 64 x 64
logical canvas with its ground contact at (32, 48); export at least 192 x 192.
Preserve transparent padding because the picker and world use the same asset.
The resident's perch offset is 22 logical units above the Mushroom Stool's base.
The old lamp remains its own permanent decoration and interaction.

The world emits `decoration_enjoyed` after three seconds at a placed item;
the Sanctuary controller alone records its moment. Replacing/removing furniture
cancels unfinished reactions. Animation state is transient, plot assignments
and discovered moments are saved. Human-made textures change no save contracts.
