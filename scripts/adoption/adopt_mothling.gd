extends Control

@onready var name_input: LineEdit = $Margin/VBox/NameInput
@onready var message: Label = $Margin/VBox/Message
@onready var beans_button: Button = $Margin/VBox/Beans

var mothling: Dictionary = {}
var _html_name_input = null
var _html_input_callback = null
var _html_key_callback = null

func _ready() -> void:
	CampStyle.button($Margin/VBox/Invite, "green")
	CampStyle.button(beans_button, "green")
	mothling = GameState.get_wild_individual("mothling")
	if mothling.is_empty() or int(mothling.get("trust", 0)) < 80:
		get_tree().change_scene_to_file("res://scenes/main/main.tscn")
		return
	$Margin/VBox/Invite.pressed.connect(_welcome_home)
	beans_button.pressed.connect(_use_beans)
	name_input.text_submitted.connect(_submit_name)
	name_input.gui_input.connect(_on_name_input_gui_input)
	name_input.focus_entered.connect(_show_mobile_keyboard)
	_setup_web_name_input()

func _setup_web_name_input() -> void:
	if not OS.has_feature("web"):
		return
	var document = JavaScriptBridge.get_interface("document")
	if document == null:
		return
	_html_name_input = document.createElement("input")
	_html_name_input.type = "text"
	_html_name_input.placeholder = "Give your new friend a name..."
	_html_name_input.maxLength = 20
	_html_name_input.autocomplete = "off"
	_html_name_input.autocapitalize = "words"
	_html_name_input.enterKeyHint = "done"
	var style = _html_name_input.style
	style.position = "fixed"
	style.left = "8%"
	style.right = "8%"
	style.bottom = "18px"
	style.width = "84%"
	style.height = "52px"
	style.boxSizing = "border-box"
	style.fontSize = "20px"
	style.padding = "10px 14px"
	style.borderRadius = "8px"
	style.border = "2px solid #6d9a78"
	style.background = "#f3f0e4"
	style.color = "#183326"
	style.zIndex = "2147483647"
	style.display = "none"
	_html_input_callback = JavaScriptBridge.create_callback(_on_html_input)
	_html_key_callback = JavaScriptBridge.create_callback(_on_html_key)
	_html_name_input.addEventListener("input", _html_input_callback)
	_html_name_input.addEventListener("keydown", _html_key_callback)
	document.body.appendChild(_html_name_input)

func _on_name_input_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		_show_mobile_keyboard()

func _show_mobile_keyboard() -> void:
	name_input.grab_focus()
	if OS.has_feature("web") and _html_name_input != null:
		_html_name_input.value = name_input.text
		_html_name_input.style.display = "block"
		_html_name_input.focus()
		return
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		var rect := Rect2(name_input.global_position, name_input.size)
		DisplayServer.virtual_keyboard_show(name_input.text, rect, DisplayServer.KEYBOARD_TYPE_DEFAULT, name_input.max_length, name_input.caret_column, name_input.caret_column)

func _on_html_input(args: Array) -> void:
	if args.is_empty():
		return
	var event = args[0]
	name_input.text = str(event.target.value)

func _on_html_key(args: Array) -> void:
	if args.is_empty():
		return
	var event = args[0]
	if str(event.key) == "Enter":
		event.preventDefault()
		name_input.text = str(event.target.value)
		_welcome_home()

func _use_beans() -> void:
	name_input.text = "Beans"
	if _html_name_input != null:
		_html_name_input.value = "Beans"
	_welcome_home()

func _submit_name(_value: String) -> void:
	_welcome_home()

func _welcome_home() -> void:
	if _html_name_input != null and str(_html_name_input.value).strip_edges() != "":
		name_input.text = str(_html_name_input.value)
	var chosen := name_input.text.strip_edges()
	if chosen.is_empty():
		message.text = "Every camp resident needs a name."
		return
	mothling = GameState.adopt_cryptid(str(mothling.get("id")), chosen)
	if mothling.is_empty():
		message.text = "Something went wrong. The Mothling is still waiting."
		return
	_cleanup_web_input()
	DisplayServer.virtual_keyboard_hide()
	get_tree().change_scene_to_file("res://scenes/sanctuary/sanctuary.tscn")

func _cleanup_web_input() -> void:
	if _html_name_input != null:
		_html_name_input.remove()
		_html_name_input = null

func _exit_tree() -> void:
	_cleanup_web_input()
