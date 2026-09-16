class_name Hd2dWorld
extends Node3D
## HD-2D 舞台：地图贴图 + 斜视镜头。演员仍用色块占位。

const ACTOR_SCENE := preload("res://scenes/hd2d/hd2d_actor_placeholder.tscn")
const GROUND_TEXTURE := preload("res://assets/map/ground.png")
const HUB_FRONT_TEXTURE := preload("res://assets/map/hub_front.png")
const HUB_SIDE_TEXTURE := preload("res://assets/map/hub_side.png")
const HUB_TOP_TEXTURE_PATH := "res://assets/map/hub_top.png"
const TREE_TEXTURE := preload("res://assets/map/dead_tree.png")
const ROCK_TEXTURE := preload("res://assets/map/ash_rocks.png")
const HERO_TEXTURE_PATH := "res://assets/characters/hero.png"
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
@onready var _floor: MeshInstance3D = %Floor

var _player_actor: Hd2dActorPlaceholder
var _enemy_actor: Hd2dActorPlaceholder
var _hub_actor: Hd2dActorPlaceholder
var _exploration_actor: Hd2dActorPlaceholder


func _ready() -> void:
	_apply_ground_art()
	_build_map_props()
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
	_apply_hero_art(_player_actor)
	_enemy_actor = _spawn_actor(_enemy_slot, ENEMY_COLOR, enemy_name)
	_apply_stage()


func setup_hub(hero_name: String) -> void:
	stage_id = &"hub"
	_clear_actors()
	_hub_actor = _spawn_actor(_hub_slot, HERO_COLOR, hero_name)
	_apply_hero_art(_hub_actor)
	_apply_stage()


func setup_exploration(hero_name: String, start_position: Vector3) -> Hd2dActorPlaceholder:
	stage_id = &"exploration"
	_clear_actors()
	_exploration_actor = ACTOR_SCENE.instantiate() as Hd2dActorPlaceholder
	add_child(_exploration_actor)
	_exploration_actor.position = start_position
	_exploration_actor.set_body_color(HERO_COLOR)
	_exploration_actor.set_caption(hero_name)
	_apply_hero_art(_exploration_actor)
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


func _apply_hero_art(actor: Hd2dActorPlaceholder) -> void:
	var texture := load(HERO_TEXTURE_PATH) as Texture2D
	if texture == null:
		push_warning("缺少主角贴图 %s" % HERO_TEXTURE_PATH)
		return
	actor.set_art(texture)


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


func _apply_ground_art() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = GROUND_TEXTURE
	mat.roughness = 0.92
	mat.metallic = 0.0
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_floor.set_surface_override_material(0, mat)


func _build_map_props() -> void:
	for child: Node in _prop_host.get_children():
		child.queue_free()
	_add_hub_building(GameState.HUB_WORLD_POSITION)
	_add_billboard(TREE_TEXTURE, Vector3(7.2, 0.0, -6.4), 0.0045, Vector3(0.8, 2.2, 0.8))
	_add_billboard(TREE_TEXTURE, Vector3(-8.6, 0.0, 3.8), 0.0041, Vector3(0.72, 2.0, 0.72))
	_add_billboard(TREE_TEXTURE, Vector3(4.8, 0.0, 7.1), 0.0038, Vector3(0.68, 1.8, 0.68))
	_add_billboard(ROCK_TEXTURE, Vector3(8.4, 0.0, 2.2), 0.0028, Vector3(1.1, 1.25, 0.9))
	_add_billboard(ROCK_TEXTURE, Vector3(-2.6, 0.0, 7.4), 0.0025, Vector3(0.92, 1.05, 0.8))
	_add_billboard(ROCK_TEXTURE, Vector3(-9.0, 0.0, -2.4), 0.0024, Vector3(0.86, 0.98, 0.76))


func _add_hub_building(pos: Vector3) -> void:
	var building := Node3D.new()
	building.position = pos
	_prop_host.add_child(building)
	_add_box_mesh(building, Vector3(3.25, 2.1, 2.55), Vector3(0.0, 1.05, 0.0))
	_add_facade(building, HUB_FRONT_TEXTURE, Vector3(0.0, 1.52, 1.3), 0.0074, 0.0)
	_add_facade(building, HUB_SIDE_TEXTURE, Vector3(-1.66, 1.52, 0.0), 0.0074, -PI * 0.5)
	var top_texture := load(HUB_TOP_TEXTURE_PATH) as Texture2D
	assert(top_texture != null, "缺少据点顶视图贴图")
	_add_roof(building, top_texture, Vector3(0.0, 2.13, 0.0), Vector2(3.35, 2.65))
	_add_collision_box(building, Vector3(3.1, 2.0, 2.35), Vector3(0.0, 1.0, 0.0))


func _add_box_mesh(parent: Node3D, size: Vector3, pos: Vector3) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.17, 0.13, 0.1)
	material.roughness = 0.94
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)


func _add_facade(
		parent: Node3D,
		texture: Texture2D,
		pos: Vector3,
		pixel_size: float,
		yaw: float,
) -> void:
	var sprite := Sprite3D.new()
	sprite.texture = texture
	sprite.pixel_size = pixel_size
	sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	sprite.shaded = true
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	sprite.double_sided = false
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sprite.position = Vector3(pos.x, texture.get_height() * pixel_size * 0.5, pos.z)
	sprite.rotation.y = yaw
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(sprite)


func _add_roof(parent: Node3D, texture: Texture2D, pos: Vector3, size: Vector2) -> void:
	var mesh := QuadMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.roughness = 0.9
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.rotation.x = -PI * 0.5
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)


func _add_billboard(
		texture: Texture2D,
		ground_position: Vector3,
		pixel_size: float,
		collision_size: Vector3,
) -> void:
	var sprite := Sprite3D.new()
	sprite.texture = texture
	sprite.pixel_size = pixel_size
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sprite.shaded = true
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	sprite.double_sided = false
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sprite.position = ground_position + Vector3.UP * (texture.get_height() * pixel_size * 0.5)
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	_prop_host.add_child(sprite)
	_add_collision_box(_prop_host, collision_size, Vector3(
			ground_position.x,
			collision_size.y * 0.5,
			ground_position.z,
	))


func _add_collision_box(parent: Node3D, size: Vector3, pos: Vector3) -> void:
	var body := StaticBody3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	var collider := CollisionShape3D.new()
	collider.shape = shape
	collider.position = pos
	body.add_child(collider)
	parent.add_child(body)
