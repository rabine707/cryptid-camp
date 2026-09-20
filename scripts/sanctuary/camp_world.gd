extends Control
## Art and motion are separate from persistence. Coordinates use a 360 x 380
## world; the parent can resize without changing routes or interaction targets.
signal lamp_reached
signal inspected(message: String)

const WORLD_SIZE := Vector2(360, 380)
const POINTS := [Vector2(171, 161), Vector2(183, 204), Vector2(139, 251), Vector2(207, 264), Vector2(258, 211), Vector2(213, 316)]
const LINKS := [[1], [0, 2, 3, 4], [1, 3], [1, 2, 5], [1], [3]]
const TREES := [Vector3(19, 82, 1.05), Vector3(53, 60, 0.95), Vector3(294, 67, 1.1), Vector3(330, 96, 1.25), Vector3(16, 153, 1.15), Vector3(343, 174, 1.1), Vector3(20, 251, 1.0), Vector3(332, 282, 1.2), Vector3(38, 345, 1.15), Vector3(315, 365, 1.2), Vector3(12, 386, 1.25)]
var resident: Dictionary = {}
var lamp_placed := false
var creature_position := Vector2(171, 161)
var destination := 0
var route: Array[int] = []
var waiting := 1.5
var lamp_requested := false
var resting_at_lamp := false
var elapsed := 0.0
var rng := RandomNumberGenerator.new()
var textures: Dictionary = {}
var ripple := -1.0
var greeting := 0.0
var moving := false

func _ready() -> void:
	clip_contents = true
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	rng.randomize()
	for slot in ["background.sanctuary", "scenery.sanctuary.cabin", "scenery.sanctuary.pine", "scenery.sanctuary.pond", "scenery.sanctuary.campfire", "decoration.old_lamp"]:
		textures[slot] = ArtRegistry.texture_for(slot)

func configure(individual: Dictionary, placed: bool) -> void:
	resident = individual
	lamp_placed = placed
	var variant := str(resident.get("variant", "classic"))
	textures["resident"] = ArtRegistry.texture_for("cryptid.mothling." + variant)
	if textures["resident"] == null:
		textures["resident"] = ArtRegistry.texture_for("cryptid.mothling.classic")
	if placed and not resident.is_empty():
		creature_position = POINTS[2]
		destination = 2
		resting_at_lamp = true
		waiting = 5.0
	queue_redraw()

func visit_lamp() -> void:
	if resident.is_empty():
		return
	lamp_placed = true
	lamp_requested = true
	waiting = 0.0
	# Finish the current edge first, then take a shortest walkable route.
	# A repeat press replaces the route rather than starting a second animation.
	route = _path(destination, 2)
	queue_redraw()

func _path(start: int, finish: int) -> Array[int]:
	var frontier: Array[int] = [start]
	var previous: Dictionary = {start: -1}
	while not frontier.is_empty():
		var current: int = frontier.pop_front()
		if current == finish:
			break
		for neighbor in LINKS[current]:
			if not previous.has(neighbor):
				previous[neighbor] = current
				frontier.append(neighbor)
	var result: Array[int] = []
	var cursor := finish
	while cursor != start:
		result.push_front(cursor)
		cursor = int(previous[cursor])
	return result

