extends Control

const OBJECTS_PATH := "res://data/lure_objects.json"
const CRYPTIDS_PATH := "res://data/cryptids.json"
const MAX_OBJECTS := 6
const STARTER_OBJECTS := ["pine_tree", "berry_bush", "hollow_log", "lantern", "old_radio", "camping_chair"]

var object_defs: Dictionary = {}
var cryptid_defs: Dictionary = {}
var placed_objects: Array[String] = []
var rng := RandomNumberGenerator.new()

@onready var clearing: GridContainer = $Margin/VBox/ClearingPanel/ClearingMargin/Clearing
@onready var inventory: HFlowContainer = $Margin/VBox/Inventory
@onready var status: Label = $Margin/VBox/Status
@onready var observe_button: Button = $Margin/VBox/Observe

func _ready() -> void:
	rng.randomize()
	object_defs = _load_json(OBJECTS_PATH)
	cryptid_defs = _load_json(CRYPTIDS_PATH)
	placed_objects = GameState.get_lure_objects()
	$Margin/VBox/Header/Back.pressed.connect(_go_back)
	observe_button.pressed.connect(_begin_observation)
	CampStyle.button($Margin/VBox/Header/Back, "wood")
	CampStyle.button(observe_button, "green")
	CampStyle.parchment($Margin/VBox/ClearingPanel)
	var clearing_panel := $Margin/VBox/ClearingPanel
	clearing_panel.add_theme_stylebox_override("panel", CampStyle.panel(Color("10251e"), 18, 3, Color("647252")))
	var landscape := TextureRect.new()
	landscape.texture = ArtRegistry.texture_for("background.whispering_woods")
	landscape.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	landscape.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	landscape.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clearing_panel.add_child(landscape)
	clearing_panel.move_child(landscape, 0)
	_build_clearing()
	_build_inventory()
	_refresh()
	if GameState.needs_first_hunt():
		$Margin/VBox/Hint.text = "Your first visitor: place a Lantern, then watch the Trail Cam. Light draws curious creatures out of hiding."

func _load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open " + path)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

func _build_clearing() -> void:
	for i in range(MAX_OBJECTS):
		var slot := Button.new()
		slot.custom_minimum_size = Vector2(0, 205)
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.name = "Slot%d" % i
		slot.pressed.connect(_remove_from_slot.bind(i))
		CampStyle.button(slot, "paper")
		slot.add_theme_stylebox_override("normal", CampStyle.panel(Color(0.025, 0.085, 0.065, 0.78), 14, 2, Color("869175")))
		slot.add_theme_color_override("font_color", Color("f0e4c5"))
		slot.add_theme_font_size_override("font_size", 32)
		clearing.add_child(slot)

func _build_inventory() -> void:
	for object_id in STARTER_OBJECTS:
		var button := Button.new()
		button.custom_minimum_size = Vector2(310, 150)
		button.text = str(object_defs.get(object_id, {}).get("name", object_id))
		button.pressed.connect(_place_object.bind(object_id))
		CampStyle.button(button, "wood")
		button.add_theme_font_size_override("font_size", 32)
		if object_id == "lantern" and GameState.needs_first_hunt():
			CampStyle.button(button, "green")
		inventory.add_child(button)

func _place_object(object_id: String) -> void:
	if placed_objects.size() >= MAX_OBJECTS:
		status.text = "The clearing is full. Tap an object above to pack it up."
		return
	placed_objects.append(object_id)
	GameState.set_lure_objects(placed_objects)
	_refresh()

func _remove_from_slot(index: int) -> void:
	if index >= placed_objects.size():
		return
	placed_objects.remove_at(index)
	GameState.set_lure_objects(placed_objects)
	_refresh()

func _refresh() -> void:
	for i in range(MAX_OBJECTS):
		var slot := clearing.get_child(i) as Button
		if i < placed_objects.size():
			var id := placed_objects[i]
			slot.text = str(object_defs.get(id, {}).get("name", id))
		else:
			slot.text = "+\nEmpty"
	observe_button.disabled = placed_objects.is_empty()
	if placed_objects.is_empty():
		status.text = "Place a few things and see what notices."
	else:
		status.text = "%d / %d objects placed. Your clearing stays deployed between visits." % [placed_objects.size(), MAX_OBJECTS]
	if GameState.needs_first_hunt():
		observe_button.disabled = "lantern" not in placed_objects
		status.text = "Lantern ready. Watch for movement on the Trail Cam." if "lantern" in placed_objects else "Tap Lantern in your Field Kit. If the clearing is full, tap a placed object to pack it up."
		observe_button.text = "Watch the Trail Cam"

func _begin_observation() -> void:
	var scores: Dictionary = {}
	for cryptid_id in cryptid_defs:
		scores[cryptid_id] = Attraction.score(cryptid_defs[cryptid_id], placed_objects, object_defs, {"is_night": true})
	var visitor := Observation.choose_visitor(scores, rng)
	if GameState.needs_first_hunt():
		visitor = "mothling"
	GameState.begin_hunt()
	var events := Observation.generate_events(visitor, rng)
	TrailCamSession.events = events
	TrailCamSession.visitor_id = visitor
	TrailCamSession.placed_objects = placed_objects.duplicate()
	get_tree().change_scene_to_file("res://scenes/trail_cam/trail_cam.tscn")

func _go_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
