extends HBoxContainer

@onready var mahjong_manager = %MahjongManager
@onready var tile_counter = mahjong_manager.tile_counter
@onready var shop_root = %ShopRoot

@export var purchaseable: PackedScene

@export var type = Purchaseable.TYPES.AKA
@export var BUTTONS = 3
@export var PER_BUTTON = 3

func start():
	var akas = tile_counter.get_random_non_aka_ids(PER_BUTTON, BUTTONS)
	
	for c in get_children():
		c.queue_free()
	
	for i in BUTTONS:
		var a: Purchaseable = purchaseable.instantiate()
		add_child(a)
		# funny finder function
		# 0: 9  /25
		# 1: 7  /25
		# 2: 5  /25
		# 3: 3  /25
		# 4: 1  /25
		#
		# 0: 7  /16
		# 1: 5  /16
		# 2: 3  /16
		# 3: 1  /16
		a.assign_tiles(akas[i], mini(randi()%(PER_BUTTON+1),randi()%(PER_BUTTON+1)))
		a.assign_type(type)
		a.calc_cost()


func pressed(node: Purchaseable):
	if shop_root.money < node.cost:
		return false
	
	shop_root.adjust_money(-node.cost)
	
	match node.type:
		Purchaseable.TYPES.AKA:
			for t in node.tiles:
				tile_counter.increment_aka(t)
		Purchaseable.TYPES.ADD:
			for t in node.tiles:
				tile_counter.increment_tile(t)
	
	return true
