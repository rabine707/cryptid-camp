extends Control

var area_id := "camp_clearing"
var area: Dictionary = {}
var room_layer: Control
var roster_panel: PanelContainer
var roster_box: VBoxContainer
var status: Label

const RESIDENT_POSITIONS := [
	Vector2(0.20, 0.67), Vector2(0.50, 0.72), Vector2(0.78, 0.65),
	Vector2(0.30, 0.43), Vector2(0.66, 0.42), Vector2(0.50, 0.25)
]

func _ready() -> void:
	area_id = str(GameState.state.get("active_sanctuary_area", "camp_clearing"))
	area = GameState.get_sanctuary_areas().get(area_id, {})
	_build_room()
	_refresh()

func _build_room() -> void:
	var bg := TextureRect.new()
	bg.texture = ArtRegistry.texture_for("background.sanctuary")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var shade := ColorRect.new()
	shade.color = Color(0.02,0.08,0.07,0.20)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side, 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 26)
	add_child(margin)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	margin.add_child(page)

	var top := HBoxContainer.new()
	page.add_child(top)
	var back := _button("Areas", "paper")
	back.custom_minimum_size = Vector2(155, 76)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/sanctuary/area_selector.tscn"))
	top.add_child(back)
	var title := _label(str(area.get("name","Sanctuary Area")), 48, CampStyle.CREAM)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_child(title)
	var spacer := Control.new()
	spacer.custom_minimum_size.x = 155
	top.add_child(spacer)

	status = _label("", 24, Color("ead49d"))
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(status)

	var room := PanelContainer.new()
	room.size_flags_vertical = Control.SIZE_EXPAND_FILL
	room.custom_minimum_size.y = 1120
	room.add_theme_stylebox_override("panel", CampStyle.panel(Color(0.03,0.12,0.10,0.16), 22, 3, CampStyle.WOOD_LIGHT))
	page.add_child(room)
	room_layer = Control.new()
	room_layer.clip_contents = true
	room.add_child(room_layer)

	var hint := _label("Tap a resident to say hello", 23, Color("f3e5bc"))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hint.offset_top = 20
	hint.offset_bottom = 60
	room_layer.add_child(hint)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	page.add_child(actions)
	for item in [["Residents","residents"],["Decorate","decorate"],["Area Info","info"]]:
		var b := _button(item[0], "wood")
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size.y = 92
		match item[1]:
			"residents": b.pressed.connect(_toggle_roster)
			"decorate": b.pressed.connect(_show_decorate_note)
			"info": b.pressed.connect(_show_area_info)
		actions.add_child(b)

	roster_panel = PanelContainer.new()
	roster_panel.visible = false
	roster_panel.custom_minimum_size.y = 430
	roster_panel.add_theme_stylebox_override("panel", CampStyle.panel(CampStyle.PAPER, 18, 3, CampStyle.WOOD))
	page.add_child(roster_panel)
	var scroll := ScrollContainer.new()
	roster_panel.add_child(scroll)
	roster_box = VBoxContainer.new()
	roster_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	roster_box.add_theme_constant_override("separation", 10)
	scroll.add_child(roster_box)

