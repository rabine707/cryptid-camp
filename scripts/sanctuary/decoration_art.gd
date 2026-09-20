extends Control
## Shared, non-AI vector placeholders for world props and picker thumbnails.
var item_id := ""
var art_texture: Texture2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_texture = ArtRegistry.texture_for("decoration." + item_id)

func _draw() -> void:
	if art_texture != null:
		var fit := art_texture.get_size() * minf(size.x / art_texture.get_width(), size.y / art_texture.get_height())
		draw_texture_rect(art_texture, Rect2((size - fit) / 2, fit), false)
		return
	draw_set_transform(Vector2.ZERO, 0, size / Vector2(64, 64))
	paint(self, item_id, Vector2(32, 48), 0)
	draw_set_transform(Vector2.ZERO)

static func ellipse(canvas: CanvasItem, p: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(32):
		var a := TAU * i / 32.0
		points.append(p + Vector2(cos(a), sin(a)) * radius)
	canvas.draw_colored_polygon(points, color)

static func paint(canvas: CanvasItem, item: String, p: Vector2, time: float) -> void:
	ellipse(canvas, p + Vector2(1, 3), Vector2(20, 7), Color("294537"))
	match item:
		"mushroom_stool":
			canvas.draw_rect(Rect2(p + Vector2(-6, -18), Vector2(12, 20)), Color("d3be8a"))
			ellipse(canvas, p + Vector2(0, -16), Vector2(19, 6), Color("ddbd88"))
			ellipse(canvas, p + Vector2(0, -21), Vector2(20, 10), Color("b96552"))
			for offset in [Vector2(-10, -22), Vector2(4, -26), Vector2(11, -19)]:
				ellipse(canvas, p + offset, Vector2(3, 2), Color("f3ddb2"))
		"flower_patch":
			ellipse(canvas, p, Vector2(22, 10), Color("648258"))
			for i in range(5):
				var f := p + Vector2(-15 + i * 7, -12 - (i % 3) * 5)
				f.x += sin(time * 1.3 + i) * 1.4
				canvas.draw_line(p + Vector2(-15 + i * 7, 0), f, Color("99ad70"), 2, true)
				for j in range(5):
					var a := TAU * j / 5.0
					canvas.draw_circle(f + Vector2(cos(a), sin(a)) * 3, 2.8, Color("e7b4a3") if i % 2 == 0 else Color("dccb8f"))
				canvas.draw_circle(f, 2, Color("ad8150"))
		"moss_cushion":
			ellipse(canvas, p - Vector2(0, 3), Vector2(22, 11), Color("526d50"))
			ellipse(canvas, p - Vector2(0, 7), Vector2(21, 10), Color("98ab75"))
			ellipse(canvas, p - Vector2(0, 8), Vector2(17, 7), Color("b2bf8b"))
			for x in [-12, 0, 12]: canvas.draw_line(p + Vector2(x, -8), p + Vector2(x + 2, -6), Color("718852"), 1.5, true)
		"wind_chimes":
			canvas.draw_line(p + Vector2(-13, 0), p + Vector2(-13, -39), Color("c1a574"), 3, true)
			canvas.draw_line(p + Vector2(-13, -38), p + Vector2(15, -38), Color("c1a574"), 3, true)
			for i in range(4):
				var x := -5 + i * 6.0
				var sway := sin(time * 2 + i * 0.5) * 3
				canvas.draw_line(p + Vector2(x, -37), p + Vector2(x + sway, -26), Color("d0c18f"), 1, true)
				canvas.draw_line(p + Vector2(x + sway, -27), p + Vector2(x + sway, -12 + i % 2 * 4), Color("91b9af"), 3, true)
		"star_blanket":
			canvas.draw_colored_polygon(PackedVector2Array([p + Vector2(-24, -9), p + Vector2(12, -16), p + Vector2(25, 4), p + Vector2(-13, 10)]), Color("6d7498"))
			canvas.draw_polyline(PackedVector2Array([p + Vector2(-20, -8), p + Vector2(11, -13), p + Vector2(21, 3), p + Vector2(-12, 7), p + Vector2(-20, -8)]), Color("b8b6ac"), 1, true)
			for offset in [Vector2(-9, -3), Vector2(6, -7), Vector2(8, 3)]:
				canvas.draw_line(p + offset - Vector2(3, 0), p + offset + Vector2(3, 0), Color("eee0a7"), 1.5, true)
				canvas.draw_line(p + offset - Vector2(0, 3), p + offset + Vector2(0, 3), Color("eee0a7"), 1.5, true)
