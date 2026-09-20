extends Control

var mothling: Dictionary
var action_count := 0
var rng := RandomNumberGenerator.new()

@onready var details: Label = $Margin/VBox/Details
@onready var trust_label: Label = $Margin/VBox/Trust
@onready var message: Label = $Margin/VBox/Message

func _ready() -> void:
	rng.randomize()
	CampStyle.button($Margin/VBox/Actions/Treat, "wood")
	CampStyle.button($Margin/VBox/Actions/Observe, "wood")
	CampStyle.button($Margin/VBox/Actions/Photo, "wood")
	CampStyle.button($Margin/VBox/Leave, "green")
	mothling = GameState.ensure_wild_individual("mothling", rng)
	$Margin/VBox/Actions/Treat.pressed.connect(_treat)
	$Margin/VBox/Actions/Observe.pressed.connect(_observe)
	$Margin/VBox/Actions/Photo.pressed.connect(_photo)
	$Margin/VBox/Leave.pressed.connect(_leave)
	_render()

func _render() -> void:
	var variant := str(mothling.get("variant", "classic")).capitalize()
	details.text = "%s • %s • %s\n%s" % [
		variant,
		mothling.get("size", "Average"),
		mothling.get("personality", "Curious"),
		"A " + str(mothling.get("quirk", "mysterious")) + " little visitor."
	]
	var trust := int(mothling.get("trust", 0))
	trust_label.text = "Trust: %s  •  %d/100" % [CryptidFactory.trust_stage(trust), trust]

func _treat() -> void:
	_apply_action(8, "It sniffs the treat, then scoots closer. Very slightly.")

func _observe() -> void:
	_apply_action(5, "You stay quiet. It seems relieved you aren't chasing it.")

func _photo() -> void:
	var amount := 2
	if mothling.get("quirk") == "Camera Shy":
		amount = 0
	_apply_action(amount, "Click. The Mothling stares directly into the lens.")

func _apply_action(amount: int, text: String) -> void:
	if action_count >= 3:
		message.text = "It has had enough excitement for one visit. Better not push it."
		return
	action_count += 1
	mothling = GameState.change_trust(str(mothling.get("id")), amount)
	message.text = text
	_render()
	if int(mothling.get("trust", 0)) >= 80:
		message.text += "\n\nIt doesn't retreat when you step closer anymore."
		$Margin/VBox/Leave.text = "Invite to Sanctuary"

func _leave() -> void:
	if int(mothling.get("trust", 0)) >= 80:
		get_tree().change_scene_to_file("res://scenes/adoption/adopt_mothling.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/lure_sites/whispering_woods.tscn")
