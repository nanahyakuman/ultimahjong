class_name MTile

enum SUITS {MAN=1, SOU=4, PIN=2, SPECIAL=8}
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
	return gen_id(suit, value)

func get_adj_ids():
	if suit == SUITS.SPECIAL:
		return []
	else:
		return [gen_id(suit, value-1), gen_id(suit, value+1)]

static func gen_id(s: int, v:int):
	return s * 100 + v * 1

static func tile_compare(a:MTile, b:MTile):
	return a.get_id() < b.get_id()
