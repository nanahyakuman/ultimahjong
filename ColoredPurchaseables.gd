##  ignores all the exports, lol.
##  pretty hacky overall but functional
extends PurchaseablesHolder

@onready var root = $"../../../../.."

func start():
	for c in get_children():
		c.queue_free()
	
	var i = 0
	for color in [Purchaseable.TYPES.AO, Purchaseable.TYPES.AKA, Purchaseable.TYPES.KIN]:
		var a: Purchaseable = purchaseable.instantiate()
		add_child(a)
		#var hidden = mini(randi()%(PER_BUTTON+1),randi()%(PER_BUTTON+1))
		#hidden = mini(randi()%(PER_BUTTON+1), hidden)
		var hidden = 0
		a.assign_tiles(tile_counter.get_random_non_colored_ids(pow(2, 2-i), 1)[0], hidden)
		a.assign_type(color)
		
		a.cost = 0
		
		i += 1
	
	visible = true

func pressed(node: Purchaseable):
	visible = false
	# prevent you from being able to cycle main menu for infinite dora
	root.last_round_was_victory = false
	return await super.pressed(node)
