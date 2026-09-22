extends Control

var selected_species := "mothling"

func _ready() -> void:
	CampStyle.button($Margin/VBox/Header/Back, "wood")
	CampStyle.parchment($Margin/VBox/Page)
	_set_ink($Margin/VBox/Page/Content)
	$Margin/VBox/Header/Back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/main.tscn"))
	var picker := OptionButton.new()
	picker.custom_minimum_size.y = 144
	picker.get_popup().add_theme_font_size_override("font_size", 44)
	picker.get_popup().add_theme_constant_override("v_separation", 48)
	CampStyle.button(picker, "wood")
	picker.add_theme_font_size_override("font_size", 36)
	for id in FieldResearch.NAMES:
		picker.add_item(FieldResearch.NAMES[id] if GameState.is_discovered(id) else "Unknown / " + str(picker.item_count + 1))
	picker.item_selected.connect(func(index: int): selected_species = FieldResearch.NAMES.keys()[index]; _render())
	$Margin/VBox.add_child(picker)
	$Margin/VBox.move_child(picker, 1)
	var sketchbook := Button.new()
	sketchbook.text = "Camp sketchbook"
	sketchbook.custom_minimum_size.y = 132
	CampStyle.button(sketchbook, "wood")
	sketchbook.add_theme_font_size_override("font_size", 38)
	sketchbook.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/journal/sketchbook.tscn"))
	$Margin/VBox.add_child(sketchbook)
	_render()

func _set_ink(node: Node) -> void:
	for child in node.get_children():
		if child is Label:
			child.add_theme_color_override("font_color", CampStyle.INK)
			if child.name in ["Notes", "Resident", "Status"]:
				child.add_theme_font_override("font", ThemeDB.fallback_font)
		_set_ink(child)

func _render() -> void:
	var discovered := GameState.is_discovered(selected_species)
	var evidence := GameState.evidence_for(selected_species)
	var resident := GameState.get_adopted_species(selected_species)
	$Margin/VBox/Page/Content/Species.text = str(FieldResearch.NAMES[selected_species]).to_upper() if discovered else "UNKNOWN VISITOR"
	$Margin/VBox/Page/Content/Sketch.visible = discovered
	$Margin/VBox/Page/Content/Sketch.set_species(selected_species)
	$Margin/VBox/Page/Content/Status.text = "DISCOVERED" if discovered else ("DOCUMENTED" if not evidence.is_empty() else "RUMORED")
	var notes := "No reliable notes yet. Place a lure in Whispering Woods and review your Trail Cam."
	if not evidence.is_empty():
		notes = "Evidence recorded: %d\n" % evidence.size()
		for clue in evidence:
			if FieldResearch.CLUES.has(clue):
				notes += "\n- " + str(FieldResearch.CLUES[clue].label)
	if discovered and selected_species == "mothling":
		notes += "\n\nCurious, cautious, and much fluffier than the rumors suggested. Visit it to build trust, then invite it home at 80 trust."
	elif discovered:
		notes += "\n\nRecorded in your collection. This visitor's trust and adoption encounter is not available in this milestone."
	$Margin/VBox/Page/Content/Notes.text = notes
	$Margin/VBox/Page/Content/Resident.text = ""
	if not resident.is_empty():
		$Margin/VBox/Page/Content/Resident.text = "CAMP RESIDENT\n%s / %s / %s / %s" % [resident.get("name","Mothling"), str(resident.get("variant","classic")).capitalize(), resident.get("personality","Curious"), resident.get("quirk","Clingy")]
