extends Button

@export var options_loader: Node

func _pressed():
	if options_loader:
		options_loader.save_cfg()
	
	get_tree().change_scene_to_packed(load("res://character_select.tscn"))
