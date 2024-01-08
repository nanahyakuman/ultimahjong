extends Button

func _ready():
	AnimTimer.skip = button_pressed

func _pressed():
	AnimTimer.skip = button_pressed
	release_focus()
