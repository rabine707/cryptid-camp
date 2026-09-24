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
	_check(_find_button(scene, "My Cryptids") != null or _find_button(scene, "Resident Areas") != null or _find_button(scene, "Visit Sanctuary") != null, "Camp Home resident control exists")
	_check(scene.get_node_or_null("BuildBadge") != null, "visible build badge survives home construction")
	_check(_find_button(scene, "Daily Check-In") != null, "daily check-in exists")
	_check(_find_button(scene, "Camp Chore") != null, "daily camp chore exists")
	_check(_find_button(scene, "Mystery Spot") != null, "daily mystery activity exists")
	_check(_find_button(scene, "Lost & Found") != null, "lost and found exists")
	_check(_find_button(scene, "Camp Mail") != null, "camp mail exists")
	_check(_find_button(scene, "Notice Board") != null, "notice board exists")
	_check(_find_button(scene, "Old Stump") != null, "old stump exists")
	_check(_find_button(scene, "Creek Bank") != null, "creek bank exists")
	_check(_find_button(scene, "Ranger Cabin") != null, "ranger cabin exists")
	_check(_find_button(scene, "Curio Shelf") != null, "curio shelf exists")
	_check(_find_button(scene, "Trail Cam") != null, "trail cam exists")
	_check(_find_button(scene, "Resident Hangout") != null, "resident hangout exists")
	_check(_find_button(scene, "Campfire Story") != null, "campfire story exists")
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
