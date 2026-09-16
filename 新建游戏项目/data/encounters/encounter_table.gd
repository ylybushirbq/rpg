class_name EncounterTable
extends Resource
## 四节点遭遇表。

@export var encounters: Array[EncounterData] = []

var _by_id: Dictionary[StringName, EncounterData] = {}


func ensure_index() -> void:
	if not _by_id.is_empty():
		return
	for encounter: EncounterData in encounters:
		_by_id[encounter.id] = encounter


func get_encounter(encounter_id: StringName) -> EncounterData:
	ensure_index()
	assert(_by_id.has(encounter_id), "未知遭遇 id: %s" % String(encounter_id))
	return _by_id[encounter_id]
