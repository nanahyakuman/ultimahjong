extends VBoxContainer

@onready var menu_counts = [$RichTextLabel2, $RichTextLabel4, $RichTextLabel6, $RichTextLabel8]

@onready var mahjong_manager = %MahjongManager
@onready var tile_counter = mahjong_manager.get_node("TileCounter")


func _ready():
	tile_counter.connect("updated", update_display)
	
	#update_display()

# `tile_data` must be sorted
func update_display():
	var counts = tile_counter.tile_data
	
	var suits = [MTile.SUITS.PIN, MTile.SUITS.SOU, MTile.SUITS.MAN, MTile.SUITS.SPECIAL]
	
	var strs = ["","","",""]
	
	for i in counts:
		var find = suits.find(i.suit)
		if find == -1:
			continue
		strs[find] += "%s+%s " % [i.count-i.aka_count, i.aka_count]
	
	for i in strs.size():
		menu_counts[i].text = strs[i]
