extends Control

@onready var resident_name: Label = $Margin/VBox/ResidentArea/ResidentVBox/ResidentName
@onready var resident_details: Label = $Margin/VBox/ResidentArea/ResidentVBox/ResidentDetails
@onready var creature: Label = $Margin/VBox/ResidentArea/ResidentVBox/Creature
@onready var lamp_button: Button = $Margin/VBox/Lamp
@onready var moment: Label = $Margin/VBox/Moment

var resident: Dictionary = {}

func _ready() -> void:
	CampStyle.button($Margin/VBox/Header/Back, "wood")
	CampStyle.button(lamp_button, "green")
	CampStyle.parchment($Margin/VBox/ResidentArea)
	resident_name.add_theme_color_override("font_color", CampStyle.INK)
	resident_details.add_theme_color_override("font_color", CampStyle.INK)
	creature.add_theme_color_override("font_color", CampStyle.INK)
	$Margin/VBox/Header/Back.pressed.connect(_go_map)
	lamp_button.pressed.connect(_place_lamp)
	resident = GameState.get_adopted_species("mothling")
	_render()

func _render() -> void:
	if resident.is_empty():
		resident_name.text = "No residents yet"
		resident_details.text = "Whispering Woods is waiting."
		creature.text = "🌲       🌲"
		lamp_button.disabled = true
		return
	resident_name.text = str(resident.get("name", "Mothling"))
	resident_details.text = "%s Mothling • %s • %s\nTrust: %s" % [
		str(resident.get("variant", "classic")).capitalize(),
		resident.get("personality", "Curious"),
		resident.get("quirk", "Clingy"),
		CryptidFactory.trust_stage(int(resident.get("trust", 0)))
	]
	if GameState.has_moment("warm_glow"):
		_show_warm_glow(false)

func _place_lamp() -> void:
	if resident.is_empty():
		return
	GameState.place_sanctuary_decoration("old_lamp")
	_show_warm_glow(true)

func _show_warm_glow(is_new: bool) -> void:
	creature.text = "🏮  🦋\n\n     ♡"
	lamp_button.text = "🏮  Old Lamp"
	lamp_button.disabled = true
	if is_new:
		GameState.unlock_moment("warm_glow")
		moment.text = "✨ MOMENT DISCOVERED\nWarm Glow\n%s has decided this lamp belongs to them now." % resident.get("name", "Your Mothling")
	else:
		moment.text = "✨ Warm Glow — This lamp has a permanent Mothling attached."

func _go_map() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
