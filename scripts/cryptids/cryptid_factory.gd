class_name CryptidFactory
extends RefCounted

const PERSONALITIES := ["Shy", "Playful", "Curious", "Mischievous"]
const QUIRKS := ["Snack Lover", "Sleepy", "Collector", "Clingy", "Camera Shy", "Adventurous"]
const SIZES := ["Tiny", "Small", "Average", "Big"]

static func create(species_id: String, rng: RandomNumberGenerator) -> Dictionary:
	var variants := ["classic"]
	if species_id == "mothling":
		variants = ["classic", "autumn", "luna"]
	return {
		"id": "%s_%s_%04d" % [species_id, str(Time.get_unix_time_from_system()), rng.randi_range(1, 9999)],
		"species": species_id,
		"name": "",
		"variant": variants[rng.randi_range(0, variants.size() - 1)],
		"size": SIZES[rng.randi_range(0, SIZES.size() - 1)],
		"personality": PERSONALITIES[rng.randi_range(0, PERSONALITIES.size() - 1)],
		"quirk": QUIRKS[rng.randi_range(0, QUIRKS.size() - 1)],
		"trust": 0,
		"adopted": false,
		"encounter_count": 1,
		"encounter_history": [int(Time.get_unix_time_from_system())]
	}

static func trust_stage(trust: int) -> String:
	if trust >= 100: return "Family"
	if trust >= 80: return "Bonded"
	if trust >= 60: return "Friendly"
	if trust >= 40: return "Comfortable"
	if trust >= 20: return "Curious"
	return "Wary"
