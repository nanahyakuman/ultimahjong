extends TextureRect

@onready var mahjong_manager = %MahjongManager
@onready var calls = $".."

@export var bitmask: MahjongManager.CALL_BITMASK

func enable(bm: int):
	visible = bm & bitmask
	visible = visible or ((bitmask == MahjongManager.CALL_BITMASK.NONE) and (bm != 0))

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			calls.enable_calls(0)
			mahjong_manager.call_graphic_clicked(bitmask)
