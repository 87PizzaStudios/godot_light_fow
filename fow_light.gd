extends TextureRect
class_name FogOfWar


## The texture to overlay as fog of war
@export var fog_texture : Texture2D
## Fog scroll velocity in units of pixels per second
@export var fog_scroll_velocity:= Vector2(0.1, 0.1)
## Determines whether observed areas stay revealed after moving to a new area
@export var persistent_reveal: bool = true
## The light node in the game scene that will reveal fog of war
@export var light: Light2D
## Name of the group of light occluders
@export var light_occluder_group: String
## Scales down the fow texture for more efficient computation
@export_range(0.05,1.0) var fow_scale_factor := 1.
## Whether to reveal at initial light location
@export var initial_reveal: bool = true

@onready var light_sv = $LightSubViewport
@onready var mask_sv = $MaskSubViewport
@onready var mask = $MaskSubViewport/TextureRect

#var fog_image : Image
var light_dup : Light2D
var mask_image: Image
var mask_texture: Texture2D
var size_vec: Vector2

func _ready():
	var display_width = self.size.x
	var display_height = self.size.y
	size_vec = fow_scale_factor * Vector2(display_width, display_height)
	print(size_vec)
	print(self.size)

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
	light_dup.position *= fow_scale_factor
	light_dup.apply_scale(fow_scale_factor * Vector2(1.,1.))
	light_sv.add_child(light_dup)

	# add copies of the light occluders to the light subviewport
	for occluder in get_tree().get_nodes_in_group(light_occluder_group):
		if occluder is LightOccluder2D:
			var occluder_dup: LightOccluder2D = occluder.duplicate()
			occluder_dup.position *= fow_scale_factor
			occluder_dup.apply_scale(fow_scale_factor * Vector2(1., 1.))
			light_sv.add_child(occluder_dup)

	# set shader params
	mask.material.set_shader_parameter("persistent_reveal", persistent_reveal)
	material.set_shader_parameter("fog_scroll_velocity", fog_scroll_velocity)
	material.set_shader_parameter('fog_texture', fog_texture)
	material.set_shader_parameter('mask_texture', mask_texture)
	if persistent_reveal:
		mask.material.set_shader_parameter('mask_texture', mask_texture)
	
	# reveal at initial light location
	if initial_reveal:
		# workaround for node initialization order (possible engine bug?)
		await get_tree().process_frame
		await get_tree().physics_frame
		on_light_moved(light_dup.position / fow_scale_factor)
		
func _input(event):
	if event.is_action_pressed("screencap"):
		print("Saving diagnostic images...")
		light_sv.get_texture().get_image().save_png('res://cap_light.png')
		mask_sv.get_texture().get_image().save_png('res://cap_mask.png')
		get_viewport().get_texture().get_image().save_png('res://cap_game.png')

func on_light_moved(pos: Vector2):
	light_dup.position = fow_scale_factor * pos
	mask_image = mask_sv.get_texture().get_image()
	mask_texture = ImageTexture.create_from_image(mask_image)
	material.set_shader_parameter('mask_texture', mask_texture)
	if persistent_reveal:
		mask.material.set_shader_parameter('mask_texture', mask_texture)
