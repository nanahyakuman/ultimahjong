extends GridContainer

@onready var tile_graphic = preload("res://TileGraphic.tscn")

func generate(preview_tile_strings: Array):
	for c in get_children():
		c.queue_free()
	
	for ts in preview_tile_strings:
		var tiles = MTileStringConverter.str_to_mtile(ts)
		for t in tiles:
			var a = tile_graphic.instantiate()
			add_child(a)
			a.assign_tile(t)
