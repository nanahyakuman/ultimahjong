extends Button

@onready var last_round_won_window = $".."

func _on_pressed():
	last_round_won_window.visible = false
