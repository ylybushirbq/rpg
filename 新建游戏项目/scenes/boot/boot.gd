extends Control
## 启动：读档成功进据点，坏档提示后去创建页。

@onready var _error_label: Label = %ErrorLabel
@onready var _continue_button: Button = %ContinueButton


func _ready() -> void:
	_continue_button.pressed.connect(_on_continue_button_pressed)
	if GameState.corrupt_save_message != "":
		_error_label.text = GameState.corrupt_save_message
		_error_label.visible = true
		_continue_button.visible = true
		return
	if GameState.has_hero():
		GameState.go_hub()
		return
	GameState.go_create()


func _on_continue_button_pressed() -> void:
	GameState.corrupt_save_message = ""
	GameState.go_create()
