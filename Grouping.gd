extends Node
class_name Grouping

enum {NONE, PAIR, SET, RUN}
var type = NONE
var tiles = []

func _init(typ: int, ts: Array):
	type = typ
	tiles = ts
