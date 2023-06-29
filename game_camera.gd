class_name ZoomingCamera2D
extends Camera2D
signal parameter_update(pos: Vector2, zoom: Vector2)

@export var min_zoom := 0.5
@export var max_zoom := 1.0
@export var zoom_step := 0.1
@export var tween_duration := 0.2
var zoom_scale := 1.0
var start_zoom := Vector2(1.0, 1.0)

func _process(_delta):
	self.get_global_transform()
	parameter_update.emit(self.get_screen_center_position(), zoom)

func _input(event):
	if event.is_action_pressed("zoom_in"):
		zoom_event(zoom_step)
	elif event.is_action_pressed("zoom_out"):
		zoom_event(-zoom_step)

func zoom_event(step):
	zoom_scale = clamp(zoom_scale + step, min_zoom, max_zoom)
	zoom = zoom_scale * start_zoom
