extends TabContainer

@onready var tab_container = $TabContainer
@onready var mahjong_manager = %MahjongManager
@onready var ALL_YAKU = mahjong_manager.ALL_YAKU


func _ready():
	var curr_rtl: RichTextLabel = null
	for i in ALL_YAKU.YAKUS.values():
		if i is String:
			if i == "Dora":
				break
			if i.substr(5) == "Open ":
				continue
			
			var a = TabBar.new()
			a.name = i
			add_child(a)
			
			var b = RichTextLabel.new()
			b.set_anchors_preset(Control.PRESET_FULL_RECT)
			a.add_child(b)
			curr_rtl = b
		else:
			assert(i is ScoringInfo.Han)
			
			curr_rtl.append_text("[b]%s[/b]\n%s\n" % [i.nam, i.desc])
