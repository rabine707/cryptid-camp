extends SceneTree
var failures := 0
var game: Node
var session: Node
var scene: Control
var capture_dir := ""

func _initialize() -> void:
	call_deferred("_run")

func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error("FAIL: " + message)
	else:
		print("PASS: " + message)

func open_camera(visitor: String) -> void:
	if is_instance_valid(scene):
		scene.free()
	session.visitor_id = visitor
	var rng := RandomNumberGenerator.new()
	rng.seed = 707
	session.events = Observation.generate_events(visitor, rng)
	scene = load("res://scenes/trail_cam/trail_cam.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

func capture(filename: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join(filename))

func _run() -> void:
	if not OS.get_user_data_dir().contains("cryptid-camp-tests"):
		push_error("Use isolated APPDATA/XDG_DATA_HOME containing cryptid-camp-tests.")
		quit(1)
		return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			capture_dir = arg.trim_prefix("--capture=")
	root.size = Vector2i(390, 844)
	root.content_scale_size = Vector2i(1080, 1920)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	game = root.get_node("GameState")
	session = root.get_node("TrailCamSession")
	game.state = SaveManager.default_state()
	check(game.needs_first_hunt(), "fresh save enables guided hunt")
	var woods = load("res://scenes/lure_sites/whispering_woods.tscn").instantiate()
	root.add_child(woods)
	current_scene = woods
	check(woods.observe_button.disabled, "first hunt waits for the lantern setup")
	woods._place_object("old_radio")
	check(woods.observe_button.disabled, "unhelpful first lure cannot strand the tutorial")
	woods._place_object("lantern")
	check(not woods.observe_button.disabled, "lantern enables observation")
	woods.observe_button.pressed.emit()
	await process_frame
	await process_frame
	scene = current_scene
	check(session.visitor_id == "mothling", "first observation guarantees the intended visitor")
	await open_camera("mothling")
	check(not game.is_discovered("mothling"), "camera does not automatically discover visitor")
	check(scene.primary.text == "Collect Camera Evidence", "first action teaches collecting")
	await capture("trail-cam-detection.png")
	scene.primary.pressed.emit()
	check(game.evidence_for("mothling") == ["red_eyes"], "collect saves the real camera evidence")
	check(FieldResearch.candidates(game.evidence_for("mothling")).size() == 2, "first clue leaves two candidates")
	check(not game.identify_species("mothling"), "identification rejected before sufficient evidence")
	scene.secondary.pressed.emit()
	check(scene.primary.text == "Follow the Red Eyes", "alternate path remains recoverable")
	scene.primary.pressed.emit()
	check(FieldResearch.candidates(game.evidence_for("mothling")) == ["mothling"], "wing clue narrows candidates")
	await capture("trail-cam-investigation.png")
	game.state = SaveManager.load_state()
	await open_camera("mothling")
	check(scene.primary.text == "Watch the Lantern", "reload resumes incomplete first hunt")
	scene.primary.pressed.emit()
	check(scene.primary.text == "Identify Mothling", "confirmation follows enough evidence")
	await capture("trail-cam-identify.png")
	scene.primary.pressed.emit()
	check(game.is_discovered("mothling") and scene.revealed, "explicit identification records collection and reveal")
	await capture("trail-cam-reveal.png")
	game.identify_species("mothling")
	check(game.state.discovered_species.count("mothling") == 1, "identification is idempotent")
	check(scene.primary.get_global_rect().end.y <= scene.size.y, "primary action stays in layout")
	game.begin_hunt()
	check(game.has_second_hunt_hint(), "second hunt has lighter hints")
	await open_camera("bigfoot")
	scene.primary.pressed.emit()
	check(scene.hint.text.contains("Another piece"), "second new visitor asks for another clue")
	scene.primary.pressed.emit()
	scene.primary.pressed.emit()
	check(game.is_discovered("bigfoot"), "second species can be recorded in journal")
	game.begin_hunt()
	check(not game.has_second_hunt_hint(), "third hunt uses normal gameplay")
	await open_camera("nightcrawler")
	scene.primary.pressed.emit()
	scene.primary.pressed.emit()
	scene.primary.pressed.emit()
	check(game.is_discovered("nightcrawler"), "nightcrawler identification follows its own clues")
	var rng := RandomNumberGenerator.new()
	rng.seed = 707
	var resident := CryptidFactory.create("mothling", rng)
	resident["name"] = "Beans"
	resident["trust"] = 83
	resident["adopted"] = true
	game.state = SaveManager.default_state()
	game.state["cryptids"] = [resident.duplicate(true)]
	game.state["discovered_species"] = ["mothling"]
	game.state["moments"] = ["warm_glow"]
	game.begin_hunt()
	check(not game.needs_first_hunt() and not game.has_second_hunt_hint(), "legacy player skips tutorial")
	check(game.state.cryptids[0] == resident and game.has_moment("warm_glow"), "legacy identity trust and moments preserved")
	await open_camera("mothling")
	check(scene.primary.text == "Visit the Mothling", "legacy discovery still opens encounter")
	await open_camera("")
	check(scene.primary.text == "Return to Clearing", "empty observation remains usable")
	scene.free()
	for path in ["main/main", "lure_sites/whispering_woods", "journal/journal", "encounters/mothling_encounter"]:
		scene = load("res://scenes/" + path + ".tscn").instantiate()
		root.add_child(scene)
		await process_frame
		await capture(path.get_file() + ".png")
		scene.free()
	print("FIRST HUNT FAILURES: ", failures)
	quit(1 if failures else 0)
