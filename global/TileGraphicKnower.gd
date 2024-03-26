extends Node

signal highlight
signal new_dora
signal change_texture

var dora_ids = []

var tile_version = 0
@onready var tilesets =[
	preload("res://image/tile/tiles.png"),
	preload("res://image/tile/tile_numerals.png")
]

func highlight_matching_tiles(tile: MTile, val: bool):
	emit_signal("highlight", tile.get_id(), tile.get_adj_ids(), val)

func update_dora_ids(ids: Array):
	dora_ids = ids
	emit_signal("new_dora", dora_ids)

func new_texture(_tileversion: int):
	tile_version = _tileversion
	emit_signal("change_texture", tilesets[tile_version])
