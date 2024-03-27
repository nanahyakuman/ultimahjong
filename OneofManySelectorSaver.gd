class_name OneOfManySelectorSaver
extends Node

func load_cfg(config: ConfigFile):
	var val = config.get_value("selector", name, "en")
	for c in get_children():
		# force update to new standard
		if typeof(c.val) != typeof(val):
			c.button_pressed = true
			c._pressed()
			break
		elif c.val == val:
			c.button_pressed = true
			# have to forcibly call this here, uggy i know
			c._pressed()
			break

func save_cfg(config: ConfigFile):
	for c in get_children():
		if c.button_pressed:
			config.set_value("selector", name, c.val)
			break
