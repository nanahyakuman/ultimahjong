extends TextureRect

@onready var tile_counter = $TileCounter
@onready var end = $End

@onready var textures = [preload("res://image/tilecounter_end_odd.png"), preload("res://image/tilecounter_end_even.png"), preload("res://image/tilecounter_end_final.png")]


func update_wall_count(c: int):
	tile_counter.size.y = ((c-1) / 2) * 4
	end.position.y = tile_counter.size.y + tile_counter.position.y
	end.texture = textures[(c+1)%2]
	if c == 1:
		end.texture = textures[2]
