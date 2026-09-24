extends Control

var area_id := "whispering_grove"
var area: Dictionary = {}
var residents_box: VBoxContainer
var roster_box: VBoxContainer
var status: Label

func _ready() -> void:
	area_id = str(GameState.state.get("active_sanctuary_area", "whispering_grove"))
	area = GameState.get_sanctuary_areas().get(area_id, {})
	var bg := ColorRect.new()
	bg.color = Color("10232a")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side, 34)
	for side in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side, 30)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	margin.add_child(column)
	var top := HBoxContainer.new()
	column.add_child(top)
	var back := _button("‹ Areas")
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/sanctuary/area_selector.tscn"))
	top.add_child(back)
	var title := _label(str(area.get("name","Sanctuary Area")), 58)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	status = _label("", 30, Color("d7bd82"))
	column.add_child(status)
	var scene_panel := PanelContainer.new()
	scene_panel.custom_minimum_size.y = 560
	scene_panel.add_theme_stylebox_override("panel", CampStyle.panel(Color("183d38"), 22, 5, Color("d0a35e")))
	column.add_child(scene_panel)
	residents_box = VBoxContainer.new()
	residents_box.alignment = BoxContainer.ALIGNMENT_CENTER
	residents_box.add_theme_constant_override("separation", 12)
	scene_panel.add_child(residents_box)
	var manage := _button("Manage Residents")
	manage.pressed.connect(_toggle_roster)
	column.add_child(manage)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size.y = 520
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	roster_box = VBoxContainer.new()
	roster_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	roster_box.add_theme_constant_override("separation", 12)
	scroll.add_child(roster_box)
	_refresh()

func _refresh() -> void:
	for child in residents_box.get_children(): child.queue_free()
	for child in roster_box.get_children(): child.queue_free()
	var assigned := GameState.get_area_residents(area_id)
	status.text = "%d / 6 Residents · Tap Manage Residents to change who lives here." % assigned.size()
	if assigned.is_empty():
		residents_box.add_child(_label("This area is waiting for its first resident.", 34))
	else:
		for cryptid_id in assigned:
			var c := _find_cryptid(str(cryptid_id))
			residents_box.add_child(_label("🐾  %s · %s" % [_display_name(c), str(c.get("species","Unknown")).capitalize()], 34))
	var adopted: Array = []
	for c in GameState.state.get("cryptids", []):
		if c.get("adopted", false): adopted.append(c)
	if adopted.is_empty():
		roster_box.add_child(_label("Befriend a cryptid and it will appear here.", 30))
	for c in adopted:
		var row := HBoxContainer.new()
		var name := _label("%s  ·  %s" % [_display_name(c), str(c.get("species","")).capitalize()], 30, Color("f3e5bc"))
		name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name)
		var here := str(c.get("id","")) in assigned
		var action := _button("Remove" if here else "Move Here")
		action.custom_minimum_size = Vector2(220, 90)
		action.disabled = not here and assigned.size() >= 6
		action.pressed.connect((_remove if here else _assign).bind(str(c.get("id",""))))
		row.add_child(action)
		roster_box.add_child(row)

func _find_cryptid(id: String) -> Dictionary:
	for c in GameState.state.get("cryptids", []):
		if str(c.get("id","")) == id: return c
	return {}

func _display_name(c: Dictionary) -> String:
	var chosen := str(c.get("name","")).strip_edges()
	if not chosen.is_empty(): return chosen
	return str(c.get("species","Cryptid")).capitalize()

func _assign(id: String) -> void:
	GameState.assign_resident_to_area(area_id, id)
	_refresh()

func _remove(id: String) -> void:
	GameState.remove_resident_from_area(area_id, id)
	_refresh()

func _toggle_roster() -> void:
	roster_box.visible = not roster_box.visible

func _label(value: String, size: int, color := Color("f3e5bc")) -> Label:
	var l := Label.new()
	l.text = value
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _button(value: String) -> Button:
	var b := Button.new()
	b.text = value
	b.custom_minimum_size.y = 105
	CampStyle.button(b, "wood")
	b.add_theme_font_size_override("font_size", 30)
	return b
