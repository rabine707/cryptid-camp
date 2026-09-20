class_name SaveManager
extends RefCounted

const SAVE_PATH := "user://cryptid_camp_save.json"

static func default_state() -> Dictionary:
	return {"version":1,"discovered_species":[],"evidence":{},"inventory":{},"lure_site":{"placed_objects":[]},"cryptids":[],"sanctuary_decorations":[],"moments":[],"research_progress":0}

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
	return parsed if parsed is Dictionary else default_state()
