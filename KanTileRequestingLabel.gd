extends TileRequestingLabel

# `flip` is ignored btw

@export var MAX_KANS = 5
@onready var kan_label_2 = $"../KanLabel2"

func _request_tiles(width: int):
	graphical_tile_generator.request_tiles(self, global_position, width, false, false)
	if width/8 < MAX_KANS:
	# the other label is the register for rear-facing tiles. dumb but functional
		graphical_tile_generator.request_tiles(kan_label_2, global_position+Vector2(width,0), MAX_KANS*16 - width, false, true)
