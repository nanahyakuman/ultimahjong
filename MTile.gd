class_name MTile

enum SUITS {MAN=1, PIN=2, SOU=4, SPECIAL=8}
# specials are 1-indexed becuase so are the suits
enum SPECIALS {NONE, EAST, SOUTH, WEST, NORTH, HAKU, HATSU, CHUN}

var suit: int
var value: int

var aka: bool = false

func _init(s:int,v:int,a:bool = false):
	suit = s
	value = v
	aka = a

func get_id():
	return MTile.gen_id(suit, value)

#  `chi_sets` returns neighbors and superneighbors in order, to make
# it easy to check for chis.
func get_adj_ids(s = suit, v = value, chi_sets = false):
	if suit == SUITS.SPECIAL:
		return []
	else:
		if !chi_sets:
			return [MTile.gen_id(s, v-1), MTile.gen_id(s, v+1)]
		else:
			return [MTile.gen_id(s, v-2), MTile.gen_id(s, v-1), MTile.gen_id(s, v+1), MTile.gen_id(s, v+2)]

static func gen_id(s: int, v:int):
	return s * 100 + v * 1

static func tile_compare(a:MTile, b:MTile):
	return a.get_id() < b.get_id()
