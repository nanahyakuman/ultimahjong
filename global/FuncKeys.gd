extends Node

func _ready():
	DisplayServer.window_set_min_size(Vector2i(640,360))

func _process(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		if get_window().mode == Window.MODE_WINDOWED:
			get_window().set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)
		else:
			get_window().set_mode(Window.MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(0,0))
	
	if Input.is_action_just_pressed("set_size"):
		DisplayServer.window_set_size(Vector2i(1920,1080))
	
	if Input.is_action_just_pressed("screenshot"):
		var image = get_viewport().get_texture().get_image()
		image.save_png("G:/video/mahjtut/%d.png" % randi())
