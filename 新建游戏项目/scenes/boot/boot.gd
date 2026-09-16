extends Control
## 开始页：新游戏、加载、退出。不自动进据点菜单。

@onready var _error_label: Label = %ErrorLabel
@onready var _new_button: Button = %NewButton
@onready var _load_button: Button = %LoadButton
@onready var _quit_button: Button = %QuitButton
@onready var _slot_picker: Control = %SlotPicker
@onready var _overwrite_dialog: ConfirmationDialog = %OverwriteDialog

var _slot_mode: StringName = &""
var _pending_slot: int = 0


func _ready() -> void:
	_new_button.pressed.connect(_on_new_button_pressed)
	_load_button.pressed.connect(_on_load_button_pressed)
	_quit_button.pressed.connect(_on_quit_button_pressed)
	_slot_picker.connect(&"slot_chosen", _on_slot_chosen)
	_overwrite_dialog.confirmed.connect(_on_overwrite_confirmed)
	_refresh()


func _refresh() -> void:
	_load_button.disabled = not GameState.has_save()
	if GameState.corrupt_save_message != "":
		_error_label.text = GameState.corrupt_save_message
		_error_label.visible = true
	else:
		_error_label.visible = false


func _on_new_button_pressed() -> void:
	GameState.corrupt_save_message = ""
	_slot_mode = &"new"
	_slot_picker.call(&"open", "选择新游戏存档栏位", false)


func _on_load_button_pressed() -> void:
	_slot_mode = &"load"
	_slot_picker.call(&"open", "选择要加载的存档", true)


func _on_slot_chosen(slot: int) -> void:
	_pending_slot = slot
	if _slot_mode == &"new":
		if GameState.slot_exists(slot):
			_overwrite_dialog.dialog_text = "栏位 %d 已有存档。开始新游戏会在创建角色后覆盖它，是否继续？" % slot
			_overwrite_dialog.popup_centered()
			return
		_begin_new_game()
		return
	if _slot_mode != &"load":
		return
	var reason := GameState.load_slot(slot)
	if reason != "":
		_error_label.text = reason
		_error_label.visible = true
		_refresh()
		return
	GameState.go_exploration()


func _on_overwrite_confirmed() -> void:
	_begin_new_game()


func _begin_new_game() -> void:
	GameState.select_save_slot(_pending_slot)
	GameState.go_create()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
