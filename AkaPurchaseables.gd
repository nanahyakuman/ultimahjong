extends HBoxContainer

@onready var mahjong_manager = %MahjongManager
@onready var tile_counter = mahjong_manager.tile_counter
@onready var shop_root = %ShopRoot

@export var purchaseable: PackedScene

enum TYPES {AKA}
const AKABUTTONS = 3
const PER_AKABUTTON = 3

func start():
	var akas = tile_counter.get_random_non_aka_ids(PER_AKABUTTON, AKABUTTONS)
	
	for c in get_children():
		c.queue_free()
	
	for i in AKABUTTONS:
		var a: Purchaseable = purchaseable.instantiate()
		add_child(a)
		a.assign_tile_ids(akas[i])
		a.assign_type(TYPES.AKA)


func pressed(node: Purchaseable):
	if shop_root.money < node.cost:
		return false
	
	shop_root.adjust_money(-node.cost)
	
	match node.type:
		TYPES.AKA:
			for id in node.tile_ids:
				tile_counter.increment_aka(MTile.tile_from_id(id))
	
	return true
