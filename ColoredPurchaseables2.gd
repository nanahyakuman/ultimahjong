##  ignores all the exports, lol.
##  pretty hacky overall but functional
extends PurchaseablesHolder

@onready var root = $"../../../../.."

const TILES_PER_COLOR = {
	MTile.COL_AKA: 2,
	MTile.COL_AO: 4,
	MTile.COL_KIN: 1,
	MTile.COL_MURASAKI: 3,
	MTile.COL_MIDORI: 3
}

func start():
	for c in get_children():
		c.queue_free()
	
	# select 3 random colors
	var colors = [MTile.COL_AKA, MTile.COL_AO, MTile.COL_KIN, MTile.COL_MURASAKI, MTile.COL_MIDORI]
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
		a.color = colors[i]
		a.assign_type(Purchaseable.TYPES.COLOR)
		a.calc_cost()
	
	visible = true
