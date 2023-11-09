extends Node

signal highlight
signal new_dora

var dora_ids = []

func highlight_matching_tiles(tile: MTile, val: bool):
	emit_signal("highlight", tile.get_id(), tile.get_adj_ids(), val)

func update_dora_ids(ids: Array):
	dora_ids = ids
	emit_signal("new_dora", dora_ids)
