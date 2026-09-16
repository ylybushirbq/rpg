class_name SkillData
extends Resource
## 一条技能的静态数据。倍率用整数分子分母。

@export var id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
@export var class_id: StringName = &""
@export var unlock_level: int = 1
@export var mp_cost: int = 0
@export var rg_cost: int = 0
@export var cooldown: int = 0
@export var multiplier_num: int = 10
@export var multiplier_den: int = 10
@export var uses_magic: bool = false
@export var status_apply: StringName = &""
@export var is_combo: bool = false
