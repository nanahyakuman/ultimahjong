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
	
	for i in MTile.DEF_SPECIALS:
		tile_data.append(MTileData.new(MTile.SUITS.SPECIAL, i, 4, 0))
	
	for i in 8:
		tile_data.append(MTileData.new(MTile.SUITS.FLOWER, i+1, 1, 0))


func get_all_tiles(only_unique = false):
	var ret = []
	for td in tile_data:
		for t in td.count if !only_unique else 1:
			ret.append(MTile.new(td.suit, td.value, td.aka_count>t))
	return ret

#  returns `reshuffle_every` amount of groups of non-aka tiles, groups being
# of size `amount_in_group`. looks a little weird but this implementation ensures
# that individual groups will always have 3 unique tiles, but that different groups
# can select the same suit-value pair up to as many times as it can be akafyed.
func get_random_non_aka_ids(amount_in_group: int, groups: int):
	var ret = []
	
	var data_clone = tile_data.duplicate()
	
	for i in groups:
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
			if mtd.suit == MTile.SUITS.FLOWER:
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
	
	#  right now we emit this 1 time for every single tile purchased in the shop.
	# if this causes slowdown just queue updates instead
	emit_signal("updated")

const TILE_SAME_SUIT_CHANCE = .4
const TILE_ADJ_VALUE_CHANCE = .3

func get_random_tiles_to_add(amount_in_group: int, groups: int):
	var ret = []
	
	for g in groups:
		var subret = []
		
		var curr = _get_random_tile()
		subret.append(curr)
		for i in range(1, amount_in_group):
			# weight to generate adjacent tiles
			var suit_ovr = -1
			var val_ovr = -1
			#  dont gen adjacents for specials. half becuase itd break
			# (getadj doesnt work on specials) and half because its op.
			if curr.suit != MTile.SUITS.SPECIAL:
				if randf() < TILE_SAME_SUIT_CHANCE:
					suit_ovr = curr.suit
					if randf() < TILE_ADJ_VALUE_CHANCE:
						val_ovr = MTile.tile_from_id(curr.get_adj_ids().pick_random()).value
			
			curr = _get_random_tile(suit_ovr, val_ovr)
			subret.append(curr)
		
		subret.sort_custom(Callable(MTile, "tile_compare"))
		ret.append(subret)
	
	return ret

func _get_random_tile(suit_override: int = -1, val_override: int = -1) -> MTile:
	var suit = suit_override
	var value = val_override
	if suit == -1:
		suit = [MTile.SUITS.PIN, MTile.SUITS.SOU, MTile.SUITS.MAN, MTile.SUITS.SPECIAL].pick_random()
	
	if value == -1:
		value = (randi() % 9) + 1
		if suit == MTile.SUITS.SPECIAL:
			value = MTile.DEF_SPECIALS.pick_random()
	return MTile.new(suit, value)

func increment_tile(tile: MTile):
	for mtd in tile_data:
		if mtd.suit == tile.suit and mtd.value == tile.value:
			mtd.count += 1
			break
	
	emit_signal("updated")
