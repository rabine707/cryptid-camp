class_name Attraction
extends RefCounted

static func total_tags(placed_object_ids: Array[String], objects: Dictionary) -> Dictionary:
	var totals: Dictionary = {}
	for object_id in placed_object_ids:
		if not objects.has(object_id):
			continue
		for tag in objects[object_id].get("tags", {}):
			totals[tag] = totals.get(tag, 0) + int(objects[object_id]["tags"][tag])
	return totals

static func score(cryptid: Dictionary, placed_object_ids: Array[String], objects: Dictionary, context: Dictionary = {}) -> int:
	for required in cryptid.get("required_objects", []):
		if required not in placed_object_ids:
			return 0
	var tags := total_tags(placed_object_ids, objects)
	if context.get("is_night", true):
		tags["night"] = tags.get("night", 0) + 1
	# A required prop should make its intended visitor meaningfully more likely,
	# not merely eligible beside common visitors.
	var result: int = int(cryptid.get("base_weight", 0)) + cryptid.get("required_objects", []).size() * 8
	for tag in cryptid.get("preferences", {}):
		result += int(tags.get(tag, 0)) * int(cryptid["preferences"][tag])
	return max(result, 0)

static func setup_match(cryptid: Dictionary, placed_object_ids: Array[String], objects: Dictionary) -> int:
	## A readable setup-strength signal for player guidance. This intentionally
	## ignores base rarity and never exposes the visitor roll as a percentage.
	for required in cryptid.get("required_objects", []):
		if required not in placed_object_ids:
			return -1000
	var tags := total_tags(placed_object_ids, objects)
	var result: int = cryptid.get("required_objects", []).size() * 12
	for tag in cryptid.get("preferences", {}):
		result += int(tags.get(tag, 0)) * int(cryptid["preferences"][tag])
	return result
