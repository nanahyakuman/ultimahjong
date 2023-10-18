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

signal updated

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

#  returns `reshuffle_every` amount of groups of non-aka tiles, groups being
# of size `amount_in_group`. looks a little weird but this implementation ensures
# that individual groups will always have 3 unique tiles, but that different groups
# can select the same suit-value pair up to as many times as it can be akafyed.
func get_random_non_aka_ids(amount_in_group: int, group_by: int):
	var ret = []
	
	var data_clone = tile_data.duplicate()
	
	for i in group_by:
		data_clone.shuffle()
		var counter = amount_in_group
		var subret = []
		for mtd in data_clone:
			if counter <= 0:
				break
			
			var theoretical_akas = mtd.aka_count
			for t in subret:
				if t.get_id() == MTile.gen_id(mtd.suit,mtd.value):
					theoretical_akas += 1
			if theoretical_akas >= mtd.count:
				continue
			
			subret.append(MTile.new(mtd.suit,mtd.value))
			counter -= 1
		
		subret.sort_custom(Callable(MTile, "tile_compare"))
		ret.append(subret)
	
	
	return ret

func increment_aka(tile: MTile):
	for mtd in tile_data:
		if mtd.suit == tile.suit and mtd.value == tile.value:
			mtd.aka_count += 1
			break
	
	emit_signal("updated")
