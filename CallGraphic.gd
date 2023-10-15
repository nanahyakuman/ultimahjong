extends TextureRect

@onready var mahjong_manager = %MahjongManager
@onready var calls = $".."
@onready var hand = $"../../All/SideSpacers/Tiles/HBoxContainer/Hand"

@export var bitmask: MahjongManager.CALL_BITMASK
var _tiles_involved = []

func _ready():
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)

func enable(bm: int, tiles_involved: Dictionary):
	visible = bm & bitmask
	visible = visible or ((bitmask == MahjongManager.CALL_BITMASK.NONE) and (bm != 0))
	
	if tiles_involved.has(bitmask):
		_tiles_involved = tiles_involved[bitmask]
	else:
		_tiles_involved = []

func _gui_input(event):
	# clicking
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_mouse_exited()
			mahjong_manager.call_graphic_clicked(bitmask,_tiles_involved)
			calls.enable_calls(0, {})


# tells the hand to tell relevant tiles to highlight themselves
func _on_mouse_entered():
	hand.highlight_relevant_tiles(_tiles_involved, true)
func _on_mouse_exited():
	hand.highlight_relevant_tiles([], false)
