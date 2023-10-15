extends Node

# this MUST remain sorted for the tiles tab to display properly!
var tile_data = []

class MTileData:
	var suit: int
	var value: int
	var count: int
	var aka_count: int
	
	func _init(s: int, v: int, c: int, a :int):
		suit = s
		value = v
		count = c
		aka_count = a

func _ready():
	# should happen start of a run, not this nodes' lifetime start
	initialize_tiles()


# this should support multiple "characters"
func initialize_tiles():
	for i in [MTile.SUITS.MAN, MTile.SUITS.PIN, MTile.SUITS.SOU]:
		for j in 9:
			tile_data.append(MTileData.new(i,j+1,4, 1 if j+1 == 5 else 0))
	
	for i in MTile.def_specials:
		tile_data.append(MTileData.new(MTile.SUITS.SPECIAL, i, 4, 0))


func get_all_tiles():
	var ret = []
	for td in tile_data:
		for t in td.count:
			ret.append(MTile.new(td.suit, td.value, td.aka_count>t))
	return ret

# returns a dict with {id: [count, aka_count]} pairs
#func get_all_counts():
#	var ret = {}
#	for i in tile_data:
#		ret[MTile.gen_id(i.suit, i.value)] = [i.count, i.aka_count]
#	return ret
