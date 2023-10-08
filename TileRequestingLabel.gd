extends RichTextLabel
class_name TileRequestingLabel

@export var flip = false

@onready var graphical_tile_generator = %GraphicalTileGenerator

var prev_width = 0

func _process(delta):
	var w = get_content_width()
	if w != prev_width:
		_request_tiles(w)
		prev_width = w

func _request_tiles(width: int):
	graphical_tile_generator.request_tiles(self, global_position, width, flip, false)
