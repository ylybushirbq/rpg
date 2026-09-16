class_name SkillTable
extends Resource
## 技能表。

@export var skills: Array[SkillData] = []

var _by_id: Dictionary[StringName, SkillData] = {}


func ensure_index() -> void:
	if not _by_id.is_empty():
		return
	for skill: SkillData in skills:
		_by_id[skill.id] = skill


func get_skill(skill_id: StringName) -> SkillData:
	ensure_index()
	assert(_by_id.has(skill_id), "未知技能 id: %s" % String(skill_id))
	return _by_id[skill_id]
