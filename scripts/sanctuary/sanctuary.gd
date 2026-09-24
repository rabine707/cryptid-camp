extends Control

const CampWorld = preload("res://scripts/sanctuary/camp_world.gd")
const Catalog = preload("res://scripts/sanctuary/decor_catalog.gd")
const CampSheet = preload("res://scripts/sanctuary/camp_sheet.gd")
var resident: Dictionary = {}
var world: Control
var lamp_button: Button
var moment: Label
var resident_name: Label
var resident_details: Label
var activity_label: Label
var sheet: Control
var decorate_button: Button
var album_button: Button

func _ready() -> void:
	# The project scales its 1080 x 1920 canvas to the 360 x 640 test window.
	var background := ColorRect.new()
	background.color = Color("10232a")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 36)
	for side in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	margin.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var back := _button("Map", "wood")
	back.custom_minimum_size = Vector2(150, 132)
	back.pressed.connect(_go_map)
	header.add_child(back)
	var heading := VBoxContainer.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(heading)
	heading.add_child(_label("Sanctuary", 66, Color("f3e5bc")))
	activity_label = _label("A little wild. A little home.", 31, Color("b7c9ad"))
	heading.add_child(activity_label)
	world = CampWorld.new()
	world.name = "CampWorld"
	world.custom_minimum_size = Vector2(0, 900)
	world.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(world)
	world.lamp_reached.connect(_on_lamp_reached)
	world.inspected.connect(_on_inspected)
	world.plot_selected.connect(_open_decorations)
	world.decoration_enjoyed.connect(_on_decoration_enjoyed)
	world.activity_changed.connect(func(value: String): activity_label.text = value)
	resident_name = _label("", 44, Color("f3e5bc"))
	column.add_child(resident_name)
	resident_details = _label("", 32, Color("b7c9ad"))
	resident_details.custom_minimum_size.y = 84
	column.add_child(resident_details)
	lamp_button = _button("Place Old Lamp", "green")
	lamp_button.custom_minimum_size.y = 132
	lamp_button.pressed.connect(_place_lamp)
	column.add_child(lamp_button)
	var tools := HBoxContainer.new()
	tools.add_theme_constant_override("separation", 18)
	column.add_child(tools)
	decorate_button = _button("Decorate camp", "wood")
	decorate_button.custom_minimum_size.y = 132
	decorate_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	decorate_button.pressed.connect(func(): _open_decorations("garden_left"))
	tools.add_child(decorate_button)
	album_button = _button("Moments", "wood")
	album_button.custom_minimum_size.y = 132
	album_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	album_button.pressed.connect(_open_album)
	tools.add_child(album_button)
	moment = _label("Tap Decorate camp to make room for little moments.", 33, Color("e1c38a"))
	moment.custom_minimum_size.y = 120
	column.add_child(moment)
	resident = GameState.get_adopted_species("mothling")
	var placed: bool = "old_lamp" in GameState.state.get("sanctuary_decorations", []) or GameState.has_moment("warm_glow")
	world.configure(resident, placed, GameState.get_sanctuary_plots())
	_update_album_count()
	if resident.is_empty():
		resident_name.text = "A home for someone strange"
		resident_details.text = "Meet a Mothling in Whispering Woods\nand invite them home."
		lamp_button.text = "Old Lamp · waiting for a resident"
		lamp_button.disabled = true
	else:
		resident_name.text = str(resident.get("name", "Mothling")) + "  ·  " + CryptidFactory.trust_stage(int(resident.get("trust", 0)))
		resident_details.text = "%s Mothling · %s\n%s · at home" % [str(resident.get("variant", "classic")).capitalize(), resident.get("personality", "Curious"), resident.get("quirk", "Clingy")]
		if placed:
			lamp_button.text = "Visit the Old Lamp"
			if GameState.has_moment("warm_glow"):
				moment.text = "WARM GLOW\nA favorite light. A familiar little friend."
			else:
				world.visit_lamp()
	if not GameState.get_sanctuary_plots().is_empty():
		moment.text = "Your corners are just as you left them.\nTap a decoration to change it or invite a visit."

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	if font_size < 42:
		label.add_theme_font_override("font", ThemeDB.fallback_font)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _button(value: String, kind: String) -> Button:
	var button := Button.new()
	button.text = value
	CampStyle.button(button, kind)
	button.add_theme_font_size_override("font_size", 38)
	button.add_theme_stylebox_override("focus", CampStyle.panel(Color.TRANSPARENT, 14, 4, CampStyle.GOLD))
	return button

