class_name SaveManager
extends RefCounted

const SAVE_PATH := "user://cryptid_camp_save.json"

static func default_sanctuary_areas() -> Dictionary:
	return {
		"camp_clearing": {"name":"Camp Clearing","unlocked":true,"residents":[]},
		"whispering_grove": {"name":"Whispering Grove","unlocked":true,"residents":[]},
		"misty_wetlands": {"name":"Misty Wetlands","unlocked":false,"residents":[]},
		"highland_hollow": {"name":"Highland Hollow","unlocked":false,"residents":[]},
		"dusty_outpost": {"name":"Dusty Outpost","unlocked":false,"residents":[]}
	}

static func default_state() -> Dictionary:
	return {"version":2,"discovered_species":[],"evidence":{},"inventory":{},"lure_site":{"placed_objects":[]},"cryptids":[],"sanctuary_decorations":[],"sanctuary_areas":default_sanctuary_areas(),"moments":[],"research_progress":0}

static func migrate(state: Dictionary) -> Dictionary:
	if not state.has("sanctuary_areas"):
		state["sanctuary_areas"] = default_sanctuary_areas()
	state["version"] = maxi(int(state.get("version", 1)), 2)
	return state

static func save(state: Dictionary) -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(state))
	return true

static func load_state() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return default_state()
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return default_state()
	var parsed = JSON.parse_string(file.get_as_text())
	return migrate(parsed) if parsed is Dictionary else default_state()
