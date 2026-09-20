extends Control

const CampWorld = preload("res://scripts/sanctuary/camp_world.gd")
var resident: Dictionary = {}
var world: Control
var lamp_button: Button
var moment: Label
var resident_name: Label
var resident_details: Label

func _ready() -> void:
	# The project scales its 1080 x 1920 canvas to the 360 x 640 test window.
	var background := ColorRect.new()
	background.color = Color("172f2c")
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
	heading.add_child(_label("SANCTUARY", 52, Color("f3e5bc")))
	heading.add_child(_label("A little wild. A little home.", 33, Color("b7c9ad")))
	world = CampWorld.new()
	world.name = "CampWorld"
	world.custom_minimum_size = Vector2(0, 900)
	world.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(world)
	world.lamp_reached.connect(_on_lamp_reached)
	world.inspected.connect(_on_inspected)
	resident_name = _label("", 44, Color("f3e5bc"))
	column.add_child(resident_name)
	resident_details = _label("", 32, Color("b7c9ad"))
	resident_details.custom_minimum_size.y = 84
	column.add_child(resident_details)
	lamp_button = _button("Place Old Lamp", "green")
	lamp_button.custom_minimum_size.y = 132
	lamp_button.pressed.connect(_place_lamp)
	column.add_child(lamp_button)
	moment = _label("Tap the pond, fire or a garden plot to explore.", 33, Color("e1c38a"))
	moment.custom_minimum_size.y = 120
	column.add_child(moment)
	resident = GameState.get_adopted_species("mothling")
	var placed: bool = "old_lamp" in GameState.state.get("sanctuary_decorations", []) or GameState.has_moment("warm_glow")
	world.configure(resident, placed)
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

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
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
	moment.text = ("MOMENT DISCOVERED · WARM GLOW" if is_new else "WARM GLOW") + "\n%s has claimed the coziest spot." % resident.get("name", "Your Mothling")

func _on_inspected(message: String) -> void:
	moment.text = message

func _go_map() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
