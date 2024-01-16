extends Button


@export var options_loader: Node
@export var main_loader: Node

func _pressed():
	if options_loader:
		options_loader.save_cfg()
	
	if main_loader:
		main_loader.save_cfg()
	
	get_tree().change_scene_to_packed(load("res://main_menu.tscn"))
