extends HBoxContainer

@onready var mahjong_manager = %MahjongManager
@onready var tile_counter = mahjong_manager.tile_counter
@onready var upgrades = mahjong_manager.upgrades
@onready var shop_root = %ShopRoot
@onready var anim_timer = %AnimTimer
@onready var items = %Items

@export var purchaseable: PackedScene

@export var type = Purchaseable.TYPES.AKA
@export var BUTTONS = 3
@export var PER_BUTTON = 3

func start():
	var tiles
	var valid_items
	match type:
		Purchaseable.TYPES.AKA:
			tiles = tile_counter.get_random_non_aka_ids(PER_BUTTON, BUTTONS)
		Purchaseable.TYPES.ADD:
			tiles = tile_counter.get_random_tiles_to_add(PER_BUTTON, BUTTONS)
		Purchaseable.TYPES.ITEM:
			var possessed_items = []
			for i in items.get_children():
				possessed_items.append(i.type)
			valid_items = Item.TYPES.values()
			for t in possessed_items:
				valid_items.erase(t)
			valid_items.erase(0)
		
	for c in get_children():
		c.queue_free()
	
	for i in BUTTONS:
		var a: Purchaseable = purchaseable.instantiate()
		add_child(a)
		var hidden = mini(randi()%(PER_BUTTON+1),randi()%(PER_BUTTON+1))
		hidden = mini(randi()%(PER_BUTTON+1), hidden)
		if tiles:
			a.assign_tiles(tiles[i], hidden)
		else:
			a.assign_tiles([], 0)
		a.assign_type(type)
		if valid_items:
			var itm = valid_items.pick_random()
			a.assign_item(itm)
			valid_items.erase(itm)
		
		a.calc_cost()


func pressed(node: Purchaseable):
	if shop_root.money < node.cost:
		return false
	
	if shop_root.state != shop_root.STATE_ACTIVE:
		return false
	
	shop_root.adjust_money(-node.cost)
	shop_root.state = shop_root.STATE_ANIMATING
	
	match node.type:
		Purchaseable.TYPES.AKA:
			for t in node.tiles:
				tile_counter.increment_aka(t)
				await anim_timer.start_mod(.15)
		Purchaseable.TYPES.ADD:
			for t in node.tiles:
				tile_counter.increment_tile(t)
				await anim_timer.start_mod(.15)
		Purchaseable.TYPES.DEAD_REDUCE:
			upgrades.dead_wall_size_reduce += 2
		Purchaseable.TYPES.KAN_REVEAL:
			upgrades.additional_revealed_kandora += 1
		Purchaseable.TYPES.ITEM:
			var a = node.item.duplicate()
			items.add_child(a)
			a.activate(mahjong_manager, %TileSelect)
	
	shop_root.state = shop_root.STATE_ACTIVE
	
	return true


func hovered(node: Purchaseable, yes: bool):
	if !node.item:
		CursorText.set_text(node.HOVER_TEXTS[node.type] if yes else "")
