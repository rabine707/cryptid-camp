# Illustrated art pass

Generated using the built-in image-generation tool, September 2026, at the user's request.
All images are separate from live UI text and input controls. Gameplay and saves are unchanged.
Original generated PNGs are stored unchanged; Godot imports them for both desktop and web.

## Assets

- `art/backgrounds/main_menu.png`: 1024 x 1536 RGB. Home painting; subtle fireflies and legibility gradients are drawn separately by Godot.
- `art/backgrounds/whispering_woods.png`: 1536 x 1024 RGB. Empty clearing; interactive lure slots remain separate. Also tinted by the camera renderer for night vision.
- `art/cryptids/mothling/classic.png`: 1254 x 1254 RGBA with verified alpha 0-255. Used by encounter, journal and adoption portraits, and the existing sanctuary resident art slot. Existing variant slots fall back to classic until variant art is supplied.

All are referenced through ArtRegistry semantic slots. Missing creature art retains the vector fallback. No AI service is called at runtime.

## Final generation prompts

### Main menu

Use case: illustration-story. Create a polished production game background for Cryptid Camp, a cozy-creepy folklore creature collecting game. Portrait 2:3 composition. Hand-painted richly textured illustrated indie-game key art, sophisticated picture-book gouache with crisp readable silhouettes, deep midnight teal and spruce green, warm amber lantern light, subdued cream moon. A small welcoming woodland campsite in towering pine woods at night, rustic little cabin with glowing windows on the mid-right, canvas tent on mid-left, a small stone-ring campfire and a winding path in the lower middle, ferns and mushrooms at edges, distant layered misty mountains. Tiny mysterious red eye pair barely visible deep between trees, no visible full monsters. Magical and a little eerie, cozy rather than horror. Composition for mobile main menu: top 25 percent mostly dark quiet night sky framed by pines, central 50 percent beautiful environment focal scene, bottom 25 percent dark simple foreground with very little detail to support overlaid navigation. No text, no lettering, no logo, no buttons, no interface, no watermark. Full bleed finished illustration, not a mockup. Strong art direction and depth, no generic vector shapes, no flat clip art.

### Whispering Woods

Use case: illustration-story. Production background illustration for the Whispering Woods location in Cryptid Camp, a cozy-creepy woodland creature collecting game. Landscape 3:2. Beautiful hand painted gouache indie game environment with refined tactile details and readable mobile silhouettes. A secluded empty mossy clearing in an ancient pine forest at midnight, deep spruce green and blue teal, cool silver moonbeams through tall trunks, atmospheric fog behind trees, ferns and tiny mushrooms at the lower corners, faint amber firefly specks. Eye-level view slightly looking down at a wide oval open grassy clearing occupying the lower center, path leading into distant dark trees. Central and lower clearing remains empty for separately rendered interactive lure objects. No cabin, no tent, no campfire, no lantern, no creatures, no red eyes. Strong cinematic depth, eerie but inviting. No text, logos, UI, labels, frame, or watermark. Full bleed art asset, not a screenshot or mockup.

### Mothling

Use case: illustration-story. Create a production transparent PNG creature sprite for Cryptid Camp, a cozy-creepy hand-painted woodland game. Single Mothling, full body facing forward, centered, isolated on a genuinely transparent alpha background. Adorable small cryptid resembling a fluffy moth owl: round oatmeal cream fluffy body, short tiny two feet at bottom, short fuzzy antennae, two large friendly glowing coral-red eyes with dark pupils and small highlights, tiny smiling mouth, broad symmetrical sage and deep olive moth wings opened to either side with understated tan eyespot patterns, tactile feathery edges. Cute, curious and a little mysterious, a huggable woodland friend rather than frightening Mothman. Refined hand-painted gouache with natural delicate fur detail and a clear silhouette that reads at 48px. Wings not clipped. Body centered at 50 percent width, feet at 88 percent height, total creature including wings fills 85 percent of a square canvas, ample transparent padding. Soft warm light from left, subtle cool moonlit rim. No scene, no floor, no cast shadow, no pedestal, no props, no labels, no lettering, no frame, no watermark, not a sheet of poses. Exactly one complete creature on transparency.
