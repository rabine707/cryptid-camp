extends SceneTree

var failures := 0

func _initialize() -> void:
	print("CAMP HOME RUNTIME TEST")
	await process_frame
	change_scene_to_file("res://scenes/main/main.tscn")
	await process_frame
	await process_frame
	var scene := current_scene
	_check(scene != null, "main scene loads")
	_check(scene.get_node_or_null("Margin/VBox/WhisperingWoods") == null, "legacy main menu is replaced")
	_check(_find_button(scene, "Explore Whispering Woods") != null or _find_button(scene, "Explore") != null, "Camp Home exploration control exists")
	_check(_find_button(scene, "Residents") != null, "Camp Home resident control exists")
	_check(scene.get_node_or_null("BuildBadge") != null, "visible build badge survives home construction")
	if failures > 0:
		push_error("CAMP HOME FAILURES: %d" % failures)
		quit(1)
		return
	print("ALL CAMP HOME TESTS PASSED")
	quit(0)

func _find_button(root: Node, label: String) -> Button:
	if root is Button and root.text == label:
		return root
	for child in root.get_children():
		var found := _find_button(child, label)
		if found != null:
			return found
	return null

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error("FAIL: " + label)
		return
	print("PASS: " + label)
