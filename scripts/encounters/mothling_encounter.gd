extends Control

var mothling: Dictionary
var action_count := 0
var rng := RandomNumberGenerator.new()

@onready var details: Label = $Margin/VBox/Details
@onready var trust_label: Label = $Margin/VBox/Trust
@onready var message: Label = $Margin/VBox/Message
@onready var dev_button: Button = $Margin/VBox/DevTrust

func _ready() -> void:
	rng.randomize()
	CampStyle.button($Margin/VBox/Actions/Treat, "wood")
	CampStyle.button($Margin/VBox/Actions/Observe, "wood")
	CampStyle.button($Margin/VBox/Actions/Photo, "wood")
	CampStyle.button($Margin/VBox/Leave, "green")
	CampStyle.button(dev_button, "paper")
	mothling = GameState.ensure_wild_individual("mothling", rng)
	$Margin/VBox/Actions/Treat.pressed.connect(_treat)
	$Margin/VBox/Actions/Observe.pressed.connect(_observe)
	$Margin/VBox/Actions/Photo.pressed.connect(_photo)
	$Margin/VBox/Leave.pressed.connect(_leave)
	dev_button.pressed.connect(_dev_add_trust)
	dev_button.visible = OS.has_feature("editor")
	for control in [$Margin/VBox/Actions/Treat, $Margin/VBox/Actions/Observe, $Margin/VBox/Actions/Photo, $Margin/VBox/Leave]:
		control.add_theme_font_size_override("font_size", 32)
	_render()
	message.text = _arrival_message()
	if int(mothling.get("encounter_count", 1)) == 1:
		message.text = "Discovery is just the beginning. Offer a treat or observe quietly to build trust. At 80 trust, invite your new friend to the Sanctuary."

func _render() -> void:
	var variant := str(mothling.get("variant", "classic")).capitalize()
	details.text = "%s • %s • %s\n%s" % [
		variant, mothling.get("size", "Average"), mothling.get("personality", "Curious"),
		"A " + str(mothling.get("quirk", "mysterious")) + " little visitor."
	]
	var trust := int(mothling.get("trust", 0))
	trust_label.text = "Trust: %s  •  %d/100" % [CryptidFactory.trust_stage(trust), trust]
	$Margin/VBox/Leave.text = "Invite to Sanctuary" if trust >= 80 else "Give It Space"

func _arrival_message() -> String:
	var trust := int(mothling.get("trust", 0))
	if trust >= 80:
		return "It is already waiting near the lantern. When you approach, it stays."
	if trust >= 60:
		return "It flutters down before you even settle in. It recognizes you now."
	if trust >= 40:
		return "It steps fully into the lantern light and watches your hands instead of the exit."
	if trust >= 20:
		return "It peeks out almost immediately. This time, it comes a little closer on its own."
	return "It watches you carefully from the edge of the light."

func _treat() -> void:
	var trust := int(mothling.get("trust", 0))
	var text := "It sniffs the treat, then scoots closer. Very slightly."
	if trust >= 60: text = "It takes the treat from your hand and stays close enough to ask for another."
	elif trust >= 40: text = "It accepts the treat without retreating to the trees."
	elif trust >= 20: text = "It creeps forward, grabs the treat, and only backs up one tiny step."
	_apply_action(8, text)

func _observe() -> void:
	var trust := int(mothling.get("trust", 0))
	var text := "You stay quiet. It seems relieved you aren't chasing it."
	if trust >= 60: text = "It settles beside you. Apparently you're part of the scenery now."
	elif trust >= 40: text = "It mirrors your head tilt, then gives a tiny excited wing flutter."
	elif trust >= 20: text = "It stops hiding its whole body behind the tree."
	_apply_action(5, text)

func _photo() -> void:
	var amount := 2
	var text := "Click. The Mothling stares directly into the lens."
	if mothling.get("quirk") == "Camera Shy":
		amount = 0
		text = "Click. It immediately ducks behind a wing. Definitely not a camera fan."
	elif int(mothling.get("trust", 0)) >= 40:
		text = "Click. It holds still this time. Almost like it knows what you're doing."
	_apply_action(amount, text)

func _apply_action(amount: int, text: String) -> void:
	if action_count >= 3:
		message.text = "It has had enough excitement for one visit. Better not push it."
		return
	action_count += 1
	var old_stage := CryptidFactory.trust_stage(int(mothling.get("trust", 0)))
	mothling = GameState.change_trust(str(mothling.get("id")), amount)
	var new_stage := CryptidFactory.trust_stage(int(mothling.get("trust", 0)))
	message.text = text
	if new_stage != old_stage:
		message.text += "\n\nTrust grew: %s" % new_stage
	_render()

func _dev_add_trust() -> void:
	mothling = GameState.change_trust(str(mothling.get("id")), 20)
	message.text = "DEV TEST: +20 trust. Current behavior stage: %s." % CryptidFactory.trust_stage(int(mothling.get("trust", 0)))
	_render()

func _leave() -> void:
	if int(mothling.get("trust", 0)) >= 80:
		get_tree().change_scene_to_file("res://scenes/adoption/adopt_mothling.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/lure_sites/whispering_woods.tscn")
