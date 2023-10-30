extends Control

@export var hover_text = ""
@onready var cursor_text = %CursorText

func _ready():
	connect("mouse_entered", _mouse_entered)
	connect("mouse_exited", _mouse_exited)

func _mouse_entered():
	cursor_text.set_text(hover_text)
func _mouse_exited():
	cursor_text.set_text("")
