extends TabContainer

@onready var tab_container = $TabContainer
@onready var mahjong_manager = %MahjongManager
@onready var ALL_YAKU = mahjong_manager.ALL_YAKU

# create tabs for all yaku procedurally.
func _ready():
	var curr_tab_box: VBoxContainer = null
	for i in ALL_YAKU.YAKUS.values():
		if i is String:
			if i == "Dora":
				break
			
			var a = TabBar.new()
			a.name = i
			add_child(a)
			
			var b = ScrollContainer.new()
			b.set_anchors_preset(Control.PRESET_FULL_RECT)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			a.add_child(b)
			
			var c = VBoxContainer.new()
			c.set_anchors_preset(Control.PRESET_FULL_RECT)
			c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.add_child(c)
			curr_tab_box = c
		else:
			assert(i is ScoringInfo.Han)
			
			var new_yaku = load("res://yaku_info_sidebar.tscn").instantiate()
			curr_tab_box.add_child(new_yaku)
			new_yaku.set_info(i)
