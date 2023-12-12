extends HBoxContainer

@onready var mahjong_manager = %MahjongManager
@onready var hand = $"../All/SideSpacers/Tiles/HBoxContainer/Hand"
@onready var call_scene = preload("res://call.tscn")
@onready var call_ignore_scene = preload("res://call_ignore.tscn")
func _ready():
	for i in MahjongManager.CALL_BITMASK.values():
		if i == MahjongManager.CALL_BITMASK.NONE:
			continue
		var a = call_scene.instantiate()
		a.bitmask = i
		a.assign_nodes(mahjong_manager, self, hand)
		add_child(a)
	
	var a = call_ignore_scene.instantiate()
	a.bitmask = MahjongManager.CALL_BITMASK.NONE
	a.assign_nodes(mahjong_manager, self, hand)
	add_child(a)
	
	enable_calls(0, {})

func enable_calls(bitmask: int, tiles_involved: Dictionary):
	for c in get_children():
		c.enable(bitmask, tiles_involved)
