extends Button

#@onready var options_loader = $"../../OptionsLoader"

@export var options_loader: Node

func _pressed():
	if options_loader:
		options_loader.save_cfg()
	
	get_tree().quit()
