extends HSlider

@export var bus_name = "Master"

@onready var bus_id = AudioServer.get_bus_index(bus_name)


func _ready():
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_id))
	connect("drag_ended", drag_ended)

func _value_changed(new_value):
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(new_value))

func drag_ended(val):
	release_focus()
