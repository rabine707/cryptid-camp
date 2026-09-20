extends Control

@onready var preview: Label = $Margin/VBox/Preview/PreviewText
@onready var events_box: VBoxContainer = $Margin/VBox/Events
@onready var return_button: Button = $Margin/VBox/Return

var encounter_unlocked := false

func _ready() -> void:
	CampStyle.button(return_button, "green")
	CampStyle.parchment($Margin/VBox/Preview)
	$Margin/VBox/Preview/PreviewText.add_theme_color_override("font_color", CampStyle.INK)
	return_button.pressed.connect(_primary_action)
	_process_evidence()
	_render_events()

func _process_evidence() -> void:
	for event in TrailCamSession.events:
		if event.get("type") == "evidence":
			var species := str(event.get("cryptid", ""))
			var evidence_id := str(event.get("evidence", ""))
			var count := GameState.add_evidence(species, evidence_id)
			if species == "mothling" and count >= 1:
				GameState.discover_species("mothling")
				encounter_unlocked = true

func _render_events() -> void:
	var events := TrailCamSession.events
	if events.is_empty():
		preview.text = "No footage recovered."
		return
	var visitor := TrailCamSession.visitor_id
	if visitor == "mothling":
		preview.text = "🔴     🔴\n\n...something is watching the lantern."
	elif visitor == "bigfoot":
		preview.text = "🌲   ?   🌲\n\nThe subject stayed outside the frame."
	elif visitor == "nightcrawler":
		preview.text = "🌙\n\n      〰  〰\n\nA pale shape crossed the clearing."
	else:
		preview.text = "🌲   📷   🌲\n\nMotion detected. Subject unknown."
	for event in events:
		var card := Label.new()
		card.text = "• " + str(event.get("text", "Unknown event"))
		card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_theme_font_size_override("font_size", 27)
		events_box.add_child(card)
	if encounter_unlocked:
		return_button.text = "Follow the Red Eyes"
	else:
		return_button.text = "Return to Clearing"

func _primary_action() -> void:
	if encounter_unlocked:
		get_tree().change_scene_to_file("res://scenes/encounters/mothling_encounter.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/lure_sites/whispering_woods.tscn")