func _place_lamp() -> void:
	if resident.is_empty():
		return
	GameState.place_sanctuary_decoration("old_lamp")
	world.visit_lamp()
	lamp_button.text = "Visit the Old Lamp"
	moment.text = "%s is coming over to the warm light…" % resident.get("name", "Your Mothling")

func _on_lamp_reached() -> void:
	var is_new := not GameState.has_moment("warm_glow")
	if is_new:
		GameState.unlock_moment("warm_glow")
		world.celebration = 3.0
	_update_album_count()
	moment.text = ("MOMENT DISCOVERED · WARM GLOW" if is_new else "WARM GLOW") + "\n%s has claimed the coziest spot." % resident.get("name", "Your Mothling")

func _on_inspected(message: String) -> void:
	moment.text = message

func _open_decorations(plot: String) -> void:
	_open_sheet("decorate", plot)

func _open_album() -> void:
	_open_sheet("moments", "garden_left")

func _open_sheet(mode: String, plot: String) -> void:
	if is_instance_valid(sheet): return
	world.set_process(false)
	world.selected_plot = plot if mode == "decorate" else ""
	world.queue_redraw()
	sheet = CampSheet.new()
	sheet.mode = mode
	sheet.current_plot = plot
	sheet.plots = GameState.get_sanctuary_plots()
	sheet.moments = GameState.state.get("moments", []).duplicate()
	sheet.has_resident = not resident.is_empty()
	sheet.closed.connect(_close_sheet)
	sheet.item_chosen.connect(_choose_decoration)
	sheet.visit_requested.connect(_invite_to_plot)
	add_child(sheet)

func _close_sheet() -> void:
	if is_instance_valid(sheet):
		remove_child(sheet)
		sheet.queue_free()
		sheet = null
	world.selected_plot = ""
	world.set_process(true)
	decorate_button.grab_focus()

func _choose_decoration(plot: String, item: String) -> void:
	if not GameState.set_sanctuary_plot(plot, item):
		_close_sheet()
		moment.text = "Couldn't save that change. Your camp is unchanged."
		return
	_close_sheet()
	world.set_plots(GameState.get_sanctuary_plots())
	if item.is_empty():
		moment.text = "%s is ready for something new.\nYour discovered moments are kept." % Catalog.plot_name(plot)
	else:
		var data: Dictionary = Catalog.ITEMS[item]
		moment.text = "%s placed in %s.\n%s" % [data.name, Catalog.plot_name(plot), "A curious little visitor is on the way." if not resident.is_empty() else "A cozy welcome for a future resident."]
		world.celebration = 1.5
		world.visit_plot(plot)

func _invite_to_plot(plot: String) -> void:
	_close_sheet()
	world.visit_plot(plot)
	moment.text = "%s is coming to %s." % [resident.get("name", "Your Mothling"), Catalog.plot_name(plot)]

func _on_decoration_enjoyed(item: String) -> void:
	var data: Dictionary = Catalog.ITEMS[item]
	var is_new := not GameState.has_moment(str(data.moment))
	if is_new:
		GameState.unlock_moment(str(data.moment))
		world.celebration = 3.0
	_update_album_count()
	moment.text = ("NEW MOMENT · " if is_new else "") + str(data.title).to_upper() + "\n" + str(data.memory)

func _update_album_count() -> void:
	var count := 1 if GameState.has_moment("warm_glow") else 0
	for data in Catalog.ITEMS.values():
		if GameState.has_moment(str(data.moment)): count += 1
	album_button.text = "Moments %d/6" % count

func _go_map() -> void:
	# Sanctuary now opens into the area/room selector rather than jumping straight home.
	get_tree().change_scene_to_file("res://scenes/sanctuary/area_selector.tscn")
