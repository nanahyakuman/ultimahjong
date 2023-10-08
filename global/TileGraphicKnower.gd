extends Node

signal highlight

func highlight_matching_tiles(tile: MTile, val: bool):
	var id = tile.get_id()
	emit_signal("highlight", id, val, false)
	
#	for i in tile.get_adj_ids():
#		emit_signal("highlight", i, val, true)
