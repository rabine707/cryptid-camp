extends Control

const AREA_ORDER := ["camp_clearing","whispering_grove","misty_wetlands","highland_hollow","dusty_outpost"]
const AREA_DESCRIPTIONS := {
	"camp_clearing":"The heart of your sanctuary.",
	"whispering_grove":"A peaceful forest filled with towering trees and soft light.",
	"misty_wetlands":"Reeds, ponds, and foggy little hiding places.",
	"highland_hollow":"Cool mountain air and rocky overlooks.",
	"dusty_outpost":"Warm stone, open skies, and desert trails."
}

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color("13282b")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side, 34)
	for side in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side, 34)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 22)
	margin.add_child(column)
	var top := HBoxContainer.new()
	column.add_child(top)
	var back := _button("‹ Camp")
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/main.tscn"))
	top.add_child(back)
	var title := _label("Sanctuary", 64)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	column.add_child(_label("Choose an area to visit. Each area can house up to 6 cryptids.", 31))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 20)
	scroll.add_child(list)
	var areas := GameState.get_sanctuary_areas()
	for area_id in AREA_ORDER:
		if not areas.has(area_id): continue
		var data: Dictionary = areas[area_id]
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", CampStyle.panel(Color("f1dfb4"), 18, 5, Color("5b3a24")))
		var row := HBoxContainer.new()
		row.custom_minimum_size.y = 210
		panel.add_child(row)
		var text_box := VBoxContainer.new()
		text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(text_box)
		var name := str(data.get("name", area_id))
		text_box.add_child(_label(name, 43, Color("342417")))
		text_box.add_child(_label(AREA_DESCRIPTIONS.get(area_id, ""), 27, Color("5c4937")))
		var count: int = int(data.get("residents", []).size())
		var status := "%d / 6 Residents" % count if data.get("unlocked", false) else "Locked · discover more areas"
		text_box.add_child(_label(status, 29, Color("41604b")))
		var visit := _button("Visit ›" if data.get("unlocked", false) else "🔒")
		visit.disabled = not data.get("unlocked", false)
		visit.custom_minimum_size.x = 190
		visit.pressed.connect(_visit_area.bind(area_id))
		row.add_child(visit)
		list.add_child(panel)

func _visit_area(area_id: String) -> void:
	GameState.state["active_sanctuary_area"] = area_id
	GameState.persist()
	get_tree().change_scene_to_file("res://scenes/sanctuary/area.tscn")

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
	b.custom_minimum_size.y = 110
	CampStyle.button(b, "wood")
	b.add_theme_font_size_override("font_size", 32)
	return b
