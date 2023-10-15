extends Node
class_name Grouping

# set covers both pon and kan
enum {NONE, PAIR, SET, RUN}
var type = NONE
var tiles = []

func _init(typ: int, ts: Array):
	type = typ
	tiles = ts.duplicate()
