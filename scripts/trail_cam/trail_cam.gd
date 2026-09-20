extends Control

@onready var preview: Label = $Margin/VBox/Preview/PreviewText
@onready var events_box: VBoxContainer = $Margin/VBox/Events
@onready var return_button: Button = $Margin/VBox/Return
var encounter_unlocked := false

func _ready() -> void:
	CampStyle.button(return_button, "green")
	CampStyle.parchment($Margin/VBox/Preview)
	preview.add_theme_color_override("font_color", CampStyle.INK)
	return_button.pressed.connect(_primary_action)
	_process_evidence()
	_render_events()

func _process_evidence() -> void:
	for event in TrailCamSession.events:
		if event.get("type") == "evidence":
			var species := str(event.get("cryptid",""))
			var count := GameState.add_evidence(species, str(event.get("evidence","")))
			if species == "mothling" and count >= 1:
				GameState.discover_species("mothling")
				encounter_unlocked = true

func _render_events() -> void:
	var events := TrailCamSession.events
	if events.is_empty():
		preview.text = "REC  00:14:22\n\n🌲       🌲\n\nNo usable subject."
	else:
		match TrailCamSession.visitor_id:
			"mothling":
				preview.text = "REC  00:14:22   CAM 01\n\n🌲    🔴  🔴    🌲\n\n      ▴  ʚɞ  ▴\n\nMOTION DETECTED"
			"bigfoot":
				preview.text = "REC  02:41:09   CAM 01\n\n🌲   ▓▓?▓▓   🌲\n\nSUBJECT OFF FRAME"
			"nightcrawler":
				preview.text = "REC  03:07:51   CAM 01\n\n☾\n\n      〰   〰\n\nMOTION DETECTED"
			_:
				preview.text = "REC  01:12:03   CAM 01\n\n🌲   📷   🌲\n\nMOTION DETECTED"
	for event in events:
		var card := Label.new()
		card.text = "• " + str(event.get("text","Unknown event"))
		card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_theme_font_size_override("font_size",27)
		events_box.add_child(card)
	return_button.text = "Follow the Red Eyes" if encounter_unlocked else "Return to Clearing"

func _primary_action() -> void:
	get_tree().change_scene_to_file("res://scenes/encounters/mothling_encounter.tscn" if encounter_unlocked else "res://scenes/lure_sites/whispering_woods.tscn")
