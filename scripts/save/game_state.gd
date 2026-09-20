extends Node

var state: Dictionary = {}

func _ready() -> void:
	state = SaveManager.load_state()

func persist() -> void:
	SaveManager.save(state)

func add_evidence(species_id: String, evidence_id: String) -> int:
	var evidence: Dictionary = state.get("evidence", {})
	var species_evidence: Array = evidence.get(species_id, [])
	if evidence_id not in species_evidence:
		species_evidence.append(evidence_id)
	evidence[species_id] = species_evidence
	state["evidence"] = evidence
	persist()
	return species_evidence.size()

func discover_species(species_id: String) -> void:
	var discovered: Array = state.get("discovered_species", [])
	if species_id not in discovered:
		discovered.append(species_id)
	state["discovered_species"] = discovered
	persist()

func is_discovered(species_id: String) -> bool:
	return species_id in state.get("discovered_species", [])

func get_lure_objects() -> Array[String]:
	var result: Array[String] = []
	var lure: Dictionary = state.get("lure_site", {})
	for object_id in lure.get("placed_objects", []):
		result.append(str(object_id))
	return result

func set_lure_objects(objects: Array[String]) -> void:
	var lure: Dictionary = state.get("lure_site", {})
	lure["placed_objects"] = objects.duplicate()
	state["lure_site"] = lure
	persist()

func get_wild_individual(species_id: String) -> Dictionary:
	for cryptid in state.get("cryptids", []):
		if cryptid.get("species") == species_id and not cryptid.get("adopted", false):
			return cryptid
	return {}

func ensure_wild_individual(species_id: String, rng: RandomNumberGenerator) -> Dictionary:
	var existing := get_wild_individual(species_id)
	if not existing.is_empty():
		existing["encounter_count"] = int(existing.get("encounter_count", 0)) + 1
		var history: Array = existing.get("encounter_history", [])
		history.append(int(Time.get_unix_time_from_system()))
		existing["encounter_history"] = history
		persist()
		return existing
	var created := CryptidFactory.create(species_id, rng)
	var cryptids: Array = state.get("cryptids", [])
	cryptids.append(created)
	state["cryptids"] = cryptids
	persist()
	return created

func change_trust(cryptid_id: String, amount: int) -> Dictionary:
	for cryptid in state.get("cryptids", []):
		if cryptid.get("id") == cryptid_id:
			cryptid["trust"] = clampi(int(cryptid.get("trust", 0)) + amount, 0, 100)
			persist()
			return cryptid
	return {}

func set_trust(cryptid_id: String, value: int) -> Dictionary:
	for cryptid in state.get("cryptids", []):
		if cryptid.get("id") == cryptid_id:
			cryptid["trust"] = clampi(value, 0, 100)
			persist()
			return cryptid
	return {}

func adopt_cryptid(cryptid_id: String, chosen_name: String) -> Dictionary:
	for cryptid in state.get("cryptids", []):
		if cryptid.get("id") == cryptid_id:
			cryptid["name"] = chosen_name.strip_edges()
			cryptid["adopted"] = true
			cryptid["adopted_at"] = int(Time.get_unix_time_from_system())
			persist()
			return cryptid
	return {}

func get_adopted_species(species_id: String) -> Dictionary:
	for cryptid in state.get("cryptids", []):
		if cryptid.get("species") == species_id and cryptid.get("adopted", false):
			return cryptid
	return {}

func place_sanctuary_decoration(decoration_id: String) -> void:
	var decorations: Array = state.get("sanctuary_decorations", [])
	if decoration_id not in decorations:
		decorations.append(decoration_id)
	state["sanctuary_decorations"] = decorations
	persist()

func unlock_moment(moment_id: String) -> void:
	var moments: Array = state.get("moments", [])
	if moment_id not in moments:
		moments.append(moment_id)
	state["moments"] = moments
	persist()

func has_moment(moment_id: String) -> bool:
	return moment_id in state.get("moments", [])

func get_sanctuary_plots() -> Dictionary:
	return preload("res://scripts/sanctuary/decor_catalog.gd").clean_plots(state.get("sanctuary_plots", {}))

func set_sanctuary_plot(plot: String, item: String) -> bool:
	var catalog = preload("res://scripts/sanctuary/decor_catalog.gd")
	if plot not in catalog.PLOTS or (not item.is_empty() and not catalog.ITEMS.has(item)):
		return false
	var before: Dictionary = state.duplicate(true)
	var plots := get_sanctuary_plots()
	if item.is_empty():
		plots.erase(plot)
	else:
		plots[plot] = item
	state["sanctuary_plots"] = plots
	if not SaveManager.save(state):
		state = before
		return false
	return true
