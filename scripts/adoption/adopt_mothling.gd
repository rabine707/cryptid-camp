extends Control

@onready var name_input: LineEdit = $Margin/VBox/NameInput
@onready var message: Label = $Margin/VBox/Message

var mothling: Dictionary = {}
var _web_form = null
var _web_submit = null
var _submitted := false

func _ready() -> void:
	CampStyle.button($Margin/VBox/Invite, "green")
	mothling = GameState.get_wild_individual("mothling")
	if mothling.is_empty() or int(mothling.get("trust", 0)) < 80:
		get_tree().change_scene_to_file.call_deferred("res://scenes/main/main.tscn")
		return
	$Margin/VBox/Invite.pressed.connect(_welcome_home)
	name_input.text_submitted.connect(_submit_name)
	name_input.text_changed.connect(func(_text: String): message.text = "")
	if OS.has_feature("web"):
		call_deferred("_setup_web_form")
	elif not DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		name_input.grab_focus.call_deferred()

func _setup_web_form() -> void:
	JavaScriptBridge.eval(FileAccess.get_file_as_string("res://web/name-entry.js"), true)
	_web_submit = JavaScriptBridge.create_callback(_on_web_submit)
	_web_form = JavaScriptBridge.get_interface("CryptidNameEntry").mount(_web_submit)
	# Keep the original layout while the directly tappable browser form owns input.
	for control in [name_input, $Margin/VBox/Hint, $Margin/VBox/Invite, message]:
		control.modulate.a = 0.0
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		control.focus_mode = Control.FOCUS_NONE
	name_input.virtual_keyboard_enabled = false

func _process(_delta: float) -> void:
	if _web_form != null:
		var rect := name_input.get_global_rect()
		_web_form.position(rect.position.x / size.x, rect.position.y / size.y, rect.size.x / size.x, size.x / size.y)

func _on_web_submit(args: Array) -> void:
	if not args.is_empty():
		# Validate before assigning to LineEdit, which otherwise silently truncates.
		_welcome_home(str(args[0]))

func _submit_name(_value: String) -> void:
	_welcome_home()

func _welcome_home(web_value: String = "") -> void:
	if _submitted:
		return
	var chosen := (web_value if _web_form != null else name_input.text).strip_edges()
	if chosen.is_empty():
		_show_error("Every camp resident needs a name.")
		return
	if chosen.length() > 20 or chosen.contains("\n") or chosen.contains("\r"):
		_show_error("Choose a name of 1–20 characters on one line.")
		return
	var adopted := GameState.adopt_cryptid(str(mothling.get("id")), chosen)
	if adopted.is_empty():
		_show_error("Something went wrong. The Mothling is still waiting.")
		return
	_submitted = true
	DisplayServer.virtual_keyboard_hide()
	get_tree().change_scene_to_file("res://scenes/sanctuary/sanctuary.tscn")

func _show_error(text: String) -> void:
	message.text = text
	if _web_form != null:
		_web_form.error(text)
	else:
		name_input.grab_focus()

func _exit_tree() -> void:
	if _web_form != null:
		_web_form.destroy()
		_web_form = null
	_web_submit = null
