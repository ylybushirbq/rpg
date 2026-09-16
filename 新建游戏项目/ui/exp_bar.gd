class_name ExpBar
extends VBoxContainer
## 金色经验条。满级时条填满并显示已满级。

@onready var _level_label: Label = %ExpLevelLabel
@onready var _progress: ProgressBar = %ExpProgress
@onready var _value_label: Label = %ExpValueLabel


func _ready() -> void:
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.85, 0.7, 0.2)
	fill.corner_radius_top_left = 3
	fill.corner_radius_top_right = 3
	fill.corner_radius_bottom_right = 3
	fill.corner_radius_bottom_left = 3
	_progress.add_theme_stylebox_override("fill", fill)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.18, 0.16, 0.1)
	_progress.add_theme_stylebox_override("background", bg)
	_progress.show_percentage = false


func bind(level: int, exp_value: int, exp_to_next: int, level_cap: int) -> void:
	if level >= level_cap:
		_level_label.text = "Lv.%d 已满级" % level
		_progress.max_value = 1.0
		_progress.value = 1.0
		_value_label.text = "已满级"
		return
	_level_label.text = "Lv.%d" % level
	_progress.max_value = float(maxi(1, exp_to_next))
	_progress.value = float(exp_value)
	_value_label.text = "%d / %d" % [exp_value, exp_to_next]