func _refresh() -> void:
	for child in room_layer.get_children():
		if child.name.begins_with("Resident"):
			child.queue_free()
	for child in roster_box.get_children(): child.queue_free()
	var assigned := GameState.get_area_residents(area_id)
	status.text = "%d / 6 residents" % assigned.size()
	if assigned.is_empty():
		var empty := _label("This clearing is waiting for its first friend.", 31, CampStyle.CREAM)
		empty.name = "ResidentEmpty"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.set_anchors_preset(Control.PRESET_CENTER_TOP)
		empty.anchor_left = 0.0
		empty.anchor_right = 1.0
		empty.offset_top = -30
		empty.offset_bottom = 40
		room_layer.add_child(empty)
	else:
		for i in range(mini(assigned.size(), 6)):
			_add_resident_to_room(_find_cryptid(str(assigned[i])), i)

	var adopted: Array = []
	for c in GameState.state.get("cryptids", []):
		if c.get("adopted", false): adopted.append(c)
	if adopted.is_empty():
		roster_box.add_child(_label("Befriend a cryptid and it will appear here.", 26, CampStyle.INK))
	for c in adopted:
		var row := HBoxContainer.new()
		var name := _label("%s  ·  %s" % [_display_name(c), _species_name(c)], 27, CampStyle.INK)
		name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name)
		var here := str(c.get("id","")) in assigned
		var action := _button("Remove" if here else "Move Here", "paper")
		action.custom_minimum_size = Vector2(190, 78)
		action.disabled = not here and assigned.size() >= 6
		action.pressed.connect((_remove if here else _assign).bind(str(c.get("id",""))))
		row.add_child(action)
		roster_box.add_child(row)

func _add_resident_to_room(c: Dictionary, index: int) -> void:
	if c.is_empty(): return
	var pos: Vector2 = RESIDENT_POSITIONS[index]
	var resident := VBoxContainer.new()
	resident.name = "Resident%d" % index
	resident.alignment = BoxContainer.ALIGNMENT_CENTER
	resident.set_anchors_preset(Control.PRESET_TOP_LEFT)
	resident.anchor_left = pos.x
	resident.anchor_top = pos.y
	resident.anchor_right = pos.x
	resident.anchor_bottom = pos.y
	resident.position = Vector2(-105, -120)
	resident.custom_minimum_size = Vector2(210, 240)

	var portrait := TextureButton.new()
	portrait.ignore_texture_size = true
	portrait.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size = Vector2(210, 180)
	portrait.texture_normal = _resident_texture(c)
	portrait.tooltip_text = "%s · %s" % [_display_name(c), _species_name(c)]
	portrait.pressed.connect(_resident_tapped.bind(c))
	resident.add_child(portrait)
	var name := _label(_display_name(c), 28, CampStyle.CREAM)
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resident.add_child(name)
	var species := _label(_species_name(c), 20, Color("ead49d"))
	species.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resident.add_child(species)
	room_layer.add_child(resident)

func _resident_texture(c: Dictionary) -> Texture2D:
	var species := str(c.get("species","")).to_lower()
	var variant := str(c.get("variant","classic")).to_lower()
	var texture := ArtRegistry.texture_for("cryptid.%s.%s" % [species, variant])
	if texture == null:
		texture = ArtRegistry.texture_for("cryptid.%s.classic" % species)
	return texture

func _resident_tapped(c: Dictionary) -> void:
	status.text = "%s is enjoying %s." % [_display_name(c), str(area.get("name","camp"))]

func _show_decorate_note() -> void:
	status.text = "Decorating this area is coming next."

func _show_area_info() -> void:
	status.text = "%s · Up to 6 cryptids can call this place home." % str(area.get("name","Sanctuary"))

func _find_cryptid(id: String) -> Dictionary:
	for c in GameState.state.get("cryptids", []):
		if str(c.get("id","")) == id: return c
	return {}

func _display_name(c: Dictionary) -> String:
	var chosen := str(c.get("name","")).strip_edges()
	if not chosen.is_empty(): return chosen
	return _species_name(c)

func _species_name(c: Dictionary) -> String:
	return str(c.get("species","Cryptid")).replace("_"," ").capitalize()

func _assign(id: String) -> void:
	GameState.assign_resident_to_area(area_id, id)
	_refresh()

func _remove(id: String) -> void:
	GameState.remove_resident_from_area(area_id, id)
	_refresh()

func _toggle_roster() -> void:
	roster_panel.visible = not roster_panel.visible

func _label(value: String, size: int, color := CampStyle.CREAM) -> Label:
	var l := Label.new()
	l.text = value
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _button(value: String, kind := "wood") -> Button:
	var b := Button.new()
	b.text = value
	CampStyle.button(b, kind)
	b.add_theme_font_size_override("font_size", 26)
	return b
