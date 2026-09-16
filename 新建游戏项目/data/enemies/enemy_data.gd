class_name EnemyData
extends Resource
## 一只敌人的静态数据。攻击力按物理攻击结算。

@export var id: StringName = &""
@export var display_name: String = ""
@export var hp: int = 1
@export var phys_atk: int = 0
@export var defense: int = 0
@export var speed: int = 0
@export var reward_exp: int = 0
@export var reward_gold: int = 0
@export var exp_type: StringName = &"mob"