func _process(delta: float) -> void:
	elapsed += delta
	greeting = maxf(0.0, greeting - delta)
	if ripple >= 0.0:
		ripple += delta
		if ripple > 2.0:
			ripple = -1.0
	moving = false
	if not resident.is_empty():
		if creature_position.distance_to(POINTS[destination]) > 0.5:
			moving = true
			resting_at_lamp = false
			creature_position = creature_position.move_toward(POINTS[destination], 22.0 * delta)
		elif not route.is_empty():
			destination = route.pop_front()
		elif lamp_requested:
			lamp_requested = false
			resting_at_lamp = true
			waiting = 7.0
			lamp_reached.emit()
		elif waiting > 0.0:
			waiting -= delta
		else:
			if lamp_placed and destination != 2 and rng.randf() < 0.35:
				route = _path(destination, 2)
				lamp_requested = true
			else:
				var neighbors: Array = LINKS[destination]
				destination = int(neighbors[rng.randi_range(0, neighbors.size() - 1)])
				waiting = rng.randf_range(2.0, 4.5)
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	var tapped: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	if event is InputEventScreenTouch:
		tapped = event.pressed
	if not tapped:
		return
	var point: Vector2 = event.position * WORLD_SIZE / size
	if not resident.is_empty() and point.distance_to(creature_position - Vector2(0, 15)) < 24.0:
		greeting = 2.5
		inspected.emit("%s gives a happy little flutter." % resident.get("name", "Your Mothling"))
	elif point.distance_to(Vector2(284, 151)) < 43.0:
		ripple = 0.0
		inspected.emit("STILLWATER POND\nSomething tiny ripples beneath the lily pads.")
	elif point.distance_to(Vector2(233, 249)) < 26.0:
		inspected.emit("THE FIRE CIRCLE\nA little crackle. A little warmth. Stay awhile.")
	elif point.distance_to(Vector2(112, 240)) < 25.0:
		if lamp_placed and not resident.is_empty():
			visit_lamp()
			inspected.emit("A familiar light calls your Mothling over.")
		else:
			inspected.emit("LANTERN NOOK\nThe perfect place for an Old Lamp.")
	elif Rect2(59, 289, 90, 47).has_point(point):
		inspected.emit("ROOM TO GROW\nTwo garden plots, saved for future decorations.")
	elif Rect2(70, 57, 128, 96).has_point(point):
		inspected.emit("CAMP CABIN\nA warm window. A place to come back to.")
	else:
		inspected.emit("Evening settles softly over your Sanctuary.")
	accept_event()

func _ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(40):
		var angle := TAU * float(i) / 40.0
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, color)

func _poly(points: Array, color: String) -> void:
	draw_colored_polygon(PackedVector2Array(points), Color(color))

func _sprite(slot: String, rectangle: Rect2) -> bool:
	var texture: Texture2D = textures.get(slot)
	if texture == null:
		return false
	var scaled := texture.get_size() * minf(rectangle.size.x / texture.get_width(), rectangle.size.y / texture.get_height())
	draw_texture_rect(texture, Rect2(rectangle.get_center() - scaled / 2.0, scaled), false)
	return true

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, size / WORLD_SIZE)
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("203e36"))
	if not _sprite("background.sanctuary", Rect2(Vector2.ZERO, WORLD_SIZE)):
		_ground()
	# Props and resident share foot-based depth ordering; replacement textures
	# keep the same baseline and never change paths or gameplay state.
	var props: Array[Dictionary] = [{"kind": "cabin", "y": 147.0}, {"kind": "pond", "y": 178.0}, {"kind": "fire", "y": 251.0}, {"kind": "lamp", "y": 246.0}]
	for tree in TREES:
		props.append({"kind": "tree", "y": tree.y, "tree": tree})
	if not resident.is_empty():
		props.append({"kind": "resident", "y": creature_position.y})
	props.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a.y) < float(b.y))
	for prop in props:
		match prop.kind:
			"cabin": _cabin()
			"pond": _pond()
			"fire": _fire()
			"lamp": _lamp()
			"tree": _tree(prop.tree)
			"resident": _creature()
	# Quiet fireflies drift only at the edge of the clearing.
	for i in range(9):
		var phase := elapsed * 0.6 + i * 2.3
		var p := Vector2(42 + fmod(i * 67.0, 278.0), 65 + fmod(i * 43.0, 275.0)) + Vector2(sin(phase) * 6, cos(phase * 0.8) * 5)
		draw_circle(p, 1.3, Color(0.91, 0.91, 0.56, 0.22 + 0.45 * (sin(phase) * 0.5 + 0.5)))
	draw_set_transform(Vector2.ZERO)

