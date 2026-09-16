extends Control
## 出征：四节点，标已通关。

@onready var _back_button: Button = %BackButton
@onready var _node_box: VBoxContainer = %NodeBox
@onready var _hint_label: Label = %HintLabel


func _ready() -> void:
	_back_button.pressed.connect(_on_back_button_pressed)
	_build_nodes()


func _on_back_button_pressed() -> void:
	GameState.go_hub()


func _build_nodes() -> void:
	for encounter: EncounterData in GameState.catalog.encounters.encounters:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var button := Button.new()
		button.custom_minimum_size = Vector2(280, 44)
		button.text = encounter.display_name
		button.pressed.connect(_on_node_pressed.bind(encounter.id))
		var mark := Label.new()
		if GameState.is_node_cleared(encounter.id):
			mark.text = "已通关（可再战，经验照给）"
		else:
			mark.text = "未通关"
		row.add_child(button)
		row.add_child(mark)
		_node_box.add_child(row)


func _on_node_pressed(encounter_id: StringName) -> void:
	_hint_label.text = ""
	GameState.go_battle(encounter_id)
