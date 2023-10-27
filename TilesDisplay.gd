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
	
	var suits = [MTile.SUITS.MAN, MTile.SUITS.PIN, MTile.SUITS.SOU, MTile.SUITS.SPECIAL]
	
	var strs = ["","","",""]
	
	for i in counts:
		strs[suits.find(i.suit)] += "%s+%s " % [i.count-i.aka_count, i.aka_count]
	
	for i in strs.size():
		menu_counts[i].text = strs[i]
