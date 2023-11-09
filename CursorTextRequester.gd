extends Control
class_name CursorTextRequester

@export var hover_text = ""

func _ready():
	connect("mouse_entered", _mouse_entered)
	connect("mouse_exited", _mouse_exited)

func _mouse_entered():
	CursorText.set_text(hover_text)
func _mouse_exited():
	CursorText.set_text("")
