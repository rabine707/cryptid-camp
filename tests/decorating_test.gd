extends "res://tests/sanctuary_test.gd"
const Catalog = preload("res://scripts/sanctuary/decor_catalog.gd")

func _advance(seconds: float) -> void:
	scene.world.set_process(false)
	for i in range(int(seconds * 10)):
		scene.world._process(0.1)

func _click(button: Button) -> void:
	await process_frame
	var point := button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event, true)
		await process_frame

func _pick(plot: String, item: String) -> void:
	scene._open_decorations(plot)
	await process_frame
	await process_frame
	var button: Button = scene.sheet.item_buttons[item]
	scene.sheet.scroll.ensure_control_visible(button)
	await process_frame
	await _click(button)
	_check(not is_instance_valid(scene.sheet), "actual pointer click places " + item)
	scene.world.set_process(false)

func _run() -> void:
	if not OS.get_user_data_dir().contains("cryptid-camp-tests"):
		push_error("Use an isolated APPDATA directory named cryptid-camp-tests.")
		quit(1)
		return
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): capture_dir = argument.trim_prefix("--capture=")
	root.size = Vector2i(360, 640)
	root.content_scale_size = Vector2i(1080, 1920)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	game = root.get_node("GameState")
	game.state = SaveManager.default_state()
	await _open()
	_check(game.get_sanctuary_plots().is_empty(), "legacy save without plots opens with empty corners")
	await _click(scene.decorate_button)
	_check(is_instance_valid(scene.sheet), "actual Decorate camp click opens picker")
	if not is_instance_valid(scene.sheet):
		quit(1)
		return
	_check(not scene.world.is_processing(), "browsing pauses resident reactions")
	_check(scene.sheet.visit_button.disabled, "empty camp cannot summon a nonexistent resident")
	await _capture("decorating-picker.png")
	await _click(scene.sheet.close_button)
	_check(not is_instance_valid(scene.sheet), "Done closes picker through pointer input")
	await _pick("garden_left", "flower_patch")
	_advance(20)
	_check(game.get_sanctuary_plots().get("garden_left") == "flower_patch", "empty camp can be decorated")
	_check(not game.has_moment("petal_hello"), "decorations never unlock moments without a resident")
	game.state = SaveManager.load_state()
	_check(game.get_sanctuary_plots().get("garden_left") == "flower_patch", "plot placement survives disk reload")
	var rng := RandomNumberGenerator.new()
	rng.seed = 707
	var beans := CryptidFactory.create("mothling", rng)
	beans.merge({"name": "beans", "adopted": true, "trust": 100, "personality": "Mischievous", "quirk": "Adventurous"}, true)
	game.state["cryptids"] = [beans]
	game.state["sanctuary_decorations"] = ["old_lamp"]
	game.state["moments"] = ["warm_glow"]
	var identity := beans.duplicate(true)
	game.persist()
	await _open()
	# Inspect the other corner via its actual world hit target.
	_tap(scene.world.POINTS[8])
	_check(scene.sheet.current_plot == "garden_right", "Meadow Corner tap selects the correct plot")
	await _click(scene.sheet.slot_buttons["garden_left"])
	_check(scene.sheet.current_plot == "garden_left", "plot tabs switch the target")
	await _click(scene.sheet.close_button)
	# Every item has a distinct on-arrival action and an earned memory.
	for item in Catalog.ITEMS:
		await _pick("garden_right", item)
		_check(game.get_sanctuary_plots().get("garden_left") == "flower_patch", "replacing right plot preserves left plot")
		var id := str(Catalog.ITEMS[item].moment)
		_check(not game.has_moment(id), "placement alone does not unlock " + id)
		for i in range(300):
			scene.world._process(0.1)
			if scene.world.active_plot == "garden_right": break
		_check(scene.world.active_plot == "garden_right", "resident physically reaches " + item)
		_check(scene.world.creature_position.distance_to(scene.world.POINTS[8]) < 1, "reaction starts at the item's position")
		_check(scene.activity_label.text == str(Catalog.ITEMS[item].action), "activity describes " + item)
		_check(not game.has_moment(id), "arrival alone does not unlock " + id)
		_advance(3.2)
		_check(game.has_moment(id), "enjoying decoration unlocks " + id)
		_check(game.state["moments"].count(id) == 1, "moment is unique: " + id)
		_check(scene.moment.get_global_rect().end.y <= 1920, "moment copy fits portrait screen")
		if item == "moss_cushion": await _capture("decorating-little-nap.png")
		if item == "mushroom_stool": await _capture("decorating-tiny-throne.png")
		# Revisit the same item without duplicating the memory.
		scene.world.visit_plot("garden_right")
		_advance(3.4)
		_check(game.state["moments"].count(id) == 1, "repeat visit keeps a single " + id)
	_check(scene.album_button.text == "Moments 6/6", "album count includes all discoveries and Warm Glow")
	_check(game.state["cryptids"][0] == identity, "decorating does not alter the saved individual")
	await _click(scene.album_button)
	_check(scene.sheet.mode == "moments" and scene.sheet._moment_count() == 6, "album opens with six collected memories")
	await _capture("decorating-moments.png")
	# Escape must close the modal without touching the map behind it.
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	root.push_input(escape, true)
	await process_frame
	_check(not is_instance_valid(scene.sheet), "Escape dismisses the modal")
	game.state = SaveManager.load_state()
	await _open()
	_check(game.state["cryptids"][0] == JSON.parse_string(JSON.stringify(identity)), "resident survives new save fields and reload")
	_check(game.get_sanctuary_plots() == {"garden_left": "flower_patch", "garden_right": "star_blanket"}, "both plot assignments restore exactly")
	_check(scene.album_button.text == "Moments 6/6", "album discoveries survive disk reload")
	# Replace mid-reaction: the removed item must not earn a stale moment.
	game.state["moments"] = ["warm_glow"]
	await _pick("garden_right", "moss_cushion")
	for i in range(300):
		scene.world._process(0.1)
		if scene.world.active_plot == "garden_right": break
	_advance(1.0)
	await _pick("garden_right", "mushroom_stool")
	_advance(3.5)
	_check(not game.has_moment("little_nap") and game.has_moment("tiny_throne"), "replacement cancels unfinished nap and earns the new item's moment")
	# Remove during movement and preserve every memory already earned.
	scene.world.visit_lamp()
	_advance(1.0)
	scene._open_decorations("garden_right")
	await process_frame
	await _click(scene.sheet.clear_button)
	_check(not game.get_sanctuary_plots().has("garden_right"), "Clear plot removes only the selected item")
	_check(scene.world.active_plot.is_empty() and scene.world.requested_plot.is_empty(), "removal cancels stale reactions")
	_check(not scene.world.lamp_requested, "removal cannot trigger a false lamp arrival")
	_check(game.has_moment("tiny_throne") and game.has_moment("warm_glow"), "clearing a plot keeps discovered memories")
	game.state = SaveManager.load_state()
	_check(not game.get_sanctuary_plots().has("garden_right"), "plot removal persists")
	var snapshot: Dictionary = game.state.duplicate(true)
	_check(not game.set_sanctuary_plot("fake_plot", "flower_patch"), "invalid plot rejected")
	_check(not game.set_sanctuary_plot("garden_left", "fake_item"), "invalid decoration rejected")
	_check(game.state == snapshot, "invalid placements leave the save unchanged")
	game.state["sanctuary_plots"] = {"garden_left": "unknown_future_item", "garden_right": "moss_cushion", "bad": "flower_patch"}
	_check(game.get_sanctuary_plots() == {"garden_right": "moss_cushion"}, "unknown save IDs are ignored safely")
	game.state["sanctuary_plots"] = "invalid"
	_check(game.get_sanctuary_plots().is_empty(), "malformed optional plot data falls back safely")
	# All route edges still avoid the cabin, pond and fire.
	for start in range(scene.world.POINTS.size()):
		for finish in scene.world.LINKS[start]:
			for step in range(41): _check_route(scene.world.POINTS[start].lerp(scene.world.POINTS[finish], step / 40.0))
	# Finish on a representative decorated scene for visual inspection.
	game.state["moments"] = ["warm_glow", "little_nap", "petal_hello", "tiny_throne", "quiet_duet", "star_watch"]
	game.set_sanctuary_plot("garden_left", "flower_patch")
	game.set_sanctuary_plot("garden_right", "moss_cushion")
	await _open()
	var autonomous_visits: Array[String] = []
	scene.world.decoration_enjoyed.connect(func(item: String):
		if item not in autonomous_visits: autonomous_visits.append(item))
	_advance(180)
	_check("flower_patch" in autonomous_visits and "moss_cushion" in autonomous_visits, "resident independently enjoys both decorations without being summoned")
	scene.world.visit_plot("garden_right")
	for i in range(300):
		scene.world._process(0.1)
		if scene.world.active_plot == "garden_right": break
	_advance(3.2)
	await _capture("sanctuary-decorated.png")
	# A live pointer opens the album after all replacements and removals.
	await _click(scene.album_button)
	await process_frame
	_check(scene.sheet._moment_count() == 6, "completed album survives all editing flows")
	scene.sheet.scroll.scroll_vertical = 2000
	await _capture("decorating-moments-bottom.png")
	await _click(scene.sheet.close_button)
	scene.world.visit_plot("garden_left")
	_advance(1.0)
	current_scene = scene
	scene._go_map()
	await process_frame
	await process_frame
	current_scene.get_node("Margin/VBox/Sanctuary").pressed.emit()
	await process_frame
	await process_frame
	scene = current_scene
	_check(scene.world.plots == game.get_sanctuary_plots(), "leaving during a decoration visit and returning restores both plots")
	print("DECORATING TESTS: " + ("PASSED" if failures == 0 else str(failures) + " FAILED"))
	quit(0 if failures == 0 else 1)
