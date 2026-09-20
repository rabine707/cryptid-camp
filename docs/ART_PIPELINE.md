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
