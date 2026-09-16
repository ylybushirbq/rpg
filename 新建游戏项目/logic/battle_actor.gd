class_name BattleActor
extends RefCounted
## 一场战斗里的运行时单位。不要写回 .tres。

var display_name: String = ""
var is_player: bool = false
var hp: int = 1
var hp_max: int = 1
var mp: int = 0
var mp_max: int = 0
var rg: int = 0
var rg_max: int = 100
var phys_atk: int = 0
var mag_atk: int = 0
var defense: int = 0
var speed: int = 0
var is_defending: bool = false
var learned_skill_ids: Array[StringName] = []


func is_down() -> bool:
	return hp <= 0
