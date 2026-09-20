extends Node

var events: Array[Dictionary] = []
var visitor_id: String = ""
var placed_objects: Array[String] = []

func clear() -> void:
	events.clear()
	visitor_id = ""
	placed_objects.clear()
