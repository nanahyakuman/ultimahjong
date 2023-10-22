extends Sprite2D

func _ready():
	Input.set_custom_mouse_cursor(load("res://image/cursor.png"))

#func _process(delta):
#	Input.warp_mouse(get_window().get_mouse_position().snapped(Vector2(1.0,1.0))*4.0)
