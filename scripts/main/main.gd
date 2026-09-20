extends Control

func _ready() -> void:
	CampStyle.parchment($Margin/VBox/Sign)
	$Margin/VBox/Sign/Title.add_theme_color_override("font_color", CampStyle.INK)
	for path in ["WhisperingWoods", "Sanctuary"]:
		CampStyle.button($Margin/VBox.get_node(path), "wood")
	CampStyle.button($Margin/VBox/Journal, "green")
	$Margin/VBox/WhisperingWoods.pressed.connect(_open_whispering_woods)
	$Margin/VBox/Sanctuary.pressed.connect(_open_sanctuary)
	$Margin/VBox/Journal.pressed.connect(_open_journal)

func _open_whispering_woods() -> void:
	get_tree().change_scene_to_file("res://scenes/lure_sites/whispering_woods.tscn")

func _open_sanctuary() -> void:
	get_tree().change_scene_to_file("res://scenes/sanctuary/sanctuary.tscn")

func _open_journal() -> void:
	get_tree().change_scene_to_file("res://scenes/journal/journal.tscn")
