extends Control

@onready var name_input: LineEdit = $Margin/VBox/NameInput
@onready var message: Label = $Margin/VBox/Message

var mothling: Dictionary = {}

func _ready() -> void:
	mothling = GameState.get_wild_individual("mothling")
	if mothling.is_empty() or int(mothling.get("trust", 0)) < 80:
		get_tree().change_scene_to_file("res://scenes/main/main.tscn")
		return
	$Margin/VBox/Invite.pressed.connect(_welcome_home)
	name_input.text_submitted.connect(_submit_name)

func _submit_name(_value: String) -> void:
	_welcome_home()

func _welcome_home() -> void:
	var chosen := name_input.text.strip_edges()
	if chosen.is_empty():
		message.text = "Every camp resident needs a name."
		return
	mothling = GameState.adopt_cryptid(str(mothling.get("id")), chosen)
	if mothling.is_empty():
		message.text = "Something went wrong. The Mothling is still waiting."
		return
	get_tree().change_scene_to_file("res://scenes/sanctuary/sanctuary.tscn")
