class_name Hd2dCamera
extends Node3D
## 八方旅人式镜头：可自由环绕，并在探索时跟随主角。

signal view_mode_changed(is_free: bool)

enum ViewMode {
	FIXED,
	FREE,
}

const FIXED_PITCH_DEG: float = -38.0
const FIXED_YAW_DEG: float = 42.0
const FIXED_DISTANCE: float = 11.5
const MIN_DISTANCE: float = 5.0
const MAX_DISTANCE: float = 22.0
const MIN_PITCH_DEG: float = -75.0
const MAX_PITCH_DEG: float = -12.0
const MOUSE_SENS: float = 0.18
const ZOOM_STEP: float = 0.9
const FOLLOW_LERP_SPEED: float = 9.0

@onready var _pivot: Node3D = %CameraPivot
@onready var _boom: Node3D = %CameraBoom

var _mode: ViewMode = ViewMode.FIXED
var _yaw_deg: float = FIXED_YAW_DEG
var _pitch_deg: float = FIXED_PITCH_DEG
var _distance: float = FIXED_DISTANCE
var _dragging: bool = false
var _follow_target: Node3D


func _ready() -> void:
	_apply_transform()
	set_process(false)


func is_free() -> bool:
	return _mode == ViewMode.FREE


func set_view_mode(mode: ViewMode) -> void:
	_mode = mode
	if _mode == ViewMode.FIXED:
		_yaw_deg = FIXED_YAW_DEG
		_pitch_deg = FIXED_PITCH_DEG
		_distance = FIXED_DISTANCE
		_dragging = false
		set_process(false)
	else:
		set_process(true)
	_apply_transform()
	view_mode_changed.emit(is_free())


func set_follow_target(target: Node3D) -> void:
	_follow_target = target
	if _follow_target != null:
		global_position = _follow_target.global_position


func reset_view() -> void:
	set_view_mode(ViewMode.FIXED)
	set_view_mode(ViewMode.FREE)


func horizontal_basis() -> Basis:
	var yaw_basis := Basis(Vector3.UP, deg_to_rad(_yaw_deg))
	return yaw_basis


func toggle_view_mode() -> void:
	if _mode == ViewMode.FIXED:
		set_view_mode(ViewMode.FREE)
	else:
		set_view_mode(ViewMode.FIXED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo and key.keycode == KEY_C:
			toggle_view_mode()
			get_viewport().set_input_as_handled()
			return
	if _mode != ViewMode.FREE:
		return
	if event is InputEventMouseButton:
		_handle_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion and _dragging:
		var motion := event as InputEventMouseMotion
		_yaw_deg -= motion.relative.x * MOUSE_SENS
		_pitch_deg -= motion.relative.y * MOUSE_SENS
		_pitch_deg = clampf(_pitch_deg, MIN_PITCH_DEG, MAX_PITCH_DEG)
		_apply_transform()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _follow_target != null and is_instance_valid(_follow_target):
		global_position = global_position.lerp(
				_follow_target.global_position,
				1.0 - exp(-FOLLOW_LERP_SPEED * delta),
		)


func _handle_mouse_button(mb: InputEventMouseButton) -> void:
	if mb.button_index == MOUSE_BUTTON_RIGHT:
		_dragging = mb.pressed
		get_viewport().set_input_as_handled()
		return
	if not mb.pressed:
		return
	if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
		_distance = maxf(MIN_DISTANCE, _distance - ZOOM_STEP)
		_apply_transform()
		get_viewport().set_input_as_handled()
	elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_distance = minf(MAX_DISTANCE, _distance + ZOOM_STEP)
		_apply_transform()
		get_viewport().set_input_as_handled()


func _apply_transform() -> void:
	_pivot.rotation_degrees = Vector3(_pitch_deg, _yaw_deg, 0.0)
	_boom.position = Vector3(0.0, 0.0, _distance)
