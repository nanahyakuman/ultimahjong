extends Button


func _pressed():
	OS.shell_open("https://store.steampowered.com/app/2861660/ULTIMAHJONG/")
	button_pressed = false
	release_focus()
