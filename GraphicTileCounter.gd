extends TextureRect

@onready var tile_counter = $TileCounter
@onready var end = $End
@onready var dead_tile_counter = $DeadTileCounter
@onready var dead_tile_end = $DeadTileEnd
@onready var label = $Label

@onready var textures = [preload("res://image/tilecounter/tilecounter_end_odd.png"), preload("res://image/tilecounter/tilecounter_end_even.png"), preload("res://image/tilecounter/tilecounter_end_final.png")]

@export var text_offset = Vector2(11,12)

func update_wall_count(c: int):
	tile_counter.size.y = ((c-1) / 2) * 4
	tile_counter.position.y = 2
	end.position.y = tile_counter.size.y + tile_counter.position.y
	end.texture = textures[(c+1)%2]
	end.visible = c > 0
	if c == 1:
		end.texture = textures[2]
	
	label.text = str(c)
	label.position = end.position + text_offset

func reset_dead_wall_count():
	dead_tile_counter.size.y = 0
	
	dead_tile_end.visible = false
	dead_tile_counter.visible = false

# this rounds to the nearest even atm.
func increment_dead_wall_count(add: int):
	dead_tile_counter.size.y += add/2*4
	
	dead_tile_end.visible = dead_tile_counter.size.y > 0
	dead_tile_counter.visible = dead_tile_end.visible
