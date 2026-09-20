class_name ArtRegistry
extends RefCounted

const MANIFEST_PATH := "res://data/art_manifest.json"

static var _slots: Dictionary = {}

static func _ensure_loaded() -> void:
	if not _slots.is_empty():
		return
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_slots = parsed.get("slots", {})

static func path_for(slot: String) -> String:
	_ensure_loaded()
	return str(_slots.get(slot, ""))

static func texture_for(slot: String) -> Texture2D:
	var path := path_for(slot)
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D
