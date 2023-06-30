extends Control
class_name FogOfWar


## The texture to overlay as fog of war
@export var fog_texture : Texture2D
## Fog scroll velocity in units of pixels per second
@export var fog_scroll_velocity:= Vector2(0.1, 0.1)
## Determines whether observed areas stay revealed after moving to a new area
@export var persistent_reveal: bool = true
## The light node in the game scene that will reveal fog of war
@export var light: Light2D
## Occluders in the game scene
@export var light_occluders: Node
## Scales down the fow texture for more efficient computation
@export_range(0.05,1.0) var fow_scale_factor := 1.

@onready var light_sv = $LightSubViewport
@onready var mask_sv = $MaskSubViewport
@onready var mask = $MaskSubViewport/TextureRect

#var fog_image : Image
var light_dup : Light2D
var mask_image: Image
var mask_texture: Texture2D

func _ready():
	var display_width = self.size.x
	var display_height = self.size.y
	var size_vec := fow_scale_factor * Vector2(display_width, display_height)

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
	light_dup = light.duplicate()
	#light_dup.position *= fow_scale_factor
	light_dup.apply_scale(fow_scale_factor * Vector2(1.,1.))
	light_sv.add_child(light_dup)

	# add copies of the light occluders to the light subviewport
	for occluder in light_occluders.get_children():
		if occluder is LightOccluder2D:
			var occluder_dup:= occluder.duplicate()
			occluder_dup.apply_scale(fow_scale_factor * Vector2(1., 1.))
			light_sv.add_child(occluder_dup)

	# set shader params
	mask.material.set_shader_parameter("persistent_reveal", persistent_reveal)
	material.set_shader_parameter("fog_scroll_velocity", fog_scroll_velocity)
	material.set_shader_parameter('fog_texture', fog_texture)
	material.set_shader_parameter('mask_texture', mask_texture)
	if persistent_reveal:
		mask.material.set_shader_parameter('mask_texture', mask_texture)

func on_light_moved(pos: Vector2):
	light_dup.position = fow_scale_factor * pos
	mask_image = mask_sv.get_texture().get_image()
	mask_texture = ImageTexture.create_from_image(mask_image)
	material.set_shader_parameter('mask_texture', mask_texture)
	if persistent_reveal:
		mask.material.set_shader_parameter('mask_texture', mask_texture)
