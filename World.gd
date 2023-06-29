extends Node2D
signal on_light_moved(position: Vector2)


@onready var light = $OtherStuff/Light
@onready var camera = $OtherStuff/Light/Camera2D


func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var pos = get_local_mouse_position()
		light.position = pos
		on_light_moved.emit(pos)
