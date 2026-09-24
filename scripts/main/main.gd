extends Control

var visitors: Array = []

func _ready() -> void:
	_build_camp_home()

func _build_camp_home() -> void:
	for child in get_children():
		child.queue_free()
	var bg := TextureRect.new()
	bg.texture = ArtRegistry.texture_for("background.main_menu")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.07, 0.06, 0.42)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side, 34)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 26)
	add_child(margin)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 16)
	margin.add_child(page)

	var header := HBoxContainer.new()
	page.add_child(header)
	var brand := _label("CRYPTID CAMP", 52, CampStyle.CREAM)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(brand)
	var residents := _button("Residents", "paper")
	residents.custom_minimum_size = Vector2(220, 82)
	residents.pressed.connect(_open_areas)
	header.add_child(residents)

	var weather := PanelContainer.new()
	weather.add_theme_stylebox_override("panel", CampStyle.panel(Color(0.05,0.12,0.11,0.94), 16, 2, CampStyle.WOOD_LIGHT))
	page.add_child(weather)
	var weather_row := HBoxContainer.new()
	weather.add_child(weather_row)
	var greeting := _label("Tonight at Camp", 31)
	greeting.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	weather_row.add_child(greeting)
	var count := _adopted_count()
	weather_row.add_child(_label("%d friends" % count, 26, CampStyle.GOLD))

	var scene_panel := PanelContainer.new()
	scene_panel.custom_minimum_size.y = 900
	scene_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scene_panel.add_theme_stylebox_override("panel", CampStyle.panel(Color(0.06,0.15,0.12,0.78), 22, 4, CampStyle.WOOD))
	page.add_child(scene_panel)
	var camp := VBoxContainer.new()
	camp.alignment = BoxContainer.ALIGNMENT_CENTER
	camp.add_theme_constant_override("separation", 22)
	scene_panel.add_child(camp)
	camp.add_child(_label("THE CAMP CLEARING", 28, CampStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	visitors = GameState.get_camp_visitors(4)
	if visitors.is_empty():
		camp.add_child(_label("The clearing is quiet...", 44, CampStyle.CREAM, HORIZONTAL_ALIGNMENT_CENTER))
		camp.add_child(_label("Explore the woods and befriend your first cryptid.\nSoon this place will feel a lot less empty.", 27, Color("d8cda9"), HORIZONTAL_ALIGNMENT_CENTER))
		var start := _button("Explore Whispering Woods", "green")
		start.custom_minimum_size.y = 120
		start.pressed.connect(_open_whispering_woods)
		camp.add_child(start)
	else:
		camp.add_child(_label("Camp Visitors", 45, CampStyle.CREAM, HORIZONTAL_ALIGNMENT_CENTER))
		var grid := GridContainer.new()
		grid.columns = 2
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_theme_constant_override("h_separation", 18)
		grid.add_theme_constant_override("v_separation", 18)
		camp.add_child(grid)
		for id in visitors:
			var card := PanelContainer.new()
			card.custom_minimum_size = Vector2(450, 190)
			card.add_theme_stylebox_override("panel", CampStyle.panel(Color("e8d5ad"), 18, 3, CampStyle.WOOD))
			var box := VBoxContainer.new()
			card.add_child(box)
			box.add_child(_label(_display_name(str(id)), 34, CampStyle.INK, HORIZONTAL_ALIGNMENT_CENTER))
			box.add_child(_label("Visiting camp", 23, Color("5c4937"), HORIZONTAL_ALIGNMENT_CENTER))
			grid.add_child(card)
		var areas := _button("Visit Sanctuary Areas", "wood")
		areas.custom_minimum_size.y = 110
		areas.pressed.connect(_open_areas)
		camp.add_child(areas)

	var today := PanelContainer.new()
	today.add_theme_stylebox_override("panel", CampStyle.panel(CampStyle.PAPER, 16, 3, CampStyle.WOOD))
	page.add_child(today)
	var today_box := VBoxContainer.new()
	today.add_child(today_box)
	today_box.add_child(_label("TODAY AT CAMP", 27, CampStyle.INK))
	var status := "Your Trail Cam is waiting in Whispering Woods." if GameState.needs_first_hunt() else "The woods are always changing. See who is nearby tonight."
	today_box.add_child(_label(status, 25, Color("4d4334")))

	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 10)
	page.add_child(nav)
	for item in [["Camp", "camp"], ["Explore", "explore"], ["Sanctuary", "areas"], ["Journal", "journal"]]:
		var b := _button(item[0], "green" if item[1] == "camp" else "wood")
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size.y = 105
		match item[1]:
			"explore": b.pressed.connect(_open_whispering_woods)
			"areas": b.pressed.connect(_open_areas)
			"journal": b.pressed.connect(_open_journal)
		nav.add_child(b)

func _adopted_count() -> int:
	var count := 0
	for cryptid in GameState.state.get("cryptids", []):
		if cryptid.get("adopted", false):
			count += 1
	return count

func _display_name(id: String) -> String:
	var data = GameState.state.get("cryptids", [])
	for cryptid in data:
		if str(cryptid.get("species", "")) == id and cryptid.get("adopted", false):
			var nickname := str(cryptid.get("name", ""))
			if not nickname.is_empty(): return nickname
	return id.replace("_", " ").capitalize()

func _label(value: String, size: int, color := CampStyle.CREAM, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = align
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

func _button(value: String, kind := "wood") -> Button:
	var button := Button.new()
	button.text = value
	CampStyle.button(button, kind)
	button.add_theme_font_size_override("font_size", 28)
	return button

func _open_whispering_woods() -> void:
	get_tree().change_scene_to_file("res://scenes/lure_sites/whispering_woods.tscn")

func _open_areas() -> void:
	get_tree().change_scene_to_file("res://scenes/sanctuary/area_selector.tscn")

func _open_journal() -> void:
	get_tree().change_scene_to_file("res://scenes/journal/journal.tscn")
