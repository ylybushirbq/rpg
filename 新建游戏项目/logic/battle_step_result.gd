class_name BattleStepResult
extends RefCounted
## 一次指令结算后的展示数据。UI 只读这个对象。

enum Outcome {
	NONE,
	VICTORY,
	DEFEAT,
}

var log_line: String = ""
var outcome: Outcome = Outcome.NONE
var damage_dealt: int = 0
var wait_for_enemy: bool = false
