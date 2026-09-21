extends Control
## A quiet, lightweight foreground over the menu painting; never intercept taps.
var time := 0.0
var tick := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	time += delta
	tick += delta
	if tick >= 0.05:
		tick = 0.0
		queue_redraw()

func _draw() -> void:
	# Darken only the edges that carry live Godot text and buttons.
	var shade := Color(0.01, 0.04, 0.035, 0.62)
	var clear := Color(0.01, 0.04, 0.035, 0)
	draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0), Vector2(size.x, size.y * 0.28), Vector2(0, size.y * 0.28)]), PackedColorArray([shade, shade, clear, clear]))
	shade.a = 0.92
	draw_polygon(PackedVector2Array([Vector2(0, size.y * 0.63), Vector2(size.x, size.y * 0.63), size, Vector2(0, size.y)]), PackedColorArray([clear, clear, shade, shade]))
	for i in range(13):
		var phase := float(i) * 2.39
		var point := Vector2(size.x * (0.1 + fmod(phase, 0.8)), size.y * (0.45 + fmod(phase * 0.27, 0.24)))
		point += Vector2(sin(time * 0.31 + phase) * 16, cos(time * 0.22 + phase) * 21)
		var alpha := 0.18 + (sin(time * 0.6 + phase) + 1.0) * 0.16
		draw_circle(point, 8, Color(1, 0.72, 0.25, alpha * 0.12))
		draw_circle(point, 2, Color(1, 0.81, 0.36, alpha))
