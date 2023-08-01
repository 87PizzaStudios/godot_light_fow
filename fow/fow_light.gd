extends TextureRect
class_name FogOfWar


## The texture to overlay as fog of war
@export var fog_texture : Texture2D
## Fog scroll velocity
@export var fog_scroll_velocity:= Vector2(0.1, 0.1)
## Determines whether observed areas stay revealed after moving to a new area
@export var persistent_reveal: bool = true
## Name of the group of lights that will reveal fog of war
@export var light_group: String
## Name of the group of light occluders
@export var light_occluder_group: String
## Scales down the fow texture for more efficient computation
@export_range(0.05,1.0) var fow_scale_factor := 1.
## Whether to reveal at initial light location
@export var initial_reveal: bool = true

@onready var light_sv = $LightSubViewport
@onready var mask_sv = $MaskSubViewport
@onready var mask = $MaskSubViewport/TextureRect


var mask_image: Image
var mask_texture: Texture2D
var size_vec: Vector2i

# pairs of original and duplicate lights and occluders
var light_dups_dict: Dictionary
var occluder_dups_dict: Dictionary

func _ready():
	var display_width = self.size.x
	var display_height = self.size.y
	size_vec = fow_scale_factor * Vector2(display_width, display_height)


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
	for light in get_tree().get_nodes_in_group(light_group):
		if light is PointLight2D:
			var light_dup: PointLight2D = light.duplicate()
			light_dup.color = Color.WHITE
			light_dup.position = light.global_position * fow_scale_factor
			light_dup.apply_scale(fow_scale_factor * Vector2(1.,1.))
			light_sv.add_child(light_dup)
			light_dups_dict[light.get_instance_id()] = light_dup


	# add copies of the light occluders to the light subviewport
	for occluder in get_tree().get_nodes_in_group(light_occluder_group):
		if occluder is LightOccluder2D:
			var occluder_dup: LightOccluder2D = occluder.duplicate()
			occluder_dup.position *= fow_scale_factor
			occluder_dup.apply_scale(fow_scale_factor * Vector2(1., 1.))
			light_sv.add_child(occluder_dup)
			occluder_dups_dict[occluder.get_instance_id()] = occluder_dup


	# set shader params
	mask.material.set_shader_parameter("persistent_reveal", persistent_reveal)
	material.set_shader_parameter("fog_scroll_velocity", fog_scroll_velocity)
	material.set_shader_parameter('fog_texture', fog_texture)
	material.set_shader_parameter('mask_texture', mask_texture)
	if persistent_reveal:
		mask.material.set_shader_parameter('mask_texture', mask_texture)
	
	# reveal at initial light locations
	if initial_reveal:
		# workaround for node initialization order (possible engine bug?)
		await get_tree().process_frame
		await get_tree().physics_frame
		for light in light_dups_dict:
			on_light_moved(light, instance_from_id(light).global_position)


# takes the instance ID and position of the in-game light to move the duplicate light and update fog
func on_light_moved(light: int, pos: Vector2):
	light_dups_dict[light].position = fow_scale_factor * pos
	mask_image = mask_sv.get_texture().get_image()
	mask_texture = ImageTexture.create_from_image(mask_image)
	material.set_shader_parameter('mask_texture', mask_texture)
	if persistent_reveal:
		mask.material.set_shader_parameter('mask_texture', mask_texture)
