extends SceneTree

var failures := 0
var game: Node

func check(value: bool, message: String) -> void:
	if value:
		print("PASS: " + message)
	else:
		failures += 1
		push_error("FAIL: " + message)

func load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text()) if file else {}
	return parsed if parsed is Dictionary else {}

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if not OS.get_user_data_dir().contains("cryptid-camp-tests"):
		push_error("Use isolated APPDATA/XDG_DATA_HOME containing cryptid-camp-tests.")
		quit(1)
		return
	root.size = Vector2i(390, 844)
	root.content_scale_size = Vector2i(1080, 1920)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	game = root.get_node("GameState")
	var objects := load_json("res://data/lure_objects.json")
	var cryptids := load_json("res://data/cryptids.json")
	var moth_light := Attraction.setup_match(cryptids.mothling, ["lantern", "pine_tree"], objects)
	var sprig_light := Attraction.setup_match(cryptids.bigfoot, ["lantern", "pine_tree"], objects)
	check(moth_light > sprig_light, "lantern and forest guidance favors Mothling")
	var woodland: Array[String] = ["berry_bush", "hollow_log", "pine_tree"]
	check(Attraction.setup_match(cryptids.bigfoot, woodland, objects) > Attraction.setup_match(cryptids.mothling, woodland, objects), "fruit and cover guidance favors Sprigfoot")
	check(Attraction.setup_match(cryptids.nightcrawler, ["camping_chair"], objects, {"is_night":true}) > Attraction.setup_match(cryptids.mothling, ["camping_chair"], objects, {"is_night":true}), "open nighttime setup favors Stilts")
	check(Attraction.setup_match(cryptids.nightcrawler, ["wildflowers"], objects, {"is_night":true}) > 0, "Stilts can like open space without requiring one exact prop")
	check(Attraction.setup_match(cryptids.nightcrawler, ["hollow_log"], objects, {"is_night":true}) < Attraction.setup_match(cryptids.nightcrawler, ["camping_chair"], objects, {"is_night":true}), "heavy cover is less suitable for Stilts")
	check(Attraction.setup_band(Attraction.setup_match(cryptids.mothling, ["lantern", "pine_tree"], objects, {"is_night":true})) in ["strong", "exceptional"], "guidance exposes a readable strength band")

	game.state = SaveManager.default_state()
	game.state.discovered_species = ["mothling"]
	var woods = load("res://scenes/lure_sites/whispering_woods.tscn").instantiate()
	root.add_child(woods)
	await process_frame
	check(woods.get_node("Margin/VBox/Hint").text.contains("FIELD NOTES"), "empty clearing shows setup field notes")
	woods._place_object("lantern")
	woods._place_object("pine_tree")
	check(woods.get_node("Margin/VBox/Hint").text.contains("Strong match for Mothling"), "live setup read names the strongest visitor match")
	var lantern_button: Button = woods.inventory.get_child(3)
	check(lantern_button.text.contains("Human") and lantern_button.text.contains("Light"), "field-kit buttons explain object traits")
	woods.free()

	game.state = SaveManager.default_state()
	game.state.discovered_species = ["mothling"]
	game.state.cryptids = [{
		"id":"trust-test", "species":"mothling", "name":"", "variant":"classic",
		"size":"Average", "personality":"Curious", "quirk":"Camera Shy",
		"trust":0, "adopted":false, "encounter_count":0, "encounter_history":[]
	}]
	for visit in range(3):
		var encounter = load("res://scenes/encounters/mothling_encounter.tscn").instantiate()
		root.add_child(encounter)
		await process_frame
		encounter._treat()
		encounter._observe()
		encounter._photo()
		encounter.free()
	var resident: Dictionary = game.get_wild_individual("mothling")
	check(int(resident.trust) >= 80, "even a camera-shy Mothling bonds within three varied visits")
	check(int(resident.trust) < 100, "faster bonding does not instantly max family trust")

	print("ENCOUNTER + GUIDANCE FAILURES: ", failures)
	quit(1 if failures else 0)
