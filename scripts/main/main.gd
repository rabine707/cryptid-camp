extends Control

func _ready() -> void:
	CampStyle.parchment($Margin/VBox/Sign)
	$Margin/VBox/Sign/Title.add_theme_color_override("font_color", CampStyle.INK)
	for path in ["WhisperingWoods", "Sanctuary"]:
		CampStyle.button($Margin/VBox.get_node(path), "wood")
	CampStyle.button($Margin/VBox/Journal, "green")
	for control in [$Margin/VBox/WhisperingWoods, $Margin/VBox/Sanctuary, $Margin/VBox/Journal]:
		control.add_theme_font_size_override("font_size", 36)
	$Margin/VBox/WhisperingWoods.pressed.connect(_open_whispering_woods)
	$Margin/VBox/Sanctuary.pressed.connect(_open_sanctuary)
	$Margin/VBox/Journal.pressed.connect(_open_journal)
	if GameState.needs_first_hunt():
		$Margin/VBox/WhisperingWoods.text = "Find Your First Cryptid"
		$Margin/VBox/Tagline.text = "Start in Whispering Woods. Your Trail Cam is waiting."
		$Margin/VBox/Tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		CampStyle.button($Margin/VBox/WhisperingWoods, "green")
		$Margin/VBox/WhisperingWoods.add_theme_font_size_override("font_size", 36)

func _open_whispering_woods() -> void:
	get_tree().change_scene_to_file("res://scenes/lure_sites/whispering_woods.tscn")

func _open_sanctuary() -> void:
	get_tree().change_scene_to_file("res://scenes/sanctuary/sanctuary.tscn")

func _open_journal() -> void:
	get_tree().change_scene_to_file("res://scenes/journal/journal.tscn")
