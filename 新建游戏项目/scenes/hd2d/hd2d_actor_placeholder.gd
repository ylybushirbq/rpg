class_name Hd2dActorPlaceholder
extends CharacterBody3D
## 色块占位演员。后续把 Sprite3D 的贴图换成像素立绘即可，不必改战斗逻辑。

const PLACEHOLDER_PIXEL_SIZE: float = 0.04
const ART_HEIGHT_METERS: float = 1.72

@export var body_color: Color = Color(0.3, 0.45, 0.75, 1)
@export var caption: String = ""
var is_running: bool = false
var _has_custom_art: bool = false

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
	if _actor_sprite != null and not _has_custom_art:
		_apply_placeholder_art()


func set_running(value: bool) -> void:
	is_running = value
	if _has_custom_art and _actor_sprite != null:
		_actor_sprite.pixel_size = _art_pixel_size() * (1.08 if is_running else 1.0)
	elif _body != null:
		_body.scale = Vector3(1.15, 0.8, 1.15) if is_running else Vector3.ONE
	if _caption != null:
		_caption.modulate = Color(1.0, 0.82, 0.42) if is_running else Color(0.95, 0.93, 0.88)


func set_art(texture: Texture2D) -> void:
	if texture == null or _actor_sprite == null:
		return
	_has_custom_art = true
	_actor_sprite.texture = texture
	_actor_sprite.pixel_size = _art_pixel_size()
	_actor_sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_actor_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	_actor_sprite.shaded = true
	_actor_sprite.position.y = texture.get_height() * _actor_sprite.pixel_size * 0.5
	if _body != null:
		_body.visible = false
	if _caption != null:
		_caption.position.y = _actor_sprite.position.y * 2.0 + 0.18


func _art_pixel_size() -> float:
	if _actor_sprite == null or _actor_sprite.texture == null:
		return PLACEHOLDER_PIXEL_SIZE
	var height: int = _actor_sprite.texture.get_height()
	if height <= 0:
		return PLACEHOLDER_PIXEL_SIZE
	return ART_HEIGHT_METERS / float(height)


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
