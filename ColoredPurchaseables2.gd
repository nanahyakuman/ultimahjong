##  pretty hacky overall but functional
extends PurchaseablesHolder

@onready var root = $"../../../../.."

const TILES_PER_COLOR = {
	MTile.COLS.AKA: 2,
	MTile.COLS.AO: 4,
	MTile.COLS.KIN: 1,
	MTile.COLS.MURASAKI: 3,
	MTile.COLS.MIDORI: 3
}

func start():
	for c in get_children():
		c.queue_free()
	
	# select 3 random colors
	var colors = []
	for i in range(1, MTile.COLS.size()-1): # avoid "none" and kuro
		colors.append(i)
	while colors.size() > BUTTONS:
		colors.remove_at(randi_range(0,colors.size()-1))
	
	for i in BUTTONS:
		var a: Purchaseable = purchaseable.instantiate()
		add_child(a)
		#var hidden = mini(randi()%(PER_BUTTON+1),randi()%(PER_BUTTON+1))
		#hidden = mini(randi()%(PER_BUTTON+1), hidden)
		var hidden = 0
		a.assign_tiles(tile_counter.get_random_non_colored_ids(TILES_PER_COLOR[colors[i]], 1)[0], hidden)
		# do the following two in this order
		a.color_or_material = colors[i]
		a.assign_type(Purchaseable.TYPES.COLOR)
		a.calc_cost()
		
		# chain together exclusive items
		if exclusive:
			if i < BUTTONS - 1:
				var rect = TextureRect.new()
				rect.texture = chain
				rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
				add_child(rect)
	
	if exclusive:
		add_theme_constant_override("separation", 0)
	
	visible = true
