extends SceneTree
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, label: String) -> void:
	if value:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)

func run() -> void:
	if not OS.get_user_data_dir().contains("cryptid-camp-tests"):
		quit(1)
		return
	root.size = Vector2i(320, 568)
	root.content_scale_size = Vector2i(1080, 1920)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	var game := root.get_node("GameState")
	game.state = SaveManager.default_state()
	game.state.discovered_species = ["mothling", "bigfoot", "nightcrawler"]
	var original: Dictionary = game.state.duplicate(true)
	for slot in ["background.sanctuary", "background.main_menu", "background.whispering_woods", "ui.wood", "cryptid.mothling.classic", "cryptid.bigfoot.classic", "cryptid.nightcrawler.classic", "cryptid.scraps.classic", "cryptid.glimmer.classic"]:
		check(ArtRegistry.texture_for(slot) != null, "art resource loads: " + slot)
	for item in ["old_lamp", "mushroom_stool", "flower_patch", "moss_cushion", "wind_chimes", "star_blanket"]:
		var texture := ArtRegistry.texture_for("decoration." + item)
		check(texture is AtlasTexture and texture.get_size() == Vector2(512, 512), "isolated atlas region: " + item)
	var book = load("res://scenes/journal/sketchbook.tscn").instantiate()
	root.add_child(book)
	await process_frame
	for index in range(book.ENTRIES.size()):
		book._show_entry(index)
		await process_frame
		check(book.portrait.texture != null, "sketchbook portrait: " + book.ENTRIES[index].name)
		check(book.availability.get_global_rect().end.y <= 1920, "sketchbook copy fits small mobile: " + book.ENTRIES[index].name)
		if index > 2:
			check(book.availability.text.contains("not available"), "future visitor is clearly marked")
	book.free()
	var journal = load("res://scenes/journal/journal.tscn").instantiate()
	root.add_child(journal)
	await process_frame
	for id in ["mothling", "bigfoot", "nightcrawler"]:
		journal.selected_species = id
		journal._render()
		check(journal.get_node("Margin/VBox/Page/Content/Sketch").texture != null, "discovered journal portrait: " + id)
	check(game.state == original, "browsing all art preserves progression and saves")
	check(FieldResearch.NAMES.keys() == ["mothling", "bigfoot", "nightcrawler"], "species save IDs and encounter roster unchanged")
	journal.free()
	print("STORYBOOK FAILURES: ", failures)
	quit(1 if failures else 0)
