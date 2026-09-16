class_name PlayerCharacter
extends RefCounted
## 可玩角色的持久字段。战斗临时 RG / 防御不放这里。

var name: String = ""
var class_id: StringName = &""
var level: int = 1
var exp: int = 0
var str: int = 0
var agi: int = 0
var intl: int = 0
var con: int = 0
var spi: int = 0
var luk: int = 0
var unspent_stat_points: int = 0
var hp: int = 1
var hp_max: int = 1
var mp: int = 0
var mp_max: int = 0
var rg: int = 0
var rg_max: int = 100
var weapon_id: StringName = &""
var armor_id: StringName = &""
var accessory_id: StringName = &""
var learned_skill_ids: Array[StringName] = []
var gold: int = 0
var companions: Array[StringName] = []
var job_change_unlocked: bool = false
var statuses: Array[StringName] = []


func stat_value(stat_id: StringName) -> int:
	match stat_id:
		&"str":
			return str
		&"agi":
			return agi
		&"intl":
			return intl
		&"con":
			return con
		&"spi":
			return spi
		&"luk":
			return luk
		_:
			return 0


func set_stat_value(stat_id: StringName, value: int) -> void:
	match stat_id:
		&"str":
			str = value
		&"agi":
			agi = value
		&"intl":
			intl = value
		&"con":
			con = value
		&"spi":
			spi = value
		&"luk":
			luk = value


func has_learned(skill_id: StringName) -> bool:
	return learned_skill_ids.has(skill_id)


func learn_skill(skill_id: StringName) -> bool:
	if has_learned(skill_id):
		return false
	learned_skill_ids.append(skill_id)
	return true


func equipped_id(slot: StringName) -> StringName:
	match slot:
		&"weapon":
			return weapon_id
		&"armor":
			return armor_id
		&"accessory":
			return accessory_id
		_:
			return &""


func set_equipped_id(slot: StringName, item_id: StringName) -> void:
	match slot:
		&"weapon":
			weapon_id = item_id
		&"armor":
			armor_id = item_id
		&"accessory":
			accessory_id = item_id
