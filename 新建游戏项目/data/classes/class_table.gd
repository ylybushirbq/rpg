class_name ClassTable
extends Resource
## 职业表。按 id 查找，不要在脚本里写死六维。

@export var classes: Array[ClassData] = []

var _by_id: Dictionary[StringName, ClassData] = {}


func ensure_index() -> void:
	if not _by_id.is_empty():
		return
	for class_data: ClassData in classes:
		_by_id[class_data.id] = class_data


func get_class_data(class_id: StringName) -> ClassData:
	ensure_index()
	assert(_by_id.has(class_id), "未知职业 id: %s" % String(class_id))
	return _by_id[class_id]


func has_class(class_id: StringName) -> bool:
	ensure_index()
	return _by_id.has(class_id)
