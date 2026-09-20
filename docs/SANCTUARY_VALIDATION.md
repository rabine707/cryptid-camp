# Sanctuary validation

Use Godot 4.x (validated with 4.7.2, Compatibility renderer). The project retains
its 1080 x 1920 logical canvas and 360 x 640 portrait test window.

## Run automated checks on Windows

Run from the project directory. Point `$godot` at your Godot console executable.
The dedicated test data directory is important: these checks intentionally write
fixture saves, and refuse to run against the normal player save location.

```powershell
$godot = 'C:\path\to\Godot_console.exe'
$previousAppData = $env:APPDATA
$testData = Join-Path ([IO.Path]::GetTempPath()) 'cryptid-camp-tests'
New-Item -ItemType Directory -Force $testData | Out-Null
$env:APPDATA = (Resolve-Path $testData).Path
try {
    & $godot --headless --path . --editor --import --quit
    & $godot --headless --path . --script tests/smoke_test.gd
    & $godot --headless --path . --script tests/sanctuary_test.gd
    & $godot --headless --path . --script tests/decorating_test.gd
} finally {
    $env:APPDATA = $previousAppData
}
```

To capture the actual renderer, run the Sanctuary test without `--headless`,
adding `-- --capture=C:/existing/output/folder`. It saves three 360 x 640 PNGs:
empty camp, a resident before lamp placement, and the restored Warm Glow state.
Keep the isolated APPDATA setting for this run too. Resolve APPDATA to an
absolute, normalized path so the renderer can create its shader cache.

Coverage includes saved lowercase name and every individual field, disk reload,
empty camp, wandering before and after Warm Glow, safe routes around scenery,
repeat lamp requests, unlock on arrival, interrupted arrival recovery, legacy
Warm Glow-only saves, pond/plots/resident taps, replacement texture rendering,
portrait bounds, 44-pixel lamp target and navigation to/from the existing map.

## Manual play check

1. Pull origin, reload the project in Godot, and Play.
2. Open Sanctuary. Existing residents and Warm Glow should appear immediately.
3. Watch the resident pause, wander and return to the lamp. Tap the resident.
4. Tap the pond, campfire or cabin for small details. Tap either garden plot to
   open its decoration picker, or use Decorate camp.
5. Use Visit the Old Lamp, then leave through Map while the resident is walking.
6. Re-enter Sanctuary and confirm the same saved individual and lamp remain.
7. With a separate fresh save, invite a resident and place the Old Lamp. Warm
   Glow should unlock when the resident reaches it, once only.

8. Place a Moss Cushion in one corner and flowers in the other. Watch the resident
   approach, react, and discover Little Nap or Petal Hello after settling in.
9. Swap decorations, clear a corner, revisit the Old Lamp, and open Moments.
   Collected moments must remain even after their decoration is removed.

No save reset or migration is needed for existing players. The additive optional
`sanctuary_plots` dictionary stores `garden_left` and `garden_right` item IDs.
Missing/unknown plot data safely appears empty. The existing decoration array
still owns `old_lamp`; the existing moments array holds Warm Glow and the new
`tiny_throne`, `petal_hello`, `little_nap`, `quiet_duet` and `star_watch` IDs.

`decorating_test.gd` adds actual pointer-driven picker/slot/scroll/card/clear/album
checks, Escape dismissal, empty-camp placement, disk restoration, all five
arrival-and-dwell reactions, no premature/duplicate moments, replacement during
a reaction, removal during travel, invalid data handling, autonomous visits to
both corners, and leaving/re-entering camp while a decoration visit is pending.
Run it with the same `--capture` option to generate picker, album, perch and nap
screenshots. Tests use a seeded resident fixture, never the player's live save.
