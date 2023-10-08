extends ColorRect
@onready var mahjong_manager = %MahjongManager


var index = 13

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			mahjong_manager.draw_and_discard_index(index)
