extends HBoxContainer
class_name PurchaseablesHolder

@onready var mahjong_manager = %MahjongManager
@onready var tile_counter = mahjong_manager.tile_counter
@onready var upgrades = mahjong_manager.upgrades
@onready var shop_root = %ShopRoot
@onready var items = %Items
@onready var upgrades_grid_container = %UpgradesGridContainer
@onready var score_tracker = %ScoreTracker

@export var purchaseable: PackedScene

@export var type = Purchaseable.TYPES.COLOR
# how many sub buttons to generate
@export var BUTTONS = 3

# only permit one to be bought from the set
@export var exclusive = false
var chain = preload("res://image/chain.png")

func start():
	var tiles
	var valid_items
	var valid_ups
	match type:
		Purchaseable.TYPES.ITEM:
			var possessed_items = []
			for i in items.get_children():
				possessed_items.append(i.type)
			valid_items = Item.TYPES.values()
			for t in possessed_items:
				valid_items.erase(t)
			valid_items.erase(0)
		Purchaseable.TYPES.UPGRADE:
			valid_ups = upgrades_grid_container.get_random_from_pool(BUTTONS)
	
	# clear items but not the labels
	var cs = get_children()
	for i in range(1, cs.size()):
		cs[i].queue_free()
	
	for i in BUTTONS:
		var a: Purchaseable = purchaseable.instantiate()
		add_child(a)
		# no longer used hiding code
		#var hidden_c = mini(randi()%(PER_BUTTON+1),randi()%(PER_BUTTON+1))
		#hidden_c = mini(randi()%(PER_BUTTON+1), hidden_c)
		if tiles:
			a.assign_tiles(tiles[i], 0)#hidden_c)
		else:
			a.assign_tiles([], 0)
		
		a.assign_type(type)
		
		if valid_items:
			# inelegant temp solution while pocchis dont exist
			valid_items.erase(Item.TYPES.ITEM_POCCHI)
			var itm = valid_items.pick_random()
			# 1124
			#var item_type = maxi(0, i - 1)
			var item_type = [1,1,2,2][i]
			a.assign_item(itm, item_type)
			valid_items.erase(itm)
		
		if valid_ups:
			var upr = valid_ups[i]
			a.assign_upgrade(upr)
		
		a.calc_cost()


func pressed(node: Purchaseable):
	if shop_root.money < node.cost:
		return false
	
	if shop_root.state != shop_root.STATE_ACTIVE:
		return false
	
	if node.type == Purchaseable.TYPES.ITEM and items.get_child_count() >= items.max:
		return false
	
	shop_root.adjust_money(-node.cost)
	shop_root.state = shop_root.STATE_ANIMATING
	
	match node.type:
		Purchaseable.TYPES.COLOR:
			for t in node.tiles:
				tile_counter.set_color(t, node.color_or_material)
				await AnimTimer.start_mod(.15)
		Purchaseable.TYPES.MATERIAL:
			for t in node.tiles:
				tile_counter.set_material(t, node.color_or_material)
				await AnimTimer.start_mod(.15)
		Purchaseable.TYPES.ITEM:
			var a = node.item
			a.reparent(items)
			a._mouse_exited()
			a.activate(mahjong_manager, %TileSelectPanel, %PopupTileSelector, %ManaBar, shop_root)
			items.recount()
		Purchaseable.TYPES.UPGRADE:
			var a = node.upgrade
			a.reparent(upgrades_grid_container)
			a.bought(upgrades, tile_counter, score_tracker, false)
			upgrades_grid_container.alert_bought(a.type)
			CursorText.set_text("")
	
	shop_root.state = shop_root.STATE_ACTIVE
	
	if exclusive:
		for c in get_children():
			c.queue_free()
	
	return true

