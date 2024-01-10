extends HSlider

@export var bus_name = "Master"

@onready var bus_id = AudioServer.get_bus_index(bus_name)


#func _ready():
#	value = db_to_linear(AudioServer.get_bus_volume_db(bus_id))
#	connect("drag_ended", drag_ended)

# name based save/load funcs, called by the options loader
func load_cfg(config: ConfigFile):
	value = config.get_value("volume", name, 1)
func save_cfg(config: ConfigFile):
	config.set_value("volume", name, value)



func _value_changed(new_value):
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(new_value))

func drag_ended(val):
	release_focus()
