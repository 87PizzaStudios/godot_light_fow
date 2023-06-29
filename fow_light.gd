extends Control
class_name FogOfWar

@export var fog_texture : Texture2D
@export var light: Light2D
@export var light_occluders: Node
@export var persistent_reveal: bool = true
@export var fog_scroll_velocity:= Vector2(0.1, 0.1)

@onready var light_sv = $LightSubViewport
@onready var mask_sv = $MaskSubViewport
@onready var mask = $MaskSubViewport/TextureRect

#var fog_image : Image
var fog_light : Light2D
var mask_image: Image
var mask_texture: Texture2D

func _ready():
	var display_width = 1080
	var display_height = 720
	var size_vec := Vector2(display_width, display_height)

	# set whether revealed area should be persistent
	mask.material.set_shader_parameter("persistent_reveal", persistent_reveal)

	# set fog scroll velocity
	material.set_shader_parameter("fog_scroll_velocity", fog_scroll_velocity)

	# set Viewports and TextureRects to window size
	light_sv.set_size(size_vec)
	mask_sv.set_size(size_vec)
	$LightSubViewport/Background.set_size(size_vec)
	$MaskSubViewport/TextureRect.set_size(size_vec)

	# mask
	mask_image = Image.create(display_width, display_height, false, Image.FORMAT_RGBA8)
	mask_image.fill(Color.BLACK)
	mask_texture = ImageTexture.create_from_image(mask_image)

	# add a copy of the light to the light subviewport
	fog_light = light.duplicate()
	light_sv.add_child(fog_light)

	# add copies of the light occluders to the light subviewport
	for occluder in light_occluders.get_children():
		if occluder is LightOccluder2D:
			light_sv.add_child(occluder.duplicate())

	# set shader params
	material.set_shader_parameter('fog_texture', fog_texture)
	material.set_shader_parameter('mask_texture', mask_texture)
	if persistent_reveal:
		mask.material.set_shader_parameter('mask_texture', mask_texture)

func on_light_moved(pos: Vector2):
	fog_light.position = pos
	mask_image = mask_sv.get_texture().get_image()
	mask_texture = ImageTexture.create_from_image(mask_image)
	material.set_shader_parameter('mask_texture', mask_texture)
	if persistent_reveal:
		mask.material.set_shader_parameter('mask_texture', mask_texture)
