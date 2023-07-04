extends Node2D
signal on_light_moved(light_id: int, position: Vector2)


@onready var light = $OtherStuff/Light

func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var pos = get_local_mouse_position()
		light.position = pos
		on_light_moved.emit(light.get_instance_id(), pos)
