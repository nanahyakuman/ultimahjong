##  graphically displays items, and also keeps track of item pooling
extends GridContainer

@onready var upgrades: Upgrades
@onready var tile_counter = $"../../../../../../../MahjongRoot/MahjongManager/TileCounter"
@onready var upgrade = preload("res://upgrade.tscn")

var pool: ExpandingCounterDict

func _ready():
	pool = ExpandingCounterDict.new()
	for i in Upgrade.TYPES.size():
		if i == Upgrade.TYPES.UPR_NONE:
			continue
		var count = Upgrade.METADATA[i][Upgrade.METADATA_COUNT]
		pool.add(i, count)


# return an array of randomly selected items left in pool
func get_random_from_pool(amount: int) -> Array:
	var legal = pool.get_count_greater_than(0)
	legal.shuffle()
	legal.resize(amount)
	
	return legal

# reduce the item count by 1
func alert_bought(type: int):
	pool.add(type, -1)

func load_cfg(config: ConfigFile):
	for i in Upgrade.TYPES.size():
		var count = config.get_value("item", str(i), 0)
		for j in count:
			var a = upgrade.instantiate()
			a.type = i
			add_child(a)
			if !upgrades:
				upgrades = $"../../../../../../../MahjongRoot/MahjongManager/Upgrades"
			# retrigger upgrades
			a.bought(upgrades, tile_counter)

func save_cfg(config: ConfigFile):
	var a = ExpandingCounterDict.new()
	for c in get_children():
		a.add(c.type)
	for u in a.counts:
		config.set_value("upgrade", str(u), a.counts[u])
