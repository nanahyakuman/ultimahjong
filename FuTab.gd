extends VBoxContainer

@onready var mahjong_manager = %MahjongManager
@onready var yakufu = mahjong_manager.get_node("YakuFu")

@export var fu_graphical = preload("res://fu_info_graphical.tscn")

func _ready():
	for c in get_children():
		c.queue_free()
	
	for str in yakufu.FU.keys():
		# headers
		if yakufu.FU[str] is String:
			var a = RichTextLabel.new()
			add_child(a)
			a.bbcode_enabled = true
			a.append_text(tr(yakufu.FU[str]))
			a.fit_content = true
		# fu
		else:
			var a = fu_graphical.instantiate()
			add_child(a)
			a.set_string(tr(yakufu.FU[str].nam), (yakufu.FU[str].fu))
			a.set_upgrade_count(yakufu.FU[str].times_upgraded)
	
	var a = Control.new()
	a.custom_minimum_size.y = 8
	add_child(a)
