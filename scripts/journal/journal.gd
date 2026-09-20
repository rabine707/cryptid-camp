extends Control

func _ready() -> void:
	CampStyle.button($Margin/VBox/Header/Back, "wood")
	CampStyle.parchment($Margin/VBox/Page)
	_set_ink($Margin/VBox/Page/Content)
	$Margin/VBox/Header/Back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main/main.tscn"))
	_render()

func _set_ink(node: Node) -> void:
	for child in node.get_children():
		if child is Label:
			child.add_theme_color_override("font_color", CampStyle.INK)
		_set_ink(child)

func _render() -> void:
	var discovered := GameState.is_discovered("mothling")
	var evidence: Array = GameState.state.get("evidence", {}).get("mothling", [])
	var resident := GameState.get_adopted_species("mothling")
	if discovered:
		$Margin/VBox/Page/Content/Species.text = "MOTHLING"
		$Margin/VBox/Page/Content/Sketch.text = "  ╱\\  ʚɞ  /╲\n     •ᴗ•"
		$Margin/VBox/Page/Content/Status.text = "DISCOVERED"
		$Margin/VBox/Page/Content/Notes.text = "Observed near artificial light after dark. Seems curious, cautious, and much fluffier than the rumors suggested.\n\nEvidence recorded: %d" % evidence.size()
	elif evidence.size() > 0:
		$Margin/VBox/Page/Content/Status.text = "DOCUMENTED"
		$Margin/VBox/Page/Content/Notes.text = "Faint red eyes. Movement near the light. Something winged is visiting the clearing."
	if not resident.is_empty():
		$Margin/VBox/Page/Content/Resident.text = "CAMP RESIDENT\n%s • %s • %s • %s" % [resident.get("name","Mothling"), str(resident.get("variant","classic")).capitalize(), resident.get("personality","Curious"), resident.get("quirk","Clingy")]
