extends Control
class_name FogOfWar

@export var fog_texture : Texture2D
@export var light: Light2D
@export var light_occluders: Node
@export var persistent_reveal: bool = true
@export var fog_scroll_velocity:= Vector2(0.1, 0.1)
@export var game_camera: ZoomingCamera2D

@onready var light_sv := $LightSubViewport
@onready var mask_sv := $MaskSubViewport
@onready var mask := $MaskSubViewport/TextureRect

var fog_light : Light2D
var mask_image: Image
var mask_texture: Texture2D
var local_camera1: Camera2D
var local_camera2: Camera2D
var global_time: float = 0

func _ready():
	# set Viewports to window size
	var display_width = ProjectSettings.get("display/window/size/viewport_width")
	var display_height = ProjectSettings.get("display/window/size/viewport_height")
	var window_size := Vector2(display_width, display_height)
	light_sv.set_size(window_size)
	mask_sv.set_size(window_size)

	# set textures to world size
	var world_size := self.size
	$LightSubViewport/Background.set_size(world_size)
	$MaskSubViewport/TextureRect.set_size(world_size)

	# mask image initialization
	mask_image = Image.create(world_size[0], world_size[1], false, Image.FORMAT_RGBA8)
	mask_image.fill(Color.BLACK)
	mask_texture = ImageTexture.create_from_image(mask_image)

	# add a copy of the light to the light subviewport
	fog_light = light.duplicate()
	for n in fog_light.get_children():
		n.queue_free()
	light_sv.add_child(fog_light)

	# add copies of the light occluders to the light subviewport
	for occluder in light_occluders.get_children():
		if occluder is LightOccluder2D:
			light_sv.add_child(occluder.duplicate())
			
	# copy of camera
	if game_camera:
		game_camera.parameter_update.connect(on_camera_moved)
		local_camera1 = game_camera.duplicate()
		local_camera2 = game_camera.duplicate()
		light_sv.add_child(local_camera1)
		mask_sv.add_child(local_camera2)
		
	# set shader params
	material.set_shader_parameter('fog_texture', fog_texture)
	material.set_shader_parameter('mask_texture', mask_texture)
	material.set_shader_parameter("fog_scroll_velocity", fog_scroll_velocity)
	mask.material.set_shader_parameter("persistent_reveal", persistent_reveal)
	mask.material.set_shader_parameter('mask_texture', mask_texture)
		
func _process(delta):
	global_time += delta
	if global_time > 0.1:
		var new_mask_image: Image = mask_sv.get_texture().get_image()
		var new_mask_blit_dst: Vector2 = get_blit_rect().position
#		print(new_mask_blit_dst)
		
		# This fixes the drift, but I'm not sure why its needed. 
		# once the camera moves, it looks like the displacement in direction of 
		# camera movement in mask_sv is one pixel off. This can be fixed by 
		# adding 1 to the displacement along either axis.
#		new_mask_blit_dst = Vector2(
#				new_mask_blit_dst[0] if new_mask_blit_dst[0]==0 else new_mask_blit_dst[0] + 1,
#				new_mask_blit_dst[1] if new_mask_blit_dst[1]==0 else new_mask_blit_dst[1] + 1
#			)
		
		mask_image.blit_rect(new_mask_image, mask.get_viewport_rect(), new_mask_blit_dst)
#		new_mask_image.save_png('res://test.png')
#		mask_image.save_png('res://test_full.png')
		mask_texture = ImageTexture.create_from_image(mask_image)
		material.set_shader_parameter('mask_texture', mask_texture)
		if persistent_reveal:
			mask.material.set_shader_parameter('mask_texture', mask_texture)

func on_light_moved(pos: Vector2):
	fog_light.position = pos
		
func on_camera_moved(pos: Vector2, zoom: Vector2):
	local_camera1.position = pos
	local_camera1.zoom = zoom
	local_camera2.position = pos
	local_camera2.zoom = zoom
	
func get_blit_rect() -> Rect2:
	var viewportRect: Rect2 = mask.get_viewport_rect()
	var globalToViewportTransform: Transform2D = mask.get_viewport_transform()
	var viewportToGlobalTransform: Transform2D = globalToViewportTransform.affine_inverse()
	var viewportRectGlobal: Rect2 = viewportToGlobalTransform * viewportRect
	return viewportRectGlobal
	
	
