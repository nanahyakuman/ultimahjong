extends HBoxContainer
@onready var mana_bar = $"../ManaBar"

@onready var item_scene = preload("res://item.tscn")
@onready var item_count_label = $"../ItemCountLabel"

@export var max = 5

func _ready():
	recount()

# update label. since queuefree isnt instantaneous we allow for offsetting
func recount(offset = 0):
	item_count_label.text = "%d/%d" % [get_child_count() + offset, max]

# add mana or reduce counters
func tile_drawn(amount: int = 1):
	mana_bar.add_mana(amount)
	for c in get_children():
		c.decrement(amount)
	update_tile_graphics()

func update_tile_graphics():
	for i in get_children():
		i.update_graphics(mana_bar.mana)

func load_cfg(config: ConfigFile):
	var types = config.get_value("items", "types")
	var charge_types = config.get_value("items", "charge_types")
	var charges = config.get_value("items", "charges")
	for c in types.size():
		var i = item_scene.instantiate()
		i.type = types[c]
		i.charge_type = charge_types[c]
		i.cooldown_counter = charges[c]
		add_child(i)
		i.activate(%MahjongManager, %TileSelectPanel, %PopupTileSelector, %ManaBar, %ShopRoot)
	

func save_cfg(config: ConfigFile):
	var types = []
	var charge_types = []
	var charges = []
	for c in get_children():
		types.append(c.type)
		charge_types.append(c.charge_type)
		charges.append(c.cooldown_counter)
	
	config.set_value("items", "types", types)
	config.set_value("items", "charge_types", charge_types)
	config.set_value("items", "charges", charges)
