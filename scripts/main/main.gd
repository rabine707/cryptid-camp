extends Control

func _ready() -> void:
	$Margin/VBox/WhisperingWoods.pressed.connect(_open_whispering_woods)
	$Margin/VBox/Sanctuary.pressed.connect(_open_sanctuary)

func _open_whispering_woods() -> void:
	get_tree().change_scene_to_file("res://scenes/lure_sites/whispering_woods.tscn")

func _open_sanctuary() -> void:
	print("Sanctuary: Beans will live here.")
