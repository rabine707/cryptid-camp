extends Control
## A font-independent field sketch for encounter, journal and adoption screens.
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var unit := minf(size.x / 500.0, size.y / 380.0)
	draw_set_transform(size / 2, 0, Vector2.ONE * unit)
	for side in [-1, 1]:
		draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(side * 180, -110), Vector2(side * 155, 55), Vector2(side * 65, 115)]), Color("67785b"))
		draw_line(Vector2(side * 35, 15), Vector2(side * 155, -73), Color("a2ab7a"), 4)
		draw_line(Vector2(side * 18, -50), Vector2(side * 37, -100), Color("c6bf95"), 5)
	draw_circle(Vector2(0, 28), 65, Color("b8b697"))
	draw_circle(Vector2(0, -29), 59, Color("d1c9a9"))
	for x in [-23, 23]:
		draw_circle(Vector2(x, -30), 14, Color("622e2e"))
		draw_circle(Vector2(x, -33), 9, Color("e97659"))
		draw_circle(Vector2(x - 3, -36), 3, Color("fff0ca"))
	draw_arc(Vector2(0, -9), 9, 0.2, 2.9, 12, Color("5d5143"), 3, true)
