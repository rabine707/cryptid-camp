extends Control

@onready var preview: Label = $Margin/VBox/Preview/PreviewText
@onready var events_box: VBoxContainer = $Margin/VBox/Events

func _ready() -> void:
	$Margin/VBox/Return.pressed.connect(_return_to_clearing)
	_render_events()

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

func _return_to_clearing() -> void:
	get_tree().change_scene_to_file("res://scenes/lure_sites/whispering_woods.tscn")
