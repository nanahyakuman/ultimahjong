extends HBoxContainer


func _ready():
	for c in get_child_count():
		get_child(c).index = c
		
