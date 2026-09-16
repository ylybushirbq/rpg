class_name RandomEncounter
extends RefCounted
## 按探索距离触发的暗雷。每次遭遇后重新抽取下一次的安全距离。

const MIN_DISTANCE: float = 9.0
const MAX_DISTANCE: float = 18.0
const CHECK_INTERVAL: float = 1.5
const ENCOUNTER_CHANCE: float = 0.38

var distance_since_check: float = 0.0
var distance_until_check: float = MIN_DISTANCE
var _rng := RandomNumberGenerator.new()


func _init(seed_value: int = 0) -> void:
	if seed_value == 0:
		_rng.randomize()
	else:
		_rng.seed = seed_value
	reset()


func reset() -> void:
	distance_since_check = 0.0
	distance_until_check = _rng.randf_range(MIN_DISTANCE, MAX_DISTANCE)


func add_distance(distance: float) -> bool:
	if distance <= 0.0:
		return false
	distance_since_check += distance
	if distance_since_check < distance_until_check:
		return false
	distance_since_check = 0.0
	distance_until_check = _rng.randf_range(MIN_DISTANCE, MAX_DISTANCE)
	return _rng.randf() < ENCOUNTER_CHANCE


func pick_encounter(catalog: GameCatalog, cleared_ids: Array[StringName]) -> StringName:
	var candidates: Array[StringName] = []
	for encounter: EncounterData in catalog.encounters.encounters:
		if not cleared_ids.has(encounter.id):
			candidates.append(encounter.id)
	if candidates.is_empty():
		for encounter: EncounterData in catalog.encounters.encounters:
			candidates.append(encounter.id)
	if candidates.is_empty():
		return &""
	return candidates[_rng.randi_range(0, candidates.size() - 1)]
