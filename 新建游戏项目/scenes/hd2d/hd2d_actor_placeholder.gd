class_name Hd2dActorPlaceholder
extends Node3D
## 色块占位演员。后续把 Sprite3D 的贴图换成像素立绘即可，不必改战斗逻辑。

@export var body_color: Color = Color(0.3, 0.45, 0.75, 1)
@export var caption: String = ""

@onready var _actor_sprite: Sprite3D = %ActorSprite
@onready var _body: MeshInstance3D = %BodyPlaceholder
@onready var _caption: Label3D = %Caption


func _ready() -> void:
	_apply_placeholder_art()
	if caption != "":
		_caption.text = caption


func set_caption(text: String) -> void:
	caption = text
	if _caption != null:
		_caption.text = text


func set_body_color(color: Color) -> void:
	body_color = color
	if _actor_sprite != null:
		_apply_placeholder_art()


func set_art(texture: Texture2D) -> void:
	_actor_sprite.texture = texture
	_body.visible = false


func _apply_placeholder_art() -> void:
	var image := Image.create(32, 48, false, Image.FORMAT_RGBA8)
	image.fill(body_color)
	var shade := body_color.darkened(0.35)
	for y: int in range(40, 48):
		for x: int in 32:
			image.set_pixel(x, y, shade)
	_actor_sprite.texture = ImageTexture.create_from_image(image)
	_body.visible = true
	var mat := _body.material_override as StandardMaterial3D
	if mat == null:
		mat = StandardMaterial3D.new()
		_body.material_override = mat
	mat.albedo_color = body_color.darkened(0.15)
	mat.roughness = 0.82
	mat.metallic = 0.0
