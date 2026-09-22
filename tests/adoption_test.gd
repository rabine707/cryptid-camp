extends SceneTree

var failures := 0
var game: Node

func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error("FAIL: " + description)
	else:
		print("PASS: " + description)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	if not OS.get_user_data_dir().contains("cryptid-camp-tests"):
		push_error("Use isolated APPDATA/XDG_DATA_HOME containing cryptid-camp-tests.")
		quit(1)
		return
	game = root.get_node("GameState")
	game.state = SaveManager.default_state()
	var rng := RandomNumberGenerator.new()
	rng.seed = 707
	var wild: Dictionary = game.ensure_wild_individual("mothling", rng)
	game.set_trust(wild.id, 80)
	var identity: Dictionary = wild.duplicate(true)
	root.size = Vector2i(390, 844)
	root.content_scale_size = Vector2i(1080, 1920)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	var scene = load("res://scenes/adoption/adopt_mothling.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await process_frame
	var field: LineEdit = scene.name_input
	field.grab_focus()
	var key := InputEventKey.new()
	key.pressed = true
	key.keycode = KEY_B
	key.unicode = 66
	root.push_input(key)
	check(field.text == "B", "keyboard event types in the focused name field")
	field.text = "   "
	scene._welcome_home()
	check(not wild.adopted and field.has_focus(), "blank submission preserves wild resident and restores focus")
	check(not scene.message.text.is_empty(), "blank name shows validation message")
	field.text = "  Luna 🦋  "
	key.keycode = KEY_ENTER
	key.unicode = 13
	root.push_input(key)
	await process_frame
	await process_frame
	var resident: Dictionary = game.get_adopted_species("mothling")
	check(resident.get("name") == "Luna 🦋", "Enter adopts once with trimmed Unicode name")
	check(current_scene.scene_file_path.ends_with("sanctuary.tscn"), "successful submit opens sanctuary")
	for property in ["id", "trust", "personality", "quirk", "variant"]:
		check(resident.get(property) == identity.get(property), "adoption preserves " + property)
	check(SaveManager.load_state().cryptids[0].name == "Luna 🦋", "submitted name persists to disk")
	change_scene_to_file("res://scenes/adoption/adopt_mothling.tscn")
	await process_frame
	await process_frame
	check(current_scene.scene_file_path.ends_with("main.tscn"), "ineligible naming screen safely returns to map")
	print("ADOPTION FAILURES: ", failures)
	quit(1 if failures else 0)
