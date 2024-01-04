extends TabContainer

@onready var mahjong_manager = %MahjongManager
@onready var ALL_YAKU = mahjong_manager.ALL_YAKU

@onready var sidebar_yaku = load("res://yaku_info_sidebar.tscn")

# create tabs for all yaku procedurally.
func _ready():
	generate()
	
	LocaleChangedSignaller.connect("locale_changed", generate)
	

func generate():
	for c in get_children():
		c.queue_free()
	
	var curr_tab_box: VBoxContainer = null
	for i in ALL_YAKU.YAKUS.values():
		if i is String:
			if i == "Dora":
				break
			
			var a = TabBar.new()
			a.name = tr(i)
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
			
		elif i is Array:
			var l = RichTextLabel.new()
			l.fit_content = true
			l.bbcode_enabled = true
			curr_tab_box.add_child(l)
			l.append_text(tr(i[0]))
			
		else:
			assert(i is ScoringInfo.Han)
			
			var new_yaku = sidebar_yaku.instantiate()
			curr_tab_box.add_child(new_yaku)
			new_yaku.set_info(i)
