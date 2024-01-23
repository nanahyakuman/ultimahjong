extends Button

#  not an array because exporting arrays sucks.
#  the main menu scene intentionally doesnt define these bc it'd overwrite
# the options save if it did. this means youll have to rechange the language if
# you start the game, change it, and then quit, but that's the only option
# on the title screen.
@export var options_loader: Node
@export var main_loader: Node

func _pressed():
	if options_loader:
		options_loader.save_cfg()
	
	if main_loader:
		main_loader.save_cfg()
	
	get_tree().quit()
