extends Node

var tile_data = []

class MTileData:
	var suit: int
	var value: int
	var count: int
	
	func _init(s: int, v: int, c: int):
		suit = s
		value = v
		count = c

func _ready():
	# should happen start of a run, not this nodes' lifetime start
	initialize_tiles()


# this should support multiple "characters"
func initialize_tiles():
	for i in [MTile.SUITS.MAN, MTile.SUITS.PIN, MTile.SUITS.SOU]:
		for j in 9:
			tile_data.append(MTileData.new(i,j+1,4))
	
	for i in MTile.SPECIALS.size()-1:
		tile_data.append(MTileData.new(MTile.SUITS.SPECIAL, i, 4))


func get_all_tiles():
	var ret = []
	for t in tile_data:
		var block = []
		block.resize(t.count)
		block.fill(MTile.new(t.suit, t.value))
		ret.append_array(block)
	return ret
