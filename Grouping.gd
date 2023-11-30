extends Node
class_name Grouping

# set covers both pon and kan, use `tiles.size()` to differentiate.
enum {NONE, PAIR, SET, RUN, SPECIAL}
const TYPE_STRS = ["NONE","PAIR","SET","RUN", "SPECIAL"]
var type = NONE
#  tiles MUST be sorted!!! as a result, a `RUN` with a 2s in `tiles[0]` is implicitly
# a 234s
var tiles = []
# -1 means closed, +0123 means opened on that tile
var open_tile: int = -1

func _init(typ: int, ts: Array):
	type = typ
	tiles = ts.duplicate()

func equivalent(a: Grouping):
	return a.type == type and a.tiles[0].get_id() == tiles[0].get_id()

func print_self():
	print(TYPE_STRS[type])
	var str = "  "
	for t in tiles:
		str += t.get_name() + " "
	print(str)

func is_open() -> bool:
	return open_tile >= 0
