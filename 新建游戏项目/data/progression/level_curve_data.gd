class_name LevelCurveData
extends Resource
## 升级曲线。exp_to_next(L) = per_level × L + base。

@export var level_cap: int = 10
@export var base: int = 20
@export var per_level: int = 40
@export var points_per_level: int = 3
