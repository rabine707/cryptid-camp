extends RefCounted
## Stable IDs are save contracts; labels and art may change independently.
const PLOTS := ["garden_left", "garden_right"]
const ITEMS := {
	"mushroom_stool": {"name": "Mushroom Stool", "detail": "A tiny throne for a very important moth.", "action": "Perching proudly", "moment": "tiny_throne", "title": "Tiny Throne", "memory": "A small mushroom. An enormous sense of importance."},
	"flower_patch": {"name": "Flower Patch", "detail": "Soft petals for a curious little nose.", "action": "Sniffing the flowers", "moment": "petal_hello", "title": "Petal Hello", "memory": "One careful sniff, and a new friendship with a flower."},
	"moss_cushion": {"name": "Moss Cushion", "detail": "Somewhere soft to fold those wings.", "action": "Taking a little nap", "moment": "little_nap", "title": "Little Nap", "memory": "Wings folded. Eyes closed. Finally, somewhere safe."},
	"wind_chimes": {"name": "Wind Chimes", "detail": "A little dance in the evening breeze.", "action": "Swaying with the chimes", "moment": "quiet_duet", "title": "Quiet Duet", "memory": "The chimes swayed. A tiny pair of wings swayed back."},
	"star_blanket": {"name": "Stargazer Blanket", "detail": "A patch of sky, stitched just for camp.", "action": "Watching for a falling star", "moment": "star_watch", "title": "Star Watch", "memory": "For a moment, even the busiest little moth stood still."}
}
const WARM_GLOW := {"title": "Warm Glow", "memory": "A favorite light. A familiar little friend.", "detail": "A warm lamp might catch a Mothling's attention."}

static func plot_name(plot: String) -> String:
	return "Fern Corner" if plot == "garden_left" else "Meadow Corner"

static func clean_plots(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	if value is Dictionary:
		for plot in PLOTS:
			var item := str(value.get(plot, ""))
			if ITEMS.has(item): result[plot] = item
	return result
