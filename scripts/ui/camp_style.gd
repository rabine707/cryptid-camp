extends RefCounted

const CREAM := Color("#f1e6c8")
const INK := Color("#27251d")
const FOREST := Color("#183529")
const FOREST_DARK := Color("#0d211a")
const MOSS := Color("#365d36")
const WOOD := Color("#6d472c")
const WOOD_LIGHT := Color("#9b7045")
const PAPER := Color("#e8d5ad")
const GOLD := Color("#d6a657")
const DANGER := Color("#7f3f34")

static func panel(color: Color, radius := 18, border := 0, border_color := Color.TRANSPARENT) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	box.border_width_left = border
	box.border_width_top = border
	box.border_width_right = border
	box.border_width_bottom = border
	box.border_color = border_color
	box.content_margin_left = 22
	box.content_margin_right = 22
	box.content_margin_top = 18
	box.content_margin_bottom = 18
	return box

static func button(button: Button, kind := "wood") -> void:
	var base := WOOD
	var hover := WOOD_LIGHT
	if kind == "green":
		base = MOSS
		hover = Color("#4b7446")
	elif kind == "paper":
		base = PAPER
		hover = Color("#f0dfbc")
	elif kind == "danger":
		base = DANGER
		hover = Color("#9a5043")
	button.add_theme_stylebox_override("normal", panel(base, 14, 2, Color("#1b1b16")))
	button.add_theme_stylebox_override("hover", panel(hover, 14, 2, GOLD))
	button.add_theme_stylebox_override("pressed", panel(base.darkened(0.18), 14, 2, GOLD))
	button.add_theme_color_override("font_color", INK if kind == "paper" else CREAM)
	button.add_theme_color_override("font_hover_color", INK if kind == "paper" else Color.WHITE)
	button.add_theme_font_size_override("font_size", 26)

static func parchment(control: Control) -> void:
	control.add_theme_stylebox_override("panel", panel(PAPER, 18, 3, WOOD))
