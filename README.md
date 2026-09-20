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
pond, campfire, future garden plots and a wandering Mothling. Tap world details
or visit the Old Lamp. Warm Glow unlocks on arrival and survives returning to
camp. Existing resident saves require no reset. See
`docs/SANCTUARY_VALIDATION.md` for isolated tests and portrait capture instructions.
