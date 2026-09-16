extends Node
## 实时探索：WASD 移动、地图据点、暗雷、背包。

const WALK_SPEED: float = 4.6
const RUN_SPEED_MULTIPLIER: float = 1.65
const MAP_LIMIT: float = 10.0

@onready var _world: Hd2dWorld = %Hd2dWorld
@onready var _name_label: Label = %NameLabel
@onready var _status_label: Label = %StatusLabel
@onready var _hint_label: Label = %HintLabel
@onready var _camera_button: Button = %CameraButton
@onready var _bag_button: Button = %BagButton
@onready var _hub_panel: Control = %HubPanel
@onready var _hub_body: Label = %HubBody
@onready var _hub_equip_button: Button = %HubEquipButton
@onready var _hub_leave_button: Button = %HubLeaveButton
@onready var _backpack: BackpackView = %Backpack

var _hero_actor: CharacterBody3D
var _encounters := RandomEncounter.new()
var _changing_scene: bool = false
var _in_hub_menu: bool = false
var _is_running: bool = false


func _ready() -> void:
	_camera_button.pressed.connect(_on_camera_button_pressed)
	_bag_button.pressed.connect(_on_bag_button_pressed)
	_hub_equip_button.pressed.connect(_on_hub_equip_pressed)
	_hub_leave_button.pressed.connect(_on_hub_leave_pressed)
	_backpack.closed.connect(_on_backpack_closed)
	_backpack.request_reset_camera.connect(_on_camera_button_pressed)
	_backpack.request_title.connect(_on_title_requested)
	_hub_panel.visible = false
	_hero_actor = _world.setup_exploration(
			GameState.hero.name,
			GameState.exploration_position,
	) as CharacterBody3D
	_world.camera().set_view_mode(Hd2dCamera.ViewMode.FREE)
	_world.camera().set_follow_target(_hero_actor)
	_name_label.text = "%s  ·  探索中" % GameState.hero.name
	_refresh_status()
	if GameState.last_hint != "":
		_hint_label.text = GameState.last_hint
		GameState.last_hint = ""


func _physics_process(delta: float) -> void:
	if _ui_locked() or _hero_actor == null:
		return
	var input: Vector2 = Input.get_vector(
			&"move_left",
			&"move_right",
			&"move_forward",
			&"move_back",
	)
	if input.is_zero_approx():
		_refresh_status()
		return
	var camera_basis: Basis = _world.camera().horizontal_basis()
	var direction: Vector3 = camera_basis * Vector3(input.x, 0.0, input.y)
	if direction.is_zero_approx():
		return
	direction = direction.normalized()
	var before: Vector3 = _hero_actor.position
	var speed: float = WALK_SPEED
	if _is_running:
		speed *= RUN_SPEED_MULTIPLIER
	var wanted: Vector3 = before + direction * speed * delta
	wanted.x = clampf(wanted.x, -MAP_LIMIT, MAP_LIMIT)
	wanted.z = clampf(wanted.z, -MAP_LIMIT, MAP_LIMIT)
	_hero_actor.move_and_collide(wanted - before)
	var next: Vector3 = _hero_actor.position
	_hero_actor.rotation.y = lerp_angle(_hero_actor.rotation.y, atan2(direction.x, direction.z), 14.0 * delta)
	var travelled := before.distance_to(next)
	GameState.exploration_position = next
	_refresh_status()
	if GameState.is_near_hub(next):
		return
	if _encounters.add_distance(travelled):
		_start_encounter()


func _unhandled_input(event: InputEvent) -> void:
	if _changing_scene:
		return
	if event.is_action_pressed(&"reset_camera"):
		_world.camera().reset_view()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"toggle_run"):
		_is_running = not _is_running
		_hero_actor.call(&"set_running", _is_running)
		_refresh_status()
		get_viewport().set_input_as_handled()
		return
	if _backpack.is_open() or _in_hub_menu:
		return
	if event.is_action_pressed(&"open_bag"):
		_open_backpack()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"interact") and GameState.is_near_hub(_hero_actor.position):
		_enter_hub()
		get_viewport().set_input_as_handled()


func _ui_locked() -> bool:
	return _changing_scene or _in_hub_menu or _backpack.is_open()


func _refresh_status() -> void:
	if _hero_actor == null:
		return
	if GameState.is_near_hub(_hero_actor.position):
		_status_label.text = "据点附近 · 按 E 进入"
	else:
		var move_state := "奔跑" if _is_running else "步行"
		_status_label.text = "%s · Shift 切换 · 右键镜头 · B 背包" % move_state


func _enter_hub() -> void:
	_in_hub_menu = true
	GameState.rest_at_hub()
	GameState.exploration_position = _hero_actor.position
	_hub_body.text = "体力已恢复。HP/MP 已回满（不补充药水）。"
	_hub_panel.visible = true
	_hint_label.text = GameState.last_hint


func _open_backpack(tab_index: int = 0) -> void:
	_backpack.open(tab_index)


func _start_encounter() -> void:
	var encounter_id := _encounters.pick_encounter(GameState.catalog, GameState.cleared_node_ids)
	if encounter_id == &"":
		return
	_changing_scene = true
	_status_label.text = "遭遇敌人！"
	GameState.save_game()
	GameState.go_battle(encounter_id)


func _on_return_or_leave_map() -> void:
	GameState.exploration_position = _hero_actor.position
	GameState.save_game()
	GameState.go_title()


func _on_camera_button_pressed() -> void:
	_world.camera().reset_view()


func _on_bag_button_pressed() -> void:
	if _ui_locked() and not _backpack.is_open():
		return
	if _backpack.is_open():
		_backpack.close()
		return
	_open_backpack()


func _on_hub_equip_pressed() -> void:
	_hub_panel.visible = false
	_in_hub_menu = false
	_open_backpack(2)


func _on_hub_leave_pressed() -> void:
	_hub_panel.visible = false
	_in_hub_menu = false
	_refresh_status()


func _on_backpack_closed() -> void:
	_refresh_status()
	_name_label.text = "%s  ·  探索中" % GameState.hero.name


func _on_title_requested() -> void:
	_on_return_or_leave_map()
