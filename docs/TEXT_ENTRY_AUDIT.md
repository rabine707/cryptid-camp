# Cryptid Camp text-entry audit — 2026-09-21

Implemented locally on `fix/text-entry-audit`, based on fetched `origin/main` at `a9eae9f`. No commit, push, PR, or deployment was performed. Existing older checkouts and their uncommitted work were preserved.

## Scope and findings

The current main branch has one editable text control: the Mothling adoption name. The scene, game input handlers, decorative layers, and web export settings were inspected. There are no other text fields, chat boxes, account forms, or rename screens in this version. A separate older dirty checkout contains an experimental cloud/save wrapper; it is not part of the current main branch and was not changed.

Main already enabled Godot's experimental web keyboard and manually called keyboard-show from both pointer and focus handlers. This still depends on a canvas-to-hidden-input handoff. An unmerged HTML-input branch was inspected but not merged. This fix makes the visible field itself a native browser input, so a touch goes directly to the element that accepts text. Godot documents the experimental keyboard option in its [web export reference](https://docs.godotengine.org/en/stable/classes/class_editorexportplatformweb.html); engine reports also describe [keyboard overlap and Enter limitations](https://github.com/godotengine/godot/issues/76215).

## Exact changes

| File | Change |
| --- | --- |
| `web/name-entry.js` | Added a labeled native HTML form for web naming. Supports direct click/touch focus, standard editing and selection, Enter or button submission, Tab navigation, composition-aware submission, inline accessible errors, and duplicate-submit prevention. Rejects blank/whitespace-only and over-20-character names; counts Unicode code points. Tracks visual viewport size/offset for keyboard resizing, accounts for the portrait game's letterboxing, uses 48px controls and 18px input text, and removes listeners/form on exit. Restores the canvas tab index and focus when appropriate. |
| `scripts/adoption/adopt_mothling.gd` | Connects the browser form to the existing adoption/save method. Disables duplicate canvas controls only on web. Removes redundant manual keyboard-show handlers; native builds retain Godot's built-in LineEdit keyboard behavior. Adds desktop native focus, validation/refocus, a submission guard, cleanup on exit, and deferred scene navigation when no eligible Mothling exists. Preserves the resident dictionary if adoption fails. |
| `scenes/adoption/adopt_mothling.tscn` | Makes the background ignore pointer input; increases native input/button height from 100/110 to 144 design pixels and input text from 32 to 48. |
| `export_presets.cfg` | Includes the new JavaScript resource in web exports. |
| `tests/adoption_test.gd` | Adds native engine regression coverage for real typing, blank validation/focus, Enter, trimmed Unicode names, persistent identity/save, and the ineligible-scene guard. Requires an isolated test save directory. |
| `tests/web-entry.test.cjs` | Adds isolated Chromium browser regression tests against an actual release export. Seeds a bonded Mothling in a fresh browser context and changes only the test HTML boot scene, bypassing the trust grind; production gets no fixture/debug hook. |
| `.github/workflows/godot-validation.yml` | Adds the native adoption regression test to CI. Browser tests remain a separately runnable check requiring Playwright/Chromium. |

## Verified

- Godot 4.3 asset import and release web export succeeded. The restricted Windows host prints a root certificate-store warning; no script/compile errors occurred.
- Existing smoke, first-hunt, sanctuary, and decorating test suites passed.
- New native adoption test passed, including saved name and resident identity preservation.
- Chromium desktop **1280 × 800**, touch/mobile **390 × 844**, and touch/mobile **320 × 568** passed against the final build.
- Browser checks cover direct focus, hit testing for intercepting overlays, typed characters, arrow/backspace caret editing, replacing/clearing text, blank submission, 21-character rejection, IME composition suppression, Tab to submit, Enter submission, touch-button submission, real adoption, saved name/id/trust, and reload persistence.
- Mobile tests reduce viewport height to **320px** and confirm both the name field and submit button remain visible. This is a layout simulation, not a real virtual keyboard.
- Final screenshots were visually inspected, including desktop alignment, small mobile, reduced-height form, and sanctuary after adoption. Final browser runs reported **zero page/console errors**.
- The naming form is removed after adoption and absent after reload; the existing sanctuary renders normally.

## Still needs attention

1. **Real-device keyboard verification:** physical iPhone Safari and Android Chrome keyboard activation, IME candidates, predictive text, orientation changes, keyboard dismissal/reopening, and Done-key behavior have not been tested. Desktop touch emulation cannot establish these. The direct native-input approach removes the previous focus handoff, but does not replace device verification.
2. **Unicode font coverage:** names such as `月光 Beans` survive submission/save/reload, but the current Godot game font renders some CJK characters as missing-glyph boxes in the sanctuary. The native HTML input displays them correctly. A separate font fallback/asset change is needed for full Unicode display in the game.
3. **Release:** these changes are local and uncommitted. The published game has not changed. No claim is made about deployed behavior or Safari/Firefox compatibility.

## Reproduce

Export with Godot 4.3 to `build/web/index.html`, then serve `build/web` on localhost port 8943. Run `node tests/web-entry.test.cjs` with Playwright installed. Optional environment variables: `PLAYWRIGHT_MODULE` (module path), `CHROME_PATH`, `CAMP_TEST_URL`, and `CAMP_TEST_OUTPUT`. Screenshots and `results.json` default to `build/input-audit`.

For native tests, set `APPDATA` on Windows or `XDG_DATA_HOME` on Linux to an isolated directory containing `cryptid-camp-tests`, then run `godot --headless --path . --script res://tests/adoption_test.gd`. Do not point test runs at a player's save directory.
