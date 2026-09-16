class_name SaveSlotPicker
extends Control
## 复用的三栏位选择器。存档覆盖确认由调用页面负责。

signal slot_chosen(slot: int)
signal dismissed

@onready var _title: Label = %Title
@onready var _slot_one: Button = %SlotOne
@onready var _slot_two: Button = %SlotTwo
@onready var _slot_three: Button = %SlotThree
@onready var _cancel: Button = %CancelButton


func _ready() -> void:
	_slot_one.pressed.connect(_choose.bind(1))
	_slot_two.pressed.connect(_choose.bind(2))
	_slot_three.pressed.connect(_choose.bind(3))
	_cancel.pressed.connect(close)
	visible = false


func open(title: String, require_existing: bool) -> void:
	_title.text = title
	_set_slot_button(_slot_one, 1, require_existing)
	_set_slot_button(_slot_two, 2, require_existing)
	_set_slot_button(_slot_three, 3, require_existing)
	visible = true


func close() -> void:
	if visible:
		visible = false
		dismissed.emit()


func _set_slot_button(button: Button, slot: int, require_existing: bool) -> void:
	button.text = GameState.slot_summary(slot)
	button.disabled = require_existing and not GameState.slot_exists(slot)


func _choose(slot: int) -> void:
	visible = false
	slot_chosen.emit(slot)
