##  pretty hacky overall but functional
extends PurchaseablesHolder

@onready var root = $"../../../../.."

const TILES_PER_MAT = {
	MTile.MATS.CERAMIC: 2,
	MTile.MATS.METAL: 2,
	MTile.MATS.VERDANT: 2,
	MTile.MATS.FRAME: 2,
	MTile.MATS.KEBAB: 2,
}

func start():
	for c in get_children():
		c.queue_free()
	
	#  select random mats.
	# dislike how this is static
	var mats = []
	for i in range(1, MTile.MATS.size()):
		mats.append(i)
	
	while mats.size() > BUTTONS:
		mats.remove_at(randi_range(0,mats.size()-1))
	
	for i in BUTTONS:
		var a: Purchaseable = purchaseable.instantiate()
		add_child(a)
		#var hidden = mini(randi()%(PER_BUTTON+1),randi()%(PER_BUTTON+1))
		#hidden = mini(randi()%(PER_BUTTON+1), hidden)
		var hidden = 0
		a.assign_tiles(tile_counter.get_random_non_colored_ids(TILES_PER_MAT[mats[i]], 1)[0], hidden)
		# do the following two in this order
		a.color_or_material = mats[i]
		a.assign_type(Purchaseable.TYPES.MATERIAL)
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
