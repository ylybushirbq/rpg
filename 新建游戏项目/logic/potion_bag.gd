class_name PotionBag
extends RefCounted
## 两种药水的数量。战斗与据点共用同一份引用。

var bandage: int = 0
var water: int = 0


func count_of(item_id: StringName, rules: BattleRulesData) -> int:
	if item_id == rules.bandage_id:
		return bandage
	if item_id == rules.water_id:
		return water
	return 0


func consume(item_id: StringName, rules: BattleRulesData) -> void:
	if item_id == rules.bandage_id:
		bandage = maxi(0, bandage - 1)
	elif item_id == rules.water_id:
		water = maxi(0, water - 1)
