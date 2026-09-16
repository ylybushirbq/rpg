class_name EnemyTable
extends Resource
## 敌人表。

@export var enemies: Array[EnemyData] = []

var _by_id: Dictionary[StringName, EnemyData] = {}


func ensure_index() -> void:
	if not _by_id.is_empty():
		return
	for enemy: EnemyData in enemies:
		_by_id[enemy.id] = enemy


func get_enemy(enemy_id: StringName) -> EnemyData:
	ensure_index()
	assert(_by_id.has(enemy_id), "未知敌人 id: %s" % String(enemy_id))
	return _by_id[enemy_id]
