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
