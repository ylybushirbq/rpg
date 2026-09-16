class_name BattleRulesData
extends Resource
## 1.0 战斗与养成常量。不要把这些数字写进结算 if。

@export var rg_max: int = 100
@export var rg_on_attack_hit: int = 15
@export var rg_on_take_hit: int = 10
@export var rg_on_defend: int = 20
@export var rage_cost: int = 100
@export var mp_restore_percent: int = 20
@export var defend_divisor: int = 2
@export var min_undefended_damage: int = 1
@export var inventory_cap: int = 30
@export var starter_bandage: int = 3
@export var starter_water: int = 3
@export var name_min_chars: int = 2
@export var name_max_chars: int = 12
@export var default_hero_name: String = "旅团长"
@export var bandage_id: StringName = &"p_hp"
@export var water_id: StringName = &"p_mp"
