extends Control

@onready var resident_name: Label = $Margin/VBox/Yard/YardControl/ResidentName
@onready var resident_details: Label = $Margin/VBox/Yard/YardControl/ResidentDetails
@onready var creature: Label = $Margin/VBox/Yard/YardControl/Creature
@onready var lamp_spot: Label = $Margin/VBox/Yard/YardControl/LampSpot
@onready var lamp_button: Button = $Margin/VBox/Lamp
@onready var moment: Label = $Margin/VBox/Moment

var resident: Dictionary = {}
var home_position := Vector2(420,330)
var lamp_position := Vector2(170,430)

func _ready() -> void:
	CampStyle.button($Margin/VBox/Header/Back, "wood")
	CampStyle.button(lamp_button, "green")
	CampStyle.parchment($Margin/VBox/Yard)
	$Margin/VBox/Header/Back.pressed.connect(_go_map)
	lamp_button.pressed.connect(_place_lamp)
	resident = GameState.get_adopted_species("mothling")
	_render()

func _render() -> void:
	if resident.is_empty():
		resident_name.text = "No residents yet"
		resident_details.text = "Whispering Woods is waiting."
		creature.text = "?"
		lamp_button.disabled = true
		return
	resident_name.text = str(resident.get("name", "Mothling"))
	resident_details.text = "%s Mothling • %s • %s\nTrust: %s" % [
		str(resident.get("variant", "classic")).capitalize(),
		resident.get("personality", "Curious"),
		resident.get("quirk", "Clingy"),
		CryptidFactory.trust_stage(int(resident.get("trust", 0)))
	]
	creature.text = "ʚɞ\n•ᴗ•"
	if GameState.has_moment("warm_glow"):
		_show_warm_glow(false)
	else:
		_start_idle_motion()

func _start_idle_motion() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(creature, "position", home_position + Vector2(45,-12), 2.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(creature, "position", home_position + Vector2(-30,8), 2.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(creature, "position", home_position, 1.8).set_trans(Tween.TRANS_SINE)

func _place_lamp() -> void:
	if resident.is_empty(): return
	GameState.place_sanctuary_decoration("old_lamp")
	GameState.unlock_moment("warm_glow")
	_show_warm_glow(true)

func _show_warm_glow(is_new: bool) -> void:
	lamp_spot.text = "🏮"
	lamp_button.text = "🏮  Old Lamp Placed"
	lamp_button.disabled = true
	var tween := create_tween()
	tween.tween_property(creature, "position", lamp_position, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	creature.text = "ʚɞ ♡"
	if is_new:
		moment.text = "✨ MOMENT DISCOVERED — Warm Glow\n%s has decided this lamp belongs to them now." % resident.get("name","Your Mothling")
	else:
		moment.text = "✨ Warm Glow — The lamp still has a permanent Mothling attached."

func _go_map() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
