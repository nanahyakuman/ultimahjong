extends Button

@onready var options_loader = $"../../OptionsLoader"

func _on_pressed():
	options_loader.save_cfg()
	get_tree().quit()
