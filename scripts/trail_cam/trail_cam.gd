extends Control

const CameraArt = preload("res://scripts/trail_cam/night_vision.gd")
var species := ""
var first_hunt := false
var collected := false
var revealed := false
var alternate_checked := false
var camera: Control
var content: VBoxContainer
var primary: Button
var secondary: Button
var heading: Label
var hint: Label
var evidence_box: VBoxContainer
var suspects: Label

func _ready() -> void:
	species = TrailCamSession.visitor_id
	first_hunt = GameState.needs_first_hunt()
	collected = not GameState.evidence_for(species).is_empty()
	_build_ui()
	_render()

func _label(text: String, font_size: int, color := Color("e5e9d5")) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("09130f")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 42)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 20)
	margin.add_child(column)
	var top := HBoxContainer.new()
	column.add_child(top)
	var title := _label("TRAIL CAM", 54)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	var back := Button.new()
	back.text = "Camp"
	back.custom_minimum_size = Vector2(180, 150)
	CampStyle.button(back, "wood")
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/main.tscn"))
	top.add_child(back)
	column.add_child(_label("WHISPERING WOODS / NIGHT", 30, Color("9cab87")))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 22)
	scroll.add_child(content)
	camera = CameraArt.new()
	camera.visitor = species
	camera.custom_minimum_size = Vector2(0, 580)
	content.add_child(camera)
	heading = _label("", 42, Color("e7c582"))
	content.add_child(heading)
	hint = _label("", 35)
	content.add_child(hint)
	content.add_child(_label("TONIGHT'S EVIDENCE", 30, Color("9cab87")))
	evidence_box = VBoxContainer.new()
	evidence_box.add_theme_constant_override("separation", 12)
	content.add_child(evidence_box)
	suspects = _label("", 32, Color("b9caa4"))
	content.add_child(suspects)
	secondary = Button.new()
	secondary.custom_minimum_size.y = 150
	CampStyle.button(secondary, "wood")
	secondary.add_theme_font_size_override("font_size", 34)
	secondary.pressed.connect(_secondary_action)
	column.add_child(secondary)
	primary = Button.new()
	primary.custom_minimum_size.y = 150
	CampStyle.button(primary, "green")
	primary.add_theme_font_size_override("font_size", 38)
	primary.pressed.connect(_primary_action)
	column.add_child(primary)

func _render() -> void:
	for child in evidence_box.get_children():
		evidence_box.remove_child(child)
		child.queue_free()
	var evidence := GameState.evidence_for(species)
	for clue in evidence:
		if FieldResearch.CLUES.has(clue):
			var card := PanelContainer.new()
			card.add_theme_stylebox_override("panel", CampStyle.panel(Color("17291e"), 12, 1, Color("3e5234")))
			card.add_child(_label("RECORDED / " + str(FieldResearch.CLUES[clue].label), 33))
			evidence_box.add_child(card)
	if evidence_box.get_child_count() == 0:
		evidence_box.add_child(_label("No clues recorded yet. Review this camera trigger.", 33, Color("9cab87")))
	var possible := FieldResearch.candidates(evidence)
	var names: Array[String] = []
	for id in possible:
		names.append(FieldResearch.NAMES[id])
	suspects.text = "Possible cryptids: %d\n%s" % [possible.size(), " / ".join(names)]
	secondary.visible = false
	if not FieldResearch.TRAILS.has(species):
		heading.text = "The woods are keeping quiet"
		hint.text = "Nothing clear enough to record. Change the objects in your clearing and observe again."
		primary.text = "Return to Clearing"
		suspects.text = ""
	elif revealed:
		heading.text = str(FieldResearch.NAMES[species]).to_upper() + " DISCOVERED"
		hint.text = "Added to your Field Journal. You followed the evidence and identified your visitor."
		if species == "mothling":
			hint.text += " Now meet it gently to build trust and eventually invite it home."
		primary.text = "Meet the Mothling" if species == "mothling" else "Return to Clearing"
		secondary.visible = true
		secondary.text = "Open Field Journal"
		suspects.text = "IDENTIFICATION CONFIRMED / Saved to your collection"
		camera.reveal = true
	elif GameState.is_discovered(species):
		heading.text = "A familiar visitor"
		hint.text = "Your Field Journal already knows this creature."
		if GameState.has_second_hunt_hint():
			hint.text += " For a new discovery, change your lure objects and collect more than one clue."
		primary.text = "Visit the Mothling" if species == "mothling" else "Return to Clearing"
	elif not collected:
		heading.text = "01 / Something triggered the camera" if first_hunt else "New camera trigger"
		hint.text = "Cryptids leave evidence. Record what the camera caught, then investigate to learn who's out there." if first_hunt else "Record this sighting in your Field Journal."
		primary.text = "Collect Camera Evidence"
		suspects.text = "Review the footage to start narrowing the possibilities."
	elif FieldResearch.can_identify(species, evidence):
		heading.text = "04 / Identification ready" if first_hunt else "Identification ready"
		hint.text = "The wings and fascination with light confirm one visitor. Make your identification." if first_hunt else "Your clues point to one creature. Confirm it in your Field Journal."
		primary.text = "Identify " + str(FieldResearch.NAMES[species])
	else:
		var next := FieldResearch.next_clue(species, evidence)
		heading.text = ("02 / Where will you investigate?" if next == "wing_shadow" else "03 / One more clue") if first_hunt else "Investigate the sighting"
		hint.text = "Red eyes alone aren't enough. Follow them quietly to look for another clue." if next == "wing_shadow" else "The wing-shaped shadow narrows it to Mothling. Watch what it does near the light to confirm."
		if not first_hunt:
			hint.text = "Another piece of evidence will help confirm your visitor." if GameState.has_second_hunt_hint() else "Choose a trail to investigate."
		if alternate_checked:
			hint.text = "No clear tracks here. Nothing lost: the camera's trail is still waiting."
		primary.text = {"wing_shadow": "Follow the Red Eyes", "light_fascination": "Watch the Lantern", "wood_knock": "Follow the Footprints", "long_stride": "Watch the Open Ground"}.get(next, "Investigate")
		secondary.visible = true
		secondary.text = "Search for Tracks" if species == "mothling" else "Check Another Camera"

func _primary_action() -> void:
	if revealed or GameState.is_discovered(species):
		get_tree().change_scene_to_file("res://scenes/encounters/mothling_encounter.tscn" if species == "mothling" else "res://scenes/lure_sites/whispering_woods.tscn")
	elif not FieldResearch.TRAILS.has(species):
		get_tree().change_scene_to_file("res://scenes/lure_sites/whispering_woods.tscn")
	elif not collected:
		for event in TrailCamSession.events:
			if event.get("type") == "evidence" and event.get("cryptid") == species:
				GameState.add_evidence(species, str(event.get("evidence", "")))
		collected = true
		_render()
	elif FieldResearch.can_identify(species, GameState.evidence_for(species)):
		revealed = GameState.identify_species(species)
		_render()
	else:
		GameState.add_evidence(species, FieldResearch.next_clue(species, GameState.evidence_for(species)))
		alternate_checked = false
		_render()

func _secondary_action() -> void:
	if revealed:
		get_tree().change_scene_to_file("res://scenes/journal/journal.tscn")
	else:
		alternate_checked = true
		_render()
