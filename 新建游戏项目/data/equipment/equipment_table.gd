class_name EquipmentTable
extends Resource
## 装备表。

@export var items: Array[EquipmentData] = []

var _by_id: Dictionary[StringName, EquipmentData] = {}


func ensure_index() -> void:
	if not _by_id.is_empty():
		return
	for item: EquipmentData in items:
		_by_id[item.id] = item


func get_item(item_id: StringName) -> EquipmentData:
	ensure_index()
	assert(_by_id.has(item_id), "未知装备 id: %s" % String(item_id))
	return _by_id[item_id]


func try_get_item(item_id: StringName) -> EquipmentData:
	if item_id == &"":
		return null
	ensure_index()
	if not _by_id.has(item_id):
		return null
	return _by_id[item_id]
