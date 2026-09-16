extends Node
## 实时探索入口：WASD 控制主角，按累计位移结算暗雷。

const WALK_SPEED: float = 4.6
const MAP_LIMIT: float = 10.0

@onready var _world: Hd2dWorld = %Hd2dWorld
@onready var _name_label: Label = %NameLabel
@onready var _status_label: Label = %StatusLabel
@onready var _return_button: Button = %ReturnButton
@onready var _camera_button: Button = %CameraButton

var _hero_actor: Hd2dActorPlaceholder
var _encounters := RandomEncounter.new()
var _changing_scene: bool = false


func _ready() -> void:
	_return_button.pressed.connect(_on_return_button_pressed)
	_camera_button.pressed.connect(_on_camera_button_pressed)
	_hero_actor = _world.setup_exploration(GameState.hero.name, GameState.exploration_position)
	_world.camera().set_view_mode(Hd2dCamera.ViewMode.FREE)
	_world.camera().set_follow_target(_hero_actor)
	_name_label.text = "%s  ·  探索中" % GameState.hero.name
	_status_label.text = "WASD 移动 · 右键拖拽镜头 · 滚轮缩放 · C 重置视角"


func _physics_process(delta: float) -> void:
	if _changing_scene or _hero_actor == null:
		return
	var input: Vector2 = Input.get_vector(
			&"move_left",
			&"move_right",
			&"move_forward",
			&"move_back",
	)
	if input.is_zero_approx():
		return
	var camera_basis: Basis = _world.camera().horizontal_basis()
	var direction: Vector3 = camera_basis * Vector3(input.x, 0.0, input.y)
	if direction.is_zero_approx():
		return
	direction = direction.normalized()
	var before: Vector3 = _hero_actor.position
	var next: Vector3 = before + direction * WALK_SPEED * delta
	next.x = clampf(next.x, -MAP_LIMIT, MAP_LIMIT)
	next.z = clampf(next.z, -MAP_LIMIT, MAP_LIMIT)
	_hero_actor.position = next
	_hero_actor.rotation.y = lerp_angle(_hero_actor.rotation.y, atan2(direction.x, direction.z), 14.0 * delta)
	var travelled := before.distance_to(next)
	GameState.exploration_position = next
	if _encounters.add_distance(travelled):
		_start_encounter()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"reset_camera"):
		_world.camera().reset_view()
		get_viewport().set_input_as_handled()


func _start_encounter() -> void:
	var encounter_id := _encounters.pick_encounter(GameState.catalog, GameState.cleared_node_ids)
	if encounter_id == &"":
		return
	_changing_scene = true
	_status_label.text = "遭遇敌人！"
	GameState.save_game()
	GameState.go_battle(encounter_id)


func _on_return_button_pressed() -> void:
	if _changing_scene:
		return
	GameState.exploration_position = _hero_actor.position
	GameState.save_game()
	GameState.go_hub()


func _on_camera_button_pressed() -> void:
	_world.camera().reset_view()
