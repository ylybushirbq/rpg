class_name GameCatalog
extends Resource
## 运行时只读策划表入口。

@export var classes: ClassTable
@export var skills: SkillTable
@export var equipment: EquipmentTable
@export var enemies: EnemyTable
@export var encounters: EncounterTable
@export var items: ItemTable
@export var level_curve: LevelCurveData
@export var rules: BattleRulesData


func ensure_index() -> void:
	classes.ensure_index()
	skills.ensure_index()
	equipment.ensure_index()
	enemies.ensure_index()
	encounters.ensure_index()
	items.ensure_index()
