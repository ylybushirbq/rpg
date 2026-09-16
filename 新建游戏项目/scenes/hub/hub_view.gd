extends Node
## 据点：摘要、五个入口、进据点自动存。

@onready var _name_label: Label = %NameLabel
@onready var _gold_label: Label = %GoldLabel
@onready var _rg_note_label: Label = %RgNoteLabel
@onready var _hint_label: Label = %HintLabel
@onready var _clear_label: Label = %ClearLabel
@onready var _exp_bar: ExpBar = %ExpBar
@onready var _expedition_button: Button = %ExpeditionButton
@onready var _character_button: Button = %CharacterButton
@onready var _equipment_button: Button = %EquipmentButton
@onready var _rest_button: Button = %RestButton
@onready var _world: Hd2dWorld = %Hd2dWorld


func _ready() -> void:
	_expedition_button.pressed.connect(_on_expedition_button_pressed)
	_character_button.pressed.connect(_on_character_button_pressed)
	_equipment_button.pressed.connect(_on_equipment_button_pressed)
	_rest_button.pressed.connect(_on_rest_button_pressed)
	GameState.save_game()
	_world.setup_hub(GameState.hero.name)
	_refresh()


func _on_expedition_button_pressed() -> void:
	GameState.go_expedition()


func _on_character_button_pressed() -> void:
	GameState.go_character()


func _on_equipment_button_pressed() -> void:
	GameState.go_equipment()


func _on_rest_button_pressed() -> void:
	GameState.rest_at_hub()
	_refresh()


func _refresh() -> void:
	var hero := GameState.hero
	var class_data := GameState.catalog.classes.get_class_data(hero.class_id)
	_name_label.text = "%s · %s" % [hero.name, class_data.display_name]
	_gold_label.text = "金币 %d　%s" % [hero.gold, UiText.NO_SHOP]
	_rg_note_label.text = UiText.RG_CAP_NOTE
	var need := DerivedStats.exp_to_next(hero.level, GameState.catalog.level_curve)
	_exp_bar.bind(hero.level, hero.exp, need, GameState.catalog.level_curve.level_cap)
	_hint_label.text = GameState.last_hint
	if GameState.is_campaign_cleared():
		_clear_label.text = "已击败烬狼，通关。"
		_clear_label.visible = true
	else:
		_clear_label.visible = false
