extends SceneTree
## Run with an isolated APPDATA directory ending in cryptid-camp-tests.
## Optional --capture=<absolute folder> captures the real rendered viewport.
var failures := 0
var game: Node
var scene: Control
var capture_dir := ""

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)

func _open() -> void:
	if is_instance_valid(scene):
		scene.queue_free()
		await process_frame
	scene = load("res://scenes/sanctuary/sanctuary.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	scene.world.set_process(false)
	scene.world.rng.seed = 707

func _capture(filename: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	_check(image.get_size() == Vector2i(360, 640), "actual rendered viewport is 360 x 640")
	_check(image.save_png(capture_dir.path_join(filename)) == OK, "capture " + filename)

func _tap(point: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = point * scene.world.size / scene.world.WORLD_SIZE
	scene.world._gui_input(event)

func _run() -> void:
	if not OS.get_user_data_dir().contains("cryptid-camp-tests"):
		push_error("Use an isolated APPDATA directory named cryptid-camp-tests; never test against a player save.")
		quit(1)
		return
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			capture_dir = argument.trim_prefix("--capture=")
	root.size = Vector2i(360, 640)
	root.content_scale_size = Vector2i(1080, 1920)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	game = root.get_node("GameState")
	game.state = SaveManager.default_state()
	await _open()
	_check(scene.resident.is_empty() and scene.lamp_button.disabled, "empty camp has no invented resident and disables lamp")
	_check(scene.moment.get_global_rect().end.y <= 1920, "empty camp fits portrait canvas")
	await _capture("sanctuary-empty.png")
	var rng := RandomNumberGenerator.new()
	rng.seed = 707
	var beans := CryptidFactory.create("mothling", rng)
	beans.merge({"name": "beans", "adopted": true, "trust": 100, "personality": "Mischievous", "quirk": "Adventurous"}, true)
	game.state["cryptids"] = [beans]
	var identity := beans.duplicate(true)
	await _open()
	_check(scene.resident_name.text.begins_with("beans"), "saved lowercase resident name preserved")
	_check(scene.resident_details.text.contains("Mischievous") and scene.resident_details.text.contains("Adventurous"), "personality and quirk preserved")
	var initial: Vector2 = scene.world.creature_position
	var wandered := false
	for i in range(90):
		scene.world._process(0.1)
		if scene.world.creature_position.distance_to(initial) > 5: wandered = true
	_check(wandered, "resident wanders through the world")
	_check(not game.has_moment("warm_glow"), "wandering does not unlock Warm Glow")
	await _capture("sanctuary-before-lamp.png")
	scene.lamp_button.pressed.emit()
	_check("old_lamp" in game.state["sanctuary_decorations"], "lamp placement persists immediately")
	_check(not game.has_moment("warm_glow"), "moment waits for physical arrival")
	for i in range(180):
		if i == 3: scene.lamp_button.pressed.emit()
		scene.world._process(0.1)
		if game.has_moment("warm_glow"): break
	_check(game.has_moment("warm_glow"), "lamp arrival unlocks Warm Glow despite repeat tap")
	_check(scene.world.creature_position.distance_to(scene.world.POINTS[2]) < 1, "resident actually reaches lamp")
	_check(game.state["cryptids"][0] == identity, "all resident identity fields unchanged")
	_check(game.state["moments"].count("warm_glow") == 1 and game.state["sanctuary_decorations"].count("old_lamp") == 1, "repeated placement does not duplicate saved entries")
	game.state = SaveManager.load_state()
	await _open()
	_check(scene.world.lamp_placed and game.has_moment("warm_glow"), "saved lamp and moment survive disk reload")
	_check(game.state["cryptids"][0] == JSON.parse_string(JSON.stringify(identity)), "saved individual survives disk reload")
	_check(scene.moment.get_global_rect().end.y <= 1920, "resident controls fit portrait canvas")
	_check(scene.lamp_button.size.y >= 132, "lamp touch target is at least 44 screen pixels")
	await _capture("sanctuary-warm-glow.png")
	_tap(Vector2(284, 151))
	_check(scene.moment.text.contains("STILLWATER"), "pond interaction responds")
	_tap(scene.world.POINTS[scene.world.PLOT_POINTS.garden_left])
	_check(is_instance_valid(scene.sheet) and scene.sheet.current_plot == "garden_left", "garden plot opens the decoration picker")
	scene._close_sheet()
	scene.world.set_process(false)
	_tap(scene.world.creature_position - Vector2(0, 15))
	_check(scene.world.greeting > 0, "resident responds to touch")
	var explored := false
	for i in range(300):
		scene.world._process(0.1)
		var p: Vector2 = scene.world.creature_position
		_check_route(p)
		if p.distance_to(scene.world.POINTS[2]) > 10: explored = true
	_check(explored, "resident continues exploring after Warm Glow")
	for start in range(scene.world.POINTS.size()):
		for finish in scene.world.LINKS[start]:
			for step in range(41):
				_check_route(scene.world.POINTS[start].lerp(scene.world.POINTS[finish], step / 40.0))
	# Manifest replacement is independent of resident simulation.
	var art := GradientTexture2D.new()
	scene.world.textures["resident"] = art
	scene.world.queue_redraw()
	await process_frame
	_check(scene.world.textures["resident"] == art, "texture replacement coexists with movement")
	# A saved decoration without a moment resumes the unfinished encounter.
	game.state["moments"] = []
	await _open()
	for i in range(10): scene.world._process(0.1)
	_check(game.has_moment("warm_glow"), "interrupted first visit recovers on reopening")
	# Legacy saves had the moment as the visible lamp source.
	game.state["sanctuary_decorations"] = []
	await _open()
	_check(scene.world.lamp_placed, "legacy Warm Glow-only saves still show the lamp")
	# A live navigation request must successfully load the existing map.
	current_scene = scene
	scene._go_map()
	await process_frame
	await process_frame
	_check(current_scene != null and current_scene.scene_file_path == "res://scenes/sanctuary/area_selector.tscn", "Sanctuary navigation opens the area selector")
	current_scene._visit_area("whispering_grove")
	await process_frame
	await process_frame
	_check(current_scene != null and current_scene.scene_file_path == "res://scenes/sanctuary/area.tscn", "area selector opens a Sanctuary area")
	current_scene.get_tree().change_scene_to_file("res://scenes/main/main.tscn")
	await process_frame
	await process_frame
	_check(current_scene.scene_file_path == "res://scenes/main/main.tscn", "navigation during a lamp visit safely stops movement")
	for path in ["res://scenes/lure_sites/whispering_woods.tscn", "res://scenes/encounters/mothling_encounter.tscn", "res://scenes/journal/journal.tscn"]:
		_check(load(path) != null, "existing scene loads: " + path)
	print("SANCTUARY TESTS: " + ("PASSED" if failures == 0 else str(failures) + " FAILED"))
	quit(0 if failures == 0 else 1)

func _check_route(p: Vector2) -> void:
	if p.distance_to(scene.world.FIRE_CENTER) < 28 or scene.world.POND_BOUNDS.has_point(p) or scene.world.CABIN_BOUNDS.has_point(p):
		failures += 1
		push_error("Walking route intersects scenery: " + str(p))
