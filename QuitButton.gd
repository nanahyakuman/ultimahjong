extends Button

# not an array because exporting arrays sucks
@export var options_loader: Node
@export var main_loader: Node

func _pressed():
	if options_loader:
		options_loader.save_cfg()
	
	if main_loader:
		main_loader.save_cfg()
	
	get_tree().quit()
