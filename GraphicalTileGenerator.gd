extends Node2D

var tiles = {}

@export var tile_sprite: Texture2D
@export var tile_rear_sprite: Texture2D

func request_tiles(requester: Node, pos: Vector2, width: int, flip: bool, rear: bool):
	var twid = tile_sprite.get_width()
	var count = width / twid
	var range = 0
	var existing_size = 0 
	if tiles.has(requester):
		existing_size = tiles[requester].size()
		range = existing_size
	else:
		tiles[requester] = []
	range = max(range, count)
	
	for i in range:
		# add if not yet extant
		if i >= existing_size:
			var a = Sprite2D.new()
			a.texture = tile_sprite if !rear else tile_rear_sprite
			a.centered = false
			tiles[requester].append(a)
			#a.z_index = -1
			a.y_sort_enabled = true
			add_child(a)
		
		var curr = tiles[requester][i]
		
		curr.position.x = pos.x + (twid * i)
		curr.position.y = pos.y
		curr.flip_v = flip
		if flip:
			curr.position.y -= 16
		
		if i >= count:
			curr.visible = false
