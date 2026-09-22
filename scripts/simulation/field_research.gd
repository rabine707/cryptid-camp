class_name FieldResearch
extends RefCounted
## Stable evidence IDs extend the existing save; no reset or currency migration.
const NAMES := {"mothling": "Mothling", "bigfoot": "Sprigfoot", "nightcrawler": "Stilts"}
const CLUES := {
	"red_eyes": {"label": "Red eyes beside the light", "matches": ["mothling", "bigfoot"]},
	"wing_shadow": {"label": "A small, wing-shaped shadow", "matches": ["mothling"]},
	"light_fascination": {"label": "It keeps returning to the lantern", "matches": ["mothling"]},
	"footprint": {"label": "Large footprints in the soil", "matches": ["bigfoot", "nightcrawler"]},
	"wood_knock": {"label": "Wood knocking beyond the berry bush", "matches": ["bigfoot"]},
	"pale_shape": {"label": "A tall pale shape on open ground", "matches": ["nightcrawler", "mothling"]},
	"long_stride": {"label": "Two long legs stride past the chair", "matches": ["nightcrawler"]}
}
const TRAILS := {"mothling": ["red_eyes", "wing_shadow", "light_fascination"], "bigfoot": ["footprint", "wood_knock"], "nightcrawler": ["pale_shape", "long_stride"]}

static func candidates(evidence: Array) -> Array:
	var possible: Array = NAMES.keys()
	for clue in evidence:
		if not CLUES.has(clue):
			continue
		for species in possible.duplicate():
			if species not in CLUES[clue].matches:
				possible.erase(species)
	return possible

static func next_clue(species: String, evidence: Array) -> String:
	for clue in TRAILS.get(species, []):
		if clue not in evidence:
			return clue
	return ""

static func can_identify(species: String, evidence: Array) -> bool:
	return TRAILS.has(species) and next_clue(species, evidence).is_empty() and candidates(evidence) == [species]