func _ground() -> void:
	_ellipse(Vector2(184, 235), Vector2(153, 164), Color("355745"))
	_ellipse(Vector2(177, 232), Vector2(132, 141), Color("46664b"))
	_ellipse(Vector2(201, 263), Vector2(102, 79), Color("4e6b4d"))
	var path := PackedVector2Array([Vector2(183, 396), Vector2(191, 344), Vector2(206, 301), Vector2(184, 269), Vector2(178, 211), Vector2(164, 165), Vector2(141, 136)])
	draw_polyline(path, Color("63745a"), 37, true)
	draw_polyline(path, Color("a0966b"), 25, true)
	draw_polyline(PackedVector2Array([Vector2(181, 215), Vector2(145, 244), Vector2(109, 253)]), Color("a0966b"), 20, true)
	draw_polyline(PackedVector2Array([Vector2(181, 218), Vector2(225, 211), Vector2(264, 191)]), Color("a0966b"), 18, true)
	# Fixed procedural scatter never changes or flickers between frames.
	for i in range(100):
		var p := Vector2(39 + fmod(i * 71.7, 280), 73 + fmod(i * 47.3, 288))
		if p.distance_to(Vector2(185, 230)) > 152:
			continue
		draw_line(p, p + Vector2(-2, -4), Color("64815a"), 1.0, true)
		draw_line(p, p + Vector2(2, -5), Color("64815a"), 1.0, true)
	for i in range(16):
		var p := Vector2(177 + sin(i * 1.8) * 9, 172 + i * 13)
		_ellipse(p, Vector2(2.4, 1.1), Color("bbad7f"))
	for p in [Vector2(56, 198), Vector2(302, 299), Vector2(74, 350), Vector2(301, 94)]:
		_ellipse(p + Vector2(0, 2), Vector2(10, 5), Color("29483a"))
		_poly([p + Vector2(-9, 0), p + Vector2(-6, -8), p + Vector2(3, -10), p + Vector2(10, -2), p + Vector2(6, 3)], "8c9d88")
		draw_line(p + Vector2(-6, -7), p + Vector2(3, -9), Color("bec5a4"), 2, true)
	for p in [Vector2(69, 280), Vector2(294, 238), Vector2(63, 170)]:
		for offset in [Vector2.ZERO, Vector2(8, 5), Vector2(-7, 7)]:
			draw_line(p + offset, p + offset + Vector2(0, -5), Color("a6b67e"), 1, true)
			draw_circle(p + offset + Vector2(0, -6), 2, Color("e0c789"))
	for x in [81, 123]:
		var p := Vector2(x, 311)
		_ellipse(p, Vector2(18, 12), Color("2b4535"))
		_ellipse(p - Vector2(0, 2), Vector2(16, 10), Color("756d4c"))
		for i in range(8):
			var a := TAU * i / 8.0
			draw_circle(p + Vector2(cos(a) * 16, sin(a) * 10), 2.1, Color("a4a582"))
		draw_line(p + Vector2(-4, -2), p + Vector2(4, -2), Color("c5c09a"), 1.5, true)
		draw_line(p + Vector2(0, -6), p + Vector2(0, 2), Color("c5c09a"), 1.5, true)
	# Low fence and entrance posts frame the foreground without closing the path.
	for x in [69, 99, 129, 248, 278]:
		draw_line(Vector2(x, 365), Vector2(x + 30, 370), Color("827c57"), 4, true)
		draw_line(Vector2(x, 374), Vector2(x + 30, 379), Color("827c57"), 3, true)
		draw_line(Vector2(x, 357), Vector2(x, 382), Color("b1a173"), 5, true)

func _tree(tree: Vector3) -> void:
	var p := Vector2(tree.x, tree.y)
	var s := tree.z
	if _sprite("scenery.sanctuary.pine", Rect2(p - Vector2(28, 77) * s, Vector2(56, 83) * s)):
		return
	_ellipse(p + Vector2(5, 1), Vector2(23, 8) * s, Color(0.07, 0.18, 0.14, 0.4))
	draw_line(p, p - Vector2(0, 38) * s, Color("796442"), 6 * s, true)
	for i in range(3):
		var y := -17.0 - i * 16
		var width := 27.0 - i * 5
		_poly([p + Vector2(-width, y) * s, p + Vector2(0, y - 36) * s, p + Vector2(width, y) * s], "244c3e")
		_poly([p + Vector2(-width, y) * s, p + Vector2(0, y - 36) * s, p + Vector2(-3, y - 2) * s], "39624b")
		draw_line(p + Vector2(-width + 4, y - 1) * s, p + Vector2(-5, y - 7) * s, Color("517653"), s, true)

