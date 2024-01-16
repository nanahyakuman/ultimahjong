extends Button


func _pressed():
	CharInfoForwarder.load = true
	get_tree().change_scene_to_packed(load("res://root.tscn"))
