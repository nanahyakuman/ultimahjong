extends HBoxContainer

@onready var mahjong_manager = %MahjongManager
@onready var tile_counter = mahjong_manager.tile_counter
@onready var upgrades = mahjong_manager.upgrades
@onready var shop_root = %ShopRoot
@onready var cursor_text = %CursorText

@export var purchaseable: PackedScene

@export var type = Purchaseable.TYPES.AKA
@export var BUTTONS = 3
@export var PER_BUTTON = 3

func start():
	var akas
	match type:
		Purchaseable.TYPES.AKA:
			akas = tile_counter.get_random_non_aka_ids(PER_BUTTON, BUTTONS)
		Purchaseable.TYPES.ADD:
			akas = tile_counter.get_random_tiles_to_add(PER_BUTTON, BUTTONS)
	
	for c in get_children():
		c.queue_free()
	
	for i in BUTTONS:
		var a: Purchaseable = purchaseable.instantiate()
		add_child(a)
		var hidden = mini(randi()%(PER_BUTTON+1),randi()%(PER_BUTTON+1))
		hidden = mini(randi()%(PER_BUTTON+1), hidden)
		if akas:
			a.assign_tiles(akas[i], hidden)
		else:
			a.assign_tiles([], 0)
		a.assign_type(type)
		a.calc_cost()
	
	# quick printer to try out different hiding weights
#	var counts = {}
#	for i in PER_BUTTON+1:
#		counts[i] = 0
#	for i in PER_BUTTON+1:
#		for j in PER_BUTTON+1:
#			for k in PER_BUTTON+1:
#				counts[mini(i,mini(j,k))] += 1
#	print(counts)


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
		Purchaseable.TYPES.DEAD_REDUCE:
			upgrades.dead_wall_size_reduce += 2
		Purchaseable.TYPES.KAN_REVEAL:
			upgrades.additional_revealed_kandora += 1
	
	return true


func hovered(node: Purchaseable, yes: bool):
	cursor_text.set_text(node.HOVER_TEXTS[node.type] if yes else "")
