extends TextureRect

@onready var dead_tile_counter = $DeadTileCounter
@onready var dead_tile_kan_counter = $DeadTileKanCounter
@onready var dead_end = $DeadEnd
@onready var tile_counter = $TileCounter
@onready var end = $End
@onready var end_sprite = $End/EndSprite2D
@onready var label = $Label


@export var text_offset = Vector2(11,12)

func update_wall_count(c: int, dead_wall_size: int, kan_count: int):
	# do a min here to animate in the wall
	dead_tile_counter.size.y = ((min(c,dead_wall_size-kan_count*2)) / 2) * 4
	tile_counter.position.y = 2
	
	dead_tile_kan_counter.position.y = dead_tile_counter.position.y + dead_tile_counter.size.y
	dead_tile_kan_counter.size.y = ((min(c-dead_wall_size,kan_count*2)) / 2) * 4
	
	
	dead_end.position.y = dead_tile_kan_counter.position.y + dead_tile_kan_counter.size.y
	#dead_end.visible = min(c,dead_wall_size) > 0
	
	tile_counter.size.y = ((c-dead_wall_size-1) / 2) * 4
	tile_counter.position.y = dead_end.position.y #+ dead_end.size.y
	
	end.position.y = tile_counter.size.y + tile_counter.position.y
	end_sprite.frame = c%2
	end.visible = c-dead_wall_size > 0
	if c-dead_wall_size == 1:
		end_sprite.frame = 2
	
	label.text = str(c - dead_wall_size)
	label.position = end.position + text_offset
