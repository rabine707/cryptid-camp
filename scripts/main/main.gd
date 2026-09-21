extends Control

func _ready() -> void:
	var artwork := TextureRect.new()
	artwork.texture = ArtRegistry.texture_for("background.main_menu")
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	artwork.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(artwork)
	move_child(artwork, 1)
	var atmosphere := preload("res://scripts/art/camp_atmosphere.gd").new()
	atmosphere.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(atmosphere)
	move_child(atmosphere, 2)
	$Margin/VBox/Sign.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	$Margin/VBox/Sign/Title.add_theme_color_override("font_color", Color("f5e5ba"))
	$Margin/VBox/Sign/Title.add_theme_color_override("font_shadow_color", Color("09130f"))
	$Margin/VBox/Sign/Title.add_theme_constant_override("shadow_offset_y", 6)
	$Margin/VBox/Version.text = "A little strange. A little like home."
	$Margin/VBox/Version.add_theme_font_size_override("font_size", 28)
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
	# Calm translucent navigation lets the painting remain the focal point.
	for button in [$Margin/VBox/Sanctuary, $Margin/VBox/Journal]:
		button.add_theme_stylebox_override("normal", CampStyle.panel(Color(0.025, 0.09, 0.075, 0.91), 18, 2, Color("67735b")))
	$Margin/VBox/WhisperingWoods.add_theme_stylebox_override("normal", CampStyle.panel(Color("b88a45"), 18, 2, Color("e9cd8f")))
	$Margin/VBox/WhisperingWoods.add_theme_color_override("font_color", Color("15251d"))

func _open_whispering_woods() -> void:
	get_tree().change_scene_to_file("res://scenes/lure_sites/whispering_woods.tscn")

func _open_sanctuary() -> void:
	get_tree().change_scene_to_file("res://scenes/sanctuary/sanctuary.tscn")

func _open_journal() -> void:
	get_tree().change_scene_to_file("res://scenes/journal/journal.tscn")
