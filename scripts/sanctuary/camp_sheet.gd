extends Control
## A single modal sheet handles decoration and the persistent moment album.
signal item_chosen(plot: String, item: String)
signal visit_requested(plot: String)
signal closed
const Catalog = preload("res://scripts/sanctuary/decor_catalog.gd")
const Art = preload("res://scripts/sanctuary/decoration_art.gd")
var current_plot := "garden_left"
var plots: Dictionary = {}
var moments: Array = []
var has_resident := false
var mode := "decorate"
var content: VBoxContainer
var scroll: ScrollContainer
var close_button: Button
var item_buttons: Dictionary = {}
var slot_buttons: Dictionary = {}
var clear_button: Button
var visit_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.06, 0.04, 0.7)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed: closed.emit())
	add_child(shade)
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 24
	panel.offset_right = -24
	panel.offset_top = 225
	panel.offset_bottom = -24
	panel.add_theme_stylebox_override("panel", CampStyle.panel(Color("203d32"), 32, 3, Color("8b9864")))
	add_child(panel)
	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 22)
	panel.add_child(content)
	_render()

func _render() -> void:
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	item_buttons.clear()
	slot_buttons.clear()
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	content.add_child(header)
	var title := _label("Make it yours" if mode == "decorate" else "Little moments", 55, Color("f3e5bc"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	close_button = _button("Done", "wood")
	close_button.custom_minimum_size.x = 165
	close_button.pressed.connect(func(): closed.emit())
	header.add_child(close_button)
	var subtitle := "Five free decorations. Swap them anytime." if mode == "decorate" else "%d / 6 discovered · saved with your camp" % _moment_count()
	content.add_child(_label(subtitle, 33, Color("bdc9a6")))
	if mode == "decorate":
		var tabs := HBoxContainer.new()
		tabs.add_theme_constant_override("separation", 16)
		content.add_child(tabs)
		for plot in Catalog.PLOTS:
			var button := _button(Catalog.plot_name(plot), "green" if current_plot == plot else "wood")
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.pressed.connect(_select_plot.bind(plot))
			button.add_theme_color_override("font_color", Color("fff1bb") if plot == current_plot else Color("d4c6a8"))
			tabs.add_child(button)
			slot_buttons[plot] = button
		content.add_child(_label("Choose something for " + Catalog.plot_name(current_plot) + ".", 32, Color("e1c38a")))
	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 16)
	scroll.add_child(list)
	if mode == "decorate":
		for item in Catalog.ITEMS:
			_add_item(list, item)
		var actions := HBoxContainer.new()
		actions.add_theme_constant_override("separation", 16)
		content.add_child(actions)
		visit_button = _button("Invite resident over" if has_resident else "No resident yet", "green")
		visit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		visit_button.disabled = not has_resident or not plots.has(current_plot)
		visit_button.pressed.connect(func(): visit_requested.emit(current_plot))
		actions.add_child(visit_button)
		clear_button = _button("Clear plot", "wood")
		clear_button.disabled = not plots.has(current_plot)
		clear_button.pressed.connect(func(): item_chosen.emit(current_plot, ""))
		actions.add_child(clear_button)
	else:
		_add_memory(list, "warm_glow", Catalog.WARM_GLOW, "")
		for item in Catalog.ITEMS:
			_add_memory(list, str(Catalog.ITEMS[item].moment), Catalog.ITEMS[item], item)
		content.add_child(_label("Place something inviting. Let your resident explore.", 33, Color("e1c38a")))
	close_button.grab_focus()

func _select_plot(plot: String) -> void:
	current_plot = plot
	_render()
	slot_buttons[plot].grab_focus()

func _add_item(list: VBoxContainer, item: String) -> void:
	var data: Dictionary = Catalog.ITEMS[item]
	var chosen: bool = str(plots.get(current_plot, "")) == item
	var button := _button("", "green" if chosen else "wood")
	button.custom_minimum_size.y = 215
	button.pressed.connect(func(): item_chosen.emit(current_plot, item))
	list.add_child(button)
	item_buttons[item] = button
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 18)
	button.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	margin.add_child(row)
	var preview := Art.new()
	preview.item_id = item
	preview.custom_minimum_size = Vector2(140, 140)
	row.add_child(preview)
	var words := VBoxContainer.new()
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(words)
	words.add_child(_label(str(data.name), 39, Color("fff0cf")))
	words.add_child(_label(str(data.detail), 31, Color("ddd1b3")))
	words.add_child(_label("PLACED HERE" if chosen else "FREE · TAP TO PLACE", 26, Color("ebc786")))
	_ignore_input(margin)

func _add_memory(list: VBoxContainer, id: String, data: Dictionary, item: String) -> void:
	var unlocked: bool = id in moments
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", CampStyle.panel(Color("3f5940") if unlocked else Color("2a4437"), 18))
	panel.custom_minimum_size.y = 215
	list.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	panel.add_child(row)
	if not item.is_empty():
		var art := Art.new()
		art.item_id = item
		art.custom_minimum_size = Vector2(120, 120)
		art.modulate.a = 1.0 if unlocked else 0.45
		row.add_child(art)
	var words := VBoxContainer.new()
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(words)
	words.add_child(_label(str(data.title) if unlocked else "An undiscovered moment", 39, Color("f3dfae") if unlocked else Color("a6b59b")))
	words.add_child(_label(str(data.memory) if unlocked else str(data.detail), 32, Color("c6d0b5")))
	words.add_child(_label("DISCOVERED" if unlocked else "WAITING TO HAPPEN", 26, Color("dfc07b") if unlocked else Color("91a285")))

func _moment_count() -> int:
	var count := 1 if "warm_glow" in moments else 0
	for item in Catalog.ITEMS.values():
		if item.moment in moments: count += 1
	return count

func _ignore_input(node: Node) -> void:
	if node is Control: node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children(): _ignore_input(child)

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _button(value: String, kind: String) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size.y = 132
	CampStyle.button(button, kind)
	button.add_theme_font_size_override("font_size", 35)
	button.add_theme_stylebox_override("focus", CampStyle.panel(Color.TRANSPARENT, 14, 4, CampStyle.GOLD))
	return button

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		closed.emit()
