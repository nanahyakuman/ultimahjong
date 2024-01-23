extends Button

func _ready():
	if !FileAccess.file_exists("user://save.cfg"):
		disabled = true

func _pressed():
	CharInfoForwarder.load = true
	get_tree().change_scene_to_packed(load("res://root.tscn"))
