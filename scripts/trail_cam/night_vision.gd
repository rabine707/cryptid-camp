extends Control
## Resolution-independent Godot art shared by desktop and WebGL. No font icons.
var visitor := "mothling"
var reveal := false
var elapsed := 0.0
var tick := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true

func _process(delta: float) -> void:
	elapsed += delta
	tick += delta
	if tick > 0.12:
		tick = 0.0
		queue_redraw()

func _draw() -> void:
	var scale_xy := size / Vector2(960, 620)
	draw_set_transform(Vector2.ZERO, 0, scale_xy)
	draw_rect(Rect2(0, 0, 960, 620), Color("07120d"))
	# Layered infrared haze and forest canopy.
	for layer in range(12):
		draw_circle(Vector2(500, 340), 330.0 - layer * 20, Color(0.12, 0.26, 0.13, 0.045))
	var rng := RandomNumberGenerator.new()
	rng.seed = 707
	for i in range(24):
		var x := rng.randf_range(-30, 980)
		var y := rng.randf_range(70, 280)
		var height := rng.randf_range(180, 420)
		var shade := Color("132a1b") if i < 13 else Color("091b12")
		draw_line(Vector2(x, y), Vector2(x - 12, 620), shade, rng.randf_range(10, 25))
		for branch in range(4):
			var top := y + branch * height * 0.18
			var width := 35.0 + branch * 16
			draw_colored_polygon(PackedVector2Array([Vector2(x, top - 55), Vector2(x - width, top + 95), Vector2(x + width, top + 90)]), shade)
	for i in range(8):
		draw_line(Vector2(0, 460 + i * 17), Vector2(960, 435 + i * 24), Color(0.2, 0.34, 0.21, 0.045), 16)
	var body := Color("334a32") if reveal else Color("0b1b12")
	if visitor == "mothling":
		var flutter := sin(elapsed * 0.8) * 5
		for direction in [-1, 1]:
			var wing := PackedVector2Array([Vector2(492, 345), Vector2(492 + direction * 140, 250 + flutter), Vector2(492 + direction * 122, 370), Vector2(492 + direction * 60, 420), Vector2(492, 391)])
			draw_colored_polygon(wing, body)
			draw_line(wing[1], wing[3], Color(0.3, 0.45, 0.27, 0.12), 2)
		draw_circle(Vector2(492, 355), 37, body)
		draw_circle(Vector2(492, 391), 27, body)
		for x in [478, 508]:
			for glow in range(5, 0, -1):
				draw_circle(Vector2(x, 344), glow * 4, Color(0.85, 0.025, 0.02, 0.045))
			draw_circle(Vector2(x, 344), 5.5, Color("ef493e"))
			draw_circle(Vector2(x - 1, 342), 2, Color("ffb18b"))
	elif visitor == "bigfoot":
		draw_circle(Vector2(760, 286), 28, body)
		draw_line(Vector2(760, 320), Vector2(780, 440), body, 65)
		for dx in [-30, 30]:
			draw_line(Vector2(775, 420), Vector2(780 + dx, 527), body, 24)
	elif visitor == "nightcrawler":
		for dx in [-28, 28]:
			draw_line(Vector2(610, 325), Vector2(610 + dx, 493), Color("536d4b"), 17)
		draw_circle(Vector2(610, 323), 19, Color("536d4b"))
	# Foreground branches, scan lines and low contrast static; no bright flashing.
	draw_line(Vector2(70, 640), Vector2(116, 100), Color("040d09"), 42)
	draw_line(Vector2(850, 640), Vector2(885, 35), Color("040d09"), 55)
	for y in range(0, 620, 5):
		draw_line(Vector2(0, y), Vector2(960, y), Color(0, 0, 0, 0.16))
	rng.seed = int(elapsed * 8) + 99
	for i in range(320):
		var p := Vector2(rng.randf_range(0, 960), rng.randf_range(0, 620))
		draw_rect(Rect2(p, Vector2(2, 1)), Color(0.5, 0.7, 0.45, 0.10))
	var hud := Color("b7cda0")
	var font := ThemeDB.fallback_font
	draw_circle(Vector2(35, 36), 6, Color("e65e4d"))
	draw_string(font, Vector2(52, 44), "REC  00:14:22", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, hud)
	draw_string(font, Vector2(748, 44), "CAM 01 / IR", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, hud)
	draw_string(font, Vector2(28, 585), "MOTION DETECTED" if not visitor.is_empty() else "NO USABLE SUBJECT", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, hud)
	draw_string(font, Vector2(750, 585), "NIGHT / 01", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, hud)
	for p in [Vector2(425, 292), Vector2(554, 292), Vector2(425, 420), Vector2(554, 420)]:
		var dx := 1 if p.x < 490 else -1
		var dy := 1 if p.y < 350 else -1
		draw_line(p, p + Vector2(dx * 18, 0), Color(0.55, 0.7, 0.44, 0.45), 2)
		draw_line(p, p + Vector2(0, dy * 18), Color(0.55, 0.7, 0.44, 0.45), 2)
