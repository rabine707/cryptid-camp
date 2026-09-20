# Cryptid Camp 🌲🦋

A cozy mobile creature-collector about building temporary **Lure Sites**, discovering adorable cryptids, earning their trust, and inviting them home to a permanent **Sanctuary**.

> **Design rule:** Cryptids are discovered through curiosity, not instructions.

## v0.0.1 — Beans

The first playable milestone proves one complete loop: enter Whispering Woods, place lure objects, observe, review Trail Cam evidence, discover and befriend a persistent Mothling, invite it home, name it, and unlock **Warm Glow** when it hugs a lamp.

No combat, gacha, accounts, multiplayer, or store in this milestone.

## Tech

- Godot 4.x + GDScript
- Portrait-first mobile UI
- Local JSON save
- Data-driven lure objects and cryptids
- Simulation separated from presentation

See `docs/GAME_DESIGN.md` and `docs/BEANS_MILESTONE.md`.


## Art pipeline

Prototype visuals are deliberately replaceable. Gameplay references semantic art slots, with safe placeholders until production artwork exists. See `docs/ART_PIPELINE.md` and `data/art_manifest.json`.

## Sanctuary campground

Sanctuary now has a vector campground with a lit cabin, paths, perimeter pines,
pond, campfire, two decoration corners and a wandering Mothling. Tap world details
or visit the Old Lamp. Warm Glow unlocks on arrival and survives returning to
camp. Existing resident saves require no reset. See
`docs/SANCTUARY_VALIDATION.md` for isolated tests and portrait capture instructions.

### Make it yours

Open **Decorate camp** or tap a garden corner. Choose from five free items:
Mushroom Stool, Flower Patch, Moss Cushion, Wind Chimes and Stargazer Blanket.
Place, replace or clear either corner; changes save immediately. Your resident
walks over to investigate, then continues to visit decorations independently.
Each item has its own reaction and discoverable moment. Open **Moments** to see
all six memories (including Warm Glow) and hints for those still undiscovered.

Decorating is available before adoption too, but a resident must actually enjoy
an item before its moment is discovered. No currency, waiting timers or purchases
are required. The resident, trust, lamp and existing save data remain unchanged.
