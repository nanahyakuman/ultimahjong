class_name MTile

# this needs to stay a bitmask or a lot of stuff will break!
enum SUITS {NONE=0, MAN=4, PIN=1, SOU=2, SPECIAL=8, FLOWER=16}
# specials are 1-indexed becuase so are the suits
enum SPECIALS {NONE, EAST, SOUTH, WEST, NORTH, UP, HAKU, HATSU, CHUN, KIN}
const DEF_SPECIALS = [SPECIALS.EAST, SPECIALS.SOUTH, SPECIALS.WEST, SPECIALS.NORTH, SPECIALS.HAKU, SPECIALS.HATSU, SPECIALS.CHUN]

# for easy lookup with `has()`
const DRAGONS = [SPECIALS.HAKU, SPECIALS.HATSU, SPECIALS.CHUN, SPECIALS.KIN]
const WINDS = [SPECIALS.EAST, SPECIALS.SOUTH, SPECIALS.WEST, SPECIALS.NORTH]

# to generate human readable name
const SUIT_NAMES = ["NONE", "-Pin", "-Sou", 0, "-Man",0,0,0,0,0,0,0,0,0,0,0,"-Flower"]
const SPECIAL_NAMES = ["NONE", "East", "South", "West", "North", "Rising", "White", "Green", "Red", "Gold"]

var suit: int
var value: int

var aka: bool = false

#  im not entirely sure how i want this to work yet, but i def at least
# want a shiropochhi, and i can see use cases for generalizing it.
var pocchi: bool = false

#  allows us to track tiles that have been modified so we can still
# count them
var former: MTile = null

#  allow tiles in round use to point back to their canon originator in
# `TileCounter` so that permanent mods are easier to make
var canon_tile: MTile = null

func _init(s:int, v:int, a:bool = false, f = null, p = false, c = null):
	suit = s
	value = v
	aka = a
	former = f
	pocchi = p
	canon_tile = c

# duplicate and save self as new tile's "canon" tile
func duplicate_canonize() -> MTile:
	return MTile.new(suit, value, aka, former, pocchi, self)

# just duplicate
func duplicate() -> MTile:
	return MTile.new(suit, value, aka, former, pocchi, canon_tile)

func get_id():
	return MTile.gen_id(suit, value)

func get_name():
	return MTile.gen_name(self)

#  `chi_sets` returns neighbors and superneighbors in order, to make
# it easy to check for chis.
func get_adj_ids(s = suit, v = value, chi_sets = false):
	if suit == SUITS.SPECIAL or suit == SUITS.FLOWER:
		return []
	else:
		if !chi_sets:
			return [MTile.gen_id(s, v-1), MTile.gen_id(s, v+1)]
		else:
			return [MTile.gen_id(s, v-2), MTile.gen_id(s, v-1), MTile.gen_id(s, v+1), MTile.gen_id(s, v+2)]

func get_dora_id():
	var val = []
	if suit == SUITS.SPECIAL:
		match value:
			SPECIALS.EAST:
				val.append(SPECIALS.SOUTH)
			SPECIALS.SOUTH:
				val.append(SPECIALS.WEST)
			SPECIALS.WEST:
				val.append(SPECIALS.NORTH)
			SPECIALS.NORTH:
				val.append(SPECIALS.EAST)
			SPECIALS.HAKU:
				val.append(SPECIALS.HATSU)
			SPECIALS.HATSU:
				val.append(SPECIALS.CHUN)
			SPECIALS.CHUN:
				val.append(SPECIALS.HAKU)
			SPECIALS.KIN:
				val += [SPECIALS.HAKU, SPECIALS.HATSU, SPECIALS.CHUN]
			SPECIALS.UP:
				val += [SPECIALS.UP]
	elif suit == SUITS.FLOWER:
		pass
	else:
		val.append((((value + 1) - 1) % 9) + 1)
	
	var ret = []
	for v in val:
		ret.append(MTile.gen_id(suit, v))
	return ret

# does not care about aka
static func gen_id(s: int, v: int):
	return s * 100 + v * 1

static func tile_from_id(id: int) -> MTile:
	return MTile.new(int(id/100), id%100)

# ordered so that aka are always first
static func gen_order(t: MTile):
	return gen_id(t.suit,t.value) * 10 - int(t.aka)

static func tile_compare(a:MTile, b:MTile):
	return gen_order(a) < gen_order(b)

static func gen_name(tile: MTile):
	if tile.suit == SUITS.SPECIAL:
		return SPECIAL_NAMES[tile.value]
	else:
		return str(tile.value) + SUIT_NAMES[tile.suit]
