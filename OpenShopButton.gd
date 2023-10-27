extends Button
@onready var root = $"../../../.."

func _on_pressed():
	root.start_shop()
