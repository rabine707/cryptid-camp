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
4. Tap the pond, campfire, cabin and two future garden plots for small details.
5. Use Visit the Old Lamp, then leave through Map while the resident is walking.
6. Re-enter Sanctuary and confirm the same saved individual and lamp remain.
7. With a separate fresh save, invite a resident and place the Old Lamp. Warm
   Glow should unlock when the resident reaches it, once only.

No save reset or migration is needed for existing players. Only the existing
`old_lamp` decoration and `warm_glow` moment are written by the Sanctuary.
