extends Node

signal highlight
signal new_dora
signal change_texture

var dora_ids = []

# can be set by options
var pinsou_version = 0:
	set(val):
		pinsou_version = val
		emit_signal("change_texture")
var man_version = 0:
	set(val):
		man_version = val
		emit_signal("change_texture")
var wind_version = 0:
	set(val):
		wind_version = val
		emit_signal("change_texture")


func highlight_matching_tiles(tile: MTile, val: bool):
	emit_signal("highlight", tile.get_id(), tile.get_adj_ids(), val)

func update_dora_ids(ids: Array):
	dora_ids = ids
	emit_signal("new_dora", dora_ids)
