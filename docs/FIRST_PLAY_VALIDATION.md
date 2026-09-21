# First-play / Trail Cam validation

The Trail Cam remains `scenes/trail_cam/trail_cam.tscn`, driven by
`scripts/trail_cam/trail_cam.gd`. Desktop and web use the same scenes and scripts.
`night_vision.gd` draws the camera feed without emoji or external textures.

## Player flow

- A new player is prompted to place a Lantern. The first observation guarantees
  Mothling so lure probabilities cannot strand the tutorial.
- Camera evidence is collected explicitly. Red eyes leave two candidates; wings
  narrow the list; watching the lantern confirms the identification.
- An alternate investigation provides a recovery hint without losing evidence.
- Identification adds the species to the existing Field Journal collection. For
  Mothling it unlocks the existing trust encounter, adoption at 80 trust, and
  sanctuary progression. Beans is a suggested name/milestone, not currency.
- The second observation has a short contextual hint. Later observations use
  normal attraction and investigation. Bigfoot/Nightcrawler can be documented
  and identified, but their trust/adoption encounters remain outside this milestone.

## Save compatibility

Existing JSON keys and evidence IDs are retained. `guided_hunts` is an optional
counter: existing discoveries or individuals skip first-play guidance; missing
counters in established saves skip second-hunt guidance too. Recorded clues
resume the first investigation after reopening and observing again. Repeated
identification cannot duplicate collection entries. No trust, names, variants,
residents, decorations or moments are reset. Tests use isolated save directories.

## Automated checks

Use Godot 4.3 (matching Build and Deploy Godot Web). Set APPDATA on Windows or
XDG_DATA_HOME on Linux to a disposable directory containing `cryptid-camp-tests`.
Never point these tests at a player profile.

```
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/smoke_test.gd
godot --headless --path . --script res://tests/first_hunt_test.gd
godot --headless --path . --script res://tests/sanctuary_test.gd
godot --headless --path . --script res://tests/decorating_test.gd
godot --headless --path . --export-release Web build/web/index.html
```

The existing Pages workflow now runs all four suites before uploading the build.
For actual Godot viewport captures, run first_hunt_test.gd without `--headless`
and append `-- --capture=<absolute existing directory>`.

## Browser review checklist

Serve build/web over HTTP. Start in a fresh isolated browser profile, place a
Lantern, collect evidence, try the alternate investigation, follow the eyes,
watch the lantern, identify, open the Journal and meet Mothling. Check a reload
preserves clues/discovery, the second hunt has a lighter hint, and small portrait
and desktop viewports retain usable buttons. Check the browser error log.
