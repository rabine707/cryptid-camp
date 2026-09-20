extends SceneTree

func _initialize() -> void:
	print("CRYPTID CAMP SMOKE TEST")
	var objects := _load_json("res://data/lure_objects.json")
	var cryptids := _load_json("res://data/cryptids.json")
	_assert(not objects.is_empty(), "lure object data loads")
	_assert(not cryptids.is_empty(), "cryptid data loads")
	_assert(objects.has("lantern"), "lantern exists")
	_assert(cryptids.has("mothling"), "mothling exists")

	var lure: Array[String] = ["pine_tree", "hollow_log", "lantern"]
	var score := Attraction.score(cryptids["mothling"], lure, objects, {"is_night": true})
	_assert(score > 0, "Mothling is attractable by starter lure")

	var rng := RandomNumberGenerator.new()
	rng.seed = 707
	var events := Observation.generate_events("mothling", rng)
	_assert(events.size() >= 2, "Mothling produces Trail Cam evidence")
	_assert(events[1].get("cryptid") == "mothling", "evidence belongs to Mothling")

	var individual := CryptidFactory.create("mothling", rng)
	_assert(individual.get("species") == "mothling", "individual factory creates Mothling")
	_assert(int(individual.get("trust", -1)) == 0, "new individual starts at zero trust")
	_assert(CryptidFactory.trust_stage(80) == "Bonded", "80 trust is Bonded")

	print("ALL SMOKE TESTS PASSED")
	quit(0)

func _load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_fail("cannot open " + path)
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		_fail("invalid JSON at " + path)
	return parsed

func _assert(condition: bool, label: String) -> void:
	if not condition:
		_fail(label)
	print("PASS: " + label)

func _fail(label: String) -> void:
	push_error("FAIL: " + label)
	quit(1)
