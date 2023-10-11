extends Node

signal highlight
signal new_dora

var dora_ids = []

func highlight_matching_tiles(tile: MTile, val: bool):
	var id = tile.get_id()
	emit_signal("highlight", id, val, false)
	
	for i in tile.get_adj_ids():
		emit_signal("highlight", i, val, true)

func update_dora_ids(ids: Array):
	dora_ids = ids
	emit_signal("new_dora", dora_ids)
