class_name Hd2dUnderlay
extends SubViewportContainer
## 给纯 UI 场景垫一层 HD-2D 色块舞台。鼠标穿透，不挡按钮。

const WORLD_SCENE := preload("res://scenes/hd2d/hd2d_world.tscn")

@export var stage_id: StringName = &"hub"
@export var allow_free_camera: bool = false

var _world: Hd2dWorld


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	stretch = true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var viewport := SubViewport.new()
	viewport.own_world_3d = true
	viewport.transparent_bg = false
	viewport.handle_input_locally = allow_free_camera
	viewport.msaa_3d = Viewport.MSAA_2X
	viewport.size = Vector2i(1280, 720)
	add_child(viewport)
	_world = WORLD_SCENE.instantiate() as Hd2dWorld
	_world.stage_id = stage_id
	_world.allow_free_camera = allow_free_camera
	viewport.add_child(_world)


func world() -> Hd2dWorld:
	return _world
