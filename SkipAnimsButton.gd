extends Button

func _ready():
	AnimTimer.skip = button_pressed

func _pressed():
	AnimTimer.skip = button_pressed
	release_focus()

func load_cfg(config: ConfigFile):
	button_pressed = config.get_value("button", name, 1)
	_pressed()
func save_cfg(config: ConfigFile):
	config.set_value("button", name, button_pressed)
