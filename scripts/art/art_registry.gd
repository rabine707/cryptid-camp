class_name ArtRegistry
extends RefCounted

const MANIFEST_PATH := "res://data/art_manifest.json"

static var _slots: Dictionary = {}
static var _textures: Dictionary = {}

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
	var entry = _slots.get(slot, "")
	return str(entry.get("path", "")) if entry is Dictionary else str(entry)

static func texture_for(slot: String) -> Texture2D:
	if _textures.has(slot):
		return _textures[slot]
	var path := path_for(slot)
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var texture := load(path) as Texture2D
	var entry = _slots.get(slot)
	if entry is Dictionary and entry.has("region"):
		var region: Array = entry.region
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(region[0], region[1], region[2], region[3])
		atlas.filter_clip = true
		texture = atlas
	_textures[slot] = texture
	return texture
