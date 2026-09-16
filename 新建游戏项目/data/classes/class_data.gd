class_name ClassData
extends Resource
## 一条职业的静态数据。

@export var id: StringName = &""
@export var display_name: String = ""
@export var str: int = 0
@export var agi: int = 0
@export var intl: int = 0
@export var con: int = 0
@export var spi: int = 0
@export var luk: int = 0
@export var primary_stat: StringName = &"con"
@export var skill_ids: Array[StringName] = []
@export var starter_weapon_id: StringName = &""
@export var starter_armor_id: StringName = &""
