class_name Attraction
extends RefCounted

static func total_tags(placed_object_ids: Array[String], objects: Dictionary, context: Dictionary = {}) -> Dictionary:
	var totals: Dictionary = {}
	for object_id in placed_object_ids:
		if not objects.has(object_id):
			continue
		for tag in objects[object_id].get("tags", {}):
			totals[tag] = totals.get(tag, 0) + int(objects[object_id]["tags"][tag])
	for tag in context.get("tags", {}):
		totals[tag] = totals.get(tag, 0) + int(context["tags"][tag])
	if context.get("is_night", true):
		totals["night"] = totals.get("night", 0) + 1
	return totals

static func score(cryptid: Dictionary, placed_object_ids: Array[String], objects: Dictionary, context: Dictionary = {}) -> int:
	## Ordinary cryptids never require one exact prop. Objects and weather simply
	## contribute semantic tags, so many different setups can attract a species.
	var tags := total_tags(placed_object_ids, objects, context)
	var result: int = int(cryptid.get("base_weight", 0))
	for tag in cryptid.get("preferences", {}):
		result += int(tags.get(tag, 0)) * int(cryptid["preferences"][tag])
	return max(result, 0)

static func setup_match(cryptid: Dictionary, placed_object_ids: Array[String], objects: Dictionary, context: Dictionary = {}) -> int:
	## Player-facing setup strength ignores rarity/base weight and exact recipes.
	var tags := total_tags(placed_object_ids, objects, context)
	var result := 0
	for tag in cryptid.get("preferences", {}):
		result += int(tags.get(tag, 0)) * int(cryptid["preferences"][tag])
	return result

static func setup_band(value: int) -> String:
	if value <= 0:
		return "none"
	if value <= 3:
		return "weak"
	if value <= 7:
		return "promising"
	if value <= 12:
		return "strong"
	return "exceptional"
