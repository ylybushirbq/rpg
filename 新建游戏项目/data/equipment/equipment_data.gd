class_name EquipmentData
extends Resource
## 一件固定数值装备。1.0 不读词缀与耐久。

@export var id: StringName = &""
@export var display_name: String = ""
@export var slot: StringName = &"weapon"
@export var class_allowed: Array[StringName] = []
@export var phys_atk: int = 0
@export var mag_atk: int = 0
@export var defense: int = 0
@export var hp: int = 0
@export var mp: int = 0
@export var affixes: Array[StringName] = []
@export var durability: int = -1
@export var set_id: StringName = &""


func can_equip(class_id: StringName) -> bool:
	if class_allowed.is_empty():
		return true
	return class_allowed.has(class_id)
