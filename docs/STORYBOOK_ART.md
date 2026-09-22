# Storybook artwork implementation — 2026-09-21

The six user-supplied Cryptid Camp reference sheets establish the character identities and the cozy nighttime forest direction. Original game-ready bitmap assets were generated with OpenAI image generation and copied unchanged into `art/storybook/`. No reference-sheet text or layout is used as game UI.

## Asset and prompt record

The following describes the generation briefs used, rather than promising reproducible identical images. All prompts requested polished painterly storybook rendering, cream highlights, deep teal/navy forest shadows, warm amber lantern light, and no text, watermark, border, or UI.

| File | Reference and generation brief |
| --- | --- |
| sanctuary.png | Sanctuary sheet 12_38_56: portrait elevated camp clearing, cabin upper left, pond/waterfall upper right, fire right of center, winding paths and clear lower planting spaces. No creatures or signs. |
| home.png | Sanctuary/reference cast direction: portrait welcoming nighttime forest campsite, warm cabin and lanterns, open center for live title/buttons. No baked typography. |
| woods.png | Sanctuary forest direction: wide nighttime woodland clearing for the lure site and trail camera, deep blue trees, moss, rocks, warm fireflies, readable central floor. |
| mothling.png | Mothling sheet 12_39_03: full-body cream fluffy moth, red eyes, rounded taupe wings, small charcoal feet and feathery antennae. Centered isolated sprite, transparent background. |
| sprigfoot.png | Sprigfoot sheet 12_38_50: friendly brown furry forest giant with moss, leaves, mushrooms and daisies, gentle face, full body, isolated transparent background. |
| stilts.png | Stilts sheet 12_38_38: cream shaggy nightcrawler with tiny head/body, black oval eyes and two exceptionally long legs, full body including feet, isolated transparent background. |
| scraps.png | Scraps sheet 12_38_32: cute rust-red Jersey Devil, large ears, cream horns, bat wings, curled tail and dark hooves, isolated full body on transparency. |
| glimmer.png | Glimmer sheet 12_38_25: small mysterious spirit in layered plum/olive woodland cloak, dark face with two amber glowing eyes, gentle firefly glow, isolated full body on transparency. |
| wood.png | Reference wooden signs: blank warm brown three-plank horizontal wooden sign with hand-painted grain, irregular edges and subtle nails, transparent exterior. |
| decorations.png | Consistent isolated 3-by-2 prop atlas, six equal 512px cells: lantern, mushroom stool, flowers / moss cushion, hanging wind chimes, star-pattern blanket. Transparent background, no labels. |

Source references are the six `Codex Image Sep 21, 2026` PNGs supplied from the user's Downloads folder. Generation outputs were produced in this task's generated_images directory and preserved as the versioned PNGs above. Character texture transparency is retained; decorations use clipped AtlasTexture regions, not manually cut or altered raster files.

Patrick Hand is bundled in `art/fonts/PatrickHand-Regular.ttf`, obtained from the official Google Fonts repository. Its SIL Open Font License is included as `art/fonts/OFL.txt`. Small journal body text uses Godot's fallback font for readability.

## Integration

- Semantic art manifest and cached registry serve all shared desktop/web scenes. The registry also supports atlas-region definitions.
- Home and Whispering Woods use new environment art. Sanctuary uses an illustrated background with resident/decorations drawn separately; navigation, cabin/pond/fire interactions and decoration plots align to that art.
- Wood-textured buttons and title signage, cream handwriting, forest-colored panels, and visible focus outlines update the shared theme.
- Mothling portraits update adoption, sanctuary, journal and revealed trail-camera views. Discovered Sprigfoot and Stilts receive their own portraits.
- Journal includes a five-character Camp sketchbook. Scraps and Glimmer are labeled future visitors. Browsing has no progression/save side effects.
- Display names Sprigfoot/Stilts preserve existing bigfoot/nightcrawler save IDs. Encounter roster and adoption eligibility remain unchanged.
- Sprites are static illustrations with existing movement/bobbing. The reference sheets' full pose animations are not implemented.

## Verification and boundaries

Godot import/export and native storybook, adoption, smoke, first-hunt, sanctuary and decorating checks passed. Storybook tests check resource loading, all atlas regions, five portraits, small-screen copy, future-visitor labels and unchanged saves/species IDs. Native adoption and storybook checks are wired into CI; browser checks are separately runnable.

Chromium release-export review covers 320x568, 390x844 and 1280x800. Naming checks exercise typing/editing, direct touch/click focus, overlay hit testing, blank/length validation, IME submit guard, Tab, Enter and button submission, simulated keyboard-height resizing, real save updates and reload. Test fixtures use isolated saves and test-only boot interception.

Physical iOS/Android virtual keyboards, Safari and Firefox remain unverified. CJK names persist but some glyphs remain missing in game-rendered text. No additional playable encounters or full pose animation sets were added. These changes are local and uncommitted; nothing was published.
