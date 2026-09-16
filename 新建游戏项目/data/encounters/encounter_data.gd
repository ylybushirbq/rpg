class_name EncounterData
extends Resource
## 路线上的一场 1v1 遭遇。enemies 长度固定为 1。

@export var id: StringName = &""
@export var display_name: String = ""
@export var enemies: Array[StringName] = []
@export var first_drop_ids: Array[StringName] = []
@export var guard_extra_drop_id: StringName = &""
@export var sorcerer_extra_drop_id: StringName = &""
