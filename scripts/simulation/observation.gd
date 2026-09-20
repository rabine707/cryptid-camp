class_name Observation
extends RefCounted

static func choose_visitor(scores: Dictionary, rng: RandomNumberGenerator) -> String:
	var total := 0
	for id in scores:
		total += max(int(scores[id]), 0)
	if total <= 0:
		return ""
	var roll := rng.randi_range(1, total)
	var cursor := 0
	for id in scores:
		cursor += max(int(scores[id]), 0)
		if roll <= cursor:
			return str(id)
	return ""

static func generate_events(visitor_id: String, rng: RandomNumberGenerator) -> Array[Dictionary]:
	var events: Array[Dictionary] = [{"type":"ambient","text":"Leaves shift at the edge of the clearing."}]
	if visitor_id == "":
		events.append({"type":"empty","text":"The camera triggered, but nothing was visible."})
	elif visitor_id == "mothling":
		events.append({"type":"evidence","cryptid":"mothling","evidence":"red_eyes","text":"Two red eyes appeared beside the light."})
		if rng.randf() > 0.45:
			events.append({"type":"photo","cryptid":"mothling","quality":"blurry","text":"A winged shape crossed the Trail Cam."})
	elif visitor_id == "bigfoot":
		events.append({"type":"evidence","cryptid":"bigfoot","evidence":"footprint","text":"Large footprints appeared near the clearing."})
	elif visitor_id == "nightcrawler":
		events.append({"type":"evidence","cryptid":"nightcrawler","evidence":"pale_shape","text":"A tall pale shape crossed open ground."})
	return events
