class_name RewardReport
extends RefCounted
## 战胜后的经验 / 金币 / 掉落 / 升级摘要。

var reward_exp: int = 0
var reward_gold: int = 0
var gained_exp: int = 0
var discarded_exp: int = 0
var drops: Array[EquipmentData] = []
var discarded_drops: Array[String] = []
var levels_gained: int = 0
var new_skill_names: Array[String] = []
var start_level: int = 1
var start_exp: int = 0
var end_level: int = 1
var end_exp: int = 0
var campaign_cleared: bool = false
