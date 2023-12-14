extends Control
@onready var label = $Label

@export var offset = Vector2(12,-1)

func _ready():
	Input.set_custom_mouse_cursor(load("res://image/cursor/cursor.png"))
	Input.set_custom_mouse_cursor(load("res://image/cursor/handcursor.png"), Input.CURSOR_POINTING_HAND)
	set_text("")

func _process(delta):
	position = get_window().get_mouse_position() + offset

func set_text(str: String):
	visible = str.length() != 0
	label.text = str
	size = Vector2i(0,0)
	
