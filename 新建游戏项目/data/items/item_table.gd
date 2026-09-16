class_name ItemTable
extends Resource
## 消耗品表。

@export var items: Array[ItemData] = []

var _by_id: Dictionary[StringName, ItemData] = {}


func ensure_index() -> void:
	if not _by_id.is_empty():
		return
	for item: ItemData in items:
		_by_id[item.id] = item


func get_item(item_id: StringName) -> ItemData:
	ensure_index()
	assert(_by_id.has(item_id), "未知物品 id: %s" % String(item_id))
	return _by_id[item_id]
