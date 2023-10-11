extends HBoxContainer

func _ready():
	enable_calls(0, {})

func enable_calls(bitmask: int, tiles_involved: Dictionary):
	for c in get_children():
		c.enable(bitmask, tiles_involved)
