class_name Hd2dWorld
extends Node3D
## HD-2D 舞台：色块布景 + 斜视镜头 + 方向光阴影。
## 换美术时替换 PropHost / 演员 Sprite3D 贴图，不要改结算。

const ACTOR_SCENE := preload("res://scenes/hd2d/hd2d_actor_placeholder.tscn")
const PLAYER_COLOR := Color(0.32, 0.52, 0.82, 1)
const ENEMY_COLOR := Color(0.78, 0.28, 0.24, 1)
const HERO_COLOR := Color(0.45, 0.62, 0.38, 1)

@export var stage_id: StringName = &"hub"
@export var allow_free_camera: bool = true

@onready var _camera: Hd2dCamera = %CameraRig
@onready var _prop_host: Node3D = %PropHost
@onready var _player_slot: Marker3D = %PlayerSlot
@onready var _enemy_slot: Marker3D = %EnemySlot
@onready var _hub_slot: Marker3D = %HubHeroSlot

var _player_actor: Hd2dActorPlaceholder
var _enemy_actor: Hd2dActorPlaceholder
var _hub_actor: Hd2dActorPlaceholder
var _exploration_actor: Hd2dActorPlaceholder


func _ready() -> void:
	_build_placeholder_props()
	_camera.set_view_mode(Hd2dCamera.ViewMode.FIXED)
	if not allow_free_camera:
		_camera.set_process(false)
	_apply_stage()


func camera() -> Hd2dCamera:
	return _camera


func setup_battle(player_name: String, enemy_name: String) -> void:
	stage_id = &"battle"
	_clear_actors()
	_player_actor = _spawn_actor(_player_slot, PLAYER_COLOR, player_name)
	_enemy_actor = _spawn_actor(_enemy_slot, ENEMY_COLOR, enemy_name)
	_apply_stage()


func setup_hub(hero_name: String) -> void:
	stage_id = &"hub"
	_clear_actors()
	_hub_actor = _spawn_actor(_hub_slot, HERO_COLOR, hero_name)
	_apply_stage()


func setup_exploration(hero_name: String, start_position: Vector3) -> Hd2dActorPlaceholder:
	stage_id = &"exploration"
	_clear_actors()
	_exploration_actor = ACTOR_SCENE.instantiate() as Hd2dActorPlaceholder
	add_child(_exploration_actor)
	_exploration_actor.position = start_position
	_exploration_actor.set_body_color(HERO_COLOR)
	_exploration_actor.set_caption(hero_name)
	_apply_stage()
	return _exploration_actor


func view_mode_label() -> String:
	if not allow_free_camera:
		return "镜头：固定"
	if _camera.is_free():
		return "镜头：自由（C 切换，右键拖转，WASD 移动，滚轮缩放）"
	return "镜头：固定（按 C 或按钮切到自由）"


func _apply_stage() -> void:
	_player_slot.visible = stage_id == &"battle"
	_enemy_slot.visible = stage_id == &"battle"
	_hub_slot.visible = stage_id == &"hub"


func _spawn_actor(
		slot: Marker3D,
		color: Color,
		caption: String,
) -> Hd2dActorPlaceholder:
	var actor := ACTOR_SCENE.instantiate() as Hd2dActorPlaceholder
	slot.add_child(actor)
	actor.set_body_color(color)
	actor.set_caption(caption)
	return actor


func _clear_actors() -> void:
	_free_actor(_player_actor)
	_free_actor(_enemy_actor)
	_free_actor(_hub_actor)
	_free_actor(_exploration_actor)
	_player_actor = null
	_enemy_actor = null
	_hub_actor = null
	_exploration_actor = null


func _free_actor(actor: Hd2dActorPlaceholder) -> void:
	if actor != null and is_instance_valid(actor):
		actor.queue_free()


func _build_placeholder_props() -> void:
	for child: Node in _prop_host.get_children():
		child.queue_free()
	_add_box(Vector3(0.0, -0.02, 0.0), Vector3(22.0, 0.04, 22.0), Color(0.36, 0.32, 0.28))
	_add_box(Vector3(-7.5, 1.4, -6.0), Vector3(2.2, 2.8, 2.2), Color(0.28, 0.3, 0.34))
	_add_box(Vector3(-5.2, 0.9, -7.2), Vector3(1.4, 1.8, 1.4), Color(0.24, 0.26, 0.3))
	_add_box(Vector3(7.0, 1.1, -5.5), Vector3(1.8, 2.2, 1.8), Color(0.22, 0.34, 0.24))
	_add_box(Vector3(8.4, 2.2, -6.4), Vector3(0.55, 4.4, 0.55), Color(0.18, 0.28, 0.2))
	_add_box(Vector3(6.2, 2.0, -7.1), Vector3(0.5, 4.0, 0.5), Color(0.16, 0.26, 0.18))
	_add_box(Vector3(3.5, 0.35, 4.8), Vector3(1.6, 0.7, 1.2), Color(0.42, 0.36, 0.3))
	_add_box(Vector3(-3.8, 0.28, 5.2), Vector3(1.3, 0.56, 1.0), Color(0.4, 0.34, 0.28))
	_add_box(Vector3(0.8, 0.22, -3.4), Vector3(2.4, 0.44, 1.1), Color(0.33, 0.29, 0.25))
	_add_box(Vector3(-8.5, 0.7, 2.0), Vector3(1.1, 1.4, 1.1), Color(0.5, 0.38, 0.22))
	_add_box(Vector3(-9.5, 0.3, -1.5), Vector3(1.2, 0.6, 3.4), Color(0.3, 0.38, 0.24))
	_add_box(Vector3(9.2, 0.3, 3.0), Vector3(1.2, 0.6, 3.8), Color(0.3, 0.38, 0.24))


func _add_box(pos: Vector3, size: Vector3, color: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.88
	mat.metallic = 0.02
	var inst := MeshInstance3D.new()
	inst.mesh = mesh
	inst.position = pos
	inst.material_override = mat
	inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	_prop_host.add_child(inst)
