extends Node
class_name Grouping

# set covers both pon and kan
enum {NONE, PAIR, SET, RUN}
const TYPE_STRS = ["NONE","PAIR","SET","RUN"]
var type = NONE
# tiles MUST be sorted!!!
var tiles = []
var open = false

func _init(typ: int, ts: Array):
	type = typ
	tiles = ts.duplicate()
	
#	var tsorted = tiles.duplicate()
#	tsorted.sort()
#	assert(tiles.hash() == tsorted.hash())

func print_self():
	print(TYPE_STRS[type])
	var str = "  "
	for t in tiles:
		str += t.get_name() + " "
	print(str)
