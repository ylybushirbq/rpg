extends Control
## 创建角色：名字 + 卫士 / 咒术师。

@onready var _name_edit: LineEdit = %NameEdit
@onready var _guard_button: Button = %GuardButton
@onready var _sorcerer_button: Button = %SorcererButton
@onready var _start_button: Button = %StartButton
@onready var _back_button: Button = %BackButton
@onready var _hint_label: Label = %HintLabel

var _class_id: StringName = &"guard"


func _ready() -> void:
	_name_edit.placeholder_text = GameState.catalog.rules.default_hero_name
	_name_edit.text = GameState.catalog.rules.default_hero_name
	_guard_button.pressed.connect(_on_guard_button_pressed)
	_sorcerer_button.pressed.connect(_on_sorcerer_button_pressed)
	_start_button.pressed.connect(_on_start_button_pressed)
	_back_button.pressed.connect(_on_back_button_pressed)
	_refresh_class_buttons()


func _on_guard_button_pressed() -> void:
	_class_id = &"guard"
	_refresh_class_buttons()


func _on_sorcerer_button_pressed() -> void:
	_class_id = &"sorcerer"
	_refresh_class_buttons()


func _on_start_button_pressed() -> void:
	var reason := GameState.create_hero(_name_edit.text, _class_id)
	if reason != "":
		_hint_label.text = reason
		return
	GameState.go_exploration()


func _on_back_button_pressed() -> void:
	GameState.go_title()


func _refresh_class_buttons() -> void:
	_guard_button.disabled = _class_id == &"guard"
	_sorcerer_button.disabled = _class_id == &"sorcerer"
	if _class_id == &"guard":
		_hint_label.text = "卫士：体质成长，物理技能。"
	else:
		_hint_label.text = "咒术师：智力成长，法术技能。"
	if GameState.has_save():
		_hint_label.text += " 开始后会覆盖现有存档。"