func _cabin() -> void:
	if _sprite("scenery.sanctuary.cabin", Rect2(69, 48, 140, 109)):
		return
	_ellipse(Vector2(145, 148), Vector2(72, 13), Color("294639"))
	draw_rect(Rect2(87, 88, 105, 54), Color("996e48"))
	draw_rect(Rect2(89, 135, 102, 13), Color("b08a5a"))
	for y in range(94, 137, 9):
		draw_line(Vector2(90, y), Vector2(190, y), Color("72533b"), 2)
	draw_rect(Rect2(164, 50, 13, 28), Color("6b7363"))
	_poly([Vector2(76, 91), Vector2(109, 54), Vector2(171, 54), Vector2(204, 91)], "293f39")
	_poly([Vector2(82, 87), Vector2(111, 59), Vector2(168, 59), Vector2(197, 87)], "547265")
	for x in range(111, 175, 13):
		draw_line(Vector2(x, 61), Vector2(x + 19, 86), Color("6d8970"), 1, true)
	draw_line(Vector2(77, 91), Vector2(203, 91), Color("b69867"), 4, true)
	draw_rect(Rect2(129, 104, 24, 34), Color("3a493b"))
	draw_circle(Vector2(147, 121), 1.5, Color("e5c07b"))
	for x in [99, 163]:
		_ellipse(Vector2(x + 7, 113), Vector2(21, 21), Color(1, 0.74, 0.35, 0.05))
		draw_rect(Rect2(x - 2, 100, 19, 23), Color("4e4e39"))
		draw_rect(Rect2(x, 102, 15, 18), Color("ebc376"))
		draw_line(Vector2(x + 7, 102), Vector2(x + 7, 120), Color("967449"), 2)
		draw_line(Vector2(x, 111), Vector2(x + 15, 111), Color("967449"), 2)
	for i in range(3):
		draw_rect(Rect2(123 - i * 3, 141 + i * 5, 36 + i * 6, 4), Color("c1a577"))
	for i in range(3):
		var phase := fmod(elapsed * 0.18 + i / 3.0, 1.0)
		_ellipse(Vector2(171 + sin(phase * 5) * 5, 49 - phase * 33), Vector2(4 + phase * 6, 3 + phase * 5), Color(0.7, 0.77, 0.67, (1 - phase) * 0.17))

func _pond() -> void:
	if _sprite("scenery.sanctuary.pond", Rect2(242, 119, 87, 65)):
		return
	_ellipse(Vector2(282, 155), Vector2(43, 30), Color("78917b"))
	_ellipse(Vector2(282, 152), Vector2(39, 26), Color("315d5a"))
	_ellipse(Vector2(281, 149), Vector2(34, 22), Color("417776"))
	for i in range(3):
		var y := 140.0 + i * 10
		draw_line(Vector2(265 + sin(elapsed + i) * 3, y), Vector2(291 + sin(elapsed + i) * 3, y), Color("699a8c"), 1, true)
	for p in [Vector2(303, 149), Vector2(273, 166)]:
		_ellipse(p, Vector2(7, 4), Color("8eae71"))
		draw_line(p, p + Vector2(6, 2), Color("417776"), 1.5, true)
	for x in [247, 254, 315]:
		draw_line(Vector2(x, 147), Vector2(x - 2, 129), Color("a7ae74"), 1.5, true)
		draw_line(Vector2(x - 2, 130), Vector2(x - 2, 124), Color("bd9c6a"), 3, true)
	if ripple >= 0:
		_ellipse(Vector2(285, 152), Vector2(7 + ripple * 12, 3 + ripple * 6), Color(0.7, 0.88, 0.78, (2 - ripple) * 0.13))

func _fire() -> void:
	if _sprite("scenery.sanctuary.campfire", Rect2(209, 211, 48, 49)):
		return
	var p := Vector2(233, 247)
	_ellipse(p, Vector2(33, 23), Color(1, 0.68, 0.25, 0.055 + sin(elapsed * 3) * 0.015))
	_ellipse(p, Vector2(20, 12), Color("3c4436"))
	for i in range(9):
		var a := TAU * i / 9.0
		_ellipse(p + Vector2(cos(a) * 18, sin(a) * 10), Vector2(4, 3), Color("a8a587"))
	draw_line(p + Vector2(-10, -5), p + Vector2(10, 3), Color("86613f"), 5, true)
	draw_line(p + Vector2(-10, 3), p + Vector2(10, -5), Color("b38b59"), 4, true)
	var sway := sin(elapsed * 5) * 2
	_poly([p + Vector2(-8, -4), p + Vector2(-7, -13), p + Vector2(-2 + sway, -26), p + Vector2(3, -13), p + Vector2(7, -19), p + Vector2(9, -5), p + Vector2(0, 0)], "eb9e50")
	_poly([p + Vector2(-4, -4), p + Vector2(sway, -17), p + Vector2(5, -4)], "f6d58c")
	for i in range(3):
		var phase := fmod(elapsed * 0.5 + i * 0.33, 1.0)
		draw_circle(p + Vector2(sin(i + phase * 7) * 7, -20 - phase * 21), 1, Color(1, 0.77, 0.4, 1 - phase))
	# A split log seat, safely outside the walking route.
	draw_line(Vector2(261, 266), Vector2(279, 248), Color("503e2e"), 11, true)
	draw_line(Vector2(261, 263), Vector2(279, 245), Color("a58759"), 9, true)
	draw_circle(Vector2(261, 263), 4, Color("c8aa77"))

