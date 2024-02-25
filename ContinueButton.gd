extends Button

@export var options_loader: Node

func _ready():
	if !FileAccess.file_exists("user://save.cfg"):
		disabled = true

func _pressed():
	if options_loader:
		options_loader.save_cfg()
	
	CharInfoForwarder.load = true
	get_tree().change_scene_to_packed(load("res://root.tscn"))
