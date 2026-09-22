extends Control
## An art-only book: never unlocks encounters, changes discovery, or creates saves.
const ENTRIES := [
	{"id": "mothling", "name": "Mothling", "tagline": "Small moth. Big heart.", "description": "A tiny cryptid with a big love for light. Shy, curious, and happiest beside a familiar lantern.", "availability": "Meet, befriend, and invite home in Whispering Woods."},
	{"id": "bigfoot", "name": "Sprigfoot", "tagline": "Big steps. Soft heart.", "description": "A gentle forest giant with moss in their hair and a fondness for berries, flowers, and quiet company.", "availability": "Discover in Whispering Woods. Adoption is not available yet."},
	{"id": "nightcrawler", "name": "Stilts", "tagline": "Long legs. Kind intentions.", "description": "A quiet nighttime wanderer. Always curious about the small, ordinary things the rest of camp walks past.", "availability": "Discover in Whispering Woods. Adoption is not available yet."},
	{"id": "scraps", "name": "Scraps", "tagline": "Trouble finds a way.", "description": "An impish Jersey Devil with a fondness for shiny things. Behind the mischief is a loyal friend.", "availability": "Future visitor · encounters are not available yet."},
	{"id": "glimmer", "name": "Glimmer", "tagline": "Strange lights. Kind intentions.", "description": "A softly glowing visitor who speaks in gestures and little sparks of light. There is magic in their quiet company.", "availability": "Future visitor · encounters are not available yet."}
]
var portrait: Control
var title: Label
var tagline: Label
var description: Label
var availability: Label
var picker: OptionButton

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("10232a")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 48)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 26)
	margin.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var back := Button.new()
	back.text = "Journal"
	back.custom_minimum_size = Vector2(205, 144)
	CampStyle.button(back)
	back.add_theme_font_size_override("font_size", 38)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/journal/journal.tscn"))
	header.add_child(back)
	var heading := _label("Camp sketchbook", 62, CampStyle.CREAM)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(heading)
	picker = OptionButton.new()
	picker.custom_minimum_size.y = 144
	picker.get_popup().add_theme_font_size_override("font_size", 44)
	picker.get_popup().add_theme_constant_override("v_separation", 48)
	CampStyle.button(picker)
	picker.add_theme_font_size_override("font_size", 46)
	for entry in ENTRIES:
		picker.add_item(entry.name)
	picker.item_selected.connect(_show_entry)
	column.add_child(picker)
	portrait = preload("res://scripts/cryptids/mothling_portrait.gd").new()
	portrait.custom_minimum_size.y = 560
	portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(portrait)
	title = _label("", 76, CampStyle.CREAM)
	column.add_child(title)
	tagline = _label("", 44, Color("edc888"))
	column.add_child(tagline)
	description = _label("", 40, Color("d3decf"))
	column.add_child(description)
	availability = _label("", 34, Color("b4c5b6"))
	availability.custom_minimum_size.y = 110
	column.add_child(availability)
	_show_entry(0)

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _show_entry(index: int) -> void:
	var entry: Dictionary = ENTRIES[index]
	portrait.set_species(entry.id)
	title.text = entry.name
	tagline.text = entry.tagline
	description.text = entry.description
	availability.text = entry.availability