func _lamp() -> void:
	var p := Vector2(111, 246)
	_ellipse(p, Vector2(20, 12), Color("8e8960"))
	if not lamp_placed:
		draw_arc(p, 13, 0, TAU, 32, Color("bdba8c"), 1, true)
		draw_line(p - Vector2(4, 0), p + Vector2(4, 0), Color("d1c79a"), 2, true)
		draw_line(p - Vector2(0, 4), p + Vector2(0, 4), Color("d1c79a"), 2, true)
		return
	for i in range(4):
		_ellipse(p - Vector2(0, 13), Vector2(18 + i * 8, 22 + i * 7), Color(1, 0.78, 0.36, 0.025))
	if _sprite("decoration.old_lamp", Rect2(99, 211, 24, 40)):
		return
	draw_line(p, p - Vector2(0, 38), Color("584c35"), 3, true)
	draw_line(p - Vector2(0, 38), p + Vector2(12, -38), Color("584c35"), 3, true)
	draw_line(p + Vector2(12, -38), p + Vector2(12, -32), Color("584c35"), 2, true)
	draw_rect(Rect2(p + Vector2(6, -30), Vector2(13, 17)), Color("f0cc7e"))
	draw_rect(Rect2(p + Vector2(4, -32), Vector2(17, 3)), Color("62513a"))
	draw_rect(Rect2(p + Vector2(4, -14), Vector2(17, 3)), Color("62513a"))
	draw_line(p + Vector2(12, -29), p + Vector2(12, -15), Color("fff0bc"), 3)

func _creature() -> void:
	var p := creature_position
	_ellipse(p + Vector2(1, 2), Vector2(14, 5), Color(0.08, 0.18, 0.14, 0.38))
	var bob := sin(elapsed * (8.0 if moving else 2.2)) * (2.0 if moving else 0.7)
	p.y += bob
	if not _sprite("resident", Rect2(p - Vector2(24, 42), Vector2(48, 46))):
		var wing := Color("c8b99a")
		var variant := str(resident.get("variant", "classic"))
		if variant == "autumn": wing = Color("cb9469")
		if variant == "luna": wing = Color("adcaa9")
		var flutter := sin(elapsed * (10.0 if moving or greeting > 0 else 2.5)) * 2
		_ellipse(p + Vector2(-11, -17), Vector2(10 + flutter, 15), wing)
		_ellipse(p + Vector2(11, -17), Vector2(10 + flutter, 15), wing)
		_ellipse(p + Vector2(-12, -15), Vector2(5, 8), wing.darkened(0.2))
		_ellipse(p + Vector2(12, -15), Vector2(5, 8), wing.darkened(0.2))
		_ellipse(p + Vector2(0, -17), Vector2(9, 14), Color("ede0be"))
		draw_line(p + Vector2(-4, -27), p + Vector2(-9, -36), Color("e5d3ad"), 2, true)
		draw_line(p + Vector2(4, -27), p + Vector2(9, -36), Color("e5d3ad"), 2, true)
		var blink := fmod(elapsed, 5.8) > 5.6
		for x in [-4, 4]:
			if blink:
				draw_line(p + Vector2(x - 2, -20), p + Vector2(x + 2, -20), Color("683f3b"), 2, true)
			else:
				draw_circle(p + Vector2(x, -20), 2.7, Color("9c5148"))
				draw_circle(p + Vector2(x - 0.6, -21), 0.8, Color("fff2cf"))
		draw_arc(p + Vector2(0, -15), 2.5, 0.1, PI - 0.1, 10, Color("765c48"), 1, true)
	if resting_at_lamp or greeting > 0:
		var h := p + Vector2(0, -48)
		draw_circle(h + Vector2(-2, 0), 3, Color("e9b68d"))
		draw_circle(h + Vector2(2, 0), 3, Color("e9b68d"))
		_poly([h + Vector2(-5, 1), h + Vector2(5, 1), h + Vector2(0, 7)], "e9b68d")
